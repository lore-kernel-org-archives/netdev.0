From: "Ravinandan Arakali" <ravinandan.arakali@s2io.com>
Subject: RE: Patch submission for S2io Xframe driver to 2.6 kernel
Date: Mon, 13 Sep 2004 10:09:53 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <002201c499b4$7c7b60c0$a010100a@S2IOtech.com>
References: <413116FF.7000701@pobox.com>
Reply-To: <ravinandan.arakali@s2io.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_NextPart_000_0023_01C49979.D01C88C0"
Cc: <netdev@oss.sgi.com>, <leonid.grossman@s2io.com>,
        <raghavendra.koushik@s2io.com>, <rapuru.sriram@s2io.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Jeff Garzik'" <jgarzik@pobox.com>
In-Reply-To: <413116FF.7000701@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

------=_NextPart_000_0023_01C49979.D01C88C0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Jeff,
Attached is the patch with the first round comments incorporated.
In addition, this patch contains
Some fixes related to 32-bit systems.
Few fixes related to Rx path in NAPI.

Thanks to all for the comments.

Pls review this patch as well and come back with your comments.

Regards,
Ravi

-----Original Message-----
From: Jeff Garzik [mailto:jgarzik@pobox.com]
Sent: Saturday, August 28, 2004 4:37 PM
To: ravinandan.arakali@s2io.com
Cc: netdev@oss.sgi.com; leonid.grossman@s2io.com;
raghavendra.koushik@s2io.com
Subject: Re: Patch submission for S2io Xframe driver to 2.6 kernel


is there a follow-up patch addressing the comments ?

------=_NextPart_000_0023_01C49979.D01C88C0
Content-Type: application/octet-stream;
	name="s2io_submit2_1_patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="s2io_submit2_1_patch"

diff -urN vanilla_linux-2.6.7/drivers/net/Kconfig =
linux-2.6.7/drivers/net/Kconfig=0A=
--- vanilla_linux-2.6.7/drivers/net/Kconfig	2004-06-15 =
22:19:52.000000000 -0700=0A=
+++ linux-2.6.7/drivers/net/Kconfig	2004-09-08 12:54:13.000000000 -0700=0A=
@@ -2160,7 +2160,16 @@=0A=
 config S2IO_NAPI=0A=
 	bool "Use Rx Polling (NAPI) (EXPERIMENTAL)"=0A=
 	depends on S2IO && EXPERIMENTAL=0A=
-=0A=
+config 2BUFF_MODE=0A=
+	bool "Use 2 Buffer Mode on Rx side."=0A=
+	depends on S2IO=0A=
+	---help---=0A=
+	On enabling the 2 buffer mode, the received frame will be=0A=
+	split into 2 parts before being DMA'ed to the hosts memory.=0A=
+	The parts are the ethernet header and ethernet payload. =0A=
+	This is useful on systems where DMA'ing to to unaligned =0A=
+	physical memory loactions comes with a heavy price.=0A=
+	If not sure please say N.=0A=
 endmenu=0A=
 =0A=
 source "drivers/net/tokenring/Kconfig"=0A=
diff -urN vanilla_linux-2.6.7/drivers/net/s2io-regs.h =
linux-2.6.7/drivers/net/s2io-regs.h=0A=
--- vanilla_linux-2.6.7/drivers/net/s2io-regs.h	2004-06-15 =
22:19:22.000000000 -0700=0A=
+++ linux-2.6.7/drivers/net/s2io-regs.h	2004-09-08 12:55:02.000000000 =
-0700=0A=
@@ -289,6 +289,8 @@=0A=
 	u64 tda_err_alarm;=0A=
 =0A=
 	u64 pcc_err_reg;=0A=
+#define PCC_FB_ECC_DB_ERR		vBIT(0xFF, 16, 8)=0A=
+=0A=
 	u64 pcc_err_mask;=0A=
 	u64 pcc_err_alarm;=0A=
 =0A=
@@ -512,6 +514,7 @@=0A=
 #define RX_PA_CFG_IGNORE_FRM_ERR           BIT(1)=0A=
 #define RX_PA_CFG_IGNORE_SNAP_OUI          BIT(2)=0A=
 #define RX_PA_CFG_IGNORE_LLC_CTRL          BIT(3)=0A=
+#define RX_PA_CFG_IGNORE_L2_ERR            BIT(6)=0A=
 =0A=
 	u8 unused12[0x700 - 0x1D8];=0A=
 =0A=
diff -urN vanilla_linux-2.6.7/drivers/net/s2io.c =
linux-2.6.7/drivers/net/s2io.c=0A=
--- vanilla_linux-2.6.7/drivers/net/s2io.c	2004-06-15 22:19:37.000000000 =
-0700=0A=
+++ linux-2.6.7/drivers/net/s2io.c	2004-09-10 13:16:58.000000000 -0700=0A=
@@ -61,6 +61,7 @@=0A=
 #include<asm/uaccess.h>=0A=
 #include<linux/version.h>=0A=
 #include<asm/io.h>=0A=
+#include<linux/proc_fs.h>=0A=
 #include<linux/workqueue.h>=0A=
 =0A=
 /* local include */=0A=
@@ -69,7 +70,16 @@=0A=
 =0A=
 /* S2io Driver name & version. */=0A=
 static char s2io_driver_name[] =3D "s2io";=0A=
-static char s2io_driver_version[] =3D "Version 1.0";=0A=
+static char s2iO_driver_version[] =3D "Version 1.1";=0A=
+=0A=
+/* =0A=
+ * Cards with following subsystem_id have a link state indication=0A=
+ * problem, 600B, 600C, 600D, 640B, 640C and 640D.=0A=
+ * macro below identifies these cards given the subsystem_id.=0A=
+ */=0A=
+#define CARDS_WITH_FAULTY_LINK_INDICATORS(subid) \=0A=
+		(((subid >=3D 0x600B) && (subid <=3D 0x600D)) || \=0A=
+		 ((subid >=3D 0x640B) && (subid <=3D 0x640D))) ? 1 : 0=0A=
 =0A=
 #define LINK_IS_UP(val64) (!(val64 & (ADAPTER_STATUS_RMAC_REMOTE_FAULT =
| \=0A=
 				      ADAPTER_STATUS_RMAC_LOCAL_FAULT)))=0A=
@@ -80,10 +90,11 @@=0A=
 static inline int rx_buffer_level(nic_t * sp, int rxb_size, int ring)=0A=
 {=0A=
 	int level =3D 0;=0A=
-	if ((sp->pkt_cnt[ring] - rxb_size) > 128) {=0A=
+	if ((sp->pkt_cnt[ring] - rxb_size) > 16) {=0A=
 		level =3D LOW;=0A=
-		if (rxb_size < sp->pkt_cnt[ring] / 8)=0A=
+		if ((sp->pkt_cnt[ring] - rxb_size) < MAX_RXDS_PER_BLOCK) {=0A=
 			level =3D PANIC;=0A=
+		}=0A=
 	}=0A=
 =0A=
 	return level;=0A=
@@ -99,45 +110,45 @@=0A=
 };=0A=
 =0A=
 static char ethtool_stats_keys[][ETH_GSTRING_LEN] =3D {=0A=
-	"tmac_frms",=0A=
-	"tmac_data_octets",=0A=
-	"tmac_drop_frms",=0A=
-	"tmac_mcst_frms",=0A=
-	"tmac_bcst_frms",=0A=
-	"tmac_pause_ctrl_frms",=0A=
-	"tmac_any_err_frms",=0A=
-	"tmac_vld_ip_octets",=0A=
-	"tmac_vld_ip",=0A=
-	"tmac_drop_ip",=0A=
-	"tmac_icmp",=0A=
-	"tmac_rst_tcp",=0A=
-	"tmac_tcp",=0A=
-	"tmac_udp",=0A=
-	"rmac_vld_frms",=0A=
-	"rmac_data_octets",=0A=
-	"rmac_fcs_err_frms",=0A=
-	"rmac_drop_frms",=0A=
-	"rmac_vld_mcst_frms",=0A=
-	"rmac_vld_bcst_frms",=0A=
-	"rmac_in_rng_len_err_frms",=0A=
-	"rmac_long_frms",=0A=
-	"rmac_pause_ctrl_frms",=0A=
-	"rmac_discarded_frms",=0A=
-	"rmac_usized_frms",=0A=
-	"rmac_osized_frms",=0A=
-	"rmac_frag_frms",=0A=
-	"rmac_jabber_frms",=0A=
-	"rmac_ip",=0A=
-	"rmac_ip_octets",=0A=
-	"rmac_hdr_err_ip",=0A=
-	"rmac_drop_ip",=0A=
-	"rmac_icmp",=0A=
-	"rmac_tcp",=0A=
-	"rmac_udp",=0A=
-	"rmac_err_drp_udp",=0A=
-	"rmac_pause_cnt",=0A=
-	"rmac_accepted_ip",=0A=
-	"rmac_err_tcp",=0A=
+	{"tmac_frms"},=0A=
+	{"tmac_data_octets"},=0A=
+	{"tmac_drop_frms"},=0A=
+	{"tmac_mcst_frms"},=0A=
+	{"tmac_bcst_frms"},=0A=
+	{"tmac_pause_ctrl_frms"},=0A=
+	{"tmac_any_err_frms"},=0A=
+	{"tmac_vld_ip_octets"},=0A=
+	{"tmac_vld_ip"},=0A=
+	{"tmac_drop_ip"},=0A=
+	{"tmac_icmp"},=0A=
+	{"tmac_rst_tcp"},=0A=
+	{"tmac_tcp"},=0A=
+	{"tmac_udp"},=0A=
+	{"rmac_vld_frms"},=0A=
+	{"rmac_data_octets"},=0A=
+	{"rmac_fcs_err_frms"},=0A=
+	{"rmac_drop_frms"},=0A=
+	{"rmac_vld_mcst_frms"},=0A=
+	{"rmac_vld_bcst_frms"},=0A=
+	{"rmac_in_rng_len_err_frms"},=0A=
+	{"rmac_long_frms"},=0A=
+	{"rmac_pause_ctrl_frms"},=0A=
+	{"rmac_discarded_frms"},=0A=
+	{"rmac_usized_frms"},=0A=
+	{"rmac_osized_frms"},=0A=
+	{"rmac_frag_frms"},=0A=
+	{"rmac_jabber_frms"},=0A=
+	{"rmac_ip"},=0A=
+	{"rmac_ip_octets"},=0A=
+	{"rmac_hdr_err_ip"},=0A=
+	{"rmac_drop_ip"},=0A=
+	{"rmac_icmp"},=0A=
+	{"rmac_tcp"},=0A=
+	{"rmac_udp"},=0A=
+	{"rmac_err_drp_udp"},=0A=
+	{"rmac_pause_cnt"},=0A=
+	{"rmac_accepted_ip"},=0A=
+	{"rmac_err_tcp"},=0A=
 };=0A=
 =0A=
 #define S2IO_STAT_LEN sizeof(ethtool_stats_keys)/ ETH_GSTRING_LEN=0A=
@@ -147,7 +158,8 @@=0A=
 #define S2IO_STRINGS_LEN	S2IO_TEST_LEN * ETH_GSTRING_LEN=0A=
 =0A=
 =0A=
-/* Constants to be programmed into the Xena's registers to configure=0A=
+/* =0A=
+ * Constants to be programmed into the Xena's registers to configure=0A=
  * the XAUI.=0A=
  */=0A=
 =0A=
@@ -188,7 +200,9 @@=0A=
 	END_SIGN=0A=
 };=0A=
 =0A=
-/* Constants for Fixing the MacAddress problem seen mostly on=0A=
+=0A=
+/* =0A=
+ * Constants for Fixing the MacAddress problem seen mostly on=0A=
  * Alpha machines.=0A=
  */=0A=
 static u64 fix_mac[] =3D {=0A=
@@ -209,16 +223,67 @@=0A=
 	END_SIGN=0A=
 };=0A=
 =0A=
-=0A=
 /* Module Loadable parameters. */=0A=
-static u32 ring_num;=0A=
 static u32 frame_len[MAX_RX_RINGS];=0A=
-static u32 ring_len[MAX_RX_RINGS];=0A=
-static u32 fifo_num;=0A=
-static u32 fifo_len[MAX_TX_FIFOS];=0A=
 static u32 rx_prio;=0A=
 static u32 tx_prio;=0A=
-static u8 latency_timer =3D 0;=0A=
+=0A=
+static unsigned int lso_enable =3D 1;=0A=
+#ifndef CONFIG_S2IO_NAPI=0A=
+static unsigned int indicate_max_pkts =3D 0;=0A=
+#endif=0A=
+static unsigned int cksum_offload_enable =3D 1;=0A=
+static unsigned int TxFifoNum =3D 1;=0A=
+static unsigned int TxFIFOLen_0 =3D DEFAULT_FIFO_LEN;=0A=
+static unsigned int TxFIFOLen_1 =3D 0;=0A=
+static unsigned int TxFIFOLen_2 =3D 0;=0A=
+static unsigned int TxFIFOLen_3 =3D 0;=0A=
+static unsigned int TxFIFOLen_4 =3D 0;=0A=
+static unsigned int TxFIFOLen_5 =3D 0;=0A=
+static unsigned int TxFIFOLen_6 =3D 0;=0A=
+static unsigned int TxFIFOLen_7 =3D 0;=0A=
+static unsigned int MaxTxDs =3D MAX_SKB_FRAGS;=0A=
+static unsigned int RxRingNum =3D 1;=0A=
+static unsigned int RxRingSz_0 =3D SMALL_BLK_CNT;=0A=
+static unsigned int RxRingSz_1 =3D 0;=0A=
+static unsigned int RxRingSz_2 =3D 0;=0A=
+static unsigned int RxRingSz_3 =3D 0;=0A=
+static unsigned int RxRingSz_4 =3D 0;=0A=
+static unsigned int RxRingSz_5 =3D 0;=0A=
+static unsigned int RxRingSz_6 =3D 0;=0A=
+static unsigned int RxRingSz_7 =3D 0;=0A=
+static unsigned int Stats_refresh_time =3D 4;=0A=
+static unsigned int rmac_pause_time =3D 65535;=0A=
+static unsigned int mc_pause_threshold_q0q3 =3D 187;=0A=
+static unsigned int mc_pause_threshold_q4q7 =3D 187;=0A=
+static unsigned int shared_splits =3D 0;=0A=
+#if defined(__ia64__)=0A=
+static unsigned int max_splits_trans =3D XENA_THREE_SPLIT_TRANSACTION;=0A=
+#else=0A=
+static unsigned int max_splits_trans =3D XENA_TWO_SPLIT_TRANSACTION;=0A=
+#endif=0A=
+static unsigned int tmac_util_period =3D 5;=0A=
+static unsigned int rmac_util_period =3D 5;=0A=
+static unsigned int tx_timer_val =3D 0xFFF;=0A=
+static unsigned int tx_utilz_periodic =3D 1;=0A=
+static unsigned int rx_timer_val =3D 0xFFF;=0A=
+static unsigned int rx_utilz_periodic =3D 1;=0A=
+static unsigned int tx_urange_a =3D 0xA;=0A=
+static unsigned int tx_ufc_a =3D 0x10;=0A=
+static unsigned int tx_urange_b =3D 0x10;=0A=
+static unsigned int tx_ufc_b =3D 0x20;=0A=
+static unsigned int tx_urange_c =3D 0x30;=0A=
+static unsigned int tx_ufc_c =3D 0x40;=0A=
+static unsigned int tx_ufc_d =3D 0x80;=0A=
+static unsigned int rx_urange_a =3D 0xA;=0A=
+static unsigned int rx_ufc_a =3D 0x1;=0A=
+static unsigned int rx_urange_b =3D 0x10;=0A=
+static unsigned int rx_ufc_b =3D 0x2;=0A=
+static unsigned int rx_urange_c =3D 0x30;=0A=
+static unsigned int rx_ufc_c =3D 0x40;=0A=
+static unsigned int rx_ufc_d =3D 0x80;=0A=
+static u8 latency_timer =3D 0xf8;=0A=
+static u8 max_read_byte_cnt =3D 2;=0A=
 =0A=
 /* =0A=
  * S2IO device table.=0A=
@@ -235,30 +300,36 @@=0A=
 MODULE_DEVICE_TABLE(pci, s2io_tbl);=0A=
 =0A=
 static struct pci_driver s2io_driver =3D {=0A=
-      name:"S2IO",=0A=
-      id_table:s2io_tbl,=0A=
-      probe:s2io_init_nic,=0A=
-      remove:__devexit_p(s2io_rem_nic),=0A=
+	name:"S2IO",=0A=
+	id_table:s2io_tbl,=0A=
+	probe:s2io_init_nic,=0A=
+	remove:__devexit_p(s2io_rem_nic),=0A=
 };=0A=
 =0A=
-/*  =0A=
- *  Input Arguments: =0A=
- *  Device private variable.=0A=
- *  Return Value: =0A=
- *  SUCCESS on success and an appropriate -ve value on failure.=0A=
- *  Description: =0A=
- *  The function allocates the all memory areas shared =0A=
- *  between the NIC and the driver. This includes Tx descriptors, =0A=
- *  Rx descriptors and the statistics block.=0A=
+/* A simplifier macro used both by init and free shared_mem Fns(). */=0A=
+#define container_index(len, per_each) ((len+per_each - 1) / per_each)=0A=
+=0A=
+/**=0A=
+ * init_shared_mem - Allocation and Initialization of Memory=0A=
+ * @nic: Device private variable.=0A=
+ * Description: The function allocates the all memory areas shared =0A=
+ * between the NIC and the driver. This includes Tx descriptors, =0A=
+ * Rx descriptors and the statistics block.=0A=
  */=0A=
