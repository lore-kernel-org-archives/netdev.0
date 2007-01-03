From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [IPV6] RAW: Add checksum default defines for MH.
Date: Wed,  3 Jan 2007 18:57:48 +0900
Message-ID: <11678182681435-git-send-email-nakam@linux-ipv6.org>
Cc: netdev@vger.kernel.org, Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi020.linux-ipv6.org ([203.178.140.20]:55820 "EHLO
	neptune.linux-ipv6.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1750695AbXACKEj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jan 2007 05:04:39 -0500
To: davem@davemloft.net, yoshfuji@linux-ipv6.org,
	takamiya@po.ntts.co.jp
In-Reply-To: 4591FD33.3070205@linux-ipv6.org
References: 4591FD33.3070205@linux-ipv6.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add checksum default defines for mobility header(MH) which
goes through raw socket. As the result kernel's behavior is
to handle MH checksum as default.

This patch also removes verifying inbound MH checksum at
mip6_mh_filter() since it did not consider user specified
checksum offset and was redundant check with raw socket code.

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
---
 net/ipv6/mip6.c |   26 --------------------------
 net/ipv6/raw.c  |   13 +++++++++++--
 2 files changed, 11 insertions(+), 28 deletions(-)

diff --git a/net/ipv6/mip6.c b/net/ipv6/mip6.c
index be7dd7d..681bb07 100644
--- a/net/ipv6/mip6.c
+++ b/net/ipv6/mip6.c
@@ -89,7 +89,6 @@ static int mip6_mh_len(int type)
 int mip6_mh_filter(struct sock *sk, struct sk_buff *skb)
 {
 	struct ip6_mh *mh;
-	int mhlen;
 
 	if (!pskb_may_pull(skb, (skb->h.raw - skb->data) + 8) ||
 	    !pskb_may_pull(skb, (skb->h.raw - skb->data) + ((skb->h.raw[1] + 1) << 3)))
@@ -103,31 +102,6 @@ int mip6_mh_filter(struct sock *sk, stru
 		mip6_param_prob(skb, 0, (&mh->ip6mh_hdrlen) - skb->nh.raw);
 		return -1;
 	}
-	mhlen = (mh->ip6mh_hdrlen + 1) << 3;
-
-	if (skb->ip_summed == CHECKSUM_COMPLETE) {
-		skb->ip_summed = CHECKSUM_UNNECESSARY;
-		if (csum_ipv6_magic(&skb->nh.ipv6h->saddr,
-				    &skb->nh.ipv6h->daddr,
-				    mhlen, IPPROTO_MH,
-				    skb->csum)) {
-			LIMIT_NETDEBUG(KERN_DEBUG "mip6: MH hw checksum failed\n");
-			skb->ip_summed = CHECKSUM_NONE;
-		}
-	}
-	if (skb->ip_summed == CHECKSUM_NONE) {
-		if (csum_ipv6_magic(&skb->nh.ipv6h->saddr,
-				    &skb->nh.ipv6h->daddr,
-				    mhlen, IPPROTO_MH,
-				    skb_checksum(skb, 0, mhlen, 0))) {
-			LIMIT_NETDEBUG(KERN_DEBUG "mip6: MH checksum failed "
-				       "[" NIP6_FMT " > " NIP6_FMT "]\n",
-				       NIP6(skb->nh.ipv6h->saddr),
-				       NIP6(skb->nh.ipv6h->daddr));
-			return -1;
-		}
-		skb->ip_summed = CHECKSUM_UNNECESSARY;
-	}
 
 	if (mh->ip6mh_proto != IPPROTO_NONE) {
 		LIMIT_NETDEBUG(KERN_DEBUG "mip6: MH invalid payload proto = %d\n",
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 4ae1b19..4b83e69 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -1094,10 +1094,19 @@ static void rawv6_close(struct sock *sk,
 
 static int rawv6_init_sk(struct sock *sk)
 {
-	if (inet_sk(sk)->num == IPPROTO_ICMPV6) {
-		struct raw6_sock *rp = raw6_sk(sk);
+	struct raw6_sock *rp = raw6_sk(sk);
+
+	switch (inet_sk(sk)->num) {
+	case IPPROTO_ICMPV6:
 		rp->checksum = 1;
 		rp->offset   = 2;
+		break;
+	case IPPROTO_MH:
+		rp->checksum = 1;
+		rp->offset   = 4;
+		break;
+	default:
+		break;
 	}
 	return(0);
 }
-- 
1.4.2

