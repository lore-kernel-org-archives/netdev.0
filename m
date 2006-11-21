From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Subject: [PATCH 9/11] [SUNRPC]: Use k{mem,str}dup where applicable
Date: Tue, 21 Nov 2006 01:29:07 -0200
Message-ID: <20061121032907.GJ7039@mandriva.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.mandriva.com ([212.85.150.183]:20973 "EHLO mx1.mandriva.com")
	by vger.kernel.org with ESMTP id S1030690AbWKUD3V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Nov 2006 22:29:21 -0500
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
---
 net/sunrpc/auth_gss/auth_gss.c       |    3 +--
 net/sunrpc/auth_gss/gss_krb5_mech.c  |    3 +--
 net/sunrpc/auth_gss/gss_spkm3_mech.c |    3 +--
 net/sunrpc/auth_gss/svcauth_gss.c    |    7 ++-----
 net/sunrpc/clnt.c                    |    3 +--
 5 files changed, 6 insertions(+), 13 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index b36b946..e5a84a4 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -198,11 +198,10 @@ simple_get_netobj(const void *p, const v
 	q = (const void *)((const char *)p + len);
 	if (unlikely(q > end || q < p))
 		return ERR_PTR(-EFAULT);
-	dest->data = kmalloc(len, GFP_KERNEL);
+	dest->data = kmemdup(p, len, GFP_KERNEL);
 	if (unlikely(dest->data == NULL))
 		return ERR_PTR(-ENOMEM);
 	dest->len = len;
-	memcpy(dest->data, p, len);
 	return q;
 }
 
diff --git a/net/sunrpc/auth_gss/gss_krb5_mech.c b/net/sunrpc/auth_gss/gss_krb5_mech.c
index 325e72e..754b8cd 100644
--- a/net/sunrpc/auth_gss/gss_krb5_mech.c
+++ b/net/sunrpc/auth_gss/gss_krb5_mech.c
@@ -70,10 +70,9 @@ simple_get_netobj(const void *p, const v
 	q = (const void *)((const char *)p + len);
 	if (unlikely(q > end || q < p))
 		return ERR_PTR(-EFAULT);
-	res->data = kmalloc(len, GFP_KERNEL);
+	res->data = kmemdup(p, len, GFP_KERNEL);
 	if (unlikely(res->data == NULL))
 		return ERR_PTR(-ENOMEM);
-	memcpy(res->data, p, len);
 	res->len = len;
 	return q;
 }
diff --git a/net/sunrpc/auth_gss/gss_spkm3_mech.c b/net/sunrpc/auth_gss/gss_spkm3_mech.c
index bdedf45..d57f608 100644
--- a/net/sunrpc/auth_gss/gss_spkm3_mech.c
+++ b/net/sunrpc/auth_gss/gss_spkm3_mech.c
@@ -76,10 +76,9 @@ simple_get_netobj(const void *p, const v
 	q = (const void *)((const char *)p + len);
 	if (unlikely(q > end || q < p))
 		return ERR_PTR(-EFAULT);
-	res->data = kmalloc(len, GFP_KERNEL);
+	res->data = kmemdup(p, len, GFP_KERNEL);
 	if (unlikely(res->data == NULL))
 		return ERR_PTR(-ENOMEM);
-	memcpy(res->data, p, len);
 	return q;
 }
 
diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index 1f0f079..700353b 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -113,9 +113,7 @@ static int rsi_match(struct cache_head *
 static int dup_to_netobj(struct xdr_netobj *dst, char *src, int len)
 {
 	dst->len = len;
-	dst->data = (len ? kmalloc(len, GFP_KERNEL) : NULL);
-	if (dst->data)
-		memcpy(dst->data, src, len);
+	dst->data = (len ? kmemdup(src, len, GFP_KERNEL) : NULL);
 	if (len && !dst->data)
 		return -ENOMEM;
 	return 0;
@@ -756,10 +754,9 @@ svcauth_gss_register_pseudoflavor(u32 ps
 	if (!new)
 		goto out;
 	kref_init(&new->h.ref);
-	new->h.name = kmalloc(strlen(name) + 1, GFP_KERNEL);
+	new->h.name = kstrdup(name, GFP_KERNEL);
 	if (!new->h.name)
 		goto out_free_dom;
-	strcpy(new->h.name, name);
 	new->h.flavour = &svcauthops_gss;
 	new->pseudoflavor = pseudoflavor;
 
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 78696f2..dfeea4f 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -253,10 +253,9 @@ rpc_clone_client(struct rpc_clnt *clnt)
 {
 	struct rpc_clnt *new;
 
-	new = kmalloc(sizeof(*new), GFP_KERNEL);
+	new = kmemdup(clnt, sizeof(*new), GFP_KERNEL);
 	if (!new)
 		goto out_no_clnt;
-	memcpy(new, clnt, sizeof(*new));
 	atomic_set(&new->cl_count, 1);
 	atomic_set(&new->cl_users, 0);
 	new->cl_parent = clnt;
-- 
1.4.2.1.g3d5c

