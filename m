From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH 2/2] tcp: cleanup tcp_try_coalesce
Date: Thu, 3 May 2012 13:07:27 -0400
Message-ID: <20120503170727.GM9285@tuxdriver.com>
References: <1336017985.12425.9.camel@edumazet-glaptop>
 <4FA21087.1080801@gmail.com>
 <1336022373.12425.24.camel@edumazet-glaptop>
 <20120503.012502.44731688706812861.davem@davemloft.net>
 <20120503151418.GJ9285@tuxdriver.com>
 <1336058659.27487.80.camel@wwguy-huron>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	alexander.duyck@gmail.com, alexander.h.duyck@intel.com,
	netdev@vger.kernel.org, edumazet@google.com,
	jeffrey.t.kirsher@intel.com, linux-wireless@vger.kernel.org,
	Stephen Rothwell <sfr@canb.auug.org.au>
To: "Guy, Wey-Yi" <wey-yi.w.guy@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:56549 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751436Ab2ECRRy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2012 13:17:54 -0400
Content-Disposition: inline
In-Reply-To: <1336058659.27487.80.camel@wwguy-huron>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 03, 2012 at 08:24:19AM -0700, Guy, Wey-Yi wrote:
> Hi John,
> 
> On Thu, 2012-05-03 at 11:14 -0400, John W. Linville wrote:
> > On Thu, May 03, 2012 at 01:25:02AM -0400, David Miller wrote:
> > > From: Eric Dumazet <eric.dumazet@gmail.com>
> > > Date: Thu, 03 May 2012 07:19:33 +0200
> > > 
> > > > My last patch against iwlwifi is still waiting to make its way into
> > > > official tree.
> > > > 
> > > > http://www.spinics.net/lists/netdev/msg192629.html
> > > 
> > > John, please rectify this situation.
> > > 
> > > The Intel Wireless folks said they would test it, but that was more
> > > than a month ago.
> > > 
> > > It's not acceptable to let bug fixes rot for that long, I don't care
> > > what their special internal testing procedure is.
> > > 
> > > If they give you further pushback, please just ignore them and apply
> > > Eric's fix directly.
> > > 
> > > Thank you.
> > 
> > I imagine that this somehow got lost in the shuffle during the
> > merge window.  That doesn't excuse it, of course.
> > 
> > It has waited long enough already, so I'll just go ahead and take it.
> > 
> it is my mistake to lost this patch during the iwlwifi re-factor work,
> the patch is no longer apply and I ask Eric to rebase the patch.
> 
> Sorry again for the mistake

Well, it seems like a fix needed for 3.4.  And, the patch applies there.

It does cause some merge breakage in wireless-testing (and presumably
in linux-next).  I'll attach the commit diff for the wireless-testing
merge fixup I did, for review and/or as a peace offering to sfr... :-)

Please take a look at the result in wireless-testing and let me know
if it is broken...thanks!

John

---

commit 22a101d22ad3296b55d87e92c4a94548aaf6f595
Merge: 20ef730 ed90542
Author: John W. Linville <linville@tuxdriver.com>
Date:   Thu May 3 12:58:38 2012 -0400

    Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless
    
    Conflicts:
    	drivers/net/wireless/iwlwifi/iwl-agn-rx.c
    	drivers/net/wireless/iwlwifi/iwl-trans-pcie-rx.c
    	drivers/net/wireless/iwlwifi/iwl-trans.h

diff --cc drivers/net/wireless/iwlwifi/iwl-agn-rx.c
index f941223,2247460..ff758fe
--- a/drivers/net/wireless/iwlwifi/iwl-agn-rx.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn-rx.c
@@@ -752,15 -787,25 +751,25 @@@ static void iwlagn_pass_packet_to_mac80
  	    iwlagn_set_decrypted_flag(priv, hdr, ampdu_status, stats))
  		return;
  
- 	skb = dev_alloc_skb(128);
+ 	/* Dont use dev_alloc_skb(), we'll have enough headroom once
+ 	 * ieee80211_hdr pulled.
+ 	 */
+ 	skb = alloc_skb(128, GFP_ATOMIC);
  	if (!skb) {
- 		IWL_ERR(priv, "dev_alloc_skb failed\n");
+ 		IWL_ERR(priv, "alloc_skb failed\n");
  		return;
  	}
