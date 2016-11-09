From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net 1/2] bpf: Fix bpf_redirect to an ipip/ip6tnl dev
Date: Wed, 9 Nov 2016 15:36:33 -0800
Message-ID: <1478734594-337666-2-git-send-email-kafai@fb.com>
References: <1478734594-337666-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Kernel Team <kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:42920 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753297AbcKIXhD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 18:37:03 -0500
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uA9NY3oj017365
        for <netdev@vger.kernel.org>; Wed, 9 Nov 2016 15:37:02 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 26mc7v8r4b-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 09 Nov 2016 15:37:02 -0800
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)     by
 mx-out.facebook.com (10.223.100.99) with ESMTP id
 69732512a6d511e6b3a924be05956610-888eba50 for <netdev@vger.kernel.org>;        Wed,
 09 Nov 2016 15:37:01 -0800
In-Reply-To: <1478734594-337666-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the bpf program calls bpf_redirect(dev, 0) and dev is
an ipip/ip6tnl, it currently includes the mac header.
e.g. If dev is ipip, the end result is IP-EthHdr-IP instead
of IP-IP.

The fix is to pull the mac header.  At ingress, skb_postpull_rcsum()
is not needed because the ethhdr should have been pulled once already
and then got pushed back just before calling the bpf_prog.
At egress, this patch calls skb_postpull_rcsum().

If bpf_redirect(dev, BPF_F_INGRESS) is called,
it also fails now because it calls dev_forward_skb() which
eventually calls eth_type_trans(skb, dev).  The eth_type_trans()
will set skb->type = PACKET_OTHERHOST because the mac address
does not match the redirecting dev->dev_addr.  The PACKET_OTHERHOST
will eventually cause the ip_rcv() errors out.  To fix this,
____dev_forward_skb() is added.

Joint work with Daniel Borkmann.

Fixes: cfc7381b3002 ("ip_tunnel: add collect_md mode to IPIP tunnel")
Fixes: 8d79266bc48c ("ip6_tunnel: add collect_md mode to IPv6 tunnels")
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@fb.com>
Signed-off-by: Martin KaFai Lau <kafai@fb.com>
---
 include/linux/netdevice.h | 15 +++++++++++
 net/core/dev.c            | 17 +++++-------
 net/core/filter.c         | 68 +++++++++++++++++++++++++++++++++++++++++------
 3 files changed, 81 insertions(+), 19 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 91ee364..bf04a46 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3354,6 +3354,21 @@ int dev_forward_skb(struct net_device *dev, struct sk_buff *skb);
 bool is_skb_forwardable(const struct net_device *dev,
 			const struct sk_buff *skb);
 
+static __always_inline int ____dev_forward_skb(struct net_device *dev,
+					       struct sk_buff *skb)
+{
+	if (skb_orphan_frags(skb, GFP_ATOMIC) ||
+	    unlikely(!is_skb_forwardable(dev, skb))) {
+		atomic_long_inc(&dev->rx_dropped);
+		kfree_skb(skb);
+		return NET_RX_DROP;
+	}
+
+	skb_scrub_packet(skb, true);
+	skb->priority = 0;
+	return 0;
+}
+
 void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev);
 
 extern int		netdev_budget;
diff --git a/net/core/dev.c b/net/core/dev.c
index eaad4c2..6666b28 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1766,19 +1766,14 @@ EXPORT_SYMBOL_GPL(is_skb_forwardable);
 
 int __dev_forward_skb(struct net_device *dev, struct sk_buff *skb)
 {
-	if (skb_orphan_frags(skb, GFP_ATOMIC) ||
-	    unlikely(!is_skb_forwardable(dev, skb))) {
-		atomic_long_inc(&dev->rx_dropped);
-		kfree_skb(skb);
-		return NET_RX_DROP;
-	}
+	int ret = ____dev_forward_skb(dev, skb);
 
-	skb_scrub_packet(skb, true);
-	skb->priority = 0;
-	skb->protocol = eth_type_trans(skb, dev);
-	skb_postpull_rcsum(skb, eth_hdr(skb), ETH_HLEN);
+	if (likely(!ret)) {
+		skb->protocol = eth_type_trans(skb, dev);
+		skb_postpull_rcsum(skb, eth_hdr(skb), ETH_HLEN);
+	}
 
-	return 0;
+	return ret;
 }
 EXPORT_SYMBOL_GPL(__dev_forward_skb);
 
