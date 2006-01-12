From: Andreas Mohr <andim2@users.sourceforge.net>
Subject: [PATCH] WLAN acx100: some optimization/cleanup
Date: Thu, 12 Jan 2006 11:37:07 +0100
Message-ID: <20060112103706.GA12115@rhlx01.fht-esslingen.de>
Reply-To: acx100-devel@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="envbJBWh7q8WU6mo"
Cc: netdev@vger.kernel.org
Return-path: <acx100-devel-admin@lists.sourceforge.net>
To: acx100-devel@lists.sourceforge.net
Content-Disposition: inline
Sender: acx100-devel-admin@lists.sourceforge.net
Errors-To: acx100-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:acx100-devel@lists.sourceforge.net>
List-Help: <mailto:acx100-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=acx100-devel>
List-Id: netdev.vger.kernel.org


--envbJBWh7q8WU6mo
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

[copying netdev for centralized development]

Hi all,

some updates to acx-20060111:

- add some cache prefetching at critical places, but still unsure whether it
  helps (some rdtscl() testing hasn't shown much yet),
  thus make it configurable
- add recommended cpu_relax() to busy-wait loops
- use "counter % 8" instead of "counter % 5" for easier ASM calculation
- add ACX_IE_HDR__TYPE_LEN define for IE struct header variables used
  everywhere
- reorder struct wlandevice_t for better(??) cache use
- kill superfluous result variable in conv.c
- misc. small cleanup

This patch is rediffed from my modified acx-20060109 tar, NOT compile-tested!

Andreas Mohr

--envbJBWh7q8WU6mo
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="acx-20060111.diff"

diff -urN acx-20060111.orig/acx_config.h acx-20060111/acx_config.h
--- acx-20060111.orig/acx_config.h	2006-01-08 19:51:28.000000000 +0100
+++ acx-20060111/acx_config.h	2006-01-12 11:21:08.000000000 +0100
@@ -31,6 +31,9 @@
 /* if you want very early packet fragmentation bits and pieces */
 #define ACX_FRAGMENTATION 0
 
+/* not sure whether this helps, so make it configurable for testing */
+#define ACX_CACHE_PREFETCH 1
+
 /* set to 1 if you want to have 1 driver per card instead of 1 single driver
  * managing all cards (of a particular bus type) in your system
  * Useful e.g. if you need to reinitialize single cards from time to time
diff -urN acx-20060111.orig/acx_func.h acx-20060111/acx_func.h
--- acx-20060111.orig/acx_func.h	2006-01-10 07:50:33.000000000 +0100
+++ acx-20060111/acx_func.h	2006-01-12 11:21:08.000000000 +0100
@@ -120,6 +120,14 @@
 
 #endif /* ACX_DEBUG */
 
+#if ACX_CACHE_PREFETCH
+#define ACX_PREFETCH(p) prefetch(p)
+#define ACX_PREFETCHW(p) prefetchw(p)
+#else
+#define ACX_PREFETCH(p)
+#define ACX_PREFETCHW(p)
+#endif
+
 void acx_print_mac(const char *head, const u8 *mac, const char *tail);
 
 /* Optimized out to nothing in non-debug build */
@@ -171,7 +179,7 @@
 static inline int
 mac_is_bcast(const u8 *mac)
 {
-	/* AND together 4 first bytes with sign-entended 2 last bytes
+	/* AND together 4 first bytes with sign-extended 2 last bytes
 	** Only bcast address gives 0xffffffff. +1 gives 0 */
 	return ( *(s32*)mac & ((s16*)mac)[2] ) + 1 == 0;
 }
@@ -254,7 +262,7 @@
 ** acx_s_xxxx - potentially sleeping functions. Do not ever call under lock!
 ** acx_l_xxxx - functions which expect lock to be already taken.
 ** rest       - non-sleeping functions which do not require locking
-**		but may be run inder lock
+**		but may be run under lock
 **
 ** A small number of local helpers do not have acx_[eisl]_ prefix.
 ** They are always close to caller and are to be revieved locally.
diff -urN acx-20060111.orig/acx_struct.h acx-20060111/acx_struct.h
--- acx-20060111.orig/acx_struct.h	2006-01-10 07:49:27.000000000 +0100
+++ acx-20060111/acx_struct.h	2006-01-12 11:21:08.000000000 +0100
@@ -1005,6 +1005,10 @@
 #endif /* ACX_USB */
 
 
+#define ACX_IE_HDR__TYPE_LEN \
+	u16	type ACX_PACKED; \
+	u16	len ACX_PACKED;
+
 /* Config Option structs */
 
 typedef struct co_antennas {
@@ -1061,8 +1065,7 @@
 } co_fixed_t;
 
 typedef struct acx111_ie_configoption {
-	u16			type ACX_PACKED;
-	u16			len ACX_PACKED;
+	ACX_IE_HDR__TYPE_LEN
 /* Do not access below members directly, they are in fact variable length */
 	co_fixed_t		fixed ACX_PACKED;
 	co_antennas_t		antennas ACX_PACKED;
@@ -1225,9 +1228,9 @@
 	client_t	*sta_hash_tab[64];	/* hash collisions are not likely */
 	client_t	*ap_client;		/* this one is our AP (STA mode only) */
 
-	unsigned long	dup_msg_expiry;
 	int		dup_count;
 	int		nondup_count;
+	unsigned long	dup_msg_expiry;
 	u16		last_seq_ctrl;		/* duplicate packet detection */
 
 	/* 802.11 power save mode */
@@ -1289,15 +1292,15 @@
 	wep_key_t	wep_keys[DOT11_MAX_DEFAULT_WEP_KEYS];	/* the default WEP keys */
 	key_struct_t	wep_key_struct[10];
 
+	/*** Unknown ***/
+	u8		dtim_interval;
+
 	/*** Card Rx/Tx management ***/
 	u16		rx_config_1;
 	u16		rx_config_2;
 	u16		memblocksize;
-	int		tx_free;
-	int		tx_head;
-
-	/*** Unknown ***/
-	u8		dtim_interval;
+	unsigned int	tx_free;
+	unsigned int	tx_head; /* keep as close as possible to Tx stuff below (cache line) */
 
 /*************************************************************************
  *** PCI/USB/... must be last or else hw agnostic code breaks horribly ***
@@ -1310,31 +1313,31 @@
 #ifdef ACX_PCI
 	/* pointers to tx buffers, tx host descriptors (in host memory)
 	** and tx descs in device memory */
+	unsigned int	tx_tail;
 	u8		*txbuf_start;
 	txhostdesc_t	*txhostdesc_start;
 	txdesc_t	*txdesc_start;	/* points to PCI-mapped memory */
-	/* same for rx */
-	rxbuffer_t	*rxbuf_start;
-	rxhostdesc_t	*rxhostdesc_start;
-	rxdesc_t	*rxdesc_start;
-	/* physical addresses of above host memory areas */
-	dma_addr_t	rxbuf_startphy;
-	/* dma_addr_t	rxhostdesc_startphy; */
 	dma_addr_t	txbuf_startphy;
 	dma_addr_t	txhostdesc_startphy;
 	/* sizes of above host memory areas */
 	unsigned int	txbuf_area_size;
 	unsigned int	txhostdesc_area_size;
-	unsigned int	rxbuf_area_size;
-	unsigned int	rxhostdesc_area_size;
 
 	unsigned int	txdesc_size;	/* size of txdesc; ACX111 = ACX100 + 4 */
-	unsigned int	tx_tail;
-	unsigned int	rx_tail;
-
 	client_t	*txc[TX_CNT];
 	u16		txr[TX_CNT];
 
+	/* same for rx */
+	unsigned int	rx_tail;
+	rxbuffer_t	*rxbuf_start;
+	rxhostdesc_t	*rxhostdesc_start;
+	rxdesc_t	*rxdesc_start;
+	/* physical addresses of above host memory areas */
+	dma_addr_t	rxbuf_startphy;
+	/* dma_addr_t	rxhostdesc_startphy; */
+	unsigned int	rxbuf_area_size;
+	unsigned int	rxhostdesc_area_size;
+
 	u8		need_radio_fw;
 	u8		irqs_active;	/* whether irq sending is activated */
 
@@ -1499,14 +1502,12 @@
 /***********************************************************************
 */
 typedef struct acx100_ie_memblocksize {
-	u16	type ACX_PACKED;
-	u16	len ACX_PACKED;
+	ACX_IE_HDR__TYPE_LEN
 	u16	size ACX_PACKED;
 } acx100_ie_memblocksize_t;
 
 typedef struct acx100_ie_queueconfig {
-	u16	type ACX_PACKED;
-	u16	len ACX_PACKED;
+	ACX_IE_HDR__TYPE_LEN
 	u32	AreaSize ACX_PACKED;
 	u32	RxQueueStart ACX_PACKED;
 	u8	QueueOptions ACX_PACKED;
@@ -1522,8 +1523,7 @@
 } acx100_ie_queueconfig_t;
 
 typedef struct acx111_ie_queueconfig {
-	u16	type ACX_PACKED;
-	u16	len ACX_PACKED;
+	ACX_IE_HDR__TYPE_LEN
 	u32	tx_memory_block_address ACX_PACKED;
 	u32	rx_memory_block_address ACX_PACKED;
 	u32	rx1_queue_address ACX_PACKED;
@@ -1535,8 +1535,7 @@
 } acx111_ie_queueconfig_t;
 
 typedef struct acx100_ie_memconfigoption {
-	u16	type ACX_PACKED;
-	u16	len ACX_PACKED;
+	ACX_IE_HDR__TYPE_LEN
 	u32	DMA_config ACX_PACKED;
 	acx_ptr	pRxHostDesc ACX_PACKED;
 	u32	rx_mem ACX_PACKED;
@@ -1546,8 +1545,7 @@
 } acx100_ie_memconfigoption_t;
 
 typedef struct acx111_ie_memoryconfig {
-	u16	type ACX_PACKED;
-	u16	len ACX_PACKED;
+	ACX_IE_HDR__TYPE_LEN
 	u16	no_of_stations ACX_PACKED;
 	u16	memory_block_size ACX_PACKED;
 	u8	tx_rx_memory_block_allocation ACX_PACKED;
@@ -1575,8 +1573,7 @@
 } acx111_ie_memoryconfig_t;
 
 typedef struct acx_ie_memmap {
-	u16	type ACX_PACKED;
-	u16	len ACX_PACKED;
+	ACX_IE_HDR__TYPE_LEN
 	u32	CodeStart ACX_PACKED;
 	u32	CodeEnd ACX_PACKED;
 	u32	WEPCacheStart ACX_PACKED;
@@ -1590,15 +1587,13 @@
 } acx_ie_memmap_t;
 
 typedef struct acx111_ie_feature_config {
-	u16	type ACX_PACKED;
-	u16	len ACX_PACKED;
+	ACX_IE_HDR__TYPE_LEN
 	u32	feature_options ACX_PACKED;
 	u32	data_flow_options ACX_PACKED;
 } acx111_ie_feature_config_t;
 
 typedef struct acx111_ie_tx_level {
-	u16	type ACX_PACKED;
-	u16	len ACX_PACKED;
+	ACX_IE_HDR__TYPE_LEN
 	u8	level ACX_PACKED;
 } acx111_ie_tx_level_t;
 
@@ -1617,8 +1612,7 @@
 #define PS_OPT_STILL_RCV_BCASTS	0x01
 
 typedef struct acx100_ie_powermgmt {
-	u16	type ACX_PACKED;
-	u16	len ACX_PACKED;
+	ACX_IE_HDR__TYPE_LEN
 	u8	wakeup_cfg ACX_PACKED;
 	u8	listen_interval ACX_PACKED; /* for EACH_ITVL: wake up every "beacon units" interval */
 	u8	options ACX_PACKED;
@@ -1627,8 +1621,7 @@
 } acx100_ie_powermgmt_t;
 
 typedef struct acx111_ie_powermgmt {
-	u16	type ACX_PACKED;
-	u16	len ACX_PACKED;
+	ACX_IE_HDR__TYPE_LEN
 	u8	wakeup_cfg ACX_PACKED;
 	u8	listen_interval ACX_PACKED; /* for EACH_ITVL: wake up every "beacon units" interval */
 	u8	options ACX_PACKED;
@@ -1858,16 +1851,14 @@
 } acx_cmd_radioinit_t;
 
 typedef struct acx100_ie_wep_options {
-	u16	type ACX_PACKED;
-	u16	len ACX_PACKED;
+	ACX_IE_HDR__TYPE_LEN
 	u16	NumKeys ACX_PACKED;	/* max # of keys */
 	u8	WEPOption ACX_PACKED;	/* 0 == decrypt default key only, 1 == override decrypt */
 	u8	Pad ACX_PACKED;		/* used only for acx111 */
 } acx100_ie_wep_options_t;
 
 typedef struct ie_dot11WEPDefaultKey {
-	u16	type ACX_PACKED;
-	u16	len ACX_PACKED;
+	ACX_IE_HDR__TYPE_LEN
 	u8	action ACX_PACKED;
 	u8	keySize ACX_PACKED;
 	u8	defaultKeyNum ACX_PACKED;
@@ -1887,8 +1878,7 @@
 } acx111WEPDefaultKey_t;
 
 typedef struct ie_dot11WEPDefaultKeyID {
-	u16	type ACX_PACKED;
-	u16	len ACX_PACKED;
+	ACX_IE_HDR__TYPE_LEN
 	u8	KeyID ACX_PACKED;
 } ie_dot11WEPDefaultKeyID_t;
 
@@ -1906,8 +1896,7 @@
 */
 
 typedef struct acx_ie_generic {
-	u16	type ACX_PACKED;
-	u16	len ACX_PACKED;
+	ACX_IE_HDR__TYPE_LEN
 	union {
 		/* struct wep wp ACX_PACKED; */
 		/* Association ID IE: just a 16bit value: */
diff -urN acx-20060111.orig/common.c acx-20060111/common.c
--- acx-20060111.orig/common.c	2006-01-10 08:20:39.000000000 +0100
+++ acx-20060111/common.c	2006-01-12 11:21:08.000000000 +0100
@@ -155,7 +155,7 @@
 void
 acx_lock_debug(wlandevice_t *priv, const char* where)
 {
-	int count = 100*1000*1000;
+	unsigned int count = 100*1000*1000;
 	where = sanitize_str(where);
 	while (--count) {
 		if (!spin_is_locked(&priv->lock)) break;
@@ -179,7 +179,7 @@
 	}
 #endif
 	if (acx_debug & L_LOCK) {
-		unsigned diff;
+		unsigned long diff;
 		rdtscl(diff);
 		diff -= priv->lock_time;
 		if (diff > max_lock_time) {
@@ -228,7 +228,7 @@
 		dump_stack();
 	}
 	if (acx_debug & L_LOCK) {
-		unsigned diff = jiffies - priv->sem_time;
+		unsigned long diff = jiffies - priv->sem_time;
 		if (diff > max_sem_time) {
 			where = sanitize_str(where);
 			printk("max sem hold time %d jiffies from %s "
@@ -353,7 +353,7 @@
 		"STOPPED", "SCANNING", "WAIT_AUTH",
 		"AUTHENTICATED", "ASSOCIATED", "INVALID??"
 	};
-	if (status >= VEC_SIZE(str))
+	if (status > VEC_SIZE(str)-1)
 		status = VEC_SIZE(str)-1;
 
 	return str[status];
@@ -2621,6 +2621,7 @@
 	 * be expressed in dBm, or it's some pretty complicated
 	 * calculation. */
 
+	PREFETCHW(&priv->wstats.qual);
 #ifdef FROM_SCAN_SOURCE_ONLY
 	/* only consider packets originating from the MAC
 	 * address of the device that's managing our BSSID.
@@ -2968,9 +2969,11 @@
 acx_l_sta_list_get(wlandevice_t *priv, const u8 *address)
 {
 	client_t *client;
+
 	FN_ENTER;
 	client = acx_l_sta_list_get_from_hash(priv, address);
 	while (client) {
+		PREFETCH(client->next);
 		if (mac_is_equal(address, client->address)) {
 			client->mtime = jiffies;
 			break;
@@ -2995,6 +2998,7 @@
 	/* tricky. next = client on first iteration only,
 	** on all other iters next = client->next */
 	while (next) {
+		PREFETCH(client->next);
 		if (next == victim) {
 			client->next = victim->next;
 			/* Overkill */
@@ -3729,7 +3733,7 @@
 		priv->netdev->name, *req->reason,
 		acx_wlan_reason_str(*req->reason));
 
-	/* Chk: is ta is verified to be from our AP? */
+	/* Chk: is ta verified to be from our AP? */
 	if (mac_is_equal(priv->dev_addr, req->hdr->a1)) {
 		log(L_DEBUG, "AP sent us deauth packet\n");
 		SET_BIT(priv->set_mask, GETSET_RESCAN);
@@ -3755,6 +3759,7 @@
 		skb = acx_rxbuf_to_ether(priv, rxbuf);
 		if (likely(skb)) {
 			netif_rx(skb);
+			PREFETCHW(&priv->stats);
 			priv->netdev->last_rx = jiffies;
 			priv->stats.rx_packets++;
 			priv->stats.rx_bytes += skb->len;
@@ -5094,7 +5099,7 @@
 			printk("%s: no matching station found in range, "
 				"generating our own IBSS instead\n",
 				priv->netdev->name);
-			/* we do it hostap way: */
+			/* we do it the HostAP way: */
 			MAC_COPY(priv->bssid, priv->dev_addr);
 			priv->bssid[0] |= 0x02; /* 'local assigned addr' bit */
 			/* add IBSS bit to our caps... */
diff -urN acx-20060111.orig/conv.c acx-20060111/conv.c
--- acx-20060111.orig/conv.c	2006-01-10 08:02:48.000000000 +0100
+++ acx-20060111/conv.c	2006-01-12 11:21:08.000000000 +0100
@@ -138,8 +138,7 @@
 	struct wlan_llc *e_llc;
 	struct wlan_snap *e_snap;
 	const u8 *a1, *a3;
-	int header_len, payload_len;
-	int result = -1;
+	int header_len, payload_len = -1;
 	/* protocol type or data length, depending on whether
 	 * DIX or 802.3 ethernet format */
 	u16 proto;
@@ -164,7 +163,7 @@
 			goto end;
 		}
 		memcpy(w_hdr, skb->data, skb->len);
-		result = skb->len;
+		payload_len = skb->len;
 		goto end;
 	}
 
@@ -206,7 +205,6 @@
 	/* TODO: can we just let acx DMA payload from skb instead? */
 	memcpy((u8*)txbuf + header_len, skb->data + sizeof(wlan_ethhdr_t), payload_len);
 	payload_len += header_len;
-	result = payload_len;
 
 	/* Set up the 802.11 header */
 	switch (priv->mode) {
@@ -228,7 +226,7 @@
 	default:
 		printk("%s: error - converting eth to wlan in unknown mode\n",
 				priv->netdev->name);
-		result = -1;
+		payload_len = -1;
 		goto end;
 	}
 	if (priv->wep_enabled)
@@ -251,8 +249,8 @@
 #endif
 
 end:
-	FN_EXIT1(result);
-	return result;
+	FN_EXIT1(payload_len);
+	return payload_len;
 }
 
 
@@ -330,8 +328,8 @@
 	e_hdr = (wlan_ethhdr_t*) ((u8*) w_hdr + payload_offset);
 	e_llc = (wlan_llc_t*) e_hdr;
 	e_snap = (wlan_snap_t*) (e_llc + 1);
-	e_payload = (u8*) (e_snap + 1);
 	mtu = priv->netdev->mtu;
+	e_payload = (u8*) (e_snap + 1);
 
 	log(L_DATA, "rx: payload_offset %d, payload_length %d\n",
 		payload_offset, payload_length);
diff -urN acx-20060111.orig/pci.c acx-20060111/pci.c
--- acx-20060111.orig/pci.c	2006-01-10 08:03:59.000000000 +0100
+++ acx-20060111/pci.c	2006-01-12 11:21:08.000000000 +0100
@@ -223,7 +223,10 @@
 static inline client_t*
 get_txc(wlandevice_t* priv, txdesc_t* txdesc)
 {
-	int index = (u8*)txdesc - (u8*)priv->txdesc_start;
+	int index;
+
+	ACX_PREFETCH(priv->txc);
+	index = (u8*)txdesc - (u8*)priv->txdesc_start;
 	if (unlikely(ACX_DEBUG && (index % priv->txdesc_size))) {
 		printk("bad txdesc ptr %p\n", txdesc);
 		return NULL;
@@ -239,7 +242,10 @@
 static inline u16
 get_txr(wlandevice_t* priv, txdesc_t* txdesc)
 {
-	int index = (u8*)txdesc - (u8*)priv->txdesc_start;
+	int index;
+
+	ACX_PREFETCH(priv->txr);
+	index = (u8*)txdesc - (u8*)priv->txdesc_start;
 	index /= priv->txdesc_size;
 	return priv->txr[index];
 }
@@ -247,7 +253,11 @@
 static inline void
 put_txcr(wlandevice_t* priv, txdesc_t* txdesc, client_t* c, u16 r111)
 {
-	int index = (u8*)txdesc - (u8*)priv->txdesc_start;
+	int index;
+
+	ACX_PREFETCHW(priv->txc);
+	ACX_PREFETCHW(priv->txr);
+	index = (u8*)txdesc - (u8*)priv->txdesc_start;
 	if (unlikely(ACX_DEBUG && (index % priv->txdesc_size))) {
 		printk("bad txdesc ptr %p\n", txdesc);
 		return;
@@ -302,6 +312,7 @@
 			result = NOT_OK;
 			goto fail;
 		}
+		cpu_relax();
 	}
 
 	*charbuf = read_reg8(priv, IO_ACX_EEPROM_DATA);
@@ -369,6 +380,7 @@
 					"Timeout waiting for EEPROM write\n");
 				goto end;
 			}
+			cpu_relax();
 		}
 	}
 
@@ -389,6 +401,7 @@
 				printk("timeout waiting for EEPROM read\n");
 				goto end;
 			}
+			cpu_relax();
 		}
 
 		data_verify[i] = read_reg16(priv, IO_ACX_EEPROM_DATA);
@@ -435,6 +448,7 @@
 			*charbuf = 0;
 			goto fail;
 		}
+		cpu_relax();
 	}
 
 	log(L_DEBUG, "count was %u\n", count);
@@ -1029,6 +1043,7 @@
 
 	FN_ENTER;
 
+	ACX_PREFETCH(buffer);
 	devname = priv->netdev->name;
 	if (!devname || !devname[0] || devname[4]=='%')
 		devname = "acx";
@@ -1057,14 +1072,16 @@
 		/* Test for IDLE state */
 		if (!cmd_status)
 			break;
-		if (counter % 5 == 0) {
+		if (counter % 8 == 0) {
 			if (time_after(jiffies, timeout)) {
 				counter = 0;
 				break;
 			}
-			/* we waited 5 iterations, no luck. Sleep 5 ms */
-			acx_s_msleep(5);
+			/* we waited 8 iterations, no luck. Sleep 8 ms */
+			acx_s_msleep(8);
 		}
+		else
+			cpu_relax();
 	} while (likely(--counter));
 
 	if (!counter) {
@@ -1078,6 +1095,7 @@
 	}
 
 	/* now write the parameters of the command if needed */
+	ACX_PREFETCHW(priv->cmd_area);
 	if (buffer && buflen) {
 		/* if it's an INTERROGATE command, just pass the length
 		 * of parameters to read, as data */
@@ -1123,14 +1141,16 @@
 				break;
 		}
 
-		if (counter % 5 == 0) {
+		if (counter % 8 == 0) {
 			if (time_after(jiffies, timeout)) {
 				counter = 0;
 				break;
 			}
-			/* we waited 5 iterations, no luck. Sleep 5 ms */
-			acx_s_msleep(5);
+			/* we waited 8 iterations, no luck. Sleep 8 ms */
+			acx_s_msleep(8);
 		}
+		else
+			cpu_relax();
 	} while (likely(--counter));
 
 	/* save state for debugging */
@@ -2319,6 +2339,8 @@
 	register rxhostdesc_t *hostdesc;
 	int count, tail;
 
+	ACX_PREFETCH(&priv->rx_tail);
+
 	FN_ENTER;
 
 	if (unlikely(acx_debug & L_BUFR))
@@ -2331,6 +2353,8 @@
 	count = RX_CNT;
 	while (1) {
 		hostdesc = &priv->rxhostdesc_start[tail];
+
+		ACX_PREFETCH(hostdesc);
 		/* advance tail regardless of outcome of the below test */
 		tail = (tail + 1) % RX_CNT;
 
@@ -2344,6 +2368,8 @@
 
 	/* now process descriptors, starting with the first we figured out */
 	while (1) {
+		ACX_PREFETCH(hostdesc->data);
+
 		log(L_BUFR, "rx: tail=%u Ctl_16=%04X Status=%08X\n",
 			tail, hostdesc->Ctl_16, hostdesc->Status);
 
@@ -3103,7 +3129,9 @@
 void*
 acxpci_l_get_txbuf(wlandevice_t *priv, tx_t* tx_opaque)
 {
-	return get_txhostdesc(priv, (txdesc_t*)tx_opaque)->data;
+	void *buf = get_txhostdesc(priv, (txdesc_t*)tx_opaque)->data;
+	ACX_PREFETCHW(buf);
+	return buf;
 }
 
 
@@ -3415,6 +3443,8 @@
 	u16 r111;
 	u8 error, ack_failures, rts_failures, rts_ok, r100;
 
+	ACX_PREFETCH(&priv->tx_tail);
+
 	FN_ENTER;
 
 	if (unlikely(acx_debug & L_DEBUG))
diff -urN acx-20060111.orig/usb.c acx-20060111/usb.c
--- acx-20060111.orig/usb.c	2006-01-10 08:03:08.000000000 +0100
+++ acx-20060111/usb.c	2006-01-12 11:21:08.000000000 +0100
@@ -1618,7 +1618,7 @@
 		printk("%d ", usbdev->ep_in[i]->desc.wMaxPacketSize);
 	printk("\n");
 	printk("  ep_out wMaxPacketSize: ");
-	for (i = 0; i < 15; ++i)
+	for (i = 0; i < 16; ++i)
 		printk("%d ", usbdev->ep_out[i]->desc.wMaxPacketSize);
 	printk("\n");
 #else

--envbJBWh7q8WU6mo--


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
