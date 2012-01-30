From: Andrea Shepard <andrea@persephoneslair.org>
Subject: [04/22] Cyclades PC300 driver: Fix prototypes
Date: Sun, 29 Jan 2012 18:47:00 -0800
Message-ID: <20120130024700.GE10262@cronus.persephoneslair.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: khc@pm.waw.pl, davem@davemloft.net, mmarek@suse.cz,
	jkosina@suse.cz, joe@perches.com, justinmattock@gmail.com,
	gregkh@suse.de, alan@linux.intel.com, jdmason@kudzu.us
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix the usage of function prototypes to avoid unnecessary globally visible
symbols.  Functions and global variables which are only ever referenced in
pc300_drv.c are declared static and in that file rather than pc300.h.  This
patch generates some style warnings due to pre-existing style violations in
some of the function definitions; these are fixed in patch 15 (cleanup).

Signed-off-by: Andrea Shepard <andrea@persephoneslair.org>

diff --git a/drivers/net/wan/pc300.h b/drivers/net/wan/pc300.h
index bd70320..ad52c85 100644
--- a/drivers/net/wan/pc300.h
+++ b/drivers/net/wan/pc300.h
@@ -466,26 +466,7 @@ enum pc300_loopback_cmds {
 #define	PC300_DEF_MTU		1600
 
 #ifdef __KERNEL__
-/* Function Prototypes */
-int dma_buf_write(pc300_t *, int, ucchar *, int);
-int dma_buf_read(pc300_t *, int, struct sk_buff *);
-void tx_dma_start(pc300_t *, int);
-void rx_dma_start(pc300_t *, int);
-void tx_dma_stop(pc300_t *, int);
-void rx_dma_stop(pc300_t *, int);
-int cpc_queue_xmit(struct sk_buff *, struct net_device *);
-void cpc_net_rx(hdlc_device *);
-void cpc_sca_status(pc300_t *, int);
-int cpc_change_mtu(struct net_device *, int);
-int cpc_ioctl(struct net_device *, struct ifreq *, int);
-int ch_config(pc300dev_t *);
-int rx_config(pc300dev_t *);
-int tx_config(pc300dev_t *);
-void cpc_opench(pc300dev_t *);
-void cpc_closech(pc300dev_t *);
-int cpc_open(struct net_device *dev);
-int cpc_close(struct net_device *dev);
-int cpc_set_media(hdlc_device *, int);
+int cpc_open(struct net_device *);
 #endif /* __KERNEL__ */
 
 #endif	/* _PC300_H */
diff --git a/drivers/net/wan/pc300_drv.c b/drivers/net/wan/pc300_drv.c
index b5781e9..5cec02b 100644
--- a/drivers/net/wan/pc300_drv.c
+++ b/drivers/net/wan/pc300_drv.c
@@ -279,20 +279,85 @@ MODULE_DEVICE_TABLE(pci, cpc_pci_dev_id);
 #define	cpc_max(a,b)	(((a)>(b))?(a):(b))
 #endif
 
-/* prototypes */
-static void tx_dma_buf_pt_init(pc300_t *, int);
-static void tx_dma_buf_init(pc300_t *, int);
-static void rx_dma_buf_pt_init(pc300_t *, int);
+/* DMA routines */
+static int dma_buf_read(pc300_t *, int, struct sk_buff *);
+static int dma_buf_write(pc300_t *, int, u8 *, int);
+static int dma_get_rx_frame_size(pc300_t *, int);
+static void rx_dma_buf_check(pc300_t *, int);
 static void rx_dma_buf_init(pc300_t *, int);
+static void rx_dma_buf_pt_init(pc300_t *, int);
+static void rx_dma_start(pc300_t *, int);
+static void rx_dma_stop(pc300_t *, int);
+#ifdef PC300_DEBUG_OTHER
+static void tx1_dma_buf_check(pc300_t *, int);
+#endif
 static void tx_dma_buf_check(pc300_t *, int);
-static void rx_dma_buf_check(pc300_t *, int);
-static irqreturn_t cpc_intr(int, void *, struct pt_regs *);
-static struct net_device_stats *cpc_get_stats(struct net_device *);
+static void tx_dma_buf_init(pc300_t *, int);
+static void tx_dma_buf_pt_init(pc300_t *, int);
+static void tx_dma_stop(pc300_t *, int);
+
+/* FALC routines */
+static void falc_check_status(pc300_t *, int, unsigned char);
+static void falc_close_all_timeslots(pc300_t *, int);
+static void falc_close_timeslot(pc300_t *, int, int);
+static void falc_disable_comm(pc300_t *, int);
+static void falc_e1_intr(pc300_t *, int);
+static void falc_e1_loop_detection(pc300_t *, int, u8);
+static void falc_enable_comm(pc300_t *, int);
+static void falc_generate_loop_down_code(pc300_t *, int);
+static void falc_generate_loop_up_code(pc300_t *, int);
+static void falc_init_e1(pc300_t *, int);
+static void falc_init_hdlc(pc300_t *, int);
+static void falc_init_t1(pc300_t *, int);
+static void falc_init_timeslot(pc300_t *, int);
+static void falc_intr_enable(pc300_t *, int);
+static void falc_intr(pc300_t *);
+static void falc_issue_cmd(pc300_t *, int, u8);
+static void falc_local_loop(pc300_t *, int, int);
+static void falc_open_all_timeslots(pc300_t *, int);
+static void falc_open_timeslot(pc300_t *, int, int);
+static u16 falc_pattern_test_error(pc300_t *, int);
+static void falc_pattern_test(pc300_t *, int, unsigned int);
+static void falc_payload_loop(pc300_t *, int, int);
+static void falc_remote_loop(pc300_t *, int, int);
+static void falc_t1_intr(pc300_t *, int);
+static void falc_t1_loop_detection(pc300_t *, int, u8);
+static void falc_update_stats(pc300_t *, int);
+static void te_config(pc300_t *, int);
+static void turn_off_xld(pc300_t *, int);
+static void turn_off_xlu(pc300_t *, int);
+
+static void sca_intr(pc300_t *);
+static void sca_tx_intr(pc300dev_t *);
+
+static int ch_config(pc300dev_t *);
 static int clock_rate_calc(u32, u32, int *);
 static u32 detect_ram(pc300_t *);
 static void plx_init(pc300_t *);
+static int rx_config(pc300dev_t *);
+static inline void show_version(void);
+static int tx_config(pc300dev_t *);
+
+static int cpc_attach(struct net_device *, unsigned short, unsigned short);
+static int cpc_change_mtu(struct net_device *, int);
+static void __exit cpc_cleanup_module(void);
+static void cpc_closech(pc300dev_t *);
+static int cpc_close(struct net_device *);
+static void cpc_falc_status(pc300_t *, int);
+static struct net_device_stats *cpc_get_stats(struct net_device *);
+static void cpc_init_card(pc300_t *);
+static int __devinit cpc_init_one(struct pci_dev *,
+				  const struct pci_device_id *);
+static int __init cpc_init(void);
+static irqreturn_t cpc_intr(int, void *, struct pt_regs *);
+static int cpc_ioctl(struct net_device *, struct ifreq *, int);
+static void cpc_net_rx(struct net_device *);
+static int cpc_opench(pc300dev_t *);
+static int cpc_queue_xmit(struct sk_buff *, struct net_device *);
+static void __devexit cpc_remove_one(struct pci_dev *);
+static void cpc_sca_status(pc300_t *, int);
 static void cpc_trace(struct net_device *, struct sk_buff *, char);
-static int cpc_attach(hdlc_device *, unsigned short, unsigned short);
+static void cpc_tx_timeout(struct net_device *);
 
 #ifdef CONFIG_PC300_MLPPP
 void cpc_tty_init(pc300dev_t * dev);
@@ -440,7 +505,7 @@ static void rx_dma_buf_check(pc300_t * card, int ch)
 	printk("\n");
 }
 
