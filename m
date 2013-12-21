From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH 4/5] drivers: net: APM X-Gene SoC Ethernet driver error
 handling
Date: Fri, 20 Dec 2013 19:42:55 -0800
Message-ID: <1387597376-29303-5-git-send-email-isubramanian@apm.com>
References: <1387597376-29303-1-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org, gregkh@linuxfoundation.org,
 Iyappan Subramanian <isubramanian@apm.com>, patches@apm.com,
 linux-kernel@vger.kernel.org, netdev@vger.kernel.org, jcm@redhat.com,
 Keyur Chudgar <kchudgar@apm.com>, linux-arm-kernel@lists.infradead.org,
 Ravi Patel <rapatel@apm.com>
To: davem@davemloft.net
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1387597376-29303-1-git-send-email-isubramanian@apm.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Error handling and error interrupt handler code.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Signed-off-by: Ravi Patel <rapatel@apm.com>
Signed-off-by: Keyur Chudgar <kchudgar@apm.com>
---
 drivers/net/ethernet/apm/xgene/Makefile          |    3 +-
 drivers/net/ethernet/apm/xgene/xgene_enet_csr.h  |  265 +++++++-
 drivers/net/ethernet/apm/xgene/xgene_enet_err.c  |  715 ++++++++++++++++++++++
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c |   27 +
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h |    4 +
 5 files changed, 1011 insertions(+), 3 deletions(-)
 create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_err.c

diff --git a/drivers/net/ethernet/apm/xgene/Makefile b/drivers/net/ethernet/apm/xgene/Makefile
index 16dfc6c..091547e 100644
--- a/drivers/net/ethernet/apm/xgene/Makefile
+++ b/drivers/net/ethernet/apm/xgene/Makefile
@@ -5,6 +5,7 @@
 xgene-enet-objs := \
 		xgene_enet_common.o	\
 		xgene_enet_mac.o	\
-		xgene_enet_main.o
+		xgene_enet_main.o	\
+		xgene_enet_err.o
 
 obj-$(CONFIG_NET_XGENE) += xgene-enet.o
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_csr.h b/drivers/net/ethernet/apm/xgene/xgene_enet_csr.h
index c6b49c9..858d155 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_csr.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_csr.h
@@ -19,6 +19,13 @@
 #ifndef __XGENE_ENET_CSR_H__
 #define __XGENE_ENET_CSR_H__
 
+#define RSIF_INT_REG0_ADDR                                           0x00000054
+#define RSIF_FINT_REG0_ADDR                                          0x0000005c
+#define TSIF_INT_REG0_ADDR                                           0x0000012c
+#define TSIF_FINT_REG0_ADDR                                          0x00000134
+#define TSO_INT_REG0_ADDR                                            0x00000324
+#define SPI2SAP_INT_REG0_ADDR                                        0x00000448
+#define RX_TX_BUF_CHKSM_INT_REG0_ADDR                                0x0000052c
 #define ENET_SPARE_CFG_REG_ADDR                                      0x00000750
 #define RSIF_CONFIG_REG_ADDR                                         0x00000010
 #define RSIF_RAM_DBG_REG0_ADDR                                       0x00000048
@@ -33,7 +40,108 @@
 #define TSIF_MSS_REG1_0_ADDR                                         0x00000110
 #define TSO_CFG_0_ADDR                                               0x00000314
 #define TSO_CFG_INSERT_VLAN_0_ADDR                                   0x0000031c
-#define CFG_RSIF_FPBUFF_TIMEOUT_EN_WR(src)      (((u32)(src)<<31) & 0x80000000)
+#define CFG_RSIF_FPBUFF_TIMEOUT_EN_WR(src) \
+	(((u32)(src)<<31) & 0x80000000)
+#define RSIF_LCL_RXBUF_FIFO_OVERFL_INTR_RXPRT10_MASK                 0x20000000
+#define RSIF_LCL_RXBUF_FIFO_OVERFL_INTR_RXPRT10_RD(src) \
+	(((src) & 0x20000000)>>29)
+#define RSIF_LCL_RXBUF_FIFO_UNDERFL_INTR_RXPRT10_MASK                0x10000000
+#define RSIF_LCL_RXBUF_FIFO_UNDERFL_INTR_RXPRT10_RD(src) \
+	(((src) & 0x10000000)>>28)
+#define RSIF_CHKSUM_BUFF_FIFO_OVERFL_INTR_RXPRT10_MASK               0x08000000
+#define RSIF_CHKSUM_BUFF_FIFO_OVERFL_INTR_RXPRT10_RD(src) \
+	(((src) & 0x08000000)>>27)
+#define RSIF_CHKSUM_BUFF_FIFO_UNDERFL_INTR_RXPRT10_MASK              0x04000000
+#define RSIF_CHKSUM_BUFF_FIFO_UNDERFL_INTR_RXPRT10_RD(src) \
+	(((src) & 0x04000000)>>26)
+#define RSIF_TIMESTAMP_BUFF_FIFO_OVERFL_INTR_RXPRT10_MASK            0x02000000
+#define RSIF_TIMESTAMP_BUFF_FIFO_OVERFL_INTR_RXPRT10_RD(src) \
+	(((src) & 0x02000000)>>25)
+#define RSIF_TIMESTAMP_BUFF_FIFO_UNDERFL_INTR_RXPRT10_MASK           0x01000000
+#define RSIF_TIMESTAMP_BUFF_FIFO_UNDERFL_INTR_RXPRT10_RD(src) \
+	(((src) & 0x01000000)>>24)
+#define RSIF_ERR_BUFF_FIFO_OVERFL_INTR_RXPRT10_MASK                  0x00800000
+#define RSIF_ERR_BUFF_FIFO_OVERFL_INTR_RXPRT10_RD(src) \
+	(((src) & 0x00800000)>>23)
+#define RSIF_ERR_BUFF_FIFO_UNDERFL_INTR_RXPRT10_MASK                 0x00400000
+#define RSIF_ERR_BUFF_FIFO_UNDERFL_INTR_RXPRT10_RD(src) \
+	(((src) & 0x00400000)>>22)
+#define RSIF_CLEBUFF_FIFO_OVERFL_INTR_RXPRT10_MASK                   0x00200000
+#define RSIF_CLEBUFF_FIFO_OVERFL_INTR_RXPRT10_RD(src) \
+	(((src) & 0x00200000)>>21)
+#define RSIF_CLEBUFF_FIFO_UNDERFL_INTR_RXPRT10_MASK                  0x00100000
+#define RSIF_CLEBUFF_FIFO_UNDERFL_INTR_RXPRT10_RD(src) \
+	(((src) & 0x00100000)>>20)
+#define RSIF_CTRLBUFF_FIFO_OVERFL_INTR_RXPRT10_MASK                  0x00080000
+#define RSIF_CTRLBUFF_FIFO_OVERFL_INTR_RXPRT10_RD(src) \
+	(((src) & 0x00080000)>>19)
+#define RSIF_CTRLBUFF_FIFO_UNDERFL_INTR_RXPRT10_MASK                 0x00040000
+#define RSIF_CTRLBUFF_FIFO_UNDERFL_INTR_RXPRT10_RD(src) \
+	(((src) & 0x00040000)>>18)
+#define RSIF_BUF_FIFO_OVERFL_INTR_RXPRT10_MASK                       0x00020000
+#define RSIF_BUF_FIFO_OVERFL_INTR_RXPRT10_RD(src) \
+	(((src) & 0x00020000)>>17)
+#define RSIF_BUF_FIFO_UNDERFL_INTR_RXPRT10_MASK                      0x00010000
+#define RSIF_BUF_FIFO_UNDERFL_INTR_RXPRT10_RD(src) \
+	(((src) & 0x00010000)>>16)
+#define ENET_RSIF_PLC_CLEBUFF_FIFO_OVERFL_INTR0_MASK              0x00008000
+#define ENET_RSIF_PLC_CLEBUFF_FIFO_OVERFL_INTR0_RD(src) \
+	(((src) & 0x00008000)>>15)
+#define ENET_RSIF_PLC_CLEBUFF_FIFO_UNDERFL_INTR0_RD(src) \
+	(((src) & 0x00004000)>>14)
+#define RSIF_LCL_RXBUF_FIFO_UNDERFL_INTR_RXPRT00_MASK                0x00001000
+#define RSIF_LCL_RXBUF_FIFO_UNDERFL_INTR_RXPRT00_RD(src) \
+	(((src) & 0x00001000)>>12)
+#define RSIF_LCL_RXBUF_FIFO_OVERFL_INTR_RXPRT00_MASK                 0x00002000
+#define RSIF_LCL_RXBUF_FIFO_OVERFL_INTR_RXPRT00_RD(src) \
+	(((src) & 0x00002000)>>13)
+#define RSIF_CHKSUM_BUFF_FIFO_OVERFL_INTR_RXPRT00_MASK               0x00000800
+#define RSIF_CHKSUM_BUFF_FIFO_OVERFL_INTR_RXPRT00_RD(src) \
+	(((src) & 0x00000800)>>11)
+#define RSIF_CHKSUM_BUFF_FIFO_UNDERFL_INTR_RXPRT00_MASK              0x00000400
+#define RSIF_CHKSUM_BUFF_FIFO_UNDERFL_INTR_RXPRT00_RD(src) \
+	(((src) & 0x00000400)>>10)
+#define RSIF_TIMESTAMP_BUFF_FIFO_OVERFL_INTR_RXPRT00_MASK            0x00000200
+#define RSIF_TIMESTAMP_BUFF_FIFO_OVERFL_INTR_RXPRT00_RD(src) \
+	(((src) & 0x00000200)>>9)
+#define RSIF_TIMESTAMP_BUFF_FIFO_UNDERFL_INTR_RXPRT00_MASK           0x00000100
+#define RSIF_TIMESTAMP_BUFF_FIFO_UNDERFL_INTR_RXPRT00_RD(src) \
+	(((src) & 0x00000100)>>8)
+#define RSIF_ERR_BUFF_FIFO_OVERFL_INTR_RXPRT00_MASK                  0x00000080
+#define RSIF_ERR_BUFF_FIFO_OVERFL_INTR_RXPRT00_RD(src) (((src) & 0x00000080)>>7)
+#define RSIF_ERR_BUFF_FIFO_UNDERFL_INTR_RXPRT00_MASK                 0x00000040
+#define RSIF_ERR_BUFF_FIFO_UNDERFL_INTR_RXPRT00_RD(src) \
+	(((src) & 0x00000040)>>6)
+#define RSIF_CLEBUFF_FIFO_OVERFL_INTR_RXPRT00_MASK                   0x00000020
+#define RSIF_CLEBUFF_FIFO_OVERFL_INTR_RXPRT00_RD(src) (((src) & 0x00000020)>>5)
+#define RSIF_CLEBUFF_FIFO_UNDERFL_INTR_RXPRT00_MASK                  0x00000010
+#define RSIF_CLEBUFF_FIFO_UNDERFL_INTR_RXPRT00_RD(src) (((src) & 0x00000010)>>4)
+#define RSIF_CTRLBUFF_FIFO_OVERFL_INTR_RXPRT00_MASK                  0x00000008
+#define RSIF_CTRLBUFF_FIFO_OVERFL_INTR_RXPRT00_RD(src) (((src) & 0x00000008)>>3)
+#define RSIF_CTRLBUFF_FIFO_UNDERFL_INTR_RXPRT00_MASK                 0x00000004
+#define RSIF_CTRLBUFF_FIFO_UNDERFL_INTR_RXPRT00_RD(src) \
+	(((src) & 0x00000004)>>2)
+#define RSIF_BUF_FIFO_OVERFL_INTR_RXPRT00_MASK                       0x00000002
+#define RSIF_BUF_FIFO_OVERFL_INTR_RXPRT00_RD(src)     (((src) & 0x00000002)>>1)
+#define RSIF_BUF_FIFO_UNDERFL_INTR_RXPRT00_MASK                      0x00000001
+#define RSIF_BUF_FIFO_UNDERFL_INTR_RXPRT00_RD(src)       (((src) & 0x00000001))
+#define RSIF_SS_MIRRORERR_INTR_RXPRT10_MASK                          0x00080000
+#define RSIF_SS_MIRRORERR_INTR_RXPRT10_RD(src)       (((src) & 0x00080000)>>19)
+#define RSIF_SS_SPLIT_BOUNDARY_INTR_RXPRT10_RD(src)  (((src) & 0x00040000)>>18)
+#define RSIF_SS_FPBUFF_TIMEOUT_INTR_RXPRT10_MASK                     0x00020000
+#define RSIF_SS_FPBUFF_TIMEOUT_INTR_RXPRT10_RD(src)  (((src) & 0x00020000)>>17)
+#define RSIF_SS_AXI_WRERR_INTR_RXPRT10_MASK                          0x00010000
+#define RSIF_SS_AXI_WRERR_INTR_RXPRT10_RD(src)       (((src) & 0x00010000)>>16)
+#define RSIF_SS_MIRRORERR_INTR_RXPRT00_MASK                          0x00000010
+#define RSIF_SS_MIRRORERR_INTR_RXPRT00_RD(src)        (((src) & 0x00000010)>>4)
+#define RSIF_SS_SPLIT_BOUNDARY_INTR_RXPRT00_MASK                     0x00000008
+#define RSIF_SS_SPLIT_BOUNDARY_INTR_RXPRT00_RD(src)   (((src) & 0x00000008)>>3)
+#define RSIF_SS_FPBUFF_TIMEOUT_INTR_RXPRT00_MASK                     0x00000004
+#define RSIF_SS_FPBUFF_TIMEOUT_INTR_RXPRT00_RD(src)   (((src) & 0x00000004)>>2)
+#define RSIF_SS_AXI_WRERR_INTR_RXPRT00_MASK                          0x00000002
+#define RSIF_SS_AXI_WRERR_INTR_RXPRT00_RD(src)        (((src) & 0x00000002)>>1)
+#define STS_RSIF_PLC_DROP0_MASK                                      0x00000001
+#define STS_RSIF_PLC_DROP0_RD(src)                       (((src) & 0x00000001))
 #define CFG_TSIF_MSS_SZ10_SET(dst, src) \
 	(((dst) & ~0x3fff0000) | (((u32)(src)<<16) & 0x3fff0000))
 #define CFG_TSIF_MSS_SZ00_SET(dst, src) \
