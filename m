From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 4/5] xfrm: make xfrm_replay_state_esn_len() return unsigned
 int
Date: Thu, 21 Sep 2017 23:47:50 +0300
Message-ID: <20170921204750.GE13550@avx2>
References: <20170921204543.GB13550@avx2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, davem@davemloft.net,
        netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35981 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751728AbdIUUrx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 16:47:53 -0400
Received: by mail-wm0-f67.google.com with SMTP id r136so6213478wmf.3
        for <netdev@vger.kernel.org>; Thu, 21 Sep 2017 13:47:53 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170921204543.GB13550@avx2>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replay detection bitmaps can't have negative length.

Comparisons with nla_len() are left signed just in case negative value
can sneak in there.

Propagate unsignedness for code size savings:

	add/remove: 0/0 grow/shrink: 0/5 up/down: 0/-38 (-38)
	function                                     old     new   delta
	xfrm_state_construct                        1802    1800      -2
	xfrm_update_ae_params                        295     289      -6
	xfrm_state_migrate                          1345    1339      -6
	xfrm_replay_notify_esn                       349     337     -12
	xfrm_replay_notify_bmp                       345     333     -12

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/net/xfrm.h   |    2 +-
 net/xfrm/xfrm_user.c |   10 +++++-----
 2 files changed, 6 insertions(+), 6 deletions(-)

--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1779,7 +1779,7 @@ static inline unsigned int xfrm_alg_auth_len(const struct xfrm_algo_auth *alg)
 	return sizeof(*alg) + ((alg->alg_key_len + 7) / 8);
 }
 
-static inline int xfrm_replay_state_esn_len(struct xfrm_replay_state_esn *replay_esn)
+static inline unsigned int xfrm_replay_state_esn_len(struct xfrm_replay_state_esn *replay_esn)
 {
 	return sizeof(*replay_esn) + replay_esn->bmp_len * sizeof(__u32);
 }
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -130,7 +130,7 @@ static inline int verify_replay(struct xfrm_usersa_info *p,
 		if (rs->bmp_len > XFRMA_REPLAY_ESN_MAX / sizeof(rs->bmp[0]) / 8)
 			return -EINVAL;
 
-		if (nla_len(rt) < xfrm_replay_state_esn_len(rs) &&
+		if (nla_len(rt) < (int)xfrm_replay_state_esn_len(rs) &&
 		    nla_len(rt) != sizeof(*rs))
 			return -EINVAL;
 	}
@@ -404,7 +404,7 @@ static inline int xfrm_replay_verify_len(struct xfrm_replay_state_esn *replay_es
 					 struct nlattr *rp)
 {
 	struct xfrm_replay_state_esn *up;
-	int ulen;
+	unsigned int ulen;
 
 	if (!replay_esn || !rp)
 		return 0;
@@ -414,7 +414,7 @@ static inline int xfrm_replay_verify_len(struct xfrm_replay_state_esn *replay_es
 
 	/* Check the overall length and the internal bitmap length to avoid
 	 * potential overflow. */
-	if (nla_len(rp) < ulen ||
+	if (nla_len(rp) < (int)ulen ||
 	    xfrm_replay_state_esn_len(replay_esn) != ulen ||
 	    replay_esn->bmp_len != up->bmp_len)
 		return -EINVAL;
@@ -430,14 +430,14 @@ static int xfrm_alloc_replay_state_esn(struct xfrm_replay_state_esn **replay_esn
 				       struct nlattr *rta)
 {
 	struct xfrm_replay_state_esn *p, *pp, *up;
-	int klen, ulen;
+	unsigned int klen, ulen;
 
 	if (!rta)
 		return 0;
 
 	up = nla_data(rta);
 	klen = xfrm_replay_state_esn_len(up);
-	ulen = nla_len(rta) >= klen ? klen : sizeof(*up);
+	ulen = nla_len(rta) >= (int)klen ? klen : sizeof(*up);
 
 	p = kzalloc(klen, GFP_KERNEL);
 	if (!p)