-int dma_get_rx_frame_size(pc300_t * card, int ch)
+static int dma_get_rx_frame_size(pc300_t * card, int ch)
 {
 	pcsca_bd_t __iomem *ptdescr;
 	u16 first_bd = card->chan[ch].rx_first_bd;
@@ -465,7 +530,7 @@ int dma_get_rx_frame_size(pc300_t * card, int ch)
  * dma_buf_write: writes a frame to the Tx DMA buffers
  * NOTE: this function writes one frame at a time.
  */
-int dma_buf_write(pc300_t * card, int ch, ucchar * ptdata, int len)
+static int dma_buf_write(pc300_t *card, int ch, u8 *ptdata, int len)
 {
 	int i, nchar;
 	pcsca_bd_t __iomem *ptdescr;
@@ -507,7 +572,7 @@ int dma_buf_write(pc300_t * card, int ch, ucchar * ptdata, int len)
  * dma_buf_read: reads a frame from the Rx DMA buffers
  * NOTE: this function reads one frame at a time.
  */
-int dma_buf_read(pc300_t * card, int ch, struct sk_buff *skb)
+static int dma_buf_read(pc300_t * card, int ch, struct sk_buff *skb)
 {
 	int nchar;
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
@@ -564,7 +629,7 @@ int dma_buf_read(pc300_t * card, int ch, struct sk_buff *skb)
 	return (rcvd);
 }
 
-void tx_dma_stop(pc300_t * card, int ch)
+static void tx_dma_stop(pc300_t * card, int ch)
 {
 	uintptr_t scabase = (uintptr_t)(card->hw.scabase);
 	u8 drr_ena_bit = 1 << (5 + 2 * ch);
@@ -575,7 +640,7 @@ void tx_dma_stop(pc300_t * card, int ch)
 	cpc_writeb(scabase + DRR, drr_rst_bit & ~drr_ena_bit);
 }
 
-void rx_dma_stop(pc300_t * card, int ch)
+static void rx_dma_stop(pc300_t * card, int ch)
 {
 	uintptr_t scabase = (uintptr_t)(card->hw.scabase);
 	u8 drr_ena_bit = 1 << (4 + 2 * ch);
@@ -586,7 +651,7 @@ void rx_dma_stop(pc300_t * card, int ch)
 	cpc_writeb(scabase + DRR, drr_rst_bit & ~drr_ena_bit);
 }
 
-void rx_dma_start(pc300_t * card, int ch)
+static void rx_dma_start(pc300_t * card, int ch)
 {
 	uintptr_t scabase = (uintptr_t)(card->hw.scabase);
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
@@ -611,7 +676,7 @@ void rx_dma_start(pc300_t * card, int ch)
 /*************************/
 /***   FALC Routines   ***/
 /*************************/
-void falc_issue_cmd(pc300_t * card, int ch, ucchar cmd)
+static void falc_issue_cmd(pc300_t *card, int ch, u8 cmd)
 {
 	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
 	unsigned long i = 0;
@@ -626,7 +691,7 @@ void falc_issue_cmd(pc300_t * card, int ch, ucchar cmd)
 	cpc_writeb(falcbase + F_REG(CMDR, ch), cmd);
 }
 
-void falc_intr_enable(pc300_t * card, int ch)
+static void falc_intr_enable(pc300_t * card, int ch)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
@@ -676,7 +741,7 @@ void falc_intr_enable(pc300_t * card, int ch)
 	}
 }
 
-void falc_open_timeslot(pc300_t * card, int ch, int timeslot)
+static void falc_open_timeslot(pc300_t * card, int ch, int timeslot)
 {
 	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
 	u8 tshf = card->chan[ch].falc.offset;
@@ -692,7 +757,7 @@ void falc_open_timeslot(pc300_t * card, int ch, int timeslot)
 			(0x80 >> (timeslot & 0x07)));
 }
 
