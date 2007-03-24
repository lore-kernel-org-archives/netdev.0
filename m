From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Subject: [PATCH 3/3] [SK_BUFF]: Use skb_store_bits more extensively
Date: Sat, 24 Mar 2007 18:08:18 -0300
Message-ID: <20070324210818.GY17811@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.233]:33443 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753500AbXCXVIn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Mar 2007 17:08:43 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1706211wxd
        for <netdev@vger.kernel.org>; Sat, 24 Mar 2007 14:08:43 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Avoiding direct accesses to skb->data.

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 arch/ia64/hp/sim/simeth.c                 |    2 +-
 arch/ia64/sn/kernel/xpnet.c               |    2 +-
 drivers/isdn/hysdn/hycapi.c               |    2 +-
 drivers/net/8139too.c                     |    6 +++---
 drivers/net/appletalk/ltpc.c              |    2 +-
 drivers/net/atari_bionet.c                |    2 +-
 drivers/net/atari_pamsnet.c               |    2 +-
 drivers/net/chelsio/sge.c                 |   16 ++++++++--------
 drivers/net/cxgb3/sge.c                   |    6 +++---
 drivers/net/defxx.c                       |    4 +++-
 drivers/net/e100.c                        |    2 +-
 drivers/net/ehea/ehea_main.c              |    4 ++--
 drivers/net/irda/ali-ircc.c               |    2 +-
 drivers/net/irda/au1k_ir.c                |    2 +-
 drivers/net/irda/mcs7780.c                |    4 ++--
 drivers/net/irda/nsc-ircc.c               |    6 ++++--
 drivers/net/irda/pxaficp_ir.c             |    2 +-
 drivers/net/irda/stir4200.c               |    2 +-
 drivers/net/irda/via-ircc.c               |    6 +++---
 drivers/net/irda/w83977af_ir.c            |    6 ++++--
 drivers/net/loopback.c                    |    2 +-
 drivers/net/macb.c                        |    6 +++---
 drivers/net/myri10ge/myri10ge.c           |    2 +-
 drivers/net/skfp/skfddi.c                 |    2 +-
 drivers/net/sun3lance.c                   |    2 +-
 drivers/net/tokenring/smctr.c             |    4 ++--
 drivers/net/tokenring/tms380tr.c          |    3 ++-
 drivers/net/wan/dscc4.c                   |    3 ++-
 drivers/net/wan/pc300_drv.c               |    2 +-
 drivers/net/wan/pc300_tty.c               |    4 ++--
 drivers/net/wan/z85230.c                  |    2 +-
 drivers/net/wireless/prism54/islpci_eth.c |    4 ++--
 drivers/usb/atm/usbatm.c                  |    3 ++-
 drivers/usb/net/asix.c                    |    2 +-
 net/ipv4/ipcomp.c                         |    2 +-
 net/ipv4/ipvs/ip_vs_app.c                 |    2 +-
 net/irda/irttp.c                          |    2 +-
 37 files changed, 68 insertions(+), 59 deletions(-)

diff --git a/arch/ia64/hp/sim/simeth.c b/arch/ia64/hp/sim/simeth.c
index edef008..9632c9b 100644
--- a/arch/ia64/hp/sim/simeth.c
+++ b/arch/ia64/hp/sim/simeth.c
@@ -473,7 +473,7 @@ simeth_rx(struct net_device *dev)
 		 * XXX Fix me
 		 * Should really do a csum+copy here
 		 */
-		memcpy(skb->data, frame, len);
+		skb_store_bits(skb, 0, frame, len);
 #endif
 		skb->protocol = eth_type_trans(skb, dev);
 
diff --git a/arch/ia64/sn/kernel/xpnet.c b/arch/ia64/sn/kernel/xpnet.c
index 3335b8a..785a3f9 100644
--- a/arch/ia64/sn/kernel/xpnet.c
+++ b/arch/ia64/sn/kernel/xpnet.c
@@ -233,7 +233,7 @@ xpnet_receive(partid_t partid, int channel, struct xpnet_message *msg)
 			"%lu)\n", skb->data, &msg->data,
 			(size_t) msg->embedded_bytes);
 
