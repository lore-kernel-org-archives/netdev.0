From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 3/4] xfrm: Check for esn buffer len in xfrm_new_ae
Date: Tue, 29 Mar 2011 07:47:30 +0200
Message-ID: <20110329054730.GK1290@secunet.com>
References: <20110329054552.GI1290@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:52877 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752347Ab1C2Frc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Mar 2011 01:47:32 -0400
Content-Disposition: inline
In-Reply-To: <20110329054552.GI1290@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In xfrm_new_ae() we may overwrite the allocated esn replay state
buffer with a wrong size. So check that the new size matches the
original allocated size and return an error if this is not the case.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_user.c |   21 +++++++++++++++++++++
 1 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index fc152d2..ccc4c0c 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -360,6 +360,23 @@ static int attach_aead(struct xfrm_algo_aead **algpp, u8 *props,
 	return 0;
 }
 
+static inline int xfrm_replay_verify_len(struct xfrm_replay_state_esn *replay_esn,
+					 struct nlattr *rp)
+{
+	struct xfrm_replay_state_esn *up;
+
+	if (!replay_esn || !rp)
+		return 0;
+
+	up = nla_data(rp);
+
+	if (xfrm_replay_state_esn_len(replay_esn) !=
+			xfrm_replay_state_esn_len(up))
+		return -EINVAL;
+
+	return 0;
+}
+
 static int xfrm_alloc_replay_state_esn(struct xfrm_replay_state_esn **replay_esn,
 				       struct xfrm_replay_state_esn **preplay_esn,
 				       struct nlattr *rta)
@@ -1766,6 +1783,10 @@ static int xfrm_new_ae(struct sk_buff *skb, struct nlmsghdr *nlh,
 	if (x->km.state != XFRM_STATE_VALID)
 		goto out;
 
+	err = xfrm_replay_verify_len(x->replay_esn, rp);
+	if (err)
+		goto out;
+
 	spin_lock_bh(&x->lock);
 	xfrm_update_ae_params(x, attrs);
 	spin_unlock_bh(&x->lock);
-- 
1.7.0.4

