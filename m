From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Bugme-new] [Bug 13617] New: GRO:__napi_complete from
	net_rx_action crash
Date: Sat, 27 Jun 2009 09:49:00 +0800
Message-ID: <20090627014900.GA19639@gondor.apana.org.au>
References: <bug-13617-10286@http.bugzilla.kernel.org/> <20090625122915.eedcea39.akpm@linux-foundation.org> <4A4501D7.8050301@qlogic.com> <20090626.102458.96012087.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dhananjay.phadke@qlogic.com, akpm@linux-foundation.org,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org, amit.salecha@qlogic.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:46927 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754327AbZF0BtI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2009 21:49:08 -0400
Content-Disposition: inline
In-Reply-To: <20090626.102458.96012087.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 26, 2009 at 10:24:58AM -0700, David Miller wrote:
>
> >>> In net_rx_action, there is check if napi_disable_pending then call
> >>> __napi_complete.
> >>> In __napi_complete, there is BUG_ON(n->gro_list);
> >>> Which has hit in below bug dump.
> >>> Why __napi_complete is called from net_rx_action instead of napi_complete.
> >>> napi_complete flushes the gro list.

Indeed, it was an oversight.  Thanks for catching it!

gro: Flush GRO packets in napi_disable_pending path

When NAPI is disabled while we're in net_rx_action, we end up
calling __napi_complete without flushing GRO packets.  This is
a bug as it would cause the GRO packets to linger, of course it
also literally BUGs to catch error like this :)

This patch changes it to napi_complete, with the obligatory IRQ
reenabling.  This should be safe because we've only just disabled
IRQs and it does not materially affect the test conditions in
between.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/core/dev.c b/net/core/dev.c
index 60b5728..70c27e0 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2823,9 +2823,11 @@ static void net_rx_action(struct softirq_action *h)
 		 * move the instance around on the list at-will.
 		 */
 		if (unlikely(work == weight)) {
-			if (unlikely(napi_disable_pending(n)))
-				__napi_complete(n);
-			else
+			if (unlikely(napi_disable_pending(n))) {
+				local_irq_enable();
+				napi_complete(n);
+				local_irq_disable();
+			} else
 				list_move_tail(&n->poll_list, list);
 		}

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
