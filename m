From: Bart De Schuymer <bdschuym-LPO8gxj9N8aZIoH1IeqzKA@public.gmane.org>
Subject: [PATCH] 2.6.3 fix vlan-encapsulated fragmented IP traffic
Date: Sun, 29 Feb 2004 19:14:53 +0100
Sender: ebtables-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Message-ID: <200402291914.53578.bdschuym@pandora.be>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ebtables-devel <ebtables-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	netdev <netdev-VZNHf3L845pBDgjK7y7TUQ@public.gmane.org>
Return-path: <ebtables-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: David S.Miller <davem-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Content-Disposition: inline
Errors-To: ebtables-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/ebtables-devel>,
	<mailto:ebtables-devel-request-5NWGOfrQmneRv+LV9MX5utDmRdBvX5/5ji9XKYC2TYK4Io4DoRGLOrNAH6kLmebB@public.gmane.org>
List-Post: <mailto:ebtables-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:ebtables-devel-request-5NWGOfrQmneRv+LV9MX5utDmRdBvX5/5lLLH9aP38KF1pqr+6INuaA@public.gmane.org>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/ebtables-devel>,
	<mailto:ebtables-devel-request-5NWGOfrQmneRv+LV9MX5utDmRdBvX5/5R9m/fhtKvoLKtGCp0j7rLg@public.gmane.org>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=ebtables-devel>
List-Id: netdev.vger.kernel.org

Hi Dave,

When vlan-tagged fragmented IP traffic passes the bridging firewall and
ip_conntrack is loaded and iptables sees this IP traffic, an oops can
occur when trying to fragment the defragmented packets. This only
happens in the slow_path of ip_fragment().
The problem was reported, diagnosed and fixed by Adam Osuchowski and
Tomasz Dubinski.
When ip_fragment() is fragmenting an IP packet that's encapsulated, it has
to make sure there is enough head room for the encapsulating header.

The patch below fixes it. I saw no other way than to add some code to
ip_fragment(), but this extra code is located in the slow_path so it's
hardly ever executed.

cheers,
Bart

--- linux-2.6.3/include/linux/netfilter_bridge.h.save	Sun Feb 29 17:13:44 2004
+++ linux-2.6.3/include/linux/netfilter_bridge.h	Sun Feb 29 17:43:55 2004
@@ -88,6 +88,20 @@ void nf_bridge_save_header(struct sk_buf
 	memcpy(skb->nf_bridge->data, skb->data - header_size, header_size);
 }
 
+/* This is called by the IP fragmenting code and it ensures there is
+ * enough room for the encapsulating header (if there is one). */
+static inline
+int nf_bridge_pad(struct sk_buff *skb)
+{
+	if (skb->protocol == __constant_htons(ETH_P_IP))
+		return 0;
+	if (skb->nf_bridge) {
+		if (skb->protocol == __constant_htons(ETH_P_8021Q))
+			return 4;
+	}
+	return 0;
+}
+
 struct bridge_skb_cb {
 	union {
 		__u32 ipv4;
--- linux-2.6.3/net/ipv4/ip_output.c.save	Sun Feb 29 16:30:05 2004
+++ linux-2.6.3/net/ipv4/ip_output.c	Sun Feb 29 19:11:35 2004
@@ -80,6 +80,7 @@
 #include <net/inetpeer.h>
 #include <linux/igmp.h>
 #include <linux/netfilter_ipv4.h>
+#include <linux/netfilter_bridge.h>
 #include <linux/mroute.h>
 #include <linux/netlink.h>
 
@@ -442,7 +443,7 @@ int ip_fragment(struct sk_buff *skb, int
 	int ptr;
 	struct net_device *dev;
 	struct sk_buff *skb2;
-	unsigned int mtu, hlen, left, len; 
+	unsigned int mtu, hlen, left, len, ll_rs;
 	int offset;
 	int not_last_frag;
 	struct rtable *rt = (struct rtable*)skb->dst;
@@ -563,6 +564,14 @@ slow_path:
 	left = skb->len - hlen;		/* Space per frame */
 	ptr = raw + hlen;		/* Where to start from */
 
+#ifdef CONFIG_BRIDGE_NETFILTER
+	/* for bridged IP traffic encapsulated inside f.e. a vlan header,
+	 * we need to make room for the encapsulating header */
+	ll_rs = LL_RESERVED_SPACE(rt->u.dst.dev + nf_bridge_pad(skb));
+	mtu -= nf_bridge_pad(skb);
+#else
+	ll_rs = LL_RESERVED_SPACE(rt->u.dst.dev);
+#endif
 	/*
 	 *	Fragment the datagram.
 	 */
@@ -588,7 +597,7 @@ slow_path:
 		 *	Allocate buffer.
 		 */
 
-		if ((skb2 = alloc_skb(len+hlen+LL_RESERVED_SPACE(rt->u.dst.dev), GFP_ATOMIC)) == NULL) {
+		if ((skb2 = alloc_skb(len+hlen+ll_rs, GFP_ATOMIC)) == NULL) {
 			NETDEBUG(printk(KERN_INFO "IP: frag: no memory for new fragment!\n"));
 			err = -ENOMEM;
 			goto fail;
@@ -599,7 +608,7 @@ slow_path:
 		 */
 
 		ip_copy_metadata(skb2, skb);
-		skb_reserve(skb2, LL_RESERVED_SPACE(rt->u.dst.dev));
+		skb_reserve(skb2, ll_rs);
 		skb_put(skb2, len + hlen);
 		skb2->nh.raw = skb2->data;
 		skb2->h.raw = skb2->data + hlen;




-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