-static int initSharedMem(struct s2io_nic *nic)=0A=
+=0A=
+static int init_shared_mem(struct s2io_nic *nic)=0A=
 {=0A=
 	u32 size;=0A=
 	void *tmp_v_addr, *tmp_v_addr_next;=0A=
 	dma_addr_t tmp_p_addr, tmp_p_addr_next;=0A=
 	RxD_block_t *pre_rxd_blk =3D NULL;=0A=
 	int i, j, blk_cnt;=0A=
+	int lst_size, lst_per_page;=0A=
 	struct net_device *dev =3D nic->dev;=0A=
+#ifdef CONFIG_2BUFF_MODE=0A=
+	u64 tmp;=0A=
+	buffAdd_t *ba;=0A=
+#endif=0A=
 =0A=
 	mac_info_t *mac_control;=0A=
 	struct config_param *config;=0A=
@@ -270,7 +341,7 @@=0A=
 	/* Allocation and initialization of TXDLs in FIOFs */=0A=
 	size =3D 0;=0A=
 	for (i =3D 0; i < config->TxFIFONum; i++) {=0A=
-		size +=3D config->TxCfg[i].FifoLen;=0A=
+		size +=3D config->tx_cfg[i].FifoLen;=0A=
 	}=0A=
 	if (size > MAX_AVAILABLE_TXDS) {=0A=
 		DBG_PRINT(ERR_DBG, "%s: Total number of Tx FIFOs ",=0A=
@@ -279,55 +350,71 @@=0A=
 		DBG_PRINT(ERR_DBG, "that can be used\n");=0A=
 		return FAILURE;=0A=
 	}=0A=
-	size *=3D (sizeof(TxD_t) * config->MaxTxDs);=0A=
 =0A=
-	mac_control->txd_list_mem =3D pci_alloc_consistent=0A=
-	    (nic->pdev, size, &mac_control->txd_list_mem_phy);=0A=
-	if (!mac_control->txd_list_mem) {=0A=
-		return -ENOMEM;=0A=
-	}=0A=
-	mac_control->txd_list_mem_sz =3D size;=0A=
-=0A=
-	tmp_v_addr =3D mac_control->txd_list_mem;=0A=
-	tmp_p_addr =3D mac_control->txd_list_mem_phy;=0A=
-	memset(tmp_v_addr, 0, size);=0A=
-=0A=
-	DBG_PRINT(INIT_DBG, "%s:List Mem PHY: 0x%llx\n", dev->name,=0A=
-		  (unsigned long long) tmp_p_addr);=0A=
+	lst_size =3D (sizeof(TxD_t) * config->MaxTxDs);=0A=
+	lst_per_page =3D PAGE_SIZE / lst_size;=0A=
 =0A=
 	for (i =3D 0; i < config->TxFIFONum; i++) {=0A=
-		mac_control->txdl_start_phy[i] =3D tmp_p_addr;=0A=
-		mac_control->txdl_start[i] =3D (TxD_t *) tmp_v_addr;=0A=
+		int fifo_len =3D config->tx_cfg[i].FifoLen;=0A=
+		int list_holder_size =3D fifo_len * sizeof(list_info_hold_t);=0A=
+		nic->list_info[i] =3D kmalloc(list_holder_size, GFP_KERNEL);=0A=
+		if (!nic->list_info[i]) {=0A=
+			DBG_PRINT(ERR_DBG,=0A=
+				  "Malloc failed for list_info\n");=0A=
+			return -ENOMEM;=0A=
+		}=0A=
+		memset(nic->list_info[i], 0, list_holder_size);=0A=
+	}=0A=
+	for (i =3D 0; i < config->TxFIFONum; i++) {=0A=
+		int page_num =3D container_index(config->tx_cfg[i].FifoLen,=0A=
+					       lst_per_page);=0A=
 		mac_control->tx_curr_put_info[i].offset =3D 0;=0A=
 		mac_control->tx_curr_put_info[i].fifo_len =3D=0A=
-		    config->TxCfg[i].FifoLen - 1;=0A=
+		    config->tx_cfg[i].FifoLen - 1;=0A=
 		mac_control->tx_curr_get_info[i].offset =3D 0;=0A=
 		mac_control->tx_curr_get_info[i].fifo_len =3D=0A=
-		    config->TxCfg[i].FifoLen - 1;=0A=
-=0A=
-		tmp_p_addr +=3D=0A=
-		    (config->TxCfg[i].FifoLen * (sizeof(TxD_t)) *=0A=
-		     config->MaxTxDs);=0A=
-		tmp_v_addr +=3D=0A=
-		    (config->TxCfg[i].FifoLen * (sizeof(TxD_t)) *=0A=
-		     config->MaxTxDs);=0A=
+		    config->tx_cfg[i].FifoLen - 1;=0A=
+		for (j =3D 0; j < page_num; j++) {=0A=
+			int k =3D 0;=0A=
+			dma_addr_t tmp_p;=0A=
+			void *tmp_v;=0A=
+			tmp_v =3D pci_alloc_consistent(nic->pdev,=0A=
+						     PAGE_SIZE, &tmp_p);=0A=
+			if (!tmp_v) {=0A=
+				DBG_PRINT(ERR_DBG,=0A=
+					  "pci_alloc_consistent ");=0A=
+				DBG_PRINT(ERR_DBG, "failed for TxDL\n");=0A=
+				return -ENOMEM;=0A=
+			}=0A=
+			while (k < lst_per_page) {=0A=
+				int l =3D (j * lst_per_page) + k;=0A=
+				if (l =3D=3D config->tx_cfg[i].FifoLen)=0A=
+					goto end_txd_alloc;=0A=
+				nic->list_info[i][l].list_virt_addr =3D=0A=
+				    tmp_v + (k * lst_size);=0A=
+				nic->list_info[i][l].list_phy_addr =3D=0A=
+				    tmp_p + (k * lst_size);=0A=
+				k++;=0A=
+			}=0A=
+		}=0A=
 	}=0A=
+      end_txd_alloc:=0A=
 =0A=
 	/* Allocation and initialization of RXDs in Rings */=0A=
 	size =3D 0;=0A=
 	for (i =3D 0; i < config->RxRingNum; i++) {=0A=
-		if (config->RxCfg[i].NumRxd % (MAX_RXDS_PER_BLOCK + 1)) {=0A=
+		if (config->rx_cfg[i].NumRxd % (MAX_RXDS_PER_BLOCK + 1)) {=0A=
 			DBG_PRINT(ERR_DBG, "%s: RxD count of ", dev->name);=0A=
 			DBG_PRINT(ERR_DBG, "Ring%d is not a multiple of ",=0A=
 				  i);=0A=
 			DBG_PRINT(ERR_DBG, "RxDs per Block");=0A=
 			return FAILURE;=0A=
 		}=0A=
-		size +=3D config->RxCfg[i].NumRxd;=0A=
+		size +=3D config->rx_cfg[i].NumRxd;=0A=
 		nic->block_count[i] =3D=0A=
-		    config->RxCfg[i].NumRxd / (MAX_RXDS_PER_BLOCK + 1);=0A=
+		    config->rx_cfg[i].NumRxd / (MAX_RXDS_PER_BLOCK + 1);=0A=
 		nic->pkt_cnt[i] =3D=0A=
-		    config->RxCfg[i].NumRxd - nic->block_count[i];=0A=
+		    config->rx_cfg[i].NumRxd - nic->block_count[i];=0A=
 	}=0A=
 	size =3D (size * (sizeof(RxD_t)));=0A=
 	mac_control->rxd_ring_mem_sz =3D size;=0A=
@@ -336,20 +423,25 @@=0A=
 		mac_control->rx_curr_get_info[i].block_index =3D 0;=0A=
 		mac_control->rx_curr_get_info[i].offset =3D 0;=0A=
 		mac_control->rx_curr_get_info[i].ring_len =3D=0A=
-		    config->RxCfg[i].NumRxd - 1;=0A=
+		    config->rx_cfg[i].NumRxd - 1;=0A=
 		mac_control->rx_curr_put_info[i].block_index =3D 0;=0A=
 		mac_control->rx_curr_put_info[i].offset =3D 0;=0A=
 		mac_control->rx_curr_put_info[i].ring_len =3D=0A=
-		    config->RxCfg[i].NumRxd - 1;=0A=
+		    config->rx_cfg[i].NumRxd - 1;=0A=
 		blk_cnt =3D=0A=
-		    config->RxCfg[i].NumRxd / (MAX_RXDS_PER_BLOCK + 1);=0A=
+		    config->rx_cfg[i].NumRxd / (MAX_RXDS_PER_BLOCK + 1);=0A=
 		/*  Allocating all the Rx blocks */=0A=
 		for (j =3D 0; j < blk_cnt; j++) {=0A=
+#ifndef CONFIG_2BUFF_MODE=0A=
 			size =3D (MAX_RXDS_PER_BLOCK + 1) * (sizeof(RxD_t));=0A=
+#else=0A=
+			size =3D SIZE_OF_BLOCK;=0A=
+#endif=0A=
 			tmp_v_addr =3D pci_alloc_consistent(nic->pdev, size,=0A=
 							  &tmp_p_addr);=0A=
 			if (tmp_v_addr =3D=3D NULL) {=0A=
-				/* In case of failure, freeSharedMem() =0A=
+				/*=0A=
+				 * In case of failure, free_shared_mem() =0A=
 				 * is called, which should free any =0A=
 				 * memory that was alloced till the =0A=
 				 * failure happened.=0A=
@@ -377,20 +469,68 @@=0A=
 			pre_rxd_blk->reserved_1 =3D END_OF_BLOCK;	/* last RxD =0A=
 								 * marker.=0A=
 								 */=0A=
+#ifndef	CONFIG_2BUFF_MODE=0A=
 			pre_rxd_blk->reserved_2_pNext_RxD_block =3D=0A=
 			    (unsigned long) tmp_v_addr_next;=0A=
+#endif=0A=
 			pre_rxd_blk->pNext_RxD_Blk_physical =3D=0A=
 			    (u64) tmp_p_addr_next;=0A=
 		}=0A=
 	}=0A=
 =0A=
+#ifdef CONFIG_2BUFF_MODE=0A=
+	/* =0A=
+	 * Allocation of Storages for buffer addresses in 2BUFF mode=0A=
+	 * and the buffers as well.=0A=
+	 */=0A=
+	for (i =3D 0; i < config->RxRingNum; i++) {=0A=
+		blk_cnt =3D=0A=
+		    config->rx_cfg[i].NumRxd / (MAX_RXDS_PER_BLOCK + 1);=0A=
+		nic->ba[i] =3D kmalloc((sizeof(buffAdd_t *) * blk_cnt),=0A=
+				     GFP_KERNEL);=0A=
+		if (!nic->ba[i])=0A=
+			return -ENOMEM;=0A=
+		for (j =3D 0; j < blk_cnt; j++) {=0A=
+			int k =3D 0;=0A=
+			nic->ba[i][j] =3D kmalloc((sizeof(buffAdd_t) *=0A=
+						 (MAX_RXDS_PER_BLOCK + 1)),=0A=
+						GFP_KERNEL);=0A=
+			if (!nic->ba[i][j])=0A=
+				return -ENOMEM;=0A=
+			while (k !=3D MAX_RXDS_PER_BLOCK) {=0A=
+				ba =3D &nic->ba[i][j][k];=0A=
+=0A=
+				ba->ba_0_org =3D (void *) kmalloc=0A=
+				    (BUF0_LEN + ALIGN_SIZE, GFP_ATOMIC);=0A=
+				if (!ba->ba_0_org)=0A=
+					return -ENOMEM;=0A=
+				tmp =3D (u64) ba->ba_0_org;=0A=
+				tmp +=3D ALIGN_SIZE;=0A=
+				tmp &=3D ~((u64) ALIGN_SIZE);=0A=
+				ba->ba_0 =3D (void *) tmp;=0A=
+=0A=
+				ba->ba_1_org =3D (void *) kmalloc=0A=
+				    (BUF1_LEN + ALIGN_SIZE, GFP_ATOMIC);=0A=
+				if (!ba->ba_1_org)=0A=
+					return -ENOMEM;=0A=
+				tmp =3D (u64) ba->ba_1_org;=0A=
+				tmp +=3D ALIGN_SIZE;=0A=
+				tmp &=3D ~((u64) ALIGN_SIZE);=0A=
+				ba->ba_1 =3D (void *) tmp;=0A=
+				k++;=0A=
+			}=0A=
+		}=0A=
+	}=0A=
+#endif=0A=
+=0A=
 	/* Allocation and initialization of Statistics block */=0A=
 	size =3D sizeof(StatInfo_t);=0A=
 	mac_control->stats_mem =3D pci_alloc_consistent=0A=
 	    (nic->pdev, size, &mac_control->stats_mem_phy);=0A=
 =0A=
 	if (!mac_control->stats_mem) {=0A=
-		/* In case of failure, freeSharedMem() is called, which =0A=
+		/* =0A=
+		 * In case of failure, free_shared_mem() is called, which =0A=
 		 * should free any memory that was alloced till the =0A=
 		 * failure happened.=0A=
 		 */=0A=
@@ -399,8 +539,12 @@=0A=
 	mac_control->stats_mem_sz =3D size;=0A=
 =0A=
 	tmp_v_addr =3D mac_control->stats_mem;=0A=
-	mac_control->StatsInfo =3D (StatInfo_t *) tmp_v_addr;=0A=
+	mac_control->stats_info =3D (StatInfo_t *) tmp_v_addr;=0A=
 	memset(tmp_v_addr, 0, size);=0A=
+#ifdef SNMP_SUPPORT=0A=
+	nic->nMemorySize =3D mac_control->txd_list_mem_sz +=0A=
+	    mac_control->stats_mem_sz + mac_control->rxd_ring_mem_sz;=0A=
+#endif=0A=
 =0A=
 	DBG_PRINT(INIT_DBG, "%s:Ring Mem PHY: 0x%llx\n", dev->name,=0A=
 		  (unsigned long long) tmp_p_addr);=0A=
@@ -408,22 +552,21 @@=0A=
 	return SUCCESS;=0A=
 }=0A=
 =0A=
-/*  =0A=
- *  Input Arguments: =0A=
- *  Device peivate variable.=0A=
- *  Return Value: =0A=
- *  NONE=0A=
- *  Description: =0A=
- *  This function is to free all memory locations allocated by=0A=
- *  the initSharedMem() function and return it to the kernel.=0A=
+/**  =0A=
+ * free_shared_mem - Free the allocated Memory =0A=
+ * @nic:  Device private variable.=0A=
+ * Description: This function is to free all memory locations allocated =
by=0A=
+ * the init_shared_mem() function and return it to the kernel.=0A=
  */=0A=
-static void freeSharedMem(struct s2io_nic *nic)=0A=
+=0A=
+static void free_shared_mem(struct s2io_nic *nic)=0A=
 {=0A=
 	int i, j, blk_cnt, size;=0A=
 	void *tmp_v_addr;=0A=
 	dma_addr_t tmp_p_addr;=0A=
 	mac_info_t *mac_control;=0A=
 	struct config_param *config;=0A=
+	int lst_size, lst_per_page;=0A=
 =0A=
 =0A=
 	if (!nic)=0A=
@@ -432,14 +575,30 @@=0A=
 	mac_control =3D &nic->mac_control;=0A=
 	config =3D &nic->config;=0A=
 =0A=
-	if (mac_control->txd_list_mem) {=0A=
-		pci_free_consistent(nic->pdev,=0A=
-				    mac_control->txd_list_mem_sz,=0A=
-				    mac_control->txd_list_mem,=0A=
-				    mac_control->txd_list_mem_phy);=0A=
+	lst_size =3D (sizeof(TxD_t) * config->MaxTxDs);=0A=
+	lst_per_page =3D PAGE_SIZE / lst_size;=0A=
+=0A=
+	for (i =3D 0; i < config->TxFIFONum; i++) {=0A=
+		int page_num =3D container_index(config->tx_cfg[i].FifoLen,=0A=
+					       lst_per_page);=0A=
+		for (j =3D 0; j < page_num; j++) {=0A=
+			int mem_blks =3D (j * lst_per_page);=0A=
+			if (!nic->list_info[i][mem_blks].list_virt_addr)=0A=
+				break;=0A=
+			pci_free_consistent(nic->pdev, PAGE_SIZE,=0A=
+					    nic->list_info[i][mem_blks].=0A=
+					    list_virt_addr,=0A=
+					    nic->list_info[i][mem_blks].=0A=
+					    list_phy_addr);=0A=
+		}=0A=
+		kfree(nic->list_info[i]);=0A=
 	}=0A=
 =0A=
+#ifndef CONFIG_2BUFF_MODE=0A=
 	size =3D (MAX_RXDS_PER_BLOCK + 1) * (sizeof(RxD_t));=0A=
+#else=0A=
+	size =3D SIZE_OF_BLOCK;=0A=
+#endif=0A=
 	for (i =3D 0; i < config->RxRingNum; i++) {=0A=
 		blk_cnt =3D nic->block_count[i];=0A=
 		for (j =3D 0; j < blk_cnt; j++) {=0A=
@@ -452,6 +611,28 @@=0A=
 		}=0A=
 	}=0A=
 =0A=
+#ifdef CONFIG_2BUFF_MODE=0A=
+	/* Freeing buffer storage addresses in 2BUFF mode. */=0A=
+	for (i =3D 0; i < config->RxRingNum; i++) {=0A=
+		blk_cnt =3D=0A=
+		    config->rx_cfg[i].NumRxd / (MAX_RXDS_PER_BLOCK + 1);=0A=
+		for (j =3D 0; j < blk_cnt; j++) {=0A=
+			int k =3D 0;=0A=
+			if (!nic->ba[i][j])=0A=
+				continue;=0A=
+			while (k !=3D MAX_RXDS_PER_BLOCK) {=0A=
+				buffAdd_t *ba =3D &nic->ba[i][j][k];=0A=
+				kfree(ba->ba_0_org);=0A=
+				kfree(ba->ba_1_org);=0A=
+				k++;=0A=
+			}=0A=
+			kfree(nic->ba[i][j]);=0A=
+		}=0A=
+		if (nic->ba[i])=0A=
+			kfree(nic->ba[i]);=0A=
+	}=0A=
+#endif=0A=
+=0A=
 	if (mac_control->stats_mem) {=0A=
 		pci_free_consistent(nic->pdev,=0A=
 				    mac_control->stats_mem_sz,=0A=
@@ -460,16 +641,16 @@=0A=
 	}=0A=
 }=0A=
 =0A=
-/*  =0A=
- *  Input Arguments: =0A=
- *  device peivate variable=0A=
- *  Return Value: =0A=
- *  SUCCESS on success and '-1' on failure (endian settings incorrect).=0A=
- *  Description: =0A=
- *  The function sequentially configures every block =0A=
+/**  =0A=
+ *  init_nic - Initialization of hardware =0A=
+ *  @nic: device peivate variable=0A=
+ *  Description: The function sequentially configures every block =0A=
  *  of the H/W from their reset values. =0A=
+ *  Returns:  SUCCESS on success and =0A=
+ *  '-1' on failure (endian settings incorrect).=0A=
  */=0A=
-static int initNic(struct s2io_nic *nic)=0A=
+=0A=
+static int init_nic(struct s2io_nic *nic)=0A=
 {=0A=
 	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) nic->bar0;=0A=
 	struct net_device *dev =3D nic->dev;=0A=
@@ -485,11 +666,13 @@=0A=
 	mac_control =3D &nic->mac_control;=0A=
 	config =3D &nic->config;=0A=
 =0A=
-	/*  Set proper endian settings and verify the same by =0A=
-	 *  reading the PIF Feed-back register.=0A=
+	/* =0A=
+	 * Set proper endian settings and verify the same by =0A=
+	 * reading the PIF Feed-back register.=0A=
 	 */=0A=
 #ifdef  __BIG_ENDIAN=0A=
-	/* The device by default set to a big endian format, so =0A=
+	/*=0A=
+	 * The device by default set to a big endian format, so =0A=
 	 * a big endian driver need not set anything.=0A=
 	 */=0A=
 	writeq(0xffffffffffffffffULL, &bar0->swapper_ctrl);=0A=
@@ -510,7 +693,8 @@=0A=
 		 SWAPPER_CTRL_STATS_FE | SWAPPER_CTRL_STATS_SE);=0A=
 	writeq(val64, &bar0->swapper_ctrl);=0A=
 #else=0A=
-	/* Initially we enable all bits to make it accessible by =0A=
+	/* =0A=
+	 * Initially we enable all bits to make it accessible by =0A=
 	 * the driver, then we selectively enable only those bits =0A=
 	 * that we want to set.=0A=
 	 */=0A=
@@ -537,8 +721,9 @@=0A=
 	writeq(val64, &bar0->swapper_ctrl);=0A=
 #endif=0A=
 =0A=
-	/* Verifying if endian settings are accurate by reading =0A=
-	 * a feedback register.=0A=
+	/* =0A=
+	 * Verifying if endian settings are accurate by =0A=
+	 * reading a feedback register.=0A=
 	 */=0A=
 	val64 =3D readq(&bar0->pif_rd_swapper_fb);=0A=
 	if (val64 !=3D 0x0123456789ABCDEFULL) {=0A=
@@ -559,10 +744,13 @@=0A=
 	schedule_timeout(HZ / 2);=0A=
 =0A=
 	/*  Enable Receiving broadcasts */=0A=
+	add =3D (void *) &bar0->mac_cfg;=0A=
 	val64 =3D readq(&bar0->mac_cfg);=0A=
 	val64 |=3D MAC_RMAC_BCAST_ENABLE;=0A=
 	writeq(RMAC_CFG_KEY(0x4C0D), &bar0->rmac_cfg_key);=0A=
-	writeq(val64, &bar0->mac_cfg);=0A=
+	writel((u32) val64, add);=0A=
+	writeq(RMAC_CFG_KEY(0x4C0D), &bar0->rmac_cfg_key);=0A=
+	writel((u32) (val64 >> 32), (add + 4));=0A=
 =0A=
 	/* Read registers in all blocks */=0A=
 	val64 =3D readq(&bar0->mac_int_mask);=0A=
@@ -573,8 +761,9 @@=0A=
 	val64 =3D dev->mtu;=0A=
 	writeq(vBIT(val64, 2, 14), &bar0->rmac_max_pyld_len);=0A=
 =0A=
-	/* Configuring the XAUI Interface of Xena. =0A=
-	 *****************************************=0A=
+	/* =0A=
+	 * Configuring the XAUI Interface of Xena. =0A=
+	 * ***************************************=0A=
 	 * To Configure the Xena's XAUI, one has to write a series =0A=
 	 * of 64 bit values into two registers in a particular =0A=
 	 * sequence. Hence a macro 'SWITCH_SIGN' has been defined =0A=
@@ -593,8 +782,8 @@=0A=
 				dtx_cnt++;=0A=
 				goto mdio_cfg;=0A=
 			}=0A=
-			writeq(default_dtx_cfg[dtx_cnt],=0A=
-			       &bar0->dtx_control);=0A=
+			SPECIAL_REG_WRITE(default_dtx_cfg[dtx_cnt],=0A=
+					  &bar0->dtx_control, UF);=0A=
 			val64 =3D readq(&bar0->dtx_control);=0A=
 			dtx_cnt++;=0A=
 		}=0A=
@@ -604,8 +793,8 @@=0A=
 				mdio_cnt++;=0A=
 				goto dtx_cfg;=0A=
 			}=0A=
-			writeq(default_mdio_cfg[mdio_cnt],=0A=
-			       &bar0->mdio_control);=0A=
+			SPECIAL_REG_WRITE(default_mdio_cfg[mdio_cnt],=0A=
+					  &bar0->mdio_control, UF);=0A=
 			val64 =3D readq(&bar0->mdio_control);=0A=
 			mdio_cnt++;=0A=
 		}=0A=
@@ -627,8 +816,8 @@=0A=
 =0A=
 	for (i =3D 0, j =3D 0; i < config->TxFIFONum; i++) {=0A=
 		val64 |=3D=0A=
-		    vBIT(config->TxCfg[i].FifoLen - 1, ((i * 32) + 19),=0A=
-			 13) | vBIT(config->TxCfg[i].FifoPriority,=0A=
+		    vBIT(config->tx_cfg[i].FifoLen - 1, ((i * 32) + 19),=0A=
+			 13) | vBIT(config->tx_cfg[i].FifoPriority,=0A=
 				    ((i * 32) + 5), 3);=0A=
 =0A=
 		if (i =3D=3D (config->TxFIFONum - 1)) {=0A=
@@ -677,12 +866,13 @@=0A=
 	val64 =3D 0;=0A=
 	for (i =3D 0; i < config->RxRingNum; i++) {=0A=
 		val64 |=3D=0A=
-		    vBIT(config->RxCfg[i].RingPriority, (5 + (i * 8)), 3);=0A=
+		    vBIT(config->rx_cfg[i].RingPriority, (5 + (i * 8)), 3);=0A=
 	}=0A=
 	writeq(val64, &bar0->rx_queue_priority);=0A=
 =0A=
-	/* Allocating equal share of memory to all the configured =0A=
-	 * Rings.=0A=
+	/* =0A=
+	 * Allocating equal share of memory to all the =0A=
+	 * configured Rings.=0A=
 	 */=0A=
 	val64 =3D 0;=0A=
 	for (i =3D 0; i < config->RxRingNum; i++) {=0A=
@@ -724,7 +914,8 @@=0A=
 	}=0A=
 	writeq(val64, &bar0->rx_queue_cfg);=0A=
 =0A=
-	/* Initializing the Tx round robin registers to 0.=0A=
+	/* =0A=
+	 * Initializing the Tx round robin registers to 0.=0A=
 	 * Filling Tx and Rx round robin registers as per the =0A=
 	 * number of FIFOs and Rings is still TODO.=0A=
 	 */=0A=
@@ -734,9 +925,11 @@=0A=
 	writeq(0, &bar0->tx_w_round_robin_3);=0A=
 	writeq(0, &bar0->tx_w_round_robin_4);=0A=
 =0A=
-	/* Disable Rx steering. Hard coding all packets be steered to=0A=
+	/* =0A=
+	 * TODO=0A=
+	 * Disable Rx steering. Hard coding all packets be steered to=0A=
 	 * Queue 0 for now. =0A=
-	 * TODO*/=0A=
+	 */=0A=
 	if (rx_prio) {=0A=
 		u64 def =3D 0x8000000000000000ULL, tmp;=0A=
 		for (i =3D 0; i < MAX_RX_RINGS; i++) {=0A=
@@ -760,34 +953,43 @@=0A=
 =0A=
 	/* Enable statistics */=0A=
 	writeq(mac_control->stats_mem_phy, &bar0->stat_addr);=0A=
-	val64 =3D SET_UPDT_PERIOD(8) | STAT_CFG_STAT_RO | STAT_CFG_STAT_EN;=0A=
+	val64 =3D SET_UPDT_PERIOD(Stats_refresh_time) |=0A=
+	    STAT_CFG_STAT_RO | STAT_CFG_STAT_EN;=0A=
 	writeq(val64, &bar0->stat_cfg);=0A=
 =0A=
-	/* Initializing the sampling rate for the device to calculate the=0A=
+	/* =0A=
+	 * Initializing the sampling rate for the device to calculate the=0A=
 	 * bandwidth utilization.=0A=
 	 */=0A=
-	val64 =3D MAC_TX_LINK_UTIL_VAL(0x5) | MAC_RX_LINK_UTIL_VAL(0x5);=0A=
+	val64 =3D MAC_TX_LINK_UTIL_VAL(tmac_util_period) |=0A=
+	    MAC_RX_LINK_UTIL_VAL(rmac_util_period);=0A=
 	writeq(val64, &bar0->mac_link_util);=0A=
 =0A=
 =0A=
-	/* Initializing the Transmit and Receive Traffic Interrupt =0A=
+	/* =0A=
+	 * Initializing the Transmit and Receive Traffic Interrupt =0A=
 	 * Scheme.=0A=
 	 */=0A=
 	/* TTI Initialization */=0A=
-	val64 =3D TTI_DATA1_MEM_TX_TIMER_VAL(0xFFF) |=0A=
-	    TTI_DATA1_MEM_TX_URNG_A(0xA) | TTI_DATA1_MEM_TX_URNG_B(0x10) |=0A=
-	    TTI_DATA1_MEM_TX_URNG_C(0x30) | TTI_DATA1_MEM_TX_TIMER_AC_EN;=0A=
+	val64 =3D TTI_DATA1_MEM_TX_TIMER_VAL(tx_timer_val) |=0A=
+	    TTI_DATA1_MEM_TX_URNG_A(tx_urange_a) |=0A=
+	    TTI_DATA1_MEM_TX_URNG_B(tx_urange_b) |=0A=
+	    TTI_DATA1_MEM_TX_URNG_C(tx_urange_c);=0A=
+	if (tx_utilz_periodic)=0A=
+		val64 |=3D TTI_DATA1_MEM_TX_TIMER_AC_EN;=0A=
 	writeq(val64, &bar0->tti_data1_mem);=0A=
 =0A=
-	val64 =3D=0A=
-	    TTI_DATA2_MEM_TX_UFC_A(0x10) | TTI_DATA2_MEM_TX_UFC_B(0x20) |=0A=
-	    TTI_DATA2_MEM_TX_UFC_C(0x40) | TTI_DATA2_MEM_TX_UFC_D(0x80);=0A=
+	val64 =3D TTI_DATA2_MEM_TX_UFC_A(tx_ufc_a) |=0A=
+	    TTI_DATA2_MEM_TX_UFC_B(tx_ufc_b) |=0A=
+	    TTI_DATA2_MEM_TX_UFC_C(tx_ufc_c) |=0A=
+	    TTI_DATA2_MEM_TX_UFC_D(tx_ufc_d);=0A=
 	writeq(val64, &bar0->tti_data2_mem);=0A=
 =0A=
 	val64 =3D TTI_CMD_MEM_WE | TTI_CMD_MEM_STROBE_NEW_CMD;=0A=
 	writeq(val64, &bar0->tti_command_mem);=0A=
 =0A=
-	/* Once the operation completes, the Strobe bit of the command=0A=
+	/* =0A=
+	 * Once the operation completes, the Strobe bit of the command=0A=
 	 * register will be reset. We poll for this particular condition=0A=
 	 * We wait for a maximum of 500ms for the operation to complete,=0A=
 	 * if it's not complete by then we return error.=0A=
@@ -809,19 +1011,26 @@=0A=
 	}=0A=
 =0A=
 	/* RTI Initialization */=0A=
-	val64 =3D RTI_DATA1_MEM_RX_TIMER_VAL(0xFFF) |=0A=
-	    RTI_DATA1_MEM_RX_URNG_A(0xA) | RTI_DATA1_MEM_RX_URNG_B(0x10) |=0A=
-	    RTI_DATA1_MEM_RX_URNG_C(0x30) | RTI_DATA1_MEM_RX_TIMER_AC_EN;=0A=
+	val64 =3D RTI_DATA1_MEM_RX_TIMER_VAL(rx_timer_val) |=0A=
+	    RTI_DATA1_MEM_RX_URNG_A(rx_urange_a) |=0A=
+	    RTI_DATA1_MEM_RX_URNG_B(rx_urange_b) |=0A=
+	    RTI_DATA1_MEM_RX_URNG_C(rx_urange_c);=0A=
+	if (rx_utilz_periodic)=0A=
+		val64 |=3D RTI_DATA1_MEM_RX_TIMER_AC_EN;=0A=
+=0A=
 	writeq(val64, &bar0->rti_data1_mem);=0A=
 =0A=
-	val64 =3D RTI_DATA2_MEM_RX_UFC_A(0x1) | RTI_DATA2_MEM_RX_UFC_B(0x2) |=0A=
-	    RTI_DATA2_MEM_RX_UFC_C(0x40) | RTI_DATA2_MEM_RX_UFC_D(0x80);=0A=
+	val64 =3D RTI_DATA2_MEM_RX_UFC_A(rx_ufc_a) |=0A=
+	    RTI_DATA2_MEM_RX_UFC_B(rx_ufc_b) |=0A=
+	    RTI_DATA2_MEM_RX_UFC_C(rx_ufc_c) |=0A=
+	    RTI_DATA2_MEM_RX_UFC_D(rx_ufc_d);=0A=
 	writeq(val64, &bar0->rti_data2_mem);=0A=
 =0A=
 	val64 =3D RTI_CMD_MEM_WE | RTI_CMD_MEM_STROBE_NEW_CMD;=0A=
 	writeq(val64, &bar0->rti_command_mem);=0A=
 =0A=
-	/* Once the operation completes, the Strobe bit of the command=0A=
+	/* =0A=
+	 * Once the operation completes, the Strobe bit of the command=0A=
 	 * register will be reset. We poll for this particular condition=0A=
 	 * We wait for a maximum of 500ms for the operation to complete,=0A=
 	 * if it's not complete by then we return error.=0A=
@@ -842,7 +1051,8 @@=0A=
 		schedule_timeout(HZ / 20);=0A=
 	}=0A=
 =0A=
-	/* Initializing proper values as Pause threshold into all =0A=
+	/* =0A=
+	 * Initializing proper values as Pause threshold into all =0A=
 	 * the 8 Queues on Rx side.=0A=
 	 */=0A=
 	writeq(0xffbbffbbffbbffbbULL, &bar0->mc_pause_thresh_q0q3);=0A=
@@ -858,22 +1068,62 @@=0A=
 	writel((u32) (val64 >> 32), (add + 4));=0A=
 	val64 =3D readq(&bar0->mac_cfg);=0A=
 =0A=
+	/* =0A=
+	 * Set the time value to be inserted in the pause frame =0A=
+	 * generated by xena.=0A=
+	 */=0A=
+	val64 =3D readq(&bar0->rmac_pause_cfg);=0A=
+	val64 &=3D ~(RMAC_PAUSE_HG_PTIME(0xffff));=0A=
+	val64 |=3D RMAC_PAUSE_HG_PTIME(nic->mac_control.rmac_pause_time);=0A=
+	writeq(val64, &bar0->rmac_pause_cfg);=0A=
+=0A=
+	/* =0A=
+	 * Set the Threshold Limit for Generating the pause frame=0A=
+	 * If the amount of data in any Queue exceeds ratio of=0A=
+	 * (mac_control.mc_pause_threshold_q0q3 or q4q7)/256=0A=
+	 * pause frame is generated=0A=
+	 */=0A=
+	val64 =3D 0;=0A=
+	for (i =3D 0; i < 4; i++) {=0A=
+		val64 |=3D=0A=
+		    (((u64) 0xFF00 | nic->mac_control.=0A=
+		      mc_pause_threshold_q0q3)=0A=
+		     << (i * 2 * 8));=0A=
+	}=0A=
+	writeq(val64, &bar0->mc_pause_thresh_q0q3);=0A=
+=0A=
+	val64 =3D 0;=0A=
+	for (i =3D 0; i < 4; i++) {=0A=
+		val64 |=3D=0A=
+		    (((u64) 0xFF00 | nic->mac_control.=0A=
+		      mc_pause_threshold_q4q7)=0A=
+		     << (i * 2 * 8));=0A=
+	}=0A=
+	writeq(val64, &bar0->mc_pause_thresh_q4q7);=0A=
+=0A=
+	/* =0A=
+	 * TxDMA will stop Read request if the number of read split has =0A=
+	 * exceeded the limit pointed by shared_splits=0A=
+	 */=0A=
+	val64 =3D readq(&bar0->pic_control);=0A=
+	val64 |=3D PIC_CNTL_SHARED_SPLITS(shared_splits);=0A=
+	writeq(val64, &bar0->pic_control);=0A=
+=0A=
 	return SUCCESS;=0A=
 }=0A=
 =0A=
-/*  =0A=
- *  Input Arguments: =0A=
- *  device private variable,=0A=
- *  A mask indicating which Intr block must be modified and,=0A=
- *  A flag indicating whether to enable or disable the Intrs.=0A=
- *  Return Value: =0A=
- *  NONE.=0A=
- *  Description: =0A=
- *  This function will either disable or enable the interrupts =0A=
+/**  =0A=
+ *  en_dis_able_nic_intrs - Enable or Disable the interrupts =0A=
+ *  @nic: device private variable,=0A=
+ *  @mask: A mask indicating which Intr block must be modified and,=0A=
+ *  @flag: A flag indicating whether to enable or disable the Intrs.=0A=
+ *  Description: This function will either disable or enable the =
interrupts=0A=
  *  depending on the flag argument. The mask argument can be used to =0A=
  *  enable/disable any Intr block. =0A=
+ *  Return Value: NONE.=0A=
  */=0A=
-static void en_dis_able_NicIntrs(struct s2io_nic *nic, u16 mask, int =
flag)=0A=
+=0A=
+static void en_dis_able_nic_intrs(struct s2io_nic *nic, u16 mask, int =
flag)=0A=
 {=0A=
 	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) nic->bar0;=0A=
 	register u64 val64 =3D 0, temp64 =3D 0;=0A=
@@ -887,15 +1137,20 @@=0A=
 			temp64 =3D readq(&bar0->general_int_mask);=0A=
 			temp64 &=3D ~((u64) val64);=0A=
 			writeq(temp64, &bar0->general_int_mask);=0A=
-			/*  Disabled all PCIX, Flash, MDIO, IIC and GPIO=0A=
-			 *  interrupts for now. =0A=
-			 * TODO */=0A=
+			/*  =0A=
+			 * Disabled all PCIX, Flash, MDIO, IIC and GPIO=0A=
+			 * interrupts for now. =0A=
+			 * TODO =0A=
+			 */=0A=
 			writeq(DISABLE_ALL_INTRS, &bar0->pic_int_mask);=0A=
-			/*  No MSI Support is available presently, so TTI and=0A=
+			/* =0A=
+			 * No MSI Support is available presently, so TTI and=0A=
 			 * RTI interrupts are also disabled.=0A=
 			 */=0A=
 		} else if (flag =3D=3D DISABLE_INTRS) {=0A=
-			/*  Disable PIC Intrs in the general intr mask register =0A=
+			/*  =0A=
+			 * Disable PIC Intrs in the general =0A=
+			 * intr mask register =0A=
 			 */=0A=
 			writeq(DISABLE_ALL_INTRS, &bar0->pic_int_mask);=0A=
 			temp64 =3D readq(&bar0->general_int_mask);=0A=
@@ -907,24 +1162,34 @@=0A=
 	/*  DMA Interrupts */=0A=
 	/*  Enabling/Disabling Tx DMA interrupts */=0A=
 	if (mask & TX_DMA_INTR) {=0A=
-		/*  Enable TxDMA Intrs in the general intr mask register */=0A=
+		/* Enable TxDMA Intrs in the general intr mask register */=0A=
 		val64 =3D TXDMA_INT_M;=0A=
 		if (flag =3D=3D ENABLE_INTRS) {=0A=
 			temp64 =3D readq(&bar0->general_int_mask);=0A=
 			temp64 &=3D ~((u64) val64);=0A=
 			writeq(temp64, &bar0->general_int_mask);=0A=
-			/* Disable all interrupts other than PFC interrupt in =0A=
-			 * DMA level.=0A=
+			/* =0A=
+			 * Keep all interrupts other than PFC interrupt =0A=
+			 * and PCC interrupt disabled in DMA level.=0A=
 			 */=0A=
-			val64 =3D DISABLE_ALL_INTRS & (~TXDMA_PFC_INT_M);=0A=
+			val64 =3D DISABLE_ALL_INTRS & ~(TXDMA_PFC_INT_M |=0A=
+						      TXDMA_PCC_INT_M);=0A=
 			writeq(val64, &bar0->txdma_int_mask);=0A=
-			/* Enable only the MISC error 1 interrupt in PFC block =0A=
+			/* =0A=
+			 * Enable only the MISC error 1 interrupt in PFC block =0A=
 			 */=0A=
 			val64 =3D DISABLE_ALL_INTRS & (~PFC_MISC_ERR_1);=0A=
 			writeq(val64, &bar0->pfc_err_mask);=0A=
+			/* =0A=
+			 * Enable only the FB_ECC error interrupt in PCC block =0A=
+			 */=0A=
+			val64 =3D DISABLE_ALL_INTRS & (~PCC_FB_ECC_ERR);=0A=
+			writeq(val64, &bar0->pcc_err_mask);=0A=
 		} else if (flag =3D=3D DISABLE_INTRS) {=0A=
-			/*  Disable TxDMA Intrs in the general intr mask =0A=
-			 *  register */=0A=
+			/* =0A=
+			 * Disable TxDMA Intrs in the general intr mask =0A=
+			 * register =0A=
+			 */=0A=
 			writeq(DISABLE_ALL_INTRS, &bar0->txdma_int_mask);=0A=
 			writeq(DISABLE_ALL_INTRS, &bar0->pfc_err_mask);=0A=
 			temp64 =3D readq(&bar0->general_int_mask);=0A=
@@ -941,12 +1206,16 @@=0A=
 			temp64 =3D readq(&bar0->general_int_mask);=0A=
 			temp64 &=3D ~((u64) val64);=0A=
 			writeq(temp64, &bar0->general_int_mask);=0A=
-			/* All RxDMA block interrupts are disabled for now =0A=
-			 * TODO */=0A=
+			/* =0A=
+			 * All RxDMA block interrupts are disabled for now =0A=
+			 * TODO =0A=
+			 */=0A=
 			writeq(DISABLE_ALL_INTRS, &bar0->rxdma_int_mask);=0A=
 		} else if (flag =3D=3D DISABLE_INTRS) {=0A=
-			/*  Disable RxDMA Intrs in the general intr mask =0A=
-			 *  register */=0A=
+			/*  =0A=
+			 * Disable RxDMA Intrs in the general intr mask =0A=
+			 * register =0A=
+			 */=0A=
 			writeq(DISABLE_ALL_INTRS, &bar0->rxdma_int_mask);=0A=
 			temp64 =3D readq(&bar0->general_int_mask);=0A=
 			val64 |=3D temp64;=0A=
@@ -962,9 +1231,11 @@=0A=
 			temp64 =3D readq(&bar0->general_int_mask);=0A=
 			temp64 &=3D ~((u64) val64);=0A=
 			writeq(temp64, &bar0->general_int_mask);=0A=
-			/* All MAC block error interrupts are disabled for now =0A=
+			/* =0A=
+			 * All MAC block error interrupts are disabled for now =0A=
 			 * except the link status change interrupt.=0A=
-			 * TODO*/=0A=
+			 * TODO=0A=
+			 */=0A=
 			val64 =3D MAC_INT_STATUS_RMAC_INT;=0A=
 			temp64 =3D readq(&bar0->mac_int_mask);=0A=
 			temp64 &=3D ~((u64) val64);=0A=
@@ -974,7 +1245,8 @@=0A=
 			val64 &=3D ~((u64) RMAC_LINK_STATE_CHANGE_INT);=0A=
 			writeq(val64, &bar0->mac_rmac_err_mask);=0A=
 		} else if (flag =3D=3D DISABLE_INTRS) {=0A=
-			/*  Disable MAC Intrs in the general intr mask register =0A=
+			/*  =0A=
+			 * Disable MAC Intrs in the general intr mask register =0A=
 			 */=0A=
 			writeq(DISABLE_ALL_INTRS, &bar0->mac_int_mask);=0A=
 			writeq(DISABLE_ALL_INTRS,=0A=
@@ -993,11 +1265,14 @@=0A=
 			temp64 =3D readq(&bar0->general_int_mask);=0A=
 			temp64 &=3D ~((u64) val64);=0A=
 			writeq(temp64, &bar0->general_int_mask);=0A=
-			/* All XGXS block error interrupts are disabled for now=0A=
-			 *  TODO */=0A=
+			/* =0A=
+			 * All XGXS block error interrupts are disabled for now=0A=
+			 * TODO =0A=
+			 */=0A=
 			writeq(DISABLE_ALL_INTRS, &bar0->xgxs_int_mask);=0A=
 		} else if (flag =3D=3D DISABLE_INTRS) {=0A=
-			/*  Disable MC Intrs in the general intr mask register =0A=
+			/*  =0A=
+			 * Disable MC Intrs in the general intr mask register =0A=
 			 */=0A=
 			writeq(DISABLE_ALL_INTRS, &bar0->xgxs_int_mask);=0A=
 			temp64 =3D readq(&bar0->general_int_mask);=0A=
@@ -1013,11 +1288,14 @@=0A=
 			temp64 =3D readq(&bar0->general_int_mask);=0A=
 			temp64 &=3D ~((u64) val64);=0A=
 			writeq(temp64, &bar0->general_int_mask);=0A=
-			/* All MC block error interrupts are disabled for now=0A=
-			 * TODO */=0A=
+			/* =0A=
+			 * All MC block error interrupts are disabled for now=0A=
+			 * TODO =0A=
+			 */=0A=
 			writeq(DISABLE_ALL_INTRS, &bar0->mc_int_mask);=0A=
 		} else if (flag =3D=3D DISABLE_INTRS) {=0A=
-			/*  Disable MC Intrs in the general intr mask register=0A=
+			/*=0A=
+			 * Disable MC Intrs in the general intr mask register=0A=
 			 */=0A=
 			writeq(DISABLE_ALL_INTRS, &bar0->mc_int_mask);=0A=
 			temp64 =3D readq(&bar0->general_int_mask);=0A=
@@ -1034,15 +1312,15 @@=0A=
 			temp64 =3D readq(&bar0->general_int_mask);=0A=
 			temp64 &=3D ~((u64) val64);=0A=
 			writeq(temp64, &bar0->general_int_mask);=0A=
-			/* Enable all the Tx side interrupts */=0A=
-			writeq(0x0, &bar0->tx_traffic_mask);	/* '0' Enables =0A=
-								 * all 64 TX =0A=
-								 * interrupt =0A=
-								 * levels.=0A=
-								 */=0A=
+			/* =0A=
+			 * Enable all the Tx side interrupts=0A=
+			 * writing 0 Enables all 64 TX interrupt levels =0A=
+			 */=0A=
+			writeq(0x0, &bar0->tx_traffic_mask);=0A=
 		} else if (flag =3D=3D DISABLE_INTRS) {=0A=
-			/*  Disable Tx Traffic Intrs in the general intr mask =0A=
-			 *  register.=0A=
+			/* =0A=
+			 * Disable Tx Traffic Intrs in the general intr mask =0A=
+			 * register.=0A=
 			 */=0A=
 			writeq(DISABLE_ALL_INTRS, &bar0->tx_traffic_mask);=0A=
 			temp64 =3D readq(&bar0->general_int_mask);=0A=
@@ -1058,14 +1336,12 @@=0A=
 			temp64 =3D readq(&bar0->general_int_mask);=0A=
 			temp64 &=3D ~((u64) val64);=0A=
 			writeq(temp64, &bar0->general_int_mask);=0A=
-			writeq(0x0, &bar0->rx_traffic_mask);	/* '0' Enables =0A=
-								 * all 8 RX =0A=
-								 * interrupt =0A=
-								 * levels.=0A=
-								 */=0A=
+			/* writing 0 Enables all 8 RX interrupt levels */=0A=
+			writeq(0x0, &bar0->rx_traffic_mask);=0A=
 		} else if (flag =3D=3D DISABLE_INTRS) {=0A=
-			/*  Disable Rx Traffic Intrs in the general intr mask =0A=
-			 *  register.=0A=
+			/*  =0A=
+			 * Disable Rx Traffic Intrs in the general intr mask =0A=
+			 * register.=0A=
 			 */=0A=
 			writeq(DISABLE_ALL_INTRS, &bar0->rx_traffic_mask);=0A=
 			temp64 =3D readq(&bar0->general_int_mask);=0A=
@@ -1075,17 +1351,19 @@=0A=
 	}=0A=
 }=0A=
 =0A=
-/*  =0A=
- *  Input Arguments: =0A=
- *   val64 - Value read from adapter status register.=0A=
- *   flag - indicates if the adapter enable bit was ever written once =
before.=0A=
- *  Return Value: =0A=
- *   void.=0A=
- *  Description: =0A=
- *   Returns whether the H/W is ready to go or not. Depending on =
whether =0A=
- *   adapter enable bit was written or not the comparison differs and =
the =0A=
- *   calling function passes the input argument flag to indicate this.=0A=
+/**  =0A=
+ *  verify_xena_quiescence - Checks whether the H/W is ready =0A=
+ *  @val64 :  Value read from adapter status register.=0A=
+ *  @flag : indicates if the adapter enable bit was ever written once=0A=
+ *  before.=0A=
+ *  Description: Returns whether the H/W is ready to go or not. =
Depending=0A=
+ *  on whether adapter enable bit was written or not the comparison =0A=
+ *  differs and the calling function passes the input argument flag to=0A=
+ *  indicate this.=0A=
+ *  Return: 1 If xena is quiescence =0A=
+ *          0 If Xena is not quiescence=0A=
  */=0A=
+=0A=
 static int verify_xena_quiescence(u64 val64, int flag)=0A=
 {=0A=
 	int ret =3D 0;=0A=
@@ -1122,11 +1400,15 @@=0A=
 	return ret;=0A=
 }=0A=
 =0A=
-/* =0A=
+/**=0A=
+ * fix_mac_address -  Fix for Mac addr problem on Alpha platforms=0A=
+ * @sp: Pointer to device specifc structure=0A=
+ * Description : =0A=
  * New procedure to clear mac address reading  problems on Alpha =
platforms=0A=
  *=0A=
  */=0A=
-void FixMacAddress(nic_t * sp)=0A=
+=0A=
+void fix_mac_address(nic_t * sp)=0A=
 {=0A=
 	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) sp->bar0;=0A=
 	u64 val64;=0A=
@@ -1138,19 +1420,20 @@=0A=
 	}=0A=
 }=0A=
 =0A=
-/*  =0A=
- *  Input Arguments: =0A=
- *  device private variable.=0A=
- *  Return Value: =0A=
- *  SUCCESS on success and -1 on failure.=0A=
+/**=0A=
+ *  start_nic - Turns the device on   =0A=
+ *  @nic : device private variable.=0A=
  *  Description: =0A=
- *  This function actually turns the device on. Before this =0A=
- *  function is called, all Registers are configured from their reset =
states =0A=
+ *  This function actually turns the device on. Before this  function =
is =0A=
+ *  called,all Registers are configured from their reset states =0A=
  *  and shared memory is allocated but the NIC is still quiescent. On =0A=
  *  calling this function, the device interrupts are cleared and the =
NIC is=0A=
  *  literally switched on by writing into the adapter control register.=0A=
+ *  Return Value: =0A=
+ *  SUCCESS on success and -1 on failure.=0A=
  */=0A=
-static int startNic(struct s2io_nic *nic)=0A=
+=0A=
+static int start_nic(struct s2io_nic *nic)=0A=
 {=0A=
 	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) nic->bar0;=0A=
 	struct net_device *dev =3D nic->dev;=0A=
@@ -1169,17 +1452,29 @@=0A=
 		       &bar0->prc_rxd0_n[i]);=0A=
 =0A=
 		val64 =3D readq(&bar0->prc_ctrl_n[i]);=0A=
+#ifndef CONFIG_2BUFF_MODE=0A=
 		val64 |=3D PRC_CTRL_RC_ENABLED;=0A=
+#else=0A=
+		val64 |=3D PRC_CTRL_RC_ENABLED | PRC_CTRL_RING_MODE_3;=0A=
+#endif=0A=
 		writeq(val64, &bar0->prc_ctrl_n[i]);=0A=
 	}=0A=
 =0A=
-	/* Enabling MC-RLDRAM. After enabling the device, we timeout=0A=
+#ifdef CONFIG_2BUFF_MODE=0A=
+	/* Enabling 2 buffer mode by writing into Rx_pa_cfg reg. */=0A=
+	val64 =3D readq(&bar0->rx_pa_cfg);=0A=
+	val64 |=3D RX_PA_CFG_IGNORE_L2_ERR;=0A=
+	writeq(val64, &bar0->rx_pa_cfg);=0A=
+#endif=0A=
+=0A=
+	/* =0A=
+	 * Enabling MC-RLDRAM. After enabling the device, we timeout=0A=
 	 * for around 100ms, which is approximately the time required=0A=
 	 * for the device to be ready for operation.=0A=
 	 */=0A=
 	val64 =3D readq(&bar0->mc_rldram_mrs);=0A=
 	val64 |=3D MC_RLDRAM_QUEUE_SIZE_ENABLE | MC_RLDRAM_MRS_ENABLE;=0A=
-	writeq(val64, &bar0->mc_rldram_mrs);=0A=
+	SPECIAL_REG_WRITE(val64, &bar0->mc_rldram_mrs, UF);=0A=
 	val64 =3D readq(&bar0->mc_rldram_mrs);=0A=
 =0A=
 	set_current_state(TASK_UNINTERRUPTIBLE);=0A=
@@ -1190,14 +1485,16 @@=0A=
 	val64 &=3D ~ADAPTER_ECC_EN;=0A=
 	writeq(val64, &bar0->adapter_control);=0A=
 =0A=
-	/* Clearing any possible Link state change interrupts that =0A=
+	/* =0A=
+	 * Clearing any possible Link state change interrupts that =0A=
 	 * could have popped up just before Enabling the card.=0A=
 	 */=0A=
 	val64 =3D readq(&bar0->mac_rmac_err_reg);=0A=
 	if (val64)=0A=
 		writeq(val64, &bar0->mac_rmac_err_reg);=0A=
 =0A=
-	/* Verify if the device is ready to be enabled, if so enable =0A=
+	/* =0A=
+	 * Verify if the device is ready to be enabled, if so enable =0A=
 	 * it.=0A=
 	 */=0A=
 	val64 =3D readq(&bar0->adapter_status);=0A=
@@ -1211,9 +1508,10 @@=0A=
 	/*  Enable select interrupts */=0A=
 	interruptible =3D TX_TRAFFIC_INTR | RX_TRAFFIC_INTR | TX_MAC_INTR |=0A=
 	    RX_MAC_INTR;=0A=
-	en_dis_able_NicIntrs(nic, interruptible, ENABLE_INTRS);=0A=
+	en_dis_able_nic_intrs(nic, interruptible, ENABLE_INTRS);=0A=
 =0A=
-	/* With some switches, link might be already up at this point.=0A=
+	/* =0A=
+	 * With some switches, link might be already up at this point.=0A=
 	 * Because of this weird behavior, when we enable laser, =0A=
 	 * we may not get link. We need to handle this. We cannot =0A=
 	 * figure out which switch is misbehaving. So we are forced to =0A=
@@ -1240,82 +1538,74 @@=0A=
 	 * force link down. Since link is already up, we will get=0A=
 	 * link state change interrupt after this reset=0A=
 	 */=0A=
-	writeq(0x8007051500000000ULL, &bar0->dtx_control);=0A=
+	SPECIAL_REG_WRITE(0x80010515001E0000ULL, &bar0->dtx_control, UF);=0A=
 	val64 =3D readq(&bar0->dtx_control);=0A=
-	writeq(0x80070515000000E0ULL, &bar0->dtx_control);=0A=
+	udelay(50);=0A=
+	SPECIAL_REG_WRITE(0x80010515001E00E0ULL, &bar0->dtx_control, UF);=0A=
 	val64 =3D readq(&bar0->dtx_control);=0A=
-	writeq(0x80070515001F00E4ULL, &bar0->dtx_control);=0A=
+	udelay(50);=0A=
+	SPECIAL_REG_WRITE(0x80070515001F00E4ULL, &bar0->dtx_control, UF);=0A=
 	val64 =3D readq(&bar0->dtx_control);=0A=
+	udelay(50);=0A=
 =0A=
 	return SUCCESS;=0A=
 }=0A=
 =0A=
-/*  =0A=
- *  Input Arguments: =0A=
- *   nic - device private variable.=0A=
- *  Return Value: =0A=
- *   void.=0A=
+/** =0A=
+ *  free_tx_buffers - Free all queued Tx buffers =0A=
+ *  @nic : device private variable.=0A=
  *  Description: =0A=
- *   Free all queued Tx buffers.=0A=
- */=0A=
-void freeTxBuffers(struct s2io_nic *nic)=0A=
+ *  Free all queued Tx buffers.=0A=
+ *  Return Value: void =0A=
+*/=0A=
+=0A=
+void free_tx_buffers(struct s2io_nic *nic)=0A=
 {=0A=
 	struct net_device *dev =3D nic->dev;=0A=
 	struct sk_buff *skb;=0A=
 	TxD_t *txdp;=0A=
 	int i, j;=0A=
-#if DEBUG_ON=0A=
-	int cnt =3D 0;=0A=
-#endif=0A=
 	mac_info_t *mac_control;=0A=
 	struct config_param *config;=0A=
+	int cnt =3D 0;=0A=
 =0A=
 	mac_control =3D &nic->mac_control;=0A=
 	config =3D &nic->config;=0A=
 =0A=
 	for (i =3D 0; i < config->TxFIFONum; i++) {=0A=
-		for (j =3D 0; j < config->TxCfg[i].FifoLen - 1; j++) {=0A=
-			txdp =3D mac_control->txdl_start[i] +=0A=
-			    (config->MaxTxDs * j);=0A=
-=0A=
-			if (!(txdp->Control_1 & TXD_LIST_OWN_XENA)) {=0A=
-				/* If owned by host, ignore */=0A=
-				continue;=0A=
-			}=0A=
+		for (j =3D 0; j < config->tx_cfg[i].FifoLen - 1; j++) {=0A=
+			txdp =3D (TxD_t *) nic->list_info[i][j].=0A=
+			    list_virt_addr;=0A=
 			skb =3D=0A=
 			    (struct sk_buff *) ((unsigned long) txdp->=0A=
 						Host_Control);=0A=
 			if (skb =3D=3D NULL) {=0A=
-				DBG_PRINT(ERR_DBG, "%s: NULL skb ",=0A=
-					  dev->name);=0A=
-				DBG_PRINT(ERR_DBG, "in Tx Int\n");=0A=
-				return;=0A=
+				memset(txdp, 0, sizeof(TxD_t));=0A=
+				continue;=0A=
 			}=0A=
-#if DEBUG_ON=0A=
-			cnt++;=0A=
-#endif=0A=
 			dev_kfree_skb(skb);=0A=
 			memset(txdp, 0, sizeof(TxD_t));=0A=
+			cnt++;=0A=
 		}=0A=
-#if DEBUG_ON=0A=
 		DBG_PRINT(INTR_DBG,=0A=
 			  "%s:forcibly freeing %d skbs on FIFO%d\n",=0A=
 			  dev->name, cnt, i);=0A=
-#endif=0A=
+		mac_control->tx_curr_get_info[i].offset =3D 0;=0A=
+		mac_control->tx_curr_put_info[i].offset =3D 0;=0A=
 	}=0A=
 }=0A=
 =0A=
-/*  =0A=
- *  Input Arguments: =0A=
- *   nic - device private variable.=0A=
- *  Return Value: =0A=
+/**  =0A=
+ *   stop_nic -  To stop the nic  =0A=
+ *   @nic ; device private variable.=0A=
+ *   Description: =0A=
+ *   This function does exactly the opposite of what the start_nic() =0A=
+ *   function does. This function is called to stop the device.=0A=
+ *   Return Value:=0A=
  *   void.=0A=
- *  Description: =0A=
- *   This function does exactly the opposite of what the startNic() =0A=
- *   function does. This function is called to stop =0A=
- *   the device.=0A=
  */=0A=
-static void stopNic(struct s2io_nic *nic)=0A=
+=0A=
+static void stop_nic(struct s2io_nic *nic)=0A=
 {=0A=
 	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) nic->bar0;=0A=
 	register u64 val64 =3D 0;=0A=
@@ -1326,12 +1616,12 @@=0A=
 	mac_control =3D &nic->mac_control;=0A=
 	config =3D &nic->config;=0A=
 =0A=
-/*  Disable all interrupts */=0A=
+	/*  Disable all interrupts */=0A=
 	interruptible =3D TX_TRAFFIC_INTR | RX_TRAFFIC_INTR | TX_MAC_INTR |=0A=
 	    RX_MAC_INTR;=0A=
-	en_dis_able_NicIntrs(nic, interruptible, DISABLE_INTRS);=0A=
+	en_dis_able_nic_intrs(nic, interruptible, DISABLE_INTRS);=0A=
 =0A=
-/*  Disable PRCs */=0A=
+	/*  Disable PRCs */=0A=
 	for (i =3D 0; i < config->RxRingNum; i++) {=0A=
 		val64 =3D readq(&bar0->prc_ctrl_n[i]);=0A=
 		val64 &=3D ~((u64) PRC_CTRL_RC_ENABLED);=0A=
@@ -1339,11 +1629,10 @@=0A=
 	}=0A=
 }=0A=
 =0A=
-/*  =0A=
- *  Input Arguments: =0A=
- *  device private variable=0A=
- *  Return Value: =0A=
- *  SUCCESS on success or an appropriate -ve value on failure.=0A=
+/**  =0A=
+ *  fill_rx_buffers - Allocates the Rx side skbs =0A=
+ *  @nic:  device private variable=0A=
+ *  @ring_no: ring number =0A=
  *  Description: =0A=
  *  The function allocates Rx side skbs and puts the physical=0A=
  *  address of these buffers into the RxD buffer pointers, so that the =
NIC=0A=
@@ -1354,9 +1643,13 @@=0A=
  *  3. Five buffer modes.=0A=
  *  Each mode defines how many fragments the received frame will be =
split =0A=
  *  up into by the NIC. The frame is split into L3 header, L4 Header, =0A=
- *  L4 payload in three buffer mode and in 5 buffer mode, L4 payload =
itself =0A=
- *  is split into 3 fragments. As of now only single buffer mode is =
supported.=0A=
+ *  L4 payload in three buffer mode and in 5 buffer mode, L4 payload =
itself=0A=
+ *  is split into 3 fragments. As of now only single buffer mode is=0A=
+ *  supported.=0A=
+ *   Return Value:=0A=
+ *  SUCCESS on success or an appropriate -ve value on failure.=0A=
  */=0A=
+=0A=
 int fill_rx_buffers(struct s2io_nic *nic, int ring_no)=0A=
 {=0A=
 	struct net_device *dev =3D nic->dev;=0A=
@@ -1369,6 +1662,16 @@=0A=
 	    atomic_read(&nic->rx_bufs_left[ring_no]);=0A=
 	mac_info_t *mac_control;=0A=
 	struct config_param *config;=0A=
+#ifdef CONFIG_2BUFF_MODE=0A=
+	RxD_t *rxdpnext;=0A=
+	int nextblk;=0A=
+	u64 tmp;=0A=
+	buffAdd_t *ba;=0A=
+	dma_addr_t rxdpphys;=0A=
+#endif=0A=
+#ifndef CONFIG_S2IO_NAPI=0A=
+	unsigned long flags;=0A=
+#endif=0A=
 =0A=
 	mac_control =3D &nic->mac_control;=0A=
 	config =3D &nic->config;=0A=
@@ -1390,8 +1693,13 @@=0A=
 		    block_index;=0A=
 		off =3D mac_control->rx_curr_put_info[ring_no].offset;=0A=
 		off1 =3D mac_control->rx_curr_get_info[ring_no].offset;=0A=
+#ifndef CONFIG_2BUFF_MODE=0A=
 		offset =3D block_no * (MAX_RXDS_PER_BLOCK + 1) + off;=0A=
 		offset1 =3D block_no1 * (MAX_RXDS_PER_BLOCK + 1) + off1;=0A=
+#else=0A=
+		offset =3D block_no * (MAX_RXDS_PER_BLOCK) + off;=0A=
+		offset1 =3D block_no1 * (MAX_RXDS_PER_BLOCK) + off1;=0A=
+#endif=0A=
 =0A=
 		rxdp =3D nic->rx_blocks[ring_no][block_no].=0A=
 		    block_virt_addr + off;=0A=
@@ -1400,7 +1708,7 @@=0A=
 			DBG_PRINT(INTR_DBG, " info equated\n");=0A=
 			goto end;=0A=
 		}=0A=
-=0A=
+#ifndef	CONFIG_2BUFF_MODE=0A=
 		if (rxdp->Control_1 =3D=3D END_OF_BLOCK) {=0A=
 			mac_control->rx_curr_put_info[ring_no].=0A=
 			    block_index++;=0A=
@@ -1412,25 +1720,85 @@=0A=
 			off %=3D (MAX_RXDS_PER_BLOCK + 1);=0A=
 			mac_control->rx_curr_put_info[ring_no].offset =3D=0A=
 			    off;=0A=
-			/*rxdp =3D nic->rx_blocks[ring_no][block_no].=0A=
-			   block_virt_addr + off; */=0A=
 			rxdp =3D (RxD_t *) ((unsigned long) rxdp->Control_2);=0A=
 			DBG_PRINT(INTR_DBG, "%s: Next block at: %p\n",=0A=
 				  dev->name, rxdp);=0A=
 		}=0A=
+#ifndef CONFIG_S2IO_NAPI=0A=
+		spin_lock_irqsave(&nic->put_lock, flags);=0A=
+		nic->put_pos =3D (block_no * (MAX_RXDS_PER_BLOCK + 1)) + off;=0A=
+		spin_unlock_irqrestore(&nic->put_lock, flags);=0A=
+#endif=0A=
+#else=0A=
+		if (rxdp->Host_Control =3D=3D END_OF_BLOCK) {=0A=
+			mac_control->rx_curr_put_info[ring_no].=0A=
+			    block_index++;=0A=
+			mac_control->rx_curr_put_info[ring_no].=0A=
+			    block_index %=3D nic->block_count[ring_no];=0A=
+			block_no =3D mac_control->rx_curr_put_info=0A=
+			    [ring_no].block_index;=0A=
+			off =3D 0;=0A=
+			DBG_PRINT(INTR_DBG, "%s: block%d at: 0x%llx\n",=0A=
+				  dev->name, block_no,=0A=
+				  (unsigned long long) rxdp->Control_1);=0A=
+			mac_control->rx_curr_put_info[ring_no].offset =3D=0A=
+			    off;=0A=
+			rxdp =3D nic->rx_blocks[ring_no][block_no].=0A=
+			    block_virt_addr;=0A=
+		}=0A=
+#ifndef CONFIG_S2IO_NAPI=0A=
+		spin_lock_irqsave(&nic->put_lock, flags);=0A=
+		nic->put_pos =3D (block_no * (MAX_RXDS_PER_BLOCK + 1)) + off;=0A=
+		spin_unlock_irqrestore(&nic->put_lock, flags);=0A=
+#endif=0A=
+#endif=0A=
 =0A=
-		if (rxdp->Control_1 & RXD_OWN_XENA) {=0A=
+#ifndef	CONFIG_2BUFF_MODE=0A=
+		if (rxdp->Control_1 & RXD_OWN_XENA)=0A=
+#else=0A=
+		if (rxdp->Control_2 & BIT(0))=0A=
+#endif=0A=
+		{=0A=
 			mac_control->rx_curr_put_info[ring_no].=0A=
 			    offset =3D off;=0A=
 			goto end;=0A=
 		}=0A=
+#ifdef	CONFIG_2BUFF_MODE=0A=
+		/* =0A=
+		 * RxDs Spanning cache lines will be replenished only =0A=
+		 * if the succeeding RxD is also owned by Host. It =0A=
+		 * will always be the ((8*i)+3) and ((8*i)+6) =0A=
+		 * descriptors for the 48 byte descriptor. The offending =0A=
+		 * decsriptor is of-course the 3rd descriptor.=0A=
+		 */=0A=
+		rxdpphys =3D nic->rx_blocks[ring_no][block_no].=0A=
+		    block_dma_addr + (off * sizeof(RxD_t));=0A=
+		if (((u64) (rxdpphys)) % 128 > 80) {=0A=
+			rxdpnext =3D nic->rx_blocks[ring_no][block_no].=0A=
+			    block_virt_addr + (off + 1);=0A=
+			if (rxdpnext->Host_Control =3D=3D END_OF_BLOCK) {=0A=
+				nextblk =3D (block_no + 1) %=0A=
+				    (nic->block_count[ring_no]);=0A=
+				rxdpnext =3D nic->rx_blocks[ring_no]=0A=
+				    [nextblk].block_virt_addr;=0A=
+			}=0A=
+			if (rxdpnext->Control_2 & BIT(0))=0A=
+				goto end;=0A=
+		}=0A=
+#endif=0A=
 =0A=
+#ifndef	CONFIG_2BUFF_MODE=0A=
 		skb =3D dev_alloc_skb(size + HEADER_ALIGN_LAYER_3);=0A=
+#else=0A=
+		skb =3D dev_alloc_skb(dev->mtu + ALIGN_SIZE +=0A=
+				    /*BUF0_LEN + */ 22);=0A=
+#endif=0A=
 		if (!skb) {=0A=
 			DBG_PRINT(ERR_DBG, "%s: Out of ", dev->name);=0A=
 			DBG_PRINT(ERR_DBG, "memory to allocate SKBs\n");=0A=
 			return -ENOMEM;=0A=
 		}=0A=
+#ifndef	CONFIG_2BUFF_MODE=0A=
 		skb_reserve(skb, HEADER_ALIGN_LAYER_3);=0A=
 		memset(rxdp, 0, sizeof(RxD_t));=0A=
 		rxdp->Buffer0_ptr =3D pci_map_single=0A=
@@ -1442,6 +1810,33 @@=0A=
 		off++;=0A=
 		off %=3D (MAX_RXDS_PER_BLOCK + 1);=0A=
 		mac_control->rx_curr_put_info[ring_no].offset =3D off;=0A=
+#else=0A=
+		ba =3D &nic->ba[ring_no][block_no][off];=0A=
+		tmp =3D (u64) skb->data;=0A=
+		tmp +=3D ALIGN_SIZE;=0A=
+		tmp &=3D ~ALIGN_SIZE;=0A=
+		skb->data =3D (void *) tmp;=0A=
+=0A=
+		memset(rxdp, 0, sizeof(RxD_t));=0A=
+		rxdp->Buffer2_ptr =3D pci_map_single=0A=
+		    (nic->pdev, skb->data, dev->mtu + 22,=0A=
+		     PCI_DMA_FROMDEVICE);=0A=
+		rxdp->Buffer0_ptr =3D=0A=
+		    pci_map_single(nic->pdev, ba->ba_0, BUF0_LEN,=0A=
+				   PCI_DMA_FROMDEVICE);=0A=
+		rxdp->Buffer1_ptr =3D=0A=
+		    pci_map_single(nic->pdev, ba->ba_1, BUF1_LEN,=0A=
+				   PCI_DMA_FROMDEVICE);=0A=
+=0A=
+		rxdp->Control_2 =3D SET_BUFFER2_SIZE(dev->mtu + 22);=0A=
+		rxdp->Control_2 |=3D SET_BUFFER0_SIZE(BUF0_LEN);=0A=
+		rxdp->Control_2 |=3D SET_BUFFER1_SIZE(1);	/* dummy. */=0A=
+		rxdp->Control_2 |=3D BIT(0);	/* Set Buffer_Empty bit. */=0A=
+		rxdp->Host_Control =3D (u64) ((unsigned long) (skb));=0A=
+		rxdp->Control_1 |=3D RXD_OWN_XENA;=0A=
+		off++;=0A=
+		mac_control->rx_curr_put_info[ring_no].offset =3D off;=0A=
+#endif=0A=
 		atomic_inc(&nic->rx_bufs_left[ring_no]);=0A=
 		alloc_tab++;=0A=
 	}=0A=
@@ -1450,15 +1845,16 @@=0A=
 	return SUCCESS;=0A=
 }=0A=
 =0A=
-/*  =0A=
- *  Input Arguments: =0A=
- *  device private variable.=0A=
- *  Return Value: =0A=
- *  NONE.=0A=
+/**=0A=
+ *  free_rx_buffers - Frees all Rx buffers   =0A=
+ *  @sp: device private variable.=0A=
  *  Description: =0A=
  *  This function will free all Rx buffers allocated by host.=0A=
+ *  Return Value:=0A=
+ *  NONE.=0A=
  */=0A=
-static void freeRxBuffers(struct s2io_nic *sp)=0A=
+=0A=
+static void free_rx_buffers(struct s2io_nic *sp)=0A=
 {=0A=
 	struct net_device *dev =3D sp->dev;=0A=
 	int i, j, blk =3D 0, off, buf_cnt =3D 0;=0A=
@@ -1466,15 +1862,19 @@=0A=
 	struct sk_buff *skb;=0A=
 	mac_info_t *mac_control;=0A=
 	struct config_param *config;=0A=
+#ifdef CONFIG_2BUFF_MODE=0A=
+	buffAdd_t *ba;=0A=
+#endif=0A=
 =0A=
 	mac_control =3D &sp->mac_control;=0A=
 	config =3D &sp->config;=0A=
 =0A=
 	for (i =3D 0; i < config->RxRingNum; i++) {=0A=
-		for (j =3D 0, blk =3D 0; j < config->RxCfg[i].NumRxd; j++) {=0A=
+		for (j =3D 0, blk =3D 0; j < config->rx_cfg[i].NumRxd; j++) {=0A=
 			off =3D j % (MAX_RXDS_PER_BLOCK + 1);=0A=
 			rxdp =3D sp->rx_blocks[i][blk].block_virt_addr + off;=0A=
 =0A=
+#ifndef CONFIG_2BUFF_MODE=0A=
 			if (rxdp->Control_1 =3D=3D END_OF_BLOCK) {=0A=
 				rxdp =3D=0A=
 				    (RxD_t *) ((unsigned long) rxdp->=0A=
@@ -1482,11 +1882,23 @@=0A=
 				j++;=0A=
 				blk++;=0A=
 			}=0A=
+#else=0A=
+			if (rxdp->Host_Control =3D=3D END_OF_BLOCK) {=0A=
+				blk++;=0A=
+				continue;=0A=
+			}=0A=
+#endif=0A=
+=0A=
+			if (!(rxdp->Control_1 & RXD_OWN_XENA)) {=0A=
+				memset(rxdp, 0, sizeof(RxD_t));=0A=
+				continue;=0A=
+			}=0A=
 =0A=
 			skb =3D=0A=
 			    (struct sk_buff *) ((unsigned long) rxdp->=0A=
 						Host_Control);=0A=
 			if (skb) {=0A=
+#ifndef CONFIG_2BUFF_MODE=0A=
 				pci_unmap_single(sp->pdev, (dma_addr_t)=0A=
 						 rxdp->Buffer0_ptr,=0A=
 						 dev->mtu +=0A=
@@ -1494,6 +1906,21 @@=0A=
 						 + HEADER_802_2_SIZE +=0A=
 						 HEADER_SNAP_SIZE,=0A=
 						 PCI_DMA_FROMDEVICE);=0A=
+#else=0A=
+				ba =3D &sp->ba[i][blk][off];=0A=
+				pci_unmap_single(sp->pdev, (dma_addr_t)=0A=
+						 rxdp->Buffer0_ptr,=0A=
+						 BUF0_LEN,=0A=
+						 PCI_DMA_FROMDEVICE);=0A=
+				pci_unmap_single(sp->pdev, (dma_addr_t)=0A=
+						 rxdp->Buffer1_ptr,=0A=
+						 BUF1_LEN,=0A=
+						 PCI_DMA_FROMDEVICE);=0A=
+				pci_unmap_single(sp->pdev, (dma_addr_t)=0A=
+						 rxdp->Buffer2_ptr,=0A=
+						 dev->mtu + 22,=0A=
+						 PCI_DMA_FROMDEVICE);=0A=
+#endif=0A=
 				dev_kfree_skb(skb);=0A=
 				atomic_dec(&sp->rx_bufs_left[i]);=0A=
 				buf_cnt++;=0A=
@@ -1510,18 +1937,19 @@=0A=
 	}=0A=
 }=0A=
 =0A=
-/*=0A=
- *  Input Argument: =0A=
- *   dev - pointer to the device structure.=0A=
- *   budget - The number of packets that were budgeted to be processed =
during=0A=
- *   one pass through the 'Poll" function.=0A=
- *  Return value:=0A=
- *   0 on success and 1 if there are No Rx packets to be processed.=0A=
- *  Description:=0A=
- *   Comes into picture only if NAPI support has been incorporated. It =
does=0A=
- *   the same thing that rxIntrHandler does, but not in a interrupt =
context=0A=
- *   also It will process only a given number of packets.=0A=
+/**=0A=
+ * s2io_poll - Rx interrupt handler for NAPI support=0A=
+ * @dev : pointer to the device structure.=0A=
+ * @budget : The number of packets that were budgeted to be processed =0A=
+ * during  one pass through the 'Poll" function.=0A=
+ * Description:=0A=
+ * Comes into picture only if NAPI support has been incorporated. It =
does=0A=
+ * the same thing that rx_intr_handler does, but not in a interrupt =
context=0A=
+ * also It will process only a given number of packets.=0A=
+ * Return value:=0A=
+ * 0 on success and 1 if there are No Rx packets to be processed.=0A=
  */=0A=
+=0A=
 #ifdef CONFIG_S2IO_NAPI=0A=
 static int s2io_poll(struct net_device *dev, int *budget)=0A=
 {=0A=
@@ -1529,13 +1957,18 @@=0A=
 	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) nic->bar0;=0A=
 	int pkts_to_process =3D *budget, pkt_cnt =3D 0;=0A=
 	register u64 val64 =3D 0;=0A=
-	rx_curr_get_info_t offset_info;=0A=
-	int i, block_no;=0A=
+	rx_curr_get_info_t get_info, put_info;=0A=
+	int i, get_block, put_block, get_offset, put_offset, ring_bufs;=0A=
+#ifndef CONFIG_2BUFF_MODE=0A=
 	u16 val16, cksum;=0A=
+#endif=0A=
 	struct sk_buff *skb;=0A=
 	RxD_t *rxdp;=0A=
 	mac_info_t *mac_control;=0A=
 	struct config_param *config;=0A=
+#ifdef CONFIG_2BUFF_MODE=0A=
+	buffAdd_t *ba;=0A=
+#endif=0A=
 =0A=
 	mac_control =3D &nic->mac_control;=0A=
 	config =3D &nic->config;=0A=
@@ -1547,29 +1980,47 @@=0A=
 	writeq(val64, &bar0->rx_traffic_int);=0A=
 =0A=
 	for (i =3D 0; i < config->RxRingNum; i++) {=0A=
-		if (--pkts_to_process < 0) {=0A=
-			goto no_rx;=0A=
-		}=0A=
-		offset_info =3D mac_control->rx_curr_get_info[i];=0A=
-		block_no =3D offset_info.block_index;=0A=
-		rxdp =3D nic->rx_blocks[i][block_no].block_virt_addr +=0A=
-		    offset_info.offset;=0A=
-		while (!(rxdp->Control_1 & RXD_OWN_XENA)) {=0A=
+		get_info =3D mac_control->rx_curr_get_info[i];=0A=
+		get_block =3D get_info.block_index;=0A=
+		put_info =3D mac_control->rx_curr_put_info[i];=0A=
+		put_block =3D put_info.block_index;=0A=
+		ring_bufs =3D config->rx_cfg[i].NumRxd;=0A=
+		rxdp =3D nic->rx_blocks[i][get_block].block_virt_addr +=0A=
+		    get_info.offset;=0A=
+#ifndef	CONFIG_2BUFF_MODE=0A=
+		get_offset =3D (get_block * (MAX_RXDS_PER_BLOCK + 1)) +=0A=
+		    get_info.offset;=0A=
+#ifndef CONFIG_S2IO_NAPI=0A=
+		spin_lock(&nic->put_lock);=0A=
+		put_offset =3D nic->put_pos;=0A=
+		spin_unlock(&nic->put_lock);=0A=
+#else=0A=
+		put_offset =3D (put_block * (MAX_RXDS_PER_BLOCK + 1)) +=0A=
+		    put_info.offset;=0A=
+#endif=0A=
+		while ((!(rxdp->Control_1 & RXD_OWN_XENA)) &&=0A=
+		       (((get_offset + 1) % ring_bufs) !=3D put_offset)) {=0A=
+			if (--pkts_to_process < 0) {=0A=
+				goto no_rx;=0A=
+			}=0A=
 			if (rxdp->Control_1 =3D=3D END_OF_BLOCK) {=0A=
 				rxdp =3D=0A=
 				    (RxD_t *) ((unsigned long) rxdp->=0A=
 					       Control_2);=0A=
-				offset_info.offset++;=0A=
-				offset_info.offset %=3D=0A=
+				get_info.offset++;=0A=
+				get_info.offset %=3D=0A=
 				    (MAX_RXDS_PER_BLOCK + 1);=0A=
-				block_no++;=0A=
-				block_no %=3D nic->block_count[i];=0A=
+				get_block++;=0A=
+				get_block %=3D nic->block_count[i];=0A=
 				mac_control->rx_curr_get_info[i].=0A=
-				    offset =3D offset_info.offset;=0A=
+				    offset =3D get_info.offset;=0A=
 				mac_control->rx_curr_get_info[i].=0A=
-				    block_index =3D block_no;=0A=
+				    block_index =3D get_block;=0A=
 				continue;=0A=
 			}=0A=
+			get_offset =3D=0A=
+			    (get_block * (MAX_RXDS_PER_BLOCK + 1)) +=0A=
+			    get_info.offset;=0A=
 			skb =3D=0A=
 			    (struct sk_buff *) ((unsigned long) rxdp->=0A=
 						Host_Control);=0A=
@@ -1577,7 +2028,7 @@=0A=
 				DBG_PRINT(ERR_DBG, "%s: The skb is ",=0A=
 					  dev->name);=0A=
 				DBG_PRINT(ERR_DBG, "Null in Rx Intr\n");=0A=
-				return 0;=0A=
+				goto no_rx;=0A=
 			}=0A=
 			val64 =3D RXD_GET_BUFFER0_SIZE(rxdp->Control_2);=0A=
 			val16 =3D (u16) (val64 >> 48);=0A=
@@ -1589,97 +2040,192 @@=0A=
 					 HEADER_802_2_SIZE +=0A=
 					 HEADER_SNAP_SIZE,=0A=
 					 PCI_DMA_FROMDEVICE);=0A=
-			rxOsmHandler(nic, val16, rxdp, i);=0A=
+			rx_osm_handler(nic, val16, rxdp, i);=0A=
 			pkt_cnt++;=0A=
-			offset_info.offset++;=0A=
-			offset_info.offset %=3D (MAX_RXDS_PER_BLOCK + 1);=0A=
+			get_info.offset++;=0A=
+			get_info.offset %=3D (MAX_RXDS_PER_BLOCK + 1);=0A=
 			rxdp =3D=0A=
-			    nic->rx_blocks[i][block_no].block_virt_addr +=0A=
-			    offset_info.offset;=0A=
+			    nic->rx_blocks[i][get_block].block_virt_addr +=0A=
+			    get_info.offset;=0A=
 			mac_control->rx_curr_get_info[i].offset =3D=0A=
-			    offset_info.offset;=0A=
+			    get_info.offset;=0A=
 		}=0A=
-	}=0A=
-	if (!pkt_cnt)=0A=
-		pkt_cnt =3D 1;=0A=
-=0A=
-	for (i =3D 0; i < config->RxRingNum; i++)=0A=
-		fill_rx_buffers(nic, i);=0A=
+#else=0A=
+		get_offset =3D (get_block * (MAX_RXDS_PER_BLOCK + 1)) +=0A=
+		    get_info.offset;=0A=
+#ifndef CONFIG_S2IO_NAPI=0A=
+		spin_lock(&nic->put_lock);=0A=
+		put_offset =3D nic->put_pos;=0A=
+		spin_unlock(&nic->put_lock);=0A=
+#else=0A=
+		put_offset =3D (put_block * (MAX_RXDS_PER_BLOCK + 1)) +=0A=
+		    put_info.offset;=0A=
+#endif=0A=
+		while (((!(rxdp->Control_1 & RXD_OWN_XENA)) &&=0A=
+			!(rxdp->Control_2 & BIT(0))) &&=0A=
+		       (((get_offset + 1) % ring_bufs) !=3D put_offset)) {=0A=
+			if (--pkts_to_process < 0) {=0A=
+				goto no_rx;=0A=
+			}=0A=
+			skb =3D (struct sk_buff *) ((unsigned long)=0A=
+						  rxdp->Host_Control);=0A=
+			if (skb =3D=3D NULL) {=0A=
+				DBG_PRINT(ERR_DBG, "%s: The skb is ",=0A=
+					  dev->name);=0A=
+				DBG_PRINT(ERR_DBG, "Null in Rx Intr\n");=0A=
+				goto no_rx;=0A=
+			}=0A=
+=0A=
+			pci_unmap_single(nic->pdev, (dma_addr_t)=0A=
+					 rxdp->Buffer0_ptr,=0A=
+					 BUF0_LEN, PCI_DMA_FROMDEVICE);=0A=
+			pci_unmap_single(nic->pdev, (dma_addr_t)=0A=
+					 rxdp->Buffer1_ptr,=0A=
+					 BUF1_LEN, PCI_DMA_FROMDEVICE);=0A=
+			pci_unmap_single(nic->pdev, (dma_addr_t)=0A=
+					 rxdp->Buffer2_ptr,=0A=
+					 dev->mtu + 22,=0A=
+					 PCI_DMA_FROMDEVICE);=0A=
+			ba =3D &nic->ba[i][get_block][get_info.offset];=0A=
+=0A=
+			rx_osm_handler(nic, rxdp, i, ba);=0A=
+=0A=
+			get_info.offset++;=0A=
+			mac_control->rx_curr_get_info[i].offset =3D=0A=
+			    get_info.offset;=0A=
+			rxdp =3D=0A=
+			    nic->rx_blocks[i][get_block].block_virt_addr +=0A=
+			    get_info.offset;=0A=
+=0A=
+			if (get_info.offset &&=0A=
+			    (!(get_info.offset % MAX_RXDS_PER_BLOCK))) {=0A=
+				get_info.offset =3D 0;=0A=
+				mac_control->rx_curr_get_info[i].=0A=
+				    offset =3D get_info.offset;=0A=
+				get_block++;=0A=
+				get_block %=3D nic->block_count[i];=0A=
+				mac_control->rx_curr_get_info[i].=0A=
+				    block_index =3D get_block;=0A=
+				rxdp =3D=0A=
+				    nic->rx_blocks[i][get_block].=0A=
+				    block_virt_addr;=0A=
+			}=0A=
+			get_offset =3D=0A=
+			    (get_block * (MAX_RXDS_PER_BLOCK + 1)) +=0A=
+			    get_info.offset;=0A=
+			pkt_cnt++;=0A=
+		}=0A=
+#endif=0A=
+	}=0A=
+	if (!pkt_cnt)=0A=
+		pkt_cnt =3D 1;=0A=
 =0A=
 	dev->quota -=3D pkt_cnt;=0A=
 	*budget -=3D pkt_cnt;=0A=
 	netif_rx_complete(dev);=0A=
 =0A=
-/* Re enable the Rx interrupts. */=0A=
-	en_dis_able_NicIntrs(nic, RX_TRAFFIC_INTR, ENABLE_INTRS);=0A=
+	for (i =3D 0; i < config->RxRingNum; i++) {=0A=
+		if (fill_rx_buffers(nic, i) =3D=3D -ENOMEM) {=0A=
+			DBG_PRINT(ERR_DBG, "%s:Out of memory", dev->name);=0A=
+			DBG_PRINT(ERR_DBG, " in Rx Poll!!\n");=0A=
+			break;=0A=
+		}=0A=
+	}=0A=
+	/* Re enable the Rx interrupts. */=0A=
+	en_dis_able_nic_intrs(nic, RX_TRAFFIC_INTR, ENABLE_INTRS);=0A=
 	return 0;=0A=
 =0A=
       no_rx:=0A=
-	for (i =3D 0; i < config->RxRingNum; i++)=0A=
-		fill_rx_buffers(nic, i);=0A=
 	dev->quota -=3D pkt_cnt;=0A=
 	*budget -=3D pkt_cnt;=0A=
+=0A=
+	for (i =3D 0; i < config->RxRingNum; i++) {=0A=
+		if (fill_rx_buffers(nic, i) =3D=3D -ENOMEM) {=0A=
+			DBG_PRINT(ERR_DBG, "%s:Out of memory", dev->name);=0A=
+			DBG_PRINT(ERR_DBG, " in Rx Poll!!\n");=0A=
+			break;=0A=
+		}=0A=
+	}=0A=
 	return 1;=0A=
 }=0A=
 #else=0A=
-/*  =0A=
- *  Input Arguments: =0A=
- *  device private variable.=0A=
- *  Return Value: =0A=
- *  NONE.=0A=
+/**  =0A=
+ *  rx_intr_handler - Rx interrupt handler=0A=
+ *  @nic: device private variable.=0A=
  *  Description: =0A=
- * If the interrupt is because of a received frame or if the =0A=
- *  receive ring contains fresh as yet un-processed frames, this =
function is=0A=
+ *  If the interrupt is because of a received frame or if the =0A=
+ *  receive ring contains fresh as yet un-processed frames,this =
function is=0A=
  *  called. It picks out the RxD at which place the last Rx processing =
had =0A=
  *  stopped and sends the skb to the OSM's Rx handler and then =
increments =0A=
  *  the offset.=0A=
+ *  Return Value:=0A=
+ *  NONE.=0A=
  */=0A=
-static void rxIntrHandler(struct s2io_nic *nic)=0A=
+=0A=
+static void rx_intr_handler(struct s2io_nic *nic)=0A=
 {=0A=
 	struct net_device *dev =3D (struct net_device *) nic->dev;=0A=
 	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) nic->bar0;=0A=
-	rx_curr_get_info_t offset_info;=0A=
+	rx_curr_get_info_t get_info, put_info;=0A=
 	RxD_t *rxdp;=0A=
 	struct sk_buff *skb;=0A=
+#ifndef CONFIG_2BUFF_MODE=0A=
 	u16 val16, cksum;=0A=
+#endif=0A=
 	register u64 val64 =3D 0;=0A=
-	int i, block_no;=0A=
+	int get_block, get_offset, put_block, put_offset, ring_bufs;=0A=
+	int i, pkt_cnt =3D 0;=0A=
 	mac_info_t *mac_control;=0A=
 	struct config_param *config;=0A=
+#ifdef CONFIG_2BUFF_MODE=0A=
+	buffAdd_t *ba;=0A=
+#endif=0A=
 =0A=
 	mac_control =3D &nic->mac_control;=0A=
 	config =3D &nic->config;=0A=
 =0A=
-#if DEBUG_ON=0A=
-	nic->rxint_cnt++;=0A=
-#endif=0A=
-=0A=
-/* rx_traffic_int reg is an R1 register, hence we read and write back =0A=
- * the samevalue in the register to clear it.=0A=
- */=0A=
+	/* =0A=
+	 * rx_traffic_int reg is an R1 register, hence we read and write back =0A=
+	 * the samevalue in the register to clear it.=0A=
+	 */=0A=
 	val64 =3D readq(&bar0->rx_traffic_int);=0A=
 	writeq(val64, &bar0->rx_traffic_int);=0A=
 =0A=
 	for (i =3D 0; i < config->RxRingNum; i++) {=0A=
-		offset_info =3D mac_control->rx_curr_get_info[i];=0A=
-		block_no =3D offset_info.block_index;=0A=
-		rxdp =3D nic->rx_blocks[i][block_no].block_virt_addr +=0A=
-		    offset_info.offset;=0A=
-		while (!(rxdp->Control_1 & RXD_OWN_XENA)) {=0A=
+		get_info =3D mac_control->rx_curr_get_info[i];=0A=
+		get_block =3D get_info.block_index;=0A=
+		put_info =3D mac_control->rx_curr_put_info[i];=0A=
+		put_block =3D put_info.block_index;=0A=
+		ring_bufs =3D config->rx_cfg[i].NumRxd;=0A=
+		rxdp =3D nic->rx_blocks[i][get_block].block_virt_addr +=0A=
+		    get_info.offset;=0A=
+#ifndef	CONFIG_2BUFF_MODE=0A=
+		get_offset =3D (get_block * (MAX_RXDS_PER_BLOCK + 1)) +=0A=
+		    get_info.offset;=0A=
+#ifndef CONFIG_S2IO_NAPI=0A=
+		spin_lock(&nic->put_lock);=0A=
+		put_offset =3D nic->put_pos;=0A=
+		spin_unlock(&nic->put_lock);=0A=
+#endif=0A=
+		while ((!(rxdp->Control_1 & RXD_OWN_XENA)) &&=0A=
+		       (((get_offset + 1) % ring_bufs) !=3D put_offset)) {=0A=
 			if (rxdp->Control_1 =3D=3D END_OF_BLOCK) {=0A=
 				rxdp =3D (RxD_t *) ((unsigned long)=0A=
 						  rxdp->Control_2);=0A=
-				offset_info.offset++;=0A=
-				offset_info.offset %=3D=0A=
+				get_info.offset++;=0A=
+				get_info.offset %=3D=0A=
 				    (MAX_RXDS_PER_BLOCK + 1);=0A=
-				block_no++;=0A=
-				block_no %=3D nic->block_count[i];=0A=
+				get_block++;=0A=
+				get_block %=3D nic->block_count[i];=0A=
 				mac_control->rx_curr_get_info[i].=0A=
-				    offset =3D offset_info.offset;=0A=
+				    offset =3D get_info.offset;=0A=
 				mac_control->rx_curr_get_info[i].=0A=
-				    block_index =3D block_no;=0A=
+				    block_index =3D get_block;=0A=
 				continue;=0A=
 			}=0A=
+			get_offset =3D=0A=
+			    (get_block * (MAX_RXDS_PER_BLOCK + 1)) +=0A=
+			    get_info.offset;=0A=
 			skb =3D (struct sk_buff *) ((unsigned long)=0A=
 						  rxdp->Host_Control);=0A=
 			if (skb =3D=3D NULL) {=0A=
@@ -1698,35 +2244,104 @@=0A=
 					 HEADER_802_2_SIZE +=0A=
 					 HEADER_SNAP_SIZE,=0A=
 					 PCI_DMA_FROMDEVICE);=0A=
-			rxOsmHandler(nic, val16, rxdp, i);=0A=
-			offset_info.offset++;=0A=
-			offset_info.offset %=3D (MAX_RXDS_PER_BLOCK + 1);=0A=
+			rx_osm_handler(nic, val16, rxdp, i);=0A=
+			get_info.offset++;=0A=
+			get_info.offset %=3D (MAX_RXDS_PER_BLOCK + 1);=0A=
 			rxdp =3D=0A=
-			    nic->rx_blocks[i][block_no].block_virt_addr +=0A=
-			    offset_info.offset;=0A=
+			    nic->rx_blocks[i][get_block].block_virt_addr +=0A=
+			    get_info.offset;=0A=
+			mac_control->rx_curr_get_info[i].offset =3D=0A=
+			    get_info.offset;=0A=
+			pkt_cnt++;=0A=
+			if ((indicate_max_pkts)=0A=
+			    && (pkt_cnt > indicate_max_pkts))=0A=
+				break;=0A=
+		}=0A=
+#else=0A=
+		get_offset =3D (get_block * (MAX_RXDS_PER_BLOCK + 1)) +=0A=
+		    get_info.offset;=0A=
+#ifndef CONFIG_S2IO_NAPI=0A=
+		spin_lock(&nic->put_lock);=0A=
+		put_offset =3D nic->put_pos;=0A=
+		spin_unlock(&nic->put_lock);=0A=
+#endif=0A=
+		while (((!(rxdp->Control_1 & RXD_OWN_XENA)) &&=0A=
+			!(rxdp->Control_2 & BIT(0))) &&=0A=
+		       (((get_offset + 1) % ring_bufs) !=3D put_offset)) {=0A=
+			skb =3D (struct sk_buff *) ((unsigned long)=0A=
+						  rxdp->Host_Control);=0A=
+			if (skb =3D=3D NULL) {=0A=
+				DBG_PRINT(ERR_DBG, "%s: The skb is ",=0A=
+					  dev->name);=0A=
+				DBG_PRINT(ERR_DBG, "Null in Rx Intr\n");=0A=
+				return;=0A=
+			}=0A=
+=0A=
+			pci_unmap_single(nic->pdev, (dma_addr_t)=0A=
+					 rxdp->Buffer0_ptr,=0A=
+					 BUF0_LEN, PCI_DMA_FROMDEVICE);=0A=
+			pci_unmap_single(nic->pdev, (dma_addr_t)=0A=
+					 rxdp->Buffer1_ptr,=0A=
+					 BUF1_LEN, PCI_DMA_FROMDEVICE);=0A=
+			pci_unmap_single(nic->pdev, (dma_addr_t)=0A=
+					 rxdp->Buffer2_ptr,=0A=
+					 dev->mtu + 22,=0A=
+					 PCI_DMA_FROMDEVICE);=0A=
+			ba =3D &nic->ba[i][get_block][get_info.offset];=0A=
+=0A=
+			rx_osm_handler(nic, rxdp, i, ba);=0A=
+=0A=
+			get_info.offset++;=0A=
 			mac_control->rx_curr_get_info[i].offset =3D=0A=
-			    offset_info.offset;=0A=
+			    get_info.offset;=0A=
+			rxdp =3D=0A=
+			    nic->rx_blocks[i][get_block].block_virt_addr +=0A=
+			    get_info.offset;=0A=
+=0A=
+			if (get_info.offset &&=0A=
+			    (!(get_info.offset % MAX_RXDS_PER_BLOCK))) {=0A=
+				get_info.offset =3D 0;=0A=
+				mac_control->rx_curr_get_info[i].=0A=
+				    offset =3D get_info.offset;=0A=
+				get_block++;=0A=
+				get_block %=3D nic->block_count[i];=0A=
+				mac_control->rx_curr_get_info[i].=0A=
+				    block_index =3D get_block;=0A=
+				rxdp =3D=0A=
+				    nic->rx_blocks[i][get_block].=0A=
+				    block_virt_addr;=0A=
+			}=0A=
+			get_offset =3D=0A=
+			    (get_block * (MAX_RXDS_PER_BLOCK + 1)) +=0A=
+			    get_info.offset;=0A=
+			pkt_cnt++;=0A=
+			if ((indicate_max_pkts)=0A=
+			    && (pkt_cnt > indicate_max_pkts))=0A=
+				break;=0A=
 		}=0A=
+#endif=0A=
+		if ((indicate_max_pkts) && (pkt_cnt > indicate_max_pkts))=0A=
+			break;=0A=
 	}=0A=
 }=0A=
 #endif=0A=
-=0A=
-/*  =0A=
- *  Input Arguments: =0A=
- *  device private variable=0A=
- *  Return Value: =0A=
- *  NONE=0A=
+/**  =0A=
+ *  tx_intr_handler - Transmit interrupt handler=0A=
+ *  @nic : device private variable=0A=
  *  Description: =0A=
  *  If an interrupt was raised to indicate DMA complete of the =0A=
- *  Tx packet, this function is called. It identifies the last TxD =
whose buffer=0A=
- *  was freed and frees all skbs whose data have already DMA'ed into =
the NICs=0A=
- *  internal memory.=0A=
+ *  Tx packet, this function is called. It identifies the last TxD =0A=
+ *  whose buffer was freed and frees all skbs whose data have already =0A=
+ *  DMA'ed into the NICs internal memory.=0A=
+ *  Return Value:=0A=
+ *  NONE=0A=
  */=0A=
-static void txIntrHandler(struct s2io_nic *nic)=0A=
+=0A=
+static void tx_intr_handler(struct s2io_nic *nic)=0A=
 {=0A=
 	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) nic->bar0;=0A=
 	struct net_device *dev =3D (struct net_device *) nic->dev;=0A=
-	tx_curr_get_info_t offset_info, offset_info1;=0A=
+	tx_curr_get_info_t get_info, put_info;=0A=
 	struct sk_buff *skb;=0A=
 	TxD_t *txdlp;=0A=
 	register u64 val64 =3D 0;=0A=
@@ -1734,27 +2349,24 @@=0A=
 	u16 j, frg_cnt;=0A=
 	mac_info_t *mac_control;=0A=
 	struct config_param *config;=0A=
-#if DEBUG_ON=0A=
-	int cnt =3D 0;=0A=
-	nic->txint_cnt++;=0A=
-#endif=0A=
 =0A=
 	mac_control =3D &nic->mac_control;=0A=
 	config =3D &nic->config;=0A=
 =0A=
-	/* tx_traffic_int reg is an R1 register, hence we read and write =0A=
+	/* =0A=
+	 * tx_traffic_int reg is an R1 register, hence we read and write =0A=
 	 * back the samevalue in the register to clear it.=0A=
 	 */=0A=
 	val64 =3D readq(&bar0->tx_traffic_int);=0A=
 	writeq(val64, &bar0->tx_traffic_int);=0A=
 =0A=
 	for (i =3D 0; i < config->TxFIFONum; i++) {=0A=
-		offset_info =3D mac_control->tx_curr_get_info[i];=0A=
-		offset_info1 =3D mac_control->tx_curr_put_info[i];=0A=
-		txdlp =3D mac_control->txdl_start[i] +=0A=
-		    (config->MaxTxDs * offset_info.offset);=0A=
+		get_info =3D mac_control->tx_curr_get_info[i];=0A=
+		put_info =3D mac_control->tx_curr_put_info[i];=0A=
+		txdlp =3D (TxD_t *) nic->list_info[i][get_info.offset].=0A=
+		    list_virt_addr;=0A=
 		while ((!(txdlp->Control_1 & TXD_LIST_OWN_XENA)) &&=0A=
-		       (offset_info.offset !=3D offset_info1.offset) &&=0A=
+		       (get_info.offset !=3D put_info.offset) &&=0A=
 		       (txdlp->Host_Control)) {=0A=
 			/* Check for TxD errors */=0A=
 			if (txdlp->Control_1 & TXD_T_CODE) {=0A=
@@ -1802,23 +2414,15 @@=0A=
 			/* Updating the statistics block */=0A=
 			nic->stats.tx_packets++;=0A=
 			nic->stats.tx_bytes +=3D skb->len;=0A=
-#if DEBUG_ON=0A=
-			nic->txpkt_bytes +=3D skb->len;=0A=
-			cnt++;=0A=
-#endif=0A=
 			dev_kfree_skb_irq(skb);=0A=
 =0A=
-			offset_info.offset++;=0A=
-			offset_info.offset %=3D offset_info.fifo_len + 1;=0A=
-			txdlp =3D mac_control->txdl_start[i] +=0A=
-			    (config->MaxTxDs * offset_info.offset);=0A=
+			get_info.offset++;=0A=
+			get_info.offset %=3D get_info.fifo_len + 1;=0A=
+			txdlp =3D (TxD_t *) nic->list_info[i]=0A=
+			    [get_info.offset].list_virt_addr;=0A=
 			mac_control->tx_curr_get_info[i].offset =3D=0A=
-			    offset_info.offset;=0A=
+			    get_info.offset;=0A=
 		}=0A=
-#if DEBUG_ON=0A=
-		DBG_PRINT(INTR_DBG, "%s: freed %d Tx Pkts\n", dev->name,=0A=
-			  cnt);=0A=
-#endif=0A=
 	}=0A=
 =0A=
 	spin_lock(&nic->tx_lock);=0A=
@@ -1827,67 +2431,78 @@=0A=
 	spin_unlock(&nic->tx_lock);=0A=
 }=0A=
 =0A=
-/*  =0A=
- *  Input Arguments: =0A=
- *  device private variable=0A=
- *  Return Value: =0A=
+/**  =0A=
+ *  alarm_intr_handler - Alarm Interrrupt handler=0A=
+ *  @nic: device private variable=0A=
+ *  Description: If the interrupt was neither because of Rx packet or =
Tx =0A=
+ *  complete, this function is called. If the interrupt was to indicate=0A=
+ *  a loss of link, the OSM link status handler is invoked for any =
other =0A=
+ *  alarm interrupt the block that raised the interrupt is displayed =0A=
+ *  and a H/W reset is issued.=0A=
+ *  Return Value:=0A=
  *  NONE=0A=
- *  Description: =0A=
- *  If the interrupt was neither because of Rx packet or Tx =0A=
- *  complete, this function is called. If the interrupt was to indicate =
a loss=0A=
- *  of link, the OSM link status handler is invoked for any other alarm =0A=
- *  interrupt the block that raised the interrupt is displayed and a =
H/W reset =0A=
- *  is issued.=0A=
- */=0A=
-static void alarmIntrHandler(struct s2io_nic *nic)=0A=
+*/=0A=
+=0A=
+static void alarm_intr_handler(struct s2io_nic *nic)=0A=
 {=0A=
 	struct net_device *dev =3D (struct net_device *) nic->dev;=0A=
 	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) nic->bar0;=0A=
 	register u64 val64 =3D 0, err_reg =3D 0;=0A=
 =0A=
-=0A=
 	/* Handling link status change error Intr */=0A=
 	err_reg =3D readq(&bar0->mac_rmac_err_reg);=0A=
+	writeq(err_reg, &bar0->mac_rmac_err_reg);=0A=
 	if (err_reg & RMAC_LINK_STATE_CHANGE_INT) {=0A=
 		schedule_work(&nic->set_link_task);=0A=
 	}=0A=
 =0A=
-	/* Handling SERR errors by stopping device Xmit queue and forcing =0A=
-	 * a H/W reset.=0A=
-	 */=0A=
+	/* In case of a serious error, the device will be Reset. */=0A=
 	val64 =3D readq(&bar0->serr_source);=0A=
 	if (val64 & SERR_SOURCE_ANY) {=0A=
 		DBG_PRINT(ERR_DBG, "%s: Device indicates ", dev->name);=0A=
 		DBG_PRINT(ERR_DBG, "serious error!!\n");=0A=
-		netif_stop_queue(dev);=0A=
+		schedule_work(&nic->rst_timer_task);=0A=
+	}=0A=
+=0A=
+	/*=0A=
+	 * Also as mentioned in the latest Errata sheets if the PCC_FB_ECC=0A=
+	 * Error occurs, the adapter will be recycled by disabling the=0A=
+	 * adapter enable bit and enabling it again after the device =0A=
+	 * becomes Quiescent.=0A=
+	 */=0A=
+	val64 =3D readq(&bar0->pcc_err_reg);=0A=
+	writeq(val64, &bar0->pcc_err_reg);=0A=
+	if (val64 & PCC_FB_ECC_DB_ERR) {=0A=
+		u64 ac =3D readq(&bar0->adapter_control);=0A=
+		ac &=3D ~(ADAPTER_CNTL_EN);=0A=
+		writeq(ac, &bar0->adapter_control);=0A=
+		ac =3D readq(&bar0->adapter_control);=0A=
+		schedule_work(&nic->set_link_task);=0A=
 	}=0A=
-/* Other type of interrupts are not being handled now,  TODO*/=0A=
+=0A=
+	/* Other type of interrupts are not being handled now,  TODO */=0A=
 }=0A=
 =0A=
-/*=0A=
- *  Input Argument: =0A=
- *  sp - private member of the device structure, which is a pointer to =
the =0A=
- *   	s2io_nic structure.=0A=
+/** =0A=
+ *  wait_for_cmd_complete - waits for a command to complete.=0A=
+ *  @sp : private member of the device structure, which is a pointer to =
the =0A=
+ *  s2io_nic structure.=0A=
+ *  Description: Function that waits for a command to Write into RMAC =0A=
+ *  ADDR DATA registers to be completed and returns either success or =0A=
+ *  error depending on whether the command was complete or not. =0A=
  *  Return value:=0A=
  *   SUCCESS on success and FAILURE on failure.=0A=
- *  Description:=0A=
- *   Function that waits for a command to Write into RMAC ADDR DATA =
registers =0A=
- *   to be completed and returns either success or error depending on =
whether =0A=
- *   the command was complete or not. =0A=
  */=0A=
-int waitForCmdComplete(nic_t * sp)=0A=
+=0A=
+int wait_for_cmd_complete(nic_t * sp)=0A=
 {=0A=
 	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) sp->bar0;=0A=
 	int ret =3D FAILURE, cnt =3D 0;=0A=
 	u64 val64;=0A=
 =0A=
 	while (TRUE) {=0A=
-		val64 =3D=0A=
-		    RMAC_ADDR_CMD_MEM_RD | RMAC_ADDR_CMD_MEM_STROBE_NEW_CMD=0A=
-		    | RMAC_ADDR_CMD_MEM_OFFSET(0);=0A=
-		writeq(val64, &bar0->rmac_addr_cmd_mem);=0A=
 		val64 =3D readq(&bar0->rmac_addr_cmd_mem);=0A=
-		if (!val64) {=0A=
+		if (!(val64 & RMAC_ADDR_CMD_MEM_STROBE_CMD_EXECUTING)) {=0A=
 			ret =3D SUCCESS;=0A=
 			break;=0A=
 		}=0A=
@@ -1900,17 +2515,16 @@=0A=
 	return ret;=0A=
 }=0A=
 =0A=
-/*=0A=
- *  Input Argument: =0A=
- *  sp - private member of the device structure, which is a pointer to =
the =0A=
- *   	s2io_nic structure.=0A=
+/** =0A=
+ *  s2io_reset - Resets the card. =0A=
+ *  @sp : private member of the device structure.=0A=
+ *  Description: Function to Reset the card. This function then also=0A=
+ *  restores the previously saved PCI configuration space registers as =0A=
+ *  the card reset also resets the Configration space.=0A=
  *  Return value:=0A=
- *   void.=0A=
- *  Description:=0A=
- *   Function to Reset the card. This function then also restores the =
previously=0A=
- *   saved PCI configuration space registers as the card reset also =
resets the=0A=
- *   Configration space.=0A=
+ *  void.=0A=
  */=0A=
+=0A=
 void s2io_reset(nic_t * sp)=0A=
 {=0A=
 	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) sp->bar0;=0A=
@@ -1920,7 +2534,8 @@=0A=
 	val64 =3D SW_RESET_ALL;=0A=
 	writeq(val64, &bar0->sw_reset);=0A=
 =0A=
-	/* At this stage, if the PCI write is indeed completed, the =0A=
+	/* =0A=
+	 * At this stage, if the PCI write is indeed completed, the =0A=
 	 * card is reset and so is the PCI Config space of the device. =0A=
 	 * So a read cannot be issued at this stage on any of the =0A=
 	 * registers to ensure the write into "sw_reset" register=0A=
@@ -1928,18 +2543,16 @@=0A=
 	 * Question: Is there any system call that will explicitly force=0A=
 	 * all the write commands still pending on the bus to be pushed=0A=
 	 * through?=0A=
-	 * As of now I'am just giving a 250ms delay and hoping that the=0A=
+	 * As of now I'am just giving a 100ms delay and hoping that the=0A=
 	 * PCI write to sw_reset register is done by this time.=0A=
 	 */=0A=
-	set_current_state(TASK_UNINTERRUPTIBLE);=0A=
-	schedule_timeout(HZ / 4);=0A=
+	mdelay(100);=0A=
 =0A=
 	/* Restore the PCI state saved during initializarion. */=0A=
 	pci_restore_state(sp->pdev, sp->config_space);=0A=
 	s2io_init_pci(sp);=0A=
 =0A=
-	set_current_state(TASK_UNINTERRUPTIBLE);=0A=
-	schedule_timeout(HZ / 4);=0A=
+	mdelay(100);=0A=
 =0A=
 	/* SXE-002: Configure link and activity LED to turn it off */=0A=
 	subid =3D sp->pdev->subsystem_device;=0A=
@@ -1954,29 +2567,31 @@=0A=
 	sp->device_enabled_once =3D FALSE;=0A=
 }=0A=
 =0A=
-/*=0A=
- *  Input Argument: =0A=
- *  sp - private member of the device structure, which is a pointer to =
the =0A=
- *   	s2io_nic structure.=0A=
+/**=0A=
+ *  s2io_set_swapper - to set the swapper controle on the card =0A=
+ *  @sp : private member of the device structure, =0A=
+ *  pointer to the s2io_nic structure.=0A=
+ *  Description: Function to set the swapper control on the card =0A=
+ *  correctly depending on the 'endianness' of the system.=0A=
  *  Return value:=0A=
  *  SUCCESS on success and FAILURE on failure.=0A=
- *  Description:=0A=
- * Function to set the swapper control on the card correctly depending =
on the=0A=
- * 'endianness' of the system.=0A=
  */=0A=
+=0A=
 int s2io_set_swapper(nic_t * sp)=0A=
 {=0A=
 	struct net_device *dev =3D sp->dev;=0A=
 	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) sp->bar0;=0A=
 	u64 val64;=0A=
 =0A=
-/*  Set proper endian settings and verify the same by reading the PIF =0A=
- *  Feed-back register.=0A=
- */=0A=
+	/* =0A=
+	 * Set proper endian settings and verify the same by reading=0A=
+	 * the PIF Feed-back register.=0A=
+	 */=0A=
 #ifdef  __BIG_ENDIAN=0A=
-/* The device by default set to a big endian format, so a big endian =0A=
- * driver need not set anything.=0A=
- */=0A=
+	/* =0A=
+	 * The device by default set to a big endian format, so a =0A=
+	 * big endian driver need not set anything.=0A=
+	 */=0A=
 	writeq(0xffffffffffffffffULL, &bar0->swapper_ctrl);=0A=
 	val64 =3D (SWAPPER_CTRL_PIF_R_FE |=0A=
 		 SWAPPER_CTRL_PIF_R_SE |=0A=
@@ -1995,9 +2610,11 @@=0A=
 		 SWAPPER_CTRL_STATS_FE | SWAPPER_CTRL_STATS_SE);=0A=
 	writeq(val64, &bar0->swapper_ctrl);=0A=
 #else=0A=
-/* Initially we enable all bits to make it accessible by the driver,=0A=
- * then we selectively enable only those bits that we want to set.=0A=
- */=0A=
+	/* =0A=
+	 * Initially we enable all bits to make it accessible by the=0A=
+	 * driver, then we selectively enable only those bits that =0A=
+	 * we want to set.=0A=
+	 */=0A=
 	writeq(0xffffffffffffffffULL, &bar0->swapper_ctrl);=0A=
 	val64 =3D (SWAPPER_CTRL_PIF_R_FE |=0A=
 		 SWAPPER_CTRL_PIF_R_SE |=0A=
@@ -2021,9 +2638,10 @@=0A=
 	writeq(val64, &bar0->swapper_ctrl);=0A=
 #endif=0A=
 =0A=
-/*  Verifying if endian settings are accurate by reading a feedback=0A=
- *  register.=0A=
- */=0A=
+	/* =0A=
+	 * Verifying if endian settings are accurate by reading a =0A=
+	 * feedback register.=0A=
+	 */=0A=
 	val64 =3D readq(&bar0->pif_rd_swapper_fb);=0A=
 	if (val64 !=3D 0x0123456789ABCDEFULL) {=0A=
 		/* Endian settings are incorrect, calls for another dekko. */=0A=
@@ -2041,17 +2659,18 @@=0A=
  * Functions defined below concern the OS part of the driver *=0A=
  * ********************************************************* */=0A=
 =0A=
-/*=0A=
- *  Input Argument: =0A=
- *  dev - pointer to the device structure.=0A=
- *  Return value:=0A=
- *  '0' on success and an appropriate (-)ve integer as defined in =
errno.h=0A=
- *   file on failure.=0A=
+/**  =0A=
+ *  s2io-open - open entry point of the driver=0A=
+ *  @dev : pointer to the device structure.=0A=
  *  Description:=0A=
  *  This function is the open entry point of the driver. It mainly =
calls a=0A=
  *  function to allocate Rx buffers and inserts them into the buffer=0A=
  *  descriptors and then enables the Rx part of the NIC. =0A=
+ *  Return value:=0A=
+ *  0 on success and an appropriate (-)ve integer as defined in errno.h=0A=
+ *   file on failure.=0A=
  */=0A=
+=0A=
 int s2io_open(struct net_device *dev)=0A=
 {=0A=
 	nic_t *sp =3D dev->priv;=0A=
@@ -2060,18 +2679,21 @@=0A=
 	struct config_param *config;=0A=
 =0A=
 =0A=
-/* Make sure you have link off by default every time Nic is =
initialized*/=0A=
+	/* =0A=
+	 * Make sure you have link off by default every time =0A=
+	 * Nic is initialized=0A=
+	 */=0A=
 	netif_carrier_off(dev);=0A=
 	sp->last_link_state =3D LINK_DOWN;=0A=
 =0A=
-/*  Initialize the H/W I/O registers */=0A=
-	if (initNic(sp) !=3D 0) {=0A=
+	/* Initialize the H/W I/O registers */=0A=
+	if (init_nic(sp) !=3D 0) {=0A=
 		DBG_PRINT(ERR_DBG, "%s: H/W initialization failed\n",=0A=
 			  dev->name);=0A=
 		return -ENODEV;=0A=
 	}=0A=
 =0A=
-/*  After proper initialization of H/W, register ISR */=0A=
+	/* After proper initialization of H/W, register ISR */=0A=
 	err =3D=0A=
 	    request_irq((int) sp->irq, s2io_isr, SA_SHIRQ, sp->name, dev);=0A=
 	if (err) {=0A=
@@ -2087,12 +2709,13 @@=0A=
 	}=0A=
 =0A=
 =0A=
-/*  Setting its receive mode */=0A=
+	/* Setting its receive mode */=0A=
 	s2io_set_multicast(dev);=0A=
 =0A=
-/*  Initializing the Rx buffers. For now we are considering only 1 Rx =
ring=0A=
- * and initializing buffers into 1016 RxDs or 8 Rx blocks=0A=
- */=0A=
+	/* =0A=
+	 * Initializing the Rx buffers. For now we are considering only 1 =0A=
+	 * Rx ring and initializing buffers into 1016 RxDs or 8 Rx blocks=0A=
+	 */=0A=
 	mac_control =3D &sp->mac_control;=0A=
 	config =3D &sp->config;=0A=
 =0A=
@@ -2102,23 +2725,23 @@=0A=
 				  dev->name);=0A=
 			s2io_reset(sp);=0A=
 			free_irq(dev->irq, dev);=0A=
-			freeRxBuffers(sp);=0A=
+			free_rx_buffers(sp);=0A=
 			return -ENOMEM;=0A=
 		}=0A=
 		DBG_PRINT(INFO_DBG, "Buf in ring:%d is %d:\n", i,=0A=
 			  atomic_read(&sp->rx_bufs_left[i]));=0A=
 	}=0A=
 =0A=
-/*  Enable tasklet for the device */=0A=
+	/* Enable tasklet for the device */=0A=
 	tasklet_init(&sp->task, s2io_tasklet, (unsigned long) dev);=0A=
 =0A=
-/*  Enable Rx Traffic and interrupts on the NIC */=0A=
-	if (startNic(sp)) {=0A=
+	/* Enable Rx Traffic and interrupts on the NIC */=0A=
+	if (start_nic(sp)) {=0A=
 		DBG_PRINT(ERR_DBG, "%s: Starting NIC failed\n", dev->name);=0A=
 		tasklet_kill(&sp->task);=0A=
 		s2io_reset(sp);=0A=
 		free_irq(dev->irq, dev);=0A=
-		freeRxBuffers(sp);=0A=
+		free_rx_buffers(sp);=0A=
 		return -ENODEV;=0A=
 	}=0A=
 =0A=
@@ -2128,41 +2751,55 @@=0A=
 	return 0;=0A=
 }=0A=
 =0A=
-/*=0A=
- *  Input Argument/s: =0A=
- *  dev - device pointer.=0A=
- *  Return value:=0A=
- *  '0' on success and an appropriate (-)ve integer as defined in =
errno.h=0A=
- *  file on failure.=0A=
+/**=0A=
+ *  s2io_close -close entry point of the driver=0A=
+ *  @dev : device pointer.=0A=
  *  Description:=0A=
  *  This is the stop entry point of the driver. It needs to undo exactly=0A=
- *  whatever was done by the open entry point, thus it's usually =
referred to=0A=
- *  as the close function. Among other things this function mainly =
stops the=0A=
+ *  whatever was done by the open entry point,thus it's usually =
referred to=0A=
+ *  as the close function.Among other things this function mainly stops =
the=0A=
  *  Rx side of the NIC and frees all the Rx buffers in the Rx rings.=0A=
+ *  Return value:=0A=
+ *  0 on success and an appropriate (-)ve integer as defined in errno.h=0A=
+ *  file on failure.=0A=
  */=0A=
+=0A=
 int s2io_close(struct net_device *dev)=0A=
 {=0A=
 	nic_t *sp =3D dev->priv;=0A=
 	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) sp->bar0;=0A=
 	register u64 val64 =3D 0;=0A=
 	u16 cnt =3D 0;=0A=
+	unsigned long flags;=0A=
 =0A=
-	spin_lock(&sp->isr_lock);=0A=
+	spin_lock_irqsave(&sp->tx_lock, flags);=0A=
 	netif_stop_queue(dev);=0A=
 =0A=
-/* disable Tx and Rx traffic on the NIC */=0A=
-	stopNic(sp);=0A=
+	/* disable Tx and Rx traffic on the NIC */=0A=
+	stop_nic(sp);=0A=
 =0A=
-	spin_unlock(&sp->isr_lock);=0A=
-=0A=
-/* If the device tasklet is running, wait till its done before killing =
it */=0A=
+	/* =0A=
+	 * If the device tasklet is running, wait till its done =0A=
+	 * before killing it =0A=
+	 */=0A=
 	while (atomic_read(&(sp->tasklet_status))) {=0A=
 		set_current_state(TASK_UNINTERRUPTIBLE);=0A=
 		schedule_timeout(HZ / 10);=0A=
 	}=0A=
 	tasklet_kill(&sp->task);=0A=
 =0A=
-/* Check if the device is Quiescent and then Reset the NIC */=0A=
+	/*  Free the Registered IRQ */=0A=
+	free_irq(dev->irq, dev);=0A=
+=0A=
+	/* Flush all scheduled tasks */=0A=
+	if (sp->task_flag =3D=3D 1) {=0A=
+		DBG_PRINT(INFO_DBG, "%s: Calling close from a task\n",=0A=
+			  dev->name);=0A=
+	} else {=0A=
+		flush_scheduled_work();=0A=
+	}=0A=
+=0A=
+	/* Check if the device is Quiescent and then Reset the NIC */=0A=
 	do {=0A=
 		val64 =3D readq(&bar0->adapter_status);=0A=
 		if (verify_xena_quiescence(val64, sp->device_enabled_once)) {=0A=
@@ -2182,36 +2819,35 @@=0A=
 	} while (1);=0A=
 	s2io_reset(sp);=0A=
 =0A=
-/*  Free the Registered IRQ */=0A=
-	free_irq(dev->irq, dev);=0A=
-=0A=
-/* Free all Tx Buffers waiting for transmission */=0A=
-	freeTxBuffers(sp);=0A=
+	/* Free all Tx Buffers waiting for transmission */=0A=
+	free_tx_buffers(sp);=0A=
 =0A=
-/*  Free all Rx buffers allocated by host */=0A=
-	freeRxBuffers(sp);=0A=
+	/*  Free all Rx buffers allocated by host */=0A=
+	free_rx_buffers(sp);=0A=
 =0A=
 	sp->device_close_flag =3D TRUE;	/* Device is shut down. */=0A=
+	spin_unlock_irqrestore(&sp->tx_lock, flags);=0A=
 =0A=
 	return 0;=0A=
 }=0A=
 =0A=
-/*=0A=
- *  Input Argument/s: =0A=
- *  skb - the socket buffer containing the Tx data.=0A=
- *  dev - device pointer.=0A=
- *  Return value:=0A=
- *  '0' on success & 1 on failure. =0A=
- *  NOTE: when device cant queue the pkt, just the trans_start variable =
will=0A=
- *  not be upadted.=0A=
- *  Description:=0A=
+/**=0A=
+ *  s2io_xmit - Tx entry point of te driver=0A=
+ *  @skb : the socket buffer containing the Tx data.=0A=
+ *  @dev : device pointer.=0A=
+ *  Description :=0A=
  *  This function is the Tx entry point of the driver. S2IO NIC supports=0A=
  *  certain protocol assist features on Tx side, namely  CSO, S/G, LSO.=0A=
+ *  NOTE: when device cant queue the pkt,just the trans_start variable =
will=0A=
+ *  not be upadted.=0A=
+ *  Return value:=0A=
+ *  0 on success & 1 on failure.=0A=
  */=0A=
+=0A=
 int s2io_xmit(struct sk_buff *skb, struct net_device *dev)=0A=
 {=0A=
 	nic_t *sp =3D dev->priv;=0A=
-	u16 off, txd_len, frg_cnt, frg_len, i, queue, off1, queue_len;=0A=
+	u16 frg_cnt, frg_len, i, queue, queue_len, put_off, get_off;=0A=
 	register u64 val64;=0A=
 	TxD_t *txdp;=0A=
 	TxFIFO_element_t *tx_fifo;=0A=
@@ -2221,6 +2857,7 @@=0A=
 #endif=0A=
 	mac_info_t *mac_control;=0A=
 	struct config_param *config;=0A=
+	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) sp->bar0;=0A=
 =0A=
 	mac_control =3D &sp->mac_control;=0A=
 	config =3D &sp->config;=0A=
@@ -2228,6 +2865,14 @@=0A=
 	DBG_PRINT(TX_DBG, "%s: In S2IO Tx routine\n", dev->name);=0A=
 =0A=
 	spin_lock_irqsave(&sp->tx_lock, flags);=0A=
+	if ((netif_queue_stopped(dev)) || (!netif_carrier_ok(dev))) {=0A=
+		DBG_PRINT(ERR_DBG, "%s:s2io_xmit: Tx Queue stopped\n",=0A=
+			  dev->name);=0A=
+		dev_kfree_skb(skb);=0A=
+		spin_unlock_irqrestore(&sp->tx_lock, flags);=0A=
+		return 0;=0A=
+	}=0A=
+=0A=
 	queue =3D 0;=0A=
 	/* Multi FIFO Tx is disabled for now. */=0A=
 	if (!queue && tx_prio) {=0A=
@@ -2236,21 +2881,19 @@=0A=
 	}=0A=
 =0A=
 =0A=
-	off =3D (u16) mac_control->tx_curr_put_info[queue].offset;=0A=
-	off1 =3D (u16) mac_control->tx_curr_get_info[queue].offset;=0A=
-	txd_len =3D mac_control->txdl_len;=0A=
-	txdp =3D mac_control->txdl_start[queue] + (config->MaxTxDs * off);=0A=
+	put_off =3D (u16) mac_control->tx_curr_put_info[queue].offset;=0A=
+	get_off =3D (u16) mac_control->tx_curr_get_info[queue].offset;=0A=
+	txdp =3D (TxD_t *) sp->list_info[queue][put_off].list_virt_addr;=0A=
 =0A=
 	queue_len =3D mac_control->tx_curr_put_info[queue].fifo_len + 1;=0A=
 	/* Avoid "put" pointer going beyond "get" pointer */=0A=
-	if (txdp->Host_Control || (((off + 1) % queue_len) =3D=3D off1)) {=0A=
+	if (txdp->Host_Control || (((put_off + 1) % queue_len) =3D=3D =
get_off)) {=0A=
 		DBG_PRINT(ERR_DBG, "Error in xmit, No free TXDs.\n");=0A=
 		netif_stop_queue(dev);=0A=
 		dev_kfree_skb(skb);=0A=
 		spin_unlock_irqrestore(&sp->tx_lock, flags);=0A=
 		return 0;=0A=
 	}=0A=
-=0A=
 #ifdef NETIF_F_TSO=0A=
 	mss =3D skb_shinfo(skb)->tso_size;=0A=
 	if (mss) {=0A=
@@ -2289,8 +2932,7 @@=0A=
 	txdp->Control_1 |=3D TXD_GATHER_CODE_LAST;=0A=
 =0A=
 	tx_fifo =3D mac_control->tx_FIFO_start[queue];=0A=
-	val64 =3D (mac_control->txdl_start_phy[queue] +=0A=
-		 (sizeof(TxD_t) * txd_len * off));=0A=
+	val64 =3D sp->list_info[queue][put_off].list_phy_addr;=0A=
 	writeq(val64, &tx_fifo->TxDL_Pointer);=0A=
 =0A=
 	val64 =3D (TX_FIFO_LAST_TXD_NUM(frg_cnt) | TX_FIFO_FIRST_LIST |=0A=
@@ -2301,15 +2943,18 @@=0A=
 #endif=0A=
 	writeq(val64, &tx_fifo->List_Control);=0A=
 =0A=
-	off++;=0A=
-	off %=3D mac_control->tx_curr_put_info[queue].fifo_len + 1;=0A=
-	mac_control->tx_curr_put_info[queue].offset =3D off;=0A=
+	/* Perform a PCI read to flush previous writes */=0A=
+	val64 =3D readq(&bar0->general_int_status);=0A=
+=0A=
+	put_off++;=0A=
+	put_off %=3D mac_control->tx_curr_put_info[queue].fifo_len + 1;=0A=
+	mac_control->tx_curr_put_info[queue].offset =3D put_off;=0A=
 =0A=
 	/* Avoid "put" pointer going beyond "get" pointer */=0A=
-	if (((off + 1) % queue_len) =3D=3D off1) {=0A=
-		DBG_PRINT(TX_DBG, =0A=
-		  "No free TxDs for xmit, Put: 0x%x Get:0x%x\n",=0A=
-		  off, off1);=0A=
+	if (((put_off + 1) % queue_len) =3D=3D get_off) {=0A=
+		DBG_PRINT(TX_DBG,=0A=
+			  "No free TxDs for xmit, Put: 0x%x Get:0x%x\n",=0A=
+			  put_off, get_off);=0A=
 		netif_stop_queue(dev);=0A=
 	}=0A=
 =0A=
@@ -2319,36 +2964,37 @@=0A=
 	return 0;=0A=
 }=0A=
 =0A=
-/*=0A=
- *  Input Argument/s: =0A=
- *  irq: the irq of the device.=0A=
- *  dev_id: a void pointer to the dev structure of the NIC.=0A=
- *  ptregs: pointer to the registers pushed on the stack.=0A=
+/**=0A=
+ *  s2io_isr - ISR handler of the device .=0A=
+ *  @irq: the irq of the device.=0A=
+ *  @dev_id: a void pointer to the dev structure of the NIC.=0A=
+ *  @pt_regs: pointer to the registers pushed on the stack.=0A=
+ *  Description:  This function is the ISR handler of the device. It =0A=
+ *  identifies the reason for the interrupt and calls the relevant =0A=
+ *  service routines. As a contongency measure, this ISR allocates the =0A=
+ *  recv buffers, if their numbers are below the panic value which is=0A=
+ *  presently set to 25% of the original number of rcv buffers =
allocated.=0A=
  *  Return value:=0A=
- *  void.=0A=
- *  Description:=0A=
- *  This function is the ISR handler of the device. It identifies the =
reason =0A=
- *  for the interrupt and calls the relevant service routines.=0A=
- *  As a contongency measure, this ISR allocates the recv buffers, if =
their =0A=
- *  numbers are below the panic value which is presently set to 25% of =
the=0A=
- *  original number of rcv buffers allocated.=0A=
+ *   IRQ_HANDLED: will be returned if IRQ was handled by this routine =0A=
+ *   IRQ_NONE: will be returned if interrupt is not from our device=0A=
  */=0A=
-=0A=
 static irqreturn_t s2io_isr(int irq, void *dev_id, struct pt_regs *regs)=0A=
 {=0A=
 	struct net_device *dev =3D (struct net_device *) dev_id;=0A=
 	nic_t *sp =3D dev->priv;=0A=
 	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) sp->bar0;=0A=
-	u64 reason =3D 0, general_mask =3D 0;=0A=
+#ifndef CONFIG_S2IO_NAPI=0A=
+	int i, ret;=0A=
+#endif=0A=
+	u64 reason =3D 0;=0A=
 	mac_info_t *mac_control;=0A=
 	struct config_param *config;=0A=
 =0A=
 	mac_control =3D &sp->mac_control;=0A=
 	config =3D &sp->config;=0A=
 =0A=
-	spin_lock(&sp->isr_lock);=0A=
-=0A=
-	/* Identify the cause for interrupt and call the appropriate=0A=
+	/* =0A=
+	 * Identify the cause for interrupt and call the appropriate=0A=
 	 * interrupt handler. Causes for the interrupt could be;=0A=
 	 * 1. Rx of packet.=0A=
 	 * 2. Tx complete.=0A=
@@ -2359,69 +3005,53 @@=0A=
 =0A=
 	if (!reason) {=0A=
 		/* The interrupt was not raised by Xena. */=0A=
-		spin_unlock(&sp->isr_lock);=0A=
 		return IRQ_NONE;=0A=
 	}=0A=
-	/* Mask the interrupts on the NIC */=0A=
-	general_mask =3D readq(&bar0->general_int_mask);=0A=
-	writeq(0xFFFFFFFFFFFFFFFFULL, &bar0->general_int_mask);=0A=
-=0A=
-#if DEBUG_ON=0A=
-	sp->int_cnt++;=0A=
-#endif=0A=
 =0A=
 	/* If Intr is because of Tx Traffic */=0A=
 	if (reason & GEN_INTR_TXTRAFFIC) {=0A=
-		txIntrHandler(sp);=0A=
+		tx_intr_handler(sp);=0A=
 	}=0A=
 =0A=
 	/* If Intr is because of an error */=0A=
 	if (reason & (GEN_ERROR_INTR))=0A=
-		alarmIntrHandler(sp);=0A=
+		alarm_intr_handler(sp);=0A=
 =0A=
 #ifdef CONFIG_S2IO_NAPI=0A=
 	if (reason & GEN_INTR_RXTRAFFIC) {=0A=
 		if (netif_rx_schedule_prep(dev)) {=0A=
-			en_dis_able_NicIntrs(sp, RX_TRAFFIC_INTR,=0A=
-					     DISABLE_INTRS);=0A=
-			/* We retake the snap shot of the general interrupt =0A=
-			 * register.=0A=
-			 */=0A=
-			general_mask =3D readq(&bar0->general_int_mask);=0A=
+			en_dis_able_nic_intrs(sp, RX_TRAFFIC_INTR,=0A=
+					      DISABLE_INTRS);=0A=
 			__netif_rx_schedule(dev);=0A=
 		}=0A=
 	}=0A=
 #else=0A=
 	/* If Intr is because of Rx Traffic */=0A=
 	if (reason & GEN_INTR_RXTRAFFIC) {=0A=
-		rxIntrHandler(sp);=0A=
+		rx_intr_handler(sp);=0A=
 	}=0A=
 #endif=0A=
 =0A=
-/* If the Rx buffer count is below the panic threshold then reallocate =
the=0A=
- * buffers from the interrupt handler itself, else schedule a tasklet =
to =0A=
- * reallocate the buffers.=0A=
- */=0A=
-#if 1=0A=
-	{=0A=
-	int i;=0A=
-=0A=
+	/* =0A=
+	 * If the Rx buffer count is below the panic threshold then =0A=
+	 * reallocate the buffers from the interrupt handler itself, =0A=
+	 * else schedule a tasklet to reallocate the buffers.=0A=
+	 */=0A=
+#ifndef CONFIG_S2IO_NAPI=0A=
 	for (i =3D 0; i < config->RxRingNum; i++) {=0A=
 		int rxb_size =3D atomic_read(&sp->rx_bufs_left[i]);=0A=
 		int level =3D rx_buffer_level(sp, rxb_size, i);=0A=
 =0A=
 		if ((level =3D=3D PANIC) && (!TASKLET_IN_USE)) {=0A=
-			int ret;=0A=
-=0A=
-			DBG_PRINT(ERR_DBG, "%s: Rx BD hit ", dev->name);=0A=
-			DBG_PRINT(ERR_DBG, "PANIC levels\n");=0A=
+			DBG_PRINT(INTR_DBG, "%s: Rx BD hit ", dev->name);=0A=
+			DBG_PRINT(INTR_DBG, "PANIC levels\n");=0A=
 			if ((ret =3D fill_rx_buffers(sp, i)) =3D=3D -ENOMEM) {=0A=
 				DBG_PRINT(ERR_DBG, "%s:Out of memory",=0A=
 					  dev->name);=0A=
 				DBG_PRINT(ERR_DBG, " in ISR!!\n");=0A=
-				writeq(general_mask,=0A=
-				       &bar0->general_int_mask);=0A=
-				spin_unlock(&sp->isr_lock);=0A=
+				clear_bit(0,=0A=
+					  (unsigned long *) (&sp->=0A=
+							     tasklet_status));=0A=
 				return IRQ_HANDLED;=0A=
 			}=0A=
 			clear_bit(0,=0A=
@@ -2432,28 +3062,21 @@=0A=
 		}=0A=
 =0A=
 	}=0A=
-=0A=
-	}=0A=
-#else=0A=
-	tasklet_schedule(&sp->task);=0A=
 #endif=0A=
 =0A=
-	/* Unmask all the previously enabled interrupts on the NIC */=0A=
-	writeq(general_mask, &bar0->general_int_mask);=0A=
-=0A=
-	spin_unlock(&sp->isr_lock);=0A=
 	return IRQ_HANDLED;=0A=
 }=0A=
 =0A=
-/*=0A=
- *  Input Argument/s: =0A=
- *  dev - pointer to the device structure.=0A=
- *  Return value:=0A=
- *  pointer to the updated net_device_stats structure.=0A=
+/**=0A=
+ *  s2io_get_stats - Updates the device statistics structure. =0A=
+ *  @dev : pointer to the device structure.=0A=
  *  Description:=0A=
  *  This function updates the device statistics structure in the =
s2io_nic =0A=
  *  structure and returns a pointer to the same.=0A=
+ *  Return value:=0A=
+ *  pointer to the updated net_device_stats structure.=0A=
  */=0A=
+=0A=
 struct net_device_stats *s2io_get_stats(struct net_device *dev)=0A=
 {=0A=
 	nic_t *sp =3D dev->priv;=0A=
@@ -2463,27 +3086,28 @@=0A=
 	mac_control =3D &sp->mac_control;=0A=
 	config =3D &sp->config;=0A=
 =0A=
-	sp->stats.tx_errors =3D mac_control->StatsInfo->tmac_any_err_frms;=0A=
-	sp->stats.rx_errors =3D mac_control->StatsInfo->rmac_drop_frms;=0A=
-	sp->stats.multicast =3D mac_control->StatsInfo->rmac_vld_mcst_frms;=0A=
+	sp->stats.tx_errors =3D mac_control->stats_info->tmac_any_err_frms;=0A=
+	sp->stats.rx_errors =3D mac_control->stats_info->rmac_drop_frms;=0A=
+	sp->stats.multicast =3D mac_control->stats_info->rmac_vld_mcst_frms;=0A=
 	sp->stats.rx_length_errors =3D=0A=
-	    mac_control->StatsInfo->rmac_long_frms;=0A=
+	    mac_control->stats_info->rmac_long_frms;=0A=
 =0A=
 	return (&sp->stats);=0A=
 }=0A=
 =0A=
-/*=0A=
- *  Input Argument/s: =0A=
- *  dev - pointer to the device structure=0A=
- *  Return value:=0A=
- *  void.=0A=
+/**=0A=
+ *  s2io_set_multicast - entry point for multicast address =
enable/disable.=0A=
+ *  @dev : pointer to the device structure=0A=
  *  Description:=0A=
  *  This function is a driver entry point which gets called by the =
kernel =0A=
  *  whenever multicast addresses must be enabled/disabled. This also =
gets =0A=
  *  called to set/reset promiscuous mode. Depending on the deivce flag, =
we=0A=
  *  determine, if multicast address must be enabled or if promiscuous =
mode=0A=
  *  is to be disabled etc.=0A=
+ *  Return value:=0A=
+ *  void.=0A=
  */=0A=
+=0A=
 static void s2io_set_multicast(struct net_device *dev)=0A=
 {=0A=
 	int i, j, prev_cnt;=0A=
@@ -2506,7 +3130,7 @@=0A=
 		    RMAC_ADDR_CMD_MEM_OFFSET(MAC_MC_ALL_MC_ADDR_OFFSET);=0A=
 		writeq(val64, &bar0->rmac_addr_cmd_mem);=0A=
 		/* Wait till command completes */=0A=
-		waitForCmdComplete(sp);=0A=
+		wait_for_cmd_complete(sp);=0A=
 =0A=
 		sp->m_cast_flg =3D 1;=0A=
 		sp->all_multi_pos =3D MAC_MC_ALL_MC_ADDR_OFFSET;=0A=
@@ -2519,7 +3143,7 @@=0A=
 		    RMAC_ADDR_CMD_MEM_OFFSET(sp->all_multi_pos);=0A=
 		writeq(val64, &bar0->rmac_addr_cmd_mem);=0A=
 		/* Wait till command completes */=0A=
-		waitForCmdComplete(sp);=0A=
+		wait_for_cmd_complete(sp);=0A=
 =0A=
 		sp->m_cast_flg =3D 0;=0A=
 		sp->all_multi_pos =3D 0;=0A=
@@ -2582,7 +3206,7 @@=0A=
 			writeq(val64, &bar0->rmac_addr_cmd_mem);=0A=
 =0A=
 			/* Wait for command completes */=0A=
-			if (waitForCmdComplete(sp)) {=0A=
+			if (wait_for_cmd_complete(sp)) {=0A=
 				DBG_PRINT(ERR_DBG, "%s: Adding ",=0A=
 					  dev->name);=0A=
 				DBG_PRINT(ERR_DBG, "Multicasts failed\n");=0A=
@@ -2609,7 +3233,7 @@=0A=
 			writeq(val64, &bar0->rmac_addr_cmd_mem);=0A=
 =0A=
 			/* Wait for command completes */=0A=
-			if (waitForCmdComplete(sp)) {=0A=
+			if (wait_for_cmd_complete(sp)) {=0A=
 				DBG_PRINT(ERR_DBG, "%s: Adding ",=0A=
 					  dev->name);=0A=
 				DBG_PRINT(ERR_DBG, "Multicasts failed\n");=0A=
@@ -2619,17 +3243,16 @@=0A=
 	}=0A=
 }=0A=
 =0A=
-/*=0A=
- *  Input Argument/s: =0A=
- *  dev - pointer to the device structure.=0A=
- *  new_mac - a uchar pointer to the new mac address which is to be set.=0A=
- *  Return value:=0A=
- *  SUCCESS on success and an appropriate (-)ve integer as defined in =
errno.h=0A=
- *  file on failure.=0A=
- *  Description:=0A=
- *  This procedure will program the Xframe to receive frames with new=0A=
- *  Mac Address=0A=
+/**=0A=
+ *  s2io_set_mac_addr - Programs the Xframe mac address =0A=
+ *  @dev : pointer to the device structure.=0A=
+ *  @addr: a uchar pointer to the new mac address which is to be set.=0A=
+ *  Description : This procedure will program the Xframe to receive =0A=
+ *  frames with new Mac Address=0A=
+ *  Return value: SUCCESS on success and an appropriate (-)ve integer =0A=
+ *  as defined in errno.h file on failure.=0A=
  */=0A=
+=0A=
 int s2io_set_mac_addr(struct net_device *dev, u8 * addr)=0A=
 {=0A=
 	nic_t *sp =3D dev->priv;=0A=
@@ -2655,7 +3278,7 @@=0A=
 	    RMAC_ADDR_CMD_MEM_OFFSET(0);=0A=
 	writeq(val64, &bar0->rmac_addr_cmd_mem);=0A=
 	/* Wait till command completes */=0A=
-	if (waitForCmdComplete(sp)) {=0A=
+	if (wait_for_cmd_complete(sp)) {=0A=
 		DBG_PRINT(ERR_DBG, "%s: set_mac_addr failed\n", dev->name);=0A=
 		return FAILURE;=0A=
 	}=0A=
@@ -2663,18 +3286,18 @@=0A=
 	return SUCCESS;=0A=
 }=0A=
 =0A=
-/*=0A=
- * Input Argument/s: =0A=
- *  sp - private member of the device structure, which is a pointer to =
the =0A=
- *   	s2io_nic structure.=0A=
- *  info - pointer to the structure with parameters given by ethtool to =
set=0A=
- *  link information.=0A=
- * Return value:=0A=
- *  0 on success.=0A=
+/**=0A=
+ * s2io_ethtool_sset - Sets different link parameters. =0A=
+ * @sp : private member of the device structure, which is a pointer to =
the  * s2io_nic structure.=0A=
+ * @info: pointer to the structure with parameters given by ethtool to =
set=0A=
+ * link information.=0A=
  * Description:=0A=
- *  The function sets different link parameters provided by the user =
onto =0A=
- *  the NIC.=0A=
- */=0A=
+ * The function sets different link parameters provided by the user =
onto =0A=
+ * the NIC.=0A=
+ * Return value:=0A=
+ * 0 on success.=0A=
+*/=0A=
+=0A=
 static int s2io_ethtool_sset(struct net_device *dev,=0A=
 			     struct ethtool_cmd *info)=0A=
 {=0A=
@@ -2690,17 +3313,18 @@=0A=
 	return 0;=0A=
 }=0A=
 =0A=
-/*=0A=
- * Input Argument/s: =0A=
- *  sp - private member of the device structure, which is a pointer to =
the =0A=
- *   	s2io_nic structure.=0A=
- *  info - pointer to the structure with parameters given by ethtool to =
return=0A=
- *  link information.=0A=
- * Return value:=0A=
- *  void=0A=
+/**=0A=
+ * s2io_ethtol_gset - Return link specific information. =0A=
+ * @sp : private member of the device structure, pointer to the=0A=
+ *      s2io_nic structure.=0A=
+ * @info : pointer to the structure with parameters given by ethtool=0A=
+ * to return link information.=0A=
  * Description:=0A=
- *  Returns link specefic information like speed, duplex etc.. to =
ethtool.=0A=
+ * Returns link specefic information like speed, duplex etc.. to =
ethtool.=0A=
+ * Return value :=0A=
+ * return 0 on success.=0A=
  */=0A=
+=0A=
 int s2io_ethtool_gset(struct net_device *dev, struct ethtool_cmd *info)=0A=
 {=0A=
 	nic_t *sp =3D dev->priv;=0A=
@@ -2721,17 +3345,18 @@=0A=
 	return 0;=0A=
 }=0A=
 =0A=
-/*=0A=
- * Input Argument/s: =0A=
- *  sp - private member of the device structure, which is a pointer to =
the =0A=
- *   	s2io_nic structure.=0A=
- *  info - pointer to the structure with parameters given by ethtool to =
return=0A=
- *  driver information.=0A=
+/**=0A=
+ * s2io_ethtool_gdrvinfo - Returns driver specific information. =0A=
+ * @sp : private member of the device structure, which is a pointer to =
the =0A=
+ * s2io_nic structure.=0A=
+ * @info : pointer to the structure with parameters given by ethtool to=0A=
+ * return driver information.=0A=
+ * Description:=0A=
+ * Returns driver specefic information like name, version etc.. to =
ethtool.=0A=
  * Return value:=0A=
  *  void=0A=
- * Description:=0A=
- *  Returns driver specefic information like name, version etc.. to =
ethtool.=0A=
  */=0A=
+=0A=
 static void s2io_ethtool_gdrvinfo(struct net_device *dev,=0A=
 				  struct ethtool_drvinfo *info)=0A=
 {=0A=
@@ -2748,19 +3373,20 @@=0A=
 	info->n_stats =3D S2IO_STAT_LEN;=0A=
 }=0A=
 =0A=
-/*=0A=
- * Input Argument/s: =0A=
- *  sp - private member of the device structure, which is a pointer to =
the =0A=
- *   	s2io_nic structure.=0A=
- *  regs - pointer to the structure with parameters given by ethtool =
for =0A=
+/**=0A=
+ *  s2io_ethtool_gregs - dumps the entire space of Xfame into te buffer.=0A=
+ *  @sp: private member of the device structure, which is a pointer to =
the =0A=
+ *  s2io_nic structure.=0A=
+ *  @regs : pointer to the structure with parameters given by ethtool =
for =0A=
  *  dumping the registers.=0A=
- *  reg_space - The input argumnet into which all the registers are =
dumped.=0A=
- * Return value:=0A=
- *  void=0A=
- * Description:=0A=
- *  Dumps the entire register space of xFrame NIC into the user given =
buffer =0A=
- *  area.=0A=
- */=0A=
+ *  @reg_space: The input argumnet into which all the registers are =
dumped.=0A=
+ *  Description:=0A=
+ *  Dumps the entire register space of xFrame NIC into the user given=0A=
+ *  buffer area.=0A=
+ * Return value :=0A=
+ * void .=0A=
+*/=0A=
+=0A=
 static void s2io_ethtool_gregs(struct net_device *dev,=0A=
 			       struct ethtool_regs *regs, void *space)=0A=
 {=0A=
@@ -2778,17 +3404,15 @@=0A=
 	}=0A=
 }=0A=
 =0A=
-/*=0A=
- * Input Argument/s: =0A=
- *  data - address of the private member of the device structure, which =0A=
+/**=0A=
+ *  s2io_phy_id  - timer function that alternates adapter LED.=0A=
+ *  @data : address of the private member of the device structure, =
which =0A=
  *  is a pointer to the s2io_nic structure, provided as an u32.=0A=
- * Return value:=0A=
- *  void=0A=
- * Description:=0A=
- *  This is actually the timer function that alternates the adapter LED =
bit=0A=
- *  of the adapter control bit to set/reset every time on invocation.=0A=
- *  The timer is set for 1/2 a second, hence tha NIC blinks once every =
second.=0A=
- */=0A=
+ * Description: This is actually the timer function that alternates the =0A=
+ * adapter LED bit of the adapter control bit to set/reset every time =
on =0A=
+ * invocation. The timer is set for 1/2 a second, hence tha NIC blinks =0A=
+ *  once every second.=0A=
+*/=0A=
 static void s2io_phy_id(unsigned long data)=0A=
 {=0A=
 	nic_t *sp =3D (nic_t *) data;=0A=
@@ -2810,28 +3434,30 @@=0A=
 	mod_timer(&sp->id_timer, jiffies + HZ / 2);=0A=
 }=0A=
 =0A=
-/*=0A=
- * Input Argument/s: =0A=
- *  sp - private member of the device structure, which is a pointer to =
the =0A=
- *   	s2io_nic structure.=0A=
- *  id - pointer to the structure with identification parameters given =
by =0A=
- *  ethtool.=0A=
+/**=0A=
+ * s2io_ethtool_idnic - To physically ientify the nic on the system.=0A=
+ * @sp : private member of the device structure, which is a pointer to =
the=0A=
+ * s2io_nic structure.=0A=
+ * @id : pointer to the structure with identification parameters given =
by =0A=
+ * ethtool.=0A=
+ * Description: Used to physically identify the NIC on the system.=0A=
+ * The Link LED will blink for a time specified by the user for =0A=
+ * identification.=0A=
+ * NOTE: The Link has to be Up to be able to blink the LED. Hence =0A=
+ * identification is possible only if it's link is up.=0A=
  * Return value:=0A=
- *  int , returns '0' on success=0A=
- * Description:=0A=
- *  Used to physically identify the NIC on the system. The Link LED =
will blink=0A=
- *  for a time specified by the user for identification.=0A=
- *  NOTE: The Link has to be Up to be able to blink the LED. Hence =0A=
- *  identification is possible only if it's link is up.=0A=
+ * int , returns 0 on success=0A=
  */=0A=
+=0A=
 static int s2io_ethtool_idnic(struct net_device *dev, u32 data)=0A=
 {=0A=
-	u64 val64 =3D 0;=0A=
+	u64 val64 =3D 0, last_gpio_ctrl_val;=0A=
 	nic_t *sp =3D dev->priv;=0A=
 	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) sp->bar0;=0A=
 	u16 subid;=0A=
 =0A=
 	subid =3D sp->pdev->subsystem_device;=0A=
+	last_gpio_ctrl_val =3D readq(&bar0->gpio_control);=0A=
 	if ((subid & 0xFF) < 0x07) {=0A=
 		val64 =3D readq(&bar0->adapter_control);=0A=
 		if (!(val64 & ADAPTER_CNTL_EN)) {=0A=
@@ -2853,18 +3479,22 @@=0A=
 		schedule_timeout(MAX_SCHEDULE_TIMEOUT);=0A=
 	del_timer_sync(&sp->id_timer);=0A=
 =0A=
+	if (CARDS_WITH_FAULTY_LINK_INDICATORS(subid)) {=0A=
+		writeq(last_gpio_ctrl_val, &bar0->gpio_control);=0A=
+		last_gpio_ctrl_val =3D readq(&bar0->gpio_control);=0A=
+	}=0A=
+=0A=
 	return 0;=0A=
 }=0A=
 =0A=
-/*=0A=
- * Input Argument/s: =0A=
- *  sp - private member of the device structure, which is a pointer to =
the =0A=
- *   	s2io_nic structure.=0A=
- *  ep - pointer to the structure with pause parameters given by =
ethtool.=0A=
+/**=0A=
+ * s2io_ethtool_getpause_data -Pause frame frame generation and =
reception.=0A=
+ * @sp : private member of the device structure, which is a pointer to =
the  * s2io_nic structure.=0A=
+ * @ep : pointer to the structure with pause parameters given by =
ethtool.=0A=
+ * Description:=0A=
+ * Returns the Pause frame generation and reception capability of the =
NIC.=0A=
  * Return value:=0A=
  *  void=0A=
- * Description:=0A=
- *  Returns the Pause frame generation and reception capability of the =
NIC.=0A=
  */=0A=
 static void s2io_ethtool_getpause_data(struct net_device *dev,=0A=
 				       struct ethtool_pauseparam *ep)=0A=
@@ -2881,17 +3511,18 @@=0A=
 	ep->autoneg =3D FALSE;=0A=
 }=0A=
 =0A=
-/*=0A=
- * Input Argument/s: =0A=
- * sp - private member of the device structure, which is a pointer to =
the =0A=
- *   	s2io_nic structure.=0A=
- * ep - pointer to the structure with pause parameters given by ethtool.=0A=
- * Return value:=0A=
- * int, returns '0' on Success=0A=
+/**=0A=
+ * s2io_ethtool-setpause_data -  set/reset pause frame generation.=0A=
+ * @sp : private member of the device structure, which is a pointer to =
the =0A=
+ *      s2io_nic structure.=0A=
+ * @ep : pointer to the structure with pause parameters given by =
ethtool.=0A=
  * Description:=0A=
- * It can be used to set or reset Pause frame generation or reception =
support =0A=
- * of the NIC.=0A=
+ * It can be used to set or reset Pause frame generation or reception=0A=
+ * support of the NIC.=0A=
+ * Return value:=0A=
+ * int, returns 0 on Success=0A=
  */=0A=
+=0A=
 int s2io_ethtool_setpause_data(struct net_device *dev,=0A=
 			       struct ethtool_pauseparam *ep)=0A=
 {=0A=
@@ -2912,35 +3543,40 @@=0A=
 	return 0;=0A=
 }=0A=
 =0A=
-/*=0A=
- * Input Argument/s: =0A=
- *  sp - private member of the device structure, which is a pointer to =
the =0A=
- *   	s2io_nic structure.=0A=
- *  off - offset at which the data must be written=0A=
- * Return value:=0A=
- *  -1 on failure and the value read from the Eeprom if successful.=0A=
+/**=0A=
+ * read_eeprom - reads 4 bytes of data from user given offset.=0A=
+ * @sp : private member of the device structure, which is a pointer to =
the =0A=
+ *      s2io_nic structure.=0A=
+ * @off : offset at which the data must be written=0A=
+ * @data : Its an output parameter where the data read at the given=0A=
+ * 	offset is stored.=0A=
  * Description:=0A=
- *  Will read 4 bytes of data from the user given offset and return the =0A=
- *  read data.=0A=
+ * Will read 4 bytes of data from the user given offset and return the =0A=
+ * read data.=0A=
  * NOTE: Will allow to read only part of the EEPROM visible through the=0A=
- * 	 I2C bus.=0A=
+ *   I2C bus.=0A=
+ * Return value:=0A=
+ *  -1 on failure and 0 on success.=0A=
  */=0A=
+=0A=
 #define S2IO_DEV_ID		5=0A=
-static u32 readEeprom(nic_t * sp, int off)=0A=
+static int read_eeprom(nic_t * sp, int off, u32 * data)=0A=
 {=0A=
-	u32 data =3D -1, exit_cnt =3D 0;=0A=
+	int ret =3D -1;=0A=
+	u32 exit_cnt =3D 0;=0A=
 	u64 val64;=0A=
 	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) sp->bar0;=0A=
 =0A=
 	val64 =3D I2C_CONTROL_DEV_ID(S2IO_DEV_ID) | I2C_CONTROL_ADDR(off) |=0A=
 	    I2C_CONTROL_BYTE_CNT(0x3) | I2C_CONTROL_READ |=0A=
 	    I2C_CONTROL_CNTL_START;=0A=
-	writeq(val64, &bar0->i2c_control);=0A=
+	SPECIAL_REG_WRITE(val64, &bar0->i2c_control, LF);=0A=
 =0A=
 	while (exit_cnt < 5) {=0A=
 		val64 =3D readq(&bar0->i2c_control);=0A=
 		if (I2C_CONTROL_CNTL_END(val64)) {=0A=
-			data =3D I2C_CONTROL_GET_DATA(val64);=0A=
+			*data =3D I2C_CONTROL_GET_DATA(val64);=0A=
+			ret =3D 0;=0A=
 			break;=0A=
 		}=0A=
 		set_current_state(TASK_UNINTERRUPTIBLE);=0A=
@@ -2948,24 +3584,25 @@=0A=
 		exit_cnt++;=0A=
 	}=0A=
 =0A=
-	return data;=0A=
+	return ret;=0A=
 }=0A=
 =0A=
-/*=0A=
- * Input Argument/s: =0A=
- *  sp - private member of the device structure, which is a pointer to =
the =0A=
- *   	s2io_nic structure.=0A=
- *  off - offset at which the data must be written=0A=
- *  data - The data that is to be written=0A=
- *  cnt - Number of bytes of the data that are actually to be written =
into =0A=
+/**=0A=
+ *  write_eeprom - actually writes the relevant part of the data value.=0A=
+ *  @sp : private member of the device structure, which is a pointer to =
the=0A=
+ *       s2io_nic structure.=0A=
+ *  @off : offset at which the data must be written=0A=
+ *  @data : The data that is to be written=0A=
+ *  @cnt : Number of bytes of the data that are actually to be written =
into =0A=
  *  the Eeprom. (max of 3)=0A=
- * Return value:=0A=
- *  '0' on success, -1 on failure.=0A=
  * Description:=0A=
  *  Actually writes the relevant part of the data value into the Eeprom=0A=
  *  through the I2C bus.=0A=
+ * Return value:=0A=
+ *  0 on success, -1 on failure.=0A=
  */=0A=
-static int writeEeprom(nic_t * sp, int off, u32 data, int cnt)=0A=
+=0A=
+static int write_eeprom(nic_t * sp, int off, u32 data, int cnt)=0A=
 {=0A=
 	int exit_cnt =3D 0, ret =3D -1;=0A=
 	u64 val64;=0A=
@@ -2974,7 +3611,7 @@=0A=
 	val64 =3D I2C_CONTROL_DEV_ID(S2IO_DEV_ID) | I2C_CONTROL_ADDR(off) |=0A=
 	    I2C_CONTROL_BYTE_CNT(cnt) | I2C_CONTROL_SET_DATA(data) |=0A=
 	    I2C_CONTROL_CNTL_START;=0A=
-	writeq(val64, &bar0->i2c_control);=0A=
+	SPECIAL_REG_WRITE(val64, &bar0->i2c_control, LF);=0A=
 =0A=
 	while (exit_cnt < 5) {=0A=
 		val64 =3D readq(&bar0->i2c_control);=0A=
@@ -2991,39 +3628,19 @@=0A=
 	return ret;=0A=
 }=0A=
 =0A=
-/* =0A=
- * A helper function used to invert the 4 byte u32 data field=0A=
- * byte by byte. This will be used by the Read Eeprom function=0A=
- * for display purposes.=0A=
- */=0A=
-u32 inv(u32 data)=0A=
-{=0A=
-	static u32 ret =3D 0;=0A=
-=0A=
-	if (data) {=0A=
-		u8 c =3D data;=0A=
-		ret =3D ((ret << 8) + c);=0A=
-		data >>=3D 8;=0A=
-		inv(data);=0A=
-	}=0A=
-=0A=
-	return ret;=0A=
-}=0A=
-=0A=
-/*=0A=
- * Input Argument/s: =0A=
- *  sp - private member of the device structure, which is a pointer to =
the =0A=
- *   	s2io_nic structure.=0A=
- *  eeprom - pointer to the user level structure provided by ethtool, =0A=
- *   containing all relevant information.=0A=
- *  data_buf - user defined value to be written into Eeprom.=0A=
- * Return value:=0A=
- *  int  '0' on success=0A=
- * Description:=0A=
- *  Reads the values stored in the Eeprom at given offset for a given =
length.=0A=
- *  Stores these values int the input argument data buffer 'data_buf' =
and=0A=
- *  returns these to the caller (ethtool.)=0A=
+/**=0A=
+ *  s2io_ethtool_geeprom  - reads the value stored in the Eeprom.=0A=
+ *  @sp : private member of the device structure, which is a pointer to =
the *       s2io_nic structure.=0A=
+ *  @eeprom : pointer to the user level structure provided by ethtool, =0A=
+ *  containing all relevant information.=0A=
+ *  @data_buf : user defined value to be written into Eeprom.=0A=
+ *  Description: Reads the values stored in the Eeprom at given offset=0A=
+ *  for a given length. Stores these values int the input argument data=0A=
+ *  buffer 'data_buf' and returns these to the caller (ethtool.)=0A=
+ *  Return value:=0A=
+ *  int  0 on success=0A=
  */=0A=
+=0A=
 int s2io_ethtool_geeprom(struct net_device *dev,=0A=
 			 struct ethtool_eeprom *eeprom, u8 * data_buf)=0A=
 {=0A=
@@ -3036,30 +3653,30 @@=0A=
 		eeprom->len =3D XENA_EEPROM_SPACE - eeprom->offset;=0A=
 =0A=
 	for (i =3D 0; i < eeprom->len; i +=3D 4) {=0A=
-		data =3D readEeprom(sp, eeprom->offset + i);=0A=
-		if (data < 0) {=0A=
+		if (read_eeprom(sp, (eeprom->offset + i), &data)) {=0A=
 			DBG_PRINT(ERR_DBG, "Read of EEPROM failed\n");=0A=
 			return -EFAULT;=0A=
 		}=0A=
-		valid =3D inv(data);=0A=
+		valid =3D INV(data);=0A=
 		memcpy((data_buf + i), &valid, 4);=0A=
 	}=0A=
 	return 0;=0A=
 }=0A=
 =0A=
-/*=0A=
- * Input Argument/s: =0A=
- *  sp - private member of the device structure, which is a pointer to =
the =0A=
- *   	s2io_nic structure.=0A=
- *  eeprom - pointer to the user level structure provided by ethtool, =0A=
- *   containing all relevant information.=0A=
- *  data_buf - user defined value to be written into Eeprom.=0A=
- * Return value:=0A=
- *  '0' on success, -EFAULT on failure.=0A=
- * Description:=0A=
+/**=0A=
+ *  s2io_ethtool_seeprom - tries to write the user provided value in =
Eeprom=0A=
+ *  @sp : private member of the device structure, which is a pointer to =
the=0A=
+ *  s2io_nic structure.=0A=
+ *  @eeprom : pointer to the user level structure provided by ethtool, =0A=
+ *  containing all relevant information.=0A=
+ *  @data_buf ; user defined value to be written into Eeprom.=0A=
+ *  Description:=0A=
  *  Tries to write the user provided value in the Eeprom, at the offset=0A=
  *  given by the user.=0A=
+ *  Return value:=0A=
+ *  0 on success, -EFAULT on failure.=0A=
  */=0A=
+=0A=
 static int s2io_ethtool_seeprom(struct net_device *dev,=0A=
 				struct ethtool_eeprom *eeprom,=0A=
 				u8 * data_buf)=0A=
@@ -3083,7 +3700,7 @@=0A=
 		} else=0A=
 			valid =3D data;=0A=
 =0A=
-		if (writeEeprom(sp, (eeprom->offset + cnt), valid, 0)) {=0A=
+		if (write_eeprom(sp, (eeprom->offset + cnt), valid, 0)) {=0A=
 			DBG_PRINT(ERR_DBG,=0A=
 				  "ETHTOOL_WRITE_EEPROM Err: Cannot ");=0A=
 			DBG_PRINT(ERR_DBG,=0A=
@@ -3097,19 +3714,20 @@=0A=
 	return 0;=0A=
 }=0A=
 =0A=
-/*=0A=
- * Input Argument/s: =0A=
- *  sp - private member of the device structure, which is a pointer to =
the =0A=
- *   	s2io_nic structure.=0A=
- *  data - variable that returns the result of each of the test =
conducted by =0A=
- *  	the driver.=0A=
- * Return value:=0A=
- *  '0' on success.=0A=
+/**=0A=
+ * s2io_register_test - reads and writes into all clock domains. =0A=
+ * @sp : private member of the device structure, which is a pointer to =
the =0A=
+ * s2io_nic structure.=0A=
+ * @data : variable that returns the result of each of the test =
conducted b=0A=
+ * by the driver.=0A=
  * Description:=0A=
- *  Read and write into all clock domains. The NIC has 3 clock domains,=0A=
- *  see that registers in all the three regions are accessible.=0A=
+ * Read and write into all clock domains. The NIC has 3 clock domains,=0A=
+ * see that registers in all the three regions are accessible.=0A=
+ * Return value:=0A=
+ * 0 on success.=0A=
  */=0A=
-static int s2io_registerTest(nic_t * sp, uint64_t * data)=0A=
+=0A=
+static int s2io_register_test(nic_t * sp, uint64_t * data)=0A=
 {=0A=
 	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) sp->bar0;=0A=
 	u64 val64 =3D 0;=0A=
@@ -3159,88 +3777,91 @@=0A=
 	return 0;=0A=
 }=0A=
 =0A=
-/*=0A=
- * Input Argument/s: =0A=
- *  sp - private member of the device structure, which is a pointer to =
the =0A=
- *   	s2io_nic structure.=0A=
- *  data - variable that returns the result of each of the test =
conducted by =0A=
- *  	the driver.=0A=
- * Return value:=0A=
- *  '0' on success.=0A=
+/**=0A=
+ * s2io_eeprom_test - to verify that EEprom in the xena can be =
programmed. =0A=
+ * @sp : private member of the device structure, which is a pointer to =
the=0A=
+ * s2io_nic structure.=0A=
+ * @data:variable that returns the result of each of the test conducted =
by=0A=
+ * the driver.=0A=
  * Description:=0A=
- *  Verify that EEPROM in the xena can be programmed using I2C_CONTROL =0A=
- *  register.=0A=
+ * Verify that EEPROM in the xena can be programmed using I2C_CONTROL =0A=
+ * register.=0A=
+ * Return value:=0A=
+ * 0 on success.=0A=
  */=0A=
-static int s2io_eepromTest(nic_t * sp, uint64_t * data)=0A=
+=0A=
+static int s2io_eeprom_test(nic_t * sp, uint64_t * data)=0A=
 {=0A=
-	int fail =3D 0, ret_data;=0A=
+	int fail =3D 0;=0A=
+	u32 ret_data;=0A=
 =0A=
 	/* Test Write Error at offset 0 */=0A=
-	if (!writeEeprom(sp, 0, 0, 3))=0A=
+	if (!write_eeprom(sp, 0, 0, 3))=0A=
 		fail =3D 1;=0A=
 =0A=
 	/* Test Write at offset 4f0 */=0A=
-	if (writeEeprom(sp, 0x4F0, 0x01234567, 3))=0A=
+	if (write_eeprom(sp, 0x4F0, 0x01234567, 3))=0A=
 		fail =3D 1;=0A=
-	if ((ret_data =3D readEeprom(sp, 0x4f0)) < 0)=0A=
+	if (read_eeprom(sp, 0x4F0, &ret_data))=0A=
 		fail =3D 1;=0A=
 =0A=
 	if (ret_data !=3D 0x01234567)=0A=
 		fail =3D 1;=0A=
 =0A=
 	/* Reset the EEPROM data go FFFF */=0A=
-	writeEeprom(sp, 0x4F0, 0xFFFFFFFF, 3);=0A=
+	write_eeprom(sp, 0x4F0, 0xFFFFFFFF, 3);=0A=
 =0A=
 	/* Test Write Request Error at offset 0x7c */=0A=
-	if (!writeEeprom(sp, 0x07C, 0, 3))=0A=
+	if (!write_eeprom(sp, 0x07C, 0, 3))=0A=
 		fail =3D 1;=0A=
 =0A=
 	/* Test Write Request at offset 0x7fc */=0A=
-	if (writeEeprom(sp, 0x7FC, 0x01234567, 3))=0A=
+	if (write_eeprom(sp, 0x7FC, 0x01234567, 3))=0A=
 		fail =3D 1;=0A=
-	if ((ret_data =3D readEeprom(sp, 0x7FC)) < 0)=0A=
+	if (read_eeprom(sp, 0x7FC, &ret_data))=0A=
 		fail =3D 1;=0A=
 =0A=
 	if (ret_data !=3D 0x01234567)=0A=
 		fail =3D 1;=0A=
 =0A=
 	/* Reset the EEPROM data go FFFF */=0A=
-	writeEeprom(sp, 0x7FC, 0xFFFFFFFF, 3);=0A=
+	write_eeprom(sp, 0x7FC, 0xFFFFFFFF, 3);=0A=
 =0A=
 	/* Test Write Error at offset 0x80 */=0A=
-	if (!writeEeprom(sp, 0x080, 0, 3))=0A=
+	if (!write_eeprom(sp, 0x080, 0, 3))=0A=
 		fail =3D 1;=0A=
 =0A=
 	/* Test Write Error at offset 0xfc */=0A=
-	if (!writeEeprom(sp, 0x0FC, 0, 3))=0A=
+	if (!write_eeprom(sp, 0x0FC, 0, 3))=0A=
 		fail =3D 1;=0A=
 =0A=
 	/* Test Write Error at offset 0x100 */=0A=
-	if (!writeEeprom(sp, 0x100, 0, 3))=0A=
+	if (!write_eeprom(sp, 0x100, 0, 3))=0A=
 		fail =3D 1;=0A=
 =0A=
 	/* Test Write Error at offset 4ec */=0A=
-	if (!writeEeprom(sp, 0x4EC, 0, 3))=0A=
+	if (!write_eeprom(sp, 0x4EC, 0, 3))=0A=
 		fail =3D 1;=0A=
 =0A=
 	*data =3D fail;=0A=
 	return 0;=0A=
 }=0A=
 =0A=
-/*=0A=
- * Input Argument/s: =0A=
- *  sp - private member of the device structure, which is a pointer to =
the =0A=
- *   	s2io_nic structure.=0A=
- *  data - variable that returns the result of each of the test =
conducted by =0A=
- *  	the driver.=0A=
- * Return value:=0A=
- *  '0' on success and -1 on failure.=0A=
+/**=0A=
+ * s2io_bist_test - invokes the MemBist test of the card .=0A=
+ * @sp : private member of the device structure, which is a pointer to =
the =0A=
+ * s2io_nic structure.=0A=
+ * @data:variable that returns the result of each of the test conducted =
by =0A=
+ * the driver.=0A=
  * Description:=0A=
- *  This invokes the MemBist test of the card. We give around=0A=
- *  2 secs time for the Test to complete. If it's still not complete=0A=
- *  within this peiod, we consider that the test failed. =0A=
+ * This invokes the MemBist test of the card. We give around=0A=
+ * 2 secs time for the Test to complete. If it's still not complete=0A=
+ * within this peiod, we consider that the test failed. =0A=
+ * Return value:=0A=
+ * 0 on success and -1 on failure.=0A=
  */=0A=
-static int s2io_bistTest(nic_t * sp, uint64_t * data)=0A=
+=0A=
+static int s2io_bist_test(nic_t * sp, uint64_t * data)=0A=
 {=0A=
 	u8 bist =3D 0;=0A=
 	int cnt =3D 0, ret =3D -1;=0A=
@@ -3264,19 +3885,20 @@=0A=
 	return ret;=0A=
 }=0A=
 =0A=
-/*=0A=
- * Input Argument/s: =0A=
- *  sp - private member of the device structure, which is a pointer to =
the =0A=
- *   	s2io_nic structure.=0A=
- *  data - variable that returns the result of each of the test =
conducted by =0A=
- *  	the driver.=0A=
- * Return value:=0A=
- *  '0' on success.=0A=
+/**=0A=
+ * s2io-link_test - verifies the link state of the nic  =0A=
+ * @sp ; private member of the device structure, which is a pointer to =
the =0A=
+ * s2io_nic structure.=0A=
+ * @data: variable that returns the result of each of the test =
conducted by=0A=
+ * the driver.=0A=
  * Description:=0A=
- *  The function verifies the link state of the NIC and updates the =
input =0A=
- *  argument 'data' appropriately.=0A=
+ * The function verifies the link state of the NIC and updates the =
input =0A=
+ * argument 'data' appropriately.=0A=
+ * Return value:=0A=
+ * 0 on success.=0A=
  */=0A=
-static int s2io_linkTest(nic_t * sp, uint64_t * data)=0A=
+=0A=
+static int s2io_link_test(nic_t * sp, uint64_t * data)=0A=
 {=0A=
 	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) sp->bar0;=0A=
 	u64 val64;=0A=
@@ -3288,19 +3910,20 @@=0A=
 	return 0;=0A=
 }=0A=
 =0A=
-/*=0A=
- * Input Argument/s: =0A=
- *  sp - private member of the device structure, which is a pointer to =
the =0A=
- *   	s2io_nic structure.=0A=
- *  data - variable that returns the result of each of the test =
conducted by =0A=
- *  	the driver.=0A=
- * Return value:=0A=
- *  '0' on success.=0A=
+/**=0A=
+ * s2io_rldram_test - offline test for access to the RldRam chip on the =
NIC =0A=
+ * @sp - private member of the device structure, which is a pointer to =
the  =0A=
+ * s2io_nic structure.=0A=
+ * @data - variable that returns the result of each of the test =0A=
+ * conducted by the driver.=0A=
  * Description:=0A=
  *  This is one of the offline test that tests the read and write =0A=
  *  access to the RldRam chip on the NIC.=0A=
+ * Return value:=0A=
+ *  0 on success.=0A=
  */=0A=
-static int s2io_rldramTest(nic_t * sp, uint64_t * data)=0A=
+=0A=
+static int s2io_rldram_test(nic_t * sp, uint64_t * data)=0A=
 {=0A=
 	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) sp->bar0;=0A=
 	u64 val64;=0A=
@@ -3316,10 +3939,10 @@=0A=
 =0A=
 	val64 =3D readq(&bar0->mc_rldram_mrs);=0A=
 	val64 |=3D MC_RLDRAM_QUEUE_SIZE_ENABLE;=0A=
-	writeq(val64, &bar0->mc_rldram_mrs);=0A=
+	SPECIAL_REG_WRITE(val64, &bar0->mc_rldram_mrs, UF);=0A=
 =0A=
 	val64 |=3D MC_RLDRAM_MRS_ENABLE;=0A=
-	writeq(val64, &bar0->mc_rldram_mrs);=0A=
+	SPECIAL_REG_WRITE(val64, &bar0->mc_rldram_mrs, UF);=0A=
 =0A=
 	while (iteration < 2) {=0A=
 		val64 =3D 0x55555555aaaa0000ULL;=0A=
@@ -3395,20 +4018,21 @@=0A=
 	return 0;=0A=
 }=0A=
 =0A=
-/*=0A=
- * Input Argument/s: =0A=
- *  sp - private member of the device structure, which is a pointer to =
the =0A=
- *   	s2io_nic structure.=0A=
- *  ethtest - pointer to a ethtool command specific structure that will =
be=0A=
- *  	returned to the user.=0A=
- *  data - variable that returns the result of each of the test =
conducted by =0A=
- *  	the driver.=0A=
- * Return value:=0A=
- *  SUCCESS on success and an appropriate -1 on failure.=0A=
+/**=0A=
+ *  s2io_ethtool_test - conducts 6 tsets to determine the health of =
card.=0A=
+ *  @sp : private member of the device structure, which is a pointer to =
the=0A=
+ *  s2io_nic structure.=0A=
+ *  @ethtest : pointer to a ethtool command specific structure that =
will be=0A=
+ *  returned to the user.=0A=
+ *  @data : variable that returns the result of each of the test =0A=
+ * conducted by the driver.=0A=
  * Description:=0A=
  *  This function conducts 6 tests ( 4 offline and 2 online) to =
determine=0A=
- *  	the health of the card.=0A=
+ *  the health of the card.=0A=
+ * Return value:=0A=
+ *  void=0A=
  */=0A=
+=0A=
 static void s2io_ethtool_test(struct net_device *dev,=0A=
 			      struct ethtool_test *ethtest,=0A=
 			      uint64_t * data)=0A=
@@ -3424,22 +4048,22 @@=0A=
 		} else=0A=
 			s2io_set_swapper(sp);=0A=
 =0A=
-		if (s2io_registerTest(sp, &data[0]))=0A=
+		if (s2io_register_test(sp, &data[0]))=0A=
 			ethtest->flags |=3D ETH_TEST_FL_FAILED;=0A=
 =0A=
 		s2io_reset(sp);=0A=
 		s2io_set_swapper(sp);=0A=
 =0A=
-		if (s2io_rldramTest(sp, &data[3]))=0A=
+		if (s2io_rldram_test(sp, &data[3]))=0A=
 			ethtest->flags |=3D ETH_TEST_FL_FAILED;=0A=
 =0A=
 		s2io_reset(sp);=0A=
 		s2io_set_swapper(sp);=0A=
 =0A=
-		if (s2io_eepromTest(sp, &data[1]))=0A=
+		if (s2io_eeprom_test(sp, &data[1]))=0A=
 			ethtest->flags |=3D ETH_TEST_FL_FAILED;=0A=
 =0A=
-		if (s2io_bistTest(sp, &data[4]))=0A=
+		if (s2io_bist_test(sp, &data[4]))=0A=
 			ethtest->flags |=3D ETH_TEST_FL_FAILED;=0A=
 =0A=
 		if (orig_state)=0A=
@@ -3459,7 +4083,7 @@=0A=
 			data[4] =3D -1;=0A=
 		}=0A=
 =0A=
-		if (s2io_linkTest(sp, &data[2]))=0A=
+		if (s2io_link_test(sp, &data[2]))=0A=
 			ethtest->flags |=3D ETH_TEST_FL_FAILED;=0A=
 =0A=
 		data[0] =3D 0;=0A=
@@ -3475,7 +4099,7 @@=0A=
 {=0A=
 	int i =3D 0;=0A=
 	nic_t *sp =3D dev->priv;=0A=
-	StatInfo_t *stat_info =3D sp->mac_control.StatsInfo;=0A=
+	StatInfo_t *stat_info =3D sp->mac_control.stats_info;=0A=
 =0A=
 	tmp_stats[i++] =3D stat_info->tmac_frms;=0A=
 	tmp_stats[i++] =3D stat_info->tmac_data_octets;=0A=
@@ -3567,6 +4191,17 @@=0A=
 	return (S2IO_STAT_LEN);=0A=
 }=0A=
 =0A=
+int s2io_ethtool_op_set_tx_csum(struct net_device *dev, u32 data)=0A=
+{=0A=
+	if (data)=0A=
+		dev->features |=3D NETIF_F_IP_CSUM;=0A=
+	else=0A=
+		dev->features &=3D ~NETIF_F_IP_CSUM;=0A=
+=0A=
+	return 0;=0A=
+}=0A=
+=0A=
+=0A=
 static struct ethtool_ops netdev_ethtool_ops =3D {=0A=
 	.get_settings =3D s2io_ethtool_gset,=0A=
 	.set_settings =3D s2io_ethtool_sset,=0A=
@@ -3582,7 +4217,7 @@=0A=
 	.get_rx_csum =3D s2io_ethtool_get_rx_csum,=0A=
 	.set_rx_csum =3D s2io_ethtool_set_rx_csum,=0A=
 	.get_tx_csum =3D ethtool_op_get_tx_csum,=0A=
-	.set_tx_csum =3D ethtool_op_set_tx_csum,=0A=
+	.set_tx_csum =3D s2io_ethtool_op_set_tx_csum,=0A=
 	.get_sg =3D ethtool_op_get_sg,=0A=
 	.set_sg =3D ethtool_op_set_sg,=0A=
 #ifdef NETIF_F_TSO=0A=
@@ -3597,36 +4232,37 @@=0A=
 	.get_ethtool_stats =3D s2io_get_ethtool_stats=0A=
 };=0A=
 =0A=
-/*=0A=
- *  Input Argument/s: =0A=
- *  dev -   Device pointer.=0A=
- *  ifr -   An IOCTL specefic structure, that can contain a pointer to=0A=
- *      a proprietary structure used to pass information to the driver.=0A=
- *  cmd -   This is used to distinguish between the different commands =
that=0A=
- *      can be passed to the IOCTL functions.=0A=
- *  Return value:=0A=
- *  '0' on success and an appropriate (-)ve integer as defined in =
errno.h=0A=
- *  file on failure.=0A=
+/**=0A=
+ *  s2io_ioctl - Entry point for the Ioctl =0A=
+ *  @dev :  Device pointer.=0A=
+ *  @ifr :  An IOCTL specefic structure, that can contain a pointer to=0A=
+ *  a proprietary structure used to pass information to the driver.=0A=
+ *  @cmd :  This is used to distinguish between the different commands =
that=0A=
+ *  can be passed to the IOCTL functions.=0A=
  *  Description:=0A=
  *  This function has support for ethtool, adding multiple MAC =
addresses on =0A=
  *  the NIC and some DBG commands for the util tool.=0A=
+ *  Return value:=0A=
+ *  Currently the IOCTL supports no operations, hence by default this=0A=
+ *  function returns OP NOT SUPPORTED value.=0A=
  */=0A=
+=0A=
 int s2io_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)=0A=
 {=0A=
 	return -EOPNOTSUPP;=0A=
 }=0A=
 =0A=
-/*=0A=
- *  Input Argument/s: =0A=
- *   dev - device pointer.=0A=
- *   new_mtu - the new MTU size for the device.=0A=
+/**=0A=
+ *  s2io_change_mtu - entry point to change MTU size for the device.=0A=
+ *   @dev : device pointer.=0A=
+ *   @new_mtu : the new MTU size for the device.=0A=
+ *   Description: A driver entry point to change MTU size for the =
device.=0A=
+ *   Before changing the MTU the device must be stopped.=0A=
  *  Return value:=0A=
- *   '0' on success and an appropriate (-)ve integer as defined in =
errno.h=0A=
+ *   0 on success and an appropriate (-)ve integer as defined in errno.h=0A=
  *   file on failure.=0A=
- *  Description:=0A=
- *   A driver entry point to change MTU size for the device. Before =
changing=0A=
- *   the MTU the device must be stopped.=0A=
  */=0A=
+=0A=
 int s2io_change_mtu(struct net_device *dev, int new_mtu)=0A=
 {=0A=
 	nic_t *sp =3D dev->priv;=0A=
@@ -3645,7 +4281,7 @@=0A=
 		return -EPERM;=0A=
 	}=0A=
 =0A=
-/* Set the new MTU into the PYLD register of the NIC */=0A=
+	/* Set the new MTU into the PYLD register of the NIC */=0A=
 	val64 =3D new_mtu;=0A=
 	writeq(vBIT(val64, 2, 14), &bar0->rmac_max_pyld_len);=0A=
 =0A=
@@ -3654,18 +4290,19 @@=0A=
 	return 0;=0A=
 }=0A=
 =0A=
-/*=0A=
- *  Input Argument/s: =0A=
- *  dev_adr - address of the device structure in dma_addr_t format.=0A=
- *  Return value:=0A=
- *  void.=0A=
+/**=0A=
+ *  s2io_tasklet - Bottom half of the ISR.=0A=
+ *  @dev_adr : address of the device structure in dma_addr_t format.=0A=
  *  Description:=0A=
  *  This is the tasklet or the bottom half of the ISR. This is=0A=
  *  an extension of the ISR which is scheduled by the scheduler to be =
run =0A=
  *  when the load on the CPU is low. All low priority tasks of the ISR =
can=0A=
  *  be pushed into the tasklet. For now the tasklet is used only to =0A=
  *  replenish the Rx buffers in the Rx buffer descriptors.=0A=
+ *  Return value:=0A=
+ *  void.=0A=
  */=0A=
+=0A=
 static void s2io_tasklet(unsigned long dev_addr)=0A=
 {=0A=
 	struct net_device *dev =3D (struct net_device *) dev_addr;=0A=
@@ -3684,31 +4321,35 @@=0A=
 				DBG_PRINT(ERR_DBG, "%s: Out of ",=0A=
 					  dev->name);=0A=
 				DBG_PRINT(ERR_DBG, "memory in tasklet\n");=0A=
-				return;=0A=
+				break;=0A=
 			} else if (ret =3D=3D -EFILL) {=0A=
 				DBG_PRINT(ERR_DBG,=0A=
 					  "%s: Rx Ring %d is full\n",=0A=
 					  dev->name, i);=0A=
-				return;=0A=
+				break;=0A=
 			}=0A=
 		}=0A=
 		clear_bit(0, (unsigned long *) (&sp->tasklet_status));=0A=
 	}=0A=
 }=0A=
 =0A=
