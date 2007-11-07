From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 13/24] [IPSEC]: Move x->outer_mode->output out of locked section
Date: Wed, 07 Nov 2007 22:08:29 +0800
Message-ID: <E1Ipla1-0001Hb-00@gondolin.me.apana.org.au>
References: <20071107140701.GA4685@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3563 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758612AbXKGOIt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 09:08:49 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPSEC]: Move x->outer_mode->output out of locked section

RO mode is the only one that requires a locked output function.  So it's
easier to move the lock into that function rather than requiring everyone
else to run under the lock.

In particular, this allows us to move the size check into the output
function without causing a potential dead-lock should the ICMP error
somehow hit the same SA on transmission.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/ipv6/xfrm6_mode_ro.c |    3 +++
 net/xfrm/xfrm_output.c   |    8 ++++----
 2 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/xfrm6_mode_ro.c b/net/ipv6/xfrm6_mode_ro.c
index a7bc8c6..4a01cb3 100644
--- a/net/ipv6/xfrm6_mode_ro.c
+++ b/net/ipv6/xfrm6_mode_ro.c
@@ -28,6 +28,7 @@
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/skbuff.h>
+#include <linux/spinlock.h>
 #include <linux/stringify.h>
 #include <linux/time.h>
 #include <net/ipv6.h>
@@ -53,7 +54,9 @@ static int xfrm6_ro_output(struct xfrm_state *x, struct sk_buff *skb)
 	__skb_pull(skb, hdr_len);
 	memmove(ipv6_hdr(skb), iph, hdr_len);
 
+	spin_lock_bh(&x->lock);
 	x->lastused = get_seconds();
+	spin_unlock_bh(&x->lock);
 
 	return 0;
 }
diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index 58d5a74..b1efdc8 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -53,6 +53,10 @@ int xfrm_output(struct sk_buff *skb)
 	}
 
 	do {
+		err = x->outer_mode->output(x, skb);
+		if (err)
+			goto error;
+
 		spin_lock_bh(&x->lock);
 		err = xfrm_state_check(x, skb);
 		if (err)
@@ -64,10 +68,6 @@ int xfrm_output(struct sk_buff *skb)
 				xfrm_replay_notify(x, XFRM_REPLAY_UPDATE);
 		}
 
-		err = x->outer_mode->output(x, skb);
-		if (err)
-			goto error;
-
 		x->curlft.bytes += skb->len;
 		x->curlft.packets++;
 
