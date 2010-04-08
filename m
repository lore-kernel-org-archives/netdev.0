From: Mark Brown <broonie@opensource.wolfsonmicro.com>
Subject: [PATCH] xfrm: Fix double dst_release() in xfrm_lookup() -EREMOTE case
Date: Thu,  8 Apr 2010 13:29:33 +0100
Message-ID: <1270729773-1758-1-git-send-email-broonie@opensource.wolfsonmicro.com>
Cc: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>,
	netdev@vger.kernel.org,
	Mark Brown <broonie@opensource.wolfsonmicro.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from opensource.wolfsonmicro.com ([80.75.67.52]:38899 "EHLO
	opensource2.wolfsonmicro.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753940Ab0DHM3g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 08:29:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 80c802 ("xfrm: cache bundles instead of policies for outgoing
flows") changed __xfrm_policy() to call dst_release() when returning
-EREMOTE. In the case where this is called from xfrm_lookup() a double
call to dst_release() would result due to the existing dst_release()
there. Remove the dst_release() in xfrm_lookup().

Signed-off-by: Mark Brown <broonie@opensource.wolfsonmicro.com>
---

I'm not sure if this is correct or not - there may a reference been
taken earlier in __xfrm_lookup() that's being dropped but I didn't spot
it.

 net/xfrm/xfrm_policy.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 7430ac2..f133036 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1881,7 +1881,6 @@ int xfrm_lookup(struct net *net, struct dst_entry **dst_p, struct flowi *fl,
 	int err = __xfrm_lookup(net, dst_p, fl, sk, flags);
 
 	if (err == -EREMOTE) {
-		dst_release(*dst_p);
 		*dst_p = NULL;
 		err = -EAGAIN;
 	}
-- 
1.7.0.3