-=0A=
-/*=0A=
- * Description:=0A=
- * =0A=
+/**=0A=
+ * s2io_set_link - Set the LInk status=0A=
+ * @data: long pointer to device private structue=0A=
+ * Description: Sets the link status for the adapter=0A=
  */=0A=
+=0A=
 static void s2io_set_link(unsigned long data)=0A=
 {=0A=
 	nic_t *nic =3D (nic_t *) data;=0A=
 	struct net_device *dev =3D nic->dev;=0A=
 	XENA_dev_config_t *bar0 =3D (XENA_dev_config_t *) nic->bar0;=0A=
-	register u64 val64, err_reg;=0A=
+	register u64 val64;=0A=
+	u16 subid;=0A=
 =0A=
-	/* Allow a small delay for the NICs self initiated =0A=
+	subid =3D nic->pdev->subsystem_device;=0A=
+	/* =0A=
+	 * Allow a small delay for the NICs self initiated =0A=
 	 * cleanup to complete.=0A=
 	 */=0A=
 	set_current_state(TASK_UNINTERRUPTIBLE);=0A=
@@ -3716,16 +4357,19 @@=0A=
 =0A=
 	val64 =3D readq(&bar0->adapter_status);=0A=
 	if (verify_xena_quiescence(val64, nic->device_enabled_once)) {=0A=
-		/* Acknowledge interrupt and clear the R1 register */=0A=
-		err_reg =3D readq(&bar0->mac_rmac_err_reg);=0A=
-		writeq(err_reg, &bar0->mac_rmac_err_reg);=0A=
-=0A=
 		if (LINK_IS_UP(val64)) {=0A=
 			val64 =3D readq(&bar0->adapter_control);=0A=
 			val64 |=3D ADAPTER_CNTL_EN;=0A=
 			writeq(val64, &bar0->adapter_control);=0A=
-			val64 |=3D ADAPTER_LED_ON;=0A=
-			writeq(val64, &bar0->adapter_control);=0A=
+			if (CARDS_WITH_FAULTY_LINK_INDICATORS(subid)) {=0A=
+				val64 =3D readq(&bar0->gpio_control);=0A=
+				val64 |=3D GPIO_CTRL_GPIO_0;=0A=
+				writeq(val64, &bar0->gpio_control);=0A=
+				val64 =3D readq(&bar0->gpio_control);=0A=
+			} else {=0A=
+				val64 |=3D ADAPTER_LED_ON;=0A=
+				writeq(val64, &bar0->adapter_control);=0A=
+			}=0A=
 			val64 =3D readq(&bar0->adapter_status);=0A=
 			if (!LINK_IS_UP(val64)) {=0A=
 				DBG_PRINT(ERR_DBG, "%s:", dev->name);=0A=
@@ -3739,6 +4383,12 @@=0A=
 			}=0A=
 			s2io_link(nic, LINK_UP);=0A=
 		} else {=0A=
+			if (CARDS_WITH_FAULTY_LINK_INDICATORS(subid)) {=0A=
+				val64 =3D readq(&bar0->gpio_control);=0A=
+				val64 &=3D ~GPIO_CTRL_GPIO_0;=0A=
+				writeq(val64, &bar0->gpio_control);=0A=
+				val64 =3D readq(&bar0->gpio_control);=0A=
+			}=0A=
 			s2io_link(nic, LINK_DOWN);=0A=
 		}=0A=
 	} else {		/* NIC is not Quiescent. */=0A=
@@ -3748,37 +4398,43 @@=0A=
 	}=0A=
 }=0A=
 =0A=
