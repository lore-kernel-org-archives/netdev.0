From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [Socketcan-users] [PATCH net-next v2 1/4] can: cc770: add driver
 core for the Bosch CC770 and Intel AN82527
Date: Mon, 28 Nov 2011 14:52:42 +0100
Message-ID: <4ED3922A.50704@grandegger.com>
References: <1322214204-1121-1-git-send-email-wg@grandegger.com> <1322214204-1121-2-git-send-email-wg@grandegger.com> <4ED3704D.5020903@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, socketcan-users@lists.berlios.de,
	linux-can@vger.kernel.org
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <4ED3704D.5020903@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Marc,

thanks for reviewing...

On 11/28/2011 12:28 PM, Marc Kleine-Budde wrote:
> On 11/25/2011 10:43 AM, Wolfgang Grandegger wrote:
>> Signed-off-by: Wolfgang Grandegger <wg@grandegger.com>
>> ---
>>  drivers/net/can/Kconfig            |    2 +
>>  drivers/net/can/Makefile           |    1 +
>>  drivers/net/can/cc770/Kconfig      |    3 +
>>  drivers/net/can/cc770/Makefile     |    7 +
>>  drivers/net/can/cc770/cc770.c      |  895 ++++++++++++++++++++++++++++++++++++
>>  drivers/net/can/cc770/cc770.h      |  234 ++++++++++
>>  include/linux/can/platform/cc770.h |   33 ++
>>  7 files changed, 1175 insertions(+), 0 deletions(-)
>>  create mode 100644 drivers/net/can/cc770/Kconfig
>>  create mode 100644 drivers/net/can/cc770/Makefile
>>  create mode 100644 drivers/net/can/cc770/cc770.c
>>  create mode 100644 drivers/net/can/cc770/cc770.h
>>  create mode 100644 include/linux/can/platform/cc770.h
> 
> I don't know the hardware, but the code looks good to me, some comments:
> - The driver doesn't use NAPI, can this be added

In principle yes but there is little benefit. This CAN controller does
buffer not more than two messages (on msg object 15) and bus errors are
not reported individually, therefore no irq flooding.

> - The rx-handlers have a while(1) loop

Yes, they should be limited.

>   For NAPI you have to add accounting, for the non NAPI case it would
>   be good, too.
> - I think you can move a large number of lines from the .h file into
>   the driver. Code that's not used in the different binding drivers.

Well, not sure if it's worth the effort.

...

