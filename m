From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 0/1] mv643xx_eth: Disable TSO by default
Date: Sat, 01 Nov 2014 10:37:33 -0700
Message-ID: <1414863453.31792.8.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1414855820-15094-1-git-send-email-ezequiel.garcia@free-electrons.com>
	 <1414862766.31792.7.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Lior Amsalem <alior@marvell.com>,
	Nadav Haklai <nadavh@marvell.com>
To: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:41802 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752499AbaKARhg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Nov 2014 13:37:36 -0400
Received: by mail-ig0-f172.google.com with SMTP id a13so2644727igq.11
        for <netdev@vger.kernel.org>; Sat, 01 Nov 2014 10:37:35 -0700 (PDT)
In-Reply-To: <1414862766.31792.7.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-11-01 at 10:26 -0700, Eric Dumazet wrote:
> On Sat, 2014-11-01 at 12:30 -0300, Ezequiel Garcia wrote:
> > Several users ([1], [2]) have been reporting data corruption with TSO on
> > Kirkwood platforms (i.e. using the mv643xx_eth driver).
> > 
> > Until we manage to find what's causing this, this simple patch will make
> > the TSO path disabled by default. This patch should be queued for stable,
> > fixing the TSO feature introduced in v3.16.
> > 
> > The corruption itself is very easy to reproduce: checking md5sum on a mounted
> > NFS directory gives a different result each time. Same tests using the mvneta
> > driver (Armada 370/38x/XP SoC) pass with no issues.
> > 
> > Frankly, I'm a bit puzzled about this, and so any ideas or debugging hints
> > are well received.
> 
> lack of barriers maybe ?
> 
> It seems you might need to populate all TX descriptors but delay the
> first, like doing the populate in descending order.
> 
> If you take a look at txq_submit_skb(), you'll see the final
> desc->cmd_sts = cmd_sts (line 959) is done _after_ frags were cooked by
> txq_submit_frag_skb()
> 
> You should kick the nick only when all TX descriptors are ready and
> committed to memory.
> 

Untested patch would be :

diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index b151a949f352a20ec8e74b4f3a7b6bb194ce841c..44789cc9a263992f91e46006d7e12703a2824cb4 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -773,7 +773,8 @@ txq_put_data_tso(struct net_device *dev, struct tx_queue *txq,
 }
 
 static inline void
-txq_put_hdr_tso(struct sk_buff *skb, struct tx_queue *txq, int length)
+txq_put_hdr_tso(struct sk_buff *skb, struct tx_queue *txq, int length,
+		struct tx_desc **pdesc, u32 *cmd)
 {
 	struct mv643xx_eth_private *mp = txq_to_mp(txq);
 	int hdr_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
@@ -797,9 +798,13 @@ txq_put_hdr_tso(struct sk_buff *skb, struct tx_queue *txq, int length)
 	desc->byte_cnt = hdr_len;
 	desc->buf_ptr = txq->tso_hdrs_dma +
 			txq->tx_curr_desc * TSO_HEADER_SIZE;
-	desc->cmd_sts = cmd_csum | BUFFER_OWNED_BY_DMA  | TX_FIRST_DESC |
-				   GEN_CRC;
-
+	cmd_csum |= BUFFER_OWNED_BY_DMA  | TX_FIRST_DESC | GEN_CRC;
+	if (*pdesc == NULL) {
+		*pdesc = desc;
+		*cmd = cmd_csum;
+	} else {
+		desc->cmd_sts = cmd_csum;
+	}
 	txq->tx_curr_desc++;
 	if (txq->tx_curr_desc == txq->tx_ring_size)
 		txq->tx_curr_desc = 0;
@@ -813,6 +818,8 @@ static int txq_submit_tso(struct tx_queue *txq, struct sk_buff *skb,
 	int desc_count = 0;
 	struct tso_t tso;
 	int hdr_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
+	struct tx_desc *desc = NULL;
+	u32 cmd_sts = 0;
 
 	/* Count needed descriptors */
 	if ((txq->tx_desc_count + tso_count_descs(skb)) >= txq->tx_ring_size) {
@@ -834,7 +841,7 @@ static int txq_submit_tso(struct tx_queue *txq, struct sk_buff *skb,
 		/* prepare packet headers: MAC + IP + TCP */
 		hdr = txq->tso_hdrs + txq->tx_curr_desc * TSO_HEADER_SIZE;
 		tso_build_hdr(skb, hdr, &tso, data_left, total_len == 0);
-		txq_put_hdr_tso(skb, txq, data_left);
+		txq_put_hdr_tso(skb, txq, data_left, &desc, &cmd_sts);
 
 		while (data_left > 0) {
 			int size;
@@ -854,6 +861,10 @@ static int txq_submit_tso(struct tx_queue *txq, struct sk_buff *skb,
 	__skb_queue_tail(&txq->tx_skb, skb);
 	skb_tx_timestamp(skb);
 
+	/* ensure all other descriptors are written before first cmd_sts */
+	wmb();
+	desc->cmd_sts = cmd_sts;
+
 	/* clear TX_END status */
 	mp->work_tx_end &= ~(1 << txq->index);
 
