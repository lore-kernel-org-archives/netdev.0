From: David Dillow <dave@thedillows.org>
Subject: [RFC BK 18/22] xfrm offload v2: typhoon: add validation of offloaded xfrm_states
Date: Mon, 10 Jan 2005 10:37:02 -0500
Message-ID: <20040110014300.27@ori.thedillows.org>
References: <20040110014300.26@ori.thedillows.org>
Cc: dave@thedillows.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/10 00:58:39-05:00 dave@thedillows.org 
#   Add routines to validate that the xfrm_state passed to them is
#   one that we can offload to the 3XP.
#   
#   Signed-off-by: David Dillow <dave@thedillows.org>
# 
# drivers/net/typhoon.c
#   2005/01/10 00:58:23-05:00 dave@thedillows.org +90 -0
#   Add routines to validate that the xfrm_state passed to them is
#   one that we can offload to the 3XP.
#   
#   Signed-off-by: David Dillow <dave@thedillows.org>
# 
diff -Nru a/drivers/net/typhoon.c b/drivers/net/typhoon.c
--- a/drivers/net/typhoon.c	2005-01-10 01:17:08 -05:00
+++ b/drivers/net/typhoon.c	2005-01-10 01:17:08 -05:00
@@ -2329,6 +2329,96 @@
 	return 0;
 }
 
+#define UNSUPPORTED	goto unsupported
+#define REQUIRED(x)	if(!(x)) goto unsupported
+
+static inline int
+typhoon_validate_ealgo(struct typhoon *tp, struct xfrm_state *x)
+{
+	switch(x->props.ealgo) {
+	case SADB_EALG_NULL:
+		break;
+	case SADB_EALG_DESCBC:
+		REQUIRED(x->ealg);
+		REQUIRED(tp->capabilities & TYPHOON_CRYPTO_DES);
+		REQUIRED(x->ealg->alg_key_len == 64);
+		break;
+	case SADB_EALG_3DESCBC:
+		REQUIRED(x->ealg);
+		REQUIRED(tp->capabilities & TYPHOON_CRYPTO_3DES);
+		REQUIRED(x->ealg->alg_key_len == 128 ||
+					x->ealg->alg_key_len == 192);
+		break;
+	default:
+		UNSUPPORTED;
+	}
+
+	return 1;
+
+unsupported:
+	return 0;
+}
+
+static inline int
+typhoon_validate_aalgo(struct typhoon *tp, struct xfrm_state *x)
+{
+	switch(x->props.aalgo) {
+	case SADB_X_AALG_NULL:
+		break;
+	case SADB_AALG_MD5HMAC:
+		REQUIRED(x->aalg);
+		REQUIRED(x->aalg->alg_key_len == 128);
+		break;
+	case SADB_AALG_SHA1HMAC:
+		REQUIRED(x->aalg);
+		REQUIRED(x->aalg->alg_key_len == 160);
+		break;
+	default:
+		UNSUPPORTED;
+	}
+
+	return 1;
+
+unsupported:
+	return 0;
+}
+
+static inline int
+typhoon_validate_xfrm(struct typhoon *tp, struct xfrm_state *x)
+{
+	u8 ealgo, aalgo, need_auth = 1;
+
+	REQUIRED(x->props.family == AF_INET);
+	REQUIRED(x->dir == XFRM_STATE_DIR_OUT || x->dir == XFRM_STATE_DIR_IN);
+	REQUIRED(!x->encap);
+
+	aalgo = x->props.aalgo;
+	ealgo = x->props.ealgo;
+
+	switch(x->type->proto) {
+	case IPPROTO_ESP:
+		need_auth = 0;
+		REQUIRED(aalgo != SADB_X_AALG_NULL || ealgo != SADB_EALG_NULL);
+		REQUIRED(typhoon_validate_ealgo(tp, x));
+		/* fall through to validate auth algorithm */
+	case IPPROTO_AH:
+		REQUIRED(typhoon_validate_aalgo(tp, x));
+		if(need_auth)
+			REQUIRED(aalgo != SADB_X_AALG_NULL);
+		break;
+	default:
+		UNSUPPORTED;
+	}
+
+	return 1;
+
+unsupported:
+	return 0;
+}
+
+#undef REQUIRED
+#undef UNSUPPORTED
+
 static void
 typhoon_tx_timeout(struct net_device *dev)
 {
