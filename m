From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH 29/44] [IPV6] MIP6: Add destination options header transformation.
Date: Thu, 24 Aug 2006 00:02:30 +0900
Message-ID: <11563453673517-git-send-email-yoshfuji@linux-ipv6.org>
References: <11563453651167-git-send-email-yoshfuji@linux-ipv6.org> <11563453651533-git-send-email-yoshfuji@linux-ipv6.org> <11563453653169-git-send-email-yoshfuji@linux-ipv6.org> <1156345365325-git-send-email-yoshfuji@linux-ipv6.org> <11563453653851-git-send-email-yoshfuji@linux-ipv6.org> <11563453653575-git-send-email-yoshfuji@linux-ipv6.org> <1156345365651-git-send-email-yoshfuji@linux-ipv6.org> <1156345365264-git-send-email-yoshfuji@linux-ipv6.org> <1156345365312-git-send-email-yoshfuji@linux-ipv6.org> <11563453652646-git-send-email-yoshfuji@linux-ipv6.org> <1156345365315-git-send-email-yoshfuji@linux-ipv6.org> <11563453651452-git-send-email-yoshfuji@linux-ipv6.org> <1156345366288-git-send-email-yoshfuji@linux-ipv6.org> <1156345366857-git-send-email-yoshfuji@linux-ipv6.org> <11563453663761-git-send-email-yoshfuji@linux-ipv6.org> <11563453662321-git-send-email-yoshfuji@linux-ipv6.org>
  <11563453661892-git-send-email-yoshfuji@linux-ipv6.org> <11563453661207-git-send-email-yoshfuji@linux-ipv6.org> <11563453663743-git-send-email-yoshfuji@linux-ipv6.org> <1156345366676-git-send-email-yoshfuji@linux-ipv6.org> <11563453662840-git-send-email-yoshfuji@linux-ipv6.org> <11563453662913-git-send-email-yoshfuji@linux-ipv6.org> <11563453663400-git-send-email-yoshfuji@linux-ipv6.org> <1156345366549-git-send-email-yoshfuji@linux-ipv6.org> <11563453662956-git-send-email-yoshfuji@linux-ipv6.org> <11563453661764-git-send-email-yoshfuji@linux-ipv6.org> <11563453663275-git-send-email-yoshfuji@linux-ipv6.org> <11563453671174-git-send-email-yoshfuji@linux-ipv6.org> <11563453674049-git-send-email-yoshfuji@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>,
	Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:7561 "EHLO
	jupiter.linux-ipv6.org") by vger.kernel.org with ESMTP
	id S964942AbWHWPCv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 11:02:51 -0400
To: davem@davemloft.net
In-Reply-To: <11563453674049-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>

Add destination options header transformation for Mobile IPv6.
Based on MIPL2 kernel patch.

This patch was also written by: Ville Nuorvala <vnuorval@tcs.hut.fi>

Signed-off-by: Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>
Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
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
index 63e548b..a8adf89 100644
--- a/net/ipv6/mip6.c
+++ b/net/ipv6/mip6.c
@@ -35,6 +35,165 @@ static xfrm_address_t *mip6_xfrm_addr(st
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
+	struct ipv6_destopt_hao *hao;
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
+static int mip6_destopt_offset(struct xfrm_state *x, struct sk_buff *skb,
+			       u8 **nexthdr)
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
+		sizeof(struct ipv6_destopt_hao);
+	BUG_TRAP(x->props.header_len == 24);
+
+	return 0;
+}
+
+/*
+ * Do nothing about destroying since it has no specific operation for
+ * destination options header unlike IPsec protocols.
+ */
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
+	.hdr_offset	= mip6_destopt_offset,
+	.local_addr	= mip6_xfrm_addr,
+};
+
 static int mip6_rthdr_input(struct xfrm_state *x, struct sk_buff *skb)
 {
 	struct rt2_hdr *rt2 = (struct rt2_hdr *)skb->data;
@@ -164,6 +323,10 @@ int __init mip6_init(void)
 {
 	printk(KERN_INFO "Mobile IPv6\n");
 
+	if (xfrm_register_type(&mip6_destopt_type, AF_INET6) < 0) {
+		printk(KERN_INFO "%s: can't add xfrm type(destopt)\n", __FUNCTION__);
+		goto mip6_destopt_xfrm_fail;
+	}
 	if (xfrm_register_type(&mip6_rthdr_type, AF_INET6) < 0) {
 		printk(KERN_INFO "%s: can't add xfrm type(rthdr)\n", __FUNCTION__);
 		goto mip6_rthdr_xfrm_fail;
@@ -171,6 +334,8 @@ int __init mip6_init(void)
 	return 0;
 
  mip6_rthdr_xfrm_fail:
+	xfrm_unregister_type(&mip6_destopt_type, AF_INET6);
+ mip6_destopt_xfrm_fail:
 	return -EAGAIN;
 }
 
@@ -178,4 +343,6 @@ void __exit mip6_fini(void)
 {
 	if (xfrm_unregister_type(&mip6_rthdr_type, AF_INET6) < 0)
 		printk(KERN_INFO "%s: can't remove xfrm type(rthdr)\n", __FUNCTION__);
+	if (xfrm_unregister_type(&mip6_destopt_type, AF_INET6) < 0)
+		printk(KERN_INFO "%s: can't remove xfrm type(destopt)\n", __FUNCTION__);
 }
-- 
1.4.0

