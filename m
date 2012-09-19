From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH 6/6] xfrm_user: don't copy esn replay window twice for new states
Date: Wed, 19 Sep 2012 23:33:43 +0200
Message-ID: <1348090423-32665-7-git-send-email-minipli@googlemail.com>
References: <1348090423-32665-1-git-send-email-minipli@googlemail.com>
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Mathias Krause <minipli@googlemail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1348090423-32665-1-git-send-email-minipli@googlemail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ESN replay window was already fully initialized in
xfrm_alloc_replay_state_esn(). No need to copy it again.

Cc: Steffen Klassert <steffen.klassert@secunet.com>
Signed-off-by: Mathias Krause <minipli@googlemail.com>
---
 net/xfrm/xfrm_user.c |    9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 7fd92b8..fa072de 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -457,10 +457,11 @@ static void copy_from_user_state(struct xfrm_state *x, struct xfrm_usersa_info *
  * somehow made shareable and move it to xfrm_state.c - JHS
  *
 */
-static void xfrm_update_ae_params(struct xfrm_state *x, struct nlattr **attrs)
+static void xfrm_update_ae_params(struct xfrm_state *x, struct nlattr **attrs,
+				  int update_esn)
 {
 	struct nlattr *rp = attrs[XFRMA_REPLAY_VAL];
-	struct nlattr *re = attrs[XFRMA_REPLAY_ESN_VAL];
+	struct nlattr *re = update_esn ? attrs[XFRMA_REPLAY_ESN_VAL] : NULL;
 	struct nlattr *lt = attrs[XFRMA_LTIME_VAL];
 	struct nlattr *et = attrs[XFRMA_ETIMER_THRESH];
 	struct nlattr *rt = attrs[XFRMA_REPLAY_THRESH];
@@ -570,7 +571,7 @@ static struct xfrm_state *xfrm_state_construct(struct net *net,
 		goto error;
 
 	/* override default values from above */
-	xfrm_update_ae_params(x, attrs);
+	xfrm_update_ae_params(x, attrs, 0);
 
 	return x;
 
@@ -1840,7 +1841,7 @@ static int xfrm_new_ae(struct sk_buff *skb, struct nlmsghdr *nlh,
 		goto out;
 
 	spin_lock_bh(&x->lock);
-	xfrm_update_ae_params(x, attrs);
+	xfrm_update_ae_params(x, attrs, 1);
 	spin_unlock_bh(&x->lock);
 
 	c.event = nlh->nlmsg_type;
-- 
1.7.10.4
