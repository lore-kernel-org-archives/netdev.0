From: Johannes Berg <johannes@sipsolutions.net>
Subject: wireless notes / pre d80211 merge
Date: Tue, 14 Nov 2006 23:19:57 +0100
Message-ID: <1163542797.5399.106.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-rulTczl3NXj36UhjUJNd"
Cc: Jeff Garzik <jgarzik@pobox.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>,
	Simon Barber <simon@devicescape.com>,
	Michael Buesch <mbuesch@freenet.de>,
	Ivo van Doorn <ivdoorn@gmail.com>,
	Michael Wu <flamingice@sourmilk.net>,
	Jouni Malinen <jkm@devicescape.com>,
	Daniel Drake <dsd@gentoo.org>, Hong Liu <hong.liu@intel.com>,
	"Luis R. Rodriguez" <mcgrof@gmail.com>,
	James Ketrenos <jketreno@linux.intel.com>,
	David Kimdon <david.kimdon@devicescape.com>,
	Udayan Singh <udayan.singh@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:40679 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S966063AbWKNWVy
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Nov 2006 17:21:54 -0500
To: netdev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-rulTczl3NXj36UhjUJNd
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

0. Introduction

Hi,

As promised on IRC, here are some thoughts on what d80211 is currently
doing and what should in my opinion be changed.=20

I'm writing this now mostly because I think that we have userspace
visible issues to sort out *before* we can land in -mm or even mainline
with d80211.

This discussion is split up as follows:

 (1) master netdev
 (2) skb path during rx
 (3) skb path during tx
 (4) "wiphy" concept
 (5) so it works, what's wrong?
 (6) d80211 as a protocol?
 (7) d80211 without master netdev?
 (8) what about a combination, or other solutions?
 (9) conclusion


(1) through (4) are just a recap of what we currently have to illustrate
some things for later. Also serves as a starting point for those not as
familiar. Could of course contain errors, I hope not too many.

(5) discusses what I think is wrong, while (6) through (8) discuss
possible scenarios I came up with to fix it.

Note that all these things are long-term. Probably longer than we can
wait with a merge, however we should settle on how the userspace
interface will look like before the merge.


1. master netdev

Currently, we have the 'master' netdev wmasterN which is created as
native 802.11 device but is essentially useless. It is exported to
userspace but only supports wireless extensions and, depending on what
the drivers do, ethtool ops. It isn't really useful for network
functionality although outgoing frames can be seen on it. See section
(3) for why.

Internally, the master netdev is also a virtual access point mode
device, but this is only relevant in the RX path I think.

Additionally, the master netdev represents the underlying 802.11
hardware when it comes to qdisc manipulation.



2. skb path during rx

When a frame is received, it is put into an skb by the lowlevel driver
and handed to d80211 by way of __ieee80211_rx() [1]. They then travel
through the whole d80211 (pre) rx handlers and finally show up as 802.3
frames in the appropriate virtual device. Note that these frames are
never associated with the master netdev, hence won't show up when you
run tcpdump or similar on it.

The whole rx handler thing could (and should!) be cleaned up quite a lot
and can be made more efficient too, but it is purely internal right now
so not a big deal. Food for another d80211 note.

[1] why we didn't make a static inline ieee80211_rx() that calls an
exported __ieee80211_rx() until we get rid of the other ieee80211 is
beyond me. Would have been good but I guess we can also just convert all
the drivers when we change the name again.


3. skb path during tx

This is more complicated. When a frame is created in one of the virtual
interfaces, it first goes through through conversion from 802.3 into
802.11, some tx control is added on and the frame is queued to the
master netdev. This is why we see outgoing frames in tcpdump.

After getting queued to the master netdev, the frame goes through the
qdiscs and some more info is tacked on into skb->cb by the 802.11 qdisc.
Afterwards, if the frame is not dropped, it shows up in
ieee80211_master_start_xmit where skb->cb is copied onto the stack and
cleared afterwards. Then, the frame goes through all the tx handlers
including fragmentation and encryption and is finally given to the
lowlevel driver via the hardware description's tx() call.



4. "wiphy" concept

Straying a bit from the discussion of frames and similar, let me
describe the "wiphy" concept we currently have. Currently, in sysfs we
have class/ieee80211/phy%d/ and below that a wealth of information not
only about various hardware related things but also, for example, a list
of all stations associated to any virtual access points intermixed with
those 'stations' that we are associated to on any virtual interface.
Also, we here find 'add_iface' and 'remove_iface', knobs to create and
destroy virtual interfaces.

