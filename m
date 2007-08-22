From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 06/16] [XFRM] netlink: Move algorithm length calculation to its own function
Date: Wed, 22 Aug 2007 16:55:44 +0200
Message-ID: <20070822145630.629135129@lsx.localdomain>
References: <20070822145538.861270927@lsx.localdomain>
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:56963 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763201AbXHVP3R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Aug 2007 11:29:17 -0400
Content-Disposition: inline; filename=xfrm_alg_key_len
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adds alg_len() to calculate the properly padded length of an
algorithm attribute to simplify the code.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.24/net/xfrm/xfrm_user.c
===================================================================
--- net-2.6.24.orig/net/xfrm/xfrm_user.c	2007-08-21 16:16:03.000000000 +0200
+++ net-2.6.24/net/xfrm/xfrm_user.c	2007-08-21 17:03:43.000000000 +0200
@@ -33,6 +33,11 @@
 #endif
 #include <linux/audit.h>
 
+static inline int alg_len(struct xfrm_algo *alg)
+{
+	return sizeof(*alg) + ((alg->alg_key_len + 7) / 8);
+}
+
 static int verify_one_alg(struct rtattr **xfrma, enum xfrm_attr_type_t type)
 {
 	struct rtattr *rt = xfrma[type - 1];
@@ -232,7 +237,6 @@ static int attach_one_algo(struct xfrm_a
 	struct rtattr *rta = u_arg;
 	struct xfrm_algo *p, *ualg;
 	struct xfrm_algo_desc *algo;
-	int len;
 
 	if (!rta)
 		return 0;
@@ -244,8 +248,7 @@ static int attach_one_algo(struct xfrm_a
 		return -ENOSYS;
 	*props = algo->desc.sadb_alg_id;
 
-	len = sizeof(*ualg) + (ualg->alg_key_len + 7U) / 8;
-	p = kmemdup(ualg, len, GFP_KERNEL);
+	p = kmemdup(ualg, alg_len(ualg), GFP_KERNEL);
 	if (!p)
 		return -ENOMEM;
 
@@ -617,11 +620,9 @@ static int dump_one_state(struct xfrm_st
 	copy_to_user_state(x, p);
 
 	if (x->aalg)
-		NLA_PUT(skb, XFRMA_ALG_AUTH,
-			sizeof(*(x->aalg))+(x->aalg->alg_key_len+7)/8, x->aalg);
+		NLA_PUT(skb, XFRMA_ALG_AUTH, alg_len(x->aalg), x->aalg);
 	if (x->ealg)
-		NLA_PUT(skb, XFRMA_ALG_CRYPT,
-			sizeof(*(x->ealg))+(x->ealg->alg_key_len+7)/8, x->ealg);
+		NLA_PUT(skb, XFRMA_ALG_CRYPT, alg_len(x->ealg), x->ealg);
 	if (x->calg)
 		NLA_PUT(skb, XFRMA_ALG_COMP, sizeof(*(x->calg)), x->calg);
 
@@ -2072,9 +2073,9 @@ static inline int xfrm_sa_len(struct xfr
 {
 	int l = 0;
 	if (x->aalg)
-		l += RTA_SPACE(sizeof(*x->aalg) + (x->aalg->alg_key_len+7)/8);
+		l += RTA_SPACE(alg_len(x->aalg));
 	if (x->ealg)
-		l += RTA_SPACE(sizeof(*x->ealg) + (x->ealg->alg_key_len+7)/8);
+		l += RTA_SPACE(alg_len(x->ealg));
 	if (x->calg)
 		l += RTA_SPACE(sizeof(*x->calg));
 	if (x->encap)
@@ -2127,11 +2128,9 @@ static int xfrm_notify_sa(struct xfrm_st
 	copy_to_user_state(x, p);
 
 	if (x->aalg)
-		NLA_PUT(skb, XFRMA_ALG_AUTH,
-			sizeof(*(x->aalg))+(x->aalg->alg_key_len+7)/8, x->aalg);
+		NLA_PUT(skb, XFRMA_ALG_AUTH, alg_len(x->aalg), x->aalg);
 	if (x->ealg)
-		NLA_PUT(skb, XFRMA_ALG_CRYPT,
-			sizeof(*(x->ealg))+(x->ealg->alg_key_len+7)/8, x->ealg);
+		NLA_PUT(skb, XFRMA_ALG_CRYPT, alg_len(x->ealg), x->ealg);
 	if (x->calg)
 		NLA_PUT(skb, XFRMA_ALG_COMP, sizeof(*(x->calg)), x->calg);
 

-- 

