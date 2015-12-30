From: "Grumbach, Emmanuel" <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH RESEND] iwlwifi:Fix error handling in the function
 iwl_pcie_enqueue_hcmd
Date: Wed, 30 Dec 2015 17:35:05 +0000
Message-ID: <0BA3FCBA62E2DC44AF3030971E174FB32E973388@hasmsx107.ger.corp.intel.com>
References: <1451495694-28740-1-git-send-email-xerofoify@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: linuxwifi <linuxwifi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org" <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	"Erenfeld, Aviya" <aviya.erenfeld-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"Dreyfuss, Haim" <haim.dreyfuss-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"Peer, Ilan" <ilan.peer-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"Altman, Avri" <avri.altman-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Nicholas Krause <xerofoify-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Berg, Johannes" <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Language: en-US
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,


On 12/30/2015 07:15 PM, Nicholas Krause wrote:
> This fixes error handling in the function iwl_pcie_enqueue_hcmd
> by checking if all calls to the function wl_pcie_txq_build_tfd
> have failed by returning a error code and if so jump to the goto
> label out from the cleaning up of acquired resources before


For sure you haven't ran your code otherwise you would have noticed it
break pretty much everything.
Moreover this patch is not based on my -next tree.
Simple rebasing won't fix the obvious issues in your patch though.

> Signed-off-by: Nicholas Krause <xerofoify-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
>  drivers/net/wireless/iwlwifi/pcie/tx.c | 27 +++++++++++++++++----------
>  1 file changed, 17 insertions(+), 10 deletions(-)
>
> diff --git a/drivers/net/wireless/iwlwifi/pcie/tx.c b/drivers/net/wireless/iwlwifi/pcie/tx.c
> index 2b86c21..49c8c77 100644
> --- a/drivers/net/wireless/iwlwifi/pcie/tx.c
> +++ b/drivers/net/wireless/iwlwifi/pcie/tx.c
> @@ -1472,9 +1472,11 @@ static int iwl_pcie_enqueue_hcmd(struct iwl_trans *trans,
>  	/* start the TFD with the scratchbuf */
>  	scratch_size = min_t(int, copy_size, IWL_HCMD_SCRATCHBUF_SIZE);
>  	memcpy(&txq->scratchbufs[q->write_ptr], &out_cmd->hdr, scratch_size);
> -	iwl_pcie_txq_build_tfd(trans, txq,
> -			       iwl_pcie_get_scratchbuf_dma(txq, q->write_ptr),
> -			       scratch_size, true);
> +	idx = iwl_pcie_txq_build_tfd(trans, txq,
> +				     iwl_pcie_get_scratchbuf_dma(txq, q->write_ptr),
> +				     scratch_size, true);
> +	if (idx)
> +		goto out;
>  
>  	/* map first command fragment, if any remains */
>  	if (copy_size > scratch_size) {
> @@ -1489,8 +1491,9 @@ static int iwl_pcie_enqueue_hcmd(struct iwl_trans *trans,
>  			goto out;
>  		}
>  
> -		iwl_pcie_txq_build_tfd(trans, txq, phys_addr,
> -				       copy_size - scratch_size, false);
> +		idx = iwl_pcie_txq_build_tfd(trans, txq, phys_addr, copy_size - scratch_size, false);
> +		if (idx)
> +			goto out;
>  	}
>  
>  	/* map the remaining (adjusted) nocopy/dup fragments */
> @@ -1513,7 +1516,9 @@ static int iwl_pcie_enqueue_hcmd(struct iwl_trans *trans,
>  			goto out;
>  		}
>  
> -		iwl_pcie_txq_build_tfd(trans, txq, phys_addr, cmdlen[i], false);
> +		idx = iwl_pcie_txq_build_tfd(trans, txq, phys_addr, cmdlen[i], false);
> +		if (idx)
> +			goto out;
>  	}
>  
>  	out_meta->flags = cmd->flags;
> @@ -1830,8 +1835,8 @@ int iwl_trans_pcie_tx(struct iwl_trans *trans, struct sk_buff *skb,
>  	/* The first TB points to the scratchbuf data - min_copy bytes */
>  	memcpy(&txq->scratchbufs[q->write_ptr], &dev_cmd->hdr,
>  	       IWL_HCMD_SCRATCHBUF_SIZE);
> -	iwl_pcie_txq_build_tfd(trans, txq, tb0_phys,
> -			       IWL_HCMD_SCRATCHBUF_SIZE, true);
> +	if (iwl_pcie_txq_build_tfd(trans, txq, tb0_phys, IWL_HCMD_SCRATCHBUF_SIZE, true))
> +			goto out_err;
>  
>  	/* there must be data left over for TB1 or this code must be changed */
>  	BUILD_BUG_ON(sizeof(struct iwl_tx_cmd) < IWL_HCMD_SCRATCHBUF_SIZE);
> @@ -1841,7 +1846,8 @@ int iwl_trans_pcie_tx(struct iwl_trans *trans, struct sk_buff *skb,
>  	tb1_phys = dma_map_single(trans->dev, tb1_addr, tb1_len, DMA_TO_DEVICE);
>  	if (unlikely(dma_mapping_error(trans->dev, tb1_phys)))
>  		goto out_err;
> -	iwl_pcie_txq_build_tfd(trans, txq, tb1_phys, tb1_len, false);
> +	if (iwl_pcie_txq_build_tfd(trans, txq, tb1_phys, tb1_len, false))
> +			goto out_err;
>  
>  	/*
>  	 * Set up TFD's third entry to point directly to remainder
> @@ -1857,7 +1863,8 @@ int iwl_trans_pcie_tx(struct iwl_trans *trans, struct sk_buff *skb,
>  					   &txq->tfds[q->write_ptr]);
>  			goto out_err;
>  		}
> -		iwl_pcie_txq_build_tfd(trans, txq, tb2_phys, tb2_len, false);
> +		if (iwl_pcie_txq_build_tfd(trans, txq, tb2_phys, tb2_len, false))
> +			goto out_err;
>  	}
>  
>  	/* Set up entry for this TFD in Tx byte-count array */

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
