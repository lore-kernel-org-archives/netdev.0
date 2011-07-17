From: David Miller <davem@davemloft.net>
Subject: [PATCH 5/5] neigh: Kill ndisc_ops->queue_xmit
Date: Sun, 17 Jul 2011 12:30:28 -0700 (PDT)
Message-ID: <20110717.123028.1472107866738084464.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38808 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756242Ab1GQTaa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jul 2011 15:30:30 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id p6HJUTxX028667
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Sun, 17 Jul 2011 12:30:29 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


It is always dev_queue_xmit().

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/neighbour.h |    1 -
 net/atm/clip.c          |    1 -
 net/core/neighbour.c    |    4 ++--
 net/decnet/dn_neigh.c   |    5 +----
 net/ipv4/arp.c          |    6 +-----
 net/ipv6/ndisc.c        |    5 +----
 6 files changed, 5 insertions(+), 17 deletions(-)

diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index 60bac81..334e92f 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -122,7 +122,6 @@ struct neigh_ops {
 	void			(*error_report)(struct neighbour *, struct sk_buff*);
 	int			(*output)(struct sk_buff*);
 	int			(*connected_output)(struct sk_buff*);
-	int			(*queue_xmit)(struct sk_buff*);
 };
 
 struct pneigh_entry {
diff --git a/net/atm/clip.c b/net/atm/clip.c
index 036cd43..40d7368 100644
--- a/net/atm/clip.c
+++ b/net/atm/clip.c
@@ -273,7 +273,6 @@ static const struct neigh_ops clip_neigh_ops = {
 	.error_report =		clip_neigh_error,
 	.output =		dev_queue_xmit,
 	.connected_output =	dev_queue_xmit,
-	.queue_xmit =		dev_queue_xmit,
 };
 
 static int clip_constructor(struct neighbour *neigh)
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 2feda6e7..b031cf6 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -1257,7 +1257,7 @@ int neigh_resolve_output(struct sk_buff *skb)
 		} while (read_seqretry(&neigh->ha_lock, seq));
 
 		if (err >= 0)
-			rc = neigh->ops->queue_xmit(skb);
+			rc = dev_queue_xmit(skb);
 		else
 			goto out_kfree_skb;
 	}
@@ -1292,7 +1292,7 @@ int neigh_connected_output(struct sk_buff *skb)
 	} while (read_seqretry(&neigh->ha_lock, seq));
 
 	if (err >= 0)
-		err = neigh->ops->queue_xmit(skb);
+		err = dev_queue_xmit(skb);
 	else {
 		err = -EINVAL;
 		kfree_skb(skb);
diff --git a/net/decnet/dn_neigh.c b/net/decnet/dn_neigh.c
index abf4de8..84fee8a 100644
--- a/net/decnet/dn_neigh.c
+++ b/net/decnet/dn_neigh.c
@@ -64,7 +64,6 @@ static const struct neigh_ops dn_long_ops = {
 	.error_report =		dn_long_error_report,
 	.output =		dn_long_output,
 	.connected_output =	dn_long_output,
-	.queue_xmit =		dev_queue_xmit,
 };
 
 /*
@@ -75,7 +74,6 @@ static const struct neigh_ops dn_short_ops = {
 	.error_report =		dn_short_error_report,
 	.output =		dn_short_output,
 	.connected_output =	dn_short_output,
-	.queue_xmit =		dev_queue_xmit,
 };
 
 /*
@@ -86,7 +84,6 @@ static const struct neigh_ops dn_phase3_ops = {
 	.error_report =		dn_short_error_report, /* Can use short version here */
 	.output =		dn_phase3_output,
 	.connected_output =	dn_phase3_output,
-	.queue_xmit =		dev_queue_xmit
 };
 
 static u32 dn_neigh_hash(const void *pkey,
@@ -212,7 +209,7 @@ static int dn_neigh_output_packet(struct sk_buff *skb)
 	dn_dn2eth(mac_addr, rt->rt_local_src);
 	if (dev_hard_header(skb, dev, ntohs(skb->protocol), neigh->ha,
 			    mac_addr, skb->len) >= 0)
-		return neigh->ops->queue_xmit(skb);
+		return dev_queue_xmit(skb);
 
 	if (net_ratelimit())
 		printk(KERN_DEBUG "dn_neigh_output_packet: oops, can't send packet\n");
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index f5f0aa1..8a21403 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -138,7 +138,6 @@ static const struct neigh_ops arp_generic_ops = {
 	.error_report =		arp_error_report,
 	.output =		neigh_resolve_output,
 	.connected_output =	neigh_connected_output,
-	.queue_xmit =		dev_queue_xmit,
 };
 
 static const struct neigh_ops arp_hh_ops = {
@@ -147,14 +146,12 @@ static const struct neigh_ops arp_hh_ops = {
 	.error_report =		arp_error_report,
 	.output =		neigh_resolve_output,
 	.connected_output =	neigh_resolve_output,
-	.queue_xmit =		dev_queue_xmit,
 };
 
 static const struct neigh_ops arp_direct_ops = {
 	.family =		AF_INET,
 	.output =		dev_queue_xmit,
 	.connected_output =	dev_queue_xmit,
-	.queue_xmit =		dev_queue_xmit,
 };
 
 static const struct neigh_ops arp_broken_ops = {
@@ -163,7 +160,6 @@ static const struct neigh_ops arp_broken_ops = {
 	.error_report =		arp_error_report,
 	.output =		neigh_compat_output,
 	.connected_output =	neigh_compat_output,
-	.queue_xmit =		dev_queue_xmit,
 };
 
 struct neigh_table arp_tbl = {
@@ -254,7 +250,7 @@ static int arp_constructor(struct neighbour *neigh)
 	if (!dev->header_ops) {
 		neigh->nud_state = NUD_NOARP;
 		neigh->ops = &arp_direct_ops;
-		neigh->output = neigh->ops->queue_xmit;
+		neigh->output = dev_queue_xmit;
 	} else {
 		/* Good devices (checked by reading texts, but only Ethernet is
 		   tested)
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index db782d2..482b970 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -107,7 +107,6 @@ static const struct neigh_ops ndisc_generic_ops = {
 	.error_report =		ndisc_error_report,
 	.output =		neigh_resolve_output,
 	.connected_output =	neigh_connected_output,
-	.queue_xmit =		dev_queue_xmit,
 };
 
 static const struct neigh_ops ndisc_hh_ops = {
@@ -116,7 +115,6 @@ static const struct neigh_ops ndisc_hh_ops = {
 	.error_report =		ndisc_error_report,
 	.output =		neigh_resolve_output,
 	.connected_output =	neigh_resolve_output,
-	.queue_xmit =		dev_queue_xmit,
 };
 
 
@@ -124,7 +122,6 @@ static const struct neigh_ops ndisc_direct_ops = {
 	.family =		AF_INET6,
 	.output =		dev_queue_xmit,
 	.connected_output =	dev_queue_xmit,
-	.queue_xmit =		dev_queue_xmit,
 };
 
 struct neigh_table nd_tbl = {
@@ -389,7 +386,7 @@ static int ndisc_constructor(struct neighbour *neigh)
 	if (!dev->header_ops) {
 		neigh->nud_state = NUD_NOARP;
 		neigh->ops = &ndisc_direct_ops;
-		neigh->output = neigh->ops->queue_xmit;
+		neigh->output = dev_queue_xmit;
 	} else {
 		if (is_multicast) {
 			neigh->nud_state = NUD_NOARP;
-- 
1.7.6