>> diff --git a/drivers/net/can/cc770/cc770.c b/drivers/net/can/cc770/cc770.c
>> new file mode 100644
>> index 0000000..47a6965
>> --- /dev/null
>> +++ b/drivers/net/can/cc770/cc770.c
>> @@ -0,0 +1,895 @@
>> +/*
>> + * cc770.c - Bosch CC770 and Intel AN82527 network device driver
>> + *
>> + * Copyright (C) 2009, 2011 Wolfgang Grandegger <wg@grandegger.com>
>> + *
>> + * Derived from the old Socket-CAN i82527 driver:
>> + *
>> + * Copyright (c) 2002-2007 Volkswagen Group Electronic Research
>> + * All rights reserved.
>> + *
>> + * Redistribution and use in source and binary forms, with or without
>> + * modification, are permitted provided that the following conditions
>> + * are met:
>> + * 1. Redistributions of source code must retain the above copyright
>> + *    notice, this list of conditions and the following disclaimer.
>> + * 2. Redistributions in binary form must reproduce the above copyright
>> + *    notice, this list of conditions and the following disclaimer in the
>> + *    documentation and/or other materials provided with the distribution.
>> + * 3. Neither the name of Volkswagen nor the names of its contributors
>> + *    may be used to endorse or promote products derived from this software
>> + *    without specific prior written permission.
>> + *
>> + * Alternatively, provided that this notice is retained in full, this
>> + * software may be distributed under the terms of the GNU General
>> + * Public License ("GPL") version 2, in which case the provisions of the
>> + * GPL apply INSTEAD OF those given above.
>> + *
>> + * The provided data structures and external interfaces from this code
>> + * are not restricted to be used by modules with a GPL compatible license.
>> + *
>> + * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
>> + * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
>> + * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
>> + * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
>> + * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
>> + * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
>> + * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
>> + * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
>> + * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
>> + * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
>> + * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
>> + * DAMAGE.
>> + *
>> + * Send feedback to <socketcan-users@lists.berlios.de>
> 
> please remove :)

Already done in v3.

>> +#include <linux/module.h>
>> +#include <linux/init.h>
>> +#include <linux/kernel.h>
>> +#include <linux/sched.h>
>> +#include <linux/types.h>
>> +#include <linux/fcntl.h>
>> +#include <linux/interrupt.h>
>> +#include <linux/ptrace.h>
>> +#include <linux/string.h>
>> +#include <linux/errno.h>
>> +#include <linux/netdevice.h>
>> +#include <linux/if_arp.h>
>> +#include <linux/if_ether.h>
>> +#include <linux/skbuff.h>
>> +#include <linux/delay.h>
>> +
>> +#include <linux/can.h>
>> +#include <linux/can/dev.h>
>> +#include <linux/can/error.h>
>> +#include <linux/can/dev.h>
>> +#include <linux/can/platform/cc770.h>
>> +
>> +#include "cc770.h"
> 
> Can you move all the definitions that are not needed in the other
> drivers (e.g. ISA, etc.) into this .c file?

Makes sense if the bus drivers are not allowed to access chips
registers, which is currently not the case...

>> +
>> +#define DRV_NAME  "cc770"
>> +
>> +MODULE_AUTHOR("Wolfgang Grandegger <wg@grandegger.com>");
>> +MODULE_LICENSE("GPL v2");
>> +MODULE_DESCRIPTION(DRV_NAME "CAN netdevice driver");
>> +
>> +/*
>> + * The CC770 is a CAN controller from Bosch, which is 100% compatible
>> + * with the AN82527 from Intel, but with "bugs" being fixed and some
>> + * additional functionality, mainly:
>> + *
>> + * 1. RX and TX error counters are readable.
>> + * 2. Support of silent (listen-only) mode.
>> + * 3. Message object 15 can receive all types of frames, also RTR and EFF.
>> + *
>> + * Details are available from Bosch's "CC770_Product_Info_2007-01.pdf",
>> + * which explains in detail the compatibility between the CC770 and the
>> + * 82527. This driver use the additional functionality 3. on real CC770
>> + * devices. Unfortunately, the CC770 does still not store the message
>> + * identifier of received remote transmission request frames and
>> + * therefore it's set to 0.
>> + *
>> + * The message objects 1..14 can be used for TX and RX while the message
>> + * objects 15 is optimized for RX. It has a shadow register for reliable
>> + * data receiption under heavy bus load. Therefore it makes sense to use
>> + * this message object for the needed use case. The frame type (EFF/SFF)
>> + * for the message object 15 can be defined via kernel module parameter
>> + * "msgobj15_eff". If not equal 0, it will receive 29-bit EFF frames,
>> + * otherwise 11 bit SFF messages.
>> + */
>> +static int msgobj15_eff;
>> +module_param(msgobj15_eff, int, S_IRUGO);
>> +MODULE_PARM_DESC(msgobj15_eff, "Extended 29-bit frames for message object 15 "
>> +		 "(default: 11-bit standard frames)");
>> +
>> +static int i82527_compat;
>> +module_param(i82527_compat, int, S_IRUGO);
>> +MODULE_PARM_DESC(i82527_compat, "Strict Intel 82527 comptibility mode "
>> +		 "without using additional functions");
>> +
>> +/*
>> + * This driver uses the last 5 message objects 11..15. The definitions
>> + * and structure below allows to configure and assign them to the real
>> + * message object.
>> + */
>> +static unsigned char cc770_obj_flags[CC770_OBJ_MAX] = {
>> +	[CC770_OBJ_RX0] = CC770_OBJ_FLAG_RX,
>> +	[CC770_OBJ_RX1] = CC770_OBJ_FLAG_RX | CC770_OBJ_FLAG_EFF,
>> +	[CC770_OBJ_RX_RTR0] = CC770_OBJ_FLAG_RX | CC770_OBJ_FLAG_RTR,
>> +	[CC770_OBJ_RX_RTR1] = CC770_OBJ_FLAG_RX | CC770_OBJ_FLAG_RTR |
>> +			      CC770_OBJ_FLAG_EFF,
>> +	[CC770_OBJ_TX] = 0,
>> +};
> 
> Is is worth the trouble making this a per device instance option? In a
> OF-Tree world should this become an "attribute" (or what's the correct
> of-tree word for it?)

