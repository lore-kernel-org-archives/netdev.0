From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: net-2.6.22 UDP stalls/hangs
Date: Tue, 24 Apr 2007 10:04:58 +1000
Message-ID: <20070424000458.GA21838@gondor.apana.org.au>
References: <20070423151240.0e8cabed.akpm@linux-foundation.org> <20070423.151531.70219647.davem@davemloft.net> <20070423153714.71b9d99e.akpm@linux-foundation.org> <20070423.154509.116354989.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org, acme@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4027 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1030811AbXDXAFu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2007 20:05:50 -0400
Content-Disposition: inline
In-Reply-To: <20070423.154509.116354989.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 23, 2007 at 03:45:09PM -0700, David Miller wrote:
> 
> Either that or some error in Herbert's recent checksum offload
> handling changes, such as, in fact I am highly suspicious of
> the second change listed below, you may want to try reverting
> just that one:

Indeed.  My change depended on drivers correctly using csum_offset
instead of the old csum field.  That was wrong anyway since sparse
would now warn against that usage.  However, prior to my change it
was harmless.

[NETDRV]: Perform missing csum_offset conversions

When csum_offset was introduced we did a conversion from csum to
csum_offset where applicable.  A couple of drivers were missed in
this process.

It was harmless to begin with since the two fields coincided.  Now
that we've made them different with the addition of csum_start, the
missed drivers must be converted or they can't send packets out at
all that require checksum offload.
     
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/drivers/net/atl1/atl1_main.c b/drivers/net/atl1/atl1_main.c
index d60c221..4b1d4d1 100644
--- a/drivers/net/atl1/atl1_main.c
+++ b/drivers/net/atl1/atl1_main.c
@@ -1328,7 +1328,7 @@ static int atl1_tx_csum(struct atl1_adapter *adapter, struct sk_buff *skb,
 
 	if (likely(skb->ip_summed == CHECKSUM_PARTIAL)) {
 		cso = skb_transport_offset(skb);
-		css = cso + skb->csum;
+		css = cso + skb->csum_offset;
 		if (unlikely(cso & 0x1)) {
 			printk(KERN_DEBUG "%s: payload offset != even number\n",
 				atl1_driver_name);
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 610216e..48e2ade 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -2959,7 +2959,8 @@ e1000_tx_csum(struct e1000_adapter *adapter, struct e1000_tx_ring *tx_ring,
 
 		context_desc->lower_setup.ip_config = 0;
 		context_desc->upper_setup.tcp_fields.tucss = css;
-		context_desc->upper_setup.tcp_fields.tucso = css + skb->csum;
+		context_desc->upper_setup.tcp_fields.tucso =
+			css + skb->csum_offset;
 		context_desc->upper_setup.tcp_fields.tucse = 0;
 		context_desc->tcp_seg_setup.data = 0;
 		context_desc->cmd_and_length = cpu_to_le32(E1000_TXD_CMD_DEXT);