diff --git a/net/core/filter.c b/net/core/filter.c
index 00351cd..b391209 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1628,6 +1628,19 @@ static inline int __bpf_rx_skb(struct net_device *dev, struct sk_buff *skb)
 	return dev_forward_skb(dev, skb);
 }
 
+static inline int __bpf_rx_skb_no_mac(struct net_device *dev,
+				      struct sk_buff *skb)
+{
+	int ret = ____dev_forward_skb(dev, skb);
+
+	if (likely(!ret)) {
+		skb->dev = dev;
+		ret = netif_rx(skb);
+	}
+
+	return ret;
+}
+
 static inline int __bpf_tx_skb(struct net_device *dev, struct sk_buff *skb)
 {
 	int ret;
@@ -1647,6 +1660,51 @@ static inline int __bpf_tx_skb(struct net_device *dev, struct sk_buff *skb)
 	return ret;
 }
 
+static int __bpf_redirect_no_mac(struct sk_buff *skb, struct net_device *dev,
+				 u32 flags)
+{
+	/* skb->mac_len is not set on normal egress */
+	unsigned int mlen = skb->network_header - skb->mac_header;
+
+	__skb_pull(skb, mlen);
+
+	/* At ingress, the mac header has already been pulled once.
+	 * At egress, skb_pospull_rcsum has to be done in case that
+	 * the skb is originated from ingress (i.e. a forwarded skb)
+	 * to ensure that rcsum starts at net header.
+	 */
+	if (!skb_at_tc_ingress(skb))
+		skb_postpull_rcsum(skb, skb_mac_header(skb), mlen);
+	skb_pop_mac_header(skb);
+	skb_reset_mac_len(skb);
+	return flags & BPF_F_INGRESS ?
+	       __bpf_rx_skb_no_mac(dev, skb) : __bpf_tx_skb(dev, skb);
+}
+
+static int __bpf_redirect_common(struct sk_buff *skb, struct net_device *dev,
+				 u32 flags)
+{
+	bpf_push_mac_rcsum(skb);
+	return flags & BPF_F_INGRESS ?
+	       __bpf_rx_skb(dev, skb) : __bpf_tx_skb(dev, skb);
+}
+
+static int __bpf_redirect(struct sk_buff *skb, struct net_device *dev,
+			  u32 flags)
+{
+	switch (dev->type) {
+	case ARPHRD_TUNNEL:
+	case ARPHRD_TUNNEL6:
+	case ARPHRD_SIT:
+	case ARPHRD_IPGRE:
+	case ARPHRD_VOID:
+	case ARPHRD_NONE:
+		return __bpf_redirect_no_mac(skb, dev, flags);
+	default:
+		return __bpf_redirect_common(skb, dev, flags);
+	}
+}
+
 BPF_CALL_3(bpf_clone_redirect, struct sk_buff *, skb, u32, ifindex, u64, flags)
 {
 	struct net_device *dev;
@@ -1675,10 +1733,7 @@ BPF_CALL_3(bpf_clone_redirect, struct sk_buff *, skb, u32, ifindex, u64, flags)
 		return -ENOMEM;
 	}
 
-	bpf_push_mac_rcsum(clone);
-
-	return flags & BPF_F_INGRESS ?
-	       __bpf_rx_skb(dev, clone) : __bpf_tx_skb(dev, clone);
+	return __bpf_redirect(clone, dev, flags);
 }
 
 static const struct bpf_func_proto bpf_clone_redirect_proto = {
@@ -1722,10 +1777,7 @@ int skb_do_redirect(struct sk_buff *skb)
 		return -EINVAL;
 	}
 
-	bpf_push_mac_rcsum(skb);
-
-	return ri->flags & BPF_F_INGRESS ?
-	       __bpf_rx_skb(dev, skb) : __bpf_tx_skb(dev, skb);
+	return __bpf_redirect(skb, dev, ri->flags);
 }
 
 static const struct bpf_func_proto bpf_redirect_proto = {
-- 
2.5.1