-/*=0A=
+/** =0A=
+ * s2io_restart_nic - Resets the NIC.=0A=
+ * @data : long pointer to the device private structure=0A=
  * Description:=0A=
  * This function is scheduled to be run by the s2io_tx_watchdog=0A=
  * function after 0.5 secs to reset the NIC. The idea is to reduce =0A=
  * the run time of the watch dog routine which is run holding a=0A=
  * spin lock.=0A=
  */=0A=
+=0A=
 static void s2io_restart_nic(unsigned long data)=0A=
 {=0A=
 	struct net_device *dev =3D (struct net_device *) data;=0A=
 	nic_t *sp =3D dev->priv;=0A=
 =0A=
+	sp->task_flag =3D 1;=0A=
 	s2io_close(dev);=0A=
+	sp->task_flag =3D 0;=0A=
 	sp->device_close_flag =3D TRUE;=0A=
 	s2io_open(dev);=0A=
 	DBG_PRINT(ERR_DBG,=0A=
 		  "%s: was reset by Tx watchdog timer.\n", dev->name);=0A=
 }=0A=
 =0A=
-/*=0A=
- *  Input Argument/s: =0A=
- *  dev - device pointer.=0A=
- *  Return value:=0A=
- *  void=0A=
+/** =0A=
+ *  s2io_tx_watchdog - Watchdog for transmit side. =0A=
+ *  @dev : Pointer to net device structure=0A=
  *  Description:=0A=
  *  This function is triggered if the Tx Queue is stopped=0A=
  *  for a pre-defined amount of time when the Interface is still up.=0A=
  *  If the Interface is jammed in such a situation, the hardware is=0A=
  *  reset (by s2io_close) and restarted again (by s2io_open) to=0A=
  *  overcome any problem that might have been caused in the hardware.=0A=
+ *  Return value:=0A=
+ *  void=0A=
  */=0A=
