From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 5/8] xfrm: Auto-load xfrm offload modules
Date: Mon, 21 Aug 2017 07:49:30 +0200
Message-ID: <1503294573-10206-6-git-send-email-steffen.klassert@secunet.com>
References: <1503294573-10206-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:34940 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751264AbdHUFtn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Aug 2017 01:49:43 -0400
In-Reply-To: <1503294573-10206-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ilan Tayari <ilant@mellanox.com>

IPSec crypto offload depends on the protocol-specific
offload module (such as esp_offload.ko).

When the user installs an SA with crypto-offload, load
the offload module automatically, in the same way
that the protocol module is loaded (such as esp.ko)

Signed-off-by: Ilan Tayari <ilant@mellanox.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/xfrm.h      |  4 +++-
 net/ipv4/esp4_offload.c |  1 +
 net/ipv6/esp6_offload.c |  1 +
 net/xfrm/xfrm_device.c  |  2 +-
 net/xfrm/xfrm_state.c   | 16 ++++++++++++----
 net/xfrm/xfrm_user.c    |  2 +-
 6 files changed, 19 insertions(+), 7 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index afb4929..5a36010 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -43,6 +43,8 @@
 	MODULE_ALIAS("xfrm-mode-" __stringify(family) "-" __stringify(encap))
 #define MODULE_ALIAS_XFRM_TYPE(family, proto) \
 	MODULE_ALIAS("xfrm-type-" __stringify(family) "-" __stringify(proto))
+#define MODULE_ALIAS_XFRM_OFFLOAD_TYPE(family, proto) \
+	MODULE_ALIAS("xfrm-offload-" __stringify(family) "-" __stringify(proto))
 
 #ifdef CONFIG_XFRM_STATISTICS
 #define XFRM_INC_STATS(net, field)	SNMP_INC_STATS((net)->mib.xfrm_statistics, field)
@@ -1558,7 +1560,7 @@ void xfrm_spd_getinfo(struct net *net, struct xfrmk_spdinfo *si);
 u32 xfrm_replay_seqhi(struct xfrm_state *x, __be32 net_seq);
 int xfrm_init_replay(struct xfrm_state *x);
 int xfrm_state_mtu(struct xfrm_state *x, int mtu);
-int __xfrm_init_state(struct xfrm_state *x, bool init_replay);
+int __xfrm_init_state(struct xfrm_state *x, bool init_replay, bool offload);
 int xfrm_init_state(struct xfrm_state *x);
 int xfrm_prepare_input(struct xfrm_state *x, struct sk_buff *skb);
 int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type);
diff --git a/net/ipv4/esp4_offload.c b/net/ipv4/esp4_offload.c
index 05831de..aca1c85 100644
--- a/net/ipv4/esp4_offload.c
+++ b/net/ipv4/esp4_offload.c
@@ -305,3 +305,4 @@ module_init(esp4_offload_init);
 module_exit(esp4_offload_exit);
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Steffen Klassert <steffen.klassert@secunet.com>");
+MODULE_ALIAS_XFRM_OFFLOAD_TYPE(AF_INET, XFRM_PROTO_ESP);
diff --git a/net/ipv6/esp6_offload.c b/net/ipv6/esp6_offload.c
index eec3add..8d4e2ba 100644
--- a/net/ipv6/esp6_offload.c
+++ b/net/ipv6/esp6_offload.c
@@ -334,3 +334,4 @@ module_init(esp6_offload_init);
 module_exit(esp6_offload_exit);
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Steffen Klassert <steffen.klassert@secunet.com>");
+MODULE_ALIAS_XFRM_OFFLOAD_TYPE(AF_INET6, XFRM_PROTO_ESP);
diff --git a/net/xfrm/xfrm_device.c b/net/xfrm/xfrm_device.c
index 5cd7a24..1904127 100644
--- a/net/xfrm/xfrm_device.c
+++ b/net/xfrm/xfrm_device.c
@@ -63,7 +63,7 @@ int xfrm_dev_state_add(struct net *net, struct xfrm_state *x,
 	xfrm_address_t *daddr;
 
 	if (!x->type_offload)
-		return 0;
+		return -EINVAL;
 
 	/* We don't yet support UDP encapsulation, TFC padding and ESN. */
 	if (x->encap || x->tfcpad || (x->props.flags & XFRM_STATE_ESN))
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 82cbbce..a41e2ef 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -296,12 +296,14 @@ int xfrm_unregister_type_offload(const struct xfrm_type_offload *type,
 }
 EXPORT_SYMBOL(xfrm_unregister_type_offload);
 
-static const struct xfrm_type_offload *xfrm_get_type_offload(u8 proto, unsigned short family)
+static const struct xfrm_type_offload *
+xfrm_get_type_offload(u8 proto, unsigned short family, bool try_load)
 {
 	struct xfrm_state_afinfo *afinfo;
 	const struct xfrm_type_offload **typemap;
 	const struct xfrm_type_offload *type;
 
+retry:
 	afinfo = xfrm_state_get_afinfo(family);
 	if (unlikely(afinfo == NULL))
 		return NULL;
@@ -311,6 +313,12 @@ static const struct xfrm_type_offload *xfrm_get_type_offload(u8 proto, unsigned
 	if ((type && !try_module_get(type->owner)))
 		type = NULL;
 
+	if (!type && try_load) {
+		request_module("xfrm-offload-%d-%d", family, proto);
+		try_load = 0;
+		goto retry;
+	}
+
 	rcu_read_unlock();
 	return type;
 }
@@ -2165,7 +2173,7 @@ int xfrm_state_mtu(struct xfrm_state *x, int mtu)
 	return mtu - x->props.header_len;
 }
 
-int __xfrm_init_state(struct xfrm_state *x, bool init_replay)
+int __xfrm_init_state(struct xfrm_state *x, bool init_replay, bool offload)
 {
 	struct xfrm_state_afinfo *afinfo;
 	struct xfrm_mode *inner_mode;
@@ -2230,7 +2238,7 @@ int __xfrm_init_state(struct xfrm_state *x, bool init_replay)
 	if (x->type == NULL)
 		goto error;
 
-	x->type_offload = xfrm_get_type_offload(x->id.proto, family);
+	x->type_offload = xfrm_get_type_offload(x->id.proto, family, offload);
 
 	err = x->type->init_state(x);
 	if (err)
@@ -2258,7 +2266,7 @@ EXPORT_SYMBOL(__xfrm_init_state);
 
 int xfrm_init_state(struct xfrm_state *x)
 {
-	return __xfrm_init_state(x, true);
+	return __xfrm_init_state(x, true, false);
 }
 
 EXPORT_SYMBOL(xfrm_init_state);
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 1b539b7..ffe8d5e 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -584,7 +584,7 @@ static struct xfrm_state *xfrm_state_construct(struct net *net,
 
 	xfrm_mark_get(attrs, &x->mark);
 
-	err = __xfrm_init_state(x, false);
+	err = __xfrm_init_state(x, false, attrs[XFRMA_OFFLOAD_DEV]);
 	if (err)
 		goto error;
 
-- 
2.7.4