-		memcpy(skb->data, &msg->data, (size_t) msg->embedded_bytes);
+		skb_store_bits(skb, 0, &msg->data, (size_t)msg->embedded_bytes);
 	} else {
 		dev_dbg(xpnet, "transferring buffer to the skb->data area;\n\t"
 			"bte_copy(0x%p, 0x%p, %hu)\n", (void *)msg->buf_pa,
diff --git a/drivers/isdn/hysdn/hycapi.c b/drivers/isdn/hysdn/hycapi.c
index 662799f..668256a 100644
--- a/drivers/isdn/hysdn/hycapi.c
+++ b/drivers/isdn/hysdn/hycapi.c
@@ -399,7 +399,7 @@ static u16 hycapi_send_message(struct capi_ctr *ctrl, struct sk_buff *skb)
 			if (_len > 22) {
 				_len2 = _len - 22;
 				skb_copy_bits(skb, 0, msghead, 22);
-				memcpy(skb->data + _len2, msghead, 22);
+				skb_store_bits(skb, _len2, msghead, 22);
 				skb_pull(skb, _len2);
 				CAPIMSG_SETLEN(skb->data, 22);
 				retval = capilib_data_b3_req(&cinfo->ncci_head,
diff --git a/drivers/net/8139too.c b/drivers/net/8139too.c
index 2101334..71e41ad 100644
--- a/drivers/net/8139too.c
+++ b/drivers/net/8139too.c
@@ -1904,10 +1904,10 @@ static __inline__ void wrap_copy(struct sk_buff *skb, const unsigned char *ring,
 	u32 left = RX_BUF_LEN - offset;
 
 	if (size > left) {
-		memcpy(skb->data, ring + offset, left);
-		memcpy(skb->data+left, ring, size - left);
+		skb_store_bits(skb, 0, ring + offset, left);
+		skb_store_bits(skb, left, ring, size - left);
 	} else
-		memcpy(skb->data, ring + offset, size);
+		skb_store_bits(skb, 0, ring + offset, size);
 }
 #endif
 
diff --git a/drivers/net/appletalk/ltpc.c b/drivers/net/appletalk/ltpc.c
index 43c17c8..fac3c4c 100644
--- a/drivers/net/appletalk/ltpc.c
+++ b/drivers/net/appletalk/ltpc.c
@@ -774,7 +774,7 @@ static int sendup_buffer (struct net_device *dev)
 	skb_pull(skb,3);
 
 	/* copy ddp(s,e)hdr + contents */
-	memcpy(skb->data,(void*)ltdmabuf,len);
+	skb_store_bits(skb, 0, ltdmabuf, len);
 
 	skb_reset_transport_header(skb);
 
diff --git a/drivers/net/atari_bionet.c b/drivers/net/atari_bionet.c
index b27b763..74b7594 100644
--- a/drivers/net/atari_bionet.c
+++ b/drivers/net/atari_bionet.c
@@ -549,7 +549,7 @@ bionet_poll_rx(struct net_device *dev) {
 
 			/* 'skb->data' points to the start of sk_buff data area.
 			 */
-			memcpy(skb->data, nic_packet->buffer, pkt_len);
+			skb_store_bits(skb, 0, nic_packet->buffer, pkt_len);
 			skb->protocol = eth_type_trans( skb, dev );
 			netif_rx(skb);
 			dev->last_rx = jiffies;
diff --git a/drivers/net/atari_pamsnet.c b/drivers/net/atari_pamsnet.c
index 40d3bf1..c136b12 100644
--- a/drivers/net/atari_pamsnet.c
+++ b/drivers/net/atari_pamsnet.c
@@ -792,7 +792,7 @@ pamsnet_poll_rx(struct net_device *dev) {
 
 			/* 'skb->data' points to the start of sk_buff data area.
 			 */
-			memcpy(skb->data, nic_packet->buffer, pkt_len);
+			skb_store_bits(skb, 0, nic_packet->buffer, pkt_len);
 			netif_rx(skb);
 			dev->last_rx = jiffies;
 			lp->stats.rx_packets++;
diff --git a/drivers/net/chelsio/sge.c b/drivers/net/chelsio/sge.c
index dd0d239..01fb017 100644
--- a/drivers/net/chelsio/sge.c
+++ b/drivers/net/chelsio/sge.c
@@ -2095,10 +2095,10 @@ static void espibug_workaround_t204(unsigned long data)
 					0x0, 0x7, 0x43, 0x0, 0x0, 0x0
 				};
 
-				memcpy(skb->data + sizeof(struct cpl_tx_pkt),
-					ch_mac_addr, ETH_ALEN);
-				memcpy(skb->data + skb->len - 10,
-					ch_mac_addr, ETH_ALEN);
+				skb_store_bits(skb, sizeof(struct cpl_tx_pkt),
+					       ch_mac_addr, ETH_ALEN);
+				skb_store_bits(skb, skb->len - 10,
+					       ch_mac_addr, ETH_ALEN);
 				skb->cb[0] = 0xff;
 			}
 
@@ -2125,10 +2125,10 @@ static void espibug_workaround(unsigned long data)
 	                if (!skb->cb[0]) {
 	                        u8 ch_mac_addr[ETH_ALEN] =
 	                            {0x0, 0x7, 0x43, 0x0, 0x0, 0x0};
-	                        memcpy(skb->data + sizeof(struct cpl_tx_pkt),
-	                               ch_mac_addr, ETH_ALEN);
-	                        memcpy(skb->data + skb->len - 10, ch_mac_addr,
-	                               ETH_ALEN);
+	                        skb_store_bits(skb, sizeof(struct cpl_tx_pkt),
+					       ch_mac_addr, ETH_ALEN);
+	                        skb_store_bits(skb, skb->len - 10, ch_mac_addr,
+					       ETH_ALEN);
 	                        skb->cb[0] = 0xff;
 	                }
 
diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index e266112..0fc8f13 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -661,7 +661,7 @@ static inline struct sk_buff *get_imm_packet(const struct rsp_desc *resp)
 
 	if (skb) {
 		__skb_put(skb, IMMED_PKT_SIZE);
-		memcpy(skb->data, resp->imm_data, IMMED_PKT_SIZE);
+		skb_store_bits(skb, 0, resp->imm_data, IMMED_PKT_SIZE);
 	}
 	return skb;
 }
@@ -1718,11 +1718,11 @@ static void skb_data_init(struct sk_buff *skb, struct sge_fl_page *p,
 {
 	skb->len = len;
 	if (len <= SKB_DATA_SIZE) {
-		memcpy(skb->data, p->va, len);
+		skb_store_bits(skb, 0, p->va, len);
 		skb->tail += len;
 		put_page(p->frag.page);
 	} else {
-		memcpy(skb->data, p->va, SKB_DATA_SIZE);
+		skb_store_bits(skb, 0, p->va, SKB_DATA_SIZE);
 		skb_shinfo(skb)->frags[0].page = p->frag.page;
 		skb_shinfo(skb)->frags[0].page_offset =
 		    p->frag.page_offset + SKB_DATA_SIZE;
diff --git a/drivers/net/defxx.c b/drivers/net/defxx.c
index 8d29fae..e3189e3 100644
--- a/drivers/net/defxx.c
+++ b/drivers/net/defxx.c
@@ -3091,7 +3091,9 @@ static void dfx_rcv_queue_process(
 					{
 						/* Receive buffer allocated, pass receive packet up */
 
-						memcpy(skb->data, p_buff + RCV_BUFF_K_PADDING, pkt_len+3);
+						skb_store_bits(skb, 0,
+							       p_buff + RCV_BUFF_K_PADDING,
+							       pkt_len + 3);
 					}
 
 					skb_reserve(skb,3);		/* adjust data field so that it points to FC byte */
diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index 0cefef5..f8ccb09 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -1769,7 +1769,7 @@ static int e100_rx_alloc_skb(struct nic *nic, struct rx *rx)
 
 	/* Align, init, and map the RFD. */
 	skb_reserve(rx->skb, NET_IP_ALIGN);
-	memcpy(rx->skb->data, &nic->blank_rfd, sizeof(struct rfd));
+	skb_store_bits(rx->skb, 0, &nic->blank_rfd, sizeof(struct rfd));
 	rx->dma_addr = pci_map_single(nic->pdev, rx->skb->data,
 		RFD_BUF_LEN, PCI_DMA_BIDIRECTIONAL);
 
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index 629385d..5af3fd3 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -391,8 +391,8 @@ static int ehea_poll(struct net_device *dev, int *budget)
 					if (!skb)
 						break;
 				}
-				memcpy(skb->data, ((char*)cqe) + 64,
-				       cqe->num_bytes_transfered - 4);
+				skb_store_bits(skb, 0, ((char*)cqe) + 64,
+					       cqe->num_bytes_transfered - 4);
 				ehea_fill_skb(dev, skb, cqe);
 			} else if (rq == 2) {  /* RQ2 */
 				skb = get_skb_by_index(skb_arr_rq2,
diff --git a/drivers/net/irda/ali-ircc.c b/drivers/net/irda/ali-ircc.c
index 7b2c5ee..ddcb467 100644
--- a/drivers/net/irda/ali-ircc.c
+++ b/drivers/net/irda/ali-ircc.c
@@ -1923,7 +1923,7 @@ static int  ali_ircc_dma_receive_complete(struct ali_ircc_cb *self)
 			
 			/* Copy frame without CRC, CRC is removed by hardware*/
 			skb_put(skb, len);
-			memcpy(skb->data, self->rx_buff.data, len);
+			skb_store_bits(skb, 0, self->rx_buff.data, len);
 
 			/* Move to next frame */
 			self->rx_buff.data += len;
diff --git a/drivers/net/irda/au1k_ir.c b/drivers/net/irda/au1k_ir.c
index 6adb7ae..f8dced7 100644
--- a/drivers/net/irda/au1k_ir.c
+++ b/drivers/net/irda/au1k_ir.c
@@ -604,7 +604,7 @@ static int au1k_irda_rx(struct net_device *dev)
 				skb_put(skb, count);
 			else
 				skb_put(skb, count-2);
-			memcpy(skb->data, (void *)pDB->vaddr, count-2);
+			skb_store_bits(skb, 0, pDB->vaddr, count-2);
 			skb->dev = dev;
 			skb_reset_mac_header(skb);
 			skb->protocol = htons(ETH_P_IRDA);
diff --git a/drivers/net/irda/mcs7780.c b/drivers/net/irda/mcs7780.c
index a066042..b2335c5 100644
--- a/drivers/net/irda/mcs7780.c
+++ b/drivers/net/irda/mcs7780.c
@@ -426,7 +426,7 @@ static void mcs_unwrap_mir(struct mcs_cb *mcs, __u8 *buf, int len)
 	}
 
 	skb_reserve(skb, 1);
-	memcpy(skb->data, buf, new_len);
+	skb_store_bits(skb, 0, buf, new_len);
 	skb_put(skb, new_len);
 	skb_reset_mac_header(skb);
 	skb->protocol = htons(ETH_P_IRDA);
@@ -479,7 +479,7 @@ static void mcs_unwrap_fir(struct mcs_cb *mcs, __u8 *buf, int len)
 	}
 
 	skb_reserve(skb, 1);
-	memcpy(skb->data, buf, new_len);
+	skb_store_bits(skb, 0, buf, new_len);
 	skb_put(skb, new_len);
 	skb_reset_mac_header(skb);
 	skb->protocol = htons(ETH_P_IRDA);
diff --git a/drivers/net/irda/nsc-ircc.c b/drivers/net/irda/nsc-ircc.c
index ca14b27..b945d09 100644
--- a/drivers/net/irda/nsc-ircc.c
+++ b/drivers/net/irda/nsc-ircc.c
@@ -1868,10 +1868,12 @@ static int nsc_ircc_dma_receive_complete(struct nsc_ircc_cb *self, int iobase)
 			/* Copy frame without CRC */
 			if (self->io.speed < 4000000) {
 				skb_put(skb, len-2);
-				memcpy(skb->data, self->rx_buff.data, len-2);
+				skb_store_bits(skb, 0,
+					       self->rx_buff.data, len - 2);
 			} else {
 				skb_put(skb, len-4);
-				memcpy(skb->data, self->rx_buff.data, len-4);
+				skb_store_bits(skb, 0,
+					       self->rx_buff.data, len - 4);
 			}
 
 			/* Move to next frame */
diff --git a/drivers/net/irda/pxaficp_ir.c b/drivers/net/irda/pxaficp_ir.c
index 186f5df..238348b 100644
--- a/drivers/net/irda/pxaficp_ir.c
+++ b/drivers/net/irda/pxaficp_ir.c
@@ -371,7 +371,7 @@ static void pxa_irda_fir_irq_eif(struct pxa_irda *si, struct net_device *dev)
 
 		/* Align IP header to 20 bytes  */
 		skb_reserve(skb, 1);
-		memcpy(skb->data, si->dma_rx_buff, len);
+		skb_store_bits(skb, 0, si->dma_rx_buff, len);
 		skb_put(skb, len);
 
 		/* Feed it to IrLAP  */
diff --git a/drivers/net/irda/stir4200.c b/drivers/net/irda/stir4200.c
index aec86a2..0be2088 100644
--- a/drivers/net/irda/stir4200.c
+++ b/drivers/net/irda/stir4200.c
@@ -348,7 +348,7 @@ static void fir_eof(struct stir_cb *stir)
 		}
 		skb_reserve(nskb, 1);
 		skb = nskb;
-		memcpy(nskb->data, rx_buff->data, len);
+		skb_store_bits(nskb, 0, rx_buff->data, len);
 	} else {
 		nskb = dev_alloc_skb(rx_buff->truesize);
 		if (unlikely(!nskb)) {
diff --git a/drivers/net/irda/via-ircc.c b/drivers/net/irda/via-ircc.c
index aaa1802..365bb96 100644
--- a/drivers/net/irda/via-ircc.c
+++ b/drivers/net/irda/via-ircc.c
@@ -1189,7 +1189,7 @@ F01_E */
 		skb_reserve(skb, 1);
 		skb_put(skb, len - 4);
 
-		memcpy(skb->data, self->rx_buff.data, len - 4);
+		skb_store_bits(skb, 0, self->rx_buff.data, len - 4);
 		IRDA_DEBUG(2, "%s(): len=%x.rx_buff=%p\n", __FUNCTION__,
 			   len - 4, self->rx_buff.data);
 
@@ -1234,7 +1234,7 @@ static int upload_rxdata(struct via_ircc_cb *self, int iobase)
 	}
 	skb_reserve(skb, 1);
 	skb_put(skb, len - 4 + 1);
-	memcpy(skb->data, self->rx_buff.data, len - 4 + 1);
+	skb_store_bits(skb, 0, self->rx_buff.data, len - 4 + 1);
 	st_fifo->tail++;
 	st_fifo->len++;
 	if (st_fifo->tail > MAX_RX_WINDOW)
@@ -1303,7 +1303,7 @@ static int RxTimerHandler(struct via_ircc_cb *self, int iobase)
 			}
 			skb_reserve(skb, 1);
 			skb_put(skb, len - 4);
-			memcpy(skb->data, self->rx_buff.data, len - 4);
+			skb_store_bits(skb, 0, self->rx_buff.data, len - 4);
 
 			IRDA_DEBUG(2, "%s(): len=%x.head=%x\n", __FUNCTION__,
 				   len - 4, st_fifo->head);
diff --git a/drivers/net/irda/w83977af_ir.c b/drivers/net/irda/w83977af_ir.c
index 28837c6..74aaa47 100644
--- a/drivers/net/irda/w83977af_ir.c
+++ b/drivers/net/irda/w83977af_ir.c
@@ -908,10 +908,12 @@ int w83977af_dma_receive_complete(struct w83977af_ir *self)
 			/* Copy frame without CRC */
 			if (self->io.speed < 4000000) {
 				skb_put(skb, len-2);
-				memcpy(skb->data, self->rx_buff.data, len-2);
+				skb_store_bits(skb, 0,
+					       self->rx_buff.data, len - 2);
 			} else {
 				skb_put(skb, len-4);
-				memcpy(skb->data, self->rx_buff.data, len-4);
+				skb_store_bits(skb, 0,
+					       self->rx_buff.data, len - 4);
 			}
 
 			/* Move to next frame */
diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index 20b5cb1..30e4448 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -94,7 +94,7 @@ static void emulate_large_send_offload(struct sk_buff *skb)
 		skb_set_mac_header(nskb, -ETH_HLEN);
 		skb_reset_network_header(nskb);
 		iph = ip_hdr(nskb);
-		memcpy(nskb->data, skb_network_header(skb), doffset);
+		skb_store_bits(nskb, 0, skb_network_header(skb), doffset);
 		if (skb_copy_bits(skb,
 				  doffset + offset,
 				  nskb->data + doffset,
diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index 9e233f8..305f8d2 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -367,9 +367,9 @@ static int macb_rx_frame(struct macb *bp, unsigned int first_frag,
 			BUG_ON(frag != last_frag);
 			frag_len = len - offset;
 		}
-		memcpy(skb->data + offset,
-		       bp->rx_buffers + (RX_BUFFER_SIZE * frag),
-		       frag_len);
+		skb_store_bits(skb, offset,
+			       bp->rx_buffers + (RX_BUFFER_SIZE * frag),
+			       frag_len);
 		offset += RX_BUFFER_SIZE;
 		bp->rx_ring[frag].addr &= ~MACB_BIT(RX_USED);
 		wmb();
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index 0305056..8396bc7 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -879,7 +879,7 @@ myri10ge_rx_skb_build(struct sk_buff *skb, u8 * va,
 	 * skb_pull() (for ether_pad and eth_type_trans()) requires
 	 * the beginning of the packet in skb_headlen(), move it
 	 * manually */
-	memcpy(skb->data, va, hlen);
+	skb_store_bits(skb, 0, va, hlen);
 	skb_shinfo(skb)->frags[0].page_offset += hlen;
 	skb_shinfo(skb)->frags[0].size -= hlen;
 	skb->data_len -= hlen;
diff --git a/drivers/net/skfp/skfddi.c b/drivers/net/skfp/skfddi.c
index 064e7c2..41d51a5 100644
--- a/drivers/net/skfp/skfddi.c
+++ b/drivers/net/skfp/skfddi.c
@@ -1937,7 +1937,7 @@ int mac_drv_rx_init(struct s_smc *smc, int len, int fc,
 	}
 	skb_reserve(skb, 3);
 	skb_put(skb, len);
-	memcpy(skb->data, look_ahead, len);
+	skb_store_bits(skb, 0, look_ahead, len);
 
 	// deliver frame to system
 	skb->protocol = fddi_type_trans(skb, smc->os.dev);
diff --git a/drivers/net/sun3lance.c b/drivers/net/sun3lance.c
index ab96c05..2b7247e 100644
--- a/drivers/net/sun3lance.c
+++ b/drivers/net/sun3lance.c
@@ -839,7 +839,7 @@ static int lance_rx( struct net_device *dev )
 
 				skb_reserve( skb, 2 );	/* 16 byte align */
 				skb_put( skb, pkt_len );	/* Make room */
-//			        memcpy( skb->data, PKTBUF_ADDR(head), pkt_len );
+//			        skb_store_bits(skb, 0, PKTBUF_ADDR(head), pkt_len);
 				eth_copy_and_sum(skb,
 						 PKTBUF_ADDR(head),
 						 pkt_len, 0);
diff --git a/drivers/net/tokenring/smctr.c b/drivers/net/tokenring/smctr.c
index b0296d8..e6260fc 100644
--- a/drivers/net/tokenring/smctr.c
+++ b/drivers/net/tokenring/smctr.c
@@ -3889,7 +3889,7 @@ static int smctr_process_rx_packet(MAC_HEADER *rmf, __u16 size,
 
                 /* Slide data into a sleek skb. */
                 skb_put(skb, skb->len);
-                memcpy(skb->data, rmf, skb->len);
+                skb_store_bits(skb, 0, rmf, skb->len);
 
                 /* Update Counters */
                 tp->MacStat.rx_packets++;
@@ -4475,7 +4475,7 @@ static int smctr_rx_frame(struct net_device *dev)
 				if (skb) {
                                 	skb_put(skb, rx_size);
 
-                                	memcpy(skb->data, pbuff, rx_size);
+                                	skb_store_bits(skb, 0, pbuff, rx_size);
 
                                 	/* Update Counters */
                                 	tp->MacStat.rx_packets++;
diff --git a/drivers/net/tokenring/tms380tr.c b/drivers/net/tokenring/tms380tr.c
index d061907..33f50a4 100644
--- a/drivers/net/tokenring/tms380tr.c
+++ b/drivers/net/tokenring/tms380tr.c
@@ -2178,7 +2178,8 @@ static void tms380tr_rcv_status_irq(struct net_device *dev)
 				|| rpl->SkbStat == SKB_DMA_DIRECT))
 			{
 				if(rpl->SkbStat == SKB_DATA_COPY)
-					memcpy(skb->data, ReceiveDataPtr, Length);
+					skb_store_bits(skb, 0, ReceiveDataPtr,
+						       Length);
 
 				/* Deliver frame to system */
 				rpl->Skb = NULL;
diff --git a/drivers/net/wan/dscc4.c b/drivers/net/wan/dscc4.c
index 25021a7..0b204e1 100644
--- a/drivers/net/wan/dscc4.c
+++ b/drivers/net/wan/dscc4.c
@@ -1904,7 +1904,8 @@ static struct sk_buff *dscc4_init_dummy_skb(struct dscc4_dev_priv *dpriv)
 		struct TxFD *tx_fd = dpriv->tx_fd + last;
 
 		skb->len = DUMMY_SKB_SIZE;
-		memcpy(skb->data, version, strlen(version)%DUMMY_SKB_SIZE);
+		skb_store_bits(skb, 0, version,
+			       strlen(version) % DUMMY_SKB_SIZE);
 		tx_fd->state = FrameEnd | TO_STATE_TX(DUMMY_SKB_SIZE);
 		tx_fd->data = pci_map_single(dpriv->pci_priv->pdev, skb->data,
 					     DUMMY_SKB_SIZE, PCI_DMA_TODEVICE);
diff --git a/drivers/net/wan/pc300_drv.c b/drivers/net/wan/pc300_drv.c
index 7ea7b94..44d4c36 100644
--- a/drivers/net/wan/pc300_drv.c
+++ b/drivers/net/wan/pc300_drv.c
@@ -1759,7 +1759,7 @@ cpc_trace(struct net_device *dev, struct sk_buff *skb_main, char rx_tx)
 	skb->pkt_type = PACKET_HOST;
 	skb->len = 10 + skb_main->len;
 
-	memcpy(skb->data, dev->name, 5);
+	skb_store_bits(skb, 0, dev->name, 5);
 	skb->data[5] = '[';
 	skb->data[6] = rx_tx;
 	skb->data[7] = ']';
diff --git a/drivers/net/wan/pc300_tty.c b/drivers/net/wan/pc300_tty.c
index de02a07..0c56c67 100644
--- a/drivers/net/wan/pc300_tty.c
+++ b/drivers/net/wan/pc300_tty.c
@@ -1007,13 +1007,13 @@ static void cpc_tty_trace(pc300dev_t *dev, char* buf, int len, char rxtx)
 	skb->pkt_type = PACKET_HOST; 
 	skb->len = 10 + len; 
 
-	memcpy(skb->data,dev->dev->name,5);
+	skb_store_bits(skb, 0, dev->dev->name, 5);
 	skb->data[5] = '['; 
 	skb->data[6] = rxtx; 
 	skb->data[7] = ']'; 
 	skb->data[8] = ':'; 
 	skb->data[9] = ' '; 
-	memcpy(&skb->data[10], buf, len); 
+	skb_store_bits(skb, 10, buf, len); 
 	netif_rx(skb); 
 } 	
 
diff --git a/drivers/net/wan/z85230.c b/drivers/net/wan/z85230.c
index 5b1730a..ebfbf39 100644
--- a/drivers/net/wan/z85230.c
+++ b/drivers/net/wan/z85230.c
@@ -1656,7 +1656,7 @@ static void z8530_rx_done(struct z8530_channel *c)
 		else
 		{
 			skb_put(skb, ct);
-			memcpy(skb->data, rxb, ct);
+			skb_store_bits(skb, 0, rxb, ct);
 			c->stats.rx_packets++;
 			c->stats.rx_bytes+=ct;
 		}
diff --git a/drivers/net/wireless/prism54/islpci_eth.c b/drivers/net/wireless/prism54/islpci_eth.c
index 94c38e2..787d423 100644
--- a/drivers/net/wireless/prism54/islpci_eth.c
+++ b/drivers/net/wireless/prism54/islpci_eth.c
@@ -136,7 +136,7 @@ islpci_eth_transmit(struct sk_buff *skb, struct net_device *ndev)
 				printk("islpci_eth_transmit:wds_mac\n");
 #endif
 				memmove(skb->data + 6, src, skb->len);
-				memcpy(skb->data, wds_mac, 6);
+				skb_store_bits(skb, 0, wds_mac, 6);
 			} else {
 				memmove(skb->data, src, skb->len);
 			}
@@ -164,7 +164,7 @@ islpci_eth_transmit(struct sk_buff *skb, struct net_device *ndev)
 			if (init_wds) {
 				skb_copy_bits(skb, 0,
 					      newskb->data + 6, skb->len);
-				memcpy(newskb->data, wds_mac, 6);
+				skb_store_bits(newskb, 0, wds_mac, 6);
 #ifdef ISLPCI_ETH_DEBUG
 				printk("islpci_eth_transmit:wds_mac\n");
 #endif
diff --git a/drivers/usb/atm/usbatm.c b/drivers/usb/atm/usbatm.c
index ba36acd..1818958 100644
--- a/drivers/usb/atm/usbatm.c
+++ b/drivers/usb/atm/usbatm.c
@@ -396,7 +396,8 @@ static void usbatm_extract_one_cell(struct usbatm_data *instance, unsigned char
 			goto out;	/* atm_charge increments rx_drop */
 		}
 
-		memcpy(skb->data, skb_tail_pointer(sarb) - pdu_length, length);
+		skb_store_bits(skb, 0, skb_tail_pointer(sarb) - pdu_length,
+			       length);
 		__skb_put(skb, length);
 
 		vdbg("%s: sending skb 0x%p, skb->len %u, skb->truesize %u",
diff --git a/drivers/usb/net/asix.c b/drivers/usb/net/asix.c
index f56e2da..f107f87 100644
--- a/drivers/usb/net/asix.c
+++ b/drivers/usb/net/asix.c
@@ -352,7 +352,7 @@ static struct sk_buff *asix_tx_fixup(struct usbnet *dev, struct sk_buff *skb,
 	skb_push(skb, 4);
 	packet_len = (((skb->len - 4) ^ 0x0000ffff) << 16) + (skb->len - 4);
 	cpu_to_le32s(&packet_len);
-	memcpy(skb->data, &packet_len, sizeof(packet_len));
+	skb_store_bits(skb, 0, &packet_len, sizeof(packet_len));
 
 	if ((skb->len % 512) == 0) {
 		cpu_to_le32s(&padbytes);
diff --git a/net/ipv4/ipcomp.c b/net/ipv4/ipcomp.c
index ba348b1..35868b7 100644
--- a/net/ipv4/ipcomp.c
+++ b/net/ipv4/ipcomp.c
@@ -66,7 +66,7 @@ static int ipcomp_decompress(struct xfrm_state *x, struct sk_buff *skb)
 
 	skb->truesize += dlen - plen;
 	__skb_put(skb, dlen - plen);
-	memcpy(skb->data, scratch, dlen);
+	skb_store_bits(skb, 0, scratch, dlen);
 out:
 	put_cpu();
 	return err;
diff --git a/net/ipv4/ipvs/ip_vs_app.c b/net/ipv4/ipvs/ip_vs_app.c
index c8a822c..6bc3245 100644
--- a/net/ipv4/ipvs/ip_vs_app.c
+++ b/net/ipv4/ipvs/ip_vs_app.c
@@ -602,7 +602,7 @@ int ip_vs_skb_replace(struct sk_buff *skb, gfp_t pri,
 		skb_put(skb, diff);
 		memmove(skb->data + o_offset + n_len,
 			skb->data + o_offset + o_len, o_left);
-		memcpy(skb->data + o_offset, n_buf, n_len);
+		skb_store_bits(skb, o_offset, n_buf, n_len);
 	}
 
 	/* must update the iph total length here */
diff --git a/net/irda/irttp.c b/net/irda/irttp.c
index 0561def..a696a65 100644
--- a/net/irda/irttp.c
+++ b/net/irda/irttp.c
@@ -256,7 +256,7 @@ static struct sk_buff *irttp_reassemble_skb(struct tsap_cb *self)
 	 *  Copy all fragments to a new buffer
 	 */
 	while ((frag = skb_dequeue(&self->rx_fragments)) != NULL) {
-		memcpy(skb->data+n, frag->data, frag->len);
+		skb_store_bits(skb, n, frag->data, frag->len);
 		n += frag->len;
 
 		dev_kfree_skb(frag);
-- 
1.5.0.3