+=0A=
 static void s2io_tx_watchdog(struct net_device *dev)=0A=
 {=0A=
 	nic_t *sp =3D dev->priv;=0A=
@@ -3788,36 +4444,45 @@=0A=
 	}=0A=
 }=0A=
 =0A=
-/*=0A=
- *  Input Argument/s: =0A=
- *   sp - private member of the device structure, which is a pointer to =
the =0A=
- *   s2io_nic structure.=0A=
- *   skb - the socket buffer pointer.=0A=
- *   len - length of the packet=0A=
- *   cksum - FCS checksum of the frame.=0A=
- *  ring_no - the ring from which this RxD was extracted.=0A=
- *  Return value:=0A=
- *   SUCCESS on success and -1 on failure.=0A=
- *  Description: =0A=
- *   This function is called by the Tx interrupt serivce routine to =
perform =0A=
+/**=0A=
+ *   rx_osm_handler - To perform some OS related operations on SKB.=0A=
+ *   @sp: private member of the device structure,pointer to s2io_nic =
structure.=0A=
+ *   @skb : the socket buffer pointer.=0A=
+ *   @len : length of the packet=0A=
+ *   @cksum : FCS checksum of the frame.=0A=
+ *   @ring_no : the ring from which this RxD was extracted.=0A=
+ *   Description: =0A=
+ *   This function is called by the Tx interrupt serivce routine to =
perform=0A=
  *   some OS related operations on the SKB before passing it to the =
upper=0A=
  *   layers. It mainly checks if the checksum is OK, if so adds it to =
the=0A=
  *   SKBs cksum variable, increments the Rx packet count and passes the =
SKB=0A=
  *   to the upper layer. If the checksum is wrong, it increments the Rx=0A=
  *   packet error count, frees the SKB and returns error.=0A=
+ *   Return value:=0A=
+ *   SUCCESS on success and -1 on failure.=0A=
  */=0A=
