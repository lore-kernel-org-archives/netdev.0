From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Stable request for gso feature flag and error handling fixes
Date: Tue, 07 Jul 2015 17:38:50 -0700
Message-ID: <12864.1436315930@famine>
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:43214 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753055AbbGHAiz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2015 20:38:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Please consider commit

commit 1e16aa3ddf863c6b9f37eddf52503230a62dedb3
Author: Florian Westphal <fw@strlen.de>
Date:   Mon Oct 20 13:49:16 2014 +0200

    net: gso: use feature flag argument in all protocol gso handlers

	and, at your discretion, the related commit

commit 330966e501ffe282d7184fde4518d5e0c24bc7f8
Author: Florian Westphal <fw@strlen.de>
Date:   Mon Oct 20 13:49:17 2014 +0200

    net: make skb_gso_segment error handling more robust

	for -stable kernels prior to 3.18 back to 3.10.

	We have observed kernel panics when an openvswitch bridge is
populated with virtual devices (veth, for example) that have expansive
feature sets that include NETIF_F_GSO_GRE.

	The failure occurs when foreign GRE encapsulated traffic
(explicitly not including the initial packets of a connection) arrives
at the system (likely via a switch flood event).  The packets are GRO
accumulated, and passed to the OVS receive processing.  As the
connection is not in the OVS kernel datapath table, the call path is:

	ovs_dp_upcall ->
	     queue_gso_packets ->
		__skb_gso_segment(skb, NETIF_F_SG, false)

	Without the first patch cited above, __skb_gso_segment returns
NULL, as the features from the device (including GSO_GRE) are used in
place of the _SG feature supplied to the call.

	Without the second patch cited above, the kernel panics when it
later dereferences the NULL skb pointer in queue_userspace_packet.

	Strictly speaking, with the first place applied the panic is
avoided (as the NULL return does not occur), but including the second
patch may still be prudent.

	Thanks,

	-J

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
