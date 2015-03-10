From: Andy Zhou <azhou@nicira.com>
Subject: [patch net-next v2 3/5] net: refactor IPv4 and IPv6 fragmentation APIs
Date: Tue, 10 Mar 2015 12:07:16 -0700
Message-ID: <1426014438-9317-4-git-send-email-azhou@nicira.com>
References: <1426014438-9317-1-git-send-email-azhou@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog120.obsmtp.com ([74.125.149.140]:52943 "HELO
	na3sys009aog120.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752647AbbCJTQn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 15:16:43 -0400
Received: by mail-pa0-f46.google.com with SMTP id et14so4535670pad.11
        for <netdev@vger.kernel.org>; Tue, 10 Mar 2015 12:16:42 -0700 (PDT)
In-Reply-To: <1426014438-9317-1-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Both ip_fragment() and ip6_fragment() APIs assume skb has an
attached netdev device, from which the MTU size can be derived.
However, skbs incoming from OVS vports do not have an attached
netdev device.

This patch splits the original function into two parts: The core
fragmentation logic is now provided by
ip_fragment_mtu()/ip6_fragment_mut().

The original APIs are kept as is. Their implementation now calls
the new APIs. Any information derived from the attached netdev
device is first derived in the original APIs and passed into the
new APIs.

In addition, The call back output function into the new APIs now
accepts two arguments: a skb and an application specific pointer,
which specifies additional information not directly associated
with skb, such as OVS flow, to the output function.

Signed-off-by: Andy Zhou <azhou@nicira.com>
---
 include/net/ip.h          |   6 +-
 include/net/ip6_route.h   |   3 +-
 include/net/ipv6.h        |   4 ++
 net/bridge/br_netfilter.c |   7 +-
 net/ipv4/ip_output.c      | 126 ++++++++++++++++++++---------------
 net/ipv6/ip6_output.c     | 165 ++++++++++++++++++++++++++++------------------
 net/ipv6/xfrm6_output.c   |   9 ++-
 7 files changed, 198 insertions(+), 122 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index 025c61c..bd49ecc 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -108,7 +108,11 @@ int ip_local_deliver(struct sk_buff *skb);
 int ip_mr_input(struct sk_buff *skb);
 int ip_output(struct sock *sk, struct sk_buff *skb);
 int ip_mc_output(struct sock *sk, struct sk_buff *skb);
-int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *));
+int ip_fragment(struct sk_buff *skb, void *output_arg,
+		int (*output)(struct sk_buff *, void *output_arg));
+int ip_fragment_mtu(struct sk_buff *skb, unsigned int mtu, unsigned int ll_rs,
+		    struct net_device *dev, void *output_arg,
+		    int (*output)(struct sk_buff *, void *output_arg));
 int ip_do_nat(struct sk_buff *skb);
 void ip_send_check(struct iphdr *ip);
 int __ip_local_out(struct sk_buff *skb);
diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 1d09b46..7e2c2c5 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -170,7 +170,8 @@ static inline bool ipv6_anycast_destination(const struct sk_buff *skb)
 	return rt->rt6i_flags & RTF_ANYCAST;
 }
 
