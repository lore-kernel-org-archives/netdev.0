From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2 net-next 05/22] cxgb4: Add T5 write combining support
Date: Thu, 14 Mar 2013 16:30:16 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B718E@saturn3.aculab.com>
References: <1363273748-25330-1-git-send-email-vipul@chelsio.com> <1363273748-25330-6-git-send-email-vipul@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <roland@purestorage.com>,
	<JBottomley@parallels.com>, <dm@chelsio.com>,
	<swise@opengridcomputing.com>, <leedom@chelsio.com>,
	<naresh@chelsio.com>, <divy@chelsio.com>, <santosh@chelsio.com>,
	<arvindb@chelsio.com>, <abhishek@chelsio.com>
To: "Vipul Pandya" <vipul@chelsio.com>, <netdev@vger.kernel.org>,
	<linux-rdma@vger.kernel.org>, <linux-scsi@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:37177 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S933437Ab3CNQg7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Mar 2013 12:36:59 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 04908-10 for <netdev@vger.kernel.org>;
 Thu, 14 Mar 2013 16:36:56 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <1363273748-25330-6-git-send-email-vipul@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> This patch implements a low latency Write Combining (aka Write Coalescing) work
> request path. PCIE maps User Space Doorbell BAR2 region writes to the new
> interface to SGE. SGE pulls a new message from PCIE new interface and if its a
> coalesced write work request then pushes it for processing. This patch copies
> coalesced work request to memory mapped BAR2 space.
...
> +	} else {
> +		memset(data, 0, 2 * sizeof(u64));
> +		*data += 2;
> +	}

Using memset is overkill (or rather a big overhead if it isn't
detected by the compiler). Nothing wrong with:
		(*data)[0] = 0;
		(*data)[1] = 0;
		*data += 2;
Actually, typing that, I realise that you should probably have
read *data into a local variable, and then updated it when finished.
Otherwise some of the accesses might be ones which force the
compiler to reload the value.
		
>  static inline void ring_tx_db(struct adapter *adap, struct sge_txq *q, int n)
>  {
> +	unsigned int *wr, index;
> +
>  	wmb();            /* write descriptors before telling HW */
>  	spin_lock(&q->db_lock);
>  	if (!q->db_disabled) {
> -		t4_write_reg(adap, MYPF_REG(SGE_PF_KDOORBELL),
> -			     QID(q->cntxt_id) | PIDX(n));
> +		if (is_t4(adap->chip)) {
> +			t4_write_reg(adap, MYPF_REG(SGE_PF_KDOORBELL),
> +				     QID(q->cntxt_id) | PIDX(n));
> +		} else {
> +			if (n == 1) {
> +				index = q->pidx ? (q->pidx - 1) : (q->size - 1);
> +				wr = (unsigned int *)&q->desc[index];
> +				cxgb_pio_copy((u64 __iomem *)
> +					      (adap->bar2 + q->udb + 64),
> +					      (u64 *)wr);

Why all the casts on 'wr' ?

> +			} else
> +				writel(n,  adap->bar2 + q->udb + 8);
> +			wmb();

Since you actually need memory barriers here on x86 you definitely
need a comment saying so, and it would (IMHO) better to use a
different define in the source (even if it is currently converted
to wmb() in a local header file).

Thinking further, for portability you might want to find some way
of abstracting the multi-word writes somehow.
For example, some of the ppc have a dma engine associated with the
PCIe master interface that can be used to generate large TLP.
The code would still want to spin waiting for the dma to complete
(since the transfer would be far faster than any interrupt path).

	David
