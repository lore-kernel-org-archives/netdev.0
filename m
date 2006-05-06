From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [RFC 1/3] [IPSEC] xfrm: Undo afinfo lock proliferation
Date: Sat, 6 May 2006 21:21:23 +1000
Message-ID: <20060506112123.GA27904@gondor.apana.org.au>
References: <1145343829.44448f556684c@webmail.hiit.fi> <20060418080340.GA2206@gondor.apana.org.au> <Pine.SOL.4.64.0604181512460.26361@kekkonen.cs.hut.fi> <20060419110209.GA15584@gondor.apana.org.au> <Pine.SOL.4.64.0604191529100.11141@kekkonen.cs.hut.fi> <20060506112026.GA27671@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="k1lZvvs/B4yU6o8G"
Cc: Diego Beltrami <Diego.Beltrami@hiit.fi>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:16654 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1750725AbWEFLVb
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 May 2006 07:21:31 -0400
To: Miika Komu <miika@iki.fi>
Content-Disposition: inline
In-Reply-To: <20060506112026.GA27671@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--k1lZvvs/B4yU6o8G
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi:

The number of locks used to manage afinfo structures can easily be reduced
down to one each for policy and state respectively.  This is based on the
observation that the write locks are only held by module insertion/removal
which are very rare events so there is no need to further differentiate
between the insertion of modules like ipv6 versus esp6.

The removal of the read locks in xfrm4_policy.c/xfrm6_policy.c might look
suspicious at first.  However, after you realise that nobody ever takes
the corresponding write lock you'll feel better :)

