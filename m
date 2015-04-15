From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: ip_tunnel: Remove gratuitous skb scrubbing
Date: Wed, 15 Apr 2015 21:57:39 +0800
Message-ID: <20150415135739.GA5534@gondor.apana.org.au>
References: <20150415100107.GA3655@gondor.apana.org.au>
 <552E3B7A.2040701@6wind.com>
 <20150415102229.GA3917@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	James Morris <jmorris@redhat.com>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:52610 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752593AbbDON5q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2015 09:57:46 -0400
Content-Disposition: inline
In-Reply-To: <20150415102229.GA3917@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 15, 2015 at 06:22:29PM +0800, Herbert Xu wrote:
>
> Yes this is better.  I'm currently auditing all the other bits
> that are cleared to see if there is anything else that we should
> preserve for tunneling.

OK the only other thing that we may wish to preserve is secmark.
James, can you confirm whether secmark should be preserved or
cleared for tunnels within the same name space? Up until December
2014 it was preserved but since then it has been cleared.

For the mark here is my final tested patch.

---8<---
Subject: skbuff: Do not scrub skb mark within the same name space

The commit ea23192e8e577dfc51e0f4fc5ca113af334edff9 ("tunnels:
harmonize cleanup done on skb on rx path") broke anyone trying to
use netfilter marking across IPv4 tunnels.  While most of the
fields that are cleared by skb_scrub_packet don't matter, the
netfilter mark must be preserved.

This patch rearranges skb_scurb_packet to preserve the mark field.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 3b6e583..a185427 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -4124,19 +4124,22 @@ EXPORT_SYMBOL(skb_try_coalesce);
  */
 void skb_scrub_packet(struct sk_buff *skb, bool xnet)
 {
-	if (xnet)
-		skb_orphan(skb);
 	skb->tstamp.tv64 = 0;
 	skb->pkt_type = PACKET_HOST;
 	skb->skb_iif = 0;
 	skb->ignore_df = 0;
 	skb_dst_drop(skb);
-	skb->mark = 0;
 	skb_sender_cpu_clear(skb);
 	skb_init_secmark(skb);
 	secpath_reset(skb);
 	nf_reset(skb);
 	nf_reset_trace(skb);
+
+	if (!xnet)
+		return;
+
+	skb_orphan(skb);
+	skb->mark = 0;
 }
 EXPORT_SYMBOL_GPL(skb_scrub_packet);
 
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