-void falc_close_timeslot(pc300_t * card, int ch, int timeslot)
+static void falc_close_timeslot(pc300_t * card, int ch, int timeslot)
 {
 	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
 	u8 tshf = card->chan[ch].falc.offset;
@@ -708,7 +773,7 @@ void falc_close_timeslot(pc300_t * card, int ch, int timeslot)
 		   ~(0x80 >> (timeslot & 0x07)));
 }
 
-void falc_close_all_timeslots(pc300_t * card, int ch)
+static void falc_close_all_timeslots(pc300_t * card, int ch)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
@@ -730,7 +795,7 @@ void falc_close_all_timeslots(pc300_t * card, int ch)
 	}
 }
 
-void falc_open_all_timeslots(pc300_t * card, int ch)
+static void falc_open_all_timeslots(pc300_t * card, int ch)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
@@ -762,7 +827,7 @@ void falc_open_all_timeslots(pc300_t * card, int ch)
 	}
 }
 
-void falc_init_timeslot(pc300_t * card, int ch)
+static void falc_init_timeslot(pc300_t * card, int ch)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
@@ -780,7 +845,7 @@ void falc_init_timeslot(pc300_t * card, int ch)
 	}
 }
 
-void falc_enable_comm(pc300_t * card, int ch)
+static void falc_enable_comm(pc300_t * card, int ch)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	falc_t *pfalc = (falc_t *) & chan->falc;
@@ -796,7 +861,7 @@ void falc_enable_comm(pc300_t * card, int ch)
 		   ~((CPLD_REG1_FALC_DCD | CPLD_REG1_FALC_CTS) << (2 * ch)));
 }
 
