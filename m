From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 7/8] xfrm: export verify_userspi_info for pkfey and netlink interface
Date: Thu, 19 Dec 2013 07:36:44 +0100
Message-ID: <1387435005-8987-8-git-send-email-steffen.klassert@secunet.com>
References: <1387435005-8987-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:48193 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752812Ab3LSGhX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Dec 2013 01:37:23 -0500
In-Reply-To: <1387435005-8987-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fan Du <fan.du@windriver.com>

In order to check against valid IPcomp spi range, export verify_userspi_info
for both pfkey and netlink interface.

Signed-off-by: Fan Du <fan.du@windriver.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/xfrm.h    |    1 +
 net/key/af_key.c      |    6 ++++++
 net/xfrm/xfrm_state.c |   24 ++++++++++++++++++++++++
 net/xfrm/xfrm_user.c  |   25 +------------------------
 4 files changed, 32 insertions(+), 24 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 59f5d0a..b7635ef 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1563,6 +1563,7 @@ struct xfrm_policy *xfrm_policy_byid(struct net *net, u32 mark, u8, int dir,
 				     u32 id, int delete, int *err);
 int xfrm_policy_flush(struct net *net, u8 type, struct xfrm_audit *audit_info);
 u32 xfrm_get_acqseq(void);
+int verify_spi_info(u8 proto, u32 min, u32 max);
 int xfrm_alloc_spi(struct xfrm_state *x, u32 minspi, u32 maxspi);
 struct xfrm_state *xfrm_find_acq(struct net *net, const struct xfrm_mark *mark,
 				 u8 mode, u32 reqid, u8 proto,
diff --git a/net/key/af_key.c b/net/key/af_key.c
index 5beabd8..1a04c13 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -1340,6 +1340,12 @@ static int pfkey_getspi(struct sock *sk, struct sk_buff *skb, const struct sadb_
 		max_spi = range->sadb_spirange_max;
 	}
 
+	err = verify_spi_info(x->id.proto, min_spi, max_spi);
+	if (err) {
+		xfrm_state_put(x);
+		return err;
+	}
+
 	err = xfrm_alloc_spi(x, min_spi, max_spi);
 	resp_skb = err ? ERR_PTR(err) : pfkey_xfrm_state2msg(x);
 
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index e845066..a62c25e 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -1489,6 +1489,30 @@ u32 xfrm_get_acqseq(void)
 }
 EXPORT_SYMBOL(xfrm_get_acqseq);
 
+int verify_spi_info(u8 proto, u32 min, u32 max)
+{
+	switch (proto) {
+	case IPPROTO_AH:
+	case IPPROTO_ESP:
+		break;
+
+	case IPPROTO_COMP:
+		/* IPCOMP spi is 16-bits. */
+		if (max >= 0x10000)
+			return -EINVAL;
+		break;
+
+	default:
+		return -EINVAL;
+	}
+
+	if (min > max)
+		return -EINVAL;
+
+	return 0;
+}
+EXPORT_SYMBOL(verify_spi_info);
+
 int xfrm_alloc_spi(struct xfrm_state *x, u32 low, u32 high)
 {
 	struct net *net = xs_net(x);
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 4027c42..97681a3 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -1079,29 +1079,6 @@ out_noput:
 	return err;
 }
 
-static int verify_userspi_info(struct xfrm_userspi_info *p)
-{
-	switch (p->info.id.proto) {
-	case IPPROTO_AH:
-	case IPPROTO_ESP:
-		break;
-
-	case IPPROTO_COMP:
-		/* IPCOMP spi is 16-bits. */
-		if (p->max >= 0x10000)
-			return -EINVAL;
-		break;
-
-	default:
-		return -EINVAL;
-	}
-
-	if (p->min > p->max)
-		return -EINVAL;
-
-	return 0;
-}
-
 static int xfrm_alloc_userspi(struct sk_buff *skb, struct nlmsghdr *nlh,
 		struct nlattr **attrs)
 {
@@ -1116,7 +1093,7 @@ static int xfrm_alloc_userspi(struct sk_buff *skb, struct nlmsghdr *nlh,
 	struct xfrm_mark m;
 
 	p = nlmsg_data(nlh);
-	err = verify_userspi_info(p);
+	err = verify_spi_info(p->info.id.proto, p->min, p->max);
 	if (err)
 		goto out_noput;
 
-- 
1.7.9.5
