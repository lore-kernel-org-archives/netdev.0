From: "Ravinandan Arakali" <ravinandan.arakali@s2io.com>
Subject: [PATCH 2.6.9-rc2 6/8] S2io: new txd allocation
Date: Wed, 13 Oct 2004 18:15:42 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <005201c4b18b$538b5ff0$6c10100a@S2IOtech.com>
Reply-To: <ravinandan.arakali@s2io.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_NextPart_000_0053_01C4B150.A72C87F0"
Cc: <netdev@oss.sgi.com>, <leonid.grossman@s2io.com>,
        <raghavendra.koushik@s2io.com>, <rapuru.sriram@s2io.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Jeff Garzik'" <jgarzik@pobox.com>,
        "'Francois Romieu'" <romieu@fr.zoreil.com>
In-Reply-To: 
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

------=_NextPart_000_0053_01C4B150.A72C87F0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,
The attached patch contains a modified scheme for allocating Tx descriptor
blocks.
More description follows.

In the old scheme, the entire Tx descriptor space was allocated in one go.
This could cause driver load to fail on systems with low(or scattered)
memory. The Tx descriptor blocks are now allocated on per-page basis. A new
structure (list_info) has been introduced in nic_t structure to keep track
of the physical and virtual addresses of every TxD allocated this way.

Signed-off-by: Raghavendra Koushik <raghavendra.koushik@s2io.com>


------=_NextPart_000_0053_01C4B150.A72C87F0
Content-Type: application/octet-stream;
	name="s2io_newtxalloc.patch6"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="s2io_newtxalloc.patch6"

diff -urN vanilla-linux/drivers/net/s2io.c =
linux-2.6.8.1/drivers/net/s2io.c
--- vanilla-linux/drivers/net/s2io.c	2004-10-11 16:49:34.000000000 -0700
+++ linux-2.6.8.1/drivers/net/s2io.c	2004-10-11 17:20:24.000000000 -0700
@@ -305,6 +305,9 @@
       remove:__devexit_p(s2io_rem_nic),
 };
=20
+/* A simplifier macro used both by init and free shared_mem Fns(). */
+#define TXD_MEM_PAGE_CNT(len, per_each) ((len+per_each - 1) / per_each)
+
 /**
  * init_shared_mem - Allocation and Initialization of Memory
  * @nic: Device private variable.
@@ -320,6 +323,7 @@
 	dma_addr_t tmp_p_addr, tmp_p_addr_next;
 	RxD_block_t *pre_rxd_blk =3D NULL;
 	int i, j, blk_cnt;
+	int lst_size, lst_per_page;
 	struct net_device *dev =3D nic->dev;
=20
 	mac_info_t *mac_control;
@@ -341,39 +345,55 @@
 		DBG_PRINT(ERR_DBG, "that can be used\n");
 		return FAILURE;
 	}
-	size *=3D (sizeof(TxD_t) * config->max_txds);
=20
-	mac_control->txd_list_mem =3D pci_alloc_consistent
-	    (nic->pdev, size, &mac_control->txd_list_mem_phy);
-	if (!mac_control->txd_list_mem) {
-		return -ENOMEM;
-	}
-	mac_control->txd_list_mem_sz =3D size;
-
-	tmp_v_addr =3D mac_control->txd_list_mem;
-	tmp_p_addr =3D mac_control->txd_list_mem_phy;
-	memset(tmp_v_addr, 0, size);
-
-	DBG_PRINT(INIT_DBG, "%s:List Mem PHY: 0x%llx\n", dev->name,
-		  (unsigned long long) tmp_p_addr);
+	lst_size =3D (sizeof(TxD_t) * config->max_txds);
+	lst_per_page =3D PAGE_SIZE / lst_size;
=20
 	for (i =3D 0; i < config->tx_fifo_num; i++) {
-		mac_control->txdl_start_phy[i] =3D tmp_p_addr;
-		mac_control->txdl_start[i] =3D (TxD_t *) tmp_v_addr;
+		int fifo_len =3D config->tx_cfg[i].fifo_len;
+		int list_holder_size =3D fifo_len * sizeof(list_info_hold_t);
+		nic->list_info[i] =3D kmalloc(list_holder_size, GFP_KERNEL);
+		if (!nic->list_info[i]) {
+			DBG_PRINT(ERR_DBG,
+				  "Malloc failed for list_info\n");
+			return -ENOMEM;
+		}
+		memset(nic->list_info[i], 0, list_holder_size);
+	}
+	for (i =3D 0; i < config->tx_fifo_num; i++) {
+		int page_num =3D TXD_MEM_PAGE_CNT(config->tx_cfg[i].fifo_len,
+						lst_per_page);
 		mac_control->tx_curr_put_info[i].offset =3D 0;
 		mac_control->tx_curr_put_info[i].fifo_len =3D
 		    config->tx_cfg[i].fifo_len - 1;
 		mac_control->tx_curr_get_info[i].offset =3D 0;
 		mac_control->tx_curr_get_info[i].fifo_len =3D
 		    config->tx_cfg[i].fifo_len - 1;
-
-		tmp_p_addr +=3D
-		    (config->tx_cfg[i].fifo_len * (sizeof(TxD_t)) *
-		     config->max_txds);
-		tmp_v_addr +=3D
-		    (config->tx_cfg[i].fifo_len * (sizeof(TxD_t)) *
-		     config->max_txds);
+		for (j =3D 0; j < page_num; j++) {
+			int k =3D 0;
+			dma_addr_t tmp_p;
+			void *tmp_v;
+			tmp_v =3D pci_alloc_consistent(nic->pdev,
+						     PAGE_SIZE, &tmp_p);
+			if (!tmp_v) {
+				DBG_PRINT(ERR_DBG,
+					  "pci_alloc_consistent ");
+				DBG_PRINT(ERR_DBG, "failed for TxDL\n");
+				return -ENOMEM;
+			}
+			while (k < lst_per_page) {
+				int l =3D (j * lst_per_page) + k;
+				if (l =3D=3D config->tx_cfg[i].fifo_len)
+					goto end_txd_alloc;
+				nic->list_info[i][l].list_virt_addr =3D
+				    tmp_v + (k * lst_size);
+				nic->list_info[i][l].list_phy_addr =3D
+				    tmp_p + (k * lst_size);
+				k++;
+			}
+		}
 	}
+      end_txd_alloc:
=20
 	/* Allocation and initialization of RXDs in Rings */
 	size =3D 0;
