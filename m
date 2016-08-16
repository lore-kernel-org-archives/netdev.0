From: Doug Applegate <doug.applegate@gmail.com>
Subject: Re: [PATCH RFC 1/1] xfrm: dst lookup doesn't account for fwmark
Date: Tue, 16 Aug 2016 11:19:35 -0600
Message-ID: <CACwzwmW-M55owRSTtBt2FuTGB9MwsBZx6VXRyFEXdn4mgFbumw@mail.gmail.com>
References: <CACwzwmXYUhHdzGLoi73enk-5CCECkdDjJDsOeYHKswqwa9AzyA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f194.google.com ([209.85.161.194]:34235 "EHLO
	mail-yw0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752150AbcHPRTh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Aug 2016 13:19:37 -0400
Received: by mail-yw0-f194.google.com with SMTP id j12so3770895ywb.1
        for <netdev@vger.kernel.org>; Tue, 16 Aug 2016 10:19:36 -0700 (PDT)
In-Reply-To: <CACwzwmXYUhHdzGLoi73enk-5CCECkdDjJDsOeYHKswqwa9AzyA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If route table includes routing based on fwmark, xfrm will not take it
into account when routing ipsec traffic. We address this issue by adding
fwmark information before calling route lookup. Also simplify lookup by
passing the entire flow struct rather than tos, oif, and fwmark as
individual params.
---
 include/net/xfrm.h      |  4 ++--
 net/ipv4/xfrm4_policy.c | 16 +++++++++-------
 net/ipv6/xfrm6_policy.c |  8 ++++----
 net/xfrm/xfrm_policy.c  | 16 ++++++++--------
 4 files changed, 23 insertions(+), 21 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index adfebd6..464bca9 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -282,10 +282,10 @@ struct xfrm_policy_afinfo {
  struct dst_ops *dst_ops;
  void (*garbage_collect)(struct net *net);
  struct dst_entry *(*dst_lookup)(struct net *net,
-       int tos, int oif,
+       const struct flowi *fl,
        const xfrm_address_t *saddr,
        const xfrm_address_t *daddr);
- int (*get_saddr)(struct net *net, int oif,
+ int (*get_saddr)(struct net *net, const struct flowi *fl,
      xfrm_address_t *saddr,
      xfrm_address_t *daddr);
  void (*decode_session)(struct sk_buff *skb,
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index b644a23..5a18acf 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -18,9 +18,10 @@
 #include <net/l3mdev.h>

 static struct xfrm_policy_afinfo xfrm4_policy_afinfo;
+static int xfrm4_get_tos(const struct flowi *fl);

 static struct dst_entry *__xfrm4_dst_lookup(struct net *net, struct
flowi4 *fl4,
-    int tos, int oif,
+    const struct flowi *fl,
     const xfrm_address_t *saddr,
     const xfrm_address_t *daddr)
 {
@@ -28,8 +29,9 @@ static struct dst_entry *__xfrm4_dst_lookup(struct
net *net, struct flowi4 *fl4,

  memset(fl4, 0, sizeof(*fl4));
  fl4->daddr = daddr->a4;
- fl4->flowi4_tos = tos;
- fl4->flowi4_oif = oif;
+    fl4->flowi4_tos = xfrm4_get_tos(fl);
+    fl4->flowi4_oif = fl->flowi_oif;
+    fl4->flowi4_mark = fl->u.ip4.flowi4_mark;
  if (saddr)
  fl4->saddr = saddr->a4;

@@ -42,22 +44,22 @@ static struct dst_entry *__xfrm4_dst_lookup(struct
net *net, struct flowi4 *fl4,
  return ERR_CAST(rt);
 }

-static struct dst_entry *xfrm4_dst_lookup(struct net *net, int tos, int oif,
+static struct dst_entry *xfrm4_dst_lookup(struct net *net, const
struct flowi *fl,
   const xfrm_address_t *saddr,
   const xfrm_address_t *daddr)
 {
  struct flowi4 fl4;

- return __xfrm4_dst_lookup(net, &fl4, tos, oif, saddr, daddr);
+ return __xfrm4_dst_lookup(net, &fl4, fl, saddr, daddr);
 }

-static int xfrm4_get_saddr(struct net *net, int oif,
+static int xfrm4_get_saddr(struct net *net, const struct flowi *fl,
    xfrm_address_t *saddr, xfrm_address_t *daddr)
 {
  struct dst_entry *dst;
  struct flowi4 fl4;

- dst = __xfrm4_dst_lookup(net, &fl4, 0, oif, NULL, daddr);
+ dst = __xfrm4_dst_lookup(net, &fl4, fl, NULL, daddr);
  if (IS_ERR(dst))
  return -EHOSTUNREACH;

diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 6cc9700..8df89f8 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -27,7 +27,7 @@

 static struct xfrm_policy_afinfo xfrm6_policy_afinfo;

-static struct dst_entry *xfrm6_dst_lookup(struct net *net, int tos, int oif,
+static struct dst_entry *xfrm6_dst_lookup(struct net *net, const
struct flowi *fl,
   const xfrm_address_t *saddr,
   const xfrm_address_t *daddr)
 {
@@ -36,7 +36,7 @@ static struct dst_entry *xfrm6_dst_lookup(struct net
*net, int tos, int oif,
  int err;

  memset(&fl6, 0, sizeof(fl6));
- fl6.flowi6_oif = oif;
+ fl6.flowi6_oif = fl->flowi_oif;
  fl6.flowi6_flags = FLOWI_FLAG_SKIP_NH_OIF;
  memcpy(&fl6.daddr, daddr, sizeof(fl6.daddr));
  if (saddr)
@@ -53,13 +53,13 @@ static struct dst_entry *xfrm6_dst_lookup(struct
net *net, int tos, int oif,
  return dst;
 }

-static int xfrm6_get_saddr(struct net *net, int oif,
+static int xfrm6_get_saddr(struct net *net, const struct flowi *fl,
    xfrm_address_t *saddr, xfrm_address_t *daddr)
 {
  struct dst_entry *dst;
  struct net_device *dev;

- dst = xfrm6_dst_lookup(net, 0, oif, NULL, daddr);
+ dst = xfrm6_dst_lookup(net, fl, NULL, daddr);
  if (IS_ERR(dst))
  return -EHOSTUNREACH;

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index b5e665b..f91c6e7 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -116,7 +116,7 @@ static void xfrm_policy_put_afinfo(struct
xfrm_policy_afinfo *afinfo)
 }

 static inline struct dst_entry *__xfrm_dst_lookup(struct net *net,
-  int tos, int oif,
+  const struct flowi *fl,
   const xfrm_address_t *saddr,
   const xfrm_address_t *daddr,
   int family)
@@ -128,7 +128,7 @@ static inline struct dst_entry
*__xfrm_dst_lookup(struct net *net,
  if (unlikely(afinfo == NULL))
  return ERR_PTR(-EAFNOSUPPORT);

- dst = afinfo->dst_lookup(net, tos, oif, saddr, daddr);
+ dst = afinfo->dst_lookup(net, fl, saddr, daddr);

  xfrm_policy_put_afinfo(afinfo);

@@ -136,7 +136,7 @@ static inline struct dst_entry
*__xfrm_dst_lookup(struct net *net,
 }

 static inline struct dst_entry *xfrm_dst_lookup(struct xfrm_state *x,
- int tos, int oif,
+ const struct flowi *fl,
  xfrm_address_t *prev_saddr,
  xfrm_address_t *prev_daddr,
  int family)
@@ -155,7 +155,7 @@ static inline struct dst_entry
*xfrm_dst_lookup(struct xfrm_state *x,
  daddr = x->coaddr;
  }

- dst = __xfrm_dst_lookup(net, tos, oif, saddr, daddr, family);
+ dst = __xfrm_dst_lookup(net, fl, saddr, daddr, family);

  if (!IS_ERR(dst)) {
  if (prev_saddr != saddr)
@@ -1395,7 +1395,7 @@ int __xfrm_sk_clone_policy(struct sock *sk,
const struct sock *osk)
 }

 static int
-xfrm_get_saddr(struct net *net, int oif, xfrm_address_t *local,
+xfrm_get_saddr(struct net *net, const struct flowi *fl, xfrm_address_t *local,
        xfrm_address_t *remote, unsigned short family)
 {
  int err;
@@ -1403,7 +1403,7 @@ xfrm_get_saddr(struct net *net, int oif,
xfrm_address_t *local,

  if (unlikely(afinfo == NULL))
  return -EINVAL;
- err = afinfo->get_saddr(net, oif, local, remote);
+ err = afinfo->get_saddr(net, fl, local, remote);
  xfrm_policy_put_afinfo(afinfo);
  return err;
 }
@@ -1432,7 +1432,7 @@ xfrm_tmpl_resolve_one(struct xfrm_policy
*policy, const struct flowi *fl,
  remote = &tmpl->id.daddr;
  local = &tmpl->saddr;
  if (xfrm_addr_any(local, tmpl->encap_family)) {
- error = xfrm_get_saddr(net, fl->flowi_oif,
+ error = xfrm_get_saddr(net, fl,
        &tmp, remote,
        tmpl->encap_family);
  if (error)
@@ -1712,7 +1712,7 @@ static struct dst_entry
*xfrm_bundle_create(struct xfrm_policy *policy,

  if (xfrm[i]->props.mode != XFRM_MODE_TRANSPORT) {
  family = xfrm[i]->props.family;
- dst = xfrm_dst_lookup(xfrm[i], tos, fl->flowi_oif,
+ dst = xfrm_dst_lookup(xfrm[i], fl,
       &saddr, &daddr, family);
  err = PTR_ERR(dst);
  if (IS_ERR(dst))
-- 
2.5.0

On Fri, Jul 22, 2016 at 3:50 PM, Doug Applegate
<doug.applegate@gmail.com> wrote:
> If route table includes routing based on fwmark, xfrm will not take it
> into account when routing ipsec traffic. We address this issue by adding
> fwmark information before calling route lookup.
>
> Signed-off-by: Doug Applegate <doug.applegate@gmail.com>
> ---
>  include/net/xfrm.h      |  3 ++-
>  net/ipv4/xfrm4_policy.c | 15 +++++++++++----
>  net/ipv6/xfrm6_policy.c | 11 +++++++++--
>  net/xfrm/xfrm_policy.c  | 28 +++++++++++++++++++++++-----
>  4 files changed, 45 insertions(+), 12 deletions(-)
>
> diff --git a/include/net/xfrm.h b/include/net/xfrm.h
> index adfebd6..13e80d1 100644
> --- a/include/net/xfrm.h
> +++ b/include/net/xfrm.h
> @@ -282,7 +282,7 @@ struct xfrm_policy_afinfo {
>   struct dst_ops *dst_ops;
>   void (*garbage_collect)(struct net *net);
>   struct dst_entry *(*dst_lookup)(struct net *net,
> -       int tos, int oif,
> +       int tos, int oif, int mark,
>         const xfrm_address_t *saddr,
>         const xfrm_address_t *daddr);
>   int (*get_saddr)(struct net *net, int oif,
> @@ -292,6 +292,7 @@ struct xfrm_policy_afinfo {
>    struct flowi *fl,
>    int reverse);
>   int (*get_tos)(const struct flowi *fl);
> + int (*get_mark)(const struct flowi *fl);
>   int (*init_path)(struct xfrm_dst *path,
>       struct dst_entry *dst,
>       int nfheader_len);
> diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
> index 7b0edb3..5dcd411 100644
> --- a/net/ipv4/xfrm4_policy.c
> +++ b/net/ipv4/xfrm4_policy.c
> @@ -20,7 +20,7 @@
>  static struct xfrm_policy_afinfo xfrm4_policy_afinfo;
>
>  static struct dst_entry *__xfrm4_dst_lookup(struct net *net, struct
> flowi4 *fl4,
> -    int tos, int oif,
> +    int tos, int oif, int mark,
>      const xfrm_address_t *saddr,
>      const xfrm_address_t *daddr)
>  {
> @@ -30,6 +30,7 @@ static struct dst_entry *__xfrm4_dst_lookup(struct
> net *net, struct flowi4 *fl4,
>   fl4->daddr = daddr->a4;
>   fl4->flowi4_tos = tos;
>   fl4->flowi4_oif = oif;
> + fl4->flowi4_mark = mark;
>   if (saddr)
>   fl4->saddr = saddr->a4;
>
> @@ -42,13 +43,13 @@ static struct dst_entry *__xfrm4_dst_lookup(struct
> net *net, struct flowi4 *fl4,
>   return ERR_CAST(rt);
>  }
>
> -static struct dst_entry *xfrm4_dst_lookup(struct net *net, int tos, int oif,
> +static struct dst_entry *xfrm4_dst_lookup(struct net *net, int tos,
> int oif, int mark,
>    const xfrm_address_t *saddr,
>    const xfrm_address_t *daddr)
>  {
>   struct flowi4 fl4;
>
> - return __xfrm4_dst_lookup(net, &fl4, tos, oif, saddr, daddr);
> + return __xfrm4_dst_lookup(net, &fl4, tos, oif, mark, saddr, daddr);
>  }
>
>  static int xfrm4_get_saddr(struct net *net, int oif,
> @@ -57,7 +58,7 @@ static int xfrm4_get_saddr(struct net *net, int oif,
>   struct dst_entry *dst;
>   struct flowi4 fl4;
>
> - dst = __xfrm4_dst_lookup(net, &fl4, 0, oif, NULL, daddr);
> + dst = __xfrm4_dst_lookup(net, &fl4, 0, oif, 0, NULL, daddr);
>   if (IS_ERR(dst))
>   return -EHOSTUNREACH;
>
> @@ -71,6 +72,11 @@ static int xfrm4_get_tos(const struct flowi *fl)
>   return IPTOS_RT_MASK & fl->u.ip4.flowi4_tos; /* Strip ECN bits */
>  }
>
> +static int xfrm4_get_mark(const struct flowi *fl)
> +{
> + return fl->u.ip4.flowi4_mark;
> +}
> +
>  static int xfrm4_init_path(struct xfrm_dst *path, struct dst_entry *dst,
>     int nfheader_len)
>  {
> @@ -278,6 +284,7 @@ static struct xfrm_policy_afinfo xfrm4_policy_afinfo = {
>   .get_saddr = xfrm4_get_saddr,
>   .decode_session = _decode_session4,
>   .get_tos = xfrm4_get_tos,
> + .get_mark = xfrm4_get_mark,
>   .init_path = xfrm4_init_path,
>   .fill_dst = xfrm4_fill_dst,
>   .blackhole_route = ipv4_blackhole_route,
> diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
> index c074771..16a0af5 100644
> --- a/net/ipv6/xfrm6_policy.c
> +++ b/net/ipv6/xfrm6_policy.c
> @@ -27,7 +27,7 @@
>
>  static struct xfrm_policy_afinfo xfrm6_policy_afinfo;
>
> -static struct dst_entry *xfrm6_dst_lookup(struct net *net, int tos, int oif,
> +static struct dst_entry *xfrm6_dst_lookup(struct net *net, int tos,
> int oif, int mark,
>    const xfrm_address_t *saddr,
>    const xfrm_address_t *daddr)
>  {
> @@ -38,6 +38,7 @@ static struct dst_entry *xfrm6_dst_lookup(struct net
> *net, int tos, int oif,
>   memset(&fl6, 0, sizeof(fl6));
>   fl6.flowi6_oif = oif;
>   fl6.flowi6_flags = FLOWI_FLAG_SKIP_NH_OIF;
> + fl6.flowi6_mark = mark
>   memcpy(&fl6.daddr, daddr, sizeof(fl6.daddr));
>   if (saddr)
>   memcpy(&fl6.saddr, saddr, sizeof(fl6.saddr));
> @@ -59,7 +60,7 @@ static int xfrm6_get_saddr(struct net *net, int oif,
>   struct dst_entry *dst;
>   struct net_device *dev;
>
> - dst = xfrm6_dst_lookup(net, 0, oif, NULL, daddr);
> + dst = xfrm6_dst_lookup(net, 0, oif, 0, NULL, daddr);
>   if (IS_ERR(dst))
>   return -EHOSTUNREACH;
>
> @@ -74,6 +75,11 @@ static int xfrm6_get_tos(const struct flowi *fl)
>   return 0;
>  }
>
> +static int xfrm6_get_mark(const struct flowi *fl)
> +{
> + return fl->u.ip6.flowi6_mark;
> +}
> +
>  static int xfrm6_init_path(struct xfrm_dst *path, struct dst_entry *dst,
>     int nfheader_len)
>  {
> @@ -298,6 +304,7 @@ static struct xfrm_policy_afinfo xfrm6_policy_afinfo = {
>   .get_saddr = xfrm6_get_saddr,
>   .decode_session = _decode_session6,
>   .get_tos = xfrm6_get_tos,
> + .get_mark = xfrm6_get_mark,
>   .init_path = xfrm6_init_path,
>   .fill_dst = xfrm6_fill_dst,
>   .blackhole_route = ip6_blackhole_route,
> diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
> index b5e665b..72f9be0 100644
> --- a/net/xfrm/xfrm_policy.c
> +++ b/net/xfrm/xfrm_policy.c
> @@ -116,7 +116,7 @@ static void xfrm_policy_put_afinfo(struct
> xfrm_policy_afinfo *afinfo)
>  }
>
>  static inline struct dst_entry *__xfrm_dst_lookup(struct net *net,
> -  int tos, int oif,
> +  int tos, int oif, int mark,
>    const xfrm_address_t *saddr,
>    const xfrm_address_t *daddr,
>    int family)
> @@ -128,7 +128,7 @@ static inline struct dst_entry
> *__xfrm_dst_lookup(struct net *net,
>   if (unlikely(afinfo == NULL))
>   return ERR_PTR(-EAFNOSUPPORT);
>
> - dst = afinfo->dst_lookup(net, tos, oif, saddr, daddr);
> + dst = afinfo->dst_lookup(net, tos, oif, mark, saddr, daddr);
>
>   xfrm_policy_put_afinfo(afinfo);
>
> @@ -136,7 +136,7 @@ static inline struct dst_entry
> *__xfrm_dst_lookup(struct net *net,
>  }
>
>  static inline struct dst_entry *xfrm_dst_lookup(struct xfrm_state *x,
> - int tos, int oif,
> + int tos, int oif, int mark,
>   xfrm_address_t *prev_saddr,
>   xfrm_address_t *prev_daddr,
>   int family)
> @@ -155,7 +155,7 @@ static inline struct dst_entry
> *xfrm_dst_lookup(struct xfrm_state *x,
>   daddr = x->coaddr;
>   }
>
> - dst = __xfrm_dst_lookup(net, tos, oif, saddr, daddr, family);
> + dst = __xfrm_dst_lookup(net, tos, oif, mark, saddr, daddr, family);
>
>   if (!IS_ERR(dst)) {
>   if (prev_saddr != saddr)
> @@ -1525,6 +1525,21 @@ static inline int xfrm_get_tos(const struct
> flowi *fl, int family)
>   return tos;
>  }
>
> +static inline int xfrm_get_mark(const struct flowi *fl, int family)
> +{
> + struct xfrm_policy_afinfo *afinfo = xfrm_policy_get_afinfo(family);
> + int mark;
> +
> + if (!afinfo)
> + return -EINVAL;
> +
> + mark = afinfo->get_mark(fl);
> +
> + xfrm_policy_put_afinfo(afinfo);
> +
> + return mark;
> +}
> +
>  static struct flow_cache_object *xfrm_bundle_flo_get(struct
> flow_cache_object *flo)
>  {
>   struct xfrm_dst *xdst = container_of(flo, struct xfrm_dst, flo);
> @@ -1667,6 +1682,7 @@ static struct dst_entry
> *xfrm_bundle_create(struct xfrm_policy *policy,
>   int nfheader_len = 0;
>   int trailer_len = 0;
>   int tos;
> + int mark;
>   int family = policy->selector.family;
>   xfrm_address_t saddr, daddr;
>
> @@ -1677,6 +1693,8 @@ static struct dst_entry
> *xfrm_bundle_create(struct xfrm_policy *policy,
>   if (tos < 0)
>   goto put_states;
>
> + mark = xfrm_get_mark(fl, family);
> +
>   dst_hold(dst);
>
>   for (; i < nx; i++) {
> @@ -1712,7 +1730,7 @@ static struct dst_entry
> *xfrm_bundle_create(struct xfrm_policy *policy,
>
>   if (xfrm[i]->props.mode != XFRM_MODE_TRANSPORT) {
>   family = xfrm[i]->props.family;
> - dst = xfrm_dst_lookup(xfrm[i], tos, fl->flowi_oif,
> + dst = xfrm_dst_lookup(xfrm[i], tos, fl->flowi_oif, mark,
>        &saddr, &daddr, family);
>   err = PTR_ERR(dst);
>   if (IS_ERR(dst))
> --
> 2.5.0
