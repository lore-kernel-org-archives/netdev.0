From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next v3 1/2] cxgb4: Add PTP Hardware Clock (PHC)
 support
Date: Fri, 30 Jun 2017 15:44:53 +0200
Message-ID: <20170630134453.qsol3xwehq7pmfa7@localhost.localdomain>
References: <1498823276-21791-1-git-send-email-atul.gupta@chelsio.com>
 <1498823276-21791-2-git-send-email-atul.gupta@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, venkatesh@chelsio.com,
        ganeshgr@chelsio.com
To: Atul Gupta <atul.gupta@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:35319 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751560AbdF3No6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2017 09:44:58 -0400
Received: by mail-wr0-f193.google.com with SMTP id z45so39351110wrb.2
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2017 06:44:58 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1498823276-21791-2-git-send-email-atul.gupta@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Having the get-ts patch extra is fine, but still this one can and
should be broken down into 2 patches:

1. Transmit hardware SO_TIMESTAMPING
2. PHC support

Let me explain ...

On Fri, Jun 30, 2017 at 05:17:55PM +0530, Atul Gupta wrote:
> @@ -2475,18 +2485,69 @@ static int cxgb_ioctl(struct net_device *dev, struct ifreq *req, int cmd)
>  				   sizeof(pi->tstamp_config)))
>  			return -EFAULT;
>  
> -		switch (pi->tstamp_config.rx_filter) {
> -		case HWTSTAMP_FILTER_NONE:
> +		if (!is_t4(adapter->params.chip)) {
> +			switch (pi->tstamp_config.tx_type) {
> +			case HWTSTAMP_TX_OFF:
> +			case HWTSTAMP_TX_ON:
> +				break;
> +			default:
> +				return -ERANGE;
> +			}
> +

This is Tx HW SO_TIMESTAMPING stuff ...

> +void cxgb4_ptp_read_hwstamp(struct adapter *adapter, struct port_info *pi)
> +{
> +	struct skb_shared_hwtstamps *skb_ts = NULL;
> +	u64 tx_ts;
> +
> +	skb_ts = skb_hwtstamps(adapter->ptp_tx_skb);
> +
> +	tx_ts = t4_read_reg(adapter,
> +			    T5_PORT_REG(pi->port_id, MAC_PORT_TX_TS_VAL_LO));
> +
> +	tx_ts |= (u64)t4_read_reg(adapter,
> +				  T5_PORT_REG(pi->port_id,
> +					      MAC_PORT_TX_TS_VAL_HI)) << 32;
> +	skb_ts->hwtstamp = ns_to_ktime(tx_ts);
> +	skb_tstamp_tx(adapter->ptp_tx_skb, skb_ts);
> +	dev_kfree_skb_any(adapter->ptp_tx_skb);
> +	spin_lock(&adapter->ptp_lock);
> +	adapter->ptp_tx_skb = NULL;
> +	spin_unlock(&adapter->ptp_lock);
> +}

.. and this also.

> +static int cxgb4_ptp_adjfreq(struct ptp_clock_info *ptp, s32 ppb)
> +{
> +	struct adapter *adapter = (struct adapter *)container_of(ptp,
> +				   struct adapter, ptp_clock_info);
> +	struct fw_ptp_cmd c;
> +	int err;
> +
> +	memset(&c, 0, sizeof(c));
> +	c.op_to_portid = cpu_to_be32(FW_CMD_OP_V(FW_PTP_CMD) |
> +				     FW_CMD_REQUEST_F |
> +				     FW_CMD_WRITE_F |
> +				     FW_PTP_CMD_PORTID_V(0));
> +	c.retval_len16 = cpu_to_be32(FW_CMD_LEN16_V(sizeof(c) / 16));
> +	c.u.ts.sc = FW_PTP_SC_ADJ_FREQ;
> +	c.u.ts.sign = (ppb < 0) ? 1 : 0;
> +	if (ppb < 0)
> +		ppb = -ppb;
> +	c.u.ts.ppb = cpu_to_be32(ppb);
> +
> +	err = t4_wr_mbox(adapter, adapter->mbox, &c, sizeof(c), NULL);
> +	if (err < 0)
> +		dev_err(adapter->pdev_dev,
> +			"PTP: %s error %d\n", __func__, -err);
> +
> +	return err;
> +}

But this is PHC stuff ...

> +static const struct ptp_clock_info cxgb4_ptp_clock_info = {
> +	.owner          = THIS_MODULE,
> +	.name           = "cxgb4_clock",
> +	.max_adj        = MAX_PTP_FREQ_ADJ,
> +	.n_alarm        = 0,
> +	.n_ext_ts       = 0,
> +	.n_per_out      = 0,
> +	.pps            = 0,
> +	.adjfreq        = cxgb4_ptp_adjfreq,
> +	.adjtime        = cxgb4_ptp_adjtime,
> +	.gettime64      = cxgb4_ptp_gettime,
> +	.settime64      = cxgb4_ptp_settime,
> +	.enable         = cxgb4_ptp_enable,
> +};

... as is this.

I leave it to you to sort out the rest.

Logically SO_TIMESTAMPING and PHC are separate functionalities, and so
you should be able to separate them, one from the other.

As practical matter, it makes it *way* easier for me to review when the
series clearly divides these features into different patches.

Thanks,
Richard