@@ -42,7 +150,99 @@
 	(((dst) & ~0x00003fff) | (((u32)(src)) & 0x00003fff))
 #define CFG_TSIF_MSS_SZ30_SET(dst, src) \
 	(((dst) & ~0x3fff0000) | (((u32)(src)<<16) & 0x3fff0000))
+#define TSIF_RDMBUFF_FIFO_OVERFL_INTR_PRT10_MASK                     0x00200000
+#define TSIF_RDMBUFF_FIFO_OVERFL_INTR_PRT10_RD(src)  (((src) & 0x00200000)>>21)
+#define TSIF_RDMBUFF_FIFO_UNDERFL_INTR_PRT10_MASK                    0x00100000
+#define TSIF_RDMBUFF_FIFO_UNDERFL_INTR_PRT10_RD(src) (((src) & 0x00100000)>>20)
+#define TSIF_RRM_FIFO_OVERFL_INTR_PRT10_MASK                         0x00080000
+#define TSIF_RRM_FIFO_OVERFL_INTR_PRT10_RD(src)      (((src) & 0x00080000)>>19)
+#define TSIF_RRM_FIFO_UNDERFL_INTR_PRT10_MASK                        0x00040000
+#define TSIF_RRM_FIFO_UNDERFL_INTR_PRT10_RD(src)     (((src) & 0x00040000)>>18)
+#define TSIF_AMABUF_FIFO_OVERFL_INTR_PRT10_MASK                      0x00020000
+#define TSIF_AMABUF_FIFO_OVERFL_INTR_PRT10_RD(src)   (((src) & 0x00020000)>>17)
+#define TSIF_AMABUF_FIFO_UNDERFL_INTR_PRT10_MASK                     0x00010000
+#define TSIF_AMABUF_FIFO_UNDERFL_INTR_PRT10_RD(src)  (((src) & 0x00010000)>>16)
+#define TSIF_RDMBUFF_FIFO_OVERFL_INTR_PRT00_MASK                     0x00000020
+#define TSIF_RDMBUFF_FIFO_OVERFL_INTR_PRT00_RD(src)   (((src) & 0x00000020)>>5)
+#define TSIF_RDMBUFF_FIFO_UNDERFL_INTR_PRT00_MASK                    0x00000010
+#define TSIF_RDMBUFF_FIFO_UNDERFL_INTR_PRT00_RD(src)  (((src) & 0x00000010)>>4)
+#define TSIF_RRM_FIFO_OVERFL_INTR_PRT00_MASK                         0x00000008
+#define TSIF_RRM_FIFO_OVERFL_INTR_PRT00_RD(src)       (((src) & 0x00000008)>>3)
+#define TSIF_RRM_FIFO_UNDERFL_INTR_PRT00_MASK                        0x00000004
+#define TSIF_RRM_FIFO_UNDERFL_INTR_PRT00_RD(src)      (((src) & 0x00000004)>>2)
+#define TSIF_AMABUF_FIFO_OVERFL_INTR_PRT00_MASK                      0x00000002
+#define TSIF_AMABUF_FIFO_OVERFL_INTR_PRT00_RD(src)    (((src) & 0x00000002)>>1)
+#define TSIF_AMABUF_FIFO_UNDERFL_INTR_PRT00_MASK                     0x00000001
+#define TSIF_AMABUF_FIFO_UNDERFL_INTR_PRT00_RD(src)      (((src) & 0x00000001))
+#define TSIF_SS_AXI_LLRDERR_INTR_PRT10_MASK                          0x00040000
+#define TSIF_SS_AXI_LLRDERR_INTR_PRT10_RD(src)       (((src) & 0x00040000)>>18)
+#define TSIF_SS_AXI_RDERR_INTR_PRT10_MASK                            0x00020000
+#define TSIF_SS_AXI_RDERR_INTR_PRT10_RD(src)         (((src) & 0x00020000)>>17)
+#define TSIF_SS_BAD_MSG_INTR_PRT10_MASK                              0x00010000
+#define TSIF_SS_BAD_MSG_INTR_PRT10_RD(src)           (((src) & 0x00010000)>>16)
+#define TSIF_SS_AXI_LLRDERR_INTR_PRT00_MASK                          0x00000004
+#define TSIF_SS_AXI_LLRDERR_INTR_PRT00_RD(src)        (((src) & 0x00000004)>>2)
+#define TSIF_SS_AXI_RDERR_INTR_PRT00_MASK                            0x00000002
+#define TSIF_SS_AXI_RDERR_INTR_PRT00_RD(src)          (((src) & 0x00000002)>>1)
+#define TSIF_SS_BAD_MSG_INTR_PRT00_MASK                              0x00000001
+#define TSIF_SS_BAD_MSG_INTR_PRT00_RD(src)               (((src) & 0x00000001))
 #define RESUME_TX_WR(src)                           (((u32)(src)) & 0x00000001)
