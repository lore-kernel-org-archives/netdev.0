From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH 37/44] [IPV6] MIP6: Report to user-space when home address option is rejected.
Date: Thu, 24 Aug 2006 00:02:38 +0900
Message-ID: <11563453674194-git-send-email-yoshfuji@linux-ipv6.org>
References: <11563453651167-git-send-email-yoshfuji@linux-ipv6.org> <11563453651533-git-send-email-yoshfuji@linux-ipv6.org> <11563453653169-git-send-email-yoshfuji@linux-ipv6.org> <1156345365325-git-send-email-yoshfuji@linux-ipv6.org> <11563453653851-git-send-email-yoshfuji@linux-ipv6.org> <11563453653575-git-send-email-yoshfuji@linux-ipv6.org> <1156345365651-git-send-email-yoshfuji@linux-ipv6.org> <1156345365264-git-send-email-yoshfuji@linux-ipv6.org> <1156345365312-git-send-email-yoshfuji@linux-ipv6.org> <11563453652646-git-send-email-yoshfuji@linux-ipv6.org> <1156345365315-git-send-email-yoshfuji@linux-ipv6.org> <11563453651452-git-send-email-yoshfuji@linux-ipv6.org> <1156345366288-git-send-email-yoshfuji@linux-ipv6.org> <1156345366857-git-send-email-yoshfuji@linux-ipv6.org> <11563453663761-git-send-email-yoshfuji@linux-ipv6.org> <11563453662321-git-send-email-yoshfuji@linux-ipv6.org>
  <11563453661892-git-send-email-yoshfuji@linux-ipv6.org> <11563453661207-git-send-email-yoshfuji@linux-ipv6.org> <11563453663743-git-send-email-yoshfuji@linux-ipv6.org> <1156345366676-git-send-email-yoshfuji@linux-ipv6.org> <11563453662840-git-send-email-yoshfuji@linux-ipv6.org> <11563453662913-git-send-email-yoshfuji@linux-ipv6.org> <11563453663400-git-send-email-yoshfuji@linux-ipv6.org> <1156345366549-git-send-email-yoshfuji@linux-ipv6.org> <11563453662956-git-send-email-yoshfuji@linux-ipv6.org> <11563453661764-git-send-email-yoshfuji@linux-ipv6.org> <11563453663275-git-send-email-yoshfuji@linux-ipv6.org> <11563453671174-git-send-email-yoshfuji@linux-ipv6.org> <11563453674049-git-send-email-yoshfuji@linux-ipv6.org> <11563453673517-git-send-email-yoshfuji@linux-ipv6.org> <11563453674137-git-send-email-yoshfuji@linux-ipv6.org> <11563453671944-git-send-email-yoshfuji@linux-ipv6.org> <11
 563453671187-git-send-email-yoshfuji@linux-ipv6.org> <11563453672959-git-send-email-yoshfuji@linux-ipv6.org> <1156345367208-git-send-email-yoshfuji@linux-ipv6.org> <11563453673786-git-send-email-yoshfuji@linux-ipv6.org> <11563453672531-git-send-email-yoshfuji@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:10633 "EHLO
	jupiter.linux-ipv6.org") by vger.kernel.org with ESMTP
	id S964952AbWHWPCw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 11:02:52 -0400
To: davem@davemloft.net
In-Reply-To: <11563453672531-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>

Report to user-space when home address option is rejected.
In receiving this message user-space application will send Mobile IPv6 binding
error. It is rate-limited by kernel.
Based on MIPL2 kernel patch.

This patch was also written by: Ville Nuorvala <vnuorval@tcs.hut.fi>

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/mip6.c |   83 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 83 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/mip6.c b/net/ipv6/mip6.c
index 7b5f893..31445d0 100644
--- a/net/ipv6/mip6.c
+++ b/net/ipv6/mip6.c
@@ -25,6 +25,7 @@
 #include <linux/config.h>
 #include <linux/module.h>
 #include <linux/skbuff.h>
+#include <linux/time.h>
 #include <linux/ipv6.h>
 #include <linux/icmpv6.h>
 #include <net/sock.h>
@@ -138,6 +139,18 @@ int mip6_mh_filter(struct sock *sk, stru
 	return 0;
 }
 
