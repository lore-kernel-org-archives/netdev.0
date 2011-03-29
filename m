From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 2/4] xfrm: Assign esn pointers when cloning a state
Date: Tue, 29 Mar 2011 07:46:39 +0200
Message-ID: <20110329054639.GJ1290@secunet.com>
References: <20110329054552.GI1290@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:52869 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752347Ab1C2Fql (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Mar 2011 01:46:41 -0400
Content-Disposition: inline
In-Reply-To: <20110329054552.GI1290@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When we clone a xfrm state we have to assign the replay_esn
and the preplay_esn pointers to the state if we use the
new replay detection method. To this end, we add a
xfrm_replay_clone() function that allocates memory for
the replay detection and takes over the necessary values
from the original state.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/xfrm.h    |   22 ++++++++++++++++++++++
 net/xfrm/xfrm_state.c |    6 ++++++
 2 files changed, 28 insertions(+), 0 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index cffa5dc..6ae4bc5 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1601,6 +1601,28 @@ static inline int xfrm_replay_state_esn_len(struct xfrm_replay_state_esn *replay
 }
 
 #ifdef CONFIG_XFRM_MIGRATE
+static inline int xfrm_replay_clone(struct xfrm_state *x,
+				     struct xfrm_state *orig)
+{
+	x->replay_esn = kzalloc(xfrm_replay_state_esn_len(orig->replay_esn),
+				GFP_KERNEL);
+	if (!x->replay_esn)
+		return -ENOMEM;
+
+	x->replay_esn->bmp_len = orig->replay_esn->bmp_len;
+	x->replay_esn->replay_window = orig->replay_esn->replay_window;
+
+	x->preplay_esn = kmemdup(x->replay_esn,
+				 xfrm_replay_state_esn_len(x->replay_esn),
+				 GFP_KERNEL);
+	if (!x->preplay_esn) {
+		kfree(x->replay_esn);
+		return -ENOMEM;
+	}
+
+	return 0;
+}
+
 static inline struct xfrm_algo *xfrm_algo_clone(struct xfrm_algo *orig)
 {
 	return kmemdup(orig, xfrm_alg_len(orig), GFP_KERNEL);
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index f83a3d1..dd78536 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -1181,6 +1181,12 @@ static struct xfrm_state *xfrm_state_clone(struct xfrm_state *orig, int *errp)
 			goto error;
 	}
 
+	if (orig->replay_esn) {
+		err = xfrm_replay_clone(x, orig);
+		if (err)
+			goto error;
+	}
+
 	memcpy(&x->mark, &orig->mark, sizeof(x->mark));
 
 	err = xfrm_init_state(x);
-- 
1.7.0.4