+#define MB_TTF_FIFO_OVERFL_INTR_PRT10_RD(src)        (((src) & 0x00200000)>>21)
+#define MB_TTF_FIFO_OVERFL_INTR_PRT10_MASK                           0x00200000
+#define MB_TTF_FIFO_UNDERFL_INTR_PRT10_RD(src)       (((src) & 0x00100000)>>20)
+#define MB_TTF_FIFO_UNDERFL_INTR_PRT10_MASK                          0x00100000
+#define MH_DEALLOC_FIFO_OVERFL_INTR_PRT10_RD(src)    (((src) & 0x00080000)>>19)
+#define MH_DEALLOC_FIFO_OVERFL_INTR_PRT10_MASK                       0x00080000
+#define MH_DEALLOC_FIFO_UNDERFL_INTR_PRT10_RD(src)   (((src) & 0x00040000)>>18)
+#define MH_DEALLOC_FIFO_UNDERFL_INTR_PRT10_MASK                      0x00040000
+#define MH_FIFO_OVERFL_INTR_PRT10_RD(src)            (((src) & 0x00020000)>>17)
+#define MH_FIFO_OVERFL_INTR_PRT10_MASK                               0x00020000
+#define MH_FIFO_UNDERFL_INTR_PRT10_RD(src)           (((src) & 0x00010000)>>16)
+#define MH_FIFO_UNDERFL_INTR_PRT10_MASK                              0x00010000
+#define MB_TTF_FIFO_OVERFL_INTR_PRT00_RD(src)         (((src) & 0x00000020)>>5)
+#define MB_TTF_FIFO_OVERFL_INTR_PRT00_MASK                           0x00000020
+#define MB_TTF_FIFO_UNDERFL_INTR_PRT00_RD(src)        (((src) & 0x00000010)>>4)
+#define MB_TTF_FIFO_UNDERFL_INTR_PRT00_MASK                          0x00000010
+#define MH_DEALLOC_FIFO_OVERFL_INTR_PRT00_RD(src)     (((src) & 0x00000008)>>3)
+#define MH_DEALLOC_FIFO_OVERFL_INTR_PRT00_MASK                       0x00000008
+#define MH_DEALLOC_FIFO_UNDERFL_INTR_PRT00_RD(src)    (((src) & 0x00000004)>>2)
+#define MH_DEALLOC_FIFO_UNDERFL_INTR_PRT00_MASK                      0x00000004
+#define MH_FIFO_OVERFL_INTR_PRT00_RD(src)             (((src) & 0x00000002)>>1)
+#define MH_FIFO_OVERFL_INTR_PRT00_MASK                               0x00000002
+#define MH_FIFO_UNDERFL_INTR_PRT00_RD(src)               (((src) & 0x00000001))
+#define MH_FIFO_UNDERFL_INTR_PRT00_MASK                              0x00000001
+#define MACIF_FIFO_OVERFL_INTR_RXPRT10_RD(src)       (((src) & 0x00020000)>>17)
+#define MACIF_FIFO_OVERFL_INTR_RXPRT10_MASK                          0x00020000
+#define MACIF_FIFO_OVERFL_INTR_RXPRT00_RD(src)        (((src) & 0x00000002)>>1)
+#define MACIF_FIFO_OVERFL_INTR_RXPRT00_MASK                          0x00000002
+#define MACIF_FIFO_UNDERFL_INTR_RXPRT10_RD(src)      (((src) & 0x00010000)>>16)
+#define MACIF_FIFO_UNDERFL_INTR_RXPRT10_MASK                         0x00010000
+#define MACIF_FIFO_UNDERFL_INTR_RXPRT00_RD(src)          (((src) & 0x00000001))
+#define MACIF_FIFO_UNDERFL_INTR_RXPRT00_MASK                         0x00000001
+#define RXBUF_PAUSE_INTR_PORT10_RD(src)              (((src) & 0x00400000)>>22)
+#define RXBUF_PAUSE_INTR_PORT10_MASK                                 0x00400000
+#define RX_CHKSUM_INTR_PORT10_RD(src)                (((src) & 0x00200000)>>21)
+#define RX_CHKSUM_INTR_PORT10_MASK                                   0x00200000
+#define TX_CHKSUM_INTR_PORT10_RD(src)                (((src) & 0x00100000)>>20)
+#define TX_CHKSUM_INTR_PORT10_MASK                                   0x00100000
+#define RXBUF_FIFO_OVERFL_INTR_PRT10_RD(src)         (((src) & 0x00080000)>>19)
+#define RXBUF_FIFO_OVERFL_INTR_PRT10_MASK                            0x00080000
+#define RXBUF_FIFO_UNDERFL_INTR_PRT10_RD(src)        (((src) & 0x00040000)>>18)
+#define RXBUF_FIFO_UNDERFL_INTR_PRT10_MASK                           0x00040000
+#define TXBUF_FIFO_OVERFL_INTR_PRT10_RD(src)         (((src) & 0x00020000)>>17)
+#define TXBUF_FIFO_UNDERFL_INTR_PRT10_RD(src)        (((src) & 0x00010000)>>16)
+#define RXBUF_PAUSE_INTR_PORT00_RD(src)               (((src) & 0x00000040)>>6)
+#define RX_CHKSUM_INTR_PORT00_RD(src)                 (((src) & 0x00000020)>>5)
+#define RX_CHKSUM_INTR_PORT00_MASK                                   0x00000020
+#define RXBUF_PAUSE_INTR_PORT00_MASK                                 0x00000040
+#define TX_CHKSUM_INTR_PORT00_RD(src)                 (((src) & 0x00000010)>>4)
+#define TX_CHKSUM_INTR_PORT00_MASK                                   0x00000010
+#define RXBUF_FIFO_OVERFL_INTR_PRT00_RD(src)          (((src) & 0x00000008)>>3)
+#define RXBUF_FIFO_OVERFL_INTR_PRT00_MASK                            0x00000008
+#define RXBUF_FIFO_UNDERFL_INTR_PRT00_RD(src)         (((src) & 0x00000004)>>2)
+#define RXBUF_FIFO_UNDERFL_INTR_PRT00_MASK                           0x00000004
+#define TXBUF_FIFO_OVERFL_INTR_PRT00_RD(src)          (((src) & 0x00000002)>>1)
+#define TXBUF_FIFO_UNDERFL_INTR_PRT00_RD(src)            (((src) & 0x00000001))
 #define CFG_SPEED_1250_WR(src)                  (((u32)(src)<<24) & 0x01000000)
 #define CFG_TXCLK_MUXSEL0_WR(src)               (((u32)(src)<<29) & 0xe0000000)
 #define TX_PORT0_WR(src)                            (((u32)(src)) & 0x00000001)
@@ -58,6 +258,8 @@
 	(((dst) & ~0x000f0000) | (((u32)(src)<<16) & 0x000f0000))
 #define CFG_CLE_HENQNUM0_SET(dst, src) \
 	(((dst) & ~0x0fff0000) | (((u32)(src)<<16) & 0x0fff0000))
+#define MAC_INT_REG0_ADDR                                            0x00000514
+#define MAC_INT_REG1_ADDR                                            0x0000051c
 #define ICM_CONFIG0_REG_0_ADDR                                       0x00000400
 #define ICM_CONFIG2_REG_0_ADDR                                       0x00000410
 #define ECM_CONFIG0_REG_0_ADDR                                       0x00000500
@@ -68,10 +270,69 @@
 	(((dst) & ~0x00000002) | (((u32)(src)<<1) & 0x00000002))
 #define RESUME_RX0_SET(dst, src) \
 	(((dst) & ~0x00000001) | (((u32)(src)) & 0x00000001))
+#define ICM_DATA_FIFO_UNDERFL_INTR_PRT10_RD(src)     (((src) & 0x01000000)>>24)
+#define ICM_DATA_FIFO_UNDERFL_INTR_PRT10_MASK                        0x01000000
+#define ICM_DATA_FIFO_OVERFL_INTR_PRT10_MASK                         0x00800000
+#define ICM_CTRL_FIFO_OVERFL_INTR_PRT00_RD(src)       (((src) & 0x00000020)>>5)
+#define ICM_CTRL_FIFO_OVERFL_INTR_PRT00_MASK                         0x00000020
+#define ICM_CTRL_FIFO_OVERFL_INTR_PRT10_RD(src)      (((src) & 0x00200000)>>21)
+#define ICM_CTRL_FIFO_OVERFL_INTR_PRT10_MASK                         0x00200000
+#define ICM_CTRL_FIFO_UNDERFL_INTR_PRT10_RD(src)     (((src) & 0x00400000)>>22)
+#define ICM_CTRL_FIFO_UNDERFL_INTR_PRT10_MASK                        0x00400000
+#define ICM_CTRL_FIFO_UNDERFL_INTR_PRT00_RD(src)      (((src) & 0x00000040)>>6)
+#define ICM_CTRL_FIFO_UNDERFL_INTR_PRT00_MASK                        0x00000040
+#define ICM_DATA_FIFO_OVERFL_INTR_PRT00_RD(src)       (((src) & 0x00000080)>>7)
+#define ICM_DATA_FIFO_OVERFL_INTR_PRT10_RD(src)      (((src) & 0x00800000)>>23)
+#define ICM_DATA_FIFO_OVERFL_INTR_PRT00_MASK                         0x00000080
+#define ICM_DATA_FIFO_UNDERFL_INTR_PRT00_RD(src)      (((src) & 0x00000100)>>8)
+#define ICM_DATA_FIFO_UNDERFL_INTR_PRT00_MASK                        0x00000100
+#define ECM_DATA_FIFO_UNDERN_INTR_PRT00_RD(src)       (((src) & 0x00000010)>>4)
+#define ECM_DATA_FIFO_UNDERN_INTR_PRT00_MASK                         0x00000010
+#define ECM_DATA_FIFO_UNDERN_INTR_PRT10_RD(src)      (((src) & 0x00100000)>>20)
+#define ECM_DATA_FIFO_UNDERN_INTR_PRT10_MASK                         0x00100000
+#define ECM_DATA_FIFO_UNDERFL_INTR_PRT10_RD(src)     (((src) & 0x00080000)>>19)
+#define ECM_DATA_FIFO_UNDERFL_INTR_PRT10_MASK                        0x00080000
+#define ECM_DATA_FIFO_OVERFL_INTR_PRT10_RD(src)      (((src) & 0x00040000)>>18)
+#define ECM_DATA_FIFO_OVERFL_INTR_PRT10_MASK                         0x00040000
+#define CARRY_PORT01_RD(src)                             (((src) & 0x00000001))
+#define CARRY_PORT01_MASK                                            0x00000001
+#define LINKDOWN_PORT11_RD(src)                       (((src) & 0x00000008)>>3)
+#define LINKDOWN_PORT11_MASK                                         0x00000008
+#define CARRY_PORT11_RD(src)                          (((src) & 0x00000004)>>2)
+#define CARRY_PORT11_MASK                                            0x00000004
+#define LINKDOWN_PORT01_RD(src)                       (((src) & 0x00000002)>>1)
+#define LINKDOWN_PORT01_MASK                                         0x00000002
+#define MACIF_FIFO_UNDERFL_INTR_RXPRT00_F2_RD(src)    (((src) & 0x00000002)>>1)
+#define MACIF_FIFO_UNDERFL_INTR_RXPRT00_F2_MASK                      0x00000002
+#define MACIF_FIFO_UNDERFL_INTR_RXPRT10_F2_RD(src)   (((src) & 0x00020000)>>17)
+#define MACIF_FIFO_UNDERFL_INTR_RXPRT10_F2_MASK                      0x00020000
+#define MACIF_FIFO_OVERFL_INTR_RXPRT00_F2_RD(src)        (((src) & 0x00000001))
+#define MACIF_FIFO_OVERFL_INTR_RXPRT00_F2_MASK                       0x00000001
+#define MACIF_FIFO_OVERFL_INTR_RXPRT10_F2_RD(src)    (((src) & 0x00010000)>>16)
+#define MACIF_FIFO_OVERFL_INTR_RXPRT10_F2_MASK                       0x00010000
+#define ECM_DATA_FIFO_UNDERFL_INTR_PRT00_RD(src)      (((src) & 0x00000008)>>3)
+#define ECM_DATA_FIFO_UNDERFL_INTR_PRT00_MASK                        0x00000008
+#define ECM_DATA_FIFO_OVERFL_INTR_PRT00_RD(src)       (((src) & 0x00000004)>>2)
+#define ECM_DATA_FIFO_OVERFL_INTR_PRT00_MASK                         0x00000004
+#define ENET_STSSSQMIINT0_ADDR                                    0x0000009c
+#define ENET_STSSSQMIINT1_ADDR                                    0x000000a4
+#define ENET_STSSSQMIINT2_ADDR                                    0x000000ac
+#define ENET_STSSSQMIINT3_ADDR                                    0x000000b4
+#define ENET_STSSSQMIINT4_ADDR                                    0x000000bc
 #define ENET_CFGSSQMIWQASSOC_ADDR                                 0x000000e0
 #define ENET_CFGSSQMIFPQASSOC_ADDR                                0x000000dc
 #define ENET_CFGSSQMIQMLITEFPQASSOC_ADDR                          0x000000f0
 #define ENET_CFGSSQMIQMLITEWQASSOC_ADDR                           0x000000f4
