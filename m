From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: GRO with non napi driver: BUG in __napi_complete
Date: Tue, 17 Mar 2009 18:22:44 +0800
Message-ID: <20090317102244.GB23396@gondor.apana.org.au>
References: <49BF60C9.1080100@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Frank Blaschka <blaschka@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:43455 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752392AbZCQKWt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 06:22:49 -0400
Content-Disposition: inline
In-Reply-To: <49BF60C9.1080100@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 17, 2009 at 09:35:21AM +0100, Frank Blaschka wrote:
>
> What is the intention process_backlog calls __napi_complete() instead of
> napi_complete(), this looks suspicious to me. Can anybody help?

You're absolutely right.  Dave, we need this fix for both net
and net-next.

gro: Fix legacy path napi_complete crash

On the legacy netif_rx path, I incorrectly tried to optimise
the napi_complete call by using __napi_complete before we reenable
IRQs.  This simply doesn't work since we need to flush the held
GRO packets first.

This patch fixes it by doing the obvious thing of reenabling
IRQs first and then calling napi_complete.

Reported-by: Frank Blaschka <blaschka@linux.vnet.ibm.com>
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/core/dev.c b/net/core/dev.c
index f112970..2565f6d 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2588,9 +2588,9 @@ static int process_backlog(struct napi_struct *napi, int quota)
 		local_irq_disable();
 		skb = __skb_dequeue(&queue->input_pkt_queue);
 		if (!skb) {
-			__napi_complete(napi);
 			local_irq_enable();
-			break;
+			napi_complete(napi);
+			goto out;
 		}
 		local_irq_enable();
 
@@ -2599,6 +2599,7 @@ static int process_backlog(struct napi_struct *napi, int quota)
 
 	napi_gro_flush(napi);
 
+out:
 	return work;
 }
 
Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