The second wiphy concept is currently present in cfg80211 which
currently requires this concept in the userspace interface and should
effectively replace the 'add_iface' and 'remove_iface' hooks and make
them more generically available for non-d80211 drivers. I was thinking
of ipw2200 when I wrote it which allows adding a monitor device
(currently through some config option I think).



5. so it works, what's wrong?

Pretty broad question I asked myself here, but let me try to answer it
anyway.

For one, I think that having the master device in its current form is
useless. It sees outgoing frames that are to be sent to the hardware for
transmission, and in that way represents the actual underlying hardware.
However, it never sees incoming frames, so there again it doesn't
represent the hardware. Not seeing incoming frames makes it useless, and
even through it sees outgoing frames you cannot send frames to it.

Also, if the master netdev is thought of as representing the hardware
(which I don't think it fully does), it collides with the notion of the
'wiphy' as described above.

The master netdev and wiphy create two orthogonal interfaces to
userspace that nonetheless pretty much represent the same thing---the
underlying hardware.

As said previously, the master netdev represents the hardware when it
comes to qdisc manipulation, but the wiphy represents the hardware when
it comes to manipulation of virtual interfaces. I believe that this is
fundamentally wrong because they both manipulate operation of the
underlying hardware.

I know I actually strengthened the wiphy concept by adding it to
cfg80211, but to my defense at that point I was still pretty sure we
would be getting rid of the master device in the future. This seems to
have been naive, but see below.

This is my biggest problem with d80211 at the moment. All the internal
inefficiencies can be cleaned up without any externally visible impact.


6. d80211 as a protocol?

Some proof-of-concept patches I posted converted d80211 to a protocol.
They contained technical flaws and aren't usable at all, but do
illustrate the concept. What I did was

 - instead of having drivers create a wireless device specially, they
   simply register a netdev with 802.11 arphrd and assign a new net_dev
   member ieee80211_hw describing the hardware functionality and
   containing function pointers for example for changing channels. This
   can be thought of as similar to hardware vlan acceleration
 - d80211 hooks into the netdev notifier chain and creates appropriate
   state for itself when a native 802.11 device with hw description is
   registered

RX path:
 - drivers, instead of calling __ieee80211_rx, put the RX information
   into skb->cb (which is shared between drivers and d80211 in this
   scenario) and then netif_rx() this skb which gets a native 802.11
   type.
 - d80211 picks up this skb through a packet_type that it registered and
   injects it into its processing, ending up in some virtual device or
   scan results etc.

TX path:
 - an skb that is injected into some virtual device which is controlled
   by d80211 is transformed into whatever state it needs and subjected
   to the various tx handlers. Transmission control information is
   embedded into skb->cb for the device driver, and the frame is
   dev_queue_xmit()ed to the hardware device (former master device).
 - the SKB is subjected to qdiscs etc.
 - drivers receive this skb and transmit it to the hardware device
 - because wireless requires transmit status, when the hardware is done
   with the skb drivers don't simply free it but instead hand it to
   ieee80211_tx_status() which updates state as necessary and then frees
   the skb. Status information is given as a second parameter to that
   function along with the skb as currently.

This seems quite elegant, but there are a couple of problems with it:
 - skb->cb is sort of abused, and might be too small in the future. If
   it becomes too small, we could put a pointer into skb->cb instead and
   do lifetime management with an skb desctructor.
 - because of the transmit status requirement, skbs need to be 'given
   back' to d80211


Problems that have solutions:
 - the qdiscs can drop fragments of a frame which is useless, hence
   fragmentation (and consequently also encryption) should probably be
   moved to the qdisc, need to make sure that the 802.11 qdisc is
   attached first on the device and can't be removed.

Further comments I have received include the fact that again, the master
netdev is not very useful because there is no application that can live
with sending raw 802.11 frames without controlling transmission
parameters like transmission rate etc. [2]

=46rom a programming point of view, this is also quite a logical
separation because drivers get to fully control the netdev they
register, and the generic 802.11 code mostly is not concerned with it
(except for the qdisc issue).

Also something that has been proposed is to add the transmission control
information as a header to a newly invented protocol. This seems nice at
first, but if d80211 were to be a protocol then it would also mean that
d80211 would have to serialise the internal transmission control
structure and the driver deserialise it again. Also, adding new items to
the structure becomes impossible (unless the parser we require is
complicated...)

Also, in this scenario the ieee80211 class would go away, probably in
favour of
 (1) exporting most of the things via cfg80211
 (2) putting sta information structs into sysfs where they belong --
     with the virtual device they are associated with
 (3) adding other hw information in sysfs as attributes to the driver's
     netdev

There's probably more, and rx path cleanup is one of the things this
would require. Comments welcome :)

