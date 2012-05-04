From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the wireless
 tree
Date: Fri, 4 May 2012 13:21:38 +1000
Message-ID: <20120504132138.d0142070434e502dfcb8a980@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Fri__4_May_2012_13_21_38_+1000_m+J0Xv=Ku_Mbl+tS"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	"Guy, Wey-Yi" <wey-yi.w.guy@intel.com>, alexander.duyck@gmail.com,
	alexander.h.duyck@intel.com, jeffrey.t.kirsher@intel.com,
	linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__4_May_2012_13_21_38_+1000_m+J0Xv=Ku_Mbl+tS
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got conflicts in
drivers/net/wireless/iwlwifi/iwl-trans.h,
drivers/net/wireless/iwlwifi/iwl-trans-pcie-rx.c, and
drivers/net/wireless/iwlwifi/iwl-agn-rx.c between commit ed90542b0ce5
("iwlwifi: fix skb truesize underestimation") from the wireless tree and
various commits from the net-next tree.

This was anticipated and I have applied the fix supplied by John (see
below just to check).  Thanks to John for this!
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/wireless/iwlwifi/iwl-agn-rx.c
index 2247460,f941223..0000000
--- a/drivers/net/wireless/iwlwifi/iwl-agn-rx.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn-rx.c
@@@ -787,25 -752,15 +751,24 @@@ static void iwlagn_pass_packet_to_mac80
  	    iwlagn_set_decrypted_flag(priv, hdr, ampdu_status, stats))
  		return;
 =20
 -	skb =3D dev_alloc_skb(128);
 +	/* Dont use dev_alloc_skb(), we'll have enough headroom once
 +	 * ieee80211_hdr pulled.
 +	 */
 +	skb =3D alloc_skb(128, GFP_ATOMIC);
  	if (!skb) {
 -		IWL_ERR(priv, "dev_alloc_skb failed\n");
 +		IWL_ERR(priv, "alloc_skb failed\n");
  		return;
  	}
 +	hdrlen =3D min_t(unsigned int, len, skb_tailroom(skb));
 +	memcpy(skb_put(skb, hdrlen), hdr, hdrlen);
 +	fraglen =3D len - hdrlen;
 +
 +	if (fraglen) {
- 		int offset =3D (void *)hdr + hdrlen - rxb_addr(rxb);
++		int offset =3D (void *)hdr - rxb_addr(rxb) + rxb_offset(rxb);
 =20
 -	offset =3D (void *)hdr - rxb_addr(rxb) + rxb_offset(rxb);
 -	p =3D rxb_steal_page(rxb);
 -	skb_add_rx_frag(skb, 0, p, offset, len, len);
 +		skb_add_rx_frag(skb, 0, rxb_steal_page(rxb), offset,
 +				fraglen, rxb->truesize);
 +	}
- 	iwl_update_stats(priv, false, fc, len);
 =20
  	/*
  	* Wake any queues that were stopped due to a passive channel tx
diff --cc drivers/net/wireless/iwlwifi/iwl-trans-pcie-rx.c
index aa7aea1,d2239aa..0000000
--- a/drivers/net/wireless/iwlwifi/iwl-trans-pcie-rx.c
+++ b/drivers/net/wireless/iwlwifi/iwl-trans-pcie-rx.c
@@@ -374,72 -373,89 +373,90 @@@ static void iwl_rx_handle_rxbuf(struct=20
  	if (WARN_ON(!rxb))
  		return;
 =20
- 	rxcb.truesize =3D PAGE_SIZE << hw_params(trans).rx_page_order;
- 	dma_unmap_page(trans->dev, rxb->page_dma,
- 		       rxcb.truesize,
- 		       DMA_FROM_DEVICE);
-=20
- 	rxcb._page =3D rxb->page;
- 	pkt =3D rxb_addr(&rxcb);
-=20
- 	IWL_DEBUG_RX(trans, "%s, 0x%02x\n",
- 		     get_cmd_string(pkt->hdr.cmd), pkt->hdr.cmd);
+ 	dma_unmap_page(trans->dev, rxb->page_dma, max_len, DMA_FROM_DEVICE);
 =20
+ 	while (offset + sizeof(u32) + sizeof(struct iwl_cmd_header) < max_len) {
+ 		struct iwl_rx_packet *pkt;
+ 		struct iwl_device_cmd *cmd;
+ 		u16 sequence;
+ 		bool reclaim;
+ 		int index, cmd_index, err, len;
+ 		struct iwl_rx_cmd_buffer rxcb =3D {
+ 			._offset =3D offset,
+ 			._page =3D rxb->page,
+ 			._page_stolen =3D false,
++			.truesize =3D max_len,
+ 		};
 =20
- 	len =3D le32_to_cpu(pkt->len_n_flags) & FH_RSCSR_FRAME_SIZE_MSK;
- 	len +=3D sizeof(u32); /* account for status word */
- 	trace_iwlwifi_dev_rx(trans->dev, pkt, len);
+ 		pkt =3D rxb_addr(&rxcb);
 =20
