From: James Morris <jmorris@intercode.com.au>
Subject: [PATCH] Don't call request_module() under spinlock in xfrm_get_type()
Date: Sun, 6 Jul 2003 22:42:40 +1000 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Mutt.LNX.4.44.0307062238010.468-100000@excalibur.intercode.com.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: kuznet@ms2.inr.ac.ru, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch fixes a problem where request_module() was being called under 
the lock taken in xfrm_policy_get_afinfo().

An alternative fix would be to refcount xfrm_policy_afinfo structs, either
explicitly or via a module owner field, although it seems like overkill in
this case.


- James
-- 
James Morris
<jmorris@intercode.com.au>

diff -urN -X dontdiff bk.orig/net/xfrm/xfrm_policy.c bk.w1/net/xfrm/xfrm_policy.c
--- bk.orig/net/xfrm/xfrm_policy.c	2003-07-06 02:59:18.000000000 +1000
+++ bk.w1/net/xfrm/xfrm_policy.c	2003-07-06 22:32:47.230524746 +1000
@@ -80,22 +80,24 @@
 
 struct xfrm_type *xfrm_get_type(u8 proto, unsigned short family)
 {
-	struct xfrm_policy_afinfo *afinfo = xfrm_policy_get_afinfo(family);
+	struct xfrm_policy_afinfo *afinfo;
 	struct xfrm_type_map *typemap;
 	struct xfrm_type *type;
 	int modload_attempted = 0;
 
+retry:
+	afinfo = xfrm_policy_get_afinfo(family);
 	if (unlikely(afinfo == NULL))
 		return NULL;
 	typemap = afinfo->type_map;
 
-retry:
 	read_lock(&typemap->lock);
 	type = typemap->map[proto];
 	if (unlikely(type && !try_module_get(type->owner)))
 		type = NULL;
 	read_unlock(&typemap->lock);
 	if (!type && !modload_attempted) {
+		xfrm_policy_put_afinfo(afinfo);
 		request_module("xfrm-type-%d-%d",
 			       (int) family, (int) proto);
 		modload_attempted = 1;
