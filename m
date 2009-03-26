From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6.29 forcedeth hang W/O NAPI enabled
Date: Thu, 26 Mar 2009 11:36:58 +0800
Message-ID: <20090326033658.GA14592@gondor.apana.org.au>
References: <810119.61814.qm@web57701.mail.re3.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, berkley@cs.wustl.edu
To: adam_richter2004@yahoo.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:55382 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755562AbZCZDhI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 23:37:08 -0400
Content-Disposition: inline
In-Reply-To: <810119.61814.qm@web57701.mail.re3.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adam Richter <adam_richter2004@yahoo.com> wrote:
> 
> The patch you forwarded to me seems to work.  Thank you for bringing it
> to my attention.

Hi Adam:

Any chance you can test this patch instead of the previous one?

net: Fix netpoll lockup in legacy receive path

When I fixed the GRO crash in the legacy receive path I used
napi_complete to replace __napi_complete.  Unfortunately they're
not the same when NETPOLL is enabled, which may result in us
not calling __napi_complete at all.

What's more, we really do need to keep the __napi_complete call
within the IRQ-off section since in theory an IRQ can occur in
between and fill up the backlog to the maximum, causing us to
lock up.

This patch fixes this by essentially open-coding __napi_complete.

Note we no longer need the memory barrier because this function
is per-cpu.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/core/dev.c b/net/core/dev.c
index e3fe5c7..2a7f6b3 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2588,9 +2588,10 @@ static int process_backlog(struct napi_struct *napi, int quota)
 		local_irq_disable();
 		skb = __skb_dequeue(&queue->input_pkt_queue);
 		if (!skb) {
+			list_del(&napi->poll_list);
+			clear_bit(NAPI_STATE_SCHED, &napi->state);
 			local_irq_enable();
-			napi_complete(napi);
-			goto out;
+			break;
 		}
 		local_irq_enable();
 
@@ -2599,7 +2600,6 @@ static int process_backlog(struct napi_struct *napi, int quota)
 
 	napi_gro_flush(napi);
 
-out:
 	return work;
 }

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
