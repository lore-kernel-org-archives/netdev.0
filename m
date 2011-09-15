From: David Lamparter <equinox@diac24.net>
Subject: Soft vs. hard MTU / 802.3as
Date: Thu, 15 Sep 2011 12:29:10 +0200
Message-ID: <20110915102910.GC4037740@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:52426 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932312Ab1IOK3R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Sep 2011 06:29:17 -0400
Received: from [2001:8d8:81:5c2::] (helo=jupiter.n2.diac24.net)
	by spaceboyz.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.76)
	(envelope-from <equinox@diac24.net>)
	id 1R49C0-0002ly-Gc
	for netdev@vger.kernel.org; Thu, 15 Sep 2011 12:29:16 +0200
Received: from equinox by jupiter.n2.diac24.net with local (Exim 4.76)
	(envelope-from <equinox@diac24.net>)
	id 1R49Bu-001bEt-Ai
	for netdev@vger.kernel.org; Thu, 15 Sep 2011 12:29:15 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,


I've been looking at implementing 802.1ad S-VLANs (I posted a patch but
lacked resources to work on it after my laptop died) and I'm running
into problems with the way the MTU is treated currently.

Basically, the code has no way to ascertain hardware maximum frame size
limits for stacked VLAN tags. (Which becomes even more important for
802.1ah, having 18 bytes of extra header...)

So, unless I'm overlooking something here, I'd suggest introducing two
new fields into struct net_device:

	unsigned int hard_mtu;
	unsigned short(?) extra_vlans;

The first one would be the hardware frame size limit on TX/RX. (These
shouldn't differ, if they do it needs to be the minimum).

The second one is a bit non-intuitive (maybe I'm over-thinking this?)
I'm expecting devices that support "1518 bytes plus 1 vlan tag". Those
devices cannot tx/rx 1522 byte frames, but if it is 1518 bytes plus a
1Q tag that's ok. So, basically, this field would be 0 for devices
that have a vlan-agnostic size limit, and 1 for silicon that has
"speshul" vlans. (VLAN accel is independent of this!)

So, if you add a 802.1Q vlan device, it works like this:
	self->hard_mtu = parent->hard_mtu;
	self->extra_vlans = parent->extra_vlans;
	if (parent->extra_vlans)
		self->extra_vlans--;
	else
		self->hard_mtu -= 4;
802.1ad/ah devices would be simpler:
	self->hard_mtu = parent->hard_mtu - 4;
	self->extra_vlans = 0;
(for 802.1ah the value is 16+6 bytes instead of 4)

Introducing these fields might also allow us to clean up MTU checks in
general; the device could be mostly agnostic of whatever is set above it
(though maybe we want to propagate the value for dropping oversized
frames early?).

The mtu field cannot be used for all of those things since layer 2 and
layer 3 MTU need to be distinguished. 802.3as calls for a 2000 byte MTU
but rather clearly says that only 1500 of it is for the higher level
protocol to use. The mtu knob needs to control IP's and IPv6's packet
sizes independently of what's transmitted by some vlan stack.

Comments?
(will come up with some code if i don't get overwhelming negative)


-David


P.S.: quick IEEE number cheat-sheet:
 802.1Q - regular VLANs, protocol 0x8100, 4 byte total overhead
 802.1ad - S(ervice)-VLANs, protocol 0x88a8, 4 byte total ovh.
 802.1ah - MAC-in-MAC, protocol 0x88e7, 18 byte ovh.
 802.3ac - frame size update for 802.3 to 1522 for one .1Q tag
 802.3as - frame size update for 802.3 to 2000 for random stuff