-int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *));
+int ip6_fragment(struct sk_buff *skb, void *output_arg,
+		 int (*output)(struct sk_buff *, void *output_arg));
 
 static inline int ip6_skb_dst_mtu(struct sk_buff *skb)
 {
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index db92dc7..d35e769 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -910,6 +910,10 @@ int ip6_mc_source(int add, int omode, struct sock *sk,
 int ip6_mc_msfilter(struct sock *sk, struct group_filter *gsf);
 int ip6_mc_msfget(struct sock *sk, struct group_filter *gsf,
 		  struct group_filter __user *optval, int __user *optlen);
+int ip6_fragment_mtu(struct sk_buff *skb, unsigned int mtu, int hroom,
+		     int troom, struct net_device *dev, __be32 frag_id,
+		     void *output_arg,
+		     int (*output)(struct sk_buff *, void *));
 
 #ifdef CONFIG_PROC_FS
 int ac6_proc_init(struct net *net);
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 0ee453f..6bef77b 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -764,6 +764,11 @@ static unsigned int br_nf_forward_arp(const struct nf_hook_ops *ops,
 }
 
 #if IS_ENABLED(CONFIG_NF_DEFRAG_IPV4)
+static int br_dev_queue_push_xmit__(struct sk_buff *skb, void *__unused)
+{
+	 return br_dev_queue_push_xmit(skb);
+}
+
 static int br_nf_dev_queue_xmit(struct sk_buff *skb)
 {
 	int ret;
@@ -780,7 +785,7 @@ static int br_nf_dev_queue_xmit(struct sk_buff *skb)
 			/* Drop invalid packet */
 			return NF_DROP;
 		IPCB(skb)->frag_max_size = frag_max_size;
-		ret = ip_fragment(skb, br_dev_queue_push_xmit);
+		ret = ip_fragment(skb, NULL, br_dev_queue_push_xmit__);
 	} else
 		ret = br_dev_queue_push_xmit(skb);
 
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index a7aea20..a0dfe18 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -211,6 +211,11 @@ static inline int ip_finish_output2(struct sk_buff *skb)
 	return -EINVAL;
 }
 
+static inline int __ip_finish_output2(struct sk_buff *skb, void *__unused)
+{
+	return ip_finish_output2(skb);
+}
+
 static int ip_finish_output_gso(struct sk_buff *skb)
 {
 	netdev_features_t features;
@@ -243,7 +248,7 @@ static int ip_finish_output_gso(struct sk_buff *skb)
 		int err;
 
 		segs->next = NULL;
-		err = ip_fragment(segs, ip_finish_output2);
+		err = ip_fragment(segs, NULL, __ip_finish_output2);
 
 		if (err && ret == 0)
 			ret = err;
@@ -266,7 +271,7 @@ static int ip_finish_output(struct sk_buff *skb)
 		return ip_finish_output_gso(skb);
 
 	if (skb->len > ip_skb_dst_mtu(skb))
-		return ip_fragment(skb, ip_finish_output2);
+		return ip_fragment(skb, NULL, __ip_finish_output2);
 
 	return ip_finish_output2(skb);
 }
@@ -472,54 +477,22 @@ static void ip_copy_metadata(struct sk_buff *to, struct sk_buff *from)
 	skb_copy_secmark(to, from);
 }
 
-/*
- *	This IP datagram is too large to be sent in one piece.  Break it up into
- *	smaller pieces (each of size equal to IP header plus
- *	a block of the data of the original IP data part) that will yet fit in a
- *	single device frame, and queue such a frame for sending.
- */
-
-int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
+int ip_fragment_mtu(struct sk_buff *skb, unsigned int mtu, unsigned int ll_rs,
+		    struct net_device *dev, void *output_arg,
+		    int (*output)(struct sk_buff *, void *output_arg))
 {
+	unsigned int hlen, left, len;
+	__be16 not_last_frag;
+	struct sk_buff *skb2;
 	struct iphdr *iph;
 	int ptr;
-	struct net_device *dev;
-	struct sk_buff *skb2;
-	unsigned int mtu, hlen, left, len, ll_rs;
 	int offset;
-	__be16 not_last_frag;
-	struct rtable *rt = skb_rtable(skb);
 	int err = 0;
 
-	dev = rt->dst.dev;
-
-	/*
-	 *	Point into the IP datagram header.
-	 */
-
 	iph = ip_hdr(skb);
-
-	mtu = ip_skb_dst_mtu(skb);
-	if (unlikely(((iph->frag_off & htons(IP_DF)) && !skb->ignore_df) ||
-		     (IPCB(skb)->frag_max_size &&
-		      IPCB(skb)->frag_max_size > mtu))) {
-		IP_INC_STATS(dev_net(dev), IPSTATS_MIB_FRAGFAILS);
-		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED,
-			  htonl(mtu));
-		kfree_skb(skb);
-		return -EMSGSIZE;
-	}
-
-	/*
-	 *	Setup starting values.
-	 */
-
 	hlen = iph->ihl * 4;
 	mtu = mtu - hlen;	/* Size of data space */
