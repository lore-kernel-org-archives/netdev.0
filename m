From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] BUG: unable to handle kernel NULL pointer dereference
	at br_pass_frame_up
Date: Tue, 16 Mar 2010 11:00:02 +0800
Message-ID: <20100316030002.GA17632@gondor.apana.org.au>
References: <4B9C4A2F.8040203@fami-braun.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: michael-dev@fami-braun.de, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:57017 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932389Ab0CPDAJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Mar 2010 23:00:09 -0400
Content-Disposition: inline
In-Reply-To: <4B9C4A2F.8040203@fami-braun.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

michael-dev@fami-braun.de wrote:
>
> I'm currently using linux-next and have been running into an OOPs which
> I think might be caused by a patch submitted on 2010-02-27.

Thanks for the patch.  Next time please add a changelog and a
Sign-off so that it can be immediately integrated.

I've done this for you now.

From: Michael Braun <michael-dev@fami-braun.de>

bridge: Fix br_forward crash in promiscuous mode

It's a linux-next kernel from 2010-03-12 on an x86 system and it
OOPs in the bridge module in br_pass_frame_up (called by
br_handle_frame_finish) because brdev cannot be dereferenced (its set to
a non-null value).

Adding some BUG_ON statements revealed that
 BR_INPUT_SKB_CB(skb)->brdev == br-dev
(as set in br_handle_frame_finish first)
only holds until br_forward is called.
The next call to br_pass_frame_up then fails.

Digging deeper it seems that br_forward either frees the skb or passes
it to NF_HOOK which will in turn take care of freeing the skb. The same
is holds for br_pass_frame_ip. So it seems as if two independent skb
allocations are required. As far as I can see, commit
b33084be192ee1e347d98bb5c9e38a53d98d35e2 removed skb duplication and so
likely causes this crash. This crash does not happen on 2.6.33.

I've therefore modified br_forward the same way br_flood has been
modified so that the skb is not freed if skb0 is going to be used
and I can confirm that the attached patch resolves the issue for me.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index d61e6f7..8347916 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -19,6 +19,10 @@
 #include <linux/netfilter_bridge.h>
 #include "br_private.h"
 
+static int deliver_clone(struct net_bridge_port *prev, struct sk_buff *skb,
+			 void (*__packet_hook)(const struct net_bridge_port *p,
+					       struct sk_buff *skb));
+
 /* Don't forward packets to originating port or forwarding diasabled */
 static inline int should_deliver(const struct net_bridge_port *p,
 				 const struct sk_buff *skb)
@@ -94,14 +98,18 @@ void br_deliver(const struct net_bridge_port *to, struct sk_buff *skb)
 }
 
 /* called with rcu_read_lock */
-void br_forward(const struct net_bridge_port *to, struct sk_buff *skb)
+void br_forward(const struct net_bridge_port *to, struct sk_buff *skb, struct sk_buff *skb0)
 {
 	if (should_deliver(to, skb)) {
-		__br_forward(to, skb);
+		if (skb0)
+			deliver_clone(to, skb, __br_forward);
+		else
+			__br_forward(to, skb);
 		return;
 	}
 
-	kfree_skb(skb);
+	if (!skb0)
+		kfree_skb(skb);
 }
 
 static int deliver_clone(struct net_bridge_port *prev, struct sk_buff *skb,
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 53b3985..08a72e6 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -90,7 +90,7 @@ int br_handle_frame_finish(struct sk_buff *skb)
 
 	if (skb) {
 		if (dst)
-			br_forward(dst->dst, skb);
+			br_forward(dst->dst, skb, skb2);
 		else
 			br_flood_forward(br, skb, skb2);
 	}
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index fef0384..bfb8feb 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -252,7 +252,7 @@ extern void br_deliver(const struct net_bridge_port *to,
 		struct sk_buff *skb);
 extern int br_dev_queue_push_xmit(struct sk_buff *skb);
 extern void br_forward(const struct net_bridge_port *to,
-		struct sk_buff *skb);
+		struct sk_buff *skb, struct sk_buff *skb0);
 extern int br_forward_finish(struct sk_buff *skb);
 extern void br_flood_deliver(struct net_bridge *br, struct sk_buff *skb);
 extern void br_flood_forward(struct net_bridge *br, struct sk_buff *skb,

-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
