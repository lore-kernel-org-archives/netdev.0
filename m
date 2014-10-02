From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [patch 1/2 -next] cxgb4: clean up a type issue
Date: Thu, 2 Oct 2014 11:31:45 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D174A2E74@AcuExch.aculab.com>
References: <20141002112219.GA25606@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: 'Dan Carpenter' <dan.carpenter@oracle.com>,
	Hariprasad S <hariprasad@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:46257 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751192AbaJBLdm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2014 07:33:42 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 26448-03 for <netdev@vger.kernel.org>;
 Thu,  2 Oct 2014 12:33:33 +0100 (BST)
In-Reply-To: <20141002112219.GA25606@mwanda>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter
> The tx_desc struct hold 8 __be64 values.  The original code took a
> tx_desc pointer then casted it to an int pointer and then casted it to a
> u64 pointer.  It was confusing and triggered some static checker
> warnings.
> 
> I have changed the cxgb_pio_copy() to only take tx_desc pointers.  This
> isn't really a loss of flexibility because anything else was buggy to
> begin with.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
> index bb7851e..599cdfd 100644
> --- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
> +++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
> @@ -854,9 +854,10 @@ static void write_sgl(const struct sk_buff *skb, struct sge_txq *q,
>   * memory mapped BAR2 space(user space writes).
>   * For coalesced WR SGE, fetches data from the FIFO instead of from Host.
>   */
> -static void cxgb_pio_copy(u64 __iomem *dst, u64 *src)
> +static void cxgb_pio_copy(u64 __iomem *dst, struct tx_desc *desc)
>  {
> -	int count = 8;
> +	int count = sizeof(*desc) / sizeof(u64);
> +	u64 *src = (u64 *)desc;
> 
>  	while (count) {
>  		writeq(*src, dst);
> @@ -914,12 +915,11 @@ static inline void ring_tx_db(struct adapter *adap, struct sge_txq *q, int n)
>  			int index = (q->pidx
>  				     ? (q->pidx - 1)
>  				     : (q->size - 1));
> -			unsigned int *wr = (unsigned int *)&q->desc[index];
> +			struct tx_desc *desc = &q->desc[index];
> 
>  			cxgb_pio_copy((u64 __iomem *)
>  				      (adap->bar2 + q->udb +
> -				       SGE_UDB_WCDOORBELL),
> -				      (u64 *)wr);
> +				       SGE_UDB_WCDOORBELL), desc);

Why not put &q->desc[index] in the call itself.
And I can't help think there are better places to break the long line.
Getting it to the code below would be nice:
			cxgp_pio_copy(adap->bar2 + q->udb + SGE_UDB_WCDOORBELL,
					  q->desc + index);

	David

>  		} else {
>  			writel(val,  adap->bar2 + q->udb + SGE_UDB_KDOORBELL);
>  		}
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
