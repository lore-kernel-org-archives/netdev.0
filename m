From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [NET]: Added GSO header verification
Date: Tue, 27 Jun 2006 22:07:14 +1000
Message-ID: <20060627120714.GA15270@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:30994 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932292AbWF0MHW
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jun 2006 08:07:22 -0400
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave:

This feature is only needed by Xen but most of the code here is useful
for other things like TCPv4 ECN support.

[NET]: Added GSO header verification

When GSO packets come from an untrusted source (e.g., a Xen guest domain),
we need to verify the header integrity before passing it to the hardware.

Since the first step in GSO is to verify the header, we can reuse that
code by adding a new bit to gso_type: SKB_GSO_DODGY.  Packets with this
bit set can only be fed directly to devices with the corresponding bit
NETIF_F_GSO_ROBUST.  If the device doesn't have that bit, then the skb
is fed to the GSO engine which will allow the packet to be sent to the
hardware if it passes the header check.

This patch changes the sg flag to a full features flag.  The same method
can be used to implement TSO ECN support.  We simply have to mark packets
with CWR set with SKB_GSO_ECN so that only hardware with a corresponding
NETIF_F_TSO_ECN can accept them.  The GSO engine can either fully segment
the packet, or segment the first MTU and pass the rest to the hardware for
further segmentation.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -315,6 +315,7 @@ struct net_device
 #define NETIF_F_GSO_SHIFT	16
 #define NETIF_F_TSO		(SKB_GSO_TCPV4 << NETIF_F_GSO_SHIFT)
 #define NETIF_F_UFO		(SKB_GSO_UDPV4 << NETIF_F_GSO_SHIFT)
+#define NETIF_F_GSO_ROBUST	(SKB_GSO_DODGY << NETIF_F_GSO_SHIFT)
 
 #define NETIF_F_GEN_CSUM	(NETIF_F_NO_CSUM | NETIF_F_HW_CSUM)
 #define NETIF_F_ALL_CSUM	(NETIF_F_IP_CSUM | NETIF_F_GEN_CSUM)
@@ -543,7 +544,8 @@ struct packet_type {
 					 struct net_device *,
 					 struct packet_type *,
 					 struct net_device *);
-	struct sk_buff		*(*gso_segment)(struct sk_buff *skb, int sg);
+	struct sk_buff		*(*gso_segment)(struct sk_buff *skb,
+						int features);
 	void			*af_packet_priv;
 	struct list_head	list;
 };
@@ -968,7 +970,7 @@ extern int		netdev_max_backlog;
 extern int		weight_p;
 extern int		netdev_set_master(struct net_device *dev, struct net_device *master);
 extern int skb_checksum_help(struct sk_buff *skb, int inward);
-extern struct sk_buff *skb_gso_segment(struct sk_buff *skb, int sg);
+extern struct sk_buff *skb_gso_segment(struct sk_buff *skb, int features);
 #ifdef CONFIG_BUG
 extern void netdev_rx_csum_fault(struct net_device *dev);
 #else