@@ -484,6 +504,7 @@
 	dma_addr_t tmp_p_addr;
 	mac_info_t *mac_control;
 	struct config_param *config;
+	int lst_size, lst_per_page;
=20
=20
 	if (!nic)
@@ -492,11 +513,23 @@
 	mac_control =3D &nic->mac_control;
 	config =3D &nic->config;
=20
-	if (mac_control->txd_list_mem) {
-		pci_free_consistent(nic->pdev,
-				    mac_control->txd_list_mem_sz,
-				    mac_control->txd_list_mem,
-				    mac_control->txd_list_mem_phy);
+	lst_size =3D (sizeof(TxD_t) * config->max_txds);
+	lst_per_page =3D PAGE_SIZE / lst_size;
+
+	for (i =3D 0; i < config->tx_fifo_num; i++) {
+		int page_num =3D TXD_MEM_PAGE_CNT(config->tx_cfg[i].fifo_len,
+						lst_per_page);
+		for (j =3D 0; j < page_num; j++) {
+			int mem_blks =3D (j * lst_per_page);
+			if (!nic->list_info[i][mem_blks].list_virt_addr)
+				break;
+			pci_free_consistent(nic->pdev, PAGE_SIZE,
+					    nic->list_info[i][mem_blks].
+					    list_virt_addr,
+					    nic->list_info[i][mem_blks].
+					    list_phy_addr);
+		}
+		kfree(nic->list_info[i]);
 	}
=20
 	size =3D (MAX_RXDS_PER_BLOCK + 1) * (sizeof(RxD_t));
@@ -1444,8 +1477,8 @@
=20
 	for (i =3D 0; i < config->tx_fifo_num; i++) {
 		for (j =3D 0; j < config->tx_cfg[i].fifo_len - 1; j++) {
-			txdp =3D mac_control->txdl_start[i] +
-			    (config->max_txds * j);
+			txdp =3D (TxD_t *) nic->list_info[i][j].
+			    list_virt_addr;
 			skb =3D
 			    (struct sk_buff *) ((unsigned long) txdp->
 						Host_Control);
@@ -1460,6 +1493,8 @@
 		DBG_PRINT(INTR_DBG,
 			  "%s:forcibly freeing %d skbs on FIFO%d\n",
 			  dev->name, cnt, i);
+		mac_control->tx_curr_get_info[i].offset =3D 0;
+		mac_control->tx_curr_put_info[i].offset =3D 0;
 	}
 }
=20
@@ -1896,7 +1931,7 @@
 {
 	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) nic->bar0;
 	struct net_device *dev =3D (struct net_device *) nic->dev;
-	tx_curr_get_info_t offset_info, offset_info1;
+	tx_curr_get_info_t get_info, put_info;
 	struct sk_buff *skb;
 	TxD_t *txdlp;
 	register u64 val64 =3D 0;
@@ -1916,12 +1951,12 @@
 	writeq(val64, &bar0->tx_traffic_int);
=20
 	for (i =3D 0; i < config->tx_fifo_num; i++) {
-		offset_info =3D mac_control->tx_curr_get_info[i];
-		offset_info1 =3D mac_control->tx_curr_put_info[i];
-		txdlp =3D mac_control->txdl_start[i] +
-		    (config->max_txds * offset_info.offset);
+		get_info =3D mac_control->tx_curr_get_info[i];
+		put_info =3D mac_control->tx_curr_put_info[i];
+		txdlp =3D (TxD_t *) nic->list_info[i][get_info.offset].
+		    list_virt_addr;
 		while ((!(txdlp->Control_1 & TXD_LIST_OWN_XENA)) &&
-		       (offset_info.offset !=3D offset_info1.offset) &&
+		       (get_info.offset !=3D put_info.offset) &&
 		       (txdlp->Host_Control)) {
 			/* Check for TxD errors */
 			if (txdlp->Control_1 & TXD_T_CODE) {
@@ -1971,12 +2006,12 @@
 			nic->stats.tx_bytes +=3D skb->len;
 			dev_kfree_skb_irq(skb);
=20
-			offset_info.offset++;
-			offset_info.offset %=3D offset_info.fifo_len + 1;
-			txdlp =3D mac_control->txdl_start[i] +
-			    (config->max_txds * offset_info.offset);
+			get_info.offset++;
+			get_info.offset %=3D get_info.fifo_len + 1;
+			txdlp =3D (TxD_t *) nic->list_info[i]
+			    [get_info.offset].list_virt_addr;
 			mac_control->tx_curr_get_info[i].offset =3D
-			    offset_info.offset;
+			    get_info.offset;
 		}
 	}
=20
@@ -2327,7 +2362,9 @@
 	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) sp->bar0;
 	register u64 val64 =3D 0;
 	u16 cnt =3D 0;
+	unsigned long flags;
=20
+	spin_lock_irqsave(&sp->tx_lock, flags);
 	netif_stop_queue(dev);
=20
 	/* disable Tx and Rx traffic on the NIC */
@@ -2381,6 +2418,7 @@
 	free_rx_buffers(sp);
=20
 	sp->device_close_flag =3D TRUE;	/* Device is shut down. */
+	spin_unlock_irqrestore(&sp->tx_lock, flags);
=20
 	return 0;
 }