-#if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
-	if (skb->nf_bridge)
-		mtu -= nf_bridge_mtu_reduction(skb);
-#endif
+
 	IPCB(skb)->flags |= IPSKB_FRAG_COMPLETE;
 
 	/* When frag_list is given, use it. First, check its validity:
@@ -592,10 +565,11 @@ int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 				ip_send_check(iph);
 			}
 
-			err = output(skb);
+			err = output(skb, output_arg);
 
-			if (!err)
-				IP_INC_STATS(dev_net(dev), IPSTATS_MIB_FRAGCREATES);
+			if (!err && dev)
+				IP_INC_STATS(dev_net(dev),
+					     IPSTATS_MIB_FRAGCREATES);
 			if (err || !frag)
 				break;
 
@@ -605,7 +579,8 @@ int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 		}
 
 		if (err == 0) {
-			IP_INC_STATS(dev_net(dev), IPSTATS_MIB_FRAGOKS);
+			if (dev)
+				IP_INC_STATS(dev_net(dev), IPSTATS_MIB_FRAGOKS);
 			return 0;
 		}
 
@@ -614,7 +589,8 @@ int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 			kfree_skb(frag);
 			frag = skb;
 		}
-		IP_INC_STATS(dev_net(dev), IPSTATS_MIB_FRAGFAILS);
+		if (dev)
+			IP_INC_STATS(dev_net(dev), IPSTATS_MIB_FRAGFAILS);
 		return err;
 
 slow_path_clean:
@@ -636,10 +612,6 @@ slow_path:
 	left = skb->len - hlen;		/* Space per frame */
 	ptr = hlen;		/* Where to start from */
 
-	/* for bridged IP traffic encapsulated inside f.e. a vlan header,
-	 * we need to make room for the encapsulating header
-	 */
-	ll_rs = LL_RESERVED_SPACE_EXTRA(rt->dst.dev, nf_bridge_pad(skb));
 
 	/*
 	 *	Fragment the datagram.
@@ -732,21 +704,67 @@ slow_path:
 
 		ip_send_check(iph);
 
-		err = output(skb2);
+		err = output(skb2, output_arg);
 		if (err)
 			goto fail;
 
-		IP_INC_STATS(dev_net(dev), IPSTATS_MIB_FRAGCREATES);
+		if (dev)
+			IP_INC_STATS(dev_net(dev), IPSTATS_MIB_FRAGCREATES);
 	}
 	consume_skb(skb);
-	IP_INC_STATS(dev_net(dev), IPSTATS_MIB_FRAGOKS);
+	if (dev)
+		IP_INC_STATS(dev_net(dev), IPSTATS_MIB_FRAGOKS);
 	return err;
 
 fail:
 	kfree_skb(skb);
-	IP_INC_STATS(dev_net(dev), IPSTATS_MIB_FRAGFAILS);
+	if (dev)
+		IP_INC_STATS(dev_net(dev), IPSTATS_MIB_FRAGFAILS);
 	return err;
 }
+EXPORT_SYMBOL(ip_fragment_mtu);
+
+/* This IP datagram is too large to be sent in one piece.  Break it up into
+ * smaller pieces (each of size equal to IP header plus
+ * a block of the data of the original IP data part) that will yet fit in a
+ * single device frame, and queue such a frame for sending.
+ */
+int ip_fragment(struct sk_buff *skb, void *output_arg,
+		int (*output)(struct sk_buff *, void *output_arg))
+{
+	struct rtable *rt = skb_rtable(skb);
+	unsigned int mtu, ll_rs;
+	struct net_device *dev;
+	struct iphdr *iph;
+
+	dev = rt->dst.dev;
+
+	/* Point into the IP datagram header.  */
+	iph = ip_hdr(skb);
+
+	mtu = ip_skb_dst_mtu(skb);
+	if (unlikely(((iph->frag_off & htons(IP_DF)) && !skb->ignore_df) ||
+		     (IPCB(skb)->frag_max_size &&
+		      IPCB(skb)->frag_max_size > mtu))) {
+		IP_INC_STATS(dev_net(dev), IPSTATS_MIB_FRAGFAILS);
+		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED,
+			  htonl(mtu));
+		kfree_skb(skb);
+		return -EMSGSIZE;
+	}
+
+	/* Setup starting values.  */
+#if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
+	if (skb->nf_bridge)
+		mtu -= nf_bridge_mtu_reduction(skb);
+#endif
+	/* for bridged IP traffic encapsulated inside f.e. a vlan header,
+	 * we need to make room for the encapsulating header
+	 */
+	ll_rs = LL_RESERVED_SPACE_EXTRA(rt->dst.dev, nf_bridge_pad(skb));
+
+	return ip_fragment_mtu(skb, mtu, ll_rs, output_arg, dev, output);
+}
 EXPORT_SYMBOL(ip_fragment);
 
 int
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 0a04a37..a6714f5 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -122,12 +122,17 @@ static int ip6_finish_output2(struct sk_buff *skb)
 	return -EINVAL;
 }
 