+#define ENET_FPOVERFLOW0_RD(src)                      (((src) & 0xffffffff))
+#define ENET_WQOVERFLOW1_RD(src)                      (((src) & 0xffffffff))
+#define ENET_FPUNDERRUN2_RD(src)                      (((src) & 0xffffffff))
+#define ENET_WQUNDERRUN3_RD(src)                      (((src) & 0xffffffff))
+#define ENET_AXIWCMR_SLVERR4_RD(src)               (((src) & 0x00000002)>>1)
+#define ENET_AXIWCMR_SLVERR4_MASK                                 0x00000002
+#define ENET_FPOVERFLOW0_MASK                                     0xffffffff
+#define ENET_WQOVERFLOW1_MASK                                     0xffffffff
+#define ENET_FPUNDERRUN2_MASK                                     0xffffffff
+#define ENET_WQUNDERRUN3_MASK                                     0xffffffff
 #define ENET_CLKEN_ADDR                                              0x00000008
 #define ENET_SRST_ADDR                                               0x00000000
 #define CSR0_RESET_WR(src)                          (((u32)(src)) & 0x00000001)
@@ -159,4 +420,4 @@
 #define TX_FCS_ERROR_CNTR_MASK                                       0x00000fff
 #define TX_UNDSIZE_FRAME_CNTR_MASK                                   0x00000fff
 
