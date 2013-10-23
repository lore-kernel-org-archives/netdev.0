From: Felix Fietkau <nbd@openwrt.org>
Subject: Re: [PATCH 1/4 net-next] net: phy: add Generic Netlink Ethernet switch
 configuration API
Date: Wed, 23 Oct 2013 16:32:06 +0200
Message-ID: <5267DDE6.70600@openwrt.org>
References: <1382466229-15123-1-git-send-email-f.fainelli@gmail.com> <1382466229-15123-2-git-send-email-f.fainelli@gmail.com> <5266D7D6.9000309@intel.com> <CAGVrzcZS4SGiUFoCnhau1Fvv9F4ffS7tA+PT4r-qLCj8HV8BqQ@mail.gmail.com> <20131022202537.GA16336@hmsreliant.think-freely.org> <CAGVrzcaXFboRDn40+VciTes09w-jqTASNZz2GZNpTxbaV6D0Lw@mail.gmail.com> <5267B764.305@mojatatu.com> <5267BB53.8030703@openwrt.org> <5267C6B9.4000704@mojatatu.com> <5267CFAB.9090100@openwrt.org> <5267D8AE.7080009@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	John Crispin <blogic@openwrt.org>,
	Jonas Gorski <jogo@openwrt.org>,
	Gary Thomas <gary@mlbassoc.com>,
	Vlad Yasevich <vyasevic@redhat.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:40040 "EHLO nbd.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750977Ab3JWOca (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Oct 2013 10:32:30 -0400
In-Reply-To: <5267D8AE.7080009@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013-10-23 4:09 PM, Jamal Hadi Salim wrote:
> On 10/23/13 09:31, Felix Fietkau wrote:
>> On 2013-10-23 2:53 PM, Jamal Hadi Salim wrote:
> 
>> So you would like to have 'dummy' netdevs that don't actually work like
>> real ones, just to get stats?
> 
> Not just stats, but other utilities, example:
> *operational status read and admin status control,

> *MAC address setting?
Typically ignored by switches.

> *MTU setting
Can usually not be controlled per-port. Where supported, it is usually a
global configuration parameter for the switch.

> * If something shows up on the cpu port and comes up, we can make it 
> appear to be from such a netdev (for the case where this applies)
I think that's actually more confusing for users if they find the same
kind of devices on multiple different switches, and on some they can be
used directly, on others they cannot.

> * etc
> 
>> Many of these switches are designed to work completely standalone, i.e.
>> they receive their configuration once and then do their thing, often
>> they don't even have special treatment for the CPU port.
>>
> 
> So if i understood the worst case scenario:
> - no packets will ever come to the CPU
> - minimal config only such as configuring ports and what vlans they
> accept
> - you cant query the device for anything else not even stats
Correct.

>>> Can you at least retrieve the fdb? example how to figure out which
>>> port a specific MAC address resides?
>> On some of them, but not all.
> I think this would be a fit for netdev->features to set capabilities at
> initialization.
> So canSetfdb, canGetfdb, canDelfdb etc

>>> can support more than one vlan without having multiple bridges. example:
>>> bridgeA: link ports {swp0:vlan1, swp1:vlan2, swp0:vlan4}
>>> bridgeB: link ports {swp0:vlan3, swp1:vlan4, swp1:vlan2}
>> So even more dummy interfaces that serve no real purpose other than
>> configuration?
> 
> Yes. It may sound rediculous(trademark for that owned by DaveM), but
> given the returns that all other classical linux tools work, I think it
> is worth it.
The classical Linux tools here only cover the most basic configuration
parts. In many cases, separate configuration options are needed. For
example, on some switches, forwarding table IDs can be assigned to VLANs.
Also, the switch driver is completely independent of the network device
driver that drives the port connected to the CPU port of the switch. The
only ways I can imagine implementing this in the Linux network stack
involve an unhealthy amount of layering violations or other forms of
ugly hackery.

> Disclaimer: I still think this part is acrobatic in nature i.e no good
> one-to-one mapping
> 
>> Correct.
> 
> How do you deal with those situations today example when a packet
> shows up in the cpu port and they require routing?
> Do you have one monolithic switch netdev ?
The switch driver usually attaches itself as a PHY driver, there is no
monolithic switch netdev.

>>I still get the impression that the model you're describing is
>> mostly incompatible with what we're trying to do, and comes at the cost
>> of quite a bit of extra complexity and bloat, not just on the
>> implementation side, but on the configuration side as well.
> 
> /Sigh
> I understand it is a dilema especially when you have your model proven
> already with users.
> The danger is one-offs where certain tools only work with certain
> instantiations of common features. From a usability perspective,
> it would be nice to use iproute2, ifconfig etc on the switch/ports and
> not learn another tool (or program the switch to a different API).
I fully agree that this would be nice to have. I've given quite a bit of
thought to trying to figure out if there's a simple clean way to
implement this, but in all of the proposals I've seen so far, the costs
(complexity, bloat, quirky interfaces) seem to massively outweigh the
benefits.

>> It also seems to make it more difficult to support vendor specific
>> features. I strongly doubt that the slight increase in consistency
>> between different kinds of switches/bridges is worth all of these extra
>> costs.
> 
> I am not privy to what specific vendor features exist that are out of
> whack. But note:
> We have ability to set capabilities (netdev->features is one, but you 
> can add another netdev->field). Would it not make sense for the driver
>   to set such capabilities and the generic code to turn on/off certain
> things? Example turn on netdev->ops->fdb_add if the switch is capable
> etc.
I don't think bloating up the netdev feature flags for lots of
single-vendor fields is a good idea. swconfig simply allows the driver
to register its own global, per-port and per-vlan attributes and user
space can discover them.

That also avoids the nasty issue of userspace code having to know about
all possible vendor specific features and bits of status information.

- Felix
