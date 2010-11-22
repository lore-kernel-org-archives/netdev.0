From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [RFC] [PATCH 04/11] xfrm: Add basic infrastructure to support
 IPsec extended sequence numbers
Date: Mon, 22 Nov 2010 11:28:37 +0100
Message-ID: <20101122102837.GG1868@secunet.com>
References: <20101122102455.GC1868@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andreas Gruenbacher <agruen@suse.de>,
	Alex Badea <abadea@ixiacom.com>, netdev@vger.kernel.org,
	linux-crypto@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20101122102455.GC1868@secunet.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds the struct xfrm_replay_state_esn which will be
used to support IPsec extended sequence numbers and anti replay windows
bigger than 32 packets. Also we add a function that returns the actual
size of the xfrm_replay_state_esn, a xfrm netlink atribute and a xfrm state
flag for the use of extended sequence numbers.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/linux/xfrm.h |   12 ++++++++++++
 include/net/xfrm.h   |    7 +++++++
 2 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
index b971e38..9eeefb1 100644
--- a/include/linux/xfrm.h
+++ b/include/linux/xfrm.h
@@ -84,6 +84,16 @@ struct xfrm_replay_state {
 	__u32	bitmap;
 };
 
+struct xfrm_replay_state_esn {
+	unsigned int	bmp_len;
+	__u32		oseq;
+	__u32		seq;
+	__u32		oseq_hi;
+	__u32		seq_hi;
+	__u32		replay_window;
+	__u32		bmp[0];
+};
+
 struct xfrm_algo {
 	char		alg_name[64];
 	unsigned int	alg_key_len;    /* in bits */
@@ -283,6 +293,7 @@ enum xfrm_attr_type_t {
 	XFRMA_KMADDRESS,        /* struct xfrm_user_kmaddress */
 	XFRMA_ALG_AUTH_TRUNC,	/* struct xfrm_algo_auth */
 	XFRMA_MARK,		/* struct xfrm_mark */
+	XFRMA_REPLAY_ESN_VAL,	/* struct xfrm_replay_esn */
 	__XFRMA_MAX
 
 #define XFRMA_MAX (__XFRMA_MAX - 1)
@@ -349,6 +360,7 @@ struct xfrm_usersa_info {
 #define XFRM_STATE_WILDRECV	8
 #define XFRM_STATE_ICMP		16
 #define XFRM_STATE_AF_UNSPEC	32
+#define XFRM_STATE_ESN		64
 };
 
 struct xfrm_usersa_id {
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 54b2832..1456254 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -184,9 +184,11 @@ struct xfrm_state {
 
 	/* State for replay detection */
 	struct xfrm_replay_state replay;
+	struct xfrm_replay_state_esn *replay_esn;
 
 	/* Replay detection state at the time we sent the last notification */
 	struct xfrm_replay_state preplay;
+	struct xfrm_replay_state_esn *preplay_esn;
 
 	/* internal flag that only holds state for delayed aevent at the
 	 * moment
@@ -1553,6 +1555,11 @@ static inline int xfrm_alg_auth_len(struct xfrm_algo_auth *alg)
 	return sizeof(*alg) + ((alg->alg_key_len + 7) / 8);
 }
 
+static inline int xfrm_replay_state_esn_len(struct xfrm_replay_state_esn *replay_esn)
+{
+	return sizeof(*replay_esn) + replay_esn->bmp_len * sizeof(__u32);
+}
+
 #ifdef CONFIG_XFRM_MIGRATE
 static inline struct xfrm_algo *xfrm_algo_clone(struct xfrm_algo *orig)
 {
-- 
1.7.0.4