-void falc_disable_comm(pc300_t * card, int ch)
+static void falc_disable_comm(pc300_t * card, int ch)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	falc_t *pfalc = (falc_t *) & chan->falc;
@@ -810,7 +875,7 @@ void falc_disable_comm(pc300_t * card, int ch)
 		   ((CPLD_REG1_FALC_DCD | CPLD_REG1_FALC_CTS) << (2 * ch)));
 }
 
-void falc_init_t1(pc300_t * card, int ch)
+static void falc_init_t1(pc300_t * card, int ch)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
@@ -979,7 +1044,7 @@ void falc_init_t1(pc300_t * card, int ch)
 	falc_close_all_timeslots(card, ch);
 }
 
-void falc_init_e1(pc300_t * card, int ch)
+static void falc_init_e1(pc300_t * card, int ch)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
@@ -1159,7 +1224,7 @@ void falc_init_e1(pc300_t * card, int ch)
 	falc_close_all_timeslots(card, ch);
 }
 
-void falc_init_hdlc(pc300_t * card, int ch)
+static void falc_init_hdlc(pc300_t * card, int ch)
 {
 	uintptr_t falcbase = (uintptr_t)(card->hw.falcbase);
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
@@ -1185,7 +1250,7 @@ void falc_init_hdlc(pc300_t * card, int ch)
 	falc_intr_enable(card, ch);
 }
 
-void te_config(pc300_t * card, int ch)
+static void te_config(pc300_t * card, int ch)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
@@ -1245,7 +1310,7 @@ void te_config(pc300_t * card, int ch)
 	CPC_UNLOCK(card, flags);
 }
 
-void falc_check_status(pc300_t * card, int ch, unsigned char frs0)
+static void falc_check_status(pc300_t * card, int ch, unsigned char frs0)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
@@ -1401,7 +1466,7 @@ void falc_check_status(pc300_t * card, int ch, unsigned char frs0)
 	}
 }
 
-void falc_update_stats(pc300_t * card, int ch)
+static void falc_update_stats(pc300_t * card, int ch)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
@@ -1454,7 +1519,7 @@ void falc_update_stats(pc300_t * card, int ch)
  *		the synchronizer and then sent to the system interface.
  *----------------------------------------------------------------------------
  */
-void falc_remote_loop(pc300_t * card, int ch, int loop_on)
+static void falc_remote_loop(pc300_t * card, int ch, int loop_on)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
@@ -1499,7 +1564,7 @@ void falc_remote_loop(pc300_t * card, int ch, int loop_on)
  *		coding must be identical.
  *----------------------------------------------------------------------------
  */
-void falc_local_loop(pc300_t * card, int ch, int loop_on)
+static void falc_local_loop(pc300_t * card, int ch, int loop_on)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	falc_t *pfalc = (falc_t *) & chan->falc;
@@ -1526,7 +1591,7 @@ void falc_local_loop(pc300_t * card, int ch, int loop_on)
  *		looped. They are originated by the FALC-LH transmitter.
  *----------------------------------------------------------------------------
  */
-void falc_payload_loop(pc300_t * card, int ch, int loop_on)
+static void falc_payload_loop(pc300_t * card, int ch, int loop_on)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
@@ -1580,7 +1645,7 @@ void falc_payload_loop(pc300_t * card, int ch, int loop_on)
  * Description:	Turns XLU bit off in the proper register
  *----------------------------------------------------------------------------
  */
-void turn_off_xlu(pc300_t * card, int ch)
+static void turn_off_xlu(pc300_t * card, int ch)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
@@ -1601,7 +1666,7 @@ void turn_off_xlu(pc300_t * card, int ch)
  * Description: Turns XLD bit off in the proper register
  *----------------------------------------------------------------------------
  */
-void turn_off_xld(pc300_t * card, int ch)
+static void turn_off_xld(pc300_t * card, int ch)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
@@ -1623,7 +1688,7 @@ void turn_off_xld(pc300_t * card, int ch)
  *		to generate a LOOP activation code over a T1/E1 line.
  *----------------------------------------------------------------------------
  */
-void falc_generate_loop_up_code(pc300_t * card, int ch)
+static void falc_generate_loop_up_code(pc300_t * card, int ch)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
@@ -1656,7 +1721,7 @@ void falc_generate_loop_up_code(pc300_t * card, int ch)
  *		to generate a LOOP deactivation code over a T1/E1 line.
  *----------------------------------------------------------------------------
  */
