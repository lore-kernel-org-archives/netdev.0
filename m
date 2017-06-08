From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH V2 1/3] Documentation: devicetree: add multiple cpu port
 DSA binding
Date: Thu, 8 Jun 2017 12:57:28 -0700
Message-ID: <d89e500a-9757-d06d-7d37-23997fe2ad2b@gmail.com>
References: <20170530104419.6052-1-john@phrozen.org>
 <69dd02a6-59f9-59df-f630-0ebd948451c4@gmail.com>
 <20170607211002.ubljfplyexjb6dyl@rob-hp-laptop>
 <64218746-fbb6-f958-ba15-5ed704214d25@gmail.com>
 <20170608193112.GF20216@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, John Crispin <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>,
        Vivien Didelot <vivien.didelot-4ysUXcep3aM1wj+D4I0NRVaTQe2KTcn/@public.gmane.org>,
        "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Sean Wang <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170608193112.GF20216-g2DYL2Zd6BY@public.gmane.org>
Content-Language: en-US
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 06/08/2017 12:31 PM, Andrew Lunn wrote:
>> Right now we don't have any mechanism, and statically doing this from
>> Device Tree is too inflexible. I have been working on a parallel path
>> where we use the bridge (which is already accelerated when there is a
>> switch) in order to define groups of ports, the idea would be do to e.g:
>>
>> brctl addbr br-lan
>> brctl addbr br-lan eth0
>> brctl addbr br-lan lan1
>> ...
>> brctl addbr br-lan lan4
>>
>> brctl addbr br-wan
>> brctl addbr br-wan eth1
>> brctl addbr br-wan wan
>>
>> Assuming that lan1-lan4 are your LAN ports, and wan is your WAN port and
>> you have two CPU ports.
> 
> Hi Florian
> 
> I don't like this, on multiple levels.
> 
> My wan port typically never has more than 40Mbps of traffic on it. So
> dedicating a whole 1Gbps ethernet to it makes no sense. I want to
> share eth1 bandwidth with the wan port, and some of the other
> ports. Meaning i would have to add eth1 to br-lan as well as
> br-wan. Does the bridge allow that? And what sort of hacks do you have
> to allow a port to be added to a bridge, but not used by the bridge?

This is AN example of how to configure a port grouping based on John's
example and use case, not THE only example ;) The idea is obviously that
you can define association between user-facing ports and CPU ports as
you see fit, the idea is to use bridge to do that association because
that's already what controls VLAN membership and forwarding.

> 
> And what is the point of br-wan? It only has one real port in it. So
> i'm adding per-packet overhead which i don't need, just in order to
> signal to the hardware how it should statically route cpu traffic for
> a port.

No, it has two ports in it, adding eth1 is necessary do define the VLAN
membership and forwarding rules, when eth1 is added we resolve the CPU
port this corresponds to in the switch and we use that to define the
forwarding decision between ports.

The overhead per-packet is extremely limited because the first thing
br_handle_frame() will do is see that eth1 is a DSA master network
device and pass packets back up the stack for processing through dst->rcv().

> 
> Now say i have one of the bigger marvell switches, with 11 ports, in
> an industrial application. I setup 3 or 4 bridges. I then need to add
> eth0 and eth1 to two different bridges. And say i use some ports> without a bridge. How do i configure them?

If you don't add your conduit interface to the bridge, then the default
CPU interface (which could be left to the driver to decide which one is
relevant) gets used and things work as expected. When you add a DSA
master network device to the bridge, only then do we use that
information to refine the forwarding decision and map to the appropriate
port vectors. Doing this becomes necessary if you create a second (or
more) bridge to isolate a group of ports.

> 
> And how do i dump the current mapping?

You look at both (or more) bridges' members, what's wrong or even any
different from what happens today?

> 
> For me, this is the wrong architecture. What CPU port is used should
> be a port property, not a bridge property. I think we should use
> devlink. Add commands to dump the current mapping, and set it.

In premise I agree, although just like we need a bridge today to
configure VLAN memberships, it did not seem to me like a big stretch to
use a bridge to configure which CPU port you want.
-- 
Florian
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