-#endif /* __XGENE_ENET_CSR_H__ */
+#endif  /* __XGENE_ENET_CSR_H__ */
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_err.c b/drivers/net/ethernet/apm/xgene/xgene_enet_err.c
new file mode 100644
index 0000000..5be6531
--- /dev/null
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_err.c
@@ -0,0 +1,715 @@
+/* AppliedMicro X-Gene SoC Ethernet Driver
+ *
+ * Copyright (c) 2013, Applied Micro Circuits Corporation
+ * Authors:	Ravi Patel <rapatel@apm.com>
+ *		Iyappan Subramanian <isubramanian@apm.com>
+ *		Fushen Chen <fchen@apm.com>
+ *		Keyur Chudgar <kchudgar@apm.com>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published by
+ * the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+ * GNU General Public License for more details.
+ */
+
+#include "xgene_enet_main.h"
+#include "xgene_enet_csr.h"
+
+int xgene_enet_parse_error(u8 LErr, int qid)
+{
+	/* QM Error */
+	switch (LErr) {
+	case 1:
+		pr_err("LErr[%d] QID %d: QM msg size error\n", LErr, qid);
+		return 0;
+	case 2:
+		pr_err("LErr[%d] QID %d: QM msg hop count error\n", LErr, qid);
+		return 0;
+	case 3:
+		pr_err("LErr[%d] QID %d: enqueue to virtual queue error\n",
+		       LErr, qid);
+		return 0;
+	case 4:
+		pr_err("LErr[%d] QID %d: enqueue to disable queue error\n",
+		       LErr, qid);
+		return 0;
+	case 5:
+		pr_debug("LErr[%d] QID %d: queue overfill error\n", LErr, qid);
+		return 1;
+	case 6:
+		pr_err("LErr[%d] QID %d: QM enqueue error\n", LErr, qid);
+		return 0;
+	case 7:
+		pr_err("LErr[%d] QID %d: QM dequeue error\n", LErr, qid);
+		return 0;
+	}
+	return 0;
+}
+
+static irqreturn_t xgene_enet_qmi_err_irq(int irq, void *dev_instance)
+{
+	struct xgene_enet_pdev *pdev;
+	struct xgene_enet_priv *priv;
+	int rc;
+	u32 data;
+	u32 int_mask = 0;
+
+	pdev = netdev_priv(dev_instance);
+	priv = &pdev->priv;
+	pr_err("Received Ethernet QMI Error Interrupt\n");
+	rc = xgene_enet_rd(priv, BLOCK_ETH_CSR, ENET_STSSSQMIINT0_ADDR, &data);
+	if (data) {
+		pr_err("Received STSSSQMIINT0 Error intr\n");
+		if (ENET_FPOVERFLOW0_RD(data)) {
+			pr_err("FP PB overflow indication:0x%08X\n", data);
+			int_mask |= ENET_FPOVERFLOW0_MASK;
+		}
+		/* Clear intrstatus bits, its COW */
+		rc = xgene_enet_wr(priv, BLOCK_ETH_CSR,
+				   ENET_STSSSQMIINT0_ADDR, int_mask);
+	}
+	rc = xgene_enet_rd(priv, BLOCK_ETH_CSR, ENET_STSSSQMIINT1_ADDR, &data);
+	int_mask = 0;
+	if (data) {
+		pr_err("Received STSSSQMIINT1 Error Interrupt\n");
+		if (ENET_WQOVERFLOW1_RD(data)) {
+			pr_err("WQ PB overflow indication:0x%08X\n", data);
+			int_mask |= ENET_WQOVERFLOW1_MASK;
+		}
+		/* Clear intrstatus bits, its COW */
+		rc = xgene_enet_wr(priv, BLOCK_ETH_CSR,
+				   ENET_STSSSQMIINT1_ADDR, int_mask);
+	}
+	rc = xgene_enet_rd(priv, BLOCK_ETH_CSR, ENET_STSSSQMIINT2_ADDR, &data);
+	int_mask = 0;
+	if (data) {
+		pr_err("Received STSSSQMIINT2  Error Interrupt\n");
+		if (ENET_FPUNDERRUN2_RD(data)) {
+			pr_err("FP PB underrun indication:0x%08X\n", data);
+			int_mask |= ENET_FPUNDERRUN2_MASK;
+		}
+
+		/* Clear intrstatus bits, its COW */
+		rc = xgene_enet_wr(priv, BLOCK_ETH_CSR,
+				   ENET_STSSSQMIINT2_ADDR, int_mask);
+	}
+	rc = xgene_enet_rd(priv, BLOCK_ETH_CSR, ENET_STSSSQMIINT3_ADDR, &data);
+	int_mask = 0;
+	if (data) {
+		pr_err("Received STSSSQMIINT3 Error Interrupt\n");
+		if (ENET_WQUNDERRUN3_RD(data)) {
+			pr_err("WQ PB underrun indication:0x%08X\n", data);
+			int_mask |= ENET_WQUNDERRUN3_MASK;
+		}
+		/* Clear intrstatus bits, its COW */
+		rc = xgene_enet_wr(priv, BLOCK_ETH_CSR,
+				   ENET_STSSSQMIINT3_ADDR, int_mask);
+	}
+	rc = xgene_enet_rd(priv, BLOCK_ETH_CSR, ENET_STSSSQMIINT4_ADDR, &data);
+	int_mask = 0;
+	if (data) {
+		pr_err("Received STSSSQMIINT4 Error Interrupt\n");
+		if (ENET_AXIWCMR_SLVERR4_RD(data)) {
+			pr_err("AXI slave error on write  master channel\n");
+			int_mask |= ENET_AXIWCMR_SLVERR4_MASK;
+		}
+		/* Clear intrstatus bits, its COW */
+		rc = xgene_enet_wr(priv, BLOCK_ETH_CSR,
+				   ENET_STSSSQMIINT4_ADDR, int_mask);
+	}
+	return IRQ_HANDLED;
+}
+
+static irqreturn_t xgene_enet_mac_err_irq(int irq, void *dev_instance)
+{
+	struct xgene_enet_pdev *pdev;
+	struct xgene_enet_priv *priv;
+	int rc;
+	u32 data;
+	u32 int_mask = 0;
+
+	pdev = netdev_priv(dev_instance);
+	priv = &pdev->priv;
+	pr_err("Received Ethernet MAC Error Interrupt\n");
+
+	rc = xgene_enet_rd(priv, BLOCK_MCX_MAC_CSR, MAC_INT_REG0_ADDR, &data);
+	if (data) {
+		pr_err("Received MAC Error Interrupt\n");
+
+		if (ICM_DATA_FIFO_UNDERFL_INTR_PRT10_RD(data)) {
+			pr_err("RxPort1 ICM Data fifo underflow intr\n");
+			int_mask |= ICM_DATA_FIFO_UNDERFL_INTR_PRT10_MASK;
+		}
+		if (ICM_DATA_FIFO_OVERFL_INTR_PRT10_RD(data)) {
+			pr_err("RxPort1 ICM Data fifo overflow intr\n");
+			int_mask |= ICM_DATA_FIFO_OVERFL_INTR_PRT10_MASK;
+		}
+		if (ICM_CTRL_FIFO_UNDERFL_INTR_PRT10_RD(data)) {
+			pr_err("RxPort1 ICM Ctrl fifo underflow intr\n");
+			int_mask |= ICM_CTRL_FIFO_UNDERFL_INTR_PRT10_MASK;
+		}
+		if (ICM_CTRL_FIFO_OVERFL_INTR_PRT10_RD(data)) {
+			pr_err("RxPort1 ICM Ctrl fifo overflow intr\n");
+			int_mask |= ICM_CTRL_FIFO_OVERFL_INTR_PRT10_MASK;
+		}
+		if (ECM_DATA_FIFO_UNDERN_INTR_PRT10_RD(data)) {
+			pr_err("RxPort1 ECM Data fifo underrun intr\n");
+			int_mask |= ECM_DATA_FIFO_UNDERN_INTR_PRT10_MASK;
+		}
+		if (ECM_DATA_FIFO_UNDERFL_INTR_PRT10_RD(data)) {
+			pr_err("TxPort1 ECM Data fifo underflow intr\n");
+			int_mask |= ECM_DATA_FIFO_UNDERFL_INTR_PRT10_MASK;
+		}
+		if (ECM_DATA_FIFO_OVERFL_INTR_PRT10_RD(data)) {
+			pr_err("TxPort1 ECM Data fifo overflow intr\n");
+			int_mask |= ECM_DATA_FIFO_OVERFL_INTR_PRT10_MASK;
+		}
+		if (MACIF_FIFO_UNDERFL_INTR_RXPRT10_F2_RD(data)) {
+			pr_err("RxPort1 Mac i/f fifo underflow intr\n");
+			int_mask |= MACIF_FIFO_UNDERFL_INTR_RXPRT10_F2_MASK;
+		}
+		if (MACIF_FIFO_OVERFL_INTR_RXPRT10_F2_RD(data)) {
+			pr_err("RxPort1 Mac i/f fifo overflow intr\n");
+			int_mask |= MACIF_FIFO_OVERFL_INTR_RXPRT10_F2_MASK;
+		}
+		if (ICM_DATA_FIFO_UNDERFL_INTR_PRT00_RD(data)) {
+			pr_err("RxPort0 ICM Data fifo underflow intr\n");
+			int_mask |= ICM_DATA_FIFO_UNDERFL_INTR_PRT00_MASK;
+		}
+		if (ICM_DATA_FIFO_OVERFL_INTR_PRT00_RD(data)) {
+			pr_err("RxPort0 ICM Data fifo overflow intr\n");
+			int_mask |= ICM_DATA_FIFO_OVERFL_INTR_PRT00_MASK;
+		}
+		if (ICM_CTRL_FIFO_UNDERFL_INTR_PRT00_RD(data)) {
+			pr_err("RxPort0 ICM Ctrl fifo underflow intr\n");
+			int_mask |= ICM_CTRL_FIFO_UNDERFL_INTR_PRT00_MASK;
+		}
+		if (ICM_CTRL_FIFO_OVERFL_INTR_PRT00_RD(data)) {
+			pr_err("RxPort0 ICM Ctrl fifo overflow Interrupt\n");
+			int_mask |= ICM_CTRL_FIFO_OVERFL_INTR_PRT00_MASK;
+		}
+		if (ECM_DATA_FIFO_UNDERN_INTR_PRT00_RD(data)) {
+			pr_err("RxPort0 ECM Data fifo underrun interrupt\n");
+			int_mask |= ECM_DATA_FIFO_UNDERN_INTR_PRT00_MASK;
+		}
+		if (ECM_DATA_FIFO_UNDERFL_INTR_PRT00_RD(data)) {
+			pr_err("TxPort0 ECM Data fifo underflow interrupt\n");
+			int_mask |= ECM_DATA_FIFO_UNDERFL_INTR_PRT00_MASK;
+		}
+		if (ECM_DATA_FIFO_OVERFL_INTR_PRT00_RD(data)) {
+			pr_err("TxPort0 ECM Data fifo overflow interrupt\n");
+			int_mask |= ECM_DATA_FIFO_OVERFL_INTR_PRT00_MASK;
+		}
+		if (MACIF_FIFO_UNDERFL_INTR_RXPRT00_F2_RD(data)) {
+			pr_err("RxPort0 Mac i/f fifo underflow interrupt\n");
+			int_mask |= MACIF_FIFO_UNDERFL_INTR_RXPRT00_F2_MASK;
+		}
+		if (MACIF_FIFO_OVERFL_INTR_RXPRT00_F2_RD(data)) {
+			pr_err("RxPort0 Mac i/f fifo overflow interrupt\n");
+			int_mask |= MACIF_FIFO_OVERFL_INTR_RXPRT00_F2_MASK;
+		}
+		/* Clear intrstatus bits, its COW */
+		rc = xgene_enet_wr(priv, BLOCK_MCX_MAC_CSR,
+				   MAC_INT_REG0_ADDR, int_mask);
+	}
+	rc = xgene_enet_rd(priv, BLOCK_MCX_MAC_CSR, MAC_INT_REG1_ADDR, &data);
+	int_mask = 0;
+	if (data) {
+		pr_err("Received MAC Error Interrupt1\n");
+		if (LINKDOWN_PORT11_RD(data)) {
+			pr_err("Port1:Link Down intr\n");
+			int_mask |= LINKDOWN_PORT11_MASK;
+		}
+		if (CARRY_PORT11_RD(data)) {
+			pr_err("Carry Intr for Status Reg Overflow for Port 1\n");
+			int_mask |= CARRY_PORT11_MASK;
+		}
+		if (LINKDOWN_PORT01_RD(data)) {
+			pr_err("Port0:Link Down intr\n");
+			int_mask |= LINKDOWN_PORT01_MASK;
+		}
+		if (CARRY_PORT01_RD(data)) {
+			pr_err("Carry Intr for Status Reg Overflow for Port 0\n");
+			int_mask |= CARRY_PORT01_MASK;
+		}
+		/* Clear intrstatus bits, its COW */
+		rc = xgene_enet_wr(priv, BLOCK_MCX_MAC_CSR,
+				   MAC_INT_REG1_ADDR, int_mask);
+	}
+	return IRQ_HANDLED;
+}
+
+static irqreturn_t xgene_enet_err_irq(int irq, void *dev_instance)
+{
+	struct xgene_enet_pdev *pdev;
+	struct xgene_enet_priv *priv;
+	int rc;
+	u32 data;
+	u32 int_mask = 0;
+
+	pdev = netdev_priv(dev_instance);
+	priv = &pdev->priv;
+	rc = xgene_enet_rd(priv, BLOCK_ETH_CSR, RSIF_INT_REG0_ADDR, &data);
+	if (data) {
+		pr_err("Received RSIF Error Interrupt\n");
+		if (RSIF_LCL_RXBUF_FIFO_OVERFL_INTR_RXPRT10_RD(data)) {
+			pr_err("Rx port1 Local Rxbuff FIFO overflow intr\n");
+			int_mask |=
+			    RSIF_LCL_RXBUF_FIFO_OVERFL_INTR_RXPRT10_MASK;
+		}
+		if (RSIF_LCL_RXBUF_FIFO_UNDERFL_INTR_RXPRT10_RD(data)) {
+			pr_err("Rx port1 Local Rxbuff FIFO underflow intr\n");
+			int_mask |=
+			    RSIF_LCL_RXBUF_FIFO_UNDERFL_INTR_RXPRT10_MASK;
+		}
+		if (RSIF_CHKSUM_BUFF_FIFO_OVERFL_INTR_RXPRT10_RD(data)) {
+			pr_err("Rx port1 chksum buff FIFO overflow intr\n");
+			int_mask |=
+			    RSIF_CHKSUM_BUFF_FIFO_OVERFL_INTR_RXPRT10_MASK;
+		}
+		if (RSIF_CHKSUM_BUFF_FIFO_UNDERFL_INTR_RXPRT10_RD(data)) {
+			pr_err("Rx port1 chksum buffer FIFO underflow intr\n");
+			int_mask |=
+			    RSIF_CHKSUM_BUFF_FIFO_UNDERFL_INTR_RXPRT10_MASK;
+		}
+		if (RSIF_TIMESTAMP_BUFF_FIFO_OVERFL_INTR_RXPRT10_RD(data)) {
+			pr_err("Rx port1 timestamp buffer FIFO overflow intr\n");
+			int_mask |=
+			    RSIF_TIMESTAMP_BUFF_FIFO_OVERFL_INTR_RXPRT10_MASK;
+		}
+		if (RSIF_TIMESTAMP_BUFF_FIFO_UNDERFL_INTR_RXPRT10_RD(data)) {
+			pr_err("Rx port1 timestamp FIFO underflow intr\n");
+			int_mask |=
+			    RSIF_TIMESTAMP_BUFF_FIFO_UNDERFL_INTR_RXPRT10_MASK;
+		}
+		if (RSIF_ERR_BUFF_FIFO_OVERFL_INTR_RXPRT10_RD(data)) {
+			pr_err("Rx port1 err buffer FIFO overflow intr\n");
+			int_mask |= RSIF_ERR_BUFF_FIFO_OVERFL_INTR_RXPRT10_MASK;
+		}
+		if (RSIF_ERR_BUFF_FIFO_UNDERFL_INTR_RXPRT10_RD(data)) {
+			pr_err("Rx port1 err buffer FIFO underflow intr\n");
+			int_mask |=
+			    RSIF_ERR_BUFF_FIFO_UNDERFL_INTR_RXPRT10_MASK;
+		}
+		if (RSIF_CLEBUFF_FIFO_OVERFL_INTR_RXPRT10_RD(data)) {
+			pr_err("Rx port1 classifier buffer FIFO overflow intr\n");
+			int_mask |= RSIF_CLEBUFF_FIFO_OVERFL_INTR_RXPRT10_MASK;
+		}
+		if (RSIF_CLEBUFF_FIFO_UNDERFL_INTR_RXPRT10_RD(data)) {
+			pr_err("Rx port1 classifier buffer FIFO underflow intr\n");
+			int_mask |= RSIF_CLEBUFF_FIFO_UNDERFL_INTR_RXPRT10_MASK;
+		}
+		if (RSIF_CTRLBUFF_FIFO_OVERFL_INTR_RXPRT10_RD(data)) {
+			pr_err("Rx port1 ctrl buffer FIFO overflow intr\n");
+			int_mask |= RSIF_CTRLBUFF_FIFO_OVERFL_INTR_RXPRT10_MASK;
+		}
+		if (RSIF_CTRLBUFF_FIFO_UNDERFL_INTR_RXPRT10_RD(data)) {
+			pr_err(" Rx port1 ctrl buffer FIFO underflow intr\n");
+			int_mask |=
+			    RSIF_CTRLBUFF_FIFO_UNDERFL_INTR_RXPRT10_MASK;
+		}
+		if (RSIF_BUF_FIFO_OVERFL_INTR_RXPRT10_RD(data)) {
+			pr_err("Rx port1 buffer FIFO overflow intr\n");
+			int_mask |= RSIF_BUF_FIFO_OVERFL_INTR_RXPRT10_MASK;
+		}
+		if (RSIF_BUF_FIFO_UNDERFL_INTR_RXPRT10_RD(data)) {
+			pr_err("Rx port1 buffer FIFO underflow intr\n");
+			int_mask |= RSIF_BUF_FIFO_UNDERFL_INTR_RXPRT10_MASK;
+		}
+		if (ENET_RSIF_PLC_CLEBUFF_FIFO_OVERFL_INTR0_RD(data)) {
+			pr_err("Policer CLE FIFO overflow intr\n");
+			int_mask |=
+			    ENET_RSIF_PLC_CLEBUFF_FIFO_OVERFL_INTR0_MASK;
+		}
+		if (ENET_RSIF_PLC_CLEBUFF_FIFO_UNDERFL_INTR0_RD(data)) {
+			pr_err("Policer CLE FIFO underflow intr\n");
+			int_mask |=
+			    RSIF_LCL_RXBUF_FIFO_UNDERFL_INTR_RXPRT00_MASK;
+		}
+		if (RSIF_LCL_RXBUF_FIFO_OVERFL_INTR_RXPRT00_RD(data)) {
+			pr_err("Rx port0 Local Rx buffer FIFO overflow intr\n");
+			int_mask |=
+			    RSIF_LCL_RXBUF_FIFO_OVERFL_INTR_RXPRT00_MASK;
+		}
+		if (RSIF_LCL_RXBUF_FIFO_UNDERFL_INTR_RXPRT00_RD(data)) {
+			pr_err("Rx port0 Local Rx buffer FIFO underflow intr\n");
+			int_mask |=
+			    RSIF_LCL_RXBUF_FIFO_UNDERFL_INTR_RXPRT00_MASK;
+		}
+		if (RSIF_CHKSUM_BUFF_FIFO_OVERFL_INTR_RXPRT00_RD(data)) {
+			pr_err("Rx port0 chksum buffer FIFO overflow intr\n");
+			int_mask |=
+			    RSIF_CHKSUM_BUFF_FIFO_OVERFL_INTR_RXPRT00_MASK;
+		}
+		if (RSIF_CHKSUM_BUFF_FIFO_UNDERFL_INTR_RXPRT00_RD(data)) {
+			pr_err("Rx port0 chksum buffer FIFO underflow intr\n");
+			int_mask |=
+			    RSIF_CHKSUM_BUFF_FIFO_UNDERFL_INTR_RXPRT00_MASK;
+		}
+		if (RSIF_TIMESTAMP_BUFF_FIFO_OVERFL_INTR_RXPRT00_RD(data)) {
+			pr_err("Rx port0 timestamp buffer FIFO overflow intr\n");
+			int_mask |=
+			    RSIF_TIMESTAMP_BUFF_FIFO_OVERFL_INTR_RXPRT00_MASK;
+		}
+		if (RSIF_TIMESTAMP_BUFF_FIFO_UNDERFL_INTR_RXPRT00_RD(data)) {
+			pr_err("Rx port0 timestamp FIFO underflow intr\n");
+			int_mask |=
+			    RSIF_TIMESTAMP_BUFF_FIFO_UNDERFL_INTR_RXPRT00_MASK;
+		}
+		if (RSIF_ERR_BUFF_FIFO_OVERFL_INTR_RXPRT00_RD(data)) {
+			pr_err("Rx port0 err buffer FIFO overflow intr\n");
+			int_mask |= RSIF_ERR_BUFF_FIFO_OVERFL_INTR_RXPRT00_MASK;
+		}
+		if (RSIF_ERR_BUFF_FIFO_UNDERFL_INTR_RXPRT00_RD(data)) {
+			pr_err("Rx port0 err buffer FIFO underflow interrupt\n");
+			int_mask |=
+			    RSIF_ERR_BUFF_FIFO_UNDERFL_INTR_RXPRT00_MASK;
+		}
+		if (RSIF_CLEBUFF_FIFO_OVERFL_INTR_RXPRT00_RD(data)) {
+			pr_err("Rx port0 classifier buffer FIFO overflow intr\n");
+			int_mask |= RSIF_CLEBUFF_FIFO_OVERFL_INTR_RXPRT00_MASK;
+		}
+
+		if (RSIF_CLEBUFF_FIFO_UNDERFL_INTR_RXPRT00_RD(data)) {
+			pr_err("Rx port0 classifier buffer FIFO underflow intr\n");
+			int_mask |= RSIF_CLEBUFF_FIFO_UNDERFL_INTR_RXPRT00_MASK;
+		}
+		if (RSIF_CTRLBUFF_FIFO_OVERFL_INTR_RXPRT00_RD(data)) {
+			pr_err("Rx port0 ctrl buffer FIFO overflow intr\n");
+			int_mask |= RSIF_CTRLBUFF_FIFO_OVERFL_INTR_RXPRT00_MASK;
+		}
+		if (RSIF_CTRLBUFF_FIFO_UNDERFL_INTR_RXPRT00_RD(data)) {
+			pr_err("Rx port0 ctrl buffer FIFO overflow intr\n");
+			int_mask |=
+			    RSIF_CTRLBUFF_FIFO_UNDERFL_INTR_RXPRT00_MASK;
+		}
+		if (RSIF_BUF_FIFO_OVERFL_INTR_RXPRT00_RD(data)) {
+			pr_err("Rx port0 buffer FIFO overflow intr\n");
+			int_mask |= RSIF_BUF_FIFO_OVERFL_INTR_RXPRT00_MASK;
+		}
+		if (RSIF_BUF_FIFO_UNDERFL_INTR_RXPRT00_RD(data)) {
+			pr_err("Rx port0 buffer FIFO underflow intr\n");
+			int_mask |= RSIF_BUF_FIFO_UNDERFL_INTR_RXPRT00_MASK;
+		}
+		/* Clear intrstatus bits, its COW */
+		rc = xgene_enet_wr(priv, BLOCK_ETH_CSR,
+				   RSIF_INT_REG0_ADDR, int_mask);
+	}
+	rc = xgene_enet_rd(priv, BLOCK_ETH_CSR, RSIF_FINT_REG0_ADDR, &data);
+	int_mask = 0;
+	if (data) {
+		pr_err("Received RSIF Error2 Interrupt\n");
+		if (RSIF_SS_MIRRORERR_INTR_RXPRT10_RD(data)) {
+			pr_err("Mirror buffer address offset/length do ");
+			pr_err("not match with normal xfr address ");
+			pr_err("offset/length in port1\n");
+			int_mask |= RSIF_SS_MIRRORERR_INTR_RXPRT10_MASK;
+		}
+		if (RSIF_SS_SPLIT_BOUNDARY_INTR_RXPRT10_RD(data)) {
+			pr_err("Split boundary cannot be accomodated ");
+			pr_err("in the firt buffer in port1\n");
+			int_mask |= RSIF_SS_FPBUFF_TIMEOUT_INTR_RXPRT10_MASK;
+		}
+		if (RSIF_SS_FPBUFF_TIMEOUT_INTR_RXPRT10_RD(data)) {
+			pr_err("Packet dropped by RSIF because ");
+			pr_err("freepool buffer was NOT available from ");
+			pr_err("QMI on port1\n");
+			int_mask |= RSIF_SS_FPBUFF_TIMEOUT_INTR_RXPRT10_MASK;
+		}
+		if (RSIF_SS_AXI_WRERR_INTR_RXPRT10_RD(data)) {
+			pr_err("AXI write error on port1\n");
+			int_mask |= RSIF_SS_AXI_WRERR_INTR_RXPRT10_MASK;
+		}
+		if (RSIF_SS_MIRRORERR_INTR_RXPRT00_RD(data)) {
+			pr_err("Mirror buffer address offset/length ");
+			pr_err("do not match with normal xfr address ");
+			pr_err("offset/length in port0\n");
+			int_mask |= RSIF_SS_MIRRORERR_INTR_RXPRT00_MASK;
+		}
+		if (RSIF_SS_SPLIT_BOUNDARY_INTR_RXPRT00_RD(data)) {
+			pr_err("Split boundary cannot be accomodated ");
+			pr_err("in the firt buffer in port0\n");
+			int_mask |= RSIF_SS_SPLIT_BOUNDARY_INTR_RXPRT00_MASK;
+		}
+		if (RSIF_SS_FPBUFF_TIMEOUT_INTR_RXPRT00_RD(data)) {
+			pr_err("Packet dropped by RSIF because ");
+			pr_err("freepool buffer was NOT available from ");
+			pr_err("QMI on port0\n");
+			int_mask |= RSIF_SS_FPBUFF_TIMEOUT_INTR_RXPRT00_MASK;
+		}
+		if (RSIF_SS_AXI_WRERR_INTR_RXPRT00_RD(data)) {
+			pr_err("AXI write error on port0\n");
+			int_mask |= RSIF_SS_AXI_WRERR_INTR_RXPRT00_MASK;
+		}
+		if (STS_RSIF_PLC_DROP0_RD(data)) {
+			pr_err("Packet dropped by policer\n");
+			int_mask |= STS_RSIF_PLC_DROP0_MASK;
+		}
+		/* Clear intrstatus bits, its COW */
+		rc = xgene_enet_wr(priv, BLOCK_ETH_CSR,
+				   RSIF_FINT_REG0_ADDR, int_mask);
+	}
+	rc = xgene_enet_rd(priv, BLOCK_ETH_CSR, TSIF_INT_REG0_ADDR, &data);
+	int_mask = 0;
+	if (data) {
+		pr_err("Received TSIF Error Interrupt\n");
+		if (TSIF_RDMBUFF_FIFO_OVERFL_INTR_PRT10_RD(data)) {
+			pr_err("Tx port1 RDM buffer FIFO overflow interrupt\n");
+			int_mask |= TSIF_RDMBUFF_FIFO_OVERFL_INTR_PRT10_MASK;
+		}
+		if (TSIF_RDMBUFF_FIFO_UNDERFL_INTR_PRT10_RD(data)) {
+			pr_err("Tx port1 RDM buffer FIFO underflow interrupt\n");
+			int_mask |= TSIF_RDMBUFF_FIFO_UNDERFL_INTR_PRT10_MASK;
+		}
+		if (TSIF_RRM_FIFO_OVERFL_INTR_PRT10_RD(data)) {
+			pr_err("Tx port1 RRM buffer FIFO overflow intr\n");
+			int_mask |= TSIF_RRM_FIFO_OVERFL_INTR_PRT10_MASK;
+		}
+		if (TSIF_RRM_FIFO_UNDERFL_INTR_PRT10_RD(data)) {
+			pr_err("Tx port1 RRM buffer FIFO underflow intr\n");
+			int_mask |= TSIF_RRM_FIFO_UNDERFL_INTR_PRT10_MASK;
+		}
+		if (TSIF_AMABUF_FIFO_OVERFL_INTR_PRT10_RD(data)) {
+			pr_err("Tx port1 AMA buffer FIFO overflow intr\n");
+			int_mask |= TSIF_AMABUF_FIFO_OVERFL_INTR_PRT10_MASK;
+		}
+		if (TSIF_AMABUF_FIFO_UNDERFL_INTR_PRT10_RD(data)) {
+			pr_err("Tx port1 AMA buffer FIFO underflow intr\n");
+			int_mask |= TSIF_AMABUF_FIFO_UNDERFL_INTR_PRT10_MASK;
+		}
+
+		if (TSIF_RDMBUFF_FIFO_OVERFL_INTR_PRT00_RD(data)) {
+			pr_err("Tx port0 RDM buffer FIFO overflow intr\n");
+			int_mask |= TSIF_RDMBUFF_FIFO_OVERFL_INTR_PRT00_MASK;
+		}
+		if (TSIF_RDMBUFF_FIFO_UNDERFL_INTR_PRT00_RD(data)) {
+			pr_err("Tx port0 RDM buffer FIFO underflow intr\n");
+			int_mask |= TSIF_RDMBUFF_FIFO_UNDERFL_INTR_PRT00_MASK;
+		}
+		if (TSIF_RRM_FIFO_OVERFL_INTR_PRT00_RD(data)) {
+			pr_err("Tx port0 RRM buffer FIFO overflow intr\n");
+			int_mask |= TSIF_RRM_FIFO_OVERFL_INTR_PRT00_MASK;
+		}
+		if (TSIF_RRM_FIFO_UNDERFL_INTR_PRT00_RD(data)) {
+			pr_err("Tx port0 RRM buffer FIFO underflow intr\n");
+			int_mask |= TSIF_RRM_FIFO_UNDERFL_INTR_PRT00_MASK;
+		}
+		if (TSIF_AMABUF_FIFO_OVERFL_INTR_PRT00_RD(data)) {
+			pr_err("Tx port0 AMA buffer FIFO overflow intr\n");
+			int_mask |= TSIF_AMABUF_FIFO_OVERFL_INTR_PRT00_MASK;
+		}
+		if (TSIF_AMABUF_FIFO_UNDERFL_INTR_PRT00_RD(data)) {
+			pr_err("Tx port0 AMA buffer FIFO underflow intr\n");
+			int_mask |= TSIF_AMABUF_FIFO_UNDERFL_INTR_PRT00_MASK;
+		}
+		/* Clear intrstatus bits, its COW */
+		rc = xgene_enet_wr(priv, BLOCK_ETH_CSR,
+				   TSIF_INT_REG0_ADDR, int_mask);
+	}
+	rc = xgene_enet_rd(priv, BLOCK_ETH_CSR, TSIF_FINT_REG0_ADDR, &data);
+	int_mask = 0;
+	if (data) {
+		pr_err("Received TSIF Error Interrupt\n");
+		if (TSIF_SS_AXI_LLRDERR_INTR_PRT10_RD(data)) {
+			pr_err("AXI error when reading data from port1\n");
+			int_mask |= TSIF_SS_AXI_LLRDERR_INTR_PRT10_MASK;
+		}
+		if (TSIF_SS_AXI_RDERR_INTR_PRT10_RD(data)) {
+			pr_err("AXI error when reading data from port1\n");
+			int_mask |= TSIF_SS_AXI_RDERR_INTR_PRT10_MASK;
+		}
+		if (TSIF_SS_BAD_MSG_INTR_PRT10_RD(data)) {
+			pr_err("Bad message received by TSIF on port1\n");
+			int_mask |= TSIF_SS_BAD_MSG_INTR_PRT10_MASK;
+		}
+		if (TSIF_SS_AXI_LLRDERR_INTR_PRT00_RD(data)) {
+			pr_err("AXI error when reading data from port0\n");
+			int_mask |= TSIF_SS_AXI_LLRDERR_INTR_PRT00_MASK;
+		}
+		if (TSIF_SS_AXI_RDERR_INTR_PRT00_RD(data)) {
+			pr_err("AXI error when reading data from port0\n");
+			int_mask |= TSIF_SS_AXI_RDERR_INTR_PRT00_MASK;
+		}
+		if (TSIF_SS_BAD_MSG_INTR_PRT00_RD(data)) {
+			pr_err("Bad message received by TSIF on port0\n");
+			int_mask |= TSIF_SS_BAD_MSG_INTR_PRT00_MASK;
+		}
+		/* Clear intrstatus bits, its COW */
+		rc = xgene_enet_wr(priv, BLOCK_ETH_CSR,
+				   TSIF_FINT_REG0_ADDR, int_mask);
+	}
+	rc = xgene_enet_rd(priv, BLOCK_ETH_CSR, TSO_INT_REG0_ADDR, &data);
+	int_mask = 0;
+	if (data) {
+		pr_err("Received TSO Error Interrupt\n");
+		if (MB_TTF_FIFO_OVERFL_INTR_PRT10_RD(data)) {
+			pr_err("Tx port1 tso_txbuff FIFO overflow intr\n");
+			int_mask |= MB_TTF_FIFO_OVERFL_INTR_PRT10_MASK;
+		}
+		if (MB_TTF_FIFO_UNDERFL_INTR_PRT10_RD(data)) {
+			pr_err("Tx port1 tso_txbuff FIFO underflow intr\n");
+			int_mask |= MB_TTF_FIFO_UNDERFL_INTR_PRT10_MASK;
+		}
+		if (MH_DEALLOC_FIFO_OVERFL_INTR_PRT10_RD(data)) {
+			pr_err("Tx port1 Dealloc FIFO overflow intr\n");
+			int_mask |= MH_DEALLOC_FIFO_OVERFL_INTR_PRT10_MASK;
+		}
+		if (MH_DEALLOC_FIFO_UNDERFL_INTR_PRT10_RD(data)) {
+			pr_err("Tx port1 Dealloc FIFO underflow intr\n");
+			int_mask |= MH_DEALLOC_FIFO_UNDERFL_INTR_PRT10_MASK;
+		}
+		if (MH_FIFO_OVERFL_INTR_PRT10_RD(data)) {
+			pr_err("Tx port1 Message Hold FIFO overflow intr\n");
+			int_mask |= MH_FIFO_OVERFL_INTR_PRT10_MASK;
+		}
+		if (MH_FIFO_UNDERFL_INTR_PRT10_RD(data)) {
+			pr_err("Tx port1 Message Hold FIFO underflow intr\n");
+			int_mask |= MH_FIFO_UNDERFL_INTR_PRT10_MASK;
+		}
+		if (MB_TTF_FIFO_OVERFL_INTR_PRT00_RD(data)) {
+			pr_err("Tx port0 tso_txbuff FIFO overflow intr\n");
+			int_mask |= MB_TTF_FIFO_OVERFL_INTR_PRT00_MASK;
+		}
+		if (MB_TTF_FIFO_UNDERFL_INTR_PRT00_RD(data)) {
+			pr_err("Tx port0 tso_txbuff FIFO underflow intr\n");
+			int_mask |= MB_TTF_FIFO_UNDERFL_INTR_PRT00_MASK;
+		}
+		if (MH_DEALLOC_FIFO_OVERFL_INTR_PRT00_RD(data)) {
+			pr_err("Tx port0 Dealloc FIFO overflow intr\n");
+			int_mask |= MH_DEALLOC_FIFO_OVERFL_INTR_PRT00_MASK;
+		}
+		if (MH_DEALLOC_FIFO_UNDERFL_INTR_PRT00_RD(data)) {
+			pr_err("Tx port1 Dealloc FIFO underflow intr\n");
+			int_mask |= MH_DEALLOC_FIFO_UNDERFL_INTR_PRT00_MASK;
+		}
+		if (MH_FIFO_OVERFL_INTR_PRT00_RD(data)) {
+			pr_err("Tx port1 Message Hold FIFO overflow intr\n");
+			int_mask |= MH_FIFO_OVERFL_INTR_PRT00_MASK;
+		}
+		if (MH_FIFO_UNDERFL_INTR_PRT00_RD(data)) {
+			pr_err("Tx port1 Message Hold FIFO underflow intr\n");
+			int_mask |= MH_FIFO_UNDERFL_INTR_PRT00_MASK;
+		}
+		/* Clear intrstatus bits, its COW */
+		rc = xgene_enet_wr(priv, BLOCK_ETH_CSR,
+				   TSO_INT_REG0_ADDR, int_mask);
+	}
+	rc = xgene_enet_rd(priv, BLOCK_ETH_CSR, SPI2SAP_INT_REG0_ADDR, &data);
+	int_mask = 0;
+	if (data) {
+		pr_err("Received SPI2SAP Error Interrupt\n");
+		if (MACIF_FIFO_OVERFL_INTR_RXPRT10_RD(data)) {
+			pr_err("Rx port1 SAP FIFO overflow intr\n");
+			int_mask |= MACIF_FIFO_OVERFL_INTR_RXPRT10_MASK;
+		}
+		if (MACIF_FIFO_UNDERFL_INTR_RXPRT10_RD(data)) {
+			pr_err("Rx port1 SAP FIFO underflow intr\n");
+			int_mask |= MACIF_FIFO_UNDERFL_INTR_RXPRT10_MASK;
+		}
+		if (MACIF_FIFO_OVERFL_INTR_RXPRT00_RD(data)) {
+			pr_err("Rx port0 SAP FIFO overflow intr\n");
+			int_mask |= MACIF_FIFO_OVERFL_INTR_RXPRT00_MASK;
+		}
+		if (MACIF_FIFO_UNDERFL_INTR_RXPRT00_RD(data)) {
+			pr_err("Rx port0 SAP FIFO underflow intr\n");
+			int_mask |= MACIF_FIFO_UNDERFL_INTR_RXPRT00_MASK;
+		}
+		/* Clear intrstatus bits, its COW */
+		rc = xgene_enet_wr(priv, BLOCK_ETH_CSR,
+				   SPI2SAP_INT_REG0_ADDR, int_mask);
+	}
+	rc = xgene_enet_rd(priv, BLOCK_ETH_CSR,
+			   RX_TX_BUF_CHKSM_INT_REG0_ADDR, &data);
+	int_mask = 0;
+	if (data) {
+		pr_err("Received RX/TX Buffer Checksum Error Interrupt\n");
+		if (RXBUF_PAUSE_INTR_PORT10_RD(data)) {
+			pr_err("Rx port1 Pause interrupt\n");
+			int_mask |= RXBUF_PAUSE_INTR_PORT10_MASK;
+		}
+		if (RX_CHKSUM_INTR_PORT10_RD(data)) {
+			pr_err("Rx port1 Chksum Error intr\n");
+			int_mask |= RX_CHKSUM_INTR_PORT10_MASK;
+		}
+		if (TX_CHKSUM_INTR_PORT10_RD(data)) {
+			pr_err("Tx port1 Chksum Error intr\n");
+			int_mask |= TX_CHKSUM_INTR_PORT10_MASK;
+		}
+		if (RXBUF_FIFO_OVERFL_INTR_PRT10_RD(data)) {
+			pr_err("Rx port1 rx buffer FIFO  overflow intr\n");
+			int_mask |= RXBUF_FIFO_OVERFL_INTR_PRT10_MASK;
+		}
+		if (RXBUF_FIFO_UNDERFL_INTR_PRT10_RD(data)) {
+			pr_err("Rx port1 rx buffer FIFO  underflow intr\n");
+			int_mask |= RXBUF_FIFO_UNDERFL_INTR_PRT10_MASK;
+		}
+		if (TXBUF_FIFO_OVERFL_INTR_PRT10_RD(data)) {
+			pr_err("Rx port1 rx buffer FIFO  overflow intr\n");
+			int_mask |= RXBUF_FIFO_OVERFL_INTR_PRT10_MASK;
+		}
+		if (TXBUF_FIFO_UNDERFL_INTR_PRT10_RD(data)) {
+			pr_err("Rx port1 rx buffer FIFO  underflow intr\n");
+			int_mask |= RXBUF_FIFO_UNDERFL_INTR_PRT10_MASK;
+		}
+		if (RXBUF_PAUSE_INTR_PORT00_RD(data)) {
+			pr_err("Rx port0 Pause interrupt\n");
+			int_mask |= RXBUF_PAUSE_INTR_PORT00_MASK;
+		}
+		if (RX_CHKSUM_INTR_PORT00_RD(data)) {
+			pr_err("Rx port0 Chksum Error intr\n");
+			int_mask |= RX_CHKSUM_INTR_PORT00_MASK;
+		}
+		if (TX_CHKSUM_INTR_PORT00_RD(data)) {
+			pr_err("Tx port0 Chksum Error intr\n");
+			int_mask |= TX_CHKSUM_INTR_PORT00_MASK;
+		}
+		if (RXBUF_FIFO_OVERFL_INTR_PRT00_RD(data)) {
+			pr_err("Rx port0 rx buffer FIFO  overflow intr\n");
+			int_mask |= RXBUF_FIFO_OVERFL_INTR_PRT00_MASK;
+		}
+		if (RXBUF_FIFO_UNDERFL_INTR_PRT00_RD(data)) {
+			pr_err("Rx port0 rx buffer FIFO  underflow intr\n");
+			int_mask |= RXBUF_FIFO_UNDERFL_INTR_PRT00_MASK;
+		}
+		if (TXBUF_FIFO_OVERFL_INTR_PRT00_RD(data)) {
+			pr_err("Rx port0 rx buffer FIFO  overflow intr\n");
+			int_mask |= RXBUF_FIFO_OVERFL_INTR_PRT00_MASK;
+		}
+		if (TXBUF_FIFO_UNDERFL_INTR_PRT00_RD(data)) {
+			pr_err("Rx port0 rx buffer FIFO  underflow intr\n");
+			int_mask |= RXBUF_FIFO_UNDERFL_INTR_PRT00_MASK;
+		}
+		/* Clear intrstatus bits, its COW */
+		rc = xgene_enet_wr(priv, BLOCK_ETH_CSR,
+				   RX_TX_BUF_CHKSM_INT_REG0_ADDR, int_mask);
+	}
+	return IRQ_HANDLED;
+}
+
+void xgene_enet_register_err_irqs(struct net_device *ndev)
+{
+	struct xgene_enet_pdev *pdev;
+	struct device *dev;
+
+	pdev = (struct xgene_enet_pdev *)netdev_priv(ndev);
+	dev = &pdev->plat_dev->dev;
+
+	if ((devm_request_irq(dev, pdev->enet_err_irq, xgene_enet_err_irq,
+			 IRQF_SHARED, ndev->name, ndev)) != 0)
+		netdev_err(ndev, "Failed to reg Enet Error IRQ %d\n",
+			   pdev->enet_err_irq);
+	if ((devm_request_irq(dev, pdev->enet_mac_err_irq,
+			 xgene_enet_mac_err_irq, IRQF_SHARED,
+			 ndev->name, ndev)) != 0)
+		netdev_err(ndev, "Failed to reg Enet MAC Error IRQ %d\n",
+			   pdev->enet_mac_err_irq);
+	if ((devm_request_irq(dev, pdev->enet_qmi_err_irq,
+			 xgene_enet_qmi_err_irq,
+			 IRQF_SHARED, ndev->name, ndev)) != 0)
+		netdev_err(ndev, "Failed to reg Enet QMI Error IRQ %d\n",
+			   pdev->enet_qmi_err_irq);
+}
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index 2aa1808..90f53b8 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -770,6 +770,7 @@ static int xgene_enet_rx_frame(struct xgene_enet_qcontext *e2c,
 			goto process_pkt;
 		}
 
