From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 09/12] ipv6: use ktime_t for internal timestamps
Date: Wed, 30 Sep 2015 13:26:39 +0200
Message-ID: <1443612402-3000775-10-git-send-email-arnd@arndb.de>
References: <1443612402-3000775-1-git-send-email-arnd@arndb.de>
Cc: y2038@lists.linaro.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Arnd Bergmann <arnd@arndb.de>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.131]:64749 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933224AbbI3L1X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 07:27:23 -0400
In-Reply-To: <1443612402-3000775-1-git-send-email-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ipv6 mip6 implementation is one of only a few users of the
skb_get_timestamp() function in the kernel, which is both unsafe
on 32-bit architectures because of the 2038 overflow, and slightly
less efficient than the skb_get_ktime() based approach.

This converts the function call and the mip6_report_rate_limiter
structure that stores the time stamp, eliminating all uses of
timeval in the ipv6 code.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: James Morris <jmorris@namei.org>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Patrick McHardy <kaber@trash.net>
---
 net/ipv6/mip6.c | 16 +++++++---------
 1 file changed, 7 insertions(+), 9 deletions(-)

diff --git a/net/ipv6/mip6.c b/net/ipv6/mip6.c
index b9779d441b12..60c79a08e14a 100644
--- a/net/ipv6/mip6.c
+++ b/net/ipv6/mip6.c
@@ -118,7 +118,7 @@ static int mip6_mh_filter(struct sock *sk, struct sk_buff *skb)
 
 struct mip6_report_rate_limiter {
 	spinlock_t lock;
-	struct timeval stamp;
+	ktime_t stamp;
 	int iif;
 	struct in6_addr src;
 	struct in6_addr dst;
@@ -184,20 +184,18 @@ static int mip6_destopt_output(struct xfrm_state *x, struct sk_buff *skb)
 	return 0;
 }
 
-static inline int mip6_report_rl_allow(struct timeval *stamp,
+static inline int mip6_report_rl_allow(ktime_t stamp,
 				       const struct in6_addr *dst,
 				       const struct in6_addr *src, int iif)
 {
 	int allow = 0;
 
 	spin_lock_bh(&mip6_report_rl.lock);
-	if (mip6_report_rl.stamp.tv_sec != stamp->tv_sec ||
-	    mip6_report_rl.stamp.tv_usec != stamp->tv_usec ||
+	if (!ktime_equal(mip6_report_rl.stamp, stamp) ||
 	    mip6_report_rl.iif != iif ||
 	    !ipv6_addr_equal(&mip6_report_rl.src, src) ||
 	    !ipv6_addr_equal(&mip6_report_rl.dst, dst)) {
-		mip6_report_rl.stamp.tv_sec = stamp->tv_sec;
-		mip6_report_rl.stamp.tv_usec = stamp->tv_usec;
+		mip6_report_rl.stamp = stamp;
 		mip6_report_rl.iif = iif;
 		mip6_report_rl.src = *src;
 		mip6_report_rl.dst = *dst;
@@ -216,7 +214,7 @@ static int mip6_destopt_reject(struct xfrm_state *x, struct sk_buff *skb,
 	struct ipv6_destopt_hao *hao = NULL;
 	struct xfrm_selector sel;
 	int offset;
-	struct timeval stamp;
+	ktime_t stamp;
 	int err = 0;
 
 	if (unlikely(fl6->flowi6_proto == IPPROTO_MH &&
@@ -230,9 +228,9 @@ static int mip6_destopt_reject(struct xfrm_state *x, struct sk_buff *skb,
 					(skb_network_header(skb) + offset);
 	}
 
-	skb_get_timestamp(skb, &stamp);
+	stamp = skb_get_ktime(skb);
 
-	if (!mip6_report_rl_allow(&stamp, &ipv6_hdr(skb)->daddr,
+	if (!mip6_report_rl_allow(stamp, &ipv6_hdr(skb)->daddr,
 				  hao ? &hao->addr : &ipv6_hdr(skb)->saddr,
 				  opt->iif))
 		goto out;
-- 
2.1.0.rc2
