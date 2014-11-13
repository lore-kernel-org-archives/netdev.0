From: Roger Quadros <rogerq@ti.com>
Subject: Re: [PATCH v5 6/8] net: can: c_can: Disable pins when CAN interface
 is down
Date: Thu, 13 Nov 2014 15:04:57 +0200
Message-ID: <5464AC79.9080601@ti.com>
References: <1415371762-29885-1-git-send-email-rogerq@ti.com> <1415371762-29885-7-git-send-email-rogerq@ti.com> <54636BD0.2010208@ti.com> <5464AA61.4080606@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <wsa@the-dreams.de>, <tony@atomide.com>, <tglx@linutronix.de>,
	<mugunthanvnm@ti.com>, <george.cherian@ti.com>, <balbi@ti.com>,
	<nsekhar@ti.com>, <nm@ti.com>,
	<sergei.shtylyov@cogentembedded.com>, <linux-omap@vger.kernel.org>,
	<linux-can@vger.kernel.org>, <netdev@vger.kernel.org>
To: Marc Kleine-Budde <mkl@pengutronix.de>, <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:47561 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932622AbaKMNFW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2014 08:05:22 -0500
In-Reply-To: <5464AA61.4080606@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/13/2014 02:56 PM, Marc Kleine-Budde wrote:
> On 11/12/2014 03:16 PM, Roger Quadros wrote:
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
>>  drivers/net/can/c_can/c_can.c          | 21 +++++++++++++++++++++
>>  drivers/net/can/c_can/c_can.h          |  1 +
>>  drivers/net/can/c_can/c_can_platform.c | 20 ++++++++++++++++++++
>>  3 files changed, 42 insertions(+)
>>
>> diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_can.c
>> index 8e78bb4..a950eea 100644
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
> 
> What happens if priv->pinctrl is NULL? This is probably the case with
> the c_can_pci driver.

There will be a NULL pointer dereference error. :(

> 
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
>> diff --git a/drivers/net/can/c_can/c_can_platform.c b/drivers/net/can/c_can/c_can_platform.c
>> index b838c6b..71b9063 100644
>> --- a/drivers/net/can/c_can/c_can_platform.c
>> +++ b/drivers/net/can/c_can/c_can_platform.c
>> @@ -34,6 +34,7 @@
>>  #include <linux/of_device.h>
>>  #include <linux/mfd/syscon.h>
>>  #include <linux/regmap.h>
>> +#include <linux/pinctrl/consumer.h>
>>  
>>  #include <linux/can/dev.h>
>>  
>> @@ -230,6 +231,7 @@ static int c_can_plat_probe(struct platform_device *pdev)
>>  	struct clk *clk;
>>  	const struct c_can_driver_data *drvdata;
>>  	struct device_node *np = pdev->dev.of_node;
>> +	struct pinctrl *pinctrl;
>>  
>>  	match = of_match_device(c_can_of_table, &pdev->dev);
>>  	if (match) {
>> @@ -241,6 +243,23 @@ static int c_can_plat_probe(struct platform_device *pdev)
>>  		return -ENODEV;
>>  	}
>>  
>> +	pinctrl = devm_pinctrl_get(&pdev->dev);
>> +	if (!IS_ERR(pinctrl)) {
>> +		struct pinctrl_state *s;
>> +
>> +		/* Deactivate pins to prevent DRA7 DCAN IP from being
>> +		 * stuck in transition when module is disabled.
>> +		 * Pins are activated in c_can_start() and deactivated
>> +		 * in c_can_stop()
>> +		 */
>> +		s = pinctrl_lookup_state(pinctrl, PINCTRL_STATE_SLEEP);
>> +		if (!IS_ERR(s))
>> +			pinctrl_select_state(pinctrl, s);
>> +	} else {
>> +		dev_warn(&pdev->dev,
>> +			 "failed to get pinctrl\n");
>> +	}
> 
> Can you move the initial setting into c_can.c, register_c_can_dev()
> should be a good candidate.

OK. This should also address the NULL pointer issue you pointed out earlier with c_can_pci.

cheers,
-roger


> 
>> +
>>  	/* get the appropriate clk */
>>  	clk = devm_clk_get(&pdev->dev, NULL);
>>  	if (IS_ERR(clk)) {
>> @@ -270,6 +289,7 @@ static int c_can_plat_probe(struct platform_device *pdev)
>>  	}
>>  
>>  	priv = netdev_priv(dev);
>> +	priv->pinctrl = pinctrl;
>>  
>>  	switch (drvdata->id) {
>>  	case BOSCH_C_CAN:
>>
> 
> Marc
> 