[2] I actually have one such application internally using my previous
nl80211 work but really not filling in any of the transmit information.



7. d80211 without master netdev?

This is another possibility that I explored but got quite some headwind
from a few people :)

Effectively, this would empower the wiphy concept more. As described
previously, the master netdev is currently mostly just used for the
qdisc it can have associated with it, and thus used from userspace for
qdisc manipulation. In order to remove the master netdev completely it
would be necessary to abstract the skb queueing out from netdevs and
create some new structure responsible for it which would be embedded in
both a netdev and a wiphy structure. Then, the qdisc userspace interface
would have to be able to identify both the containers (netdev via
ifindex, wiphy probably by wiphyidx) and operate accordingly.

This actually requires some major surgery so I don't expect it to be
done before a merge. But if this should be the desired outcome, then I
propose to cut userspace breakage to a minimum: only the tc operations.
This means that the master netdev should be removed as far as possible
and the only thing left on it should be the qdisc interface. This means
drivers should no longer be able to access the netdev. [3]

I'm not sure this is completely feasible. Thinking about LLTX more it
would probably require moving that to the new queue structure, which
means that either netdev registration would have to copy it there or all
regular network drivers be modified.

[3] It was said that some drivers set LLTX in the flags. I'm not sure
this is safe because it doesn't just affect the driver but also d80211
which might not be able to cope with it.



8. what about a combination, or other solutions?

Of course combinations are possible. One thing that immediately comes to
mind is just migrating over all of the current wiphy functionality over
to the master netdev in order to unify the two userspace interfaces.
This would be visible in sysfs as well as require changes to
cfg80211[4].

Of course, the master netdev would still not see incoming frames because
they are handled by __ieee80211_rx().

I guess many more combinations are possible :)


[4] actually, in cfg80211 we'd just remove the wiphy attribute and the
change the internals a bit, it should already accept the master dev in
most cases


9. conclusion

Of course, this just represents my own opinion. I think that although
the skb->cb is sort of abused, a protocol makes most sense.

I'd like to see this resolved with a sane userspace API that doesn't
consist of multiple disjoint things representing the same hardware.

I hope it isn't all too incoherent :)

johannes

--=-rulTczl3NXj36UhjUJNd
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUARVpBC6Vg1VMiehFYAQJ/ERAAiYOR4OhCFeyH21HsQj8dd/YvfjNARsp0
X/uoIlAr3idO+vsIE1ClZqI/Z6klx/4W/lp0TKjRFljM6B8Fu0q/qeVgjQJnwmT+
nzMG6C2nSNdCn/Yb08sK/Z2R5Sip3DjsBIJZDwzJF+EHfNyH+i4wLNJVR01WEFY3
4JFSVf2K1lQ24I70gD6wDOBD2bmMKtD+Yzut87DgwQIONFLGhao9eEFNzZoMxgMM
Wsu0yDfJiOGZHWFUOy73YYkCtk1lnjt2KVRsS2/CRnXk78qZtzsTDqp6rHveKfOH
wNjQAvfSferAa2FCJ2zzHNtRReOfY3lkXjtQOHWLTguLCtksqgifBgh2lOb3efpG
z2IseXQQGO/7dmxFZf0DTkc9/dCS68FZIg8U+w3ez0dRps9um4YI+oU8QaeG7U5j
a1GgtGHJXtd9hWuJi/+zYcTgWv6v9XiCM/lQ2J+ekUCSXhqrR4F6AYihU8OrPEUx
eKx6CLtvDG3eKlTW2xN9zMxmICMzyFWN1D5f+GaPLiXUf+tCbTWONW5QhdHrZDp0
8GgBbddQSSGH13H9mJ8e9ItXeKwmovGoGoSFs+rtN8Oxju+D7e6BImCgSG6IwyIC
f5N0kZU3Upo0sJ1L72Qqoj3dgwWzcyV2qaBS96hXe99N6o1Ei0jBoGmrzSWfdmXh
BXmS1BpHTy0=
=Z5XW
-----END PGP SIGNATURE-----

--=-rulTczl3NXj36UhjUJNd--

