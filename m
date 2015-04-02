From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] xfrm: fix xfrm_input/xfrm_tunnel_check oops
Date: Thu, 2 Apr 2015 10:58:24 +0300
Message-ID: <20150402075824.GA2079@p183.telecom.by>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mike@normi.net, netdev@vger.kernel.org,
	steffen.klassert@secunet.com, herbert@gondor.apana.org.au
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:36886 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750771AbbDBH6Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 03:58:25 -0400
Received: by wiaa2 with SMTP id a2so95241192wia.0
        for <netdev@vger.kernel.org>; Thu, 02 Apr 2015 00:58:24 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
---

	Patch is in final testing, I'm sending it opportunistically.
	Mike, please chim in if this patch didn't help in the end!

 net/xfrm/xfrm_input.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

--- a/net/xfrm/xfrm_input.c
+++ a/net/xfrm/xfrm_input.c
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
