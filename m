From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH RFC 1/2] net: dsa: integrate with SWITCHDEV for HW bridging
Date: Tue, 17 Feb 2015 19:53:45 -0800
Message-ID: <54E40CC9.2000505@roeck-us.net>
References: <1424201196-4901-1-git-send-email-f.fainelli@gmail.com> <1424201196-4901-2-git-send-email-f.fainelli@gmail.com> <20150218011955.GA17155@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, cphealy@gmail.com
To: Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:50826 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751549AbbBRDyT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2015 22:54:19 -0500
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YNviM-003EUL-Bg
	for netdev@vger.kernel.org; Wed, 18 Feb 2015 03:54:18 +0000
In-Reply-To: <20150218011955.GA17155@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/17/2015 05:19 PM, Andrew Lunn wrote:
>> +/* Return a bitmask of all ports being currently bridged. Note that on
>> + * leave, the mask will still return the bitmask of ports currently bridged,
>> + * prior to port removal, and this is exactly what we want.
>> + */
>> +static u32 dsa_slave_br_port_mask(struct dsa_switch *ds)
>> +{
>> +	unsigned int port;
>> +	u32 mask = 0;
>> +
>> +	for (port = 0; port < DSA_MAX_PORTS; port++) {
>> +		if (!((1 << port) & ds->phys_port_mask))
>> +			continue;
>> +
>> +		if (ds->ports[port]->priv_flags & IFF_BRIDGE_PORT)
>> +			mask |= 1 << port;
>> +	}
>> +
>> +       return mask;
>> +}
>> +
>> +static int dsa_slave_bridge_port_join(struct net_device *dev,
>> +				      struct net_device *bridge)
>> +{
>> +	struct dsa_slave_priv *p = netdev_priv(dev);
>> +	struct dsa_switch *ds = p->parent;
>> +	int ret = -EOPNOTSUPP;
>> +
>> +	if (ds->drv->port_join_bridge)
>> +		ret = ds->drv->port_join_bridge(ds, p->port,
>> +						dsa_slave_br_port_mask(ds));
>
> Hi Florian
>
> Shouldn't this bridge port mask also be dependent on bridge?
>
> I'm thinking of cases like
>
> brctl addbr br0
> brctl addif br0 lan0
> brctl addif br0 lan1
>
> brctl addbr br1
> brctl addif br1 lan2
> brctl addif br1 lan3
>
> We have two software bridges, so need two masks.  It does look like
> your hardware and the Marvell hardware supports this, disjoint sets of
> bridged ports.  But with the current implementation, your going to end
> up with one hardware bridge with four ports, and broken STP.
>

Same problem here.

With the code above I see the ports which are part of "a" bridge group,
but I can not determine which group the port is supposed to join.

I don't really see the value in providing the port mask to
port_join_bridge, but maybe I am missing something. In my
implementation I just passed on bridge * and used it to
determine which port belongs to which bridge group.
It doesn't have to be that, but maybe we can use the bridge
ifindex or anything else that lets me determine which bridge
group the port belongs to.

Guenter
