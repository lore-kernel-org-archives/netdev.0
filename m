From: Roger Quadros <rogerq@ti.com>
Subject: Re: [PATCH] net: davinci_mdio: add GPIO reset logic
Date: Thu, 6 Apr 2017 12:15:10 +0300
Message-ID: <485433e3-1a9f-71f6-afc9-88e646cf43d1@ti.com>
References: <1491381237-24635-1-git-send-email-rogerq@ti.com>
 <20170405150334.GI13449@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <tony@atomide.com>, <nsekhar@ti.com>,
        <jsarha@ti.com>, <netdev@vger.kernel.org>,
        <linux-omap@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170405150334.GI13449@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On 05/04/17 18:03, Andrew Lunn wrote:
> On Wed, Apr 05, 2017 at 11:33:57AM +0300, Roger Quadros wrote:
>> Some boards [1] leave the PHYs at an invalid state
>> during system power-up or reset thus causing unreliability
>> issues with the PHY like not being detected by the mdio bus
>> or link not functional. To work around these boards have
>> a GPIO connected to the PHY's reset pin.
>>
>> Implement GPIO reset handling for such cases.
>>
>> [1] - am572x-idk, am571x-idk, a437x-idk.
>>
>> Signed-off-by: Roger Quadros <rogerq@ti.com>
>> Signed-off-by: Sekhar Nori <nsekhar@ti.com>
>> ---
>>  .../devicetree/bindings/net/davinci-mdio.txt       |  2 +
>>  drivers/net/ethernet/ti/davinci_mdio.c             | 68 +++++++++++++++++++---
>>  2 files changed, 62 insertions(+), 8 deletions(-)
>>
>> diff --git a/Documentation/devicetree/bindings/net/davinci-mdio.txt b/Documentation/devicetree/bindings/net/davinci-mdio.txt
>> index 621156c..fd6ebe7 100644
>> --- a/Documentation/devicetree/bindings/net/davinci-mdio.txt
>> +++ b/Documentation/devicetree/bindings/net/davinci-mdio.txt
>> @@ -12,6 +12,8 @@ Required properties:
>>  
>>  Optional properties:
>>  - ti,hwmods		: Must be "davinci_mdio"
>> +- reset-gpios		: array of GPIO specifier for PHY hardware reset control
>> +- reset-delay-us	: reset assertion time [in microseconds]
>>  
>>  Note: "ti,hwmods" field is used to fetch the base address and irq
>>  resources from TI, omap hwmod data base during device registration.
>> diff --git a/drivers/net/ethernet/ti/davinci_mdio.c b/drivers/net/ethernet/ti/davinci_mdio.c
>> index 33df340..c6f9e55 100644
>> --- a/drivers/net/ethernet/ti/davinci_mdio.c
>> +++ b/drivers/net/ethernet/ti/davinci_mdio.c
>> @@ -40,6 +40,9 @@
>>  #include <linux/of_device.h>
>>  #include <linux/of_mdio.h>
>>  #include <linux/pinctrl/consumer.h>
>> +#include <linux/gpio.h>
>> +#include <linux/gpio/consumer.h>
>> +#include <linux/of_gpio.h>
>>  
>>  /*
>>   * This timeout definition is a worst-case ultra defensive measure against
>> @@ -53,6 +56,8 @@
>>  
>>  #define DEF_OUT_FREQ		2200000		/* 2.2 MHz */
>>  
>> +#define DEFAULT_GPIO_RESET_DELAY	10	/* in microseconds */
>> +
>>  struct davinci_mdio_of_param {
>>  	int autosuspend_delay_ms;
>>  };
>> @@ -104,6 +109,9 @@ struct davinci_mdio_data {
>>  	 */
>>  	bool		skip_scan;
>>  	u32		clk_div;
>> +	struct gpio_desc **gpio_reset;
>> +	int		num_gpios;
>> +	int		reset_delay_us;
>>  };
>>  
>>  static void davinci_mdio_init_clk(struct davinci_mdio_data *data)
>> @@ -142,6 +150,20 @@ static void davinci_mdio_enable(struct davinci_mdio_data *data)
>>  	__raw_writel(data->clk_div | CONTROL_ENABLE, &data->regs->control);
>>  }
>>  
>> +static void __davinci_gpio_reset(struct davinci_mdio_data *data)
>> +{
>> +	int i;
>> +
>> +	for (i = 0; i < data->num_gpios; i++) {
>> +		if (!data->gpio_reset[i])
>> +			continue;
>> +
>> +		gpiod_set_value_cansleep(data->gpio_reset[i], 1);
>> +		udelay(data->reset_delay_us);
>> +		gpiod_set_value_cansleep(data->gpio_reset[i], 0);
>> +	}
>> +}
> 
> Do you really need more than one GPIO? A single gpio would make all
> this code a lot simpler.
> 

Yes we need. Some of our boards have separate GPIO RESET lines for
different PHYs on the same MDIO bus.

cheers,
-roger