+ 	hdrlen = min_t(unsigned int, len, skb_tailroom(skb));
+ 	memcpy(skb_put(skb, hdrlen), hdr, hdrlen);
+ 	fraglen = len - hdrlen;
+ 
+ 	if (fraglen) {
 -		int offset = (void *)hdr + hdrlen - rxb_addr(rxb);
++		int offset = (void *)hdr + hdrlen - rxb_addr(rxb)
++				+ rxb_offset(rxb);
  
- 	offset = (void *)hdr - rxb_addr(rxb) + rxb_offset(rxb);
- 	p = rxb_steal_page(rxb);
- 	skb_add_rx_frag(skb, 0, p, offset, len, len);
+ 		skb_add_rx_frag(skb, 0, rxb_steal_page(rxb), offset,
+ 				fraglen, rxb->truesize);
+ 	}
 -	iwl_update_stats(priv, false, fc, len);
  
  	/*
  	* Wake any queues that were stopped due to a passive channel tx
diff --cc drivers/net/wireless/iwlwifi/iwl-trans-pcie-rx.c
index d2239aa,aa7aea1..08517d3
--- a/drivers/net/wireless/iwlwifi/iwl-trans-pcie-rx.c
+++ b/drivers/net/wireless/iwlwifi/iwl-trans-pcie-rx.c
@@@ -373,89 -374,72 +373,90 @@@ static void iwl_rx_handle_rxbuf(struct 
  	if (WARN_ON(!rxb))
  		return;
  
 -	rxcb.truesize = PAGE_SIZE << hw_params(trans).rx_page_order;
 -	dma_unmap_page(trans->dev, rxb->page_dma,
 -		       rxcb.truesize,
 -		       DMA_FROM_DEVICE);
 -
 -	rxcb._page = rxb->page;
 -	pkt = rxb_addr(&rxcb);
 -
 -	IWL_DEBUG_RX(trans, "%s, 0x%02x\n",
 -		     get_cmd_string(pkt->hdr.cmd), pkt->hdr.cmd);
 +	dma_unmap_page(trans->dev, rxb->page_dma, max_len, DMA_FROM_DEVICE);
  
 +	while (offset + sizeof(u32) + sizeof(struct iwl_cmd_header) < max_len) {
 +		struct iwl_rx_packet *pkt;
 +		struct iwl_device_cmd *cmd;
 +		u16 sequence;
 +		bool reclaim;
 +		int index, cmd_index, err, len;
 +		struct iwl_rx_cmd_buffer rxcb = {
 +			._offset = offset,
 +			._page = rxb->page,
 +			._page_stolen = false,
++			.truesize = max_len,
 +		};
  
 -	len = le32_to_cpu(pkt->len_n_flags) & FH_RSCSR_FRAME_SIZE_MSK;
 -	len += sizeof(u32); /* account for status word */
 -	trace_iwlwifi_dev_rx(trans->dev, pkt, len);
 +		pkt = rxb_addr(&rxcb);
  
 -	/* Reclaim a command buffer only if this packet is a response
 -	 *   to a (driver-originated) command.
 -	 * If the packet (e.g. Rx frame) originated from uCode,
 -	 *   there is no command buffer to reclaim.
 -	 * Ucode should set SEQ_RX_FRAME bit if ucode-originated,
 -	 *   but apparently a few don't get set; catch them here. */
 -	reclaim = !(pkt->hdr.sequence & SEQ_RX_FRAME);
 -	if (reclaim) {
 -		int i;
 +		if (pkt->len_n_flags == cpu_to_le32(FH_RSCSR_FRAME_INVALID))
 +			break;
  
 -		for (i = 0; i < trans_pcie->n_no_reclaim_cmds; i++) {
 -			if (trans_pcie->no_reclaim_cmds[i] == pkt->hdr.cmd) {
 -				reclaim = false;
 -				break;
 +		IWL_DEBUG_RX(trans, "cmd at offset %d: %s (0x%.2x)\n",
 +			rxcb._offset,
 +			trans_pcie_get_cmd_string(trans_pcie, pkt->hdr.cmd),
 +			pkt->hdr.cmd);
 +
 +		len = le32_to_cpu(pkt->len_n_flags) & FH_RSCSR_FRAME_SIZE_MSK;
 +		len += sizeof(u32); /* account for status word */
 +		trace_iwlwifi_dev_rx(trans->dev, pkt, len);
 +
 +		/* Reclaim a command buffer only if this packet is a response
 +		 *   to a (driver-originated) command.
 +		 * If the packet (e.g. Rx frame) originated from uCode,
 +		 *   there is no command buffer to reclaim.
 +		 * Ucode should set SEQ_RX_FRAME bit if ucode-originated,
 +		 *   but apparently a few don't get set; catch them here. */
 +		reclaim = !(pkt->hdr.sequence & SEQ_RX_FRAME);
 +		if (reclaim) {
 +			int i;
 +
 +			for (i = 0; i < trans_pcie->n_no_reclaim_cmds; i++) {
 +				if (trans_pcie->no_reclaim_cmds[i] ==
 +							pkt->hdr.cmd) {
 +					reclaim = false;
 +					break;
 +				}
  			}
  		}
 -	}
  
 -	sequence = le16_to_cpu(pkt->hdr.sequence);
 -	index = SEQ_TO_INDEX(sequence);
 -	cmd_index = get_cmd_index(&txq->q, index);
 +		sequence = le16_to_cpu(pkt->hdr.sequence);
 +		index = SEQ_TO_INDEX(sequence);
 +		cmd_index = get_cmd_index(&txq->q, index);
  
 -	if (reclaim)
 -		cmd = txq->cmd[cmd_index];
 -	else
 -		cmd = NULL;
 +		if (reclaim)
 +			cmd = txq->entries[cmd_index].cmd;
 +		else
 +			cmd = NULL;
  
 -	err = iwl_op_mode_rx(trans->op_mode, &rxcb, cmd);
 +		err = iwl_op_mode_rx(trans->op_mode, &rxcb, cmd);
  
 -	/*
 -	 * XXX: After here, we should always check rxcb._page
 -	 * against NULL before touching it or its virtual
 -	 * memory (pkt). Because some rx_handler might have
 -	 * already taken or freed the pages.
 -	 */
 +		/*
 +		 * After here, we should always check rxcb._page_stolen,
 +		 * if it is true then one of the handlers took the page.
 +		 */
  
 -	if (reclaim) {
 -		/* Invoke any callbacks, transfer the buffer to caller,
 -		 * and fire off the (possibly) blocking
 -		 * iwl_trans_send_cmd()
 -		 * as we reclaim the driver command queue */
 -		if (rxcb._page)
 -			iwl_tx_cmd_complete(trans, &rxcb, err);
 -		else
 -			IWL_WARN(trans, "Claim null rxb?\n");
 +		if (reclaim) {
 +			/* Invoke any callbacks, transfer the buffer to caller,
 +			 * and fire off the (possibly) blocking
 +			 * iwl_trans_send_cmd()
 +			 * as we reclaim the driver command queue */
 +			if (!rxcb._page_stolen)
 +				iwl_tx_cmd_complete(trans, &rxcb, err);
 +			else
 +				IWL_WARN(trans, "Claim null rxb?\n");
 +		}
 +
 +		page_stolen |= rxcb._page_stolen;
 +		offset += ALIGN(len, FH_RSCSR_FRAME_ALIGN);
  	}
  
 -	/* page was stolen from us */
 -	if (rxcb._page == NULL)
 +	/* page was stolen from us -- free our reference */
 +	if (page_stolen) {
 +		__free_pages(rxb->page, trans_pcie->rx_page_order);
  		rxb->page = NULL;
 +	}
  
  	/* Reuse the page if possible. For notification packets and
  	 * SKBs that fail to Rx correctly, add them back into the
diff --cc drivers/net/wireless/iwlwifi/iwl-trans.h
index 7018d31,fdf9788..79a1e7a
--- a/drivers/net/wireless/iwlwifi/iwl-trans.h
+++ b/drivers/net/wireless/iwlwifi/iwl-trans.h
@@@ -256,8 -260,7 +256,9 @@@ static inline void iwl_free_resp(struc
  
  struct iwl_rx_cmd_buffer {
  	struct page *_page;
 +	int _offset;
 +	bool _page_stolen;
+ 	unsigned int truesize;
  };
  
  static inline void *rxb_addr(struct iwl_rx_cmd_buffer *r)
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