+static int __ip6_finish_output2(struct sk_buff *skb, void *__unused)
+{
+	return ip6_finish_output2(skb);
+}
+
 static int ip6_finish_output(struct sk_buff *skb)
 {
 	if ((skb->len > ip6_skb_dst_mtu(skb) && !skb_is_gso(skb)) ||
 	    dst_allfrag(skb_dst(skb)) ||
 	    (IP6CB(skb)->frag_max_size && skb->len > IP6CB(skb)->frag_max_size))
-		return ip6_fragment(skb, ip6_finish_output2);
+		return ip6_fragment(skb, NULL, __ip6_finish_output2);
 	else
 		return ip6_finish_output2(skb);
 }
@@ -537,46 +542,30 @@ static void ip6_copy_metadata(struct sk_buff *to, struct sk_buff *from)
 	skb_copy_secmark(to, from);
 }
 
-int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
+int ip6_fragment_mtu(struct sk_buff *skb, unsigned int mtu,
+		     int hroom, int troom, struct net_device *dev,
+		     __be32 frag_id, void *output_arg,
+		     int (*output)(struct sk_buff *, void *))
 {
-	struct sk_buff *frag;
-	struct rt6_info *rt = (struct rt6_info *)skb_dst(skb);
-	struct ipv6_pinfo *np = skb->sk ? inet6_sk(skb->sk) : NULL;
-	struct ipv6hdr *tmp_hdr;
-	struct frag_hdr *fh;
-	unsigned int mtu, hlen, left, len;
-	int hroom, troom;
-	__be32 frag_id = 0;
 	int ptr, offset = 0, err = 0;
+	unsigned int hlen, left, len;
 	u8 *prevhdr, nexthdr = 0;
-	struct net *net = dev_net(skb_dst(skb)->dev);
-
-	hlen = ip6_find_1stfragopt(skb, &prevhdr);
-	nexthdr = *prevhdr;
-
-	mtu = ip6_skb_dst_mtu(skb);
-
-	/* We must not fragment if the socket is set to force MTU discovery
-	 * or if the skb it not generated by a local socket.
-	 */
-	if (unlikely(!skb->ignore_df && skb->len > mtu) ||
-		     (IP6CB(skb)->frag_max_size &&
-		      IP6CB(skb)->frag_max_size > mtu)) {
-		if (skb->sk && dst_allfrag(skb_dst(skb)))
-			sk_nocaps_add(skb->sk, NETIF_F_GSO_MASK);
+	struct ipv6hdr *tmp_hdr;
+	struct sk_buff *frag;
+	struct frag_hdr *fh;
+	struct rt6_info *rt;
+	struct net *net;
 
-		skb->dev = skb_dst(skb)->dev;
-		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
-		IP6_INC_STATS(net, ip6_dst_idev(skb_dst(skb)),
-			      IPSTATS_MIB_FRAGFAILS);
-		kfree_skb(skb);
-		return -EMSGSIZE;
+	if (dev) {
+		net = dev_net(skb_dst(skb)->dev);
+		rt = (struct rt6_info *)skb_dst(skb);
+	} else {
+		net = NULL;
+		rt = NULL;
 	}
 
-	if (np && np->frag_size < mtu) {
-		if (np->frag_size)
-			mtu = np->frag_size;
-	}
+	hlen = ip6_find_1stfragopt(skb, &prevhdr);
+	nexthdr = *prevhdr;
 	mtu -= hlen + sizeof(struct frag_hdr);
 
 	if (skb_has_frag_list(skb)) {
@@ -616,8 +605,9 @@ int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 		*prevhdr = NEXTHDR_FRAGMENT;
 		tmp_hdr = kmemdup(skb_network_header(skb), hlen, GFP_ATOMIC);
 		if (!tmp_hdr) {
-			IP6_INC_STATS(net, ip6_dst_idev(skb_dst(skb)),
-				      IPSTATS_MIB_FRAGFAILS);
+			if (dev)
+				IP6_INC_STATS(net, ip6_dst_idev(skb_dst(skb)),
+					      IPSTATS_MIB_FRAGFAILS);
 			return -ENOMEM;
 		}
 
@@ -627,11 +617,10 @@ int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 		skb_reset_network_header(skb);
 		memcpy(skb_network_header(skb), tmp_hdr, hlen);
 
-		ipv6_select_ident(fh, rt);
 		fh->nexthdr = nexthdr;
 		fh->reserved = 0;
 		fh->frag_off = htons(IP6_MF);
-		frag_id = fh->identification;
+		fh->identification = frag_id;
 
 		first_len = skb_pagelen(skb);
 		skb->data_len = first_len - skb_headlen(skb);
@@ -639,7 +628,8 @@ int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 		ipv6_hdr(skb)->payload_len = htons(first_len -
 						   sizeof(struct ipv6hdr));
 
-		dst_hold(&rt->dst);
+		if (dev)
+			dst_hold(&rt->dst);
 
 		for (;;) {
 			/* Prepare header of the next frame,
@@ -665,8 +655,8 @@ int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 				ip6_copy_metadata(frag, skb);
 			}
 
-			err = output(skb);
-			if (!err)
+			err = output(skb, output_arg);
+			if (!err && dev)
 				IP6_INC_STATS(net, ip6_dst_idev(&rt->dst),
 					      IPSTATS_MIB_FRAGCREATES);
 
@@ -681,17 +671,21 @@ int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 		kfree(tmp_hdr);
 
 		if (err == 0) {
-			IP6_INC_STATS(net, ip6_dst_idev(&rt->dst),
-				      IPSTATS_MIB_FRAGOKS);
-			ip6_rt_put(rt);
+			if (dev) {
+				IP6_INC_STATS(net, ip6_dst_idev(&rt->dst),
+					      IPSTATS_MIB_FRAGOKS);
+				ip6_rt_put(rt);
+			}
 			return 0;
 		}
 
 		kfree_skb_list(frag);
 
-		IP6_INC_STATS(net, ip6_dst_idev(&rt->dst),
-			      IPSTATS_MIB_FRAGFAILS);
-		ip6_rt_put(rt);
+		if (dev) {
+			IP6_INC_STATS(net, ip6_dst_idev(&rt->dst),
+				      IPSTATS_MIB_FRAGFAILS);
+			ip6_rt_put(rt);
+		}
 		return err;
 
 slow_path_clean:
@@ -717,8 +711,6 @@ slow_path:
 	 */
 
 	*prevhdr = NEXTHDR_FRAGMENT;
-	hroom = LL_RESERVED_SPACE(rt->dst.dev);
-	troom = rt->dst.dev->needed_tailroom;
 
 	/*
 	 *	Keep copying data until we run out.
@@ -738,8 +730,10 @@ slow_path:
 		frag = alloc_skb(len + hlen + sizeof(struct frag_hdr) +
 				 hroom + troom, GFP_ATOMIC);
 		if (!frag) {
-			IP6_INC_STATS(net, ip6_dst_idev(skb_dst(skb)),
-				      IPSTATS_MIB_FRAGFAILS);
+			if (dev)
+				IP6_INC_STATS(net, ip6_dst_idev(skb_dst(skb)),
+					      IPSTATS_MIB_FRAGFAILS);
+
 			err = -ENOMEM;
 			goto fail;
 		}
@@ -773,11 +767,7 @@ slow_path:
 		 */
 		fh->nexthdr = nexthdr;
 		fh->reserved = 0;
-		if (!frag_id) {
-			ipv6_select_ident(fh, rt);
-			frag_id = fh->identification;
-		} else
-			fh->identification = frag_id;
+		fh->identification = frag_id;
 
 		/*
 		 *	Copy a block of the IP datagram.
@@ -798,24 +788,71 @@ slow_path:
 		/*
 		 *	Put this fragment into the sending queue.
 		 */
-		err = output(frag);
+		err = output(frag, output_arg);
 		if (err)
 			goto fail;
 
-		IP6_INC_STATS(net, ip6_dst_idev(skb_dst(skb)),
-			      IPSTATS_MIB_FRAGCREATES);
+		if (dev)
+			IP6_INC_STATS(net, ip6_dst_idev(skb_dst(skb)),
+				      IPSTATS_MIB_FRAGCREATES);
 	}
-	IP6_INC_STATS(net, ip6_dst_idev(skb_dst(skb)),
-		      IPSTATS_MIB_FRAGOKS);
+	if (dev)
+		IP6_INC_STATS(net, ip6_dst_idev(skb_dst(skb)),
+			      IPSTATS_MIB_FRAGOKS);
 	consume_skb(skb);
 	return err;
 
 fail:
-	IP6_INC_STATS(net, ip6_dst_idev(skb_dst(skb)),
-		      IPSTATS_MIB_FRAGFAILS);
+	if (dev)
+		IP6_INC_STATS(net, ip6_dst_idev(skb_dst(skb)),
+			      IPSTATS_MIB_FRAGFAILS);
 	kfree_skb(skb);
 	return err;
 }
+EXPORT_SYMBOL(ip6_fragment_mtu);
+
+int ip6_fragment(struct sk_buff *skb, void *output_arg,
+		 int (*output)(struct sk_buff *, void *))
+{
+	struct ipv6_pinfo *np = skb->sk ? inet6_sk(skb->sk) : NULL;
+	struct rt6_info *rt = (struct rt6_info *)skb_dst(skb);
+	struct net *net = dev_net(skb_dst(skb)->dev);
+	struct net_device *dev = skb_dst(skb)->dev;
+	struct frag_hdr fh;
+	unsigned int mtu;
+	int hroom, troom;
+
+	hroom = LL_RESERVED_SPACE(rt->dst.dev);
+	troom = rt->dst.dev->needed_tailroom;
+	mtu = ip6_skb_dst_mtu(skb);
+
+	/* We must not fragment if the socket is set to force MTU discovery
+	 * or if the skb it not generated by a local socket.
+	 */
+	if (unlikely(!skb->ignore_df && skb->len > mtu) ||
+	    (IP6CB(skb)->frag_max_size &&
+	     IP6CB(skb)->frag_max_size > mtu)) {
+		if (skb->sk && dst_allfrag(skb_dst(skb)))
+			sk_nocaps_add(skb->sk, NETIF_F_GSO_MASK);
+
+		skb->dev = skb_dst(skb)->dev;
+		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
+		IP6_INC_STATS(net, ip6_dst_idev(skb_dst(skb)),
+			      IPSTATS_MIB_FRAGFAILS);
+		kfree_skb(skb);
+		return -EMSGSIZE;
+	}
+
+	if (np && np->frag_size < mtu) {
+		if (np->frag_size)
+			mtu = np->frag_size;
+	}
+
+	dev = skb_dst(skb)->dev;
+	ipv6_select_ident(&fh, rt);
+	return ip6_fragment_mtu(skb, mtu, hroom, troom, dev,
+				fh.identification, NULL, output);
+}
 
 static inline int ip6_rt_check(const struct rt6key *rt_key,
 			       const struct in6_addr *fl_addr,
diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
index ca3f29b..ce52f2f 100644
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -131,6 +131,13 @@ int xfrm6_output_finish(struct sk_buff *skb)
 	return xfrm_output(skb);
 }
 
+static int __xfrm6_output_finish(struct sk_buff *skb, void *_x)
+{
+	struct xfrm_state *x = (struct xfrm_state *)_x;
+
+	return x->outer_mode->afinfo->output_finish(skb);
+}
+
 static int __xfrm6_output(struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb_dst(skb);
@@ -160,7 +167,7 @@ static int __xfrm6_output(struct sk_buff *skb)
 	if (x->props.mode == XFRM_MODE_TUNNEL &&
 	    ((skb->len > mtu && !skb_is_gso(skb)) ||
 		dst_allfrag(skb_dst(skb)))) {
-			return ip6_fragment(skb, x->outer_mode->afinfo->output_finish);
+			return ip6_fragment(skb, x, __xfrm6_output_finish);
 	}
 	return x->outer_mode->afinfo->output_finish(skb);
 }
-- 
1.9.1
