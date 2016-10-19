From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v4 net-next 1/7] ipv6: Fix Makefile conditional to use CONFIG_INET
Date: Wed, 19 Oct 2016 16:03:03 -0700
Message-ID: <20161019230309.3746853-2-tom@herbertland.com>
References: <20161019230309.3746853-1-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:58003 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754128AbcJSXD1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2016 19:03:27 -0400
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9JMwm6h011416
        for <netdev@vger.kernel.org>; Wed, 19 Oct 2016 16:03:26 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 266fgpgvgn-2
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 19 Oct 2016 16:03:26 -0700
Received: from facebook.com (2401:db00:21:6030:face:0:92:0)     by
 mx-out.facebook.com (10.222.219.45) with ESMTP id
 39fcb716965011e697f024be05904660-501eaa50 for <netdev@vger.kernel.org>;        Wed,
 19 Oct 2016 16:03:19 -0700
In-Reply-To: <20161019230309.3746853-1-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ipv6 directory was being built based on CONFIG_NET not CONFIG_INET.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 drivers/net/usb/cdc_mbim.c  |  4 ++++
 include/net/ipv6.h          | 15 +++++++++++++++
 include/net/net_namespace.h |  2 ++
 net/Makefile                |  2 +-
 4 files changed, 22 insertions(+), 1 deletion(-)

diff --git a/drivers/net/usb/cdc_mbim.c b/drivers/net/usb/cdc_mbim.c
index 96a5028..6b38e0c 100644
--- a/drivers/net/usb/cdc_mbim.c
+++ b/drivers/net/usb/cdc_mbim.c
@@ -301,6 +301,7 @@ static struct sk_buff *cdc_mbim_tx_fixup(struct usbnet *dev, struct sk_buff *skb
 	return NULL;
 }
 
+#ifdef CONFIG_INET
 /* Some devices are known to send Neigbor Solicitation messages and
  * require Neigbor Advertisement replies.  The IPv6 core will not
  * respond since IFF_NOARP is set, so we must handle them ourselves.
@@ -350,6 +351,7 @@ static void do_neigh_solicit(struct usbnet *dev, u8 *buf, u16 tci)
 out:
 	dev_put(netdev);
 }
+#endif
 
 static bool is_neigh_solicit(u8 *buf, size_t len)
 {
@@ -377,8 +379,10 @@ static struct sk_buff *cdc_mbim_process_dgram(struct usbnet *dev, u8 *buf, size_
 			proto = htons(ETH_P_IP);
 			break;
 		case 0x60:
+#ifdef CONFIG_INET
 			if (is_neigh_solicit(buf, len))
 				do_neigh_solicit(dev, buf, tci);
+#endif
 			proto = htons(ETH_P_IPV6);
 			break;
 		default:
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 8fed1cd..cbb1ce0 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -936,8 +936,15 @@ void ipv6_push_nfrag_opts(struct sk_buff *skb, struct ipv6_txoptions *opt,
 void ipv6_push_frag_opts(struct sk_buff *skb, struct ipv6_txoptions *opt,
 			 u8 *proto);
 
+#ifdef CONFIG_INET
 int ipv6_skip_exthdr(const struct sk_buff *, int start, u8 *nexthdrp,
 		     __be16 *frag_offp);
+#else
+static inline int ipv6_skip_exthdr(const struct sk_buff *skb, int start,
+				   u8 *nexthdrp, __be16 *frag_offp) {
+	return -1;
+}
+#endif
 
 bool ipv6_ext_hdr(u8 nexthdr);
 
@@ -948,8 +955,16 @@ enum {
 };
 
 /* find specified header and get offset to it */
+#ifdef CONFIG_INET
 int ipv6_find_hdr(const struct sk_buff *skb, unsigned int *offset, int target,
 		  unsigned short *fragoff, int *fragflg);
+#else
+static inline int ipv6_find_hdr(const struct sk_buff *skb, unsigned int *offset,
+				int target, unsigned short *fragoff,
+				int *fragflg) {
+	return -EPROTONOSUPPORT;
+}
+#endif
 
 int ipv6_find_tlv(const struct sk_buff *skb, int offset, int type);
 
diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index fc4f757..b4c4a5f 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -352,8 +352,10 @@ static inline void rt_genid_bump_ipv4(struct net *net)
 extern void (*__fib6_flush_trees)(struct net *net);
 static inline void rt_genid_bump_ipv6(struct net *net)
 {
+#ifdef CONFIG_INET
 	if (__fib6_flush_trees)
 		__fib6_flush_trees(net);
+#endif
 }
 
 #if IS_ENABLED(CONFIG_IEEE802154_6LOWPAN)
diff --git a/net/Makefile b/net/Makefile
index 4cafaa2..82ffb91 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -17,7 +17,7 @@ obj-$(CONFIG_NETFILTER)		+= netfilter/
 obj-$(CONFIG_INET)		+= ipv4/
 obj-$(CONFIG_XFRM)		+= xfrm/
 obj-$(CONFIG_UNIX)		+= unix/
-obj-$(CONFIG_NET)		+= ipv6/
+obj-$(CONFIG_INET)		+= ipv6/
 obj-$(CONFIG_PACKET)		+= packet/
 obj-$(CONFIG_NET_KEY)		+= key/
 obj-$(CONFIG_BRIDGE)		+= bridge/
-- 
2.9.3
