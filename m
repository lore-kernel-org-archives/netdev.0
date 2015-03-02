From: Joe Stringer <joestringer@nicira.com>
Subject: [RFCv2 net-next 5/7] net: refactor ip_fragment()
Date: Mon,  2 Mar 2015 13:55:03 -0800
Message-ID: <1425333305-19702-6-git-send-email-joestringer@nicira.com>
References: <1425333305-19702-1-git-send-email-joestringer@nicira.com>
Cc: Andy Zhou <azhou@nicira.com>, linux-kernel@vger.kernel.org,
	Justin Pettit <jpettit@nicira.com>,
	Thomas Graf <tgraf@suug.ch>, Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog133.obsmtp.com ([74.125.149.82]:46309 "HELO
	na3sys009aog133.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754556AbbCBVzo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 16:55:44 -0500
Received: by mail-pa0-f46.google.com with SMTP id bj1so47118816pad.5
        for <netdev@vger.kernel.org>; Mon, 02 Mar 2015 13:55:44 -0800 (PST)
In-Reply-To: <1425333305-19702-1-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Zhou <azhou@nicira.com>

Current ip_fragment() API assumes there is a netdev device attached to
the skb. The MTU size is then derived from the attached device. However,
skbs incoming from OVS vports do not have a netdevice attached, so it is
not possible to query it for the MTU size.

This patch splits the original function into two pieces: The core
fragmentation logic is now provided by ip_fragment_mtu(), The call back
function with this API accepts two arguments: skb and an application
specific pointer. ip_fragment() retains the original API, and it in turn
calls ip_fragment_mtu() to do the work.

Future patches will make use of the new ip_fragment_mtu() from OVS
modules.

Signed-off-by: Andy Zhou <azhou@nicira.com>
---
 include/net/ip.h     |    3 ++
 net/ipv4/ip_output.c |  113 ++++++++++++++++++++++++++++----------------------
 2 files changed, 66 insertions(+), 50 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index 025c61c..e73ac20 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -109,6 +109,9 @@ int ip_mr_input(struct sk_buff *skb);
 int ip_output(struct sock *sk, struct sk_buff *skb);
 int ip_mc_output(struct sock *sk, struct sk_buff *skb);
 int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *));
+int ip_fragment_mtu(struct sk_buff *skb, unsigned int mtu, unsigned int ll_rs,
+		    struct net_device *dev, void *output_arg,
+		    int (*output)(struct sk_buff *, void *output_arg));
 int ip_do_nat(struct sk_buff *skb);
 void ip_send_check(struct iphdr *ip);
 int __ip_local_out(struct sk_buff *skb);
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index d68199d..57ed8ef 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -472,54 +472,22 @@ static void ip_copy_metadata(struct sk_buff *to, struct sk_buff *from)
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
 	struct iphdr *iph;
 	int ptr;
-	struct net_device *dev;
 	struct sk_buff *skb2;
-	unsigned int mtu, hlen, left, len, ll_rs;
+	unsigned int hlen, left, len;
 	int offset;
 	__be16 not_last_frag;
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
@@ -592,10 +560,11 @@ int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
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
 
@@ -605,7 +574,8 @@ int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 		}
 
 		if (err == 0) {
-			IP_INC_STATS(dev_net(dev), IPSTATS_MIB_FRAGOKS);
+			if (dev)
+				IP_INC_STATS(dev_net(dev), IPSTATS_MIB_FRAGOKS);
 			return 0;
 		}
 
@@ -614,7 +584,8 @@ int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 			kfree_skb(frag);
 			frag = skb;
 		}
-		IP_INC_STATS(dev_net(dev), IPSTATS_MIB_FRAGFAILS);
+		if (dev)
+			IP_INC_STATS(dev_net(dev), IPSTATS_MIB_FRAGFAILS);
 		return err;
 
 slow_path_clean:
@@ -636,10 +607,6 @@ slow_path:
 	left = skb->len - hlen;		/* Space per frame */
 	ptr = hlen;		/* Where to start from */
 
-	/* for bridged IP traffic encapsulated inside f.e. a vlan header,
-	 * we need to make room for the encapsulating header
-	 */
-	ll_rs = LL_RESERVED_SPACE_EXTRA(rt->dst.dev, nf_bridge_pad(skb));
 
 	/*
 	 *	Fragment the datagram.
@@ -732,21 +699,67 @@ slow_path:
 
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
+/*This IP datagram is too large to be sent in one piece.  Break it up into
+ *smaller pieces (each of size equal to IP header plus
+ *a block of the data of the original IP data part) that will yet fit in a
+ *single device frame, and queue such a frame for sending.
+ */
+int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
+{
+	struct iphdr *iph;
+	struct net_device *dev;
+	unsigned int mtu, ll_rs;
+	struct rtable *rt = skb_rtable(skb);
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
+	return ip_fragment_mtu(skb, mtu, ll_rs, NULL, dev,
+			(int (*)(struct sk_buff *, void *output_arg))output);
+}
 EXPORT_SYMBOL(ip_fragment);
 
 int
-- 
1.7.10.4