+struct mip6_report_rate_limiter {
+	spinlock_t lock;
+	struct timeval stamp;
+	int iif;
+	struct in6_addr src;
+	struct in6_addr dst;
+};
+
+static struct mip6_report_rate_limiter mip6_report_rl = {
+	.lock = SPIN_LOCK_UNLOCKED
+};
+
 static int mip6_destopt_input(struct xfrm_state *x, struct sk_buff *skb)
 {
 	struct ipv6hdr *iph = skb->nh.ipv6h;
@@ -189,6 +202,75 @@ static int mip6_destopt_output(struct xf
 	return 0;
 }
 
+static inline int mip6_report_rl_allow(struct timeval *stamp,
+				       struct in6_addr *dst,
+				       struct in6_addr *src, int iif)
+{
+	int allow = 0;
+
+	spin_lock_bh(&mip6_report_rl.lock);
+	if (mip6_report_rl.stamp.tv_sec != stamp->tv_sec ||
+	    mip6_report_rl.stamp.tv_usec != stamp->tv_usec ||
+	    mip6_report_rl.iif != iif ||
+	    !ipv6_addr_equal(&mip6_report_rl.src, src) ||
+	    !ipv6_addr_equal(&mip6_report_rl.dst, dst)) {
+		mip6_report_rl.stamp.tv_sec = stamp->tv_sec;
+		mip6_report_rl.stamp.tv_usec = stamp->tv_usec;
+		mip6_report_rl.iif = iif;
+		ipv6_addr_copy(&mip6_report_rl.src, src);
+		ipv6_addr_copy(&mip6_report_rl.dst, dst);
+		allow = 1;
+	}
+	spin_unlock_bh(&mip6_report_rl.lock);
+	return allow;
+}
+
+static int mip6_destopt_reject(struct xfrm_state *x, struct sk_buff *skb, struct flowi *fl)
+{
+	struct inet6_skb_parm *opt = (struct inet6_skb_parm *)skb->cb;
+	struct ipv6_destopt_hao *hao = NULL;
+	struct xfrm_selector sel;
+	int offset;
+	struct timeval stamp;
+	int err = 0;
+
+	if (likely(opt->dsthao)) {
+		offset = ipv6_find_tlv(skb, opt->dsthao, IPV6_TLV_HAO);
+		if (likely(offset >= 0))
+			hao = (struct ipv6_destopt_hao *)(skb->nh.raw + offset);
+	}
+
+	skb_get_timestamp(skb, &stamp);
+
+	if (!mip6_report_rl_allow(&stamp, &skb->nh.ipv6h->daddr,
+				  hao ? &hao->addr : &skb->nh.ipv6h->saddr,
+				  opt->iif))
+		goto out;
+
+	memset(&sel, 0, sizeof(sel));
+	memcpy(&sel.daddr, (xfrm_address_t *)&skb->nh.ipv6h->daddr,
+	       sizeof(sel.daddr));
+	sel.prefixlen_d = 128;
+	memcpy(&sel.saddr, (xfrm_address_t *)&skb->nh.ipv6h->saddr,
+	       sizeof(sel.saddr));
+	sel.prefixlen_s = 128;
+	sel.family = AF_INET6;
+	sel.proto = fl->proto;
+	sel.dport = xfrm_flowi_dport(fl);
+	if (sel.dport)
+		sel.dport_mask = ~((__u16)0);
+	sel.sport = xfrm_flowi_sport(fl);
+	if (sel.sport)
+		sel.sport_mask = ~((__u16)0);
+	sel.ifindex = fl->oif;
+
+	err = km_report(IPPROTO_DSTOPTS, &sel,
+			(hao ? (xfrm_address_t *)&hao->addr : NULL));
+
+ out:
+	return err;
+}
+
 static int mip6_destopt_offset(struct xfrm_state *x, struct sk_buff *skb,
 			       u8 **nexthdr)
 {
@@ -273,6 +355,7 @@ static struct xfrm_type mip6_destopt_typ
 	.destructor	= mip6_destopt_destroy,
 	.input		= mip6_destopt_input,
 	.output		= mip6_destopt_output,
+ 	.reject		= mip6_destopt_reject,
 	.hdr_offset	= mip6_destopt_offset,
 	.local_addr	= mip6_xfrm_addr,
 };
-- 
1.4.0

