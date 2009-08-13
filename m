From: "Fischer, Anna" <anna.fischer@hp.com>
Subject: RE: [PATCH][RFC] net/bridge: add basic VEPA support
Date: Thu, 13 Aug 2009 22:11:06 +0000
Message-ID: <0199E0D51A61344794750DC57738F58E6D6B0C7111@GVW1118EXC.americas.hpqcorp.net>
References: <0199E0D51A61344794750DC57738F58E67D2DCECBB@GVW1118EXC.americas.hpqcorp.net>
 <200908121519.36808.arnd@arndb.de>
 <0199E0D51A61344794750DC57738F58E6D6AE9A0C1@GVW1118EXC.americas.hpqcorp.net>
 <200908121827.28905.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Paul Congdon (UC Davis)" <ptcongdon@ucdavis.edu>,
	'Stephen Hemminger' <shemminger@linux-foundation.org>,
	"bridge@lists.linux-foundation.org"
	<bridge@lists.linux-foundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>,
	"evb@yahoogroups.com" <evb@yahoogroups.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"kaber@trash.net" <kaber@trash.net>,
	"adobriyan@gmail.com" <adobriyan@gmail.com>,
	'Eric Biederman' <ebiederm@xmission.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:5479 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751591AbZHMWLo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2009 18:11:44 -0400
In-Reply-To: <200908121827.28905.arnd@arndb.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Subject: Re: [PATCH][RFC] net/bridge: add basic VEPA support
> 
> On Wednesday 12 August 2009, Fischer, Anna wrote:
> > Yes, for the basic VEPA this is not important. For MultiChannel VEPA,
> it
> > would be nice if a macvlan device could operate as VEPA and as a
> typical
> > VEB (VEB = traditional bridge but no learning).
> 
> Right, this would be a logical extension in that scenario. I would
> imagine
> that in many scenarios running a VEB also means that you want to use
> the advanced ebtables/iptables filtering of the bridge subsystem, but
> if all guests trust each other, using macvlan to bridge between them
> sounds useful as well, if only for simplicity.
> 
> > Basically, what we would need to be able to support is running a VEB
> and
> > a VEPA simultaneously on the same uplink port (e.g. the physical
> device).
> > A new component (called the S-Component) would then multiplex frames
> > to the VEB or the VEPA based on a tagging scheme.
> 
> You can of course do that by adding one port of the S-component to
> a port of a bridge, and using another port of the S-component to
> create macvlan devices, or you could have multiple ports of the
> S-component each with a macvlan multiplexor.
> 
> Just to make sure I get the chain right, would it look like this?
> (adapted from Paul's PDF)
> 
> eth0 (external) ---scomponent0 --- vlan2 --- macvlan0
>                  |              |         \- macvlan1
>                  |               \-vlan3 --- macvlan2
>                  |-scomponent1 --- vlan2 --- br0 --- tap0
>                  |                             \ --- tap1
>                  |-scomponent2 --- vlan3 --- macvlan3
>                  \-scomponent3 ---  ---  --- macvlan4
> 
> In this scenario, tap0 and tap1 could communicate over the bridge
> without
> tagging, while any data going out through the S-Component gets tagged
> with both a 802.1q Q-Tag and an S-Tag.

Yes, that looks right. If all the different interfaces, e.g. bridge ports,
macvlan devices, vlan tagging devices can be stacked that easily without
any known issues, that would be great.


> macvlan4 would be a guest that does its own tagging, and the external
> switch would need to check the VLAN IDs, but it could communicate with
> any other guest by tagging the frames as 2 or 3.
> 
> macvlan2 and macvlan3 could communicate with each other and with
> external
> guests in vlan3.
> 
> Guests on scomponent1 and scomponent3 could in theory have
> subdivisions of the network with macvlan running in the guest
> to run containers.
> 
> > I think the question here was whether there is a way for a macvlan
> interface
> > to be set to promiscuous mode. At the moment, I believe a macvlan
> interface
> > only receives packets based on its destination address (this is for
> unicast
> > packets now). What if a macvlan interface wanted to get all packets
> that
> > are being received (either on the physical device, or on a particular
> > VLAN if using macvlan nested in vlan). Would this work easily?
> Imagine
> > you have a virtual machine attached to that macvlan / macvtap device
> and
> > this VM wants to do packet inspection or network traffic monitoring
> on
> > all packets flowing through the virtualized server.
> 
> Ok, I see. As I said, the host could easily get access to all frames
> on macvlan downstream ports by opening a raw socket on the upstream
> port (with some extra work if we want to support this in bridge mode).
> 
> If you want the inspection to be done in a guest rather than the host,
> the easiest way to achieve that would be to connect that raw socket
> to the guest using Or's raw frontend for qemu.

I am not too familiar with that raw frontend for qemu to be honest, but 
if it can share the physical device with other macvlan interfaces 
simultaneously, then I think that would indeed be sufficient to support
promiscuous mode ports. We would need to have a similar sort of driver
for Xen and other hypervisor solutions again as well though.

If it is possible to easily stack macvlan devices and bridges as you
describe above, then a promiscuous port should also be realized quite
easily as a typical bridge port, e.g. as shown above tap0 and tap1 
would be typical, traditional bridge ports and though could send
and receive from/with any MAC addresses they like.

Anna