+		xgene_enet_parse_error(LErr, qid);
 		netdev_dbg(ndev, "ENET LErr 0x%x skb 0x%p FP 0x%x\n",
 			   LErr, skb, msg16->FPQNum);
 		print_hex_dump(KERN_ERR, "QM Msg: ",
@@ -1258,6 +1259,8 @@ static void xgene_enet_register_irq(struct net_device *ndev)
 		/* Disable interrupts for RX queue mailboxes */
 		disable_irq_nosync(pdev->rx[qindex]->qdesc->irq);
 	}
+
+	xgene_enet_register_err_irqs(ndev);
 }
 
 static int xgene_enet_get_resources(struct xgene_enet_pdev *pdev)
@@ -1330,6 +1333,30 @@ static int xgene_enet_get_resources(struct xgene_enet_pdev *pdev)
 	}
 	pdev->sdev = sdev;
 
+	pdata.irq = platform_get_irq(plat_dev, 0);
+	if (pdata.irq <= 0) {
+		dev_err(dev, "Unable to get ENET Error IRQ\n");
+		rc = pdata.irq;
+		goto out;
+	}
+	pdev->enet_err_irq = pdata.irq;
+
+	pdata.irq = platform_get_irq(plat_dev, 1);
+	if (pdata.irq <= 0) {
+		dev_err(dev, "Unable to get ENET MAC Error IRQ\n");
+		rc = pdata.irq;
+		goto out;
+	}
+	pdev->enet_mac_err_irq = pdata.irq;
+
+	pdata.irq = platform_get_irq(plat_dev, 2);
+	if (pdata.irq <= 0) {
+		dev_err(dev, "Unable to get ENET QMI Error IRQ\n");
+		rc = pdata.irq;
+		goto out;
+	}
+	pdev->enet_qmi_err_irq = pdata.irq;
+
 	rc = of_property_read_u32(plat_dev->dev.of_node, "phyid",
 				  &pdata.phy_id);
 	if (rc || pdata.phy_id > 0x1F) {
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
index 15ea995..b25bb37 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
@@ -127,6 +127,7 @@ struct eth_queue_ids {
 struct xgene_enet_platform_data {
 	u32 port_id;
 	const char *sname;
+	int irq;
 	u32 phy_id;
 	u8 ethaddr[6];
 };
@@ -155,6 +156,9 @@ struct xgene_enet_pdev {
 	struct eth_queue_ids qm_queues;
 	u32 rx_buff_cnt, tx_cqt_low, tx_cqt_hi;
 	int mss;
+	unsigned int enet_err_irq;
+	unsigned int enet_mac_err_irq;
+	unsigned int enet_qmi_err_irq;
 	struct xgene_enet_priv priv;
 };
 
-- 
1.7.9.5
