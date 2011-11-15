From: frank.blaschka@de.ibm.com
Subject: [patch 4/5] [PATCH] qeth: l3 fix rcu splat in xmit
Date: Tue, 15 Nov 2011 13:31:15 +0100
Message-ID: <20111115123152.579843098@de.ibm.com>
References: <20111115123111.128739986@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.uk.ibm.com ([194.196.100.167]:49753 "EHLO
	mtagate7.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752151Ab1KOMbz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2011 07:31:55 -0500
Content-Disposition: inline; filename=622-qeth-rcu-xmit-splat.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Blaschka <frank.blaschka@de.ibm.com>

when use dst_get_neighbour to get neighbour, we need
rcu_read_lock to protect, since dst_get_neighbour uses
rcu_dereference.

===================================================
[ INFO: suspicious rcu_dereference_check() usage. ]
---------------------------------------------------
include/net/dst.h:91 invoked rcu_dereference_check() without protection!
   ...
Call Trace:
([<0000000000011ad8>] show_trace+0x158/0x15c)
 [<00000000003c395a>] qeth_l3_hard_start_xmit+0x212/0xb2c
 [<00000000004006ac>] dev_hard_start_xmit+0x444/0x9bc
 [<000000000041effa>] sch_direct_xmit+0xd2/0x328
 [<000000000041f32a>] __qdisc_run+0xda/0x198
 [<00000000003f84b6>] net_tx_action+0x152/0x360
 [<000000000005798e>] __do_softirq+0xee/0x3b0
 [<0000000000021330>] do_softirq+0xac/0x100
([<00000000000212f2>] do_softirq+0x6e/0x100)
 [<0000000000057142>] local_bh_enable_ip+0x11a/0x120
 [<000000000043ff50>] tcp_sendmsg+0x21c/0xe08
 [<00000000003dfcdc>] sock_sendmsg+0xc8/0x100
 [<00000000003e3d98>] SyS_sendto+0x108/0x140
 [<00000000003e3e1c>] SyS_send+0x4c/0x5c
 [<00000000003e4b62>] SyS_socketcall+0x206/0x348
 [<00000000004e95ca>] sysc_noemu+0x16/0x1c
 [<0000004a2a87dbb0>] 0x4a2a87dbb0
INFO: lockdep is turned off.

Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_l3_main.c |    7 +++++++
 1 file changed, 7 insertions(+)

diff -urpN linux-2.6/drivers/s390/net/qeth_l3_main.c linux-2.6-patched/drivers/s390/net/qeth_l3_main.c
--- linux-2.6/drivers/s390/net/qeth_l3_main.c	2011-11-14 18:26:56.000000000 +0100
+++ linux-2.6-patched/drivers/s390/net/qeth_l3_main.c	2011-11-14 18:27:18.000000000 +0100
@@ -2756,11 +2756,13 @@ int inline qeth_l3_get_cast_type(struct
 	struct neighbour *n = NULL;
 	struct dst_entry *dst;
 
+	rcu_read_lock();
 	dst = skb_dst(skb);
 	if (dst)
 		n = dst_get_neighbour(dst);
 	if (n) {
 		cast_type = n->type;
+		rcu_read_unlock();
 		if ((cast_type == RTN_BROADCAST) ||
 		    (cast_type == RTN_MULTICAST) ||
 		    (cast_type == RTN_ANYCAST))
@@ -2768,6 +2770,8 @@ int inline qeth_l3_get_cast_type(struct
 		else
 			return RTN_UNSPEC;
 	}
+	rcu_read_unlock();
+
 	/* try something else */
 	if (skb->protocol == ETH_P_IPV6)
 		return (skb_network_header(skb)[24] == 0xff) ?
@@ -2847,6 +2851,8 @@ static void qeth_l3_fill_header(struct q
 	}
 
 	hdr->hdr.l3.length = skb->len - sizeof(struct qeth_hdr);
+
+	rcu_read_lock();
 	dst = skb_dst(skb);
 	if (dst)
 		n = dst_get_neighbour(dst);
@@ -2893,6 +2899,7 @@ static void qeth_l3_fill_header(struct q
 				QETH_CAST_UNICAST | QETH_HDR_PASSTHRU;
 		}
 	}
+	rcu_read_unlock();
 }
 
 static inline void qeth_l3_hdr_csum(struct qeth_card *card,