As far as I can gather it's an attempt to guard against the removal of
the corresponding modules.  Since neither module can be unloaded at all
we can leave it to whoever fixes up IPv6 unloading :)

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--k1lZvvs/B4yU6o8G
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="p1.patch"

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -204,8 +204,7 @@ struct xfrm_type;
 struct xfrm_dst;
 struct xfrm_policy_afinfo {
 	unsigned short		family;
-	rwlock_t		lock;
-	struct xfrm_type_map	*type_map;
+	struct xfrm_type	*type_map[256];
 	struct dst_ops		*dst_ops;
 	void			(*garbage_collect)(void);
 	int			(*dst_lookup)(struct xfrm_dst **dst, struct flowi *fl);
@@ -232,7 +231,6 @@ extern int __xfrm_state_delete(struct xf
 
 struct xfrm_state_afinfo {
 	unsigned short		family;
-	rwlock_t		lock;
 	struct list_head	*state_bydst;
 	struct list_head	*state_byspi;
 	int			(*init_flags)(struct xfrm_state *x);
@@ -264,11 +262,6 @@ struct xfrm_type
 	u32			(*get_max_size)(struct xfrm_state *, int size);
 };
 
-struct xfrm_type_map {
-	rwlock_t		lock;
-	struct xfrm_type	*map[256];
-};
-
 extern int xfrm_register_type(struct xfrm_type *type, unsigned short family);
 extern int xfrm_unregister_type(struct xfrm_type *type, unsigned short family);
 extern struct xfrm_type *xfrm_get_type(u8 proto, unsigned short family);
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -17,8 +17,6 @@
 static struct dst_ops xfrm4_dst_ops;
 static struct xfrm_policy_afinfo xfrm4_policy_afinfo;
 
-static struct xfrm_type_map xfrm4_type_map = { .lock = RW_LOCK_UNLOCKED };
-
 static int xfrm4_dst_lookup(struct xfrm_dst **dst, struct flowi *fl)
 {
 	return __ip_route_output_key((struct rtable**)dst, fl);
@@ -237,9 +235,7 @@ _decode_session4(struct sk_buff *skb, st
 
 static inline int xfrm4_garbage_collect(void)
 {
-	read_lock(&xfrm4_policy_afinfo.lock);
 	xfrm4_policy_afinfo.garbage_collect();
-	read_unlock(&xfrm4_policy_afinfo.lock);
 	return (atomic_read(&xfrm4_dst_ops.entries) > xfrm4_dst_ops.gc_thresh*2);
 }
 
@@ -299,8 +295,6 @@ static struct dst_ops xfrm4_dst_ops = {
 
 static struct xfrm_policy_afinfo xfrm4_policy_afinfo = {
 	.family = 		AF_INET,
-	.lock = 		RW_LOCK_UNLOCKED,
-	.type_map = 		&xfrm4_type_map,
 	.dst_ops =		&xfrm4_dst_ops,
 	.dst_lookup =		xfrm4_dst_lookup,
 	.find_bundle = 		__xfrm4_find_bundle,
diff --git a/net/ipv4/xfrm4_state.c b/net/ipv4/xfrm4_state.c
--- a/net/ipv4/xfrm4_state.c
+++ b/net/ipv4/xfrm4_state.c
@@ -131,7 +131,6 @@ __xfrm4_find_acq(u8 mode, u32 reqid, u8 
 
 static struct xfrm_state_afinfo xfrm4_state_afinfo = {
 	.family			= AF_INET,
-	.lock			= RW_LOCK_UNLOCKED,
 	.init_flags		= xfrm4_init_flags,
 	.init_tempsel		= __xfrm4_init_tempsel,
 	.state_lookup		= __xfrm4_state_lookup,
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -23,8 +23,6 @@
 static struct dst_ops xfrm6_dst_ops;
 static struct xfrm_policy_afinfo xfrm6_policy_afinfo;
 
-static struct xfrm_type_map xfrm6_type_map = { .lock = RW_LOCK_UNLOCKED };
-
 static int xfrm6_dst_lookup(struct xfrm_dst **dst, struct flowi *fl)
 {
 	int err = 0;
@@ -249,9 +247,7 @@ _decode_session6(struct sk_buff *skb, st
 
 static inline int xfrm6_garbage_collect(void)
 {
-	read_lock(&xfrm6_policy_afinfo.lock);
 	xfrm6_policy_afinfo.garbage_collect();
-	read_unlock(&xfrm6_policy_afinfo.lock);
 	return (atomic_read(&xfrm6_dst_ops.entries) > xfrm6_dst_ops.gc_thresh*2);
 }
 
@@ -311,8 +307,6 @@ static struct dst_ops xfrm6_dst_ops = {
 
 static struct xfrm_policy_afinfo xfrm6_policy_afinfo = {
 	.family =		AF_INET6,
-	.lock = 		RW_LOCK_UNLOCKED,
-	.type_map = 		&xfrm6_type_map,
 	.dst_ops =		&xfrm6_dst_ops,
 	.dst_lookup =		xfrm6_dst_lookup,
 	.find_bundle =		__xfrm6_find_bundle,
diff --git a/net/ipv6/xfrm6_state.c b/net/ipv6/xfrm6_state.c
--- a/net/ipv6/xfrm6_state.c
+++ b/net/ipv6/xfrm6_state.c
@@ -135,7 +135,6 @@ __xfrm6_find_acq(u8 mode, u32 reqid, u8 
 
 static struct xfrm_state_afinfo xfrm6_state_afinfo = {
 	.family			= AF_INET6,
-	.lock			= RW_LOCK_UNLOCKED,
 	.init_tempsel		= __xfrm6_init_tempsel,
 	.state_lookup		= __xfrm6_state_lookup,
 	.find_acq		= __xfrm6_find_acq,
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -46,45 +46,43 @@ static DEFINE_SPINLOCK(xfrm_policy_gc_lo
 
 static struct xfrm_policy_afinfo *xfrm_policy_get_afinfo(unsigned short family);
 static void xfrm_policy_put_afinfo(struct xfrm_policy_afinfo *afinfo);
+static struct xfrm_policy_afinfo *xfrm_policy_lock_afinfo(unsigned int family);
+static void xfrm_policy_unlock_afinfo(struct xfrm_policy_afinfo *afinfo);
 
 int xfrm_register_type(struct xfrm_type *type, unsigned short family)
 {
-	struct xfrm_policy_afinfo *afinfo = xfrm_policy_get_afinfo(family);
-	struct xfrm_type_map *typemap;
+	struct xfrm_policy_afinfo *afinfo = xfrm_policy_lock_afinfo(family);
+	struct xfrm_type **typemap;
 	int err = 0;
 
 	if (unlikely(afinfo == NULL))
 		return -EAFNOSUPPORT;
 	typemap = afinfo->type_map;
 
-	write_lock_bh(&typemap->lock);
-	if (likely(typemap->map[type->proto] == NULL))
-		typemap->map[type->proto] = type;
+	if (likely(typemap[type->proto] == NULL))
+		typemap[type->proto] = type;
 	else
 		err = -EEXIST;
-	write_unlock_bh(&typemap->lock);
-	xfrm_policy_put_afinfo(afinfo);
+	xfrm_policy_unlock_afinfo(afinfo);
 	return err;
 }
 EXPORT_SYMBOL(xfrm_register_type);
 
 int xfrm_unregister_type(struct xfrm_type *type, unsigned short family)
 {
-	struct xfrm_policy_afinfo *afinfo = xfrm_policy_get_afinfo(family);
-	struct xfrm_type_map *typemap;
+	struct xfrm_policy_afinfo *afinfo = xfrm_policy_lock_afinfo(family);
+	struct xfrm_type **typemap;
 	int err = 0;
 
 	if (unlikely(afinfo == NULL))
 		return -EAFNOSUPPORT;
 	typemap = afinfo->type_map;
 
-	write_lock_bh(&typemap->lock);
-	if (unlikely(typemap->map[type->proto] != type))
+	if (unlikely(typemap[type->proto] != type))
 		err = -ENOENT;
 	else
-		typemap->map[type->proto] = NULL;
-	write_unlock_bh(&typemap->lock);
-	xfrm_policy_put_afinfo(afinfo);
+		typemap[type->proto] = NULL;
+	xfrm_policy_unlock_afinfo(afinfo);
 	return err;
 }
 EXPORT_SYMBOL(xfrm_unregister_type);
@@ -92,7 +90,7 @@ EXPORT_SYMBOL(xfrm_unregister_type);
 struct xfrm_type *xfrm_get_type(u8 proto, unsigned short family)
 {
 	struct xfrm_policy_afinfo *afinfo;
-	struct xfrm_type_map *typemap;
+	struct xfrm_type **typemap;
 	struct xfrm_type *type;
 	int modload_attempted = 0;
 
@@ -102,11 +100,9 @@ retry:
 		return NULL;
 	typemap = afinfo->type_map;
 
-	read_lock(&typemap->lock);
-	type = typemap->map[proto];
+	type = typemap[proto];
 	if (unlikely(type && !try_module_get(type->owner)))
 		type = NULL;
-	read_unlock(&typemap->lock);
 	if (!type && !modload_attempted) {
 		xfrm_policy_put_afinfo(afinfo);
 		request_module("xfrm-type-%d-%d",
@@ -1306,17 +1302,31 @@ static struct xfrm_policy_afinfo *xfrm_p
 		return NULL;
 	read_lock(&xfrm_policy_afinfo_lock);
 	afinfo = xfrm_policy_afinfo[family];
-	if (likely(afinfo != NULL))
-		read_lock(&afinfo->lock);
-	read_unlock(&xfrm_policy_afinfo_lock);
+	if (unlikely(!afinfo))
+		read_unlock(&xfrm_policy_afinfo_lock);
 	return afinfo;
 }
 
 static void xfrm_policy_put_afinfo(struct xfrm_policy_afinfo *afinfo)
 {
-	if (unlikely(afinfo == NULL))
-		return;
-	read_unlock(&afinfo->lock);
+	read_unlock(&xfrm_policy_afinfo_lock);
+}
+
+static struct xfrm_policy_afinfo *xfrm_policy_lock_afinfo(unsigned int family)
+{
+	struct xfrm_policy_afinfo *afinfo;
+	if (unlikely(family >= NPROTO))
+		return NULL;
+	write_lock_bh(&xfrm_policy_afinfo_lock);
+	afinfo = xfrm_policy_afinfo[family];
+	if (unlikely(!afinfo))
+		write_unlock_bh(&xfrm_policy_afinfo_lock);
+	return afinfo;
+}
+
+static void xfrm_policy_unlock_afinfo(struct xfrm_policy_afinfo *afinfo)
+{
+	write_unlock_bh(&xfrm_policy_afinfo_lock);
 }
 
 static int xfrm_dev_event(struct notifier_block *this, unsigned long event, void *ptr)
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -1103,17 +1103,14 @@ static struct xfrm_state_afinfo *xfrm_st
 		return NULL;
 	read_lock(&xfrm_state_afinfo_lock);
 	afinfo = xfrm_state_afinfo[family];
-	if (likely(afinfo != NULL))
-		read_lock(&afinfo->lock);
-	read_unlock(&xfrm_state_afinfo_lock);
+	if (unlikely(!afinfo))
+		read_unlock(&xfrm_state_afinfo_lock);
 	return afinfo;
 }
 
 static void xfrm_state_put_afinfo(struct xfrm_state_afinfo *afinfo)
 {
-	if (unlikely(afinfo == NULL))
-		return;
-	read_unlock(&afinfo->lock);
+	read_unlock(&xfrm_state_afinfo_lock);
 }
 
 /* Temporarily located here until net/xfrm/xfrm_tunnel.c is created */

--k1lZvvs/B4yU6o8G--
