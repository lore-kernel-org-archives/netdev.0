From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH][PPPOL2TP]: Fix SMP oops in pppol2tp driver
Date: Mon, 25 Feb 2008 22:58:38 +0100
Message-ID: <20080225215837.GA3281@ami.dom.local>
References: <20080225133948.GC4733@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:43294 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753728AbYBYVx6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2008 16:53:58 -0500
Received: by nf-out-0910.google.com with SMTP id g13so921695nfb.21
        for <netdev@vger.kernel.org>; Mon, 25 Feb 2008 13:53:57 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080225133948.GC4733@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote, On 02/25/2008 02:39 PM:
...
> Hmm... Wait a minute! But on the other hand David has written about
> his cons here, and it looks reasonable: this place would be fixed,
> but some others can start reports like this. Maybe, it's better to
> analyze yet if it's really so hard to eliminate taking this lock
> on the xmit path?

James, I wonder if you could try to test this patch below?
ip_queue_xmit() seems to do proper things with __sk_dst_check(), and
if some other functions don't behave similarly lockdep should tell.
I think, you could test it with your "locks to _bh" patch (without
pppol2tp_xmit() part), and maybe with my sock.c lockdep patch (it
should help lockdep to see these locks a bit more distinctly).

Jarek P.

PS: Since ppp_generic isn't endangered for now I removed Paul from CC.

---

diff --git a/drivers/net/pppol2tp.c b/drivers/net/pppol2tp.c
index e0b072d..b94659a 100644
--- a/drivers/net/pppol2tp.c
+++ b/drivers/net/pppol2tp.c
@@ -1058,7 +1058,7 @@ static int pppol2tp_xmit(struct ppp_channel *chan, struct sk_buff *skb)
 
 	/* Get routing info from the tunnel socket */
 	dst_release(skb->dst);
-	skb->dst = sk_dst_get(sk_tun);
+	skb->dst = NULL;
 	skb_orphan(skb);
 	skb->sk = sk_tun;
 
