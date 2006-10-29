From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6.18 forcedeth GSO panic on send
Date: Mon, 30 Oct 2006 01:10:29 +1100
Message-ID: <20061029141029.GA5084@gondor.apana.org.au>
References: <200610270117.57877.vda.linux@googlemail.com> <20061027035858.GA11129@gondor.apana.org.au> <200610291355.56196.vda.linux@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Manfred Spraul <manfred@colorfullife.com>,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:61453 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S965250AbWJ2OLG
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Oct 2006 09:11:06 -0500
To: Denis Vlasenko <vda.linux@googlemail.com>
Content-Disposition: inline
In-Reply-To: <200610291355.56196.vda.linux@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Oct 29, 2006 at 01:55:56PM +0100, Denis Vlasenko wrote:
> 
> With "echo 1 >/proc/sys/kernel/panic_on_oops" I've got
> what you're requested. See screenshot:
> 
> http://busybox.net/~vda/gso_panic/forcedeth_gso_panic2.jpg

Thanks!

Please let me know if this patch fixes it:

[NET]: Fix segmentation of linear packets

skb_segment fails to segment linear packets correctly because it
tries to write all linear parts of the original skb into each
segment.  This will always panic as each segment only contains
enough space for one MSS.

This was not detected earlier because linear packets should be
rare for GSO.  In fact it still remains to be seen what exactly
created the linear packets that triggered this bug.  Basically
the only time this should happen is if someone enables GSO
emulation on an interface that does not support SG.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

The fact that you're triggering this bug at all means that
something else has gone wrong.  First of all your picture
shows a device setting of "lo".  This does not tally with
the fact that the BUG was triggered by ssh.  Do you have
any idea why this is the case? Do you have any netfilter
rules that might cause this?

If it is indeed lo, could you please check the ethtool -k
setting on it? Also what is the ethtool -k setting on the
interface where you expect ssh to go out?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 3c23760..f735455 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1946,7 +1946,7 @@ struct sk_buff *skb_segment(struct sk_bu
 	do {
 		struct sk_buff *nskb;
 		skb_frag_t *frag;
-		int hsize, nsize;
+		int hsize;
 		int k;
 		int size;
 
@@ -1957,11 +1957,10 @@ struct sk_buff *skb_segment(struct sk_bu
 		hsize = skb_headlen(skb) - offset;
 		if (hsize < 0)
 			hsize = 0;
-		nsize = hsize + doffset;
-		if (nsize > len + doffset || !sg)
-			nsize = len + doffset;
+		if (hsize > len || !sg)
+			hsize = len;
 
-		nskb = alloc_skb(nsize + headroom, GFP_ATOMIC);
+		nskb = alloc_skb(hsize + doffset + headroom, GFP_ATOMIC);
 		if (unlikely(!nskb))
 			goto err;
 