-void falc_generate_loop_down_code(pc300_t * card, int ch)
+static void falc_generate_loop_down_code(pc300_t * card, int ch)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
@@ -1686,7 +1751,7 @@ void falc_generate_loop_down_code(pc300_t * card, int ch)
  *		it on the reception side.
  *----------------------------------------------------------------------------
  */
-void falc_pattern_test(pc300_t * card, int ch, unsigned int activate)
+static void falc_pattern_test(pc300_t * card, int ch, unsigned int activate)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
@@ -1733,7 +1798,7 @@ void falc_pattern_test(pc300_t * card, int ch, unsigned int activate)
  * Description:	This routine returns the bit error counter value
  *----------------------------------------------------------------------------
  */
-u16 falc_pattern_test_error(pc300_t *card, int ch)
+static u16 falc_pattern_test_error(pc300_t *card, int ch)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	falc_t *pfalc = (falc_t *) & chan->falc;
@@ -1773,7 +1838,7 @@ cpc_trace(struct net_device *dev, struct sk_buff *skb_main, char rx_tx)
 	netif_rx(skb);
 }
 
-void cpc_tx_timeout(struct net_device *dev)
+static void cpc_tx_timeout(struct net_device *dev)
 {
 	pc300dev_t *d = (pc300dev_t *) dev->priv;
 	pc300ch_t *chan = (pc300ch_t *) d->chan;
@@ -1801,7 +1866,7 @@ void cpc_tx_timeout(struct net_device *dev)
 	netif_wake_queue(dev);
 }
 
-int cpc_queue_xmit(struct sk_buff *skb, struct net_device *dev)
+static int cpc_queue_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	pc300dev_t *d = (pc300dev_t *) dev->priv;
 	pc300ch_t *chan = (pc300ch_t *) d->chan;
@@ -1884,7 +1949,7 @@ int cpc_queue_xmit(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
-void cpc_net_rx(hdlc_device * hdlc)
+static void cpc_net_rx(struct net_device *dev)
 {
 	struct net_device *dev = hdlc_to_dev(hdlc);
 	pc300dev_t *d = (pc300dev_t *) dev->priv;
@@ -2410,7 +2475,7 @@ static irqreturn_t cpc_intr(int irq, void *dev_id, struct pt_regs *regs)
 	return IRQ_HANDLED;
 }
 
-void cpc_sca_status(pc300_t * card, int ch)
+static void cpc_sca_status(pc300_t * card, int ch)
 {
 	u8 ilar;
 	uintptr_t scabase = (uintptr_t)(card->hw.scabase);
@@ -2502,7 +2567,7 @@ void cpc_sca_status(pc300_t * card, int ch)
 	}
 }
 
-void cpc_falc_status(pc300_t * card, int ch)
+static void cpc_falc_status(pc300_t * card, int ch)
 {
 	pc300ch_t *chan = &card->chan[ch];
 	falc_t *pfalc = (falc_t *) & chan->falc;
@@ -2530,7 +2595,7 @@ void cpc_falc_status(pc300_t * card, int ch)
 	CPC_UNLOCK(card, flags);
 }
 
-int cpc_change_mtu(struct net_device *dev, int new_mtu)
+static int cpc_change_mtu(struct net_device *dev, int new_mtu)
 {
 	if ((new_mtu < 128) || (new_mtu > PC300_DEF_MTU))
 		return -EINVAL;
@@ -2538,7 +2603,7 @@ int cpc_change_mtu(struct net_device *dev, int new_mtu)
 	return 0;
 }
 
-int cpc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
+static int cpc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
 	hdlc_device *hdlc = dev_to_hdlc(dev);
 	pc300dev_t *d = (pc300dev_t *) dev->priv;
@@ -2868,7 +2933,7 @@ static int clock_rate_calc(u32 rate, u32 clock, int *br_io)
 	}
 }
 
-int ch_config(pc300dev_t * d)
+static int ch_config(pc300dev_t * d)
 {
 	pc300ch_t *chan = (pc300ch_t *) d->chan;
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
@@ -3016,7 +3081,7 @@ int ch_config(pc300dev_t * d)
 	return 0;
 }
 
-int rx_config(pc300dev_t * d)
+static int rx_config(pc300dev_t * d)
 {
 	pc300ch_t *chan = (pc300ch_t *) d->chan;
 	pc300_t *card = (pc300_t *) chan->card;
@@ -3047,7 +3112,7 @@ int rx_config(pc300dev_t * d)
 	return 0;
 }
 
