From: Fan Du <fan.du@windriver.com>
Subject: [PATCHv2 net-next 2/3] xfrm: export verify_userspi_info for pkfey and netlink interface
Date: Sun, 15 Dec 2013 17:19:53 +0800
Message-ID: <1387099194-18540-3-git-send-email-fan.du@windriver.com>
References: <1387099194-18540-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:62952 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753231Ab3LOJUI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Dec 2013 04:20:08 -0500
In-Reply-To: <1387099194-18540-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to check against valid IPcomp spi range, export verify_userspi_info
for both pfkey and netlink interface.

Signed-off-by: Fan Du <fan.du@windriver.com>
---
 include/net/xfrm.h    |    1 +
 net/key/af_key.c      |    6 ++++++
 net/xfrm/xfrm_state.c |   24 ++++++++++++++++++++++++
 net/xfrm/xfrm_user.c  |   25 +------------------------
 4 files changed, 32 insertions(+), 24 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 6b82fdf..369fa99 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1564,6 +1564,7 @@ struct xfrm_policy *xfrm_policy_byid(struct net *net, u32 mark, u8, int dir,
 				     u32 id, int delete, int *err);
 int xfrm_policy_flush(struct net *net, u8 type, struct xfrm_audit *audit_info);
 u32 xfrm_get_acqseq(void);
+int verify_spi_info(u8 proto, u32 min, u32 max);
 int xfrm_alloc_spi(struct xfrm_state *x, u32 minspi, u32 maxspi);
 struct xfrm_state *xfrm_find_acq(struct net *net, const struct xfrm_mark *mark,
 				 u8 mode, u32 reqid, u8 proto,
diff --git a/net/key/af_key.c b/net/key/af_key.c
index 545f047..7605d51 100644
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
index 68c2f35..d953639 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -1496,6 +1496,30 @@ u32 xfrm_get_acqseq(void)
 }
 EXPORT_SYMBOL(xfrm_get_acqseq);
 
+int verify_spi_info(u8 proto, u32 min, u32 max)
+{
+        switch (proto) {
+        case IPPROTO_AH:
+        case IPPROTO_ESP:
+                break;
+
+        case IPPROTO_COMP:
+                /* IPCOMP spi is 16-bits. */
+                if (max >= 0x10000)
+                        return -EINVAL;
+                break;
+
+        default:
+                return -EINVAL;
+        }    
+
+        if (min > max)
+                return -EINVAL;
+
+        return 0;
+}
+EXPORT_SYMBOL(verify_spi_info);
+
 int xfrm_alloc_spi(struct xfrm_state *x, u32 low, u32 high)
 {
 	struct net *net = xs_net(x);
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 8543b1b..f837983 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -1076,29 +1076,6 @@ out_noput:
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
@@ -1113,7 +1090,7 @@ static int xfrm_alloc_userspi(struct sk_buff *skb, struct nlmsghdr *nlh,
 	struct xfrm_mark m;
 
 	p = nlmsg_data(nlh);
-	err = verify_userspi_info(p);
+	err = verify_spi_info(p->info.id.proto, p->min, p->max);
 	if (err)
 		goto out_noput;
 
-- 
1.7.9.5
