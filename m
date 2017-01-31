From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH net-next 10/10] bnxt_en: Add support for XDP_TX action.
Date: Mon, 30 Jan 2017 21:27:27 -0800
Message-ID: <20170130212727.69e9b646@cakuba>
References: <1485827375-20421-1-git-send-email-michael.chan@broadcom.com>
        <1485827375-20421-11-git-send-email-michael.chan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Michael Chan <michael.chan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.wp.pl ([212.77.101.12]:22651 "EHLO mx4.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750758AbdAaF1t (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 31 Jan 2017 00:27:49 -0500
In-Reply-To: <1485827375-20421-11-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 30 Jan 2017 20:49:35 -0500, Michael Chan wrote:
> +static int bnxt_xmit_xdp(struct bnxt *bp, struct bnxt_napi *bnapi,
> +			 struct page *page, dma_addr_t mapping, u32 offset,
> +			 u32 len)
> +{
> +	struct bnxt_tx_ring_info *txr = bnapi->tx_ring;
> +	struct bnxt_sw_tx_bd *tx_buf;
> +	struct tx_bd_ext *txbd1;
> +	struct tx_bd *txbd;
> +	u32 flags;
> +	u16 prod;
> +
> +	if (bnxt_tx_avail(bp, txr) < 2)
> +		return -ENOSPC;
> +
> +	prod = txr->tx_prod;
> +	txbd = &txr->tx_desc_ring[TX_RING(prod)][TX_IDX(prod)];
> +
> +	tx_buf = &txr->tx_buf_ring[prod];
> +	tx_buf->page = page;
> +	dma_unmap_addr_set(tx_buf, mapping, mapping);
> +	flags = (len << TX_BD_LEN_SHIFT) | TX_BD_TYPE_LONG_TX_BD |
> +		(2 << TX_BD_FLAGS_BD_CNT_SHIFT) | TX_BD_FLAGS_PACKET_END |
> +		bnxt_lhint_arr[len >> 9];
> +	txbd->tx_bd_len_flags_type = cpu_to_le32(flags);
> +	txbd->tx_bd_opaque = prod;
> +	txbd->tx_bd_haddr = cpu_to_le64(mapping + offset);
> +
> +	prod = NEXT_TX(prod);
> +	txbd1 = (struct tx_bd_ext *)
> +		&txr->tx_desc_ring[TX_RING(prod)][TX_IDX(prod)];
> +
> +	txbd1->tx_bd_hsize_lflags = cpu_to_le32(0);
> +	txbd1->tx_bd_mss = cpu_to_le32(0);
> +	txbd1->tx_bd_cfa_action = cpu_to_le32(0);
> +	txbd1->tx_bd_cfa_meta = cpu_to_le32(0);
> +
> +	prod = NEXT_TX(prod);
> +	txr->tx_prod = prod;
> +	return 0;
> +}

Are you not lacking DMA syncs in general?  You map the buffers
bidirectionally, but I failed to find any dma_syncs.  I would expect
one before you run xdp and one before you TX because packet could have
been modified.  What am I missing?
