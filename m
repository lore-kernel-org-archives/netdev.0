From: Alexander Aring <aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: [PATCHv2 bluetooth-next 05/10] ndisc: add addr_len parameter to ndisc_opt_addr_data
Date: Wed, 20 Apr 2016 10:19:37 +0200
Message-ID: <1461140382-4784-6-git-send-email-aar@pengutronix.de>
References: <1461140382-4784-1-git-send-email-aar@pengutronix.de>
Cc: kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org, marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org,
	jukka.rissanen-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org,
	stefan-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org, mcr-SWp7JaYWvAQV+D8aMU/kSg@public.gmane.org, werner-SEdMjqphH88wryQfseakQg@public.gmane.org,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Alexander Aring <aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	"David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>,
	James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>,
	Hideaki YOSHIFUJI <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
To: linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1461140382-4784-1-git-send-email-aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch makes the address length as argument for the
ndisc_opt_addr_data function. This is necessary to handle addresses
which don't use dev->addr_len as address length.

Cc: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>
Cc: James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>
Cc: Hideaki YOSHIFUJI <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>
Cc: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Signed-off-by: Alexander Aring <aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
---
 include/net/ndisc.h |  5 +++--
 net/ipv6/ndisc.c    | 11 +++++++----
 net/ipv6/route.c    |  2 +-
 3 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/include/net/ndisc.h b/include/net/ndisc.h
index ef43e88..aac868e 100644
--- a/include/net/ndisc.h
+++ b/include/net/ndisc.h
@@ -134,12 +134,13 @@ static inline int ndisc_opt_addr_space(struct net_device *dev,
 }
 
 static inline u8 *ndisc_opt_addr_data(struct nd_opt_hdr *p,
-				      struct net_device *dev)
+				      struct net_device *dev,
+				      unsigned char addr_len)
 {
 	u8 *lladdr = (u8 *)(p + 1);
 	int lladdrlen = p->nd_opt_len << 3;
 	int prepad = ndisc_addr_option_pad(dev->type);
-	if (lladdrlen != ndisc_opt_addr_space(dev, dev->addr_len))
+	if (lladdrlen != ndisc_opt_addr_space(dev, addr_len))
 		return NULL;
 	return lladdr + prepad;
 }
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 69e20e3..4e91d5e 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -744,7 +744,8 @@ static void ndisc_recv_ns(struct sk_buff *skb)
 	}
 
 	if (ndopts.nd_opts_src_lladdr) {
-		lladdr = ndisc_opt_addr_data(ndopts.nd_opts_src_lladdr, dev);
+		lladdr = ndisc_opt_addr_data(ndopts.nd_opts_src_lladdr, dev,
+					     dev->addr_len);
 		if (!lladdr) {
 			ND_PRINTK(2, warn,
 				  "NS: invalid link-layer address length\n");
@@ -916,7 +917,8 @@ static void ndisc_recv_na(struct sk_buff *skb)
 		return;
 	}
 	if (ndopts.nd_opts_tgt_lladdr) {
-		lladdr = ndisc_opt_addr_data(ndopts.nd_opts_tgt_lladdr, dev);
+		lladdr = ndisc_opt_addr_data(ndopts.nd_opts_tgt_lladdr, dev,
+					     dev->addr_len);
 		if (!lladdr) {
 			ND_PRINTK(2, warn,
 				  "NA: invalid link-layer address length\n");
@@ -1024,7 +1026,7 @@ static void ndisc_recv_rs(struct sk_buff *skb)
 
 	if (ndopts.nd_opts_src_lladdr) {
 		lladdr = ndisc_opt_addr_data(ndopts.nd_opts_src_lladdr,
-					     skb->dev);
+					     skb->dev, skb->dev->addr_len);
 		if (!lladdr)
 			goto out;
 	}
@@ -1322,7 +1324,8 @@ skip_linkparms:
 		u8 *lladdr = NULL;
 		if (ndopts.nd_opts_src_lladdr) {
 			lladdr = ndisc_opt_addr_data(ndopts.nd_opts_src_lladdr,
-						     skb->dev);
+						     skb->dev,
+						     skb->dev->addr_len);
 			if (!lladdr) {
 				ND_PRINTK(2, warn,
 					  "RA: invalid link-layer address length\n");
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index ed44663..cc180b3 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2157,7 +2157,7 @@ static void rt6_do_redirect(struct dst_entry *dst, struct sock *sk, struct sk_bu
 	lladdr = NULL;
 	if (ndopts.nd_opts_tgt_lladdr) {
 		lladdr = ndisc_opt_addr_data(ndopts.nd_opts_tgt_lladdr,
-					     skb->dev);
+					     skb->dev, skb->dev->addr_len);
 		if (!lladdr) {
 			net_dbg_ratelimited("rt6_redirect: invalid link-layer address length\n");
 			return;
-- 
2.8.0