-static int rxOsmHandler(nic_t * sp, u16 len, RxD_t * rxdp, int ring_no)=0A=
+#ifndef CONFIG_2BUFF_MODE=0A=
+static int rx_osm_handler(nic_t * sp, u16 len, RxD_t * rxdp, int =
ring_no)=0A=
+#else=0A=
+static int rx_osm_handler(nic_t * sp, RxD_t * rxdp, int ring_no,=0A=
+			  buffAdd_t * ba)=0A=
+#endif=0A=
 {=0A=
 	struct net_device *dev =3D (struct net_device *) sp->dev;=0A=
 	struct sk_buff *skb =3D=0A=
 	    (struct sk_buff *) ((unsigned long) rxdp->Host_Control);=0A=
 	u16 l3_csum, l4_csum;=0A=
+#ifdef CONFIG_2BUFF_MODE=0A=
+	int buf0_len, buf2_len;=0A=
+	struct ethhdr *eth =3D (struct ethhdr *) ba->ba_0;=0A=
+#endif=0A=
 =0A=
 	l3_csum =3D RXD_GET_L3_CKSUM(rxdp->Control_1);=0A=
 	if ((rxdp->Control_1 & TCP_OR_UDP_FRAME) && (sp->rx_csum)) {=0A=
 		l4_csum =3D RXD_GET_L4_CKSUM(rxdp->Control_1);=0A=
 		if ((l3_csum =3D=3D L3_CKSUM_OK) && (l4_csum =3D=3D L4_CKSUM_OK)) {=0A=
-			/* NIC verifies if the Checksum of the received=0A=
+			/* =0A=
+			 * NIC verifies if the Checksum of the received=0A=
 			 * frame is Ok or not and accordingly returns=0A=
 			 * a flag in the RxD.=0A=
 			 */=0A=
@@ -3833,9 +4498,37 @@=0A=
 		skb->ip_summed =3D CHECKSUM_NONE;=0A=
 	}=0A=
 =0A=
+	if (rxdp->Control_1 & RXD_T_CODE) {=0A=
+		unsigned long long err =3D rxdp->Control_1 & RXD_T_CODE;=0A=
+		DBG_PRINT(ERR_DBG, "%s: Rx error Value: 0x%llx\n",=0A=
+			  dev->name, err);=0A=
+	}=0A=
+#ifdef CONFIG_2BUFF_MODE=0A=
+	buf0_len =3D RXD_GET_BUFFER0_SIZE(rxdp->Control_2);=0A=
+	buf2_len =3D RXD_GET_BUFFER2_SIZE(rxdp->Control_2);=0A=
+#endif=0A=
+=0A=
 	skb->dev =3D dev;=0A=
+#ifndef CONFIG_2BUFF_MODE=0A=
 	skb_put(skb, len);=0A=
 	skb->protocol =3D eth_type_trans(skb, dev);=0A=
+#else=0A=
+	skb_put(skb, buf2_len);=0A=
+	/* =0A=
+	 * Reproducing eth_type_trans functionality and running=0A=
+	 * on the ethernet header 'eth' stripped and given to us=0A=
+	 * by the hardware in 2Buff mode.=0A=
+	 */=0A=
+	if (*eth->h_dest & 1) {=0A=
+		if (!memcmp(eth->h_dest, dev->broadcast, ETH_ALEN))=0A=
+			skb->pkt_type =3D PACKET_BROADCAST;=0A=
+		else=0A=
+			skb->pkt_type =3D PACKET_MULTICAST;=0A=
+	} else if (memcmp(eth->h_dest, dev->dev_addr, ETH_ALEN)) {=0A=
+		skb->pkt_type =3D PACKET_OTHERHOST;=0A=
+	}=0A=
+	skb->protocol =3D eth->h_proto;=0A=
+#endif=0A=
 =0A=
 #ifdef CONFIG_S2IO_NAPI=0A=
 	netif_receive_skb(skb);=0A=
@@ -3844,20 +4537,20 @@=0A=
 #endif=0A=
 =0A=
 	dev->last_rx =3D jiffies;=0A=
-#if DEBUG_ON=0A=
-	sp->rxpkt_cnt++;=0A=
-#endif=0A=
 	sp->rx_pkt_count++;=0A=
 	sp->stats.rx_packets++;=0A=
+#ifndef CONFIG_2BUFF_MODE=0A=
 	sp->stats.rx_bytes +=3D len;=0A=
-	sp->rxpkt_bytes +=3D len;=0A=
+#else=0A=
+	sp->stats.rx_bytes +=3D buf0_len + buf2_len;=0A=
+#endif=0A=
 =0A=
 	atomic_dec(&sp->rx_bufs_left[ring_no]);=0A=
 	rxdp->Host_Control =3D 0;=0A=
 	return SUCCESS;=0A=
 }=0A=
 =0A=
-int check_for_txSpace(nic_t * sp)=0A=
+int check_for_tx_space(nic_t * sp)=0A=
 {=0A=
 	u32 put_off, get_off, queue_len;=0A=
 	int ret =3D TRUE, i;=0A=
@@ -3876,18 +4569,19 @@=0A=
 	return ret;=0A=
 }=0A=
 =0A=
-/*=0A=
-*  Input Argument/s: =0A=
-*   sp - private member of the device structure, which is a pointer to =
the =0A=
-*   s2io_nic structure.=0A=
-*   link - inidicates whether link is UP/DOWN.=0A=
-*  Return value:=0A=
-*   void.=0A=
-*  Description:=0A=
-*   This function stops/starts the Tx queue depending on whether the =
link=0A=
-*   status of the NIC is is down or up. This is called by the Alarm =
interrupt =0A=
-*  handler whenever a link change interrupt comes up. =0A=
-*/=0A=
+/**=0A=
+ *  s2io_link - stops/starts the Tx queue.=0A=
+ *  @sp : private member of the device structure, which is a pointer to =
the=0A=
+ *  s2io_nic structure.=0A=
+ *  @link : inidicates whether link is UP/DOWN.=0A=
+ *  Description:=0A=
+ *  This function stops/starts the Tx queue depending on whether the =
link=0A=
+ *  status of the NIC is is down or up. This is called by the Alarm =0A=
+ *  interrupt handler whenever a link change interrupt comes up. =0A=
+ *  Return value:=0A=
+ *  void.=0A=
+ */=0A=
+=0A=
 void s2io_link(nic_t * sp, int link)=0A=
 {=0A=
 	struct net_device *dev =3D (struct net_device *) sp->dev;=0A=
@@ -3896,29 +4590,23 @@=0A=
 		if (link =3D=3D LINK_DOWN) {=0A=
 			DBG_PRINT(ERR_DBG, "%s: Link down\n", dev->name);=0A=
 			netif_carrier_off(dev);=0A=
-			netif_stop_queue(dev);=0A=
 		} else {=0A=
 			DBG_PRINT(ERR_DBG, "%s: Link Up\n", dev->name);=0A=
 			netif_carrier_on(dev);=0A=
-			if (check_for_txSpace(sp) =3D=3D TRUE) {=0A=
-				/* Don't wake the queue, if we know there=0A=
-				 * are no free TxDs available.=0A=
-				 */=0A=
-				netif_wake_queue(dev);=0A=
-			}=0A=
 		}=0A=
 	}=0A=
 	sp->last_link_state =3D link;=0A=
 }=0A=
 =0A=
-/*=0A=
-*  Input Argument/s: =0A=
-*   pdev - structure containing the PCI related information of the =
device.=0A=
-*  Return value:=0A=
-*   returns the revision ID of the device.=0A=
-*  Description:=0A=
-*   Function to identify the Revision ID of xena.=0A=
-*/=0A=
+/**=0A=
+ *  get_xena_rev_id - to identify revision ID of xena. =0A=
+ *  @pdev : PCI Dev structure=0A=
+ *  Description:=0A=
+ *  Function to identify the Revision ID of xena.=0A=
+ *  Return value:=0A=
+ *  returns the revision ID of the device.=0A=
+ */=0A=
+=0A=
 int get_xena_rev_id(struct pci_dev *pdev)=0A=
 {=0A=
 	u8 id =3D 0;=0A=
@@ -3927,21 +4615,22 @@=0A=
 	return id;=0A=
 }=0A=
 =0A=
-/*=0A=
-*  Input Argument/s: =0A=
-*   sp - private member of the device structure, which is a pointer to =
the =0A=
-*   s2io_nic structure.=0A=
-*  Return value:=0A=
-*   void=0A=
-*  Description:=0A=
-*   This function initializes a few of the PCI and PCI-X configuration =
registers=0A=
-*   with recommended values.=0A=
-*/=0A=
+/**=0A=
+ *  s2io_init_pci -Initialization of PCI and PCI-X configuration =
registers . =0A=
+ *  @sp : private member of the device structure, which is a pointer to =
the =0A=
+ *  s2io_nic structure.=0A=
+ *  Description:=0A=
+ *  This function initializes a few of the PCI and PCI-X configuration =
registers=0A=
+ *  with recommended values.=0A=
+ *  Return value:=0A=
+ *  void=0A=
+ */=0A=
+=0A=
 static void s2io_init_pci(nic_t * sp)=0A=
 {=0A=
 	u16 pci_cmd =3D 0;=0A=
 =0A=
-/* Enable Data Parity Error Recovery in PCI-X command register. */=0A=
+	/* Enable Data Parity Error Recovery in PCI-X command register. */=0A=
 	pci_read_config_word(sp->pdev, PCIX_COMMAND_REGISTER,=0A=
 			     &(sp->pcix_cmd));=0A=
 	pci_write_config_word(sp->pdev, PCIX_COMMAND_REGISTER,=0A=
@@ -3949,13 +4638,13 @@=0A=
 	pci_read_config_word(sp->pdev, PCIX_COMMAND_REGISTER,=0A=
 			     &(sp->pcix_cmd));=0A=
 =0A=
-/* Set the PErr Response bit in PCI command register. */=0A=
+	/* Set the PErr Response bit in PCI command register. */=0A=
 	pci_read_config_word(sp->pdev, PCI_COMMAND, &pci_cmd);=0A=
 	pci_write_config_word(sp->pdev, PCI_COMMAND,=0A=
 			      (pci_cmd | PCI_COMMAND_PARITY));=0A=
 	pci_read_config_word(sp->pdev, PCI_COMMAND, &pci_cmd);=0A=
 =0A=
-/* Set user specified value in Latency Timer */=0A=
+	/* Set user specified value in Latency Timer */=0A=
 	if (latency_timer) {=0A=
 		pci_write_config_byte(sp->pdev, PCI_LATENCY_TIMER,=0A=
 				      latency_timer);=0A=
@@ -3963,49 +4652,97 @@=0A=
 				     &latency_timer);=0A=
 	}=0A=
 =0A=
-/* Set MMRB count to 4096 in PCI-X Command register. */=0A=
+	/* Set MMRB count to 4096 in PCI-X Command register. */=0A=
+	sp->pcix_cmd &=3D 0xFFF3;=0A=
 	pci_write_config_word(sp->pdev, PCIX_COMMAND_REGISTER,=0A=
-			      (sp->pcix_cmd | 0x0C));=0A=
+			      (sp->pcix_cmd | (max_read_byte_cnt << 2)));=0A=
 	pci_read_config_word(sp->pdev, PCIX_COMMAND_REGISTER,=0A=
 			     &(sp->pcix_cmd));=0A=
 =0A=
-/* Setting Maximum outstanding splits to two for now. */=0A=
-	sp->pcix_cmd &=3D 0xFF1F;=0A=
+	/*  Setting Maximum outstanding splits based on system type. */=0A=
+	sp->pcix_cmd &=3D 0xFF8F;=0A=
 =0A=
-	sp->pcix_cmd |=3D=0A=
-	    XENA_MAX_OUTSTANDING_SPLITS(XENA_TWO_SPLIT_TRANSACTION);=0A=
+	sp->pcix_cmd |=3D XENA_MAX_OUTSTANDING_SPLITS(max_splits_trans);=0A=
+	pci_write_config_word(sp->pdev, PCIX_COMMAND_REGISTER,=0A=
+			      sp->pcix_cmd);=0A=
+	pci_read_config_word(sp->pdev, PCIX_COMMAND_REGISTER,=0A=
+			     &(sp->pcix_cmd));=0A=
+	/* Forcibly disabling relaxed ordering capability of the card. */=0A=
+	sp->pcix_cmd &=3D 0xfffd;=0A=
 	pci_write_config_word(sp->pdev, PCIX_COMMAND_REGISTER,=0A=
 			      sp->pcix_cmd);=0A=
 	pci_read_config_word(sp->pdev, PCIX_COMMAND_REGISTER,=0A=
 			     &(sp->pcix_cmd));=0A=
-=0A=
 }=0A=
 =0A=
 MODULE_AUTHOR("Raghavendra Koushik <raghavendra.koushik@s2io.com>");=0A=
 MODULE_LICENSE("GPL");=0A=