@@ -2401,7 +2439,7 @@
 int s2io_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	nic_t *sp =3D dev->priv;
-	u16 off, txd_len, frg_cnt, frg_len, i, queue, off1, queue_len;
+	u16 frg_cnt, frg_len, i, queue, queue_len, put_off, get_off;
 	register u64 val64;
 	TxD_t *txdp;
 	TxFIFO_element_t *tx_fifo;
@@ -2419,6 +2457,14 @@
 	DBG_PRINT(TX_DBG, "%s: In S2IO Tx routine\n", dev->name);
=20
 	spin_lock_irqsave(&sp->tx_lock, flags);
+	if ((netif_queue_stopped(dev)) || (!netif_carrier_ok(dev))) {
+		DBG_PRINT(TX_DBG, "%s:s2io_xmit: Tx Queue stopped\n",
+			  dev->name);
+		dev_kfree_skb(skb);
+		spin_unlock_irqrestore(&sp->tx_lock, flags);
+		return 0;
+	}
+
 	queue =3D 0;
 	/* Multi FIFO Tx is disabled for now. */
 	if (!queue && tx_prio) {
@@ -2427,14 +2473,13 @@
 	}
=20
=20
-	off =3D (u16) mac_control->tx_curr_put_info[queue].offset;
-	off1 =3D (u16) mac_control->tx_curr_get_info[queue].offset;
-	txd_len =3D config->max_txds;
-	txdp =3D mac_control->txdl_start[queue] + (config->max_txds * off);
+	put_off =3D (u16) mac_control->tx_curr_put_info[queue].offset;
+	get_off =3D (u16) mac_control->tx_curr_get_info[queue].offset;
+	txdp =3D (TxD_t *) sp->list_info[queue][put_off].list_virt_addr;
=20
 	queue_len =3D mac_control->tx_curr_put_info[queue].fifo_len + 1;
 	/* Avoid "put" pointer going beyond "get" pointer */
