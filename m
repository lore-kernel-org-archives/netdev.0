From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 1/2] xfrm: fix xfrm_input/xfrm_tunnel_check oops
Date: Thu, 9 Apr 2015 12:32:10 +0200
Message-ID: <1428575531-24870-2-git-send-email-steffen.klassert@secunet.com>
References: <1428575531-24870-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:43767 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932717AbbDIKc3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Apr 2015 06:32:29 -0400
In-Reply-To: <1428575531-24870-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>

https://bugzilla.kernel.org/show_bug.cgi?id=95211

Commit 70be6c91c86596ad2b60c73587880b47df170a41
("xfrm: Add xfrm_tunnel_skb_cb to the skb common buffer") added check
which dereferences ->outer_mode too early but larval SAs don't have
this pointer set (yet). So check for tunnel stuff later.

Mike Noordermeer reported this bug and patiently applied all the debugging.

Technically this is remote-oops-in-interrupt-context type of thing.

BUG: unable to handle kernel NULL pointer dereference at 0000000000000034
IP: [<ffffffff8150dca2>] xfrm_input+0x3c2/0x5a0
	...
[<ffffffff81500fc6>] ? xfrm4_esp_rcv+0x36/0x70
[<ffffffff814acc9a>] ? ip_local_deliver_finish+0x9a/0x200
[<ffffffff81471b83>] ? __netif_receive_skb_core+0x6f3/0x8f0
	...

RIP  [<ffffffff8150dca2>] xfrm_input+0x3c2/0x5a0
Kernel panic - not syncing: Fatal exception in interrupt

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_input.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index 85d1d47..526c4fe 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -238,11 +238,6 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 
 		skb->sp->xvec[skb->sp->len++] = x;
 
-		if (xfrm_tunnel_check(skb, x, family)) {
-			XFRM_INC_STATS(net, LINUX_MIB_XFRMINSTATEMODEERROR);
-			goto drop;
-		}
-
 		spin_lock(&x->lock);
 		if (unlikely(x->km.state == XFRM_STATE_ACQ)) {
 			XFRM_INC_STATS(net, LINUX_MIB_XFRMACQUIREERROR);
@@ -271,6 +266,11 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 
 		spin_unlock(&x->lock);
 
+		if (xfrm_tunnel_check(skb, x, family)) {
+			XFRM_INC_STATS(net, LINUX_MIB_XFRMINSTATEMODEERROR);
+			goto drop;
+		}
+
 		seq_hi = htonl(xfrm_replay_seqhi(x, seq));
 
 		XFRM_SKB_CB(skb)->seq.input.low = seq;
-- 
1.9.1
