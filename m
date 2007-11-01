From: Dave Johnson <djohnson+linux-kernel@sw.starentnetworks.com>
Subject: Re: expected behavior of PF_PACKET on NETIF_F_HW_VLAN_RX device?
Date: Thu, 1 Nov 2007 17:36:22 -0400
Message-ID: <18218.18134.353553.189622@zeus.sw.starentnetworks.com>
References: <20071031123359.3954befc@freepuppy.rosehill>
	<4729269A.6090606@candelatech.com>
	<47292A99.5070805@linux-foundation.org>
	<20071031.215025.195350296.davem@davemloft.net>
	<4729EAFF.9050606@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	bguo@sw.starentnetworks.com
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.starentnetworks.com ([12.38.223.203]:40360 "EHLO
	mx0.starentnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758924AbXKAVga (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2007 17:36:30 -0400
In-Reply-To: <4729EAFF.9050606@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben Greear writes:
> We should also define what a NIC should do with VLANs it doesn't
> explicitly know about.   I think it should pass them up the stack
> with VLAN tag intact, but again, perhaps there are reasons not to do
> that?

Unless the device also supports NETIF_F_HW_VLAN_FILTER, it has no idea
which vlans the kernel cares about, it's up to __vlan_hwaccel_rx().


Stephen Hemminger writes:
> The code in AF_PACKET should fix the skb before passing to user
> space so that there is no difference between accel and non-accel
> hardware.  Internal choices shouldn't leak to user space.  Ditto,
> the receive checksum offload should be fixed up as well.

yep.  bad csum on tx packets as reported by tcpdump is also an issue.


Ben Greear writes:
> Currently, VLAN devices offer the ability to 'reorder' the header
> and explicitly remove the VLAN header.  I assume we keep this
> feature and have the AF_PACKET logic check the device flags to see
> if it should insert the VLAN header for hw-accel vlans? 
> 
> Either way, if we sniff the underlying device, we should always get
> the VLAN header.

Yes, but it's more than just a packet socket issue.

A quick look through the hwaccel capable drivers (in 2.6.23) and most
are doing something like:

if (foo->vlgrp && packet_is_tagged)
  vlan_hwaccel_receive_skb(skb, foo->vlgrp, vlan_tag);
else
  netif_receive_skb(skb);

The important thing here is if the vlan group is NULL, the MAC must
be configured to NOT strip the tag.

users of NETIF_F_HW_VLAN_RX:
---------------------------
./drivers/net/8139cp.c:             looks ok
./drivers/net/acenic.c:             *1
./drivers/net/amd8111e.c:           unsure, probably *1
./drivers/net/atl1/atl1_main.c:     looks ok
./drivers/net/bnx2.c:               *2
./drivers/net/bonding/bond_main.c:  unsure, probably ok
./drivers/net/chelsio/cxgb2.c:      looks ok
./drivers/net/cxgb3/cxgb3_main.c:   looks ok
./drivers/net/e1000/e1000_main.c:   looks ok
./drivers/net/ehea/ehea_main.c:     unsure, probably ok
./drivers/net/forcedeth.c:          looks ok
./drivers/net/gianfar.c:            looks ok
./drivers/net/ixgb/ixgb_main.c:     looks ok
./drivers/net/ns83820.c:            unsure, probably ok
./drivers/net/r8169.c:              looks ok
./drivers/net/s2io.c:               *1
./drivers/net/sky2.c:               looks ok
./drivers/net/starfire.c:           unsure, probably ok
./drivers/net/tg3.c:                *2
./drivers/net/typhoon.c:            unsure, probably ok
./drivers/s390/net/qeth_main.c:     unsure, probably ok

*1:  Driver configures the MAC to strip TAGs even if vlan group is
     NULL. MAC strips the tag, but driver calls netif_rx() or
     netif_receive_skb() with the packet as untagged.  Kernel
     processes tagged packet as if it was received untagged.  Possible
     security issue.

*2:  If chip supports 'ASF', tag is always stripped (see *1 above).
     Looks ok if ASF is not supported. 


Ben Greear writes:
> Do the NICs not save the QoS bits in the VLAN header anywhere that
> we could use to reconstitute the header?

Most likely, __vlan_hwaccel_rx() gets the whole 16bit tag and sets
skb->priority from on it.


Besides the accidental removal with the drivers listed above when
there is no vlan group registerd, we're still back to the original
issue.

Having __vlan_hwaccel_rx() send to the base device would likely
require a copy of the skb (at least the head). That completely defeats
the point of hwaccel.

At a minimum, __vlan_hwaccel_rx() should probably add the vlan header
back on if doesn't find a vlan device.  This way no copy is needed,
just shove the header back on (we already have the full 16bits).  Once
re-added, send to the base device instead of dropping.

That would fix the unknown vlan issue, but known vlans would only go
to the vlan device not the base device.  Not sure of an easy fix for
this as af_packet can specifically bind to a specified base device.  I
don't this this would be much of an issue and probably doesn't need
fixing.

-- 
Dave Johnson
Starent Networks

