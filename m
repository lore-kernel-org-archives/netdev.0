From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [PATCH 13/20] [PATCH] [IPV6] MIP6: Add destination options header transformation.
Date: Sat, 29 Jul 2006 18:38:51 +0900
Message-ID: <11541659312212-git-send-email-nakam@linux-ipv6.org>
Reply-To: Masahide NAKAMURA <nakam@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:47747 "EHLO jupiter")
	by vger.kernel.org with ESMTP id S1422718AbWG2Jiw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2006 05:38:52 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add destination options header transformation for Mobile IPv6.
Based on MIPL2 kernel patch.
---
 include/net/mip6.h |    3 +
 net/ipv6/mip6.c    |  167 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 170 insertions(+), 0 deletions(-)

diff --git a/include/net/mip6.h b/include/net/mip6.h
index 644b8b6..42b65ba 100644
--- a/include/net/mip6.h
+++ b/include/net/mip6.h
@@ -25,6 +25,9 @@
 #ifndef _NET_MIP6_H
 #define _NET_MIP6_H
 
+#define MIP6_OPT_PAD_1	0
+#define MIP6_OPT_PAD_N	1
+
 extern int mip6_init(void);
 extern void mip6_fini(void);
 
diff --git a/net/ipv6/mip6.c b/net/ipv6/mip6.c
index 0fa495a..5721cf8 100644
--- a/net/ipv6/mip6.c
+++ b/net/ipv6/mip6.c
@@ -36,6 +36,165 @@ static xfrm_address_t *mip6_xfrm_addr(st
 	return x->coaddr;
 }
 
