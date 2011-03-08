From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [RFC v2 PATCH 2/9] xfrm: Add basic infrastructure to support IPsec
 extended sequence numbers
Date: Tue, 8 Mar 2011 11:05:43 +0100
Message-ID: <20110308100543.GD31402@secunet.com>
References: <20110308100407.GB31402@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alex Badea <abadea@ixiacom.com>,
	Andreas Gruenbacher <agruen@suse.de>, netdev@vger.kernel.org,
	linux-crypto@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:47931 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752433Ab1CHKFp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Mar 2011 05:05:45 -0500
Content-Disposition: inline
In-Reply-To: <20110308100407.GB31402@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
index b93d6f5..22e61fd 100644
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
@@ -284,6 +294,7 @@ enum xfrm_attr_type_t {
 	XFRMA_ALG_AUTH_TRUNC,	/* struct xfrm_algo_auth */
 	XFRMA_MARK,		/* struct xfrm_mark */
 	XFRMA_TFCPAD,		/* __u32 */
+	XFRMA_REPLAY_ESN_VAL,	/* struct xfrm_replay_esn */
 	__XFRMA_MAX
 
 #define XFRMA_MAX (__XFRMA_MAX - 1)
@@ -351,6 +362,7 @@ struct xfrm_usersa_info {
 #define XFRM_STATE_ICMP		16
 #define XFRM_STATE_AF_UNSPEC	32
 #define XFRM_STATE_ALIGN4	64
+#define XFRM_STATE_ESN		128
 };
 
 struct xfrm_usersa_id {
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index d5dcf39..6dab7df 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -186,9 +186,11 @@ struct xfrm_state {
 
 	/* State for replay detection */
 	struct xfrm_replay_state replay;
+	struct xfrm_replay_state_esn *replay_esn;
 
 	/* Replay detection state at the time we sent the last notification */
 	struct xfrm_replay_state preplay;
+	struct xfrm_replay_state_esn *preplay_esn;
 
 	/* internal flag that only holds state for delayed aevent at the
 	 * moment
@@ -1569,6 +1571,11 @@ static inline int xfrm_alg_auth_len(const struct xfrm_algo_auth *alg)
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

