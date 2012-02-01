From: David Miller <davem@davemloft.net>
Subject: [PATCH] decnet: Add missing neigh->ha locking to
 dn_neigh_output_packet()
Date: Wed, 01 Feb 2012 16:36:33 -0500 (EST)
Message-ID: <20120201.163633.429880242045037062.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35357 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932510Ab2BAVgf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2012 16:36:35 -0500
Received: from localhost (nat-pool-rdu.redhat.com [66.187.233.202])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id q11LaXix004492
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 1 Feb 2012 13:36:34 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Basically, mirror the logic in neigh_connected_output().

Signed-off-by: David S. Miller <davem@davemloft.net>
---

Noticed this while auditing neighbour entry usage in the DecNET stack.
Committed to net-next.

 net/decnet/dn_neigh.c |   24 +++++++++++++++---------
 1 files changed, 15 insertions(+), 9 deletions(-)

diff --git a/net/decnet/dn_neigh.c b/net/decnet/dn_neigh.c
index befe426..ee7013f 100644
--- a/net/decnet/dn_neigh.c
+++ b/net/decnet/dn_neigh.c
@@ -205,17 +205,23 @@ static int dn_neigh_output_packet(struct sk_buff *skb)
 	struct neighbour *neigh = dst_get_neighbour_noref(dst);
 	struct net_device *dev = neigh->dev;
 	char mac_addr[ETH_ALEN];
+	unsigned int seq;
+	int err;
 
 	dn_dn2eth(mac_addr, rt->rt_local_src);
-	if (dev_hard_header(skb, dev, ntohs(skb->protocol), neigh->ha,
-			    mac_addr, skb->len) >= 0)
-		return dev_queue_xmit(skb);
-
-	if (net_ratelimit())
-		printk(KERN_DEBUG "dn_neigh_output_packet: oops, can't send packet\n");
-
-	kfree_skb(skb);
-	return -EINVAL;
+	do {
+		seq = read_seqbegin(&neigh->ha_lock);
+		err = dev_hard_header(skb, dev, ntohs(skb->protocol),
+				      neigh->ha, mac_addr, skb->len);
+	} while (read_seqretry(&neigh->ha_lock, seq));
+
+	if (err >= 0)
+		err = dev_queue_xmit(skb);
+	else {
+		kfree_skb(skb);
+		err = -EINVAL;
+	}
+	return err;
 }
 
 static int dn_long_output(struct neighbour *neigh, struct sk_buff *skb)
-- 
1.7.7.6
