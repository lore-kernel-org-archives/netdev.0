From: Dave Johnson <djohnson+linux-kernel@sw.starentnetworks.com>
Subject: Re: expected behavior of PF_PACKET on NETIF_F_HW_VLAN_RX device?
Date: Fri, 2 Nov 2007 14:08:32 -0400
Message-ID: <18219.26528.485099.317944@zeus.sw.starentnetworks.com>
References: <20071031123359.3954befc@freepuppy.rosehill>
	<4729269A.6090606@candelatech.com>
	<47292A99.5070805@linux-foundation.org>
	<20071031.215025.195350296.davem@davemloft.net>
	<4729EAFF.9050606@candelatech.com>
	<18218.18134.353553.189622@zeus.sw.starentnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	bguo@sw.starentnetworks.com, Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.starentnetworks.com ([12.38.223.203]:42677 "EHLO
	mx0.starentnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753974AbXKBSIi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Nov 2007 14:08:38 -0400
In-Reply-To: <18218.18134.353553.189622@zeus.sw.starentnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave Johnson writes:
> Ben Greear writes:
> > Currently, VLAN devices offer the ability to 'reorder' the header
> > and explicitly remove the VLAN header.  I assume we keep this
> > feature and have the AF_PACKET logic check the device flags to see
> > if it should insert the VLAN header for hw-accel vlans? 
> > 
> > Either way, if we sniff the underlying device, we should always get
> > the VLAN header.
> 
> Yes, but it's more than just a packet socket issue.
> 
> A quick look through the hwaccel capable drivers (in 2.6.23) and most
> are doing something like:
> 
> if (foo->vlgrp && packet_is_tagged)
>   vlan_hwaccel_receive_skb(skb, foo->vlgrp, vlan_tag);
> else
>   netif_receive_skb(skb);
> 
> The important thing here is if the vlan group is NULL, the MAC must
> be configured to NOT strip the tag.
> 
> users of NETIF_F_HW_VLAN_RX:
> ---------------------------
> ./drivers/net/8139cp.c:             looks ok
> ./drivers/net/acenic.c:             *1
> ./drivers/net/amd8111e.c:           unsure, probably *1
> ./drivers/net/atl1/atl1_main.c:     looks ok
> ./drivers/net/bnx2.c:               *2
> ./drivers/net/bonding/bond_main.c:  unsure, probably ok
> ./drivers/net/chelsio/cxgb2.c:      looks ok
> ./drivers/net/cxgb3/cxgb3_main.c:   looks ok
> ./drivers/net/e1000/e1000_main.c:   looks ok
> ./drivers/net/ehea/ehea_main.c:     unsure, probably ok
> ./drivers/net/forcedeth.c:          looks ok
> ./drivers/net/gianfar.c:            looks ok
> ./drivers/net/ixgb/ixgb_main.c:     looks ok
> ./drivers/net/ns83820.c:            unsure, probably ok
> ./drivers/net/r8169.c:              looks ok
> ./drivers/net/s2io.c:               *1
> ./drivers/net/sky2.c:               looks ok
> ./drivers/net/starfire.c:           unsure, probably ok
> ./drivers/net/tg3.c:                *2
> ./drivers/net/typhoon.c:            unsure, probably ok
> ./drivers/s390/net/qeth_main.c:     unsure, probably ok
> 
> *1:  Driver configures the MAC to strip TAGs even if vlan group is
>      NULL. MAC strips the tag, but driver calls netif_rx() or
>      netif_receive_skb() with the packet as untagged.  Kernel
>      processes tagged packet as if it was received untagged.  Possible
>      security issue.
> 
> *2:  If chip supports 'ASF', tag is always stripped (see *1 above).
>      Looks ok if ASF is not supported. 

Michael,

These changes seems to cause this issue:

>  [BNX2]: Fix VLAN on ASF
>  
>  Always set up the device to strip incoming VLAN tags when ASF is
>  enabled. ASF firmware will not parse packets correctly if VLAN tags
>  are not stripped.
>  
>  Signed-off-by: Michael Chan <mchan@broadcom.com>
>  Signed-off-by: David S. Miller <davem@davemloft.net>
>  
>  GIT: e29054f92d7d575631691865c1b95bee5bc974cc

and

> ChangeSet@1.1371.72.2, 2003-12-02 02:34:13-08:00, davem@nuts.ninka.net +1 -0
>   [TG3]: Do not set RX_MODE_KEEP_VLAN_TAG when ASF is enabled.


Could you elaborate if this is really needed, if so is there some
workaround that could be done instead?

Simply removing the check seemed to work for me, but I'm unsure if
this is actually a valid thing to do with these MACs.



-- 
Dave Johnson
Starent Networks

