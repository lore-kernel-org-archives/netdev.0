From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC 1/2] net: dsa: integrate with SWITCHDEV for HW bridging
Date: Tue, 17 Feb 2015 17:43:28 -0800
Message-ID: <54E3EE40.9010406@gmail.com>
References: <1424201196-4901-1-git-send-email-f.fainelli@gmail.com> <1424201196-4901-2-git-send-email-f.fainelli@gmail.com> <20150218011955.GA17155@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, linux@roeck-us.net,
	cphealy@gmail.com, Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:45108 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751810AbbBRBnm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2015 20:43:42 -0500
Received: by pdjz10 with SMTP id z10so47751328pdj.12
        for <netdev@vger.kernel.org>; Tue, 17 Feb 2015 17:43:42 -0800 (PST)
In-Reply-To: <20150218011955.GA17155@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17/02/15 17:19, Andrew Lunn wrote:
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

Yes, you are very right, thankfully this is a RFC patch because of that ;)

> 
> I'm thinking of cases like
> 
> brctl addbr br0
> brctl addif br0 lan0
> brctl addif br0 lan1
> 
> brctl addbr br1
> brctl addif br1 lan2

mask = 0x4 | 0x2 | 0x1 # FAIL

> brctl addif br1 lan3

mask = 0x8 | 0x4 | 0x2 | 0x1 # FAIL

> 
> We have two software bridges, so need two masks.  It does look like
> your hardware and the Marvell hardware supports this, disjoint sets of
> bridged ports.  But with the current implementation, your going to end
> up with one hardware bridge with four ports, and broken STP.

Yep, I will rework that patch set to address that, and I can actually
test that, which is even better, thanks!
-- 
Florian
