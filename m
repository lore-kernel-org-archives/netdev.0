From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH 15/44] [XFRM] IPV6: Update outbound state timestamp for each sending.
Date: Thu, 24 Aug 2006 00:02:16 +0900
Message-ID: <11563453662321-git-send-email-yoshfuji@linux-ipv6.org>
References: <11563453651167-git-send-email-yoshfuji@linux-ipv6.org> <11563453651533-git-send-email-yoshfuji@linux-ipv6.org> <11563453653169-git-send-email-yoshfuji@linux-ipv6.org> <1156345365325-git-send-email-yoshfuji@linux-ipv6.org> <11563453653851-git-send-email-yoshfuji@linux-ipv6.org> <11563453653575-git-send-email-yoshfuji@linux-ipv6.org> <1156345365651-git-send-email-yoshfuji@linux-ipv6.org> <1156345365264-git-send-email-yoshfuji@linux-ipv6.org> <1156345365312-git-send-email-yoshfuji@linux-ipv6.org> <11563453652646-git-send-email-yoshfuji@linux-ipv6.org> <1156345365315-git-send-email-yoshfuji@linux-ipv6.org> <11563453651452-git-send-email-yoshfuji@linux-ipv6.org> <1156345366288-git-send-email-yoshfuji@linux-ipv6.org> <1156345366857-git-send-email-yoshfuji@linux-ipv6.org> <11563453663761-git-send-email-yoshfuji@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:393 "EHLO
	jupiter.linux-ipv6.org") by vger.kernel.org with ESMTP
	id S964912AbWHWPCv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 11:02:51 -0400
To: davem@davemloft.net
In-Reply-To: <11563453663761-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>

With this patch transformation state is updated last used time
for each sending. Xtime is used for it like other state lifetime
expiration.
Mobile IPv6 enabled nodes will want to know traffic status of each
binding (e.g. judgement to request binding refresh by correspondent node,
or to keep home/care-of nonce alive by mobile node).
The last used timestamp is an important hint about it.
Based on MIPL2 kernel patch.

This patch was also written by: Henrik Petander <petander@tcs.hut.fi>

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/linux/xfrm.h    |    1 +
 include/net/xfrm.h      |    3 +++
 net/ipv6/xfrm6_output.c |    2 ++
 net/xfrm/xfrm_user.c    |    3 +++
 4 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
index b53f799..1d8c1f2 100644
--- a/include/linux/xfrm.h
+++ b/include/linux/xfrm.h
@@ -236,6 +236,7 @@ enum xfrm_attr_type_t {
 	XFRMA_ETIMER_THRESH,
 	XFRMA_SRCADDR,		/* xfrm_address_t */
 	XFRMA_COADDR,		/* xfrm_address_t */
+	XFRMA_LASTUSED,
 	__XFRMA_MAX
 
 #define XFRMA_MAX (__XFRMA_MAX - 1)
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index aeee0e2..86c1188 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -168,6 +168,9 @@ struct xfrm_state
 	struct xfrm_lifetime_cur curlft;
 	struct timer_list	timer;
 
+	/* Last used time */
+	u64			lastused;
+
 	/* Reference to data common to all the instances of this
 	 * transformer. */
 	struct xfrm_type	*type;
diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
index b4628fb..db58104 100644
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -75,6 +75,8 @@ static int xfrm6_output_one(struct sk_bu
 
 		x->curlft.bytes += skb->len;
 		x->curlft.packets++;
+		if (x->props.mode == XFRM_MODE_ROUTEOPTIMIZATION)
+			x->lastused = (u64)xtime.tv_sec;
 
 		spin_unlock_bh(&x->lock);
 
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 41a02d6..6511085 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -593,6 +593,9 @@ static int dump_one_state(struct xfrm_st
 	if (x->coaddr)
 		RTA_PUT(skb, XFRMA_COADDR, sizeof(*x->coaddr), x->coaddr);
 
+	if (x->lastused)
+		RTA_PUT(skb, XFRMA_LASTUSED, sizeof(x->lastused), &x->lastused);
+
 	nlh->nlmsg_len = skb->tail - b;
 out:
 	sp->this_idx++;
-- 
1.4.0