Well, only msg object 15 does have double buffering and should therefore
be used for bulk data reception. Therefore we have for the i82527 the
module parameter:

  MODULE_PARM_DESC(msgobj15_eff,
	           "Extended 29-bit frames for message object 15 "
	 	   "(default: 11-bit standard frames)");

For TX we currently use just one object. Anyway, the device tree is not
the right place to define such parameters because it's too static. The
user may want to select it at runtime depending on the application, if
at all. We can change it when there is a *real* requirement.

>> +	for (o = 0; o <  CC770_OBJ_MAX; o++) {
>                          ^^^^^^^^^^^^^
> 
> what about ARRAY_SIZE(priv->obj_flags)

CC770_OBJ_MAX is not derived from a static array definition but as show
below:

  enum {
	CC770_OBJ_RX0 = 0,	/* for receiving normal messages */
	CC770_OBJ_RX1,		/* for receiving normal messages */
	CC770_OBJ_RX_RTR0,	/* for receiving remote transmission requests */
	CC770_OBJ_RX_RTR1,	/* for receiving remote transmission requests */
	CC770_OBJ_TX,		/* for sending messages */
	CC770_OBJ_MAX  <================
  };


> nitpick:
> o is probalby short for object, but usually we use "i" for a for loop
> 
>> +		obj_flags = priv->obj_flags[o];
>> +		mo = obj2msgobj(o);
>> +
>> +		if (obj_flags & CC770_OBJ_FLAG_RX) {
>> +			/*
>> +			 * We don't need extra objects for RTR and EFF if
>> +			 * the additional CC770 functions are enabled.
>> +			 */
>> +			if (priv->control_normal_mode & CTRL_EAF) {
>> +				if (o > 0)
>> +					continue;
>> +				netdev_dbg(dev, "Message object %d for "
>> +					   "RX data, RTR, SFF and EFF\n", mo);
>> +			} else {
>> +				netdev_dbg(dev,
>> +					   "Message object %d for RX %s %s\n",
>> +					   mo, obj_flags & CC770_OBJ_FLAG_RTR ?
>> +					   "RTR" : "data",
>> +					   obj_flags & CC770_OBJ_FLAG_EFF ?
>> +					   "EFF" : "SFF");
>> +			}
>> +
>> +			if (obj_flags & CC770_OBJ_FLAG_EFF)
>> +				msgcfg = MSGCFG_XTD;
>> +			else
>> +				msgcfg = 0;
>> +			if (obj_flags & CC770_OBJ_FLAG_RTR)
>> +				msgcfg |= MSGCFG_DIR;
>> +
>> +			cc770_write_reg(priv, msgobj[mo].config, msgcfg);
>> +			cc770_write_reg(priv, msgobj[mo].ctrl0,
>> +					MSGVAL_SET | TXIE_RES |
>> +					RXIE_SET | INTPND_RES);
>> +
>> +			if (obj_flags & CC770_OBJ_FLAG_RTR)
>> +				cc770_write_reg(priv, msgobj[mo].ctrl1,
>> +						NEWDAT_RES | CPUUPD_SET |
>> +						TXRQST_RES | RMTPND_RES);
>> +			else
>> +				cc770_write_reg(priv, msgobj[mo].ctrl1,
>> +						NEWDAT_RES | MSGLST_RES |
>> +						TXRQST_RES | RMTPND_RES);
>> +		} else {
>> +			netdev_dbg(dev, "Message object %d for "
>> +				   "TX data, RTR, SFF and EFF\n", mo);
>> +
>> +			cc770_write_reg(priv, msgobj[mo].ctrl1,
>> +					RMTPND_RES | TXRQST_RES |
>> +					CPUUPD_RES | NEWDAT_RES);
>> +			cc770_write_reg(priv, msgobj[mo].ctrl0,
>> +					MSGVAL_RES | TXIE_RES |
>> +					RXIE_RES | INTPND_RES);
>> +		}
>> +	}
>> +}
>> +
>> +static void disable_all_objs(const struct cc770_priv *priv)
>> +{
>> +	int i, mo;
> 
> here you use "i"

OK, will fix.

>> +static int cc770_probe_chip(struct net_device *dev)
> 
> nitpick: This chip returns 1 on success and 0 on failure, IMHO unusual
> return value. Why not make it return -ENODEV in case of failure?

OK, will fix.

...

> Are these Hex numbers arbitrary values?

Looks like. Not really a clever probing, though. A comment would be
useful, at least.

>> +	cc770_write_reg(priv, msgobj[1].data[1], 0x25);
>> +	cc770_write_reg(priv, msgobj[2].data[3], 0x52);
>> +	cc770_write_reg(priv, msgobj[10].data[6], 0xc3);
>> +	if ((cc770_read_reg(priv, msgobj[1].data[1]) != 0x25) ||
>> +	    (cc770_read_reg(priv, msgobj[2].data[3]) != 0x52) ||
>> +	    (cc770_read_reg(priv, msgobj[10].data[6]) != 0xc3)) {
>> +		netdev_info(dev, "probing @0x%p failed (pattern)\n",
>> +			    priv->reg_base);
>> +		return 0;
>> +	}
>> +
>> +	/* Check if this chip is a CC770 supporting additional functions */
>> +	if (cc770_read_reg(priv, control) & CTRL_EAF)
>> +		priv->control_normal_mode |= CTRL_EAF;
>> +
>> +	return 1;
>> +}
>> +
>> +static void cc770_start(struct net_device *dev)
>> +{
>> +	struct cc770_priv *priv = netdev_priv(dev);
>> +
>> +	/* leave reset mode */
>> +	if (priv->can.state != CAN_STATE_STOPPED)
>> +		set_reset_mode(dev);
>> +
>> +	/* leave reset mode */
>> +	set_normal_mode(dev);
>> +}
>> +
>> +static int cc770_set_mode(struct net_device *dev, enum can_mode mode)
>> +{
>> +	struct cc770_priv *priv = netdev_priv(dev);
>> +
>> +	if (!priv->open_time)
>> +		return -EINVAL;
>> +
>> +	switch (mode) {
>> +	case CAN_MODE_START:
>> +		cc770_start(dev);
>> +		if (netif_queue_stopped(dev))
>> +			netif_wake_queue(dev);
> 
> The "if (netif_queue_stopped(dev))" is not needed.

OK.

>> +	if (id & CAN_EFF_FLAG) {
>> +		id &= CAN_EFF_MASK;
>> +		cc770_write_reg(priv, msgobj[mo].config,
>> +				(dlc << 4) + rtr + MSGCFG_XTD);
> 
> + is the same as | here, but IMHO bitwise or is more common coding styele.

OK, will fix.

>> +		cc770_write_reg(priv, msgobj[mo].id[3],
>> +				(id << 3) & 0xFFU);
>> +		cc770_write_reg(priv, msgobj[mo].id[2],
>> +				(id >> 5) & 0xFFU);
>> +		cc770_write_reg(priv, msgobj[mo].id[1],
>> +				(id >> 13) & 0xFFU);
>> +		cc770_write_reg(priv, msgobj[mo].id[0],
>> +				(id >> 21) & 0xFFU);
> 
> msgobj[].id[] is an u8, so & 0xff is not needed.

OK.

>> +	} else {
>> +		id &= CAN_SFF_MASK;
>> +		cc770_write_reg(priv, msgobj[mo].config,
>> +				(dlc << 4) + rtr);
>> +		cc770_write_reg(priv, msgobj[mo].id[0],
>> +				(id >> 3) & 0xFFU);
>> +		cc770_write_reg(priv, msgobj[mo].id[1],
>> +				(id << 5) & 0xFFU);
> dito
>> +	}
>> +
>> +	dlc &= 0x0f;		/* restore length only */
> 
> is this needed? The dlc should be valid.

No, can_dropped_invalid_skb() already does the check before.

>> +	for (i = 0; i < dlc; i++)
>> +		cc770_write_reg(priv, msgobj[mo].data[i], cf->data[i]);
>> +
>> +	cc770_write_reg(priv, msgobj[mo].ctrl1,
>> +			RMTPND_RES | TXRQST_SET | CPUUPD_RES | NEWDAT_UNC);
>> +
>> +	stats->tx_bytes += dlc;
>> +
>> +	can_put_echo_skb(skb, dev, 0);
>> +
>> +	/*
>> +	 * HM: We had some cases of repeated IRQs so make sure the
> 
> Who is HM?

Don't know ;-(.

>> +	if (ctrl1 & RMTPND_SET) {
>> +		/*
>> +		 * Unfortunately, the chip does not store the real message
>> +		 * identifier of the received remote transmission request
>> +		 * frame. Therefore we set it to 0.
> 
> What a bug!

Well, it's a basic CAN controller, which is usually handled in a
different way (a CAN id is handled by a dedicated msg object).

>> +	skb = alloc_can_err_skb(dev, &cf);
>> +	if (skb == NULL)
> !skb

Ok, will change.

>> +static void cc770_rx_interrupt(struct net_device *dev, unsigned int o)
>> +{
>> +	struct cc770_priv *priv = netdev_priv(dev);
>> +	struct net_device_stats *stats = &dev->stats;
>> +	unsigned int mo = obj2msgobj(o);
>> +	u8 ctrl1;
>> +
>> +	while (1) {
> 
> What about limiting this?

It does make sense.

>> +	err = request_irq(dev->irq, &cc770_interrupt, priv->irq_flags,
>> +			  dev->name, (void *)dev);
> 
> the (void *) cast ist not needed

OK.


>> +	if (err) {
>> +		close_candev(dev);
>> +		return -EAGAIN;
>> +	}
>> +
>> +	/* init and start chip */
>> +	cc770_start(dev);
>> +	priv->open_time = jiffies;
> 
> open_time is used to track if the netdev is open, right? Can we use
> "ndev->flags & IFF_UP" instead?

Probably, we have similar code in the sja1000.c but not in any other
driver. It is just used in cc770_set_mode(). I guess it's not needed at
all. I will remove it therefore. Need to check if there is a race with
can_restart(), though.

>> +
>> +	netif_start_queue(dev);
>> +
>> +	return 0;
>> +}
>> +
>> +static int cc770_close(struct net_device *dev)
>> +{
>> +	struct cc770_priv *priv = netdev_priv(dev);
>> +
>> +	netif_stop_queue(dev);
>> +	set_reset_mode(dev);
>> +
>> +	free_irq(dev->irq, (void *)dev);
> cast not needed

OK.

...

>> +static __init int cc770_init(void)
>> +{
>> +	if (msgobj15_eff) {
>> +		cc770_obj_flags[CC770_OBJ_RX0] |= CC770_OBJ_FLAG_EFF;
>> +		cc770_obj_flags[CC770_OBJ_RX1] &= ~CC770_OBJ_FLAG_EFF;
>> +	}
>> +
>> +	pr_info("%s CAN netdevice driver\n", DRV_NAME);
> 
> You can add a #define pr_fmt(fmt), to get rid of the "%s", DRV_NAME.

Will add:

  #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt

>> diff --git a/drivers/net/can/cc770/cc770.h b/drivers/net/can/cc770/cc770.h
>> new file mode 100644
>> index 0000000..c6b5800
>> --- /dev/null
>> +++ b/drivers/net/can/cc770/cc770.h
>> @@ -0,0 +1,234 @@
>> +/*
>> + * cc770.h - Bosch CC770 and Intel AN82527 network device driver
>> + *
>> + * Copyright (C) 2009, 2011 Wolfgang Grandegger <wg@grandegger.com>
>> + *
>> + * Derived from the old Socket-CAN i82527 driver:
>> + *
>> + * Copyright (c) 2002-2007 Volkswagen Group Electronic Research
>> + * All rights reserved.
>> + *
>> + * Redistribution and use in source and binary forms, with or without
>> + * modification, are permitted provided that the following conditions
>> + * are met:
>> + * 1. Redistributions of source code must retain the above copyright
>> + *    notice, this list of conditions and the following disclaimer.
>> + * 2. Redistributions in binary form must reproduce the above copyright
>> + *    notice, this list of conditions and the following disclaimer in the
>> + *    documentation and/or other materials provided with the distribution.
>> + * 3. Neither the name of Volkswagen nor the names of its contributors
>> + *    may be used to endorse or promote products derived from this software
>> + *    without specific prior written permission.
>> + *
>> + * Alternatively, provided that this notice is retained in full, this
>> + * software may be distributed under the terms of the GNU General
>> + * Public License ("GPL") version 2, in which case the provisions of the
>> + * GPL apply INSTEAD OF those given above.
>> + *
>> + * The provided data structures and external interfaces from this code
>> + * are not restricted to be used by modules with a GPL compatible license.
>> + *
>> + * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
>> + * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
>> + * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
>> + * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
>> + * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
>> + * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
>> + * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
>> + * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
>> + * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
>> + * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
>> + * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
>> + * DAMAGE.
>> + *
>> + * Send feedback to <socketcan-users@lists.berlios.de>
> 
> please remove

Already done in v3.

Wolfgang.
