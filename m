From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: Re: [PATCH net-next v2 07/10] net: dsa: lan9303: Added basic
 offloading of unicast traffic
Date: Thu, 27 Jul 2017 13:21:55 +0200
Message-ID: <19cbabee-a0e5-03f1-d2fa-eea3521311a8@egil-hjelmeland.no>
References: <20170725161553.30147-1-privat@egil-hjelmeland.no>
 <20170725161553.30147-8-privat@egil-hjelmeland.no>
 <20170726172443.GR12049@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: corbet@lwn.net, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, davem@davemloft.net, kernel@pengutronix.de,
        linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20170726172443.GR12049@lunn.ch>
Content-Language: en-US
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 26. juli 2017 19:24, Andrew Lunn wrote:
> Hi Egil
> 
>> +/* forward special tagged packets from port 0 to port 1 *or* port 2 */
>> +static int lan9303_setup_tagging(struct lan9303 *chip)
>> +{
>> +	int ret;
> 
> Blank line please.
> 
> 
>> +	/* enable defining the destination port via special VLAN tagging
>> +	 * for port 0
>> +	 */
>> +	ret = lan9303_write_switch_reg(chip, LAN9303_SWE_INGRESS_PORT_TYPE,
>> +				       0x03);
> 
> #define for 0x03.
> 
>> +	if (ret)
>> +		return ret;
>> +
>> +	/* tag incoming packets at port 1 and 2 on their way to port 0 to be
>> +	 * able to discover their source port
>> +	 */
>> +	return lan9303_write_switch_reg(
>> +		chip, LAN9303_BM_EGRSS_PORT_TYPE,
>> +		LAN9303_BM_EGRSS_PORT_TYPE_SPECIAL_TAG_PORT0);
>> +}
>> +
>>   /* We want a special working switch:
>>    * - do not forward packets between port 1 and 2
>>    * - forward everything from port 1 to port 0
>>    * - forward everything from port 2 to port 0
>> - * - forward special tagged packets from port 0 to port 1 *or* port 2
>>    */
>>   static int lan9303_separate_ports(struct lan9303 *chip)
>>   {
>> @@ -534,22 +555,6 @@ static int lan9303_separate_ports(struct lan9303 *chip)
>>   	if (ret)
>>   		return ret;
>>   
>> -	/* enable defining the destination port via special VLAN tagging
>> -	 * for port 0
>> -	 */
>> -	ret = lan9303_write_switch_reg(chip, LAN9303_SWE_INGRESS_PORT_TYPE,
>> -				       0x03);
>> -	if (ret)
>> -		return ret;
>> -
>> -	/* tag incoming packets at port 1 and 2 on their way to port 0 to be
>> -	 * able to discover their source port
>> -	 */
>> -	ret = lan9303_write_switch_reg(chip, LAN9303_BM_EGRSS_PORT_TYPE,
>> -			LAN9303_BM_EGRSS_PORT_TYPE_SPECIAL_TAG_PORT0);
>> -	if (ret)
>> -		return ret;
>> -
>>   	/* prevent port 1 and 2 from forwarding packets by their own */
>>   	return lan9303_write_switch_reg(chip, LAN9303_SWE_PORT_STATE,
>>   				LAN9303_SWE_PORT_STATE_FORWARDING_PORT0 |
>> @@ -557,6 +562,12 @@ static int lan9303_separate_ports(struct lan9303 *chip)
>>   				LAN9303_SWE_PORT_STATE_BLOCKING_PORT2);
>>   }
>>   
>> +static void lan9303_bridge_ports(struct lan9303 *chip)
>> +{
>> +	/* ports bridged: remove mirroring */
>> +	lan9303_write_switch_reg(chip, LAN9303_SWE_PORT_MIRROR, 0);
>> +}
>> +
>>   static int lan9303_handle_reset(struct lan9303 *chip)
>>   {
>>   	if (!chip->reset_gpio)
>> @@ -707,6 +718,10 @@ static int lan9303_setup(struct dsa_switch *ds)
>>   		return -EINVAL;
>>   	}
>>   
>> +	ret = lan9303_setup_tagging(chip);
>> +	if (ret)
>> +		dev_err(chip->dev, "failed to setup port tagging %d\n", ret);
>> +
>>   	ret = lan9303_separate_ports(chip);
>>   	if (ret)
>>   		dev_err(chip->dev, "failed to separate ports %d\n", ret);
>> @@ -898,17 +913,81 @@ static void lan9303_port_disable(struct dsa_switch *ds, int port,
>>   	}
>>   }
>>   
>> +static int lan9303_port_bridge_join(struct dsa_switch *ds, int port,
>> +				    struct net_device *br)
>> +{
>> +	struct lan9303 *chip = ds->priv;
>> +
>> +	dev_dbg(chip->dev, "%s(port %d)\n", __func__, port);
>> +	if (ds->ports[1].bridge_dev ==  ds->ports[2].bridge_dev) {
>> +		lan9303_bridge_ports(chip);
>> +		chip->is_bridged = true;  /* unleash stp_state_set() */
>> +	}
>> +
>> +	return 0;
>> +}
>> +
>> +static void lan9303_port_bridge_leave(struct dsa_switch *ds, int port,
>> +				      struct net_device *br)
>> +{
>> +	struct lan9303 *chip = ds->priv;
>> +
>> +	dev_dbg(chip->dev, "%s(port %d)\n", __func__, port);
>> +	if (chip->is_bridged) {
>> +		lan9303_separate_ports(chip);
>> +		chip->is_bridged = false;
>> +	}
>> +}
>> +
>> +static void lan9303_port_stp_state_set(struct dsa_switch *ds, int port,
>> +				       u8 state)
>> +{
>> +	int portmask, portstate;
>> +	struct lan9303 *chip = ds->priv;
>> +
>> +	dev_dbg(chip->dev, "%s(port %d, state %d)\n",
>> +		__func__, port, state);
>> +	if (!chip->is_bridged)
>> +		return;
> 
> I think you are over-simplifying here. Say i have a layer 2 VPN and i
> bridge port 1 and the VPN? The software bridge still wants to do STP
> on port 1, in order to solve loops.
> 

Problem is that the mainline lan9303_separate_ports() does its
work by setting port 1 & 2 in STP BLOCKING state (and port 0 in
FORWARDING state). So my understanding is that it would break port
separation if LAN9303_SWE_PORT_STATE is written while the driver
is in the non-bridged state.

I thought the SW bridge would carry doing its STP work even if
there is a port_stp_state_set method on a DSA port?

>> +
>> +	switch (state) {
>> +	case BR_STATE_DISABLED:
>> +		portstate = LAN9303_SWE_PORT_STATE_DISABLED_PORT0;
>> +		break;
>> +	case BR_STATE_BLOCKING:
>> +	case BR_STATE_LISTENING:
>> +		portstate = LAN9303_SWE_PORT_STATE_BLOCKING_PORT0;
>> +		break;
>> +	case BR_STATE_LEARNING:
>> +		portstate = LAN9303_SWE_PORT_STATE_LEARNING_PORT0;
>> +		break;
>> +	case BR_STATE_FORWARDING:
>> +		portstate = LAN9303_SWE_PORT_STATE_FORWARDING_PORT0;
>> +		break;
>> +	default:
>> +		dev_err(chip->dev, "%s(port %d, state %d)\n",
>> +			__func__, port, state);
>> +	}
>> +	portmask = 0x3 << (port * 2);
>> +	portstate     <<= (port * 2);
>> +	lan9303_write_switch_reg_mask(chip, LAN9303_SWE_PORT_STATE,
>> +				      portstate, portmask);
>> +}
> 
> 
> 
> 
>> +
>>   static struct dsa_switch_ops lan9303_switch_ops = {
>>   	.get_tag_protocol = lan9303_get_tag_protocol,
>>   	.setup = lan9303_setup,
>> -	.get_strings = lan9303_get_strings,
> 
> ????
> 
>>   	.phy_read = lan9303_phy_read,
>>   	.phy_write = lan9303_phy_write,
>>   	.adjust_link = lan9303_adjust_link,
>> +	.get_strings = lan9303_get_strings,
> 
> Please don't include other unrelated changes.
> 
>         Andrew
> 