-	if (txdp->Host_Control || (((off + 1) % queue_len) =3D=3D off1)) {
+	if (txdp->Host_Control || (((put_off + 1) % queue_len) =3D=3D =
get_off)) {
 		DBG_PRINT(ERR_DBG, "Error in xmit, No free TXDs.\n");
 		netif_stop_queue(dev);
 		dev_kfree_skb(skb);
@@ -2479,8 +2524,7 @@
 	txdp->Control_1 |=3D TXD_GATHER_CODE_LAST;
=20
 	tx_fifo =3D mac_control->tx_FIFO_start[queue];
-	val64 =3D (mac_control->txdl_start_phy[queue] +
-		 (sizeof(TxD_t) * txd_len * off));
+	val64 =3D sp->list_info[queue][put_off].list_phy_addr;
 	writeq(val64, &tx_fifo->TxDL_Pointer);
=20
 	val64 =3D (TX_FIFO_LAST_TXD_NUM(frg_cnt) | TX_FIFO_FIRST_LIST |
@@ -2494,15 +2538,15 @@
 	/* Perform a PCI read to flush previous writes */
 	val64 =3D readq(&bar0->general_int_status);
=20
-	off++;
-	off %=3D mac_control->tx_curr_put_info[queue].fifo_len + 1;
-	mac_control->tx_curr_put_info[queue].offset =3D off;
+	put_off++;
+	put_off %=3D mac_control->tx_curr_put_info[queue].fifo_len + 1;
+	mac_control->tx_curr_put_info[queue].offset =3D put_off;
=20
 	/* Avoid "put" pointer going beyond "get" pointer */
-	if (((off + 1) % queue_len) =3D=3D off1) {
+	if (((put_off + 1) % queue_len) =3D=3D get_off) {
 		DBG_PRINT(TX_DBG,
 			  "No free TxDs for xmit, Put: 0x%x Get:0x%x\n",
-			  off, off1);
+			  put_off, get_off);
 		netif_stop_queue(dev);
 	}
=20
@@ -3070,7 +3114,7 @@
 }
=20
 /**
- * s2io_ethtool-setpause_data -  set/reset pause frame generation.
+ * s2io_ethtool_setpause_data -  set/reset pause frame generation.
  * @sp : private member of the device structure, which is a pointer to =
the=20
  *      s2io_nic structure.
  * @ep : pointer to the structure with pause parameters given by =
ethtool.
diff -urN vanilla-linux/drivers/net/s2io.h =
linux-2.6.8.1/drivers/net/s2io.h
--- vanilla-linux/drivers/net/s2io.h	2004-10-11 16:49:34.000000000 -0700
+++ linux-2.6.8.1/drivers/net/s2io.h	2004-10-11 17:20:24.000000000 -0700
@@ -444,6 +444,12 @@
 	u64 Host_Control;	/* reserved for host */
 } TxD_t;
=20
+/* Structure to hold the phy and virt addr of every TxDL. */
+typedef struct list_info_hold {
+	dma_addr_t list_phy_addr;
+	void *list_virt_addr;
+} list_info_hold_t;
+
 /* Rx descriptor structure */
 typedef struct _RxD_t {
 	u64 Host_Control;	/* reserved for host */
@@ -532,17 +538,9 @@
 	u16 mc_pause_threshold_q4q7;
=20
 /* tx side stuff */
-	void *txd_list_mem;	/* original pointer to allocated mem */
-	dma_addr_t txd_list_mem_phy;
-	u32 txd_list_mem_sz;
-
 	/* logical pointer of start of each Tx FIFO */
 	TxFIFO_element_t *tx_FIFO_start[MAX_TX_FIFOS];
=20
-	/* The Phy and virtual mem loactions of the Tx descriptors. */
-	TxD_t *txdl_start[MAX_TX_FIFOS];
-	dma_addr_t txdl_start_phy[MAX_TX_FIFOS];
-
 /* Current offset within tx_FIFO_start, where driver would write new Tx =
frame*/
 	tx_curr_put_info_t tx_curr_put_info[MAX_TX_FIFOS];
 	tx_curr_get_info_t tx_curr_get_info[MAX_TX_FIFOS];
@@ -638,6 +636,9 @@
 	int block_count[MAX_RX_RINGS];
 	int pkt_cnt[MAX_RX_RINGS];
=20
+	/* Place holder of all the TX List's Phy and Virt addresses. */
+	list_info_hold_t *list_info[MAX_TX_FIFOS];
+
 	/*  Id timer, used to blink NIC to physically identify NIC. */
 	struct timer_list id_timer;
=20

------=_NextPart_000_0053_01C4B150.A72C87F0--
