From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH net-2.6] [IPV6] MIP6: Ensure independence from alignment.
Date: Wed, 09 Apr 2008 00:46:32 +0900 (JST)
Message-ID: <20080409.004632.68333196.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:60995 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752314AbYDHPow (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2008 11:44:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We cannot rely on sizeof(struct ipv6_opt_hdr) when we are handling
wire format, because it may not be 2 but 4 on some architectures.
On such a architecture, the result can be different from what we
actually expect.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

-- 
diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 4aaefc3..cf57155 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -52,6 +52,8 @@ struct ipv6_opt_hdr {
 	__u8 		hdrlen;
 	/* 
 	 * TLV encoded option data follows.
+	 *
+	 * NOTE: Be aware of arch-dependent alignment requirements!
 	 */
 };
 
@@ -59,6 +61,9 @@ struct ipv6_opt_hdr {
 #define ipv6_hopopt_hdr  ipv6_opt_hdr
 
 #ifdef __KERNEL__
+/* sizeof(struct ipv6_opt_hdr) might not be 2 */
+#define IPV6_OPT_HDRLEN	2
+
 #define ipv6_optlen(p)  (((p)->hdrlen+1) << 3)
 #endif
 
diff --git a/net/ipv6/mip6.c b/net/ipv6/mip6.c
index cd8a5bd..b3d13fb 100644
--- a/net/ipv6/mip6.c
+++ b/net/ipv6/mip6.c
@@ -34,9 +34,13 @@
 #include <net/xfrm.h>
 #include <net/mip6.h>
 
-static inline unsigned int calc_padlen(unsigned int len, unsigned int n)
+static inline unsigned int calc_padlen(unsigned int offset,
+				       unsigned int m, unsigned int n)
 {
-	return (n - len + 16) & 0x7;
+	offset %= m;
+	if (offset > n)
+		offset += m;
+	return (n - offset);
 }
 
 static inline void *mip6_padn(__u8 *data, __u8 padlen)
@@ -160,8 +164,9 @@ static int mip6_destopt_output(struct xfrm_state *x, struct sk_buff *skb)
 	dstopt = (struct ipv6_destopt_hdr *)skb_transport_header(skb);
 	dstopt->nexthdr = nexthdr;
 
-	hao = mip6_padn((char *)(dstopt + 1),
-			calc_padlen(sizeof(*dstopt), 6));
+	/* Note: sizeof(*dstopt) might not be 2. */
+	hao = mip6_padn(((u8 *)dstopt) + IPV6_OPT_HDRLEN,
+			calc_padlen(IPV6_OPT_HDRLEN, 8, 6));	/* 8n + 6 */
 
 	hao->type = IPV6_TLV_HAO;
 	hao->length = sizeof(*hao) - 2;
@@ -314,9 +319,9 @@ static int mip6_destopt_init_state(struct xfrm_state *x)
 		return -EINVAL;
 	}
 
-	x->props.header_len = sizeof(struct ipv6_destopt_hdr) +
-		calc_padlen(sizeof(struct ipv6_destopt_hdr), 6) +
-		sizeof(struct ipv6_destopt_hao);
+	x->props.header_len = IPV6_OPT_HDRLEN +
+			      calc_padlen(IPV6_OPT_HDRLEN, 8, 6) + /* 8n + 6 */
+			      sizeof(struct ipv6_destopt_hao);
 	BUG_TRAP(x->props.header_len == 24);
 
 	return 0;

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