-MODULE_PARM(ring_num, "1-" __MODULE_STRING(1) "i");=0A=
-MODULE_PARM(frame_len, "1-" __MODULE_STRING(8) "i");=0A=
-MODULE_PARM(ring_len, "1-" __MODULE_STRING(8) "i");=0A=
-MODULE_PARM(fifo_num, "1-" __MODULE_STRING(1) "i");=0A=
-MODULE_PARM(fifo_len, "1-" __MODULE_STRING(8) "i");=0A=
-MODULE_PARM(rx_prio, "1-" __MODULE_STRING(1) "i");=0A=
-MODULE_PARM(tx_prio, "1-" __MODULE_STRING(1) "i");=0A=
-MODULE_PARM(latency_timer, "1-" __MODULE_STRING(1) "i");=0A=
-=0A=
-/*=0A=
-*  Input Argument/s: =0A=
-*   pdev - structure containing the PCI related information of the =
device.=0A=
-*   pre -  the List of PCI devices supported by the driver listed in =
s2io_tbl.=0A=
-*  Return value:=0A=
-*   returns '0' on success and negative on failure.=0A=
-*  Description:=0A=
-*  The function initializes an adapter identified by the pci_dec =
structure.=0A=
-*  All OS related initialization including memory and device structure =
and =0A=
-*  initlaization of the device private variable is done. Also the =
swapper =0A=
-*  control register is initialized to enable read and write into the =
I/O =0A=
-*  registers of the device.=0A=
-*  =0A=
-*/=0A=
+MODULE_PARM(lso_enable, "i");=0A=
+#ifndef CONFIG_S2IO_NAPI=0A=
+MODULE_PARM(indicate_max_pkts, "i");=0A=
+#endif=0A=
+MODULE_PARM(cksum_offload_enable, "i");=0A=
+MODULE_PARM(TxFifoNum, "i");=0A=
+MODULE_PARM(TxFIFOLen_0, "i");=0A=
+MODULE_PARM(TxFIFOLen_1, "i");=0A=
+MODULE_PARM(TxFIFOLen_2, "i");=0A=
+MODULE_PARM(TxFIFOLen_3, "i");=0A=
+MODULE_PARM(TxFIFOLen_4, "i");=0A=
+MODULE_PARM(TxFIFOLen_5, "i");=0A=
+MODULE_PARM(TxFIFOLen_6, "i");=0A=
+MODULE_PARM(TxFIFOLen_7, "i");=0A=
+MODULE_PARM(MaxTxDs, "i");=0A=
+MODULE_PARM(RxRingNum, "i");=0A=
+MODULE_PARM(RxRingSz_0, "i");=0A=
+MODULE_PARM(RxRingSz_1, "i");=0A=
+MODULE_PARM(RxRingSz_2, "i");=0A=
+MODULE_PARM(RxRingSz_3, "i");=0A=
+MODULE_PARM(RxRingSz_4, "i");=0A=
+MODULE_PARM(RxRingSz_5, "i");=0A=
+MODULE_PARM(RxRingSz_6, "i");=0A=
+MODULE_PARM(RxRingSz_7, "i");=0A=
+MODULE_PARM(Stats_refresh_time, "i");=0A=
+MODULE_PARM(rmac_pause_time, "i");=0A=
+MODULE_PARM(mc_pause_threshold_q0q3, "i");=0A=
+MODULE_PARM(mc_pause_threshold_q4q7, "i");=0A=
+MODULE_PARM(shared_splits, "i");=0A=
+MODULE_PARM(max_splits_trans, "i");=0A=
+MODULE_PARM(tmac_util_period, "i");=0A=
+MODULE_PARM(rmac_util_period, "i");=0A=
+MODULE_PARM(tx_timer_val, "i");=0A=
+MODULE_PARM(tx_utilz_periodic, "i");=0A=
+MODULE_PARM(rx_timer_val, "i");=0A=
+MODULE_PARM(rx_utilz_periodic, "i");=0A=
+MODULE_PARM(tx_urange_a, "i");=0A=
+MODULE_PARM(tx_ufc_a, "i");=0A=
+MODULE_PARM(tx_urange_b, "i");=0A=
+MODULE_PARM(tx_ufc_b, "i");=0A=
+MODULE_PARM(tx_urange_c, "i");=0A=
+MODULE_PARM(tx_ufc_c, "i");=0A=
+MODULE_PARM(tx_ufc_d, "i");=0A=
+MODULE_PARM(rx_urange_a, "i");=0A=
+MODULE_PARM(rx_ufc_a, "i");=0A=
+MODULE_PARM(rx_urange_b, "i");=0A=
+MODULE_PARM(rx_ufc_b, "i");=0A=
+MODULE_PARM(rx_urange_c, "i");=0A=
+MODULE_PARM(rx_ufc_c, "i");=0A=
+MODULE_PARM(rx_ufc_d, "i");=0A=
+MODULE_PARM(latency_timer, "i");=0A=
+MODULE_PARM(max_read_byte_cnt, "i");=0A=
+/**=0A=
+ *  s2io_init_nic - Initialization of the adapter . =0A=
+ *  @pdev : structure containing the PCI related information of the =
device.=0A=
+ *  @pre: List of PCI devices supported by the driver listed in =
s2io_tbl.=0A=
+ *  Description:=0A=
+ *  The function initializes an adapter identified by the pci_dec =
structure.=0A=
+ *  All OS related initialization including memory and device structure =
and =0A=
+ *  initlaization of the device private variable is done. Also the =
swapper =0A=
+ *  control register is initialized to enable read and write into the =
I/O =0A=
+ *  registers of the device.=0A=
+ *  Return value:=0A=
+ *  returns 0 on success and negative on failure.=0A=
+ */=0A=
+=0A=
 static int __devinit=0A=
 s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)=0A=
 {=0A=
@@ -4031,6 +4768,7 @@=0A=
 	if (!pci_set_dma_mask(pdev, 0xffffffffffffffffULL)) {=0A=
 		DBG_PRINT(INIT_DBG, "s2io_init_nic: Using 64bit DMA\n");=0A=
 		dma_flag =3D TRUE;=0A=
+=0A=
 		if (pci_set_consistent_dma_mask=0A=
 		    (pdev, 0xffffffffffffffffULL)) {=0A=
 			DBG_PRINT(ERR_DBG,=0A=
@@ -4080,7 +4818,8 @@=0A=
 	/* Initialize some PCI/PCI-X fields of the NIC. */=0A=
 	s2io_init_pci(sp);=0A=
 =0A=
-	/* Setting the device configuration parameters.=0A=
+	/* =0A=
+	 * Setting the device configuration parameters.=0A=
 	 * Most of these parameters can be specified by the user during =0A=
 	 * module insertion as they are module loadable parameters. If =0A=
 	 * these parameters are not not specified during load time, they =0A=
@@ -4090,69 +4829,63 @@=0A=
 	config =3D &sp->config;=0A=
 =0A=
 	/* Tx side parameters. */=0A=
-	config->TxFIFONum =3D fifo_num ? fifo_num : 1;=0A=
-=0A=
-	if (!fifo_len[0] && (fifo_num > 1)) {=0A=
-		printk(KERN_ERR "Fifo Lens not specified for all FIFOs\n");=0A=
-		goto init_failed;=0A=
-	}=0A=
-=0A=
-	if (fifo_len[0]) {=0A=
-		int cnt;=0A=
-=0A=
-		for (cnt =3D 0; fifo_len[cnt]; cnt++);=0A=
-		if (fifo_num) {=0A=
-			if (cnt < fifo_num) {=0A=
-				printk(KERN_ERR=0A=
-				       "Fifo Lens not specified for ");=0A=
-				printk(KERN_ERR "all FIFOs\n");=0A=
-				goto init_failed;=0A=
-			}=0A=
-		}=0A=
-		for (cnt =3D 0; cnt < config->TxFIFONum; cnt++) {=0A=
-			config->TxCfg[cnt].FifoLen =3D fifo_len[cnt];=0A=
-			config->TxCfg[cnt].FifoPriority =3D cnt;=0A=
-		}=0A=
-	} else {=0A=
-		config->TxCfg[0].FifoLen =3D DEFAULT_FIFO_LEN;=0A=
-		config->TxCfg[0].FifoPriority =3D 0;=0A=
-	}=0A=
+	config->TxFIFONum =3D TxFifoNum;=0A=
+	config->tx_cfg[0].FifoLen =3D TxFIFOLen_0;=0A=
+	config->tx_cfg[0].FifoPriority =3D 0;=0A=
+	config->tx_cfg[1].FifoLen =3D TxFIFOLen_1;=0A=
+	config->tx_cfg[1].FifoPriority =3D 1;=0A=
+	config->tx_cfg[2].FifoLen =3D TxFIFOLen_2;=0A=
+	config->tx_cfg[2].FifoPriority =3D 2;=0A=
+	config->tx_cfg[3].FifoLen =3D TxFIFOLen_3;=0A=
+	config->tx_cfg[3].FifoPriority =3D 3;=0A=
+	config->tx_cfg[4].FifoLen =3D TxFIFOLen_4;=0A=
+	config->tx_cfg[4].FifoPriority =3D 4;=0A=
+	config->tx_cfg[5].FifoLen =3D TxFIFOLen_5;=0A=
+	config->tx_cfg[5].FifoPriority =3D 5;=0A=
+	config->tx_cfg[6].FifoLen =3D TxFIFOLen_6;=0A=
+	config->tx_cfg[6].FifoPriority =3D 6;=0A=
+	config->tx_cfg[7].FifoLen =3D TxFIFOLen_7;=0A=
+	config->tx_cfg[7].FifoPriority =3D 7;=0A=
 =0A=
 	config->TxIntrType =3D TXD_INT_TYPE_UTILZ;=0A=
 	for (i =3D 0; i < config->TxFIFONum; i++) {=0A=
-		if (config->TxCfg[i].FifoLen < 65) {=0A=
+		config->tx_cfg[i].fNoSnoop =3D=0A=
+		    (NO_SNOOP_TXD | NO_SNOOP_TXD_BUFFER);=0A=
+		if (config->tx_cfg[i].FifoLen < 65) {=0A=
 			config->TxIntrType =3D TXD_INT_TYPE_PER_LIST;=0A=
 			break;=0A=
 		}=0A=
 	}=0A=
-=0A=
-	config->TxCfg[0].fNoSnoop =3D (NO_SNOOP_TXD | NO_SNOOP_TXD_BUFFER);=0A=
 	config->MaxTxDs =3D MAX_SKB_FRAGS;=0A=
 	config->TxFlow =3D TRUE;=0A=
 =0A=
 	/* Rx side parameters. */=0A=
-	config->RxRingNum =3D ring_num ? ring_num : 1;=0A=
-=0A=
-	if (ring_len[0]) {=0A=
-		int cnt;=0A=
-		for (cnt =3D 0; cnt < config->RxRingNum; cnt++) {=0A=
-			config->RxCfg[cnt].NumRxd =3D ring_len[cnt];=0A=
-			config->RxCfg[cnt].RingPriority =3D cnt;=0A=
-		}=0A=
-	} else {=0A=
-		int id;=0A=
-		if ((id =3D get_xena_rev_id(pdev)) =3D=3D 1) {=0A=
-			config->RxCfg[0].NumRxd =3D LARGE_RXD_CNT;=0A=
-=0A=
-		} else {=0A=
-			config->RxCfg[0].NumRxd =3D SMALL_RXD_CNT;=0A=
-		}=0A=
-		config->RxCfg[0].RingPriority =3D 0;=0A=
+	config->RxRingNum =3D RxRingNum;=0A=
+	config->rx_cfg[0].NumRxd =3D RxRingSz_0 * (MAX_RXDS_PER_BLOCK + 1);=0A=
+	config->rx_cfg[0].RingPriority =3D 0;=0A=
+	config->rx_cfg[1].NumRxd =3D RxRingSz_1 * (MAX_RXDS_PER_BLOCK + 1);=0A=
+	config->rx_cfg[1].RingPriority =3D 1;=0A=
+	config->rx_cfg[2].NumRxd =3D RxRingSz_2 * (MAX_RXDS_PER_BLOCK + 1);=0A=
+	config->rx_cfg[2].RingPriority =3D 2;=0A=
+	config->rx_cfg[3].NumRxd =3D RxRingSz_3 * (MAX_RXDS_PER_BLOCK + 1);=0A=
+	config->rx_cfg[3].RingPriority =3D 3;=0A=
+	config->rx_cfg[4].NumRxd =3D RxRingSz_4 * (MAX_RXDS_PER_BLOCK + 1);=0A=
+	config->rx_cfg[4].RingPriority =3D 4;=0A=
+	config->rx_cfg[5].NumRxd =3D RxRingSz_5 * (MAX_RXDS_PER_BLOCK + 1);=0A=
+	config->rx_cfg[5].RingPriority =3D 5;=0A=
+	config->rx_cfg[6].NumRxd =3D RxRingSz_6 * (MAX_RXDS_PER_BLOCK + 1);=0A=
+	config->rx_cfg[6].RingPriority =3D 6;=0A=
+	config->rx_cfg[7].NumRxd =3D RxRingSz_7 * (MAX_RXDS_PER_BLOCK + 1);=0A=
+	config->rx_cfg[7].RingPriority =3D 7;=0A=
+=0A=
+	for (i =3D 0; i < RxRingNum; i++) {=0A=
+		config->rx_cfg[i].RingOrg =3D RING_ORG_BUFF1;=0A=
+		config->rx_cfg[i].RxdThresh =3D DEFAULT_RXD_THRESHOLD;=0A=
+		config->rx_cfg[i].fNoSnoop =3D=0A=
+		    (NO_SNOOP_RXD | NO_SNOOP_RXD_BUFFER);=0A=
+		config->rx_cfg[i].RxD_BackOff_Interval =3D TBD;=0A=
 	}=0A=
-	config->RxCfg[0].RingOrg =3D RING_ORG_BUFF1;=0A=
-	config->RxCfg[0].RxdThresh =3D DEFAULT_RXD_THRESHOLD;=0A=
-	config->RxCfg[0].fNoSnoop =3D (NO_SNOOP_RXD | NO_SNOOP_RXD_BUFFER);=0A=
-	config->RxCfg[0].RxD_BackOff_Interval =3D TBD;=0A=
+=0A=
 	config->RxFlow =3D TRUE;=0A=
 =0A=
 	/* Miscellaneous parameters. */=0A=
@@ -4162,14 +4895,17 @@=0A=
 =0A=
 	/*  Setting Mac Control parameters */=0A=
 	mac_control->txdl_len =3D MAX_SKB_FRAGS;=0A=
-	mac_control->rmac_pause_time =3D 0;=0A=
+	mac_control->rmac_pause_time =3D rmac_pause_time;=0A=
+	mac_control->mc_pause_threshold_q0q3 =3D mc_pause_threshold_q0q3;=0A=
+	mac_control->mc_pause_threshold_q4q7 =3D mc_pause_threshold_q4q7;=0A=
+=0A=
 =0A=
 	/* Initialize Ring buffer parameters. */=0A=
 	for (i =3D 0; i < config->RxRingNum; i++)=0A=
 		atomic_set(&sp->rx_bufs_left[i], 0);=0A=
 =0A=
 	/*  initialize the shared memory used by the NIC and the host */=0A=
-	if (initSharedMem(sp)) {=0A=
+	if (init_shared_mem(sp)) {=0A=
 		DBG_PRINT(ERR_DBG, "%s: Memory allocation failed\n",=0A=
 			  dev->name);=0A=
 		goto mem_alloc_failed;=0A=
@@ -4208,22 +4944,26 @@=0A=
 	dev->set_multicast_list =3D &s2io_set_multicast;=0A=
 	dev->do_ioctl =3D &s2io_ioctl;=0A=
 	dev->change_mtu =3D &s2io_change_mtu;=0A=
+#ifdef SET_ETHTOOL_OPS=0A=
 	SET_ETHTOOL_OPS(dev, &netdev_ethtool_ops);=0A=
-=0A=
+#endif=0A=
 	/*=0A=
 	 * will use eth_mac_addr() for  dev->set_mac_address=0A=
 	 * mac address will be set every time dev->open() is called=0A=
 	 */=0A=
 #ifdef CONFIG_S2IO_NAPI=0A=
 	dev->poll =3D s2io_poll;=0A=
-	dev->weight =3D 128;	/* For now. */=0A=
+	dev->weight =3D 90;	/* For now. */=0A=
 #endif=0A=
 =0A=
-	dev->features |=3D NETIF_F_SG | NETIF_F_IP_CSUM;=0A=
+	dev->features |=3D NETIF_F_SG;=0A=
+	if (cksum_offload_enable)=0A=
+		dev->features |=3D NETIF_F_IP_CSUM;=0A=
 	if (sp->high_dma_flag =3D=3D TRUE)=0A=
 		dev->features |=3D NETIF_F_HIGHDMA;=0A=
 #ifdef NETIF_F_TSO=0A=
-	dev->features |=3D NETIF_F_TSO;=0A=
+	if (lso_enable)=0A=
+		dev->features |=3D NETIF_F_TSO;=0A=
 #endif=0A=
 =0A=
 	dev->tx_timeout =3D &s2io_tx_watchdog;=0A=
@@ -4233,11 +4973,6 @@=0A=
 	INIT_WORK(&sp->set_link_task,=0A=
 		  (void (*)(void *)) s2io_set_link, sp);=0A=
 =0A=
-	if (register_netdev(dev)) {=0A=
-		DBG_PRINT(ERR_DBG, "Device registration failed\n");=0A=
-		goto register_failed;=0A=
-	}=0A=
-=0A=
 	pci_save_state(sp->pdev, sp->config_space);=0A=
 =0A=
 	/* Setting swapper control on the NIC, for proper reset operation */=0A=
@@ -4248,10 +4983,11 @@=0A=
 	}=0A=
 =0A=
 	/* Fix for all "FFs" MAC address problems observed on Alpha platforms =
*/=0A=
-	FixMacAddress(sp);=0A=
+	fix_mac_address(sp);=0A=
 	s2io_reset(sp);=0A=
 =0A=
-	/* Setting swapper control on the NIC, so the MAC address can be read.=0A=
+	/*=0A=
+	 * Setting swapper control on the NIC, so the MAC address can be read.=0A=
 	 */=0A=
 	if (s2io_set_swapper(sp)) {=0A=
 		DBG_PRINT(ERR_DBG,=0A=
@@ -4260,50 +4996,54 @@=0A=
 		goto set_swap_failed;=0A=
 	}=0A=
 =0A=
-	/*  MAC address initialization.=0A=
-	 *  For now only one mac address will be read and used.=0A=
+	/*  =0A=
+	 * MAC address initialization.=0A=
+	 * For now only one mac address will be read and used.=0A=
 	 */=0A=
 	bar0 =3D (XENA_dev_config_t *) sp->bar0;=0A=
 	val64 =3D RMAC_ADDR_CMD_MEM_RD | RMAC_ADDR_CMD_MEM_STROBE_NEW_CMD |=0A=
 	    RMAC_ADDR_CMD_MEM_OFFSET(0 + MAC_MAC_ADDR_START_OFFSET);=0A=
 	writeq(val64, &bar0->rmac_addr_cmd_mem);=0A=
-	waitForCmdComplete(sp);=0A=
+	wait_for_cmd_complete(sp);=0A=
 =0A=
 	tmp64 =3D readq(&bar0->rmac_addr_data0_mem);=0A=
 	mac_down =3D (u32) tmp64;=0A=
 	mac_up =3D (u32) (tmp64 >> 32);=0A=
 =0A=
-	memset(sp->defMacAddr[0].mac_addr, 0, sizeof(ETH_ALEN));=0A=
+	memset(sp->def_mac_addr[0].mac_addr, 0, sizeof(ETH_ALEN));=0A=
 =0A=
-	sp->defMacAddr[0].mac_addr[3] =3D (u8) (mac_up);=0A=
-	sp->defMacAddr[0].mac_addr[2] =3D (u8) (mac_up >> 8);=0A=
-	sp->defMacAddr[0].mac_addr[1] =3D (u8) (mac_up >> 16);=0A=
-	sp->defMacAddr[0].mac_addr[0] =3D (u8) (mac_up >> 24);=0A=
-	sp->defMacAddr[0].mac_addr[5] =3D (u8) (mac_down >> 16);=0A=
-	sp->defMacAddr[0].mac_addr[4] =3D (u8) (mac_down >> 24);=0A=
+	sp->def_mac_addr[0].mac_addr[3] =3D (u8) (mac_up);=0A=
+	sp->def_mac_addr[0].mac_addr[2] =3D (u8) (mac_up >> 8);=0A=
+	sp->def_mac_addr[0].mac_addr[1] =3D (u8) (mac_up >> 16);=0A=
+	sp->def_mac_addr[0].mac_addr[0] =3D (u8) (mac_up >> 24);=0A=
+	sp->def_mac_addr[0].mac_addr[5] =3D (u8) (mac_down >> 16);=0A=
+	sp->def_mac_addr[0].mac_addr[4] =3D (u8) (mac_down >> 24);=0A=
 =0A=
 	DBG_PRINT(INIT_DBG,=0A=
 		  "DEFAULT MAC ADDR:0x%02x-%02x-%02x-%02x-%02x-%02x\n",=0A=
-		  sp->defMacAddr[0].mac_addr[0],=0A=
-		  sp->defMacAddr[0].mac_addr[1],=0A=
-		  sp->defMacAddr[0].mac_addr[2],=0A=
-		  sp->defMacAddr[0].mac_addr[3],=0A=
-		  sp->defMacAddr[0].mac_addr[4],=0A=
-		  sp->defMacAddr[0].mac_addr[5]);=0A=
+		  sp->def_mac_addr[0].mac_addr[0],=0A=
+		  sp->def_mac_addr[0].mac_addr[1],=0A=
+		  sp->def_mac_addr[0].mac_addr[2],=0A=
+		  sp->def_mac_addr[0].mac_addr[3],=0A=
+		  sp->def_mac_addr[0].mac_addr[4],=0A=
+		  sp->def_mac_addr[0].mac_addr[5]);=0A=
 =0A=
 	/*  Set the factory defined MAC address initially   */=0A=
 	dev->addr_len =3D ETH_ALEN;=0A=
-	memcpy(dev->dev_addr, sp->defMacAddr, ETH_ALEN);=0A=
+	memcpy(dev->dev_addr, sp->def_mac_addr, ETH_ALEN);=0A=
 =0A=
 	/*  Initialize the tasklet status flag */=0A=
 	atomic_set(&(sp->tasklet_status), 0);=0A=
 =0A=
 =0A=
 	/* Initialize spinlocks */=0A=
-	spin_lock_init(&sp->isr_lock);=0A=
 	spin_lock_init(&sp->tx_lock);=0A=
+#ifndef CONFIG_S2IO_NAPI=0A=
+	spin_lock_init(&sp->put_lock);=0A=
+#endif=0A=
 =0A=
-	/* SXE-002: Configure link and activity LED to init state =0A=
+	/* =0A=
+	 * SXE-002: Configure link and activity LED to init state =0A=
 	 * on driver load. =0A=
 	 */=0A=
 	subid =3D sp->pdev->subsystem_device;=0A=
@@ -4316,27 +5056,47 @@=0A=
 		val64 =3D readq(&bar0->gpio_control);=0A=
 	}=0A=
 =0A=
-	/* Make Link state as off at this point, when the Link change =0A=
+	sp->rx_csum =3D 1;	/* Rx chksum verify enabled by default */=0A=
+=0A=
+#ifdef SNMP_SUPPORT=0A=
+	if (!s2io_bdsnmp_init(dev))=0A=
+		DBG_PRINT(INIT_DBG,=0A=
+			  "Error Creating Proc directory for SNMP\n");=0A=
+=0A=
+	sp->nLinkStatus =3D 1;=0A=
+#ifdef NETIF_F_TSO=0A=
+	sp->nFeature =3D 1;=0A=
+#endif=0A=
+	memcpy(sp->cVersion, s2io_driver_version + 8, 20);=0A=
+	memcpy(sp->cName, s2io_driver_name, 20);=0A=
+	struct timeval tm;=0A=
+	do_gettimeofday(&tm);=0A=
+	sp->lDate =3D tm.tv_sec;=0A=
+#endif=0A=
+=0A=
+	if (register_netdev(dev)) {=0A=
+		DBG_PRINT(ERR_DBG, "Device registration failed\n");=0A=
+		goto register_failed;=0A=
+	}=0A=
+=0A=
+	/* =0A=
+	 * Make Link state as off at this point, when the Link change =0A=
 	 * interrupt comes the state will be automatically changed to =0A=
 	 * the right state.=0A=
 	 */=0A=
 	netif_carrier_off(dev);=0A=
 	sp->last_link_state =3D LINK_DOWN;=0A=
 =0A=
-	sp->rx_csum =3D 1;	/* Rx chksum verify enabled by default */=0A=
-=0A=
 	return 0;=0A=
 =0A=
-      set_swap_failed:=0A=
-	unregister_netdev(dev);=0A=
       register_failed:=0A=
+      set_swap_failed:=0A=
 	iounmap(sp->bar1);=0A=
       bar1_remap_failed:=0A=
 	iounmap(sp->bar0);=0A=
       bar0_remap_failed:=0A=
       mem_alloc_failed:=0A=
-	freeSharedMem(sp);=0A=
-      init_failed:=0A=
+	free_shared_mem(sp);=0A=
 	pci_disable_device(pdev);=0A=
 	pci_release_regions(pdev);=0A=
 	pci_set_drvdata(pdev, NULL);=0A=
@@ -4345,16 +5105,15 @@=0A=
 	return -ENODEV;=0A=
 }=0A=
 =0A=
-/*=0A=
-*  Input Argument/s: =0A=
-*   pdev - structure containing the PCI related information of the =
device.=0A=
-*  Return value:=0A=
-*  void=0A=
-*  Description:=0A=
-*  This function is called by the Pci subsystem to release a PCI device =0A=
-*  and free up all resource held up by the device. This could be in =
response =0A=
-*  to a Hot plug event or when the driver is to be removed from memory.=0A=
-*/=0A=
+/**=0A=
+ * s2io_rem_nic - Free the PCI device =0A=
+ * @pdev: structure containing the PCI related information of the =
device.=0A=
+ * Description: This function is called by the Pci subsystem to release =
a =0A=
+ * PCI device and free up all resource held up by the device. This could=0A=
+ * be in response to a Hot plug event or when the driver is to be =
removed =0A=
+ * from memory.=0A=
+ */=0A=
+=0A=
 static void __devexit s2io_rem_nic(struct pci_dev *pdev)=0A=
 {=0A=
 	struct net_device *dev =3D=0A=
@@ -4365,24 +5124,41 @@=0A=
 		DBG_PRINT(ERR_DBG, "Driver Data is NULL!!\n");=0A=
 		return;=0A=
 	}=0A=
+=0A=
 	sp =3D dev->priv;=0A=
-	freeSharedMem(sp);=0A=
+	unregister_netdev(dev);=0A=
+=0A=
+	free_shared_mem(sp);=0A=
 	iounmap(sp->bar0);=0A=
 	iounmap(sp->bar1);=0A=
 	pci_disable_device(pdev);=0A=
 	pci_release_regions(pdev);=0A=
 	pci_set_drvdata(pdev, NULL);=0A=
-=0A=
-	unregister_netdev(dev);=0A=
+#ifdef SNMP_SUPPORT=0A=
+	s2io_bdsnmp_rem(dev);=0A=
+#endif=0A=
 =0A=
 	free_netdev(dev);=0A=
 }=0A=
 =0A=
+/**=0A=
+ * s2io_starter - Entry point for the driver=0A=
+ * Description: This function is the entry point for the driver. It =
verifies=0A=
+ * the module loadable parameters and initializes PCI configuration =
space.=0A=
+ */=0A=
+=0A=
 int __init s2io_starter(void)=0A=
 {=0A=
+	if (verify_load_parm())=0A=
+		return -ENODEV;=0A=
 	return pci_module_init(&s2io_driver);=0A=
 }=0A=
 =0A=
+/**=0A=
+ * s2io_closer - Cleanup routine for the driver =0A=
+ * Description: This function is the cleanup routine for the driver. It =
unregist * ers the driver.=0A=
+ */=0A=
+=0A=
 void s2io_closer(void)=0A=
 {=0A=
 	pci_unregister_driver(&s2io_driver);=0A=
@@ -4391,3 +5167,571 @@=0A=
 =0A=
 module_init(s2io_starter);=0A=
 module_exit(s2io_closer);=0A=
+/**=0A=
+ * verify_load_parm -  verifies the module loadable parameters=0A=
+ * Descriptions: Verifies the module loadable paramters and initializes =
the=0A=
+ * Tx Fifo, Rx Ring and other paramters.=0A=
+ */=0A=
+=0A=
+int verify_load_parm()=0A=
+{=0A=
+	int fail =3D 0;=0A=
+	if (!((lso_enable =3D=3D 0) || (lso_enable =3D=3D 1))) {=0A=
+		printk("lso_enable can be either '1' or '0'\n");=0A=
+		fail =3D 1;=0A=
+	}=0A=
+#ifndef CONFIG_S2IO_NAPI=0A=
+	if ((indicate_max_pkts > (0xFFFFFFFF))) {=0A=
+		printk=0A=
+		    ("indicate_max_pkts can take value greater than zero but less =
than 2power(32)\n");=0A=
+		fail =3D 1;=0A=
+	}=0A=
+#endif=0A=
+	if (!((cksum_offload_enable =3D=3D 0) || (cksum_offload_enable =3D=3D =
1))) {=0A=
+		printk("cksum_offload_enable can be only '0' or '1' \n");=0A=
+		fail =3D 1;=0A=
+	}=0A=
+	if ((TxFifoNum =3D=3D 0) || (TxFifoNum > 8)) {=0A=
+		printk("TxFifoNum can take value from 1 to 8\n");=0A=
+		fail =3D 1;=0A=
+	}=0A=
+	switch (TxFifoNum) {=0A=
+	case 8:=0A=
+		if ((TxFIFOLen_7 =3D=3D 0) || TxFIFOLen_7 > 8192) {=0A=
+			printk=0A=
+			    ("TxFIFOLen_7 can take value from 1 to 8192\n");=0A=
+			fail =3D 1;=0A=
+		}=0A=
+	case 7:=0A=
+		if ((TxFIFOLen_6 =3D=3D 0) || TxFIFOLen_6 > 8192) {=0A=
+			printk=0A=
+			    ("TxFIFOLen_6 can take value from 1 to 8192\n");=0A=
+			fail =3D 1;=0A=
+		}=0A=
+	case 6:=0A=
+		if ((TxFIFOLen_5 =3D=3D 0) || TxFIFOLen_5 > 8192) {=0A=
+			printk=0A=
+			    ("TxFIFOLen_5 can take value from 1 to 8192\n");=0A=
+			fail =3D 1;=0A=
+		}=0A=
+	case 5:=0A=
+		if ((TxFIFOLen_4 =3D=3D 0) || TxFIFOLen_4 > 8192) {=0A=
+			printk=0A=
+			    ("TxFIFOLen_4 can take value from 1 to 8192\n");=0A=
+			fail =3D 1;=0A=
+		}=0A=
+	case 4:=0A=
+		if ((TxFIFOLen_3 =3D=3D 0) || TxFIFOLen_3 > 8192) {=0A=
+			printk=0A=
+			    ("TxFIFOLen_3 can take value from 1 to 8192\n");=0A=
+			fail =3D 1;=0A=
+		}=0A=
+	case 3:=0A=
+		if ((TxFIFOLen_2 =3D=3D 0) || TxFIFOLen_2 > 8192) {=0A=
+			printk=0A=
+			    ("TxFIFOLen_2 can take value from 1 to 8192\n");=0A=
+			fail =3D 1;=0A=
+		}=0A=
+	case 2:=0A=
+		if ((TxFIFOLen_1 =3D=3D 0) || TxFIFOLen_1 > 8192) {=0A=
+			printk=0A=
+			    ("TxFIFOLen_1 can take value from 1 to 8192\n");=0A=
+			fail =3D 1;=0A=
+		}=0A=
+	case 1:=0A=
+		if ((TxFIFOLen_0 =3D=3D 0) || TxFIFOLen_0 > 8192) {=0A=
+			printk=0A=
+			    ("TxFIFOLen_0 can take value from 1 to 8192\n");=0A=
+			fail =3D 1;=0A=
+		}=0A=
+	}=0A=
+	if ((MaxTxDs > 32) || (MaxTxDs < 1)) {=0A=
+		printk("MaxTxDs can take falue from 1 to 32\n");=0A=
+		fail =3D 1;=0A=
+	}=0A=
+	if ((RxRingNum > 8) || (RxRingNum < 1)) {=0A=
+		printk("RxRingNum can take falue from 1 to 8\n");=0A=
+		fail =3D 1;=0A=
+	}=0A=
+	switch (RxRingNum) {=0A=
+	case 8:=0A=
+		if (RxRingSz_7 < 1) {=0A=
+			printk=0A=
+			    ("RxRingSz_7 can take value greater than 0\n");=0A=
+			fail =3D 1;=0A=
+		}=0A=
+	case 7:=0A=
+		if (RxRingSz_6 < 1) {=0A=
+			printk=0A=
+			    ("RxRingSz_6 can take value greater than 0\n");=0A=
+			fail =3D 1;=0A=
+		}=0A=
+	case 6:=0A=
+		if (RxRingSz_5 < 1) {=0A=
+			printk=0A=
+			    ("RxRingSz_5 can take value greater than 0\n");=0A=
+			fail =3D 1;=0A=
+		}=0A=
+	case 5:=0A=
+		if (RxRingSz_4 < 1) {=0A=
+			printk=0A=
+			    ("RxRingSz_4 can take value greater than 0\n");=0A=
+			fail =3D 1;=0A=
+		}=0A=
+	case 4:=0A=
+		if (RxRingSz_3 < 1) {=0A=
+			printk=0A=
+			    ("RxRingSz_3 can take value greater than 0\n");=0A=
+			fail =3D 1;=0A=
+		}=0A=
+	case 3:=0A=
+		if (RxRingSz_2 < 1) {=0A=
+			printk=0A=
+			    ("RxRingSz_2 can take value greater than 0\n");=0A=
+			fail =3D 1;=0A=
+		}=0A=
+	case 2:=0A=
+		if (RxRingSz_1 < 1) {=0A=
+			printk=0A=
+			    ("RxRingSz_1 can take value greater than 0\n");=0A=
+			fail =3D 1;=0A=
+		}=0A=
+	case 1:=0A=
+		if (RxRingSz_0 < 1) {=0A=
+			printk=0A=
+			    ("RxRingSz_0 can take value greater than 0\n");=0A=
+			fail =3D 1;=0A=
+		}=0A=
+	}=0A=
+	if ((Stats_refresh_time < 1)) {=0A=
+		printk=0A=
+		    ("Stats_refresh_time cannot be less than 1 second \n");=0A=
+		fail =3D 1;=0A=
+	}=0A=
+	if (((rmac_pause_time < 0x10) && (rmac_pause_time !=3D 0)) ||=0A=
+	    (rmac_pause_time > 0xFFFF)) {=0A=
+		printk=0A=
+		    ("rmac_pause_time can take value from 16 to 65535\n");=0A=
+		fail =3D 1;=0A=
+	}=0A=
+	if ((max_splits_trans < 0) || (max_splits_trans > 7)) {=0A=
+		printk("max_splits_trans can take value from 0 to 7\n");=0A=
+		fail =3D 1;=0A=
+	}=0A=
+	if ((mc_pause_threshold_q0q3 > 0xFE)) {=0A=
+		printk("mc_pause_threshold_q0q3 cannot exceed 254\n");=0A=
+		fail =3D 1;=0A=
+	}=0A=
+	if ((mc_pause_threshold_q4q7 > 0xFE)) {=0A=
+		printk("mc_pause_threshold_q4q7 cannot exceed 254\n");=0A=
+		fail =3D 1;=0A=
+	}=0A=
+	if ((latency_timer)=0A=
+	    && ((latency_timer < 8) || (latency_timer > 255))) {=0A=
+		printk("latency_timer can take value from 8 to 255\n");=0A=
+		fail =3D 1;=0A=
+	}=0A=
+	if (max_read_byte_cnt > 3) {=0A=
+		printk("max_read_byte_cnt can take value from 0 to 3\n");=0A=
+		fail =3D 1;=0A=
+	}=0A=
+	if ((shared_splits > 31)) {=0A=
+		printk("shared_splits cannot exceed 31\n");=0A=
+		fail =3D 1;=0A=
+	}=0A=
+	if (rmac_util_period > 0xF) {=0A=
+		printk("rmac_util_period cannot exceed 15\n");=0A=
+		fail =3D 1;=0A=
+	}=0A=
+	if (tmac_util_period > 0xF) {=0A=
+		printk("tmac_util_period cannot exceed 15\n");=0A=
+		fail =3D 1;=0A=
+	}=0A=
+	if ((tx_utilz_periodic > 1) || (rx_utilz_periodic > 1)) {=0A=
+		printk=0A=
+		    ("tx_utilz_periodic & rx_utilz_periodic can be either "=0A=
+		     "'0' or '1'\n");=0A=
+		fail =3D 1;=0A=
+	}=0A=
+	if ((tx_urange_a > 127) || (tx_urange_b > 127)=0A=
+	    || (tx_urange_c > 127)) {=0A=
+		printk=0A=
+		    ("tx_urange_a, tx_urange_b & tx_urange_c can take value "=0A=
+		     "from 0 to 127\n");=0A=
+		fail =3D 1;=0A=
+	}=0A=
+	if ((rx_urange_a > 127) || (rx_urange_b > 127)=0A=
+	    || (rx_urange_c > 127)) {=0A=
+		printk=0A=
+		    ("rx_urange_a, rx_urange_b & rx_urange_c can take value "=0A=
+		     "from 0 to 127\n");=0A=
+		fail =3D 1;=0A=
+	}=0A=
+	if ((tx_ufc_a > 0xffff) || (tx_ufc_b > 0xffff) ||=0A=
+	    (tx_ufc_c > 0xffff) || (tx_ufc_d > 0xffff)) {=0A=
+		printk=0A=
+		    (" tx_ufc_a, tx_ufc_b, tx_ufc_c, tx_ufc_d can take value"=0A=
+		     "from 0 to 65535(0xFFFF)\n");=0A=
+		fail =3D 1;=0A=
+	}=0A=
+	if ((rx_ufc_a > 0xffff) || (rx_ufc_b > 0xffff) ||=0A=
+	    (rx_ufc_c > 0xffff) || (rx_ufc_d > 0xffff)) {=0A=
+		printk=0A=
+		    (" rx_ufc_a, rx_ufc_b, rx_ufc_c, rx_ufc_d can take value"=0A=
+		     "from 0 to 65535(0xFFFF)\n");=0A=
+		fail =3D 1;=0A=
+	}=0A=
+	return fail;=0A=
+}=0A=
+=0A=
+#ifdef SNMP_SUPPORT=0A=
+/**=0A=
+ * fnBaseDrv - Get the driver information=0A=
+ * @pBaseDrv -Pointer to Base driver structure which contains the =
offset =0A=
+ * and length of each of the field.=0A=
+ * Description=0A=
+ * This function copies the driver specific information from the dev =
structure=0A=
+ * to the pBaseDrv stucture. It calculates the number of physical =
adapters by=0A=
+ * parsing the dev_base global variable maintained by the kernel. This =0A=
+ * variable has to read locked before accesing.This function is called =
by=0A=
+ * fnBaseReadProc function.=0A=
+ *=0A=
+ */=0A=
+=0A=
+static void fnBaseDrv(struct stBaseDrv *pBaseDrv, struct net_device =
*dev)=0A=
+{=0A=
+=0A=
+	struct pci_dev *pdev =3D NULL;=0A=
+	struct net_device *ndev;=0A=
+	int nCount =3D 0;=0A=
+	nic_t *sp =3D (nic_t *) dev->priv;=0A=
+=0A=
+	strncpy(pBaseDrv->m_cName, sp->cName, 20);=0A=
+	strncpy(pBaseDrv->m_cVersion, sp->cVersion, 20);=0A=
+	pBaseDrv->m_nStatus =3D sp->nLinkStatus;=0A=
+	pBaseDrv->m_nFeature =3D sp->nFeature;=0A=
+	pBaseDrv->m_nMemorySize =3D sp->nMemorySize;=0A=
+	sprintf(pBaseDrv->m_cDate, "%ld", sp->lDate);=0A=
+	/* =0A=
+	 * Find all the ethernet devices on the system using =0A=
+	 * pci_find_class. Get the private data which will be the =0A=
+	 * net_device structure assigned by the driver.=0A=
+	 */=0A=
+	while ((pdev =3D=0A=
+		pci_find_class((PCI_CLASS_NETWORK_ETHERNET << 8), pdev))) {=0A=
+		ndev =3D (struct net_device *) pci_get_drvdata(pdev);=0A=
+		if (ndev =3D=3D NULL)=0A=
+			break;=0A=
+		memcpy(pBaseDrv->m_stPhyAdap[nCount].m_cName, ndev->name,=0A=
+		       20);=0A=
+		pBaseDrv->m_stPhyAdap[nCount].m_nIndex =3D ndev->ifindex;=0A=
+		nCount++;=0A=
+	}=0A=
+	pBaseDrv->m_nPhyCnt =3D nCount;=0A=
+}=0A=
+=0A=
+/* =0A=
+ *  fnBaseReadProc - Read entry point for the proc file  =0A=
+ *  @page - Buffer pointer where the data is written=0A=
+ *  @start- Pointer to buffer ptr . It is used if the data is more than =
a page=0A=
+ *  @off- the offset to the page where data is written=0A=
+ *  @count - number of bytes to write=0A=
+ *  @eof - to indicate end of file=0A=
+ *  @data - pointer to device structure.=0A=
+ *=0A=
+ * Description - =0A=
+ * This function gets  Base driver specific information from the =
fnBaseDrv =0A=
+ * function and writes into the BDInfo file. This function is called =
whenever =0A=
+ * the user reads the file. The length of data written cannot exceed =
4kb. =0A=
+ * If it exceeds then use the start pointer to write multiple pages=0A=
+ * Return - the length of the string written to proc file=0A=
+ */=0A=
+static int fnBaseReadProc(char *page, char **start, off_t off, int =
count,=0A=
+			  int *eof, void *data)=0A=
+{=0A=
+	struct stBaseDrv *pBaseDrv;=0A=
+	int nLength =3D 0;=0A=
+	int nCount =3D 0;=0A=
+	struct net_device *dev =3D (struct net_device *) data;=0A=
+	int nIndex =3D 0;=0A=
+=0A=
+	pBaseDrv =3D kmalloc(sizeof(struct stBaseDrv), GFP_KERNEL);=0A=
+	if (pBaseDrv =3D=3D NULL) {=0A=
+		printk("Error allocating memory\n");=0A=
+		return -ENOMEM;=0A=
+	}=0A=
+	fnBaseDrv(pBaseDrv, dev);=0A=
+	sprintf(page + nLength, "%-30s%-20s\n", "Base Driver Name",=0A=
+		pBaseDrv->m_cName);=0A=
+	nLength +=3D 51;=0A=
+	if (pBaseDrv->m_nStatus =3D=3D 1)=0A=
+		sprintf(page + nLength, "%-30s%-20s\n", "Load Status",=0A=
+			"Loaded");=0A=
+	else=0A=
+		sprintf(page + nLength, "%-30s%-20s\n", "Load Status",=0A=
+			"UnLoaded");=0A=
+	nLength +=3D 51;=0A=
+	sprintf(page + nLength, "%-30s%-20s\n", "Base Driver Version",=0A=
+		pBaseDrv->m_cVersion);=0A=
+	nLength +=3D 51;=0A=
+=0A=
+	sprintf(page + nLength, "%-30s%-20d\n", "Feature Supported",=0A=
+		pBaseDrv->m_nFeature);=0A=
+	nLength +=3D 51;=0A=
+=0A=
+	sprintf(page + nLength, "%-30s%-20d\n",=0A=
+		"Base Driver Memrory in Bytes", pBaseDrv->m_nMemorySize);=0A=
+	nLength +=3D 51;=0A=
+=0A=
+	sprintf(page + nLength, "%-30s%-20s\n", "Base Driver Date",=0A=
+		pBaseDrv->m_cDate);=0A=
+	nLength +=3D 51;=0A=
+=0A=
+	sprintf(page + nLength, "%-30s%-20d\n", "No of Phy Adapter",=0A=
+		pBaseDrv->m_nPhyCnt);=0A=
+	nLength +=3D 51;=0A=
+	sprintf(page + nLength, "%-20s%-20s\n\n", "Phy Adapter Index",=0A=
+		"Phy Adapter Name");=0A=
+	nLength +=3D 42;=0A=
+=0A=
+	for (nIndex =3D 0, nCount =3D pBaseDrv->m_nPhyCnt; nCount !=3D 0;=0A=
+	     nCount--, nIndex++) {=0A=
+		sprintf(page + nLength, "%-20d%-20s\n",=0A=
+			pBaseDrv->m_stPhyAdap[nIndex].m_nIndex,=0A=
+			pBaseDrv->m_stPhyAdap[nIndex].m_cName);=0A=
+		nLength +=3D 41;=0A=
+	}=0A=
+=0A=
+	*eof =3D 1;=0A=
+	kfree(pBaseDrv);=0A=
+	return nLength;=0A=
+}=0A=
+=0A=
+/* =0A=
+ *  fnPhyAdapReadProc - Read entry point for the proc file  =0A=
+ *  @page - Buffer pointer where the data is written=0A=
+ *  @start- Pointer to buffer ptr . It is used if the data is more than =
a page=0A=
+ *  @off- the offset to the page where data is written=0A=
+ *  @count - number of bytes to write=0A=
+ *  @eof - to indicate end of file=0A=
+ *  @data - pointer to device structure.=0A=
+ *=0A=
+ * Description - =0A=
+ * This function gets  physical adapter information. This function is =
called=0A=
+ * whenever the use* r reads the file. The length of data written cannot=0A=
+ * exceed 4kb. If it exceeds then use the start pointer to write =
multiple page =0A=
+ *=0A=
+ * Return - the length of the string written to proc file=0A=
+ */=0A=
+static int fnPhyAdapReadProc(char *page, char **start, off_t off,=0A=
+			     int count, int *eof, void *data)=0A=
+{=0A=
+=0A=
+	struct stPhyData *pPhyData;=0A=
+	pPhyData =3D kmalloc(sizeof(struct stPhyData), GFP_KERNEL);=0A=
+	if (pPhyData =3D=3D NULL) {=0A=
+		printk("Error allocating memory\n");=0A=
+		return -ENOMEM;=0A=
+	}=0A=
+=0A=
+	struct net_device *pNetDev;=0A=
+	struct net_device_stats *pNetStat;=0A=
+	int nLength =3D 0;=0A=
+	unsigned char cMAC[20];=0A=
+=0A=
+	/* Print the header in the PhyAdap proc file */=0A=
+	sprintf(page + nLength,=0A=
+		=
"%-10s%-22s%-10s%-10s%-22s%-22s%-10s%-10s%-10s%-10s%-10s%-10s%-10s%-10s%-=
10s%-10s%-10s%-10s%-10s%-10s\n",=0A=
+		"Index", "Description", "Mode", "Type", "Speed", "MAC",=0A=
+		"Status", "Slot", "Bus", "IRQ", "Colis", "Multi",=0A=
+		"RxBytes", "RxDrop", "RxError", "RxPacket", "TRxBytes",=0A=
+		"TRxDrop", "TxError", "TxPacket");=0A=
+=0A=
+	/* 237 is the lenght of the above string copied in the page  */=0A=
+	nLength +=3D 237;=0A=
+=0A=
+	struct pci_dev *pdev =3D NULL;=0A=
+	/* =0A=
+	 * pci_find_class will return to the pointer to the pdev structure=0A=
+	 * for all the network devices using PCI_CLASS_NETWORK_ETHERNET.=0A=
+	 * The third argument is pointer to previous pdev structure.Initailly=0A=
+	 * it has to be null=0A=
+	 */=0A=
+	while ((pdev =3D=0A=
+		pci_find_class((PCI_CLASS_NETWORK_ETHERNET << 8), pdev))) {=0A=
+		/* Private data will point to the netdevice structure */=0A=
+		pNetDev =3D (struct net_device *) pci_get_drvdata(pdev);=0A=
+		if (pNetDev =3D=3D NULL)=0A=
+			continue;=0A=
+		if (pNetDev->addr_len !=3D 0) {=0A=
+			pNetStat =3D pNetDev->get_stats(pNetDev);=0A=
+			pPhyData->m_nIndex =3D pNetDev->ifindex;=0A=
+			memcpy(pPhyData->m_cDesc, pNetDev->name, 20);=0A=
+			pPhyData->m_nMode =3D 0;=0A=
+			pPhyData->m_nType =3D 0;=0A=
+			switch (pPhyData->m_nType) {=0A=
+				/* case IFT_ETHER:=0A=
+				   memcpy(pPhyData->m_cSpeed,"10000000",20);=0A=
+				   break;=0A=
+=0A=
+				   case 9:=0A=
+				   memcpy(pPhyData->m_cSpeed,"4000000",20);=0A=
+				   break; */=0A=
+			default:=0A=
+				memcpy(pPhyData->m_cSpeed, "10000000", 20);=0A=
+				break;=0A=
+			}=0A=
+			memcpy(pPhyData->m_cPMAC, pNetDev->dev_addr,=0A=
+			       ETH_ALEN);=0A=
+			memcpy(pPhyData->m_cCMAC, pNetDev->dev_addr,=0A=
+			       ETH_ALEN);=0A=
+			pPhyData->m_nLinkStatus =3D=0A=
+			    test_bit(__LINK_STATE_START, &pNetDev->state);=0A=
+			pPhyData->m_nPCISlot =3D PCI_SLOT(pdev->devfn);=0A=
+			pPhyData->m_nPCIBus =3D pdev->bus->number;=0A=
+			pPhyData->m_nIRQ =3D pNetDev->irq;=0A=
+			pPhyData->m_nCollision =3D pNetStat->collisions;=0A=
+			pPhyData->m_nMulticast =3D pNetStat->multicast;=0A=
+=0A=
+			pPhyData->m_nRxBytes =3D pNetStat->rx_bytes;=0A=
+			pPhyData->m_nRxDropped =3D pNetStat->rx_dropped;=0A=
+			pPhyData->m_nRxErrors =3D pNetStat->rx_errors;=0A=
+			pPhyData->m_nRxPackets =3D pNetStat->rx_packets;=0A=
+=0A=
+			pPhyData->m_nTxBytes =3D pNetStat->tx_bytes;=0A=
+			pPhyData->m_nTxDropped =3D pNetStat->tx_dropped;=0A=
+			pPhyData->m_nTxErrors =3D pNetStat->tx_errors;=0A=
+			pPhyData->m_nTxPackets =3D pNetStat->tx_packets;=0A=
+=0A=
+			sprintf(cMAC, "%02x:%02x:%02x:%02x:%02x:%02x",=0A=
+				pPhyData->m_cPMAC[0], pPhyData->m_cPMAC[1],=0A=
+				pPhyData->m_cPMAC[2], pPhyData->m_cPMAC[3],=0A=
+				pPhyData->m_cPMAC[4],=0A=
+				pPhyData->m_cPMAC[5]);=0A=
+=0A=
+			sprintf(page + nLength,=0A=
+				=
"%-10d%-22s%-10d%-10d%-22s%-22s%-10d%-10d%-10d%-10d%-10d%-10d%-10d%-10d%-=
10d%-10d%-10d%-10d%-10d%-10d\n",=0A=
+				pPhyData->m_nIndex, pPhyData->m_cDesc,=0A=
+				pPhyData->m_nMode, pPhyData->m_nType,=0A=
+				pPhyData->m_cSpeed, cMAC,=0A=
+				pPhyData->m_nLinkStatus,=0A=
+				pPhyData->m_nPCISlot, pPhyData->m_nPCIBus,=0A=
+				pPhyData->m_nIRQ, pPhyData->m_nCollision,=0A=
+				pPhyData->m_nMulticast,=0A=
+				pPhyData->m_nRxBytes,=0A=
+				pPhyData->m_nRxDropped,=0A=
+				pPhyData->m_nRxErrors,=0A=
+				pPhyData->m_nRxPackets,=0A=
+				pPhyData->m_nTxBytes,=0A=
+				pPhyData->m_nTxDropped,=0A=
+				pPhyData->m_nTxErrors,=0A=
+				pPhyData->m_nTxPackets);=0A=
+			nLength +=3D 237;=0A=
+		}=0A=
+	}=0A=
+=0A=
+	*eof =3D 1;=0A=
+=0A=
+	kfree(pPhyData);=0A=
+	return nLength;=0A=
+}=0A=
+=0A=
+/* =0A=
+ * s2io_bdsnmp_init - Entry point to create proc file=0A=
+ * @dev-  Pointer to net device structure passed by the driver.=0A=
+ * Return =0A=
+ * Success If creates all the files=0A=
+ * ERROR_PROC_ENTRY /ERROR_PROC_DIR Error If could not create all the =
files=0A=
+ * Description=0A=
+ * This functon is called when the driver is loaded. It creates the S2IO=0A=
+ * proc file system in the /proc/net/ directory. This directory is used =
to =0A=
+ * store the info about the base driver afm driver, lacp, vlan  and =
nplus.=0A=
+ * It checks if S2IO directory already exists else creates it and =
creates =0A=
+ * the files BDInfo  files and assiciates read function to each of the =
files.=0A=
+ */=0A=
+=0A=
+int s2io_bdsnmp_init(struct net_device *dev)=0A=
+{=0A=
+	struct proc_dir_entry *S2ioDir;=0A=
+	struct proc_dir_entry *BaseDrv;=0A=
+	struct proc_dir_entry *PhyAdap;=0A=
+	int nLength =3D 0;=0A=
+=0A=
+	nLength =3D strlen(S2IODIRNAME);=0A=
+	/* IF the directory already exists then just return */=0A=
+	for (S2ioDir =3D proc_net->subdir; S2ioDir !=3D NULL;=0A=
+	     S2ioDir =3D S2ioDir->next) {=0A=
+		if ((S2ioDir->namelen =3D=3D nLength)=0A=
+		    && (!memcmp(S2ioDir->name, S2IODIRNAME, nLength)))=0A=
+			break;=0A=
+	}=0A=
+	if (S2ioDir =3D=3D NULL)=0A=
+		/* Create the s2io directory */=0A=
+		if (!=0A=
+		    (S2ioDir =3D=0A=
+		     create_proc_entry(S2IODIRNAME, S_IFDIR, proc_net))) {=0A=
+			DBG_PRINT(INIT_DBG,=0A=
+				  "Error Creating Proc directory for SNMP\n");=0A=
+			return ERROR_PROC_DIR;=0A=
+		}=0A=
+	/* =0A=
+	 * Create the BDInfo file to store driver info and associate =0A=
+	 * read funtion.=0A=
+	 */=0A=
+	if (!=0A=
+	    (BaseDrv =3D=0A=
+	     create_proc_read_entry(BDFILENAME, S_IFREG | S_IRUSR, S2ioDir,=0A=
+				    fnBaseReadProc, (void *) dev))) {=0A=
+		DBG_PRINT(INIT_DBG,=0A=
+			  "Error Creating Proc File for Base Drvr\n");=0A=
+		return ERROR_PROC_ENTRY;=0A=
+	}=0A=
+	if (!=0A=
+	    (PhyAdap =3D=0A=
+	     create_proc_read_entry(PADAPFILENAME, S_IFREG | S_IRUSR,=0A=
+				    S2ioDir, fnPhyAdapReadProc,=0A=
+				    (void *) dev))) {=0A=
+		DBG_PRINT(INIT_DBG,=0A=
+			  "Error Creating Proc File for Phys Adap\n");=0A=
+		return ERROR_PROC_ENTRY;=0A=
+	}=0A=
+=0A=
+=0A=
+	return SUCCESS;=0A=
+}=0A=
+=0A=
+/**=0A=
+ * s2io_bdsnmp_rem : Removes the proc file entry=0A=
+ * @dev - pointer to netdevice structre=0A=
+ * Return - void=0A=
+ * Description=0A=
+ * This functon is called when the driver is Unloaded. It checks if the =0A=
+ * S2IO directoy exists and deletes the files in the reverse order of =0A=
+ * creation.=0A=
+ */=0A=
+=0A=
+void s2io_bdsnmp_rem(struct net_device *dev)=0A=
+{=0A=
+	int nLength =3D 0;=0A=
+	struct proc_dir_entry *S2ioDir;=0A=
+	nLength =3D strlen(S2IODIRNAME);=0A=
+	/* =0A=
+	 * Check if the S2IO directory exists or not and then delete =0A=
+	 * all the files in the S2IO Directory =0A=
+	 */=0A=
+	for (S2ioDir =3D proc_net->subdir; S2ioDir !=3D NULL;=0A=
+	     S2ioDir =3D S2ioDir->next) {=0A=
+		if ((S2ioDir->namelen =3D=3D nLength)=0A=
+		    && (!memcmp(S2ioDir->name, S2IODIRNAME, nLength)))=0A=
+=0A=
+			break;=0A=
+	}=0A=
+	if (S2ioDir =3D=3D NULL)=0A=
+		return;=0A=
+	remove_proc_entry(BDFILENAME, S2ioDir);=0A=
+	remove_proc_entry(PADAPFILENAME, S2ioDir);=0A=
+	if (S2ioDir->subdir =3D=3D NULL) {=0A=
+		remove_proc_entry(S2IODIRNAME, proc_net);=0A=
+	}=0A=
+}=0A=
+#endif=0A=
diff -urN vanilla_linux-2.6.7/drivers/net/s2io.h =
linux-2.6.7/drivers/net/s2io.h=0A=
--- vanilla_linux-2.6.7/drivers/net/s2io.h	2004-06-15 22:19:09.000000000 =
-0700=0A=
+++ linux-2.6.7/drivers/net/s2io.h	2004-09-08 12:55:02.000000000 -0700=0A=
@@ -16,6 +16,7 @@=0A=
 #define TBD 0=0A=
 #define BIT(loc)		(0x8000000000000000ULL >> (loc))=0A=
 #define vBIT(val, loc, sz)	(((u64)val) << (64-loc-sz))=0A=
+#define INV(d)  ((d&0xff)<<24) | (((d>>8)&0xff)<<16) | =
(((d>>16)&0xff)<<8)| ((d>>24)&0xff)=0A=
 =0A=
 #ifndef BOOL=0A=
 #define BOOL    int=0A=
@@ -49,11 +50,13 @@=0A=
 #define ALIGN_SIZE  			127=0A=
 #define	PCIX_COMMAND_REGISTER	0x62=0A=
 =0A=
+#ifndef SET_ETHTOOL_OPS=0A=
+#define SUPPORTED_10000baseT_Full (1 << 12)=0A=
+#endif=0A=
+=0A=
 /*=0A=
  * Debug related variables.=0A=
  */=0A=
-#define DEBUG_ON TRUE=0A=
-=0A=
 /* different debug levels. */=0A=
 #define	ERR_DBG		0=0A=
 #define	INIT_DBG	1=0A=
@@ -375,7 +378,7 @@=0A=
 	u32 TxFIFONum;		/*Number of Tx FIFOs */=0A=
 #define MAX_TX_FIFOS 8=0A=
 =0A=
-	tx_fifo_config_t TxCfg[MAX_TX_FIFOS];	/*Per-Tx FIFO config */=0A=
+	tx_fifo_config_t tx_cfg[MAX_TX_FIFOS];	/*Per-Tx FIFO config */=0A=
 	u32 MaxTxDs;		/*Max no. of Tx buffer descriptor per TxDL */=0A=
 	BOOL TxVLANEnable;	/*TRUE: Insert VLAN ID, FALSE: Don't insert */=0A=
 #define TX_REQ_TIMEOUT_DEFAULT          0x0=0A=
@@ -403,7 +406,7 @@=0A=
 #define MAX_RX_RINGS 8=0A=
 #define MAX_RX_BLOCKS_PER_RING  150=0A=
 =0A=
-	rx_ring_config_t RxCfg[MAX_RX_RINGS];	/*Per-Rx Ring config */=0A=
+	rx_ring_config_t rx_cfg[MAX_RX_RINGS];	/*Per-Rx Ring config */=0A=
 	BOOL RxVLANEnable;	/*TRUE: Strip off VLAN tag from the frame,=0A=
 				   FALSE: Don't strip off VLAN tag */=0A=
 =0A=
@@ -492,6 +495,12 @@=0A=
 	u64 Host_Control;	/* reserved for host */=0A=
 } TxD_t;=0A=
 =0A=
+/* Structure to hold the phy and virt addr of every TxDL. */=0A=
+typedef struct list_info_hold {=0A=
+	dma_addr_t list_phy_addr;=0A=
+	void *list_virt_addr;=0A=
+} list_info_hold_t;=0A=
+=0A=
 /* Rx descriptor structure */=0A=
 typedef struct _RxD_t {=0A=
 	u64 Host_Control;	/* reserved for host */=0A=
@@ -508,36 +517,80 @@=0A=
 #define RXD_GET_L4_CKSUM(val)   ((u16)(val) & 0xFFFF)=0A=
 =0A=
 	u64 Control_2;=0A=
+#ifndef CONFIG_2BUFF_MODE=0A=
 #define MASK_BUFFER0_SIZE       vBIT(0xFFFF,0,16)=0A=
 #define SET_BUFFER0_SIZE(val)   vBIT(val,0,16)=0A=
+#else=0A=
+#define MASK_BUFFER0_SIZE       vBIT(0xFF,0,16)=0A=
+#define MASK_BUFFER1_SIZE       vBIT(0xFFFF,16,16)=0A=
+#define MASK_BUFFER2_SIZE       vBIT(0xFFFF,32,16)=0A=
+#define SET_BUFFER0_SIZE(val)   vBIT(val,8,8)=0A=
+#define SET_BUFFER1_SIZE(val)   vBIT(val,16,16)=0A=
+#define SET_BUFFER2_SIZE(val)   vBIT(val,32,16)=0A=
+#endif=0A=
+=0A=
 #define MASK_VLAN_TAG           vBIT(0xFFFF,48,16)=0A=
 #define SET_VLAN_TAG(val)       vBIT(val,48,16)=0A=
 #define SET_NUM_TAG(val)       vBIT(val,16,32)=0A=
 =0A=
+#ifndef CONFIG_2BUFF_MODE=0A=
 #define RXD_GET_BUFFER0_SIZE(Control_2) (u64)((Control_2 & =
vBIT(0xFFFF,0,16)))=0A=
-/*    =0A=
-#define TXD_GET_BUFFER1_SIZE(Control_2) (u16)((Control_2 & =
MASK_BUFFER1_SIZE) >> (63-31))  =0A=
-#define TXD_GET_BUFFER2_SIZE(Control_2) (u16)((Control_2 & =
MASK_BUFFER2_SIZE) >> (63-47))  =0A=
-*/=0A=
+#else=0A=
+#define RXD_GET_BUFFER0_SIZE(Control_2) (u8)((Control_2 & =
MASK_BUFFER0_SIZE) \=0A=
+							>> 48)=0A=
+#define RXD_GET_BUFFER1_SIZE(Control_2) (u16)((Control_2 & =
MASK_BUFFER1_SIZE) \=0A=
+							>> 32)=0A=
+#define RXD_GET_BUFFER2_SIZE(Control_2) (u16)((Control_2 & =
MASK_BUFFER2_SIZE) \=0A=
+							>> 16)=0A=
+#define BUF0_LEN	40=0A=
+#define BUF1_LEN	1=0A=
+#endif=0A=
+=0A=
 	u64 Buffer0_ptr;=0A=