+static inline unsigned int calc_padlen(unsigned int len, unsigned int n)
+{
+	return (n - len + 16) & 0x7;
+}
+
+static inline void *mip6_padn(__u8 *data, __u8 padlen)
+{
+	if (!data)
+		return NULL;
+	if (padlen == 1) {
+		data[0] = MIP6_OPT_PAD_1;
+	} else if (padlen > 1) {
+		data[0] = MIP6_OPT_PAD_N;
+		data[1] = padlen - 2;
+		if (padlen > 2)
+			memset(data+2, 0, data[1]);
+	}
+	return data + padlen;
+}
+
+/*****************************
+ * Destination Options Header
+ *****************************/
+
+static int mip6_destopt_input(struct xfrm_state *x, struct sk_buff *skb)
+{
+	struct ipv6hdr *iph = skb->nh.ipv6h;
+	struct ipv6_destopt_hdr *destopt = (struct ipv6_destopt_hdr *)skb->data;
+
+	if (!ipv6_addr_equal(&iph->saddr, (struct in6_addr *)x->coaddr) &&
+	    !ipv6_addr_any((struct in6_addr *)x->coaddr))
+		return -ENOENT;
+
+	return destopt->nexthdr;
+}
+
+/* Destination Option Header is inserted.
+ * IP Header's src address is replaced with Home Address Option in
+ * Destination Option Header.
+ */
+static int mip6_destopt_output(struct xfrm_state *x, struct sk_buff *skb)
+{
+	struct ipv6hdr *iph;
+	struct ipv6_destopt_hdr *dstopt;
+	struct destopt_hao *hao;
+	u8 nexthdr;
+	int len;
+
+	iph = (struct ipv6hdr *)skb->data;
+	iph->payload_len = htons(skb->len - sizeof(*iph));
+
+	nexthdr = *skb->nh.raw;
+	*skb->nh.raw = IPPROTO_DSTOPTS;
+
+	dstopt = (struct ipv6_destopt_hdr *)skb->h.raw;
+	dstopt->nexthdr = nexthdr;
+
+	hao = mip6_padn((char *)(dstopt + 1),
+			calc_padlen(sizeof(*dstopt), 6));
+
+	hao->type = IPV6_TLV_HAO;
+	hao->length = sizeof(*hao) - 2;
+	BUG_TRAP(hao->length == 16);
+
+	len = ((char *)hao - (char *)dstopt) + sizeof(*hao);
+
+	memcpy(&hao->addr, &iph->saddr, sizeof(hao->addr));
+	memcpy(&iph->saddr, x->coaddr, sizeof(iph->saddr));
+
+	BUG_TRAP(len == x->props.header_len);
+	dstopt->hdrlen = (x->props.header_len >> 3) - 1;
+
+	return 0;
+}
+
+static int mip6_destopt_place_find(struct xfrm_state *x, struct sk_buff *skb,
+				   u8 **nexthdr)
+{
+	u16 offset = sizeof(struct ipv6hdr);
+	struct ipv6_opt_hdr *exthdr = (struct ipv6_opt_hdr*)(skb->nh.ipv6h + 1);
+	unsigned int packet_len = skb->tail - skb->nh.raw;
+	int found_rhdr = 0;
+
+	*nexthdr = &skb->nh.ipv6h->nexthdr;
+
+	while (offset + 1 <= packet_len) {
+
+		switch (**nexthdr) {
+		case NEXTHDR_HOP:
+			break;
+		case NEXTHDR_ROUTING:
+			found_rhdr = 1;
+			break;
+		case NEXTHDR_DEST:
+			/*
+			 * HAO MUST NOT appear more than once.
+			 * XXX: It is better to try to find by the end of
+			 * XXX: packet if HAO exists.
+			 */
+			if (ipv6_find_tlv(skb, offset, IPV6_TLV_HAO) >= 0) {
+				LIMIT_NETDEBUG(KERN_WARNING "mip6: hao exists already, override\n");
+				return offset;
+			}
+
+			if (found_rhdr)
+				return offset;
+
+			break;
+		default:
+			return offset;
+		}
+
+		offset += ipv6_optlen(exthdr);
+		*nexthdr = &exthdr->nexthdr;
+		exthdr = (struct ipv6_opt_hdr*)(skb->nh.raw + offset);
+	}
+
+	return offset;
+}
+
+static int mip6_destopt_init_state(struct xfrm_state *x)
+{
+	if (x->id.spi) {
+		printk(KERN_INFO "%s: spi is not 0: %u\n", __FUNCTION__,
+		       x->id.spi);
+		return -EINVAL;
+	}
+	if (x->props.mode != XFRM_MODE_ROUTEOPTIMIZATION) {
+		printk(KERN_INFO "%s: state's mode is not %u: %u\n",
+		       __FUNCTION__, XFRM_MODE_ROUTEOPTIMIZATION, x->props.mode);
+		return -EINVAL;
+	}
+
+	x->props.header_len = sizeof(struct ipv6_destopt_hdr) +
+		calc_padlen(sizeof(struct ipv6_destopt_hdr), 6) +
+		sizeof(struct destopt_hao);
+	BUG_TRAP(x->props.header_len == 24);
+
+	return 0;
+}
+
+static void mip6_destopt_destroy(struct xfrm_state *x)
+{
+}
+
+static struct xfrm_type mip6_destopt_type =
+{
+	.description	= "MIP6DESTOPT",
+	.owner		= THIS_MODULE,
+	.proto	     	= IPPROTO_DSTOPTS,
+	.flags		= XFRM_TYPE_NON_FRAGMENT,
+	.init_state	= mip6_destopt_init_state,
+	.destructor	= mip6_destopt_destroy,
+	.input		= mip6_destopt_input,
+	.output		= mip6_destopt_output,
+	.place_find	= mip6_destopt_place_find,
+	.local_addr	= mip6_xfrm_addr,
+};
+
 /*****************************
  * Routing Header type 2
  *****************************/
@@ -169,6 +328,10 @@ int __init mip6_init(void)
 {
 	printk(KERN_INFO "Mobile IPv6\n");
 
+	if (xfrm_register_type(&mip6_destopt_type, AF_INET6) < 0) {
+		printk(KERN_INFO "%s: can't add xfrm type(destopt)\n", __FUNCTION__);
+		goto mip6_destopt_xfrm_fail;
+	}
 	if (xfrm_register_type(&mip6_rthdr_type, AF_INET6) < 0) {
 		printk(KERN_INFO "%s: can't add xfrm type(rthdr)\n", __FUNCTION__);
 		goto mip6_rthdr_xfrm_fail;
@@ -176,6 +339,8 @@ int __init mip6_init(void)
 	return 0;
 
  mip6_rthdr_xfrm_fail:
+	xfrm_unregister_type(&mip6_destopt_type, AF_INET6);
+ mip6_destopt_xfrm_fail:
 	return -EAGAIN;
 }
 
@@ -183,4 +348,6 @@ void __exit mip6_fini(void)
 {
 	if (xfrm_unregister_type(&mip6_rthdr_type, AF_INET6) < 0)
 		printk(KERN_INFO "%s: can't remove xfrm type(rthdr)\n", __FUNCTION__);
+	if (xfrm_unregister_type(&mip6_destopt_type, AF_INET6) < 0)
+		printk(KERN_INFO "%s: can't remove xfrm type(destopt)\n", __FUNCTION__);
 }
-- 
1.4.1

