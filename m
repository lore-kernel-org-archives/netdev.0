From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 4/8]  2.6.5-rc2 - sis190 update
Date: Sat, 27 Mar 2004 03:13:51 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040327031351.D31053@electric-eye.fr.zoreil.com>
References: <20040327030853.A30849@electric-eye.fr.zoreil.com> <20040327031131.A31053@electric-eye.fr.zoreil.com> <20040327031219.B31053@electric-eye.fr.zoreil.com> <20040327031302.C31053@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20040327031302.C31053@electric-eye.fr.zoreil.com>; from romieu@fr.zoreil.com on Sat, Mar 27, 2004 at 03:13:02AM +0100
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


New helpers (shamelessly stolen from r8169 driver):
- sis190_mark_as_last_descriptor;
- sis190_give_to_asic.


 drivers/net/sis190.c |   20 ++++++++++++++------
 1 files changed, 14 insertions(+), 6 deletions(-)

diff -puN drivers/net/sis190.c~sis190-dma-api-rx-buffers-00 drivers/net/sis190.c
--- linux-2.6.5-rc2/drivers/net/sis190.c~sis190-dma-api-rx-buffers-00	2004-03-27 02:35:56.000000000 +0100
+++ linux-2.6.5-rc2-fr/drivers/net/sis190.c	2004-03-27 02:36:46.000000000 +0100
@@ -806,6 +806,17 @@ SiS190_hw_start(struct net_device *dev)
 
 }
 
+static inline void sis190_mark_as_last_descriptor(struct RxDesc *desc)
+{
+	desc->buf_Len |= cpu_to_le32(ENDbit);
+}
+
+static inline void sis190_give_to_asic(struct RxDesc *desc, dma_addr_t mapping)
+{
+	desc->buf_addr = cpu_to_le32(mapping);
+	desc->status |= cpu_to_le32(OWNbit | INTbit);
+}
+
 static int SiS190_init_ring(struct net_device *dev)
 {
 	struct sis190_private *tp = dev->priv;
@@ -828,19 +839,16 @@ static int SiS190_init_ring(struct net_d
 	for (i = 0; i < NUM_RX_DESC; i++) {
 		struct RxDesc *desc = tp->RxDescArray + i;
 		dma_addr_t mapping;
-		u32 len;
 
 		desc->PSize = 0x0;
-
-		len = RX_BUF_SIZE + ENDbit * !((i + 1) % NUM_RX_DESC);
+		desc->buf_Len = cpu_to_le32(RX_BUF_SIZE);
 
 		tp->RxBufferRing[i] = tp->RxBufferRings + i * RX_BUF_SIZE;
 		mapping = pci_map_single(tp->pci_dev,
 			tp->RxBufferRing[i], RX_BUF_SIZE, PCI_DMA_FROMDEVICE);
-		desc->buf_addr = cpu_to_le32(mapping);
-		desc->buf_Len = cpu_to_le32(len);
-		desc->status = cpu_to_le32(OWNbit | INTbit);
+		sis190_give_to_asic(desc, mapping);
 	}
+	sis190_mark_as_last_descriptor(tp->RxDescArray + NUM_RX_DESC - 1);
 
 	return 0;
 

_
