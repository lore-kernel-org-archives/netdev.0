From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH 5/6] xfrm_user: ensure user supplied esn replay window is valid
Date: Wed, 19 Sep 2012 23:33:42 +0200
Message-ID: <1348090423-32665-6-git-send-email-minipli@googlemail.com>
References: <1348090423-32665-1-git-send-email-minipli@googlemail.com>
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Mathias Krause <minipli@googlemail.com>,
	Martin Willi <martin@revosec.ch>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1348090423-32665-1-git-send-email-minipli@googlemail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The current code fails to ensure that the netlink message actually
contains as many bytes as the header indicates. If a user creates a new
state or updates an existing one but does not supply the bytes for the
whole ESN replay window, the kernel copies random heap bytes into the
replay bitmap, the ones happen to follow the XFRMA_REPLAY_ESN_VAL
netlink attribute. This leads to following issues:

1. The replay window has random bits set confusing the replay handling
   code later on.

2. A malicious user could use this flaw to leak up to ~3.5kB of heap
   memory when she has access to the XFRM netlink interface (requires
   CAP_NET_ADMIN).

Known users of the ESN replay window are strongSwan and Steffen's
iproute2 patch (<http://patchwork.ozlabs.org/patch/85962/>). The latter
uses the interface with a bitmap supplied while the former does not.
strongSwan is therefore prone to run into issue 1.

To fix both issues without breaking existing userland allow using the
XFRMA_REPLAY_ESN_VAL netlink attribute with either an empty bitmap or a
fully specified one. For the former case we initialize the in-kernel
bitmap with zero, for the latter we copy the user supplied bitmap.

For state updates the full bitmap must be supplied.

Cc: Steffen Klassert <steffen.klassert@secunet.com>
Cc: Martin Willi <martin@revosec.ch>
Signed-off-by: Mathias Krause <minipli@googlemail.com>
---
 net/xfrm/xfrm_user.c |   27 +++++++++++++++++++++------
 1 file changed, 21 insertions(+), 6 deletions(-)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 9f1e749..7fd92b8 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -123,9 +123,17 @@ static inline int verify_replay(struct xfrm_usersa_info *p,
 				struct nlattr **attrs)
 {
 	struct nlattr *rt = attrs[XFRMA_REPLAY_ESN_VAL];
+	struct xfrm_replay_state_esn *rs;
 
-	if ((p->flags & XFRM_STATE_ESN) && !rt)
-		return -EINVAL;
+	if (p->flags & XFRM_STATE_ESN) {
+		if (!rt)
+			return -EINVAL;
+
+		rs = nla_data(rt);
+		if (nla_len(rt) < xfrm_replay_state_esn_len(rs) &&
+		    nla_len(rt) != sizeof(*rs))
+			return -EINVAL;
+	}
 
 	if (!rt)
 		return 0;
@@ -370,14 +378,15 @@ static inline int xfrm_replay_verify_len(struct xfrm_replay_state_esn *replay_es
 					 struct nlattr *rp)
 {
 	struct xfrm_replay_state_esn *up;
+	size_t ulen;
 
 	if (!replay_esn || !rp)
 		return 0;
 
 	up = nla_data(rp);
+	ulen = xfrm_replay_state_esn_len(up);
 
-	if (xfrm_replay_state_esn_len(replay_esn) !=
-			xfrm_replay_state_esn_len(up))
+	if (nla_len(rp) < ulen || xfrm_replay_state_esn_len(replay_esn) != ulen)
 		return -EINVAL;
 
 	return 0;
@@ -388,22 +397,28 @@ static int xfrm_alloc_replay_state_esn(struct xfrm_replay_state_esn **replay_esn
 				       struct nlattr *rta)
 {
 	struct xfrm_replay_state_esn *p, *pp, *up;
+	size_t klen, ulen;
 
 	if (!rta)
 		return 0;
 
 	up = nla_data(rta);
+	klen = xfrm_replay_state_esn_len(up);
+	ulen = nla_len(rta) > sizeof(*up) ? klen : sizeof(*up);
 
-	p = kmemdup(up, xfrm_replay_state_esn_len(up), GFP_KERNEL);
+	p = kzalloc(klen, GFP_KERNEL);
 	if (!p)
 		return -ENOMEM;
 
-	pp = kmemdup(up, xfrm_replay_state_esn_len(up), GFP_KERNEL);
+	pp = kzalloc(klen, GFP_KERNEL);
 	if (!pp) {
 		kfree(p);
 		return -ENOMEM;
 	}
 
+	memcpy(p, up, ulen);
+	memcpy(pp, up, ulen);
+
 	*replay_esn = p;
 	*preplay_esn = pp;
 
-- 
1.7.10.4
