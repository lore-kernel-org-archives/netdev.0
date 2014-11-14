From: Roger Quadros <rogerq@ti.com>
Subject: Re: [PATCH v5 6/8] net: can: c_can: Disable pins when CAN interface
 is down
Date: Fri, 14 Nov 2014 15:43:16 +0200
Message-ID: <546606F4.6020102@ti.com>
References: <1415371762-29885-1-git-send-email-rogerq@ti.com> <1415371762-29885-7-git-send-email-rogerq@ti.com> <5464CCFF.5010004@ti.com> <5464D661.7080505@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <wsa@the-dreams.de>, <tony@atomide.com>, <tglx@linutronix.de>,
	<mugunthanvnm@ti.com>, <george.cherian@ti.com>, <balbi@ti.com>,
	<nsekhar@ti.com>, <nm@ti.com>,
	<sergei.shtylyov@cogentembedded.com>, <linux-omap@vger.kernel.org>,
	<linux-can@vger.kernel.org>, <netdev@vger.kernel.org>
To: Marc Kleine-Budde <mkl@pengutronix.de>, <wg@grandegger.com>,
	Linus Walleij <linus.walleij@linaro.org>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <5464D661.7080505@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/13/2014 06:03 PM, Marc Kleine-Budde wrote:
> On 11/13/2014 04:23 PM, Roger Quadros wrote:
>> DRA7 CAN IP suffers from a problem which causes it to be prevented
>> from fully turning OFF (i.e. stuck in transition) if the module was
>> disabled while there was traffic on the CAN_RX line.
>>
>> To work around this issue we select the SLEEP pin state by default
>> on probe and use the DEFAULT pin state on CAN up and back to the
>> SLEEP pin state on CAN down.
>>
>> Signed-off-by: Roger Quadros <rogerq@ti.com>
>> ---
>>  drivers/net/can/c_can/c_can.c | 37 +++++++++++++++++++++++++++++++++++++
>>  drivers/net/can/c_can/c_can.h |  1 +
>>  2 files changed, 38 insertions(+)
>>
>> diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_can.c
>> index 8e78bb4..c80cb3d 100644
>> --- a/drivers/net/can/c_can/c_can.c
>> +++ b/drivers/net/can/c_can/c_can.c
>> @@ -35,6 +35,7 @@
>>  #include <linux/list.h>
>>  #include <linux/io.h>
>>  #include <linux/pm_runtime.h>
>> +#include <linux/pinctrl/consumer.h>
>>  
>>  #include <linux/can.h>
>>  #include <linux/can/dev.h>
>> @@ -587,6 +588,21 @@ static int c_can_chip_config(struct net_device *dev)
>>  	return c_can_set_bittiming(dev);
>>  }
>>  
>> +/*
>> + * Selects the pinctrl state specified in the name.
>> + */
>> +static void c_can_pinctrl_select_state(struct c_can_priv *priv,
>> +				      const char *name)
>> +{
>> +	if (!IS_ERR(priv->pinctrl)) {
>> +		struct pinctrl_state *s;
>> +
>> +		s = pinctrl_lookup_state(priv->pinctrl, name);
>> +		if (!IS_ERR(s))
>> +			pinctrl_select_state(priv->pinctrl, s);
>> +	}
>> +}
>> +
>>  static int c_can_start(struct net_device *dev)
>>  {
>>  	struct c_can_priv *priv = netdev_priv(dev);
>> @@ -603,6 +619,8 @@ static int c_can_start(struct net_device *dev)
>>  
>>  	priv->can.state = CAN_STATE_ERROR_ACTIVE;
>>  
>> +	/* activate pins */
>> +	c_can_pinctrl_select_state(priv, PINCTRL_STATE_DEFAULT);
>>  	return 0;
>>  }
>>  
>> @@ -611,6 +629,9 @@ static void c_can_stop(struct net_device *dev)
>>  	struct c_can_priv *priv = netdev_priv(dev);
>>  
>>  	c_can_irq_control(priv, false);
>> +
>> +	/* deactivate pins */
>> +	c_can_pinctrl_select_state(priv, PINCTRL_STATE_SLEEP);
>>  	priv->can.state = CAN_STATE_STOPPED;
>>  }
>>  
>> @@ -1244,6 +1265,22 @@ int register_c_can_dev(struct net_device *dev)
>>  	struct c_can_priv *priv = netdev_priv(dev);
>>  	int err;
>>  
>> +	priv->pinctrl = devm_pinctrl_get(dev->dev.parent);
> 
> What's dev->dev.parent?
> Ah, this is set by SET_NETDEV_DEV(dev, &pdev->dev); Good work!
> 
> I thought we had to set priv->pinctrl in the platform.c.
> 
>> +	if (!IS_ERR(priv->pinctrl)) {
>> +		struct pinctrl_state *s;
>> +
>> +		/* Deactivate pins to prevent DRA7 DCAN IP from being
>> +		 * stuck in transition when module is disabled.
>> +		 * Pins are activated in c_can_start() and deactivated
>> +		 * in c_can_stop()
>> +		 */
>> +		s = pinctrl_lookup_state(priv->pinctrl, PINCTRL_STATE_SLEEP);
>> +		if (!IS_ERR(s))
>> +			pinctrl_select_state(priv->pinctrl, s);
>> +	} else {
>> +		netdev_dbg(dev, "failed to get pinctrl\n");
>> +	}
>> +
> The above can be replace by this?
> 
> 	c_can_pinctrl_select_state(priv, PINCTRL_STATE_SLEEP)

Yes, indeed.

> 
> Then we don't have the worrying looking error message if there isn't any
> pinctrl, e.g. for the PCI driver with pinctrl enabled in the Kernel.
> 
> I just stumbled over pinctrl_pm_select_sleep_state(), is it possible to
> integrate this into runtime pm?
> 
> http://lxr.free-electrons.com/source/drivers/pinctrl/core.c#L1282

I think those functions are there for the same reason but not sure why aren't 
they used in runtime pm core.

Linus W. any hints?

cheers,
-roger

> 
>>  	c_can_pm_runtime_enable(priv);
>>  
>>  	dev->flags |= IFF_ECHO;	/* we support local echo */
>> diff --git a/drivers/net/can/c_can/c_can.h b/drivers/net/can/c_can/c_can.h
>> index c6715ca..3cedf48 100644
>> --- a/drivers/net/can/c_can/c_can.h
>> +++ b/drivers/net/can/c_can/c_can.h
>> @@ -210,6 +210,7 @@ struct c_can_priv {
>>  	u32 comm_rcv_high;
>>  	u32 rxmasked;
>>  	u32 dlc[C_CAN_MSG_OBJ_TX_NUM];
>> +	struct pinctrl *pinctrl;
>>  };
>>  
>>  struct net_device *alloc_c_can_dev(void);
>>
> 
> Marc
> 