@@ -988,11 +990,16 @@ extern void dev_seq_stop(struct seq_file
 
 extern void linkwatch_run_queue(void);
 
+static inline int skb_gso_ok(struct sk_buff *skb, int features)
+{
+	int feature = skb_shinfo(skb)->gso_size ?
+		      skb_shinfo(skb)->gso_type << NETIF_F_GSO_SHIFT : 0;
+	return (features & feature) != feature;
+}
+
 static inline int netif_needs_gso(struct net_device *dev, struct sk_buff *skb)
 {
-	int feature = skb_shinfo(skb)->gso_type << NETIF_F_GSO_SHIFT;
-	return skb_shinfo(skb)->gso_size &&
-	       (dev->features & feature) != feature;
+	return skb_gso_ok(skb, dev->features);
 }
 
 #endif /* __KERNEL__ */
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -172,6 +172,9 @@ enum {
 enum {
 	SKB_GSO_TCPV4 = 1 << 0,
 	SKB_GSO_UDPV4 = 1 << 1,
+
+	/* This indicates the skb is from an untrusted source. */
+	SKB_GSO_DODGY = 1 << 2,
 };
 
 /** 
@@ -1299,7 +1302,7 @@ extern void	       skb_split(struct sk_b
 				 struct sk_buff *skb1, const u32 len);
 
 extern void	       skb_release_data(struct sk_buff *skb);
-extern struct sk_buff *skb_segment(struct sk_buff *skb, int sg);
+extern struct sk_buff *skb_segment(struct sk_buff *skb, int features);
 
 static inline void *skb_header_pointer(const struct sk_buff *skb, int offset,
 				       int len, void *buffer)
diff --git a/include/net/protocol.h b/include/net/protocol.h
--- a/include/net/protocol.h
+++ b/include/net/protocol.h
@@ -36,7 +36,8 @@
 struct net_protocol {
 	int			(*handler)(struct sk_buff *skb);
 	void			(*err_handler)(struct sk_buff *skb, u32 info);
-	struct sk_buff	       *(*gso_segment)(struct sk_buff *skb, int sg);
+	struct sk_buff	       *(*gso_segment)(struct sk_buff *skb,
+					       int features);
 	int			no_policy;
 };
 
diff --git a/include/net/tcp.h b/include/net/tcp.h
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1086,7 +1086,7 @@ extern struct request_sock_ops tcp_reque
 
 extern int tcp_v4_destroy_sock(struct sock *sk);
 
-extern struct sk_buff *tcp_tso_segment(struct sk_buff *skb, int sg);
+extern struct sk_buff *tcp_tso_segment(struct sk_buff *skb, int features);
 
 #ifdef CONFIG_PROC_FS
 extern int  tcp4_proc_init(void);
diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -184,6 +184,6 @@ void br_dev_setup(struct net_device *dev
 	dev->set_mac_address = br_set_mac_address;
 	dev->priv_flags = IFF_EBRIDGE;
 
- 	dev->features = NETIF_F_SG | NETIF_F_FRAGLIST
- 		| NETIF_F_HIGHDMA | NETIF_F_TSO | NETIF_F_NO_CSUM;
+ 	dev->features = NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_HIGHDMA |
+ 			NETIF_F_TSO | NETIF_F_NO_CSUM | NETIF_F_GSO_ROBUST;
 }
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -392,7 +392,8 @@ void br_features_recompute(struct net_br
 		features &= feature;
 	}
 
-	br->dev->features = features | checksum | NETIF_F_LLTX;
+	br->dev->features = features | checksum | NETIF_F_LLTX |
+			    NETIF_F_GSO_ROBUST;
 }
 
 /* called with RTNL */
diff --git a/net/core/dev.c b/net/core/dev.c
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1190,11 +1190,14 @@ out:	
 /**
  *	skb_gso_segment - Perform segmentation on skb.
  *	@skb: buffer to segment
- *	@sg: whether scatter-gather is supported on the target.
+ *	@features: features for the output path (see dev->features)
  *
  *	This function segments the given skb and returns a list of segments.
+ *
+ *	It may return NULL if the skb requires no segmentation.  This is
+ *	only possible when GSO is used for verifying header integrity.
  */
-struct sk_buff *skb_gso_segment(struct sk_buff *skb, int sg)
+struct sk_buff *skb_gso_segment(struct sk_buff *skb, int features)
 {
 	struct sk_buff *segs = ERR_PTR(-EPROTONOSUPPORT);
 	struct packet_type *ptype;
@@ -1210,12 +1213,14 @@ struct sk_buff *skb_gso_segment(struct s
 	rcu_read_lock();
 	list_for_each_entry_rcu(ptype, &ptype_base[ntohs(type) & 15], list) {
 		if (ptype->type == type && !ptype->dev && ptype->gso_segment) {
-			segs = ptype->gso_segment(skb, sg);
+			segs = ptype->gso_segment(skb, features);
 			break;
 		}
 	}
 	rcu_read_unlock();
 
+	__skb_push(skb, skb->data - skb->mac.raw);
+
 	return segs;
 }
 
@@ -1291,9 +1296,15 @@ static int dev_gso_segment(struct sk_buf
 {
 	struct net_device *dev = skb->dev;
 	struct sk_buff *segs;
+	int features = dev->features & ~(illegal_highdma(dev, skb) ?
+					 NETIF_F_SG : 0);
+
+	segs = skb_gso_segment(skb, features);
+
+	/* Verifying header integrity only. */
+	if (!segs)
+		return 0;
 
-	segs = skb_gso_segment(skb, dev->features & NETIF_F_SG &&
-				    !illegal_highdma(dev, skb));
 	if (unlikely(IS_ERR(segs)))
 		return PTR_ERR(segs);
 
@@ -1310,13 +1321,17 @@ int dev_hard_start_xmit(struct sk_buff *
 		if (netdev_nit)
 			dev_queue_xmit_nit(skb, dev);
 
-		if (!netif_needs_gso(dev, skb))
-			return dev->hard_start_xmit(skb, dev);
+		if (netif_needs_gso(dev, skb)) {
+			if (unlikely(dev_gso_segment(skb)))
+				goto out_kfree_skb;
+			if (skb->next)
+				goto gso;
+		}
 
-		if (unlikely(dev_gso_segment(skb)))
-			goto out_kfree_skb;
+		return dev->hard_start_xmit(skb, dev);
 	}
 
+gso:
 	do {
 		struct sk_buff *nskb = skb->next;
 		int rc;
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1848,13 +1848,13 @@ EXPORT_SYMBOL_GPL(skb_pull_rcsum);
 /**
  *	skb_segment - Perform protocol segmentation on skb.
  *	@skb: buffer to segment
- *	@sg: whether scatter-gather can be used for generated segments
+ *	@features: features for the output path (see dev->features)
  *
  *	This function performs segmentation on the given skb.  It returns
  *	the segment at the given position.  It returns NULL if there are
  *	no more segments to generate, or when an error is encountered.
  */
-struct sk_buff *skb_segment(struct sk_buff *skb, int sg)
+struct sk_buff *skb_segment(struct sk_buff *skb, int features)
 {
 	struct sk_buff *segs = NULL;
 	struct sk_buff *tail = NULL;
@@ -1863,6 +1863,7 @@ struct sk_buff *skb_segment(struct sk_bu
 	unsigned int offset = doffset;
 	unsigned int headroom;
 	unsigned int len;
+	int sg = features & NETIF_F_SG;
 	int nfrags = skb_shinfo(skb)->nr_frags;
 	int err = -ENOMEM;
 	int i = 0;
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1097,7 +1097,7 @@ int inet_sk_rebuild_header(struct sock *
 
 EXPORT_SYMBOL(inet_sk_rebuild_header);
 
-static struct sk_buff *inet_gso_segment(struct sk_buff *skb, int sg)
+static struct sk_buff *inet_gso_segment(struct sk_buff *skb, int features)
 {
 	struct sk_buff *segs = ERR_PTR(-EINVAL);
 	struct iphdr *iph;
@@ -1126,10 +1126,10 @@ static struct sk_buff *inet_gso_segment(
 	rcu_read_lock();
 	ops = rcu_dereference(inet_protos[proto]);
 	if (ops && ops->gso_segment)
-		segs = ops->gso_segment(skb, sg);
+		segs = ops->gso_segment(skb, features);
 	rcu_read_unlock();
 
-	if (IS_ERR(segs))
+	if (!segs || unlikely(IS_ERR(segs)))
 		goto out;
 
 	skb = segs;
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2145,7 +2145,7 @@ int compat_tcp_getsockopt(struct sock *s
 EXPORT_SYMBOL(compat_tcp_getsockopt);
 #endif
 
-struct sk_buff *tcp_tso_segment(struct sk_buff *skb, int sg)
+struct sk_buff *tcp_tso_segment(struct sk_buff *skb, int features)
 {
 	struct sk_buff *segs = ERR_PTR(-EINVAL);
 	struct tcphdr *th;
@@ -2166,10 +2166,14 @@ struct sk_buff *tcp_tso_segment(struct s
 	if (!pskb_may_pull(skb, thlen))
 		goto out;
 
+	segs = NULL;
+	if (skb_gso_ok(skb, features | NETIF_F_GSO_ROBUST))
+		goto out;
+
 	oldlen = (u16)~skb->len;
 	__skb_pull(skb, thlen);
 
-	segs = skb_segment(skb, sg);
+	segs = skb_segment(skb, features);
 	if (IS_ERR(segs))
 		goto out;
 
