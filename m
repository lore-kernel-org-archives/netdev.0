From: cascardo@linux.vnet.ibm.com
Subject: Re: [PATCH] tg3: fix ring init when there are more TX than RX
 channels
Date: Tue, 25 Nov 2014 17:57:21 -0200
Message-ID: <20141125195721.GB3933@oc0812247204.br.ibm.com>
References: <1416932471-8744-1-git-send-email-cascardo@linux.vnet.ibm.com>
 <20141125.143352.669361329120151757.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, prashant@broadcom.com, mchan@broadcom.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp01.br.ibm.com ([32.104.18.85]:48586 "EHLO
	e24smtp01.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750991AbaKYT5a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 14:57:30 -0500
Received: from /spool/local
	by e24smtp01.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <cascardo@linux.vnet.ibm.com>;
	Tue, 25 Nov 2014 17:57:28 -0200
Received: from d24relay02.br.ibm.com (d24relay02.br.ibm.com [9.13.184.26])
	by d24dlp02.br.ibm.com (Postfix) with ESMTP id BF6EA1DC006A
	for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 14:56:30 -0500 (EST)
Received: from d24av05.br.ibm.com (d24av05.br.ibm.com [9.18.232.44])
	by d24relay02.br.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id sAPJvBJ055836868
	for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 17:57:12 -0200
Received: from d24av05.br.ibm.com (localhost [127.0.0.1])
	by d24av05.br.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id sAPJvLYc027226
	for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 14:57:21 -0500
Content-Disposition: inline
In-Reply-To: <20141125.143352.669361329120151757.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 25, 2014 at 02:33:52PM -0500, David Miller wrote:
> From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
> Date: Tue, 25 Nov 2014 14:21:11 -0200
> 
> > @@ -8563,7 +8563,8 @@ static int tg3_init_rings(struct tg3 *tp)
> >  		if (tnapi->rx_rcb)
> >  			memset(tnapi->rx_rcb, 0, TG3_RX_RCB_RING_BYTES(tp));
> >  
> > -		if (tg3_rx_prodring_alloc(tp, &tnapi->prodring)) {
> > +		if (tnapi->prodring.rx_std &&
> > +		    tg3_rx_prodring_alloc(tp, &tnapi->prodring)) {
> >  			tg3_free_rings(tp);
> >  			return -ENOMEM;
> 
> Maybe a better test is "i < tp->rxq_cnt"?  This is what is used in
> tg3_mem_rx_acquire() to determine if tg3_rx_prodring_init() happens.
> 

Well, what we have in net-next/master does:

	for (i = 0; i < limit; i++) {
		struct tg3_napi *tnapi = &tp->napi[i];

		if (tg3_rx_prodring_init(tp, &tnapi->prodring))
			goto err_out;

where limit is:

	limit = tp->rxq_cnt;

	if (tg3_flag(tp, ENABLE_RSS))
		limit++;

So, I thought that, instead of rewriting that same logic in
tg3_init_rings, that we should better just check that the rx_std has
been allocated, which is going to happen in tg3_rx_prodring_init.

So, the alternative would be:

 
diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index dbb41c19..51d45aa 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -8540,7 +8540,11 @@ static void tg3_free_rings(struct tg3 *tp)
  */
 static int tg3_init_rings(struct tg3 *tp)
 {
-	int i;
+	int i, limit;
+
+	limit = tp->rxq_cnt;
+	if (tg3_flag(tp, ENABLE_RSS))
+		limit++;
 
 	/* Free up all the SKBs. */
 	tg3_free_rings(tp);
@@ -8563,7 +8567,8 @@ static int tg3_init_rings(struct tg3 *tp)
 		if (tnapi->rx_rcb)
 			memset(tnapi->rx_rcb, 0, TG3_RX_RCB_RING_BYTES(tp));
 
-		if (tg3_rx_prodring_alloc(tp, &tnapi->prodring)) {
+		if (i < limit &&
+		    tg3_rx_prodring_alloc(tp, &tnapi->prodring)) {
 			tg3_free_rings(tp);
 			return -ENOMEM;
 		}
