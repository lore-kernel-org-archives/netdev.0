From: Roger Quadros <rogerq@ti.com>
Subject: Re: [PATCH v5 4/8] net: can: c_can: Add syscon/regmap RAMINIT mechanism
Date: Fri, 14 Nov 2014 18:42:59 +0200
Message-ID: <54663113.1020305@ti.com>
References: <1415371762-29885-1-git-send-email-rogerq@ti.com> <1415371762-29885-5-git-send-email-rogerq@ti.com> <546621C3.3010804@ti.com> <54662E9B.9030104@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <wsa@the-dreams.de>, <tony@atomide.com>, <tglx@linutronix.de>,
	<mugunthanvnm@ti.com>, <george.cherian@ti.com>, <balbi@ti.com>,
	<nsekhar@ti.com>, <nm@ti.com>,
	<sergei.shtylyov@cogentembedded.com>, <linux-omap@vger.kernel.org>,
	<linux-can@vger.kernel.org>, <netdev@vger.kernel.org>
To: Marc Kleine-Budde <mkl@pengutronix.de>, <wg@grandegger.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <54662E9B.9030104@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/14/2014 06:32 PM, Marc Kleine-Budde wrote:
> On 11/14/2014 04:37 PM, Roger Quadros wrote:
>> Some TI SoCs like DRA7 have a RAMINIT register specification
>> different from the other AMxx SoCs and as expected by the
>> existing driver.
>>
>> To add more insanity, this register is shared with other
>> IPs like DSS, PCIe and PWM.
>>
>> Provides a more generic mechanism to specify the RAMINIT
>> register location and START/DONE bit position and use the
>> syscon/regmap framework to access the register.
>>
>> Signed-off-by: Roger Quadros <rogerq@ti.com>
>> ---
>>  .../devicetree/bindings/net/can/c_can.txt          |   3 +
>>  drivers/net/can/c_can/c_can.h                      |  11 +-
>>  drivers/net/can/c_can/c_can_platform.c             | 113 ++++++++++++++-------
>>  3 files changed, 87 insertions(+), 40 deletions(-)
>>
>> diff --git a/Documentation/devicetree/bindings/net/can/c_can.txt b/Documentation/devicetree/bindings/net/can/c_can.txt
>> index 8f1ae81..a3ca3ee 100644
>> --- a/Documentation/devicetree/bindings/net/can/c_can.txt
>> +++ b/Documentation/devicetree/bindings/net/can/c_can.txt
>> @@ -12,6 +12,9 @@ Required properties:
>>  Optional properties:
>>  - ti,hwmods		: Must be "d_can<n>" or "c_can<n>", n being the
>>  			  instance number
>> +- syscon-raminit	: Handle to system control region that contains the
>> +			  RAMINIT register, register offset to the RAMINIT
>> +			  register and the CAN instance number (0 offset).
>>  
>>  Note: "ti,hwmods" field is used to fetch the base address and irq
>>  resources from TI, omap hwmod data base during device registration.
>> diff --git a/drivers/net/can/c_can/c_can.h b/drivers/net/can/c_can/c_can.h
>> index 3c305a1..0e17c7b 100644
>> --- a/drivers/net/can/c_can/c_can.h
>> +++ b/drivers/net/can/c_can/c_can.h
>> @@ -179,6 +179,14 @@ struct c_can_driver_data {
>>  	bool raminit_pulse;	/* If set, sets and clears START bit (pulse) */
>>  };
>>  
>> +/* Out of band RAMINIT register access via syscon regmap */
>> +struct c_can_raminit {
>> +	struct regmap *syscon;	/* for raminit ctrl. reg. access */
>> +	unsigned int reg;	/* register index within syscon */
>> +	u8 start_bit;
>> +	u8 done_bit;
>> +};
>> +
>>  /* c_can private data structure */
>>  struct c_can_priv {
>>  	struct can_priv can;	/* must be the first member */
>> @@ -196,8 +204,7 @@ struct c_can_priv {
>>  	const u16 *regs;
>>  	void *priv;		/* for board-specific data */
>>  	enum c_can_dev_id type;
>> -	u32 __iomem *raminit_ctrlreg;
>> -	int instance;
>> +	struct c_can_raminit raminit_sys;	/* RAMINIT via syscon regmap */
>>  	void (*raminit) (const struct c_can_priv *priv, bool enable);
>>  	u32 comm_rcv_high;
>>  	u32 rxmasked;
>> diff --git a/drivers/net/can/c_can/c_can_platform.c b/drivers/net/can/c_can/c_can_platform.c
>> index 1546c2b..89739a1 100644
>> --- a/drivers/net/can/c_can/c_can_platform.c
>> +++ b/drivers/net/can/c_can/c_can_platform.c
>> @@ -32,14 +32,13 @@
>>  #include <linux/clk.h>
>>  #include <linux/of.h>
>>  #include <linux/of_device.h>
>> +#include <linux/mfd/syscon.h>
>> +#include <linux/regmap.h>
>>  
>>  #include <linux/can/dev.h>
>>  
>>  #include "c_can.h"
>>  
>> -#define CAN_RAMINIT_START_MASK(i)	(0x001 << (i))
>> -#define CAN_RAMINIT_DONE_MASK(i)	(0x100 << (i))
>> -#define CAN_RAMINIT_ALL_MASK(i)		(0x101 << (i))
>>  #define DCAN_RAM_INIT_BIT		(1 << 3)
>>  static DEFINE_SPINLOCK(raminit_lock);
>>  /*
>> @@ -72,47 +71,61 @@ static void c_can_plat_write_reg_aligned_to_32bit(const struct c_can_priv *priv,
>>  	writew(val, priv->base + 2 * priv->regs[index]);
>>  }
>>  
>> -static void c_can_hw_raminit_wait_ti(const struct c_can_priv *priv, u32 mask,
>> -				  u32 val)
>> +static void c_can_hw_raminit_wait_syscon(const struct c_can_priv *priv,
>> +					 u32 mask, u32 val)
>>  {
>>  	int timeout = 0;
>> +	const struct c_can_raminit *raminit = &priv->raminit_sys;
>> +	u32 ctrl;
>> +
>>  	/* We look only at the bits of our instance. */
>>  	val &= mask;
>> -	while ((readl(priv->raminit_ctrlreg) & mask) != val) {
>> +	do {
>>  		udelay(1);
>>  		timeout++;
>>  
>> +		regmap_read(raminit->syscon, raminit->reg, &ctrl);
>>  		if (timeout == 1000) {
>>  			dev_err(&priv->dev->dev, "%s: time out\n", __func__);
>>  			break;
>>  		}
>> -	}
>> +	} while ((ctrl & mask) != val);
>>  }
>>  
>> -static void c_can_hw_raminit_ti(const struct c_can_priv *priv, bool enable)
>> +static void c_can_hw_raminit_syscon(const struct c_can_priv *priv, bool enable)
>>  {
>> -	u32 mask = CAN_RAMINIT_ALL_MASK(priv->instance);
>> +	u32 mask;
>>  	u32 ctrl;
>> +	const struct c_can_raminit *raminit = &priv->raminit_sys;
>> +	u8 start_bit, done_bit;
>> +
>> +	start_bit = raminit->start_bit;
>> +	done_bit = raminit->done_bit;
>>  
>>  	spin_lock(&raminit_lock);
>>  
>> -	ctrl = readl(priv->raminit_ctrlreg);
>> +	mask = 1 << start_bit | 1 << done_bit;
>> +	regmap_read(raminit->syscon, raminit->reg, &ctrl);
>> +
>>  	/* We clear the done and start bit first. The start bit is
>>  	 * looking at the 0 -> transition, but is not self clearing;
>>  	 * And we clear the init done bit as well.
>> +	 * NOTE: DONE must be written with 1 to clear it.
>>  	 */
>> -	ctrl &= ~CAN_RAMINIT_START_MASK(priv->instance);
>> -	ctrl |= CAN_RAMINIT_DONE_MASK(priv->instance);
>> -	writel(ctrl, priv->raminit_ctrlreg);
>> -	ctrl &= ~CAN_RAMINIT_DONE_MASK(priv->instance);
>> -	c_can_hw_raminit_wait_ti(priv, mask, ctrl);
>> +	ctrl &= ~(1 << start_bit);
>> +	ctrl |= 1 << done_bit;
>> +	regmap_write(raminit->syscon, raminit->reg, ctrl);
>> +
>> +	ctrl &= ~(1 << done_bit);
>> +	c_can_hw_raminit_wait_syscon(priv, mask, ctrl);
>>  
>>  	if (enable) {
>>  		/* Set start bit and wait for the done bit. */
>> -		ctrl |= CAN_RAMINIT_START_MASK(priv->instance);
>> -		writel(ctrl, priv->raminit_ctrlreg);
>> -		ctrl |= CAN_RAMINIT_DONE_MASK(priv->instance);
>> -		c_can_hw_raminit_wait_ti(priv, mask, ctrl);
>> +		ctrl |= 1 << start_bit;
>> +		regmap_write(raminit->syscon, raminit->reg, ctrl);
>> +
>> +		ctrl |= 1 << done_bit;
>> +		c_can_hw_raminit_wait_syscon(priv, mask, ctrl);
>>  	}
>>  	spin_unlock(&raminit_lock);
>>  }
> 
> My arm gcc-4.7.2 spits this warnings, I'll initialize ctrl to 0.

My 4.7.3 doesn't. Initializing to 0 is fine as well.

cheers,
-roger

> 
>> drivers/net/can/c_can/c_can_platform.c: In function 'c_can_hw_raminit_wait_syscon':
>> drivers/net/can/c_can/c_can_platform.c:92:17: warning: 'ctrl' may be used uninitialized in this function [-Wuninitialized]
>> drivers/net/can/c_can/c_can_platform.c: In function 'c_can_hw_raminit_syscon':
>> drivers/net/can/c_can/c_can_platform.c:115:7: warning: 'ctrl' is used uninitialized in this function [-Wuninitialized]
> 
> Marc
> 

