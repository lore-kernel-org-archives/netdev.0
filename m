From: David Lamparter <equinox@diac24.net>
Subject: [PATCH 4/6] mpls: split forwarding path on rx/tx boundary
Date: Mon, 21 Aug 2017 19:15:21 +0200
Message-ID: <20170821171523.951260-5-equinox@diac24.net>
References: <20170821171523.951260-1-equinox@diac24.net>
Cc: amine.kherbouche@6wind.com, roopa@cumulusnetworks.com,
        stephen@networkplumber.org, David Lamparter <equinox@diac24.net>
To: netdev@vger.kernel.org, bridge@lists.linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eidolon.nox.tf ([185.142.180.128]:37108 "EHLO eidolon.nox.tf"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754027AbdHURPr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Aug 2017 13:15:47 -0400
In-Reply-To: <20170821171523.951260-1-equinox@diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This makes mpls_rt_xmit() available for use in upcoming VPLS code.  Same
for mpls_route_input_rcu().

Signed-off-by: David Lamparter <equinox@diac24.net>
---
 net/mpls/af_mpls.c  | 48 ++++++++++++++++++++++++++++++------------------
 net/mpls/internal.h |  4 ++++
 2 files changed, 34 insertions(+), 18 deletions(-)

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index c5b9ce41d66f..1de2b3501dc8 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -43,7 +43,7 @@ static void rtmsg_lfib(int event, u32 label, struct mpls_route *rt,
 		       struct nlmsghdr *nlh, struct net *net, u32 portid,
 		       unsigned int nlm_flags);
 
-static struct mpls_route *mpls_route_input_rcu(struct net *net, unsigned index)
+struct mpls_route *mpls_route_input_rcu(struct net *net, unsigned index)
 {
 	struct mpls_route *rt = NULL;
 
@@ -313,15 +313,8 @@ static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
 	struct net *net = dev_net(dev);
 	struct mpls_shim_hdr *hdr;
 	struct mpls_route *rt;
-	struct mpls_nh *nh;
 	struct mpls_entry_decoded dec;
-	struct net_device *out_dev;
-	struct mpls_dev *out_mdev;
 	struct mpls_dev *mdev;
-	unsigned int hh_len;
-	unsigned int new_header_size;
-	unsigned int mtu;
-	int err;
 
 	/* Careful this entire function runs inside of an rcu critical section */
 
@@ -356,9 +349,6 @@ static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
 		goto drop;
 	}
 
-	nh = mpls_select_multipath(rt, skb);
-	if (!nh)
-		goto err;
 
 	/* Pop the label */
 	skb_pull(skb, sizeof(*hdr));
@@ -376,6 +366,32 @@ static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
 		goto err;
 	dec.ttl -= 1;
 
+	if (mpls_rt_xmit(skb, rt, dec))
+		goto drop;
+	return 0;
+
+err:
+	MPLS_INC_STATS(mdev, rx_errors);
+drop:
+	kfree_skb(skb);
+	return NET_RX_DROP;
+}
+
+int mpls_rt_xmit(struct sk_buff *skb, struct mpls_route *rt,
+		 struct mpls_entry_decoded dec)
+{
+	struct mpls_nh *nh;
+	struct net_device *out_dev = NULL;
+	struct mpls_dev *out_mdev;
+	unsigned int hh_len;
+	unsigned int new_header_size;
+	unsigned int mtu;
+	int err;
+
+	nh = mpls_select_multipath(rt, skb);
+	if (!nh)
+		goto tx_err;
+
 	/* Find the output device */
 	out_dev = rcu_dereference(nh->nh_dev);
 	if (!mpls_output_possible(out_dev))
@@ -401,8 +417,9 @@ static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
 	if (unlikely(!new_header_size && dec.bos)) {
 		/* Penultimate hop popping */
 		if (!mpls_egress(dev_net(out_dev), rt, skb, dec))
-			goto err;
+			goto tx_err;
 	} else {
+		struct mpls_shim_hdr *hdr;
 		bool bos;
 		int i;
 		skb_push(skb, new_header_size);
@@ -435,12 +452,7 @@ static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
 	out_mdev = out_dev ? mpls_dev_get(out_dev) : NULL;
 	if (out_mdev)
 		MPLS_INC_STATS(out_mdev, tx_errors);
-	goto drop;
-err:
-	MPLS_INC_STATS(mdev, rx_errors);
-drop:
-	kfree_skb(skb);
-	return NET_RX_DROP;
+	return -1;
 }
 
 static struct packet_type mpls_packet_type __read_mostly = {
diff --git a/net/mpls/internal.h b/net/mpls/internal.h
index cf65aec2e551..b70c6663d4f3 100644
--- a/net/mpls/internal.h
+++ b/net/mpls/internal.h
@@ -210,4 +210,8 @@ bool mpls_pkt_too_big(const struct sk_buff *skb, unsigned int mtu);
 void mpls_stats_inc_outucastpkts(struct net_device *dev,
 				 const struct sk_buff *skb);
 
+struct mpls_route *mpls_route_input_rcu(struct net *net, unsigned index);
+int mpls_rt_xmit(struct sk_buff *skb, struct mpls_route *rt,
+		 struct mpls_entry_decoded dec);
+
 #endif /* MPLS_INTERNAL_H */
-- 
2.13.0
