From: Felix Fietkau <nbd@openwrt.org>
Subject: Re: [PATCH 1/4 net-next] net: phy: add Generic Netlink Ethernet switch
 configuration API
Date: Fri, 25 Oct 2013 15:01:39 +0200
Message-ID: <526A6BB3.7050507@openwrt.org>
References: <1382466229-15123-1-git-send-email-f.fainelli@gmail.com> <1382466229-15123-2-git-send-email-f.fainelli@gmail.com> <5266D7D6.9000309@intel.com> <CAGVrzcZS4SGiUFoCnhau1Fvv9F4ffS7tA+PT4r-qLCj8HV8BqQ@mail.gmail.com> <20131022202537.GA16336@hmsreliant.think-freely.org> <CAGVrzcaXFboRDn40+VciTes09w-jqTASNZz2GZNpTxbaV6D0Lw@mail.gmail.com> <5267B764.305@mojatatu.com> <5267BB53.8030703@openwrt.org> <5267C6B9.4000704@mojatatu.com> <5267CFAB.9090100@openwrt.org> <5267D8AE.7080009@mojatatu.com> <5267DDE6.70600@openwrt.org> <526A5949.6040404@mojatatu.com>
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
Received: from nbd.name ([46.4.11.11]:52644 "EHLO nbd.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753443Ab3JYNCC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Oct 2013 09:02:02 -0400
In-Reply-To: <526A5949.6040404@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013-10-25 1:43 PM, Jamal Hadi Salim wrote:
> Hi Felix,
> 
> Sorry for the latency - some distractions on the side.
> 
> On 10/23/13 10:32, Felix Fietkau wrote:
>> On 2013-10-23 4:09 PM, Jamal Hadi Salim wrote:
> 
>>> *MAC address setting?
>> Typically ignored by switches.
>>
> 
> Ok, I take it the minority allow you to do this.
> For most, the switch port has some factory shipped MAC address?
I think it's common for the switch to have a global MAC address, not a
per-port one.

>>> *MTU setting
>> Can usually not be controlled per-port. Where supported, it is usually a
>> global configuration parameter for the switch.
> 
> Does that mean one mtu for all switch ports on such devices?
Correct.

>>> * If something shows up on the cpu port and comes up, we can make it
>>> appear to be from such a netdev (for the case where this applies)
>> I think that's actually more confusing for users if they find the same
>> kind of devices on multiple different switches, and on some they can be
>> used directly, on others they cannot.
> 
> But how does it work today for the case where you have one chip that
> wont pass up the tag to the cpu and another that does? i.e what
> happens to packets that end up being shunted to CPU?
'won't pass up the tag'? The switch is treated in pretty much the same
way as a normal managed standalone switch (you know, one you can buy in
a shop and plug your Ethernet cable into).
You simply tell it, which VLANs to put on which ports, and make the
ports tagged or untagged.
The link between the switch and the CPU is not really special, for the
switch it's just another port. This way of configuring works with pretty
much all switches that we're using.

>> The classical Linux tools here only cover the most basic configuration
>> parts. In many cases, separate configuration options are needed. For
>> example, on some switches, forwarding table IDs can be assigned to VLANs.
> 
> Multiple forwarding tables?
Yes, some switches have them, and they can be useful when dealing with
multiple VLANs.

>> Also, the switch driver is completely independent of the network device
>> driver that drives the port connected to the CPU port of the switch.
> 
> I guess this is because one piece manages attributes and other is
> for packet processing?
> There is good precedence in a few embedded systems which are
> equally challenged but still expose ports as netdevs.
No, because the connection between the CPU and the switch is handled by
a normal Ethernet MAC. The Ethernet chip doesn't care if there's a
switch connected to it, or a regular PHY.
It's just a normal MII connection, nothing more.

>>The
>> only ways I can imagine implementing this in the Linux network stack
>> involve an unhealthy amount of layering violations or other forms of
>> ugly hackery.
>> The switch driver usually attaches itself as a PHY driver, there is no
>> monolithic switch netdev.
> 
> Shouldnt the PHY driver be owned by some netdev?
Right, the netdev that owns the PHY is a normal Ethernet MAC, running
any normal Linux Ethernet driver.

>> I fully agree that this would be nice to have. I've given quite a bit of
>> thought to trying to figure out if there's a simple clean way to
>> implement this, but in all of the proposals I've seen so far, the costs
>> (complexity, bloat, quirky interfaces) seem to massively outweigh the
>> benefits.
> I can understand the massive differences in capabilities make this
> harder to retrofit. But if the only cause for impendance mismatch
> is these capability differences, I think it can be resolved.
> We need a way to discover them and only use those available.
I remain absolutely unconvinced that this will make the end result
better. Right now, these switches act like separate devices, because
aside from the fact that they're put on the same board with other
components, they pretty much *are* separate devices.

You seem to insist on treating it as a kind of port multiplexer + bridge
accelerator instead of a mostly standalone switch.

This may work for some devices, but on others this simply a model that
the hardware wasn't designed for. Sure, we could try to cram in all
those special cases, extra options, and hack through the layers where
they're in the way. If *all* you care about is being able to reuse the
existing interfaces, that might even seem like a good idea.

On the other hand, I've pointed out quite a few examples where the model
of trying to cram it into the bridge API is just a bad fit in general.

>> I don't think bloating up the netdev feature flags for lots of
>> single-vendor fields is a good idea.
> 
> I agree if you say there is a variety of capabilities.
> But if this is to be resolved - there has to be a way for these
> capabilities to be advertised by low level (and netdev->features
> is our only vehicle at the moment). We could have switch features
> in addition etc etc.
Aside from the fact that the swconfig code is already there, the model
that it uses is inherently simple. I worry about all the extra
complexity that we will have to add to try to retrofit this into a
mostly incompatible configuration model.

>> swconfig simply allows the driver
>> to register its own global, per-port and per-vlan attributes and user
>> space can discover them.
>>
>> That also avoids the nasty issue of userspace code having to know about
>> all possible vendor specific features and bits of status information.
> So it seems to me you already have taken care of this piece.
> Why not pull that into the netdev or bridge core and then re-use it?
Because it just doesn't fit there very well.

- Felix
