From: <ilant@mellanox.com>
Subject: [PATCH net-next] xfrm: Indicate xfrm_state offload errors
Date: Sun, 30 Apr 2017 16:51:19 +0300
Message-ID: <20170430135119.11159-1-ilant@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Ilan Tayari <ilant@mellanox.com>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve1eur01on0057.outbound.protection.outlook.com ([104.47.1.57]:54471
        "EHLO EUR01-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751290AbdD3Nv3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 30 Apr 2017 09:51:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ilan Tayari <ilant@mellanox.com>

Current code silently ignores driver errors when configuring
IPSec offload xfrm_state, and falls back to host-based crypto.

Fail the xfrm_state creation if the driver has an error, because
the NIC offloading was explicitly requested by the user program.

This will communicate back to the user that there was an error.

Fixes: d77e38e612a0 ("xfrm: Add an IPsec hardware offloading API")
Signed-off-by: Ilan Tayari <ilant@mellanox.com>
---
 net/xfrm/xfrm_user.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index ba74e5eeeeef..c4cceddac9db 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -595,9 +595,12 @@ static struct xfrm_state *xfrm_state_construct(struct net *net,
 			goto error;
 	}
 
-	if (attrs[XFRMA_OFFLOAD_DEV] &&
-	    xfrm_dev_state_add(net, x, nla_data(attrs[XFRMA_OFFLOAD_DEV])))
-		goto error;
+	if (attrs[XFRMA_OFFLOAD_DEV]) {
+		err = xfrm_dev_state_add(net, x,
+					 nla_data(attrs[XFRMA_OFFLOAD_DEV]));
+		if (err)
+			goto error;
+	}
 
 	if ((err = xfrm_alloc_replay_state_esn(&x->replay_esn, &x->preplay_esn,
 					       attrs[XFRMA_REPLAY_ESN_VAL])))
-- 
2.11.0
