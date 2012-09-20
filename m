From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH v3 5/7] xfrm_user: ensure user supplied esn replay window is valid
Date: Thu, 20 Sep 2012 22:01:49 +0200
Message-ID: <1348171309-9029-1-git-send-email-minipli@googlemail.com>
References: <1348090423-32665-1-git-send-email-minipli@googlemail.com> <1348090423-32665-6-git-send-email-minipli@googlemail.com> <1348094309.2636.80.camel@bwh-desktop.uk.solarflarecom.com> <CA+rthh8Q464Jw5okH5aXds0QZztay9dpcyniahtWFxev8tpN9w@mail.gmail.com> <20120920070508.GA4221@secunet.com>
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Mathias Krause <minipli@googlemail.com>,
	Martin Willi <martin@revosec.ch>,
	Ben Hutchings <bhutchings@solarflare.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120920070508.GA4221@secunet.com>
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
bitmap with zero, for the latter we copy the user supplied bitmap. For
state updates the full bitmap must be supplied.

To prevent overflows in the bitmap length calculation the maximum size
of bmp_len is limited to 128 by this patch -- resulting in a maximum
replay window of 4096 packets. This should be sufficient for all real
life scenarios (RFC 4303 recommends a default replay window size of 64).

Cc: Steffen Klassert <steffen.klassert@secunet.com>
Cc: Martin Willi <martin@revosec.ch>
Cc: Ben Hutchings <bhutchings@solarflare.com>
Signed-off-by: Mathias Krause <minipli@googlemail.com>
---
v3:
- revert size_t change to xfrm_replay_state_esn_len() (requested by Steffen)
- switch to int types for lengths (suggested by Ben)
- implement 4096 packets limit for bmp_len to avoid overflows in
  xfrm_replay_state_esn_len()
v2:
- compare against klen in xfrm_alloc_replay_state_esn (suggested by Ben)
- make xfrm_replay_state_esn_len() return size_t

 include/linux/xfrm.h |    2 ++
 net/xfrm/xfrm_user.c |   31 +++++++++++++++++++++++++------
 2 files changed, 27 insertions(+), 6 deletions(-)

diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
index 22e61fd..28e493b 100644
--- a/include/linux/xfrm.h
+++ b/include/linux/xfrm.h
@@ -84,6 +84,8 @@ struct xfrm_replay_state {
 	__u32	bitmap;
 };
 
+#define XFRMA_REPLAY_ESN_MAX	4096
+
 struct xfrm_replay_state_esn {
 	unsigned int	bmp_len;
 	__u32		oseq;
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 9f1e749..e761562 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -123,9 +123,21 @@ static inline int verify_replay(struct xfrm_usersa_info *p,
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
+
+		if (rs->bmp_len > XFRMA_REPLAY_ESN_MAX / sizeof(rs->bmp[0]) / 8)
+			return -EINVAL;
+
+		if (nla_len(rt) < xfrm_replay_state_esn_len(rs) &&
+		    nla_len(rt) != sizeof(*rs))
+			return -EINVAL;
+	}
 
 	if (!rt)
 		return 0;
@@ -370,14 +382,15 @@ static inline int xfrm_replay_verify_len(struct xfrm_replay_state_esn *replay_es
 					 struct nlattr *rp)
 {
 	struct xfrm_replay_state_esn *up;
+	int ulen;
 
 	if (!replay_esn || !rp)
 		return 0;
 
 	up = nla_data(rp);
+	ulen = xfrm_replay_state_esn_len(up);
 
-	if (xfrm_replay_state_esn_len(replay_esn) !=
-			xfrm_replay_state_esn_len(up))
+	if (nla_len(rp) < ulen || xfrm_replay_state_esn_len(replay_esn) != ulen)
 		return -EINVAL;
 
 	return 0;
@@ -388,22 +401,28 @@ static int xfrm_alloc_replay_state_esn(struct xfrm_replay_state_esn **replay_esn
 				       struct nlattr *rta)
 {
 	struct xfrm_replay_state_esn *p, *pp, *up;
+	int klen, ulen;
 
 	if (!rta)
 		return 0;
 
 	up = nla_data(rta);
+	klen = xfrm_replay_state_esn_len(up);
+	ulen = nla_len(rta) >= klen ? klen : sizeof(*up);
 
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
