From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/6] cxgb4: Enable congestion notification
 from SGE for IQs and FLs.
Date: Mon, 04 May 2015 16:12:21 -0400 (EDT)
Message-ID: <20150504.161221.2098479142600865443.davem@davemloft.net>
References: <1430756900-6086-1-git-send-email-hariprasad@chelsio.com>
	<1430756900-6086-3-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, nirranjan@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38808 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751869AbbEDUMX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 16:12:23 -0400
In-Reply-To: <1430756900-6086-3-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Mon,  4 May 2015 21:58:16 +0530

> Also changed the name of t4_hw.c:get_mps_bg_map() to t4_get_mps_bg_map()
> and make it an exported routine with a definition in cxgb4.h.
> 
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
> ---
>  drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |  3 ++-
>  drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 14 ++++++++------
>  drivers/net/ethernet/chelsio/cxgb4/sge.c        | 14 ++++++++++++--
>  drivers/net/ethernet/chelsio/cxgb4/t4_hw.c      |  6 +++---
>  drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h   |  2 ++
>  5 files changed, 27 insertions(+), 12 deletions(-)
> 
> diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
> index 524d110..b6fa958 100644
> --- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
> +++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
> @@ -1055,7 +1055,7 @@ int t4_mgmt_tx(struct adapter *adap, struct sk_buff *skb);
>  int t4_ofld_send(struct adapter *adap, struct sk_buff *skb);
>  int t4_sge_alloc_rxq(struct adapter *adap, struct sge_rspq *iq, bool fwevtq,
>  		     struct net_device *dev, int intr_idx,
> -		     struct sge_fl *fl, rspq_handler_t hnd);
> +		     struct sge_fl *fl, rspq_handler_t hnd, int cong);
>  int t4_sge_alloc_eth_txq(struct adapter *adap, struct sge_eth_txq *txq,
>  			 struct net_device *dev, struct netdev_queue *netdevq,
>  			 unsigned int iqid);
> @@ -1215,6 +1215,7 @@ int t4_mc_read(struct adapter *adap, int idx, u32 addr, __be32 *data,
>  	       u64 *parity);
>  int t4_edc_read(struct adapter *adap, int idx, u32 addr, __be32 *data,
>  		u64 *parity);
> +unsigned int t4_get_mps_bg_map(struct adapter *adapter, int idx);
>  void t4_pmtx_get_stats(struct adapter *adap, u32 cnt[], u64 cycles[]);
>  void t4_pmrx_get_stats(struct adapter *adap, u32 cnt[], u64 cycles[]);
>  int t4_read_cim_ibq(struct adapter *adap, unsigned int qid, u32 *data,
> diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
> index 803d91b..83cfded 100644
> --- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
> +++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
> @@ -977,7 +977,7 @@ static int alloc_ofld_rxqs(struct adapter *adap, struct sge_ofld_rxq *q,
>  		err = t4_sge_alloc_rxq(adap, &q->rspq, false,
>  				       adap->port[i / per_chan],
>  				       msi_idx, q->fl.size ? &q->fl : NULL,
> -				       uldrx_handler);
> +				       uldrx_handler, 0);
>  		if (err)
>  			return err;
>  		memset(&q->stats, 0, sizeof(q->stats));
> @@ -1007,7 +1007,7 @@ static int setup_sge_queues(struct adapter *adap)
>  		msi_idx = 1;         /* vector 0 is for non-queue interrupts */
>  	else {
>  		err = t4_sge_alloc_rxq(adap, &s->intrq, false, adap->port[0], 0,
> -				       NULL, NULL);
> +				       NULL, NULL, -1);
>  		if (err)
>  			return err;
>  		msi_idx = -((int)s->intrq.abs_id + 1);
> @@ -1027,7 +1027,7 @@ static int setup_sge_queues(struct adapter *adap)
>  	 *    new/deleted queues.
>  	 */
>  	err = t4_sge_alloc_rxq(adap, &s->fw_evtq, true, adap->port[0],
> -			       msi_idx, NULL, fwevtq_handler);
> +			       msi_idx, NULL, fwevtq_handler, -1);
>  	if (err) {
>  freeout:	t4_free_sge_resources(adap);
>  		return err;
> @@ -1042,9 +1042,11 @@ freeout:	t4_free_sge_resources(adap);
>  		for (j = 0; j < pi->nqsets; j++, q++) {
>  			if (msi_idx > 0)
>  				msi_idx++;
> -			err = t4_sge_alloc_rxq(adap, &q->rspq, false, dev,
> -					       msi_idx, &q->fl,
> -					       t4_ethrx_handler);
> +			err = t4_sge_alloc_rxq
> +					(adap, &q->rspq, false, dev,
> +					 msi_idx, &q->fl,
> +					 t4_ethrx_handler,
> +					 t4_get_mps_bg_map(adap, pi->tx_chan));

Please don't malign a function call in this way, you must keep the opennening
parenthesis on the same line as the function name itself.  Then split up the
arguments as necessary to abide by the maximum column rules.

> -		c.iqns_to_fl0congen = htonl(FW_IQ_CMD_FL0PACKEN_F |
> +		c.iqns_to_fl0congen |= htonl(FW_IQ_CMD_FL0PACKEN_F |
>  					    FW_IQ_CMD_FL0FETCHRO_F |
>  					    FW_IQ_CMD_FL0DATARO_F |
>  					    FW_IQ_CMD_FL0PADEN_F);

If you change where the openning parenthesis is on the first line, you must
reindent the subsequent lines so that they start precisely at the first
column after that openning parenthesis.
