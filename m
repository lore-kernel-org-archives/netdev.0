From: fruggeri@aristanetworks.com (Francesco Ruggeri)
Subject: [PATCH 1/1] net: delete stale packet_mclist entries
Date: Mon, 09 Mar 2015 12:09:52 -0700
Message-ID: <20150309190952.5C6AA483316@fruggeri-Arora18.sjc.aristanetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, mst@redhat.com, al.drozdov@gmail.com,
	willemb@google.com, viro@zeniv.linux.org.uk, edumazet@google.com,
	dborkman@redhat.com, davem@davemloft.net, fruggeri@arista.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mx.aristanetworks.com ([162.210.130.12]:55847 "EHLO
	prod-mx.aristanetworks.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752275AbbCITJw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 15:09:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From ce9a4f202723f6ba1b18bc7c4a258c130c1f4148 Mon Sep 17 00:00:00 2001
From: Francesco Ruggeri <fruggeri@arista.com>
Date: Mon, 9 Mar 2015 11:51:04 -0700
Subject: [PATCH 1/1] net: delete stale packet_mclist entries

When an interface is deleted from a net namespace the ifindex in the
corresponding entries in PF_PACKET sockets' mclists becomes stale.
This can create inconsistencies if later an interface with the same ifindex
is moved from a different namespace (not that unlikely since ifindexes are
per-namespace).
In particular we saw problems with dev->promiscuity, resulting
in "promiscuity touches roof, set promiscuity failed. promiscuity
feature of device might be broken" warnings and EOVERFLOW failures of
setsockopt(PACKET_ADD_MEMBERSHIP).
This patch deletes the mclist entries for interfaces that are deleted.
Since this now causes setsockopt(PACKET_DROP_MEMBERSHIP) to fail with
EADDRNOTAVAIL if called after the interface is deleted, also make
packet_mc_drop not fail.

Signed-off-by: Francesco Ruggeri <fruggeri@arista.com>
---
 net/packet/af_packet.c | 22 ++++++++++++++--------
 1 file changed, 14 insertions(+), 8 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 5bf1e96..f8db706 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -3123,11 +3123,18 @@ static int packet_dev_mc(struct net_device *dev, struct packet_mclist *i,
 	return 0;
 }
 
-static void packet_dev_mclist(struct net_device *dev, struct packet_mclist *i, int what)
+static void packet_dev_mclist_delete(struct net_device *dev,
+				     struct packet_mclist **mlp)
 {
-	for ( ; i; i = i->next) {
-		if (i->ifindex == dev->ifindex)
-			packet_dev_mc(dev, i, what);
+	struct packet_mclist *ml;
+
+	while ((ml = *mlp) != NULL) {
+		if (ml->ifindex == dev->ifindex) {
+			packet_dev_mc(dev, ml, -1);
+			*mlp = ml->next;
+			kfree(ml);
+		} else
+			mlp = &ml->next;
 	}
 }
 
@@ -3204,12 +3211,11 @@ static int packet_mc_drop(struct sock *sk, struct packet_mreq_max *mreq)
 					packet_dev_mc(dev, ml, -1);
 				kfree(ml);
 			}
-			rtnl_unlock();
-			return 0;
+			break;
 		}
 	}
 	rtnl_unlock();
-	return -EADDRNOTAVAIL;
+	return 0;
 }
 
 static void packet_flush_mclist(struct sock *sk)
@@ -3559,7 +3565,7 @@ static int packet_notifier(struct notifier_block *this,
 		switch (msg) {
 		case NETDEV_UNREGISTER:
 			if (po->mclist)
-				packet_dev_mclist(dev, po->mclist, -1);
+				packet_dev_mclist_delete(dev, &po->mclist);
 			/* fallthrough */
 
 		case NETDEV_DOWN:
-- 
1.8.1.4