- 	/* Reclaim a command buffer only if this packet is a response
- 	 *   to a (driver-originated) command.
- 	 * If the packet (e.g. Rx frame) originated from uCode,
- 	 *   there is no command buffer to reclaim.
- 	 * Ucode should set SEQ_RX_FRAME bit if ucode-originated,
- 	 *   but apparently a few don't get set; catch them here. */
- 	reclaim =3D !(pkt->hdr.sequence & SEQ_RX_FRAME);
- 	if (reclaim) {
- 		int i;
+ 		if (pkt->len_n_flags =3D=3D cpu_to_le32(FH_RSCSR_FRAME_INVALID))
+ 			break;
 =20
- 		for (i =3D 0; i < trans_pcie->n_no_reclaim_cmds; i++) {
- 			if (trans_pcie->no_reclaim_cmds[i] =3D=3D pkt->hdr.cmd) {
- 				reclaim =3D false;
- 				break;
+ 		IWL_DEBUG_RX(trans, "cmd at offset %d: %s (0x%.2x)\n",
+ 			rxcb._offset,
+ 			trans_pcie_get_cmd_string(trans_pcie, pkt->hdr.cmd),
+ 			pkt->hdr.cmd);
+=20
+ 		len =3D le32_to_cpu(pkt->len_n_flags) & FH_RSCSR_FRAME_SIZE_MSK;
+ 		len +=3D sizeof(u32); /* account for status word */
+ 		trace_iwlwifi_dev_rx(trans->dev, pkt, len);
+=20
+ 		/* Reclaim a command buffer only if this packet is a response
+ 		 *   to a (driver-originated) command.
+ 		 * If the packet (e.g. Rx frame) originated from uCode,
+ 		 *   there is no command buffer to reclaim.
+ 		 * Ucode should set SEQ_RX_FRAME bit if ucode-originated,
+ 		 *   but apparently a few don't get set; catch them here. */
+ 		reclaim =3D !(pkt->hdr.sequence & SEQ_RX_FRAME);
+ 		if (reclaim) {
+ 			int i;
+=20
+ 			for (i =3D 0; i < trans_pcie->n_no_reclaim_cmds; i++) {
+ 				if (trans_pcie->no_reclaim_cmds[i] =3D=3D
+ 							pkt->hdr.cmd) {
+ 					reclaim =3D false;
+ 					break;
+ 				}
  			}
  		}
- 	}
 =20
- 	sequence =3D le16_to_cpu(pkt->hdr.sequence);
- 	index =3D SEQ_TO_INDEX(sequence);
- 	cmd_index =3D get_cmd_index(&txq->q, index);
+ 		sequence =3D le16_to_cpu(pkt->hdr.sequence);
+ 		index =3D SEQ_TO_INDEX(sequence);
+ 		cmd_index =3D get_cmd_index(&txq->q, index);
 =20
- 	if (reclaim)
- 		cmd =3D txq->cmd[cmd_index];
- 	else
- 		cmd =3D NULL;
+ 		if (reclaim)
+ 			cmd =3D txq->entries[cmd_index].cmd;
+ 		else
+ 			cmd =3D NULL;
 =20
- 	err =3D iwl_op_mode_rx(trans->op_mode, &rxcb, cmd);
+ 		err =3D iwl_op_mode_rx(trans->op_mode, &rxcb, cmd);
 =20
- 	/*
- 	 * XXX: After here, we should always check rxcb._page
- 	 * against NULL before touching it or its virtual
- 	 * memory (pkt). Because some rx_handler might have
- 	 * already taken or freed the pages.
- 	 */
+ 		/*
+ 		 * After here, we should always check rxcb._page_stolen,
+ 		 * if it is true then one of the handlers took the page.
+ 		 */
 =20
- 	if (reclaim) {
- 		/* Invoke any callbacks, transfer the buffer to caller,
- 		 * and fire off the (possibly) blocking
- 		 * iwl_trans_send_cmd()
- 		 * as we reclaim the driver command queue */
- 		if (rxcb._page)
- 			iwl_tx_cmd_complete(trans, &rxcb, err);
- 		else
- 			IWL_WARN(trans, "Claim null rxb?\n");
+ 		if (reclaim) {
+ 			/* Invoke any callbacks, transfer the buffer to caller,
+ 			 * and fire off the (possibly) blocking
+ 			 * iwl_trans_send_cmd()
+ 			 * as we reclaim the driver command queue */
+ 			if (!rxcb._page_stolen)
+ 				iwl_tx_cmd_complete(trans, &rxcb, err);
+ 			else
+ 				IWL_WARN(trans, "Claim null rxb?\n");
+ 		}
+=20
+ 		page_stolen |=3D rxcb._page_stolen;
+ 		offset +=3D ALIGN(len, FH_RSCSR_FRAME_ALIGN);
  	}
 =20
- 	/* page was stolen from us */
- 	if (rxcb._page =3D=3D NULL)
+ 	/* page was stolen from us -- free our reference */
+ 	if (page_stolen) {
+ 		__free_pages(rxb->page, trans_pcie->rx_page_order);
  		rxb->page =3D NULL;
+ 	}
 =20
  	/* Reuse the page if possible. For notification packets and
  	 * SKBs that fail to Rx correctly, add them back into the
diff --cc drivers/net/wireless/iwlwifi/iwl-trans.h
index fdf9788,7018d31..0000000
--- a/drivers/net/wireless/iwlwifi/iwl-trans.h
+++ b/drivers/net/wireless/iwlwifi/iwl-trans.h
@@@ -260,7 -256,8 +256,9 @@@ static inline void iwl_free_resp(struc
 =20
  struct iwl_rx_cmd_buffer {
  	struct page *_page;
+ 	int _offset;
+ 	bool _page_stolen;
 +	unsigned int truesize;
  };
 =20
  static inline void *rxb_addr(struct iwl_rx_cmd_buffer *r)

--Signature=_Fri__4_May_2012_13_21_38_+1000_m+J0Xv=Ku_Mbl+tS
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJPo0tCAAoJEECxmPOUX5FExr0P/2+mJhP/ejpPrvFj+6y/nQq/
BPC1/dNtQwDRD/tmc8hpUpYHQHvlQxMQbvzrTDmvv/SQttis6UjpryUfqy6e4h8D
piunO5FGes6vjkSSZTK80j3jDgMx2UrseUPAcFBmOUa/v4Xdn3tv6bVLLLXc5jcV
5pjfvr77lU1po6hwKK8XzVUFZLuE0/IdZhtfbELaG1wcBckL/2bHGrrw62kEAYrb
0MOwKNLcJVf2Xtaav9K4r6yX1m40g5BitfMaA1SGaPDIscddsCSdniblHUakf9lB
vbslofhC8i37jdcXMFsfiCXaMAcho2M9NSOgN3YuWQZ8M4opu67+N9E2vnw8VfQb
xvxjqG0MAqUlw2ZkhCUxPaLMooA7qnZ0SAzonus4pzoAAxf6ljJ9qo8PAg8V7oUo
CXjmBNTulhs22F31lypURdwJuAbl4hSWtR2BH5VO3yANBM46lIYy3LYpmyATlcbh
rTq+a+v+iW0w1NtN1ZFTNb+B2rgkhiA8BM1X8NJAYg0yTlVxx0A5Nj0hUZS0KP0k
Jn4JGO+u+YPHVK6vPq/U5HbDIKdjKlnynM008mlqWNyglwzEHxejoIRh6v22WIbk
bvsm30jj1knMB5BnUG77GcK5NxZRPGESjEZxJdFIdLXnnVlxjFfXJi9GV1b+rom7
/ha5klNS2E3DifSzUxDQ
=85vZ
-----END PGP SIGNATURE-----

--Signature=_Fri__4_May_2012_13_21_38_+1000_m+J0Xv=Ku_Mbl+tS--
