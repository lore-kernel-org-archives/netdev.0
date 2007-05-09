From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: linkwatch bustage in git-net
Date: Wed, 9 May 2007 15:45:58 +1000
Message-ID: <20070509054558.GA1184@gondor.apana.org.au>
References: <20070508222033.4e57a580.akpm@linux-foundation.org> <20070509053154.GA850@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4758 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933506AbXEIFqF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2007 01:46:05 -0400
Content-Disposition: inline
In-Reply-To: <20070509053154.GA850@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 09, 2007 at 03:31:55PM +1000, Herbert Xu wrote:
> 
> Hmm, I don't see it here (probably because we use different NICs).
> But does this help?

Thinking about it again I don't think it will help you because if your
carrier started out as off then it would've been considered an urgent
event anyway.

So what NIC are you using? And where abouts in the boot process is it
hanging? For exmaple, is it hanging when obtaining a DHCP address?

In any case, this patch can't hurt.  So here's one with a changelog:

[NET] link_watch: Eliminate potential delay on wrap-around

When the jiffies wrap around or when the system boots up for the first
time, down events can be delayed indefinitely since we no longer update
linkwatch_nextevent when only urgent events are processed.

This patch fixes this by setting linkwatch_nextevent when a wrap-around
occurs.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/core/link_watch.c b/net/core/link_watch.c
index b5f4579..4674ae5 100644
--- a/net/core/link_watch.c
+++ b/net/core/link_watch.c
@@ -101,8 +101,10 @@ static void linkwatch_schedule_work(unsigned long delay)
 		return;
 
 	/* If we wrap around we'll delay it by at most HZ. */
-	if (delay > HZ)
+	if (delay > HZ) {
+		linkwatch_nextevent = jiffies;
 		delay = 0;
+	}
 
 	schedule_delayed_work(&linkwatch_work, delay);
 }