+#ifdef CONFIG_2BUFF_MODE=0A=
+	u64 Buffer1_ptr;=0A=
+	u64 Buffer2_ptr;=0A=
+#endif=0A=
 } RxD_t;=0A=
 =0A=
-=0A=
 /* Structure that represents the Rx descriptor block which contains =0A=
  * 128 Rx descriptors.=0A=
  */=0A=
+#ifndef CONFIG_2BUFF_MODE=0A=
 typedef struct _RxD_block {=0A=
 #define MAX_RXDS_PER_BLOCK             127=0A=
 	RxD_t rxd[MAX_RXDS_PER_BLOCK];=0A=
 =0A=
 	u64 reserved_0;=0A=
 #define END_OF_BLOCK    0xFEFFFFFFFFFFFFFFULL=0A=
-	u64 reserved_1;		/* 0xFEFFFFFFFFFFFFFF to mark last Rxd in this blk */=0A=
-	u64 reserved_2_pNext_RxD_block;	/*@ Logical ptr to next */=0A=
-	u64 pNext_RxD_Blk_physical;	/* Buff0_ptr.=0A=
-					   In a 32 bit arch the upper 32 bits =0A=
-					   should be 0 */=0A=
+	u64 reserved_1;		/* 0xFEFFFFFFFFFFFFFF to mark last =0A=
+				 * Rxd in this blk */=0A=
+	u64 reserved_2_pNext_RxD_block;	/* Logical ptr to next */=0A=
+	u64 pNext_RxD_Blk_physical;	/* Buff0_ptr.In a 32 bit arch=0A=
+					 * the upper 32 bits should =0A=
+					 * be 0 */=0A=
+} RxD_block_t;=0A=
+#else=0A=
+typedef struct _RxD_block {=0A=
+#define MAX_RXDS_PER_BLOCK             85=0A=
+	RxD_t rxd[MAX_RXDS_PER_BLOCK];=0A=
+=0A=
+#define END_OF_BLOCK    0xFEFFFFFFFFFFFFFFULL=0A=
+	u64 reserved_1;		/* 0xFEFFFFFFFFFFFFFF to mark last Rxd =0A=
+				 * in this blk */=0A=
+	u64 pNext_RxD_Blk_physical;	/* Phy ponter to next blk. */=0A=
 } RxD_block_t;=0A=
+#define SIZE_OF_BLOCK	4096=0A=
+=0A=
+/* Structure to hold virtual addresses of Buf0 and Buf1 in =0A=
+ * 2buf mode. */=0A=
+typedef struct bufAdd {=0A=
+	void *ba_0_org;=0A=
+	void *ba_1_org;=0A=
+	void *ba_0;=0A=
+	void *ba_1;=0A=
+} buffAdd_t;=0A=
+#endif=0A=
 =0A=
 /* Structure which stores all the MAC control parameters */=0A=
 =0A=
@@ -570,8 +623,6 @@=0A=
 typedef struct mac_info {=0A=
 /* rx side stuff */=0A=
 	u32 rxd_ring_mem_sz;=0A=
-	RxD_t *RxRing[MAX_RX_RINGS];	/* Logical Rx ring pointers */=0A=
-	dma_addr_t RxRing_Phy[MAX_RX_RINGS];=0A=
 =0A=
 	/* Put pointer info which indictes which RxD has to be replenished =0A=
 	 * with a new buffer.=0A=
@@ -584,6 +635,9 @@=0A=
 	rx_curr_get_info_t rx_curr_get_info[MAX_RX_RINGS];=0A=
 =0A=
 	u16 rmac_pause_time;=0A=
+	u16 mc_pause_threshold_q0q3;=0A=
+	u16 mc_pause_threshold_q4q7;=0A=
+=0A=
 =0A=
 	/* this will be used in receive function, this decides which ring would=0A=
 	   be processed first. eg: ring with priority value 0 (highest) should=0A=
@@ -618,7 +672,7 @@=0A=
 	void *stats_mem;	/* orignal pointer to allocated mem */=0A=
 	dma_addr_t stats_mem_phy;	/* Physical address of the stat block */=0A=
 	u32 stats_mem_sz;=0A=
-	StatInfo_t *StatsInfo;	/* Logical address of the stat block */=0A=
+	StatInfo_t *stats_info;	/* Logical address of the stat block */=0A=
 } mac_info_t;=0A=
 =0A=
 /* structure representing the user defined MAC addresses */=0A=
@@ -633,13 +687,20 @@=0A=
 	dma_addr_t block_dma_addr;=0A=
 } rx_block_info_t;=0A=
 =0A=
+/* Default Tunable parameters of the NIC. */=0A=
+#define DEFAULT_FIFO_LEN 4096=0A=
+#define SMALL_RXD_CNT	30 * (MAX_RXDS_PER_BLOCK+1)=0A=
+#define LARGE_RXD_CNT	100 * (MAX_RXDS_PER_BLOCK+1)=0A=
+#define SMALL_BLK_CNT	30=0A=
+#define LARGE_BLK_CNT	100=0A=
+=0A=
 /* Structure representing one instance of the NIC */=0A=
 typedef struct s2io_nic {=0A=
 #define MAX_MAC_SUPPORTED   16=0A=
 #define MAX_SUPPORTED_MULTICASTS MAX_MAC_SUPPORTED=0A=
 =0A=
-	macaddr_t defMacAddr[MAX_MAC_SUPPORTED];=0A=
-	macaddr_t preMacAddr[MAX_MAC_SUPPORTED];=0A=
+	macaddr_t def_mac_addr[MAX_MAC_SUPPORTED];=0A=
+	macaddr_t pre_mac_addr[MAX_MAC_SUPPORTED];=0A=
 =0A=
 	struct net_device_stats stats;=0A=
 	caddr_t bar0;=0A=
@@ -672,8 +733,10 @@=0A=
 	u32 irq;=0A=
 	atomic_t rx_bufs_left[MAX_RX_RINGS];=0A=
 =0A=
-	spinlock_t isr_lock;=0A=
 	spinlock_t tx_lock;=0A=
+#ifndef CONFIG_S2IO_NAPI=0A=
+	spinlock_t put_lock;=0A=
+#endif=0A=
 =0A=
 #define PROMISC     1=0A=
 #define ALL_MULTI   2=0A=
@@ -692,23 +755,22 @@=0A=
 	u16 tx_err_count;=0A=
 	u16 rx_err_count;=0A=
 =0A=
-#if DEBUG_ON=0A=
-	u64 rxpkt_bytes;=0A=
-	u64 txpkt_bytes;=0A=
-	int int_cnt;=0A=
-	int rxint_cnt;=0A=
-	int txint_cnt;=0A=
-	u64 rxpkt_cnt;=0A=
+#ifndef CONFIG_S2IO_NAPI=0A=
+	/* Index to the absolute position of the put pointer of Rx ring. */=0A=
+	int put_pos;=0A=
 #endif=0A=
 =0A=
-	/*  Place holders for the virtual and physical addresses of =0A=
+	/*=0A=
+	 *  Place holders for the virtual and physical addresses of =0A=
 	 *  all the Rx Blocks=0A=
 	 */=0A=
-	struct rx_block_info=0A=
-	 rx_blocks[MAX_RX_RINGS][MAX_RX_BLOCKS_PER_RING];=0A=
+	rx_block_info_t rx_blocks[MAX_RX_RINGS][MAX_RX_BLOCKS_PER_RING];=0A=
 	int block_count[MAX_RX_RINGS];=0A=
 	int pkt_cnt[MAX_RX_RINGS];=0A=
 =0A=
+	/* Place holder of all the TX List's Phy and Virt addresses. */=0A=
+	list_info_hold_t *list_info[MAX_TX_FIFOS];=0A=
+=0A=
 	/*  Id timer, used to blink NIC to physically identify NIC. */=0A=
 	struct timer_list id_timer;=0A=
 =0A=
@@ -738,24 +800,34 @@=0A=
 	u16 last_link_state;=0A=
 #define	LINK_DOWN	1=0A=
 #define	LINK_UP		2=0A=
+=0A=
+#ifdef CONFIG_2BUFF_MODE=0A=
+	/* Buffer Address store. */=0A=
+	buffAdd_t **ba[MAX_RX_RINGS];=0A=
+#endif=0A=
+	int task_flag;=0A=
+#ifdef SNMP_SUPPORT=0A=
+	char cName[20];=0A=
+	int nMemorySize;=0A=
+	int nLinkStatus;=0A=
+	int nFeature;=0A=
+	char cVersion[20];=0A=
+	long lDate;=0A=
+#endif=0A=
+=0A=
 } nic_t;=0A=
 =0A=
 #define RESET_ERROR 1;=0A=
 #define CMD_ERROR   2;=0A=
 =0A=
-/* Default Tunable parameters of the NIC. */=0A=
-#define DEFAULT_FIFO_LEN 4096=0A=
-#define SMALL_RXD_CNT	40 * (MAX_RXDS_PER_BLOCK+1)=0A=
-#define LARGE_RXD_CNT	100 * (MAX_RXDS_PER_BLOCK+1)=0A=
-=0A=
 /*  OS related system calls */=0A=
 #ifndef readq=0A=
 static inline u64 readq(void *addr)=0A=
 {=0A=
 	u64 ret =3D 0;=0A=
 	ret =3D readl(addr + 4);=0A=
-	ret <<=3D 32;=0A=
-	ret |=3D readl(addr);=0A=
+	(u64) ret <<=3D 32;=0A=
+	(u64) ret |=3D readl(addr);=0A=
 =0A=
 	return ret;=0A=
 }=0A=
@@ -767,6 +839,25 @@=0A=
 	writel((u32) (val), addr);=0A=
 	writel((u32) (val >> 32), (addr + 4));=0A=
 }=0A=
+=0A=
+/* In 32 bit modes, some registers have to be written in a =0A=
+ * particular order to expect correct hardware operation. The=0A=
+ * macro SPECIAL_REG_WRITE is used to perform such ordered =0A=
+ * writes. Defines UF (Upper First) and LF (Lower First) will =0A=
+ * be used to specify the required write order.=0A=
+ */=0A=
+#define UF	1=0A=
+#define LF	2=0A=
+#define SPECIAL_REG_WRITE(val, addr, order) 			\=0A=
+		if (order =3D=3D LF) {				\=0A=
+			writel((u32) (val), addr);		\=0A=
+			writel((u32) (val >> 32), (addr + 4));	\=0A=
+		} else {					\=0A=
+			writel((u32) (val >> 32), (addr + 4));	\=0A=
+			writel((u32) (val), addr);		\=0A=
+		}=0A=
+#else=0A=
+#define SPECIAL_REG_WRITE(val, addr, dummy) writeq(val, addr)=0A=
 #endif=0A=
 =0A=
 /*  Interrupt related values of Xena */=0A=
@@ -817,30 +908,41 @@=0A=
 =0A=
 /*  DMA level Inressupts */=0A=
 #define TXDMA_PFC_INT_M     BIT(0)=0A=
-    /*  PFC block interrupts */=0A=
+#define TXDMA_PCC_INT_M     BIT(2)=0A=
+=0A=
+/*  PFC block interrupts */=0A=
 #define PFC_MISC_ERR_1      BIT(0)	/* Interrupt to indicate FIFO full */=0A=
 =0A=
+/* PCC block interrupts. */=0A=
+#define	PCC_FB_ECC_ERR	   vBIT(0xff, 16, 8)	/* Interrupt to indicate=0A=
+						   PCC_FB_ECC Error. */=0A=
+=0A=
 /*=0A=
  * Prototype declaration.=0A=
  */=0A=
 static int __devinit s2io_init_nic(struct pci_dev *pdev,=0A=
 				   const struct pci_device_id *pre);=0A=
 static void __devexit s2io_rem_nic(struct pci_dev *pdev);=0A=
-static int initSharedMem(struct s2io_nic *sp);=0A=
-static void freeSharedMem(struct s2io_nic *sp);=0A=
-static int initNic(struct s2io_nic *nic);=0A=
+static int init_shared_mem(struct s2io_nic *sp);=0A=
+static void free_shared_mem(struct s2io_nic *sp);=0A=
+static int init_nic(struct s2io_nic *nic);=0A=
 #ifndef CONFIG_S2IO_NAPI=0A=
-static void rxIntrHandler(struct s2io_nic *sp);=0A=
+static void rx_intr_handler(struct s2io_nic *sp);=0A=
 #endif=0A=
-static void txIntrHandler(struct s2io_nic *sp);=0A=
-static void alarmIntrHandler(struct s2io_nic *sp);=0A=
+static void tx_intr_handler(struct s2io_nic *sp);=0A=
+static void alarm_intr_handler(struct s2io_nic *sp);=0A=
 =0A=
 static int s2io_starter(void);=0A=
 void s2io_closer(void);=0A=
 static void s2io_tx_watchdog(struct net_device *dev);=0A=
 static void s2io_tasklet(unsigned long dev_addr);=0A=
 static void s2io_set_multicast(struct net_device *dev);=0A=
-static int rxOsmHandler(nic_t * sp, u16 len, RxD_t * rxdp, int ring_no);=0A=
+#ifndef CONFIG_2BUFF_MODE=0A=
+static int rx_osm_handler(nic_t * sp, u16 len, RxD_t * rxdp, int =
ring_no);=0A=
+#else=0A=
+static int rx_osm_handler(nic_t * sp, RxD_t * rxdp, int ring_no,=0A=
+			  buffAdd_t * ba);=0A=
+#endif=0A=
 void s2io_link(nic_t * sp, int link);=0A=
 void s2io_reset(nic_t * sp);=0A=
 #ifdef CONFIG_S2IO_NAPI=0A=
@@ -850,6 +952,70 @@=0A=
 int s2io_set_mac_addr(struct net_device *dev, u8 * addr);=0A=
 static irqreturn_t s2io_isr(int irq, void *dev_id, struct pt_regs =
*regs);=0A=
 static int verify_xena_quiescence(u64 val64, int flag);=0A=
+int verify_load_parm(void);=0A=
+#ifdef SET_ETHTOOL_OPS=0A=
 static struct ethtool_ops netdev_ethtool_ops;=0A=
+#endif=0A=
+static void s2io_set_link(unsigned long data);=0A=
+=0A=
+#ifdef SNMP_SUPPORT=0A=
+=0A=
+#define S2IODIRNAME             "S2IO"=0A=
+#define BDFILENAME      "BDInfo"=0A=
+#define PADAPFILENAME   "PhyAdap"=0A=
+#define ERROR_PROC_DIR          -20=0A=
+#define ERROR_PROC_ENTRY        -21=0A=
+=0A=
+struct stDrvData {=0A=
+	struct stBaseDrv *pBaseDrv;=0A=
+};=0A=
+=0A=
+struct stPhyAdap {=0A=
+	int m_nIndex;=0A=
+	char m_cName[20];=0A=
+};=0A=
+struct stBaseDrv {=0A=
+	char m_cName[21];=0A=
+	int m_nStatus;=0A=
+	char m_cVersion[21];=0A=
+	int m_nFeature;=0A=
+	int m_nMemorySize;=0A=
+	char m_cDate[21];=0A=
+	int m_nPhyCnt;=0A=
+	char m_cPhyIndex[21];=0A=
+	struct stPhyAdap m_stPhyAdap[5];=0A=
+};=0A=
+=0A=
+struct stPhyData {=0A=
+	int m_nIndex;=0A=
+	unsigned char m_cDesc[20];=0A=
+	int m_nMode;=0A=
+	int m_nType;=0A=
+	char m_cSpeed[20];=0A=
+	unsigned char m_cPMAC[20];=0A=
+	unsigned char m_cCMAC[20];=0A=
+	int m_nLinkStatus;=0A=
+	int m_nPCISlot;=0A=
+	int m_nPCIBus;=0A=
+	int m_nIRQ;=0A=
+	int m_nCollision;=0A=
+	int m_nMulticast;=0A=
+=0A=
+	int m_nRxBytes;=0A=
+	int m_nRxDropped;=0A=
+	int m_nRxErrors;=0A=
+	int m_nRxPackets;=0A=
+	int m_nTxBytes;=0A=
+	int m_nTxDropped;=0A=
+	int m_nTxErrors;=0A=
+	int m_nTxPackets;=0A=
+=0A=
+=0A=
+};=0A=
+=0A=
+static int s2io_bdsnmp_init(struct net_device *dev);=0A=
+static void s2io_bdsnmp_rem(struct net_device *dev);=0A=
+#endif=0A=
+=0A=
 =0A=
 #endif				/* _S2IO_H */=0A=

------=_NextPart_000_0023_01C49979.D01C88C0--
