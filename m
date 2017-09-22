From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: Re: [PATCH net-next 2/2] net: dsa: lan9303: Add basic offloading of
 unicast traffic
Date: Fri, 22 Sep 2017 09:06:04 +0200
Message-ID: <b27d2dd4-84e3-b930-a6fe-1e5b36a7d213@egil-hjelmeland.no>
References: <20170921094139.4250-1-privat@egil-hjelmeland.no>
 <20170921094139.4250-3-privat@egil-hjelmeland.no>
 <20170921142127.GB27589@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170921142127.GB27589@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Den 21. sep. 2017 16:21, skrev Andrew Lunn:
> Hi Egil
> 
>> +static void lan9303_bridge_ports(struct lan9303 *chip)
>> +{
>> +	/* ports bridged: remove mirroring */
>> +	lan9303_write_switch_reg(chip, LAN9303_SWE_PORT_MIRROR, 0);
>> +}
> 
> Could you replace the 0 with something symbolic which makes this
> easier to understand.
> 
> #define LAN9303_SWE_PORT_MIRROR_DISABLED 0
> 

OK

>> +
>>   static int lan9303_handle_reset(struct lan9303 *chip)
>>   {
>>   	if (!chip->reset_gpio)
>> @@ -844,6 +866,69 @@ static void lan9303_port_disable(struct dsa_switch *ds, int port,
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
>> +		return; /* touching SWE_PORT_STATE will break port separation */
> 
> I'm wondering how this is supposed to work. Please add a good comment
> here, since the hardware is forcing you to do something odd.
> 
> Maybe it would be a good idea to save the STP state in chip.  And then
> when chip->is_bridged is set true, change the state in the hardware to
> the saved value?
> 
> What happens when port 0 is added to the bridge, there is then a
> minute pause and then port 1 is added? I would expect that as soon as
> port 0 is added, the STP state machine for port 0 will start and move
> into listening and then forwarding. Due to hardware limitations it
> looks like you cannot do this. So what state is the hardware
> effectively in? Blocking? Forwarding?
> 
> Then port 1 is added. You can then can respect the states. port 1 will
> do blocking->listening->forwarding, but what about port 0? The calls
> won't get repeated? How does it transition to forwarding?
> 
>    Andrew
> 

I see your point with the "minute pause" argument. Although a bit
contrived use case, it is easy to fix by caching the STP state, as
you suggest. So I can do that.

The port separation method is from the original version of the driver,
not by me.

I have read through the datasheet to see if there are other ways
to make port separation, but I could not find anything.
If anybody care to read through the 300+ page lan9303.pdf and prove
me wrong, I am happy to do it differently.

How does other DSA HW chips handle port separation? Knowing that
could perhaps help me know what to look for.

Egil
'

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
>> +		portstate = LAN9303_SWE_PORT_STATE_DISABLED_PORT0;
>> +		dev_err(chip->dev, "unknown stp state: port %d, state %d\n",
>> +			port, state);
>> +	}
>> +
>> +	portmask = 0x3 << (port * 2);
>> +	portstate     <<= (port * 2);
>> +	lan9303_write_switch_reg_mask(chip, LAN9303_SWE_PORT_STATE,
>> +				      portstate, portmask);
>> +}
> 