-int tx_config(pc300dev_t * d)
+static int tx_config(pc300dev_t * d)
 {
 	pc300ch_t *chan = (pc300ch_t *) d->chan;
 	pc300_t *card = (pc300_t *) chan->card;
@@ -3079,7 +3144,7 @@ int tx_config(pc300dev_t * d)
 	return 0;
 }
 
-static int cpc_attach(hdlc_device * hdlc, unsigned short encoding,
+static int cpc_attach(struct net_device *dev, unsigned short encoding,
 		      unsigned short parity)
 {
 	struct net_device * dev = hdlc_to_dev(hdlc);
@@ -3111,7 +3176,7 @@ static int cpc_attach(hdlc_device * hdlc, unsigned short encoding,
 	return 0;
 }
 
-void cpc_opench(pc300dev_t * d)
+static int cpc_opench(pc300dev_t * d)
 {
 	pc300ch_t *chan = (pc300ch_t *) d->chan;
 	pc300_t *card = (pc300_t *) chan->card;
@@ -3129,7 +3194,7 @@ void cpc_opench(pc300dev_t * d)
 		   cpc_readb(scabase + M_REG(CTL, ch)) & ~(CTL_RTS | CTL_DTR));
 }
 
-void cpc_closech(pc300dev_t * d)
+static void cpc_closech(pc300dev_t * d)
 {
 	pc300ch_t *chan = (pc300ch_t *) d->chan;
 	pc300_t *card = (pc300_t *) chan->card;
@@ -3186,7 +3251,7 @@ int cpc_open(struct net_device *dev)
 	return 0;
 }
 
-int cpc_close(struct net_device *dev)
+static int cpc_close(struct net_device *dev)
 {
 	hdlc_device *hdlc = dev_to_hdlc(dev);
 	pc300dev_t *d = (pc300dev_t *) dev->priv;
diff --git a/drivers/net/wan/pc300_tty.c b/drivers/net/wan/pc300_tty.c
index cddf896..e614126 100644
--- a/drivers/net/wan/pc300_tty.c
+++ b/drivers/net/wan/pc300_tty.c
@@ -112,10 +112,10 @@ typedef	struct _st_cpc_tty_area {
 static struct tty_driver serial_drv;
 
 /* local variables */
-st_cpc_tty_area	cpc_tty_area[CPC_TTY_NPORTS];
+static st_cpc_tty_area	cpc_tty_area[CPC_TTY_NPORTS];
 
-int cpc_tty_cnt=0;	/* number of intrfaces configured with MLPPP */
-int cpc_tty_unreg_flag = 0;
+static int cpc_tty_cnt = 0;	/* number of intrfaces configured with MLPPP */
+static int cpc_tty_unreg_flag = 0;
 
 /* TTY functions prototype */
 static int cpc_tty_open(struct tty_struct *tty, struct file *flip);
@@ -133,9 +133,9 @@ static void cpc_tty_trace(pc300dev_t *dev, char* buf, int len, char rxtx);
 static void cpc_tty_signal_off(pc300dev_t *pc300dev, unsigned char);
 static void cpc_tty_signal_on(pc300dev_t *pc300dev, unsigned char);
 
-int pc300_tiocmset(struct tty_struct *, struct file *,
+static int pc300_tiocmset(struct tty_struct *, struct file *,
 			unsigned int, unsigned int);
-int pc300_tiocmget(struct tty_struct *, struct file *);
+static int pc300_tiocmget(struct tty_struct *);
 
 /* functions called by PC300 driver */
 void cpc_tty_init(pc300dev_t *dev);
@@ -559,7 +559,7 @@ static int cpc_tty_chars_in_buffer(struct tty_struct *tty)
 	return(0); 
 } 
 
-int pc300_tiocmset(struct tty_struct *tty, struct file *file,
+static int pc300_tiocmset(struct tty_struct *tty, struct file *file,
 			unsigned int set, unsigned int clear)
 {
 	st_cpc_tty_area    *cpc_tty; 
@@ -586,7 +586,7 @@ int pc300_tiocmset(struct tty_struct *tty, struct file *file,
 	return 0;
 }
 
-int pc300_tiocmget(struct tty_struct *tty, struct file *file)
+static int pc300_tiocmget(struct tty_struct *tty, struct file *file)
 {
 	unsigned int result;
 	unsigned char status;
