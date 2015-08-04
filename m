From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: net: Fix skb_set_peeked use-after-free bug
Date: Tue, 4 Aug 2015 15:42:47 +0800
Message-ID: <20150804074247.GA29951@gondor.apana.org.au>
References: <CAMUH3-WyNR+2tsKgZ2qMNR=p+2Q3WDjcPrQcVSZfVSVyPA1qoA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	khlebnikov@yandex-team.ru
To: Brenden Blanco <bblanco@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:46910 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754990AbbHDHmx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2015 03:42:53 -0400
Content-Disposition: inline
In-Reply-To: <CAMUH3-WyNR+2tsKgZ2qMNR=p+2Q3WDjcPrQcVSZfVSVyPA1qoA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brenden Blanco <bblanco@plumgrid.com> wrote:
>> [  318.244596] BUG: unable to handle kernel NULL pointer dereference
>> at 000000000000008e
>> [  318.245182] IP: [<ffffffff81455e7c>] __skb_recv_datagram+0xbc/0x5a0
> 
> Replying to myself, and adding commit interested parties...
> 
> I went through the git log for the function in question, and
> positively identified that the following commit introduces the crash:
> 
> 738ac1e net: Clone skb before setting peeked flag
> 
> Null dereference is at line 224 of net/core/datagram.c (according to
> my objdump dis-assembly):

Sorry, brain fart on my part.  Please try this patch.

---8<---
The commit 738ac1ebb96d02e0d23bc320302a6ea94c612dec ("net: Clone
skb before setting peeked flag") introduced a use-after-free bug
in skb_recv_datagram.  This is because skb_set_peeked may create
a new skb and free the existing one.  As it stands the caller will
continue to use the old freed skb.

This patch fixes it by making skb_set_peeked return the new skb
(or the old one if unchanged).

Fixes: 738ac1ebb96d ("net: Clone skb before setting peeked flag")
Reported-by: Brenden Blanco <bblanco@plumgrid.com>
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/core/datagram.c b/net/core/datagram.c
index 4967262..617088a 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -131,12 +131,12 @@ out_noerr:
 	goto out;
 }
 
-static int skb_set_peeked(struct sk_buff *skb)
+static struct sk_buff *skb_set_peeked(struct sk_buff *skb)
 {
 	struct sk_buff *nskb;
 
 	if (skb->peeked)
-		return 0;
+		return skb;
 
 	/* We have to unshare an skb before modifying it. */
 	if (!skb_shared(skb))
@@ -144,7 +144,7 @@ static int skb_set_peeked(struct sk_buff *skb)
 
 	nskb = skb_clone(skb, GFP_ATOMIC);
 	if (!nskb)
-		return -ENOMEM;
+		return ERR_PTR(-ENOMEM);
 
 	skb->prev->next = nskb;
 	skb->next->prev = nskb;
@@ -157,7 +157,7 @@ static int skb_set_peeked(struct sk_buff *skb)
 done:
 	skb->peeked = 1;
 
-	return 0;
+	return skb;
 }
 
 /**
@@ -229,8 +229,9 @@ struct sk_buff *__skb_recv_datagram(struct sock *sk, unsigned int flags,
 					continue;
 				}
 
-				error = skb_set_peeked(skb);
-				if (error)
+				skb = skb_set_peeked(skb);
+				error = PTR_ERR(skb);
+				if (IS_ERR(skb))
 					goto unlock_err;
 
 				atomic_inc(&skb->users);
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
