From: "Raghavendra Koushik" <raghavendra.koushik@s2io.com>
Subject: RE: [PATCH 2.6.9-rc2 8/12] S2io: two buffer mode
Date: Tue, 9 Nov 2004 10:49:15 -0800
Message-ID: <200411091849.iA9InK39016733@guinness.s2io.com>
References: <OF3217E79B.191DEEB3-ON88256F47.0002DD18-88256F47.0003C162@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/related;
	boundary="----=_NextPart_000_001A_01C4C649.C6321620"
Cc: <jgarzik@pobox.com>, <netdev@oss.sgi.com>, <ravinandan.arakali@s2io.com>,
        <romieu@fr.zoreil.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Krishna Kumar'" <kumarkr@us.ibm.com>
In-Reply-To: <OF3217E79B.191DEEB3-ON88256F47.0002DD18-88256F47.0003C162@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

------=_NextPart_000_001A_01C4C649.C6321620
Content-Type: multipart/alternative;
	boundary="----=_NextPart_001_001B_01C4C649.C6348720"


------=_NextPart_001_001B_01C4C649.C6348720
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit

You are right a check for ba[i] at the top is necessary. Also your second
observation
is valid, there's no chance of discontinuous chunks of memory  within the ba
block. 
 
Thanks
Koushik
 



  _____  

From: Krishna Kumar [mailto:kumarkr@us.ibm.com] 
Sent: Monday, November 08, 2004 4:41 PM
To: raghavendra.koushik@s2io.com
Cc: jgarzik@pobox.com; netdev@oss.sgi.com; raghavendra.koushik@s2io.com;
ravinandan.arakali@s2io.com; romieu@fr.zoreil.com
Subject: Re: [PATCH 2.6.9-rc2 8/12] S2io: two buffer mode



Sorry if my mailer mangles the mail, but ...

This code looks like it can cause an oops on failure to alloc cases. I
havent read the code very much other than the
init and the free routines.

+#ifdef CONFIG_2BUFF_MODE
+ /* Freeing buffer storage addresses in 2BUFF mode. */
+ for (i = 0; i < config->rx_ring_num; i++) {
+ blk_cnt =
+     config->rx_cfg[i].num_rxd / (MAX_RXDS_PER_BLOCK + 1);
+ for (j = 0; j < blk_cnt; j++) {
+ int k = 0;
+ if (!nic->ba[i][j])
+ continue;
+ while (k != MAX_RXDS_PER_BLOCK) {
+ buffAdd_t *ba = &nic->ba[i][j][k];
+ kfree(ba->ba_0_org);
+ kfree(ba->ba_1_org);
+ k++;
+ }
+ kfree(nic->ba[i][j]);
+ }
+ if (nic->ba[i])
+ kfree(nic->ba[i]);
+ }
+#endif

Shouldn't this be something like (check ba[i] at the top to avoid MMU) :

+#ifdef CONFIG_2BUFF_MODE
+ /* Freeing buffer storage addresses in 2BUFF mode. */
+ for (i = 0; i < config->rx_ring_num; i++) {
+ if (!nic->ba[i]) /* if there are no holes, we are done */
+ break;
+ blk_cnt =
+     config->rx_cfg[i].num_rxd / (MAX_RXDS_PER_BLOCK + 1);
+ for (j = 0; j < blk_cnt; j++) {
+ int k = 0;
+ if (!nic->ba[i][j])
+ continue;
>> Should this be a break ? Can you have holes in the middle ?
+ while (k != MAX_RXDS_PER_BLOCK) {
+ buffAdd_t *ba = &nic->ba[i][j][k];
+ kfree(ba->ba_0_org);
+ kfree(ba->ba_1_org);
>> Actually if no holes are allowed, you can break out if the above pointers
become
>> NULL instead of iterating MAX_RXDS_PER_BLOCK (127) times.
+ k++;
+ }
+ kfree(nic->ba[i][j]);
+ }
+ kfree(nic->ba[i]);
+ }
+#endif

thx,

- KK

Inactive hide details for
raghavendra.koushik@s2io.comraghavendra.koushik@s2io.com






	raghavendra.koushik@s2io.com 
Sent by: netdev-bounce@oss.sgi.com 

	11/08/2004 08:16 AM




To

jgarzik@pobox.com, romieu@fr.zoreil.com, netdev@oss.sgi.com	



cc

ravinandan.arakali@s2io.com, raghavendra.koushik@s2io.com	



Subject

[PATCH 2.6.9-rc2 8/12] S2io: two buffer mode	
	 	

Hi,
Attached is the patch for implementing 2-buffer mode on Rx path.
More description of this mode of operation follows.

On certain systems when a DMA has to happen on an un-aligned memory location
performance will take a significant hit. It's standard
practice to offset the Rx buffer address by 2 (as Mac header is 14 bytes) so
the IP header starts from an aligned location.
Obviously using a single Rx buffer both cannot be achieved. Thus XFrame
supports something called 2 buffer Rx mode, where in the
Rx'ed frame is split into 2 parts, one is the Ethernet header and the other
is the Ethernet payload. So now we can allocate proper
aligned memory for both buffers, hence the DMA is not slowed down. Also, the
Ethernet payload(starting from L3 header) is on an
aligned location so OS need not have to do un-aligned accesses to process IP
header. To achieve this, the kernel function
eth_type_trans functionality has to be partially implemented in the driver
itself.

Signed-off-by: Raghavendra Koushik <raghavendra.koushik@s2io.com>
Signed-off-by: Ravinandan Arakali <ravinandan.arakali@s2io.com>
---
diff -urN vanilla-linux/drivers/net/Kconfig
linux-2.6.8.1/drivers/net/Kconfig
--- vanilla-linux/drivers/net/Kconfig 2004-10-06 15:15:04.000000000 -0700
+++ linux-2.6.8.1/drivers/net/Kconfig 2004-10-11 20:06:36.000000000 -0700
@@ -2267,6 +2267,17 @@

  If in doubt, say N.

+config 2BUFF_MODE
+ bool "Use 2 Buffer Mode on Rx side."
+ depends on S2IO
+ ---help---
+ On enabling the 2 buffer mode, the received frame will be
+ split into 2 parts before being DMA'ed to the hosts memory.
+ The parts are the ethernet header and ethernet payload. 
+ This is useful on systems where DMA'ing to to unaligned 
+ physical memory loactions comes with a heavy price.
+ If not sure please say N.
+
endmenu

source "drivers/net/tokenring/Kconfig"
diff -urN vanilla-linux/drivers/net/s2io.c linux-2.6.8.1/drivers/net/s2io.c
--- vanilla-linux/drivers/net/s2io.c 2004-10-11 21:21:49.000000000 -0700
+++ linux-2.6.8.1/drivers/net/s2io.c 2004-10-12 16:49:27.796331624 -0700
@@ -325,6 +325,10 @@
int i, j, blk_cnt;
int lst_size, lst_per_page;
struct net_device *dev = nic->dev;
+#ifdef CONFIG_2BUFF_MODE
+ u64 tmp;
+ buffAdd_t *ba;
+#endif

mac_info_t *mac_control;
struct config_param *config;
@@ -425,7 +429,11 @@
    config->rx_cfg[i].num_rxd / (MAX_RXDS_PER_BLOCK + 1);
/*  Allocating all the Rx blocks */
for (j = 0; j < blk_cnt; j++) {
+#ifndef CONFIG_2BUFF_MODE
size = (MAX_RXDS_PER_BLOCK + 1) * (sizeof(RxD_t));
+#else
+ size = SIZE_OF_BLOCK;
+#endif
tmp_v_addr = pci_alloc_consistent(nic->pdev, size,
  &tmp_p_addr);
if (tmp_v_addr == NULL) {
@@ -458,13 +466,60 @@
pre_rxd_blk->reserved_1 = END_OF_BLOCK; /* last RxD 
 * marker.
 */
+#ifndef CONFIG_2BUFF_MODE
pre_rxd_blk->reserved_2_pNext_RxD_block =
    (unsigned long) tmp_v_addr_next;
+#endif
pre_rxd_blk->pNext_RxD_Blk_physical =
    (u64) tmp_p_addr_next;
}
}

+#ifdef CONFIG_2BUFF_MODE
+ /* 
+  * Allocation of Storages for buffer addresses in 2BUFF mode
+  * and the buffers as well.
+  */
+ for (i = 0; i < config->rx_ring_num; i++) {
+ blk_cnt =
+     config->rx_cfg[i].num_rxd / (MAX_RXDS_PER_BLOCK + 1);
+ nic->ba[i] = kmalloc((sizeof(buffAdd_t *) * blk_cnt),
+      GFP_KERNEL);
+ if (!nic->ba[i])
+ return -ENOMEM;
+ for (j = 0; j < blk_cnt; j++) {
+ int k = 0;
+ nic->ba[i][j] = kmalloc((sizeof(buffAdd_t) *
+  (MAX_RXDS_PER_BLOCK + 1)),
+ GFP_KERNEL);
+ if (!nic->ba[i][j])
+ return -ENOMEM;
+ while (k != MAX_RXDS_PER_BLOCK) {
+ ba = &nic->ba[i][j][k];
+
+ ba->ba_0_org = (void *) kmalloc
+     (BUF0_LEN + ALIGN_SIZE, GFP_ATOMIC);
+ if (!ba->ba_0_org)
+ return -ENOMEM;
+ tmp = (u64) ba->ba_0_org;
+ tmp += ALIGN_SIZE;
+ tmp &= ~((u64) ALIGN_SIZE);
+ ba->ba_0 = (void *) tmp;
+
+ ba->ba_1_org = (void *) kmalloc
+     (BUF1_LEN + ALIGN_SIZE, GFP_ATOMIC);
+ if (!ba->ba_1_org)
+ return -ENOMEM;
+ tmp = (u64) ba->ba_1_org;
+ tmp += ALIGN_SIZE;
+ tmp &= ~((u64) ALIGN_SIZE);
+ ba->ba_1 = (void *) tmp;
+ k++;
+ }
+ }
+ }
+#endif
+
/* Allocation and initialization of Statistics block */
size = sizeof(StatInfo_t);
mac_control->stats_mem = pci_alloc_consistent
@@ -532,7 +587,11 @@
kfree(nic->list_info[i]);
}

+#ifndef CONFIG_2BUFF_MODE
size = (MAX_RXDS_PER_BLOCK + 1) * (sizeof(RxD_t));
+#else
+ size = SIZE_OF_BLOCK;
+#endif
for (i = 0; i < config->rx_ring_num; i++) {
blk_cnt = nic->block_count[i];
for (j = 0; j < blk_cnt; j++) {
@@ -545,6 +604,27 @@
}
}

+#ifdef CONFIG_2BUFF_MODE
+ /* Freeing buffer storage addresses in 2BUFF mode. */
+ for (i = 0; i < config->rx_ring_num; i++) {
+ blk_cnt =
+     config->rx_cfg[i].num_rxd / (MAX_RXDS_PER_BLOCK + 1);
+ for (j = 0; j < blk_cnt; j++) {
+ int k = 0;
+ if (!nic->ba[i][j])
+ continue;
+ while (k != MAX_RXDS_PER_BLOCK) {
+ buffAdd_t *ba = &nic->ba[i][j][k];
+ kfree(ba->ba_0_org);
+ kfree(ba->ba_1_org);
+ k++;
+ }
+ kfree(nic->ba[i][j]);
+ }
+ if (nic->ba[i])
+ kfree(nic->ba[i]);
+ }
+#endif

if (mac_control->stats_mem) {
pci_free_consistent(nic->pdev,
@@ -1366,10 +1446,21 @@
       &bar0->prc_rxd0_n[i]);

val64 = readq(&bar0->prc_ctrl_n[i]);
+#ifndef CONFIG_2BUFF_MODE
val64 |= PRC_CTRL_RC_ENABLED;
+#else
+ val64 |= PRC_CTRL_RC_ENABLED | PRC_CTRL_RING_MODE_3;
+#endif
writeq(val64, &bar0->prc_ctrl_n[i]);
}

+#ifdef CONFIG_2BUFF_MODE
+ /* Enabling 2 buffer mode by writing into Rx_pa_cfg reg. */
+ val64 = readq(&bar0->rx_pa_cfg);
+ val64 |= RX_PA_CFG_IGNORE_L2_ERR;
+ writeq(val64, &bar0->rx_pa_cfg);
+#endif
+
/* 
 * Enabling MC-RLDRAM. After enabling the device, we timeout
 * for around 100ms, which is approximately the time required
@@ -1437,6 +1528,12 @@
}

/* 
+  * Don't see link state interrupts on certain switches, so 
+  * directly scheduling a link state task from here.
+  */
+ schedule_work(&nic->set_link_task);
+
+ /* 
 * Here we are performing soft reset on XGXS to 
 * force link down. Since link is already up, we will get
 * link state change interrupt after this reset
@@ -1565,6 +1662,13 @@
    atomic_read(&nic->rx_bufs_left[ring_no]);
mac_info_t *mac_control;
struct config_param *config;
+#ifdef CONFIG_2BUFF_MODE
+ RxD_t *rxdpnext;
+ int nextblk;
+ u64 tmp;
+ buffAdd_t *ba;
+ dma_addr_t rxdpphys;
+#endif
#ifndef CONFIG_S2IO_NAPI
unsigned long flags;
#endif
@@ -1589,10 +1693,14 @@
    block_index;
off = mac_control->rx_curr_put_info[ring_no].offset;
off1 = mac_control->rx_curr_get_info[ring_no].offset;
+#ifndef CONFIG_2BUFF_MODE
offset = block_no * (MAX_RXDS_PER_BLOCK + 1) + off;
offset1 = block_no1 * (MAX_RXDS_PER_BLOCK + 1) + off1;
+#else
offset = block_no * (MAX_RXDS_PER_BLOCK) + off;
offset1 = block_no1 * (MAX_RXDS_PER_BLOCK) + off1;
+#endif
+
rxdp = nic->rx_blocks[ring_no][block_no].
    block_virt_addr + off;
if ((offset == offset1) && (rxdp->Host_Control)) {
@@ -1600,6 +1708,7 @@
DBG_PRINT(INTR_DBG, " info equated\n");
goto end;
}
+#ifndef CONFIG_2BUFF_MODE
if (rxdp->Control_1 == END_OF_BLOCK) {
mac_control->rx_curr_put_info[ring_no].
    block_index++;
@@ -1617,23 +1726,81 @@
}
#ifndef CONFIG_S2IO_NAPI
spin_lock_irqsave(&nic->put_lock, flags);
+ nic->put_pos[ring_no] =
+     (block_no * (MAX_RXDS_PER_BLOCK + 1)) + off;
+ spin_unlock_irqrestore(&nic->put_lock, flags);
+#endif
+#else
+ if (rxdp->Host_Control == END_OF_BLOCK) {
+ mac_control->rx_curr_put_info[ring_no].
+     block_index++;
+ mac_control->rx_curr_put_info[ring_no].
+     block_index %= nic->block_count[ring_no];
+ block_no = mac_control->rx_curr_put_info
+     [ring_no].block_index;
+ off = 0;
+ DBG_PRINT(INTR_DBG, "%s: block%d at: 0x%llx\n",
+   dev->name, block_no,
+   (unsigned long long) rxdp->Control_1);
+ mac_control->rx_curr_put_info[ring_no].offset =
+     off;
+ rxdp = nic->rx_blocks[ring_no][block_no].
+     block_virt_addr;
+ }
+#ifndef CONFIG_S2IO_NAPI
+ spin_lock_irqsave(&nic->put_lock, flags);
nic->put_pos[ring_no] = (block_no *
 (MAX_RXDS_PER_BLOCK + 1)) + off;
spin_unlock_irqrestore(&nic->put_lock, flags);
#endif
+#endif

- if (rxdp->Control_1 & RXD_OWN_XENA) {
+#ifndef CONFIG_2BUFF_MODE
+ if (rxdp->Control_1 & RXD_OWN_XENA)
+#else
+ if (rxdp->Control_2 & BIT(0))
+#endif
+ {
mac_control->rx_curr_put_info[ring_no].
    offset = off;
goto end;
}
+#ifdef CONFIG_2BUFF_MODE
+ /* 
+  * RxDs Spanning cache lines will be replenished only 
+  * if the succeeding RxD is also owned by Host. It 
+  * will always be the ((8*i)+3) and ((8*i)+6) 
+  * descriptors for the 48 byte descriptor. The offending 
+  * decsriptor is of-course the 3rd descriptor.
+  */
+ rxdpphys = nic->rx_blocks[ring_no][block_no].
+     block_dma_addr + (off * sizeof(RxD_t));
+ if (((u64) (rxdpphys)) % 128 > 80) {
+ rxdpnext = nic->rx_blocks[ring_no][block_no].
+     block_virt_addr + (off + 1);
+ if (rxdpnext->Host_Control == END_OF_BLOCK) {
+ nextblk = (block_no + 1) %
+     (nic->block_count[ring_no]);
+ rxdpnext = nic->rx_blocks[ring_no]
+     [nextblk].block_virt_addr;
+ }
+ if (rxdpnext->Control_2 & BIT(0))
+ goto end;
+ }
+#endif

+#ifndef CONFIG_2BUFF_MODE
skb = dev_alloc_skb(size + NET_IP_ALIGN);
+#else
+ skb = dev_alloc_skb(dev->mtu + ALIGN_SIZE +
+     /*BUF0_LEN + */ 22);
+#endif
if (!skb) {
DBG_PRINT(ERR_DBG, "%s: Out of ", dev->name);
DBG_PRINT(ERR_DBG, "memory to allocate SKBs\n");
return -ENOMEM;
}
+#ifndef CONFIG_2BUFF_MODE
skb_reserve(skb, NET_IP_ALIGN);
memset(rxdp, 0, sizeof(RxD_t));
rxdp->Buffer0_ptr = pci_map_single
@@ -1645,6 +1812,33 @@
off++;
off %= (MAX_RXDS_PER_BLOCK + 1);
mac_control->rx_curr_put_info[ring_no].offset = off;
+#else
+ ba = &nic->ba[ring_no][block_no][off];
+ tmp = (u64) skb->data;
+ tmp += ALIGN_SIZE;
+ tmp &= ~ALIGN_SIZE;
+ skb->data = (void *) tmp;
+
+ memset(rxdp, 0, sizeof(RxD_t));
+ rxdp->Buffer2_ptr = pci_map_single
+     (nic->pdev, skb->data, dev->mtu + 22,
+      PCI_DMA_FROMDEVICE);
+ rxdp->Buffer0_ptr =
+     pci_map_single(nic->pdev, ba->ba_0, BUF0_LEN,
+    PCI_DMA_FROMDEVICE);
+ rxdp->Buffer1_ptr =
+     pci_map_single(nic->pdev, ba->ba_1, BUF1_LEN,
+    PCI_DMA_FROMDEVICE);
+
+ rxdp->Control_2 = SET_BUFFER2_SIZE(dev->mtu + 22);
+ rxdp->Control_2 |= SET_BUFFER0_SIZE(BUF0_LEN);
+ rxdp->Control_2 |= SET_BUFFER1_SIZE(1); /* dummy. */
+ rxdp->Control_2 |= BIT(0); /* Set Buffer_Empty bit. */
+ rxdp->Host_Control = (u64) ((unsigned long) (skb));
+ rxdp->Control_1 |= RXD_OWN_XENA;
+ off++;
+ mac_control->rx_curr_put_info[ring_no].offset = off;
+#endif
atomic_inc(&nic->rx_bufs_left[ring_no]);
alloc_tab++;
}
@@ -1670,6 +1864,9 @@
struct sk_buff *skb;
mac_info_t *mac_control;
struct config_param *config;
+#ifdef CONFIG_2BUFF_MODE
+ buffAdd_t *ba;
+#endif

mac_control = &sp->mac_control;
config = &sp->config;
@@ -1679,6 +1876,7 @@
off = j % (MAX_RXDS_PER_BLOCK + 1);
rxdp = sp->rx_blocks[i][blk].block_virt_addr + off;

+#ifndef CONFIG_2BUFF_MODE
if (rxdp->Control_1 == END_OF_BLOCK) {
rxdp =
    (RxD_t *) ((unsigned long) rxdp->
@@ -1686,6 +1884,12 @@
j++;
blk++;
}
+#else
+ if (rxdp->Host_Control == END_OF_BLOCK) {
+ blk++;
+ continue;
+ }
+#endif

if (!(rxdp->Control_1 & RXD_OWN_XENA)) {
memset(rxdp, 0, sizeof(RxD_t));
@@ -1696,6 +1900,7 @@
    (struct sk_buff *) ((unsigned long) rxdp->
Host_Control);
if (skb) {
+#ifndef CONFIG_2BUFF_MODE
pci_unmap_single(sp->pdev, (dma_addr_t)
 rxdp->Buffer0_ptr,
 dev->mtu +
@@ -1703,6 +1908,21 @@
 + HEADER_802_2_SIZE +
 HEADER_SNAP_SIZE,
 PCI_DMA_FROMDEVICE);
+#else
+ ba = &sp->ba[i][blk][off];
+ pci_unmap_single(sp->pdev, (dma_addr_t)
+  rxdp->Buffer0_ptr,
+  BUF0_LEN,
+  PCI_DMA_FROMDEVICE);
+ pci_unmap_single(sp->pdev, (dma_addr_t)
+  rxdp->Buffer1_ptr,
+  BUF1_LEN,
+  PCI_DMA_FROMDEVICE);
+ pci_unmap_single(sp->pdev, (dma_addr_t)
+  rxdp->Buffer2_ptr,
+  dev->mtu + 22,
+  PCI_DMA_FROMDEVICE);
+#endif
dev_kfree_skb(skb);
atomic_dec(&sp->rx_bufs_left[i]);
buf_cnt++;
@@ -1741,11 +1961,16 @@
register u64 val64 = 0;
rx_curr_get_info_t get_info, put_info;
int i, get_block, put_block, get_offset, put_offset, ring_bufs;
+#ifndef CONFIG_2BUFF_MODE
u16 val16, cksum;
+#endif
struct sk_buff *skb;
RxD_t *rxdp;
mac_info_t *mac_control;
struct config_param *config;
+#ifdef CONFIG_2BUFF_MODE
+ buffAdd_t *ba;
+#endif

mac_control = &nic->mac_control;
config = &nic->config;
@@ -1764,6 +1989,7 @@
ring_bufs = config->rx_cfg[i].num_rxd;
rxdp = nic->rx_blocks[i][get_block].block_virt_addr +
    get_info.offset;
+#ifndef CONFIG_2BUFF_MODE
get_offset = (get_block * (MAX_RXDS_PER_BLOCK + 1)) +
    get_info.offset;
put_offset = (put_block * (MAX_RXDS_PER_BLOCK + 1)) +
@@ -1820,6 +2046,66 @@
mac_control->rx_curr_get_info[i].offset =
    get_info.offset;
}
+#else
+ get_offset = (get_block * (MAX_RXDS_PER_BLOCK + 1)) +
+     get_info.offset;
+ put_offset = (put_block * (MAX_RXDS_PER_BLOCK + 1)) +
+     put_info.offset;
+ while (((!(rxdp->Control_1 & RXD_OWN_XENA)) &&
+ !(rxdp->Control_2 & BIT(0))) &&
+        (((get_offset + 1) % ring_bufs) != put_offset)) {
+ if (--pkts_to_process < 0) {
+ goto no_rx;
+ }
+ skb = (struct sk_buff *) ((unsigned long)
+   rxdp->Host_Control);
+ if (skb == NULL) {
+ DBG_PRINT(ERR_DBG, "%s: The skb is ",
+   dev->name);
+ DBG_PRINT(ERR_DBG, "Null in Rx Intr\n");
+ goto no_rx;
+ }
+
+ pci_unmap_single(nic->pdev, (dma_addr_t)
+  rxdp->Buffer0_ptr,
+  BUF0_LEN, PCI_DMA_FROMDEVICE);
+ pci_unmap_single(nic->pdev, (dma_addr_t)
+  rxdp->Buffer1_ptr,
+  BUF1_LEN, PCI_DMA_FROMDEVICE);
+ pci_unmap_single(nic->pdev, (dma_addr_t)
+  rxdp->Buffer2_ptr,
+  dev->mtu + 22,
+  PCI_DMA_FROMDEVICE);
+ ba = &nic->ba[i][get_block][get_info.offset];
+
+ rx_osm_handler(nic, rxdp, i, ba);
+
+ get_info.offset++;
+ mac_control->rx_curr_get_info[i].offset =
+     get_info.offset;
+ rxdp =
+     nic->rx_blocks[i][get_block].block_virt_addr +
+     get_info.offset;
+
+ if (get_info.offset &&
+     (!(get_info.offset % MAX_RXDS_PER_BLOCK))) {
+ get_info.offset = 0;
+ mac_control->rx_curr_get_info[i].
+     offset = get_info.offset;
+ get_block++;
+ get_block %= nic->block_count[i];
+ mac_control->rx_curr_get_info[i].
+     block_index = get_block;
+ rxdp =
+     nic->rx_blocks[i][get_block].
+     block_virt_addr;
+ }
+ get_offset =
+     (get_block * (MAX_RXDS_PER_BLOCK + 1)) +
+     get_info.offset;
+ pkt_cnt++;
+ }
+#endif
}
if (!pkt_cnt)
pkt_cnt = 1;
@@ -1873,12 +2159,17 @@
rx_curr_get_info_t get_info, put_info;
RxD_t *rxdp;
struct sk_buff *skb;
+#ifndef CONFIG_2BUFF_MODE
u16 val16, cksum;
+#endif
register u64 val64 = 0;
int get_block, get_offset, put_block, put_offset, ring_bufs;
int i, pkt_cnt = 0;
mac_info_t *mac_control;
struct config_param *config;
+#ifdef CONFIG_2BUFF_MODE
+ buffAdd_t *ba;
+#endif

mac_control = &nic->mac_control;
config = &nic->config;
@@ -1898,6 +2189,7 @@
ring_bufs = config->rx_cfg[i].num_rxd;
rxdp = nic->rx_blocks[i][get_block].block_virt_addr +
    get_info.offset;
+#ifndef CONFIG_2BUFF_MODE
get_offset = (get_block * (MAX_RXDS_PER_BLOCK + 1)) +
    get_info.offset;
spin_lock(&nic->put_lock);
@@ -1953,6 +2245,67 @@
    && (pkt_cnt > indicate_max_pkts))
break;
}
+#else
+ get_offset = (get_block * (MAX_RXDS_PER_BLOCK + 1)) +
+     get_info.offset;
+ spin_lock(&nic->put_lock);
+ put_offset = nic->put_pos[i];
+ spin_unlock(&nic->put_lock);
+ while (((!(rxdp->Control_1 & RXD_OWN_XENA)) &&
+ !(rxdp->Control_2 & BIT(0))) &&
+        (((get_offset + 1) % ring_bufs) != put_offset)) {
+ skb = (struct sk_buff *) ((unsigned long)
+   rxdp->Host_Control);
+ if (skb == NULL) {
+ DBG_PRINT(ERR_DBG, "%s: The skb is ",
+   dev->name);
+ DBG_PRINT(ERR_DBG, "Null in Rx Intr\n");
+ return;
+ }
+
+ pci_unmap_single(nic->pdev, (dma_addr_t)
+  rxdp->Buffer0_ptr,
+  BUF0_LEN, PCI_DMA_FROMDEVICE);
+ pci_unmap_single(nic->pdev, (dma_addr_t)
+  rxdp->Buffer1_ptr,
+  BUF1_LEN, PCI_DMA_FROMDEVICE);
+ pci_unmap_single(nic->pdev, (dma_addr_t)
+  rxdp->Buffer2_ptr,
+  dev->mtu + 22,
+  PCI_DMA_FROMDEVICE);
+ ba = &nic->ba[i][get_block][get_info.offset];
+
+ rx_osm_handler(nic, rxdp, i, ba);
+
+ get_info.offset++;
+ mac_control->rx_curr_get_info[i].offset =
+     get_info.offset;
+ rxdp =
+     nic->rx_blocks[i][get_block].block_virt_addr +
+     get_info.offset;
+
+ if (get_info.offset &&
+     (!(get_info.offset % MAX_RXDS_PER_BLOCK))) {
+ get_info.offset = 0;
+ mac_control->rx_curr_get_info[i].
+     offset = get_info.offset;
+ get_block++;
+ get_block %= nic->block_count[i];
+ mac_control->rx_curr_get_info[i].
+     block_index = get_block;
+ rxdp =
+     nic->rx_blocks[i][get_block].
+     block_virt_addr;
+ }
+ get_offset =
+     (get_block * (MAX_RXDS_PER_BLOCK + 1)) +
+     get_info.offset;
+ pkt_cnt++;
+ if ((indicate_max_pkts)
+     && (pkt_cnt > indicate_max_pkts))
+ break;
+ }
+#endif
if ((indicate_max_pkts) && (pkt_cnt > indicate_max_pkts))
break;
}
@@ -4096,12 +4449,21 @@
 *   Return value:
 *   SUCCESS on success and -1 on failure.
 */
+#ifndef CONFIG_2BUFF_MODE
static int rx_osm_handler(nic_t * sp, u16 len, RxD_t * rxdp, int ring_no)
+#else
+static int rx_osm_handler(nic_t * sp, RxD_t * rxdp, int ring_no,
+   buffAdd_t * ba)
+#endif
{
struct net_device *dev = (struct net_device *) sp->dev;
struct sk_buff *skb =
    (struct sk_buff *) ((unsigned long) rxdp->Host_Control);
u16 l3_csum, l4_csum;
+#ifdef CONFIG_2BUFF_MODE
+ int buf0_len, buf2_len;
+ struct ethhdr *eth = (struct ethhdr *) ba->ba_0;
+#endif

l3_csum = RXD_GET_L3_CKSUM(rxdp->Control_1);
if ((rxdp->Control_1 & TCP_OR_UDP_FRAME) && (sp->rx_csum)) {
@@ -4129,10 +4491,32 @@
DBG_PRINT(ERR_DBG, "%s: Rx error Value: 0x%llx\n",
  dev->name, err);
}
+#ifdef CONFIG_2BUFF_MODE
+ buf0_len = RXD_GET_BUFFER0_SIZE(rxdp->Control_2);
+ buf2_len = RXD_GET_BUFFER2_SIZE(rxdp->Control_2);
+#endif

skb->dev = dev;
+#ifndef CONFIG_2BUFF_MODE
skb_put(skb, len);
skb->protocol = eth_type_trans(skb, dev);
+#else
+ skb_put(skb, buf2_len);
+ /* 
+  * Reproducing eth_type_trans functionality and running
+  * on the ethernet header 'eth' stripped and given to us
+  * by the hardware in 2Buff mode.
+  */
+ if (*eth->h_dest & 1) {
+ if (!memcmp(eth->h_dest, dev->broadcast, ETH_ALEN))
+ skb->pkt_type = PACKET_BROADCAST;
+ else
+ skb->pkt_type = PACKET_MULTICAST;
+ } else if (memcmp(eth->h_dest, dev->dev_addr, ETH_ALEN)) {
+ skb->pkt_type = PACKET_OTHERHOST;
+ }
+ skb->protocol = eth->h_proto;
+#endif

#ifdef CONFIG_S2IO_NAPI
netif_receive_skb(skb);
@@ -4143,7 +4527,11 @@
dev->last_rx = jiffies;
sp->rx_pkt_count++;
sp->stats.rx_packets++;
+#ifndef CONFIG_2BUFF_MODE
sp->stats.rx_bytes += len;
+#else
+ sp->stats.rx_bytes += buf0_len + buf2_len;
+#endif

atomic_dec(&sp->rx_bufs_left[ring_no]);
rxdp->Host_Control = 0;
diff -urN vanilla-linux/drivers/net/s2io.h linux-2.6.8.1/drivers/net/s2io.h
--- vanilla-linux/drivers/net/s2io.h 2004-10-11 21:21:49.000000000 -0700
+++ linux-2.6.8.1/drivers/net/s2io.h 2004-10-11 21:22:23.000000000 -0700
@@ -466,19 +466,46 @@
#define RXD_GET_L4_CKSUM(val)   ((u16)(val) & 0xFFFF)

u64 Control_2;
+#ifndef CONFIG_2BUFF_MODE
#define MASK_BUFFER0_SIZE       vBIT(0xFFFF,0,16)
#define SET_BUFFER0_SIZE(val)   vBIT(val,0,16)
+#else
+#define MASK_BUFFER0_SIZE       vBIT(0xFF,0,16)
+#define MASK_BUFFER1_SIZE       vBIT(0xFFFF,16,16)
+#define MASK_BUFFER2_SIZE       vBIT(0xFFFF,32,16)
+#define SET_BUFFER0_SIZE(val)   vBIT(val,8,8)
+#define SET_BUFFER1_SIZE(val)   vBIT(val,16,16)
+#define SET_BUFFER2_SIZE(val)   vBIT(val,32,16)
+#endif
+
#define MASK_VLAN_TAG           vBIT(0xFFFF,48,16)
#define SET_VLAN_TAG(val)       vBIT(val,48,16)
#define SET_NUM_TAG(val)       vBIT(val,16,32)

+#ifndef CONFIG_2BUFF_MODE
#define RXD_GET_BUFFER0_SIZE(Control_2) (u64)((Control_2 &
vBIT(0xFFFF,0,16)))
+#else
+#define RXD_GET_BUFFER0_SIZE(Control_2) (u8)((Control_2 &
MASK_BUFFER0_SIZE) \
+ >> 48)
+#define RXD_GET_BUFFER1_SIZE(Control_2) (u16)((Control_2 &
MASK_BUFFER1_SIZE) \
+ >> 32)
+#define RXD_GET_BUFFER2_SIZE(Control_2) (u16)((Control_2 &
MASK_BUFFER2_SIZE) \
+ >> 16)
+#define BUF0_LEN 40
+#define BUF1_LEN 1
+#endif
+
u64 Buffer0_ptr;
+#ifdef CONFIG_2BUFF_MODE
+ u64 Buffer1_ptr;
+ u64 Buffer2_ptr;
+#endif
} RxD_t;

/* Structure that represents the Rx descriptor block which contains 
 * 128 Rx descriptors.
 */
+#ifndef CONFIG_2BUFF_MODE
typedef struct _RxD_block {
#define MAX_RXDS_PER_BLOCK             127
RxD_t rxd[MAX_RXDS_PER_BLOCK];
@@ -492,6 +519,27 @@
 * the upper 32 bits should 
 * be 0 */
} RxD_block_t;
+#else
+typedef struct _RxD_block {
+#define MAX_RXDS_PER_BLOCK             85
+ RxD_t rxd[MAX_RXDS_PER_BLOCK];
+
+#define END_OF_BLOCK    0xFEFFFFFFFFFFFFFFULL
+ u64 reserved_1; /* 0xFEFFFFFFFFFFFFFF to mark last Rxd 
+  * in this blk */
+ u64 pNext_RxD_Blk_physical; /* Phy ponter to next blk. */
+} RxD_block_t;
+#define SIZE_OF_BLOCK 4096
+
+/* Structure to hold virtual addresses of Buf0 and Buf1 in 
+ * 2buf mode. */
+typedef struct bufAdd {
+ void *ba_0_org;
+ void *ba_1_org;
+ void *ba_0;
+ void *ba_1;
+} buffAdd_t;
+#endif

/* Structure which stores all the MAC control parameters */

@@ -677,6 +725,10 @@
#define LINK_DOWN 1
#define LINK_UP 2

+#ifdef CONFIG_2BUFF_MODE
+ /* Buffer Address store. */
+ buffAdd_t **ba[MAX_RX_RINGS];
+#endif
int task_flag;
} nic_t;

@@ -802,7 +854,12 @@
static void s2io_tx_watchdog(struct net_device *dev);
static void s2io_tasklet(unsigned long dev_addr);
static void s2io_set_multicast(struct net_device *dev);
+#ifndef CONFIG_2BUFF_MODE
static int rx_osm_handler(nic_t * sp, u16 len, RxD_t * rxdp, int ring_no);
+#else
+static int rx_osm_handler(nic_t * sp, RxD_t * rxdp, int ring_no,
+   buffAdd_t * ba);
+#endif
void s2io_link(nic_t * sp, int link);
void s2io_reset(nic_t * sp);
#ifdef CONFIG_S2IO_NAPI





------=_NextPart_001_001B_01C4C649.C6348720
Content-Type: text/html;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META http-equiv=3DContent-Type content=3D"text/html; =
charset=3Dus-ascii">
<META content=3D"MSHTML 6.00.2900.2523" name=3DGENERATOR></HEAD>
<BODY>
<DIV dir=3Dltr align=3Dleft><FONT face=3DArial color=3D#0000ff =
size=3D2><SPAN=20
class=3D343562918-09112004>You are right a check for ba[i] at the top is =

necessary. Also your second observation</SPAN></FONT></DIV>
<DIV dir=3Dltr align=3Dleft><FONT face=3DArial color=3D#0000ff =
size=3D2><SPAN=20
class=3D343562918-09112004>is valid, there's no chance of discontinuous =
chunks=20
of&nbsp;memory &nbsp;within the ba block.&nbsp;</SPAN></FONT></DIV>
<DIV dir=3Dltr align=3Dleft><FONT face=3DArial color=3D#0000ff =
size=3D2><SPAN=20
class=3D343562918-09112004></SPAN></FONT>&nbsp;</DIV>
<DIV dir=3Dltr align=3Dleft><FONT face=3DArial color=3D#0000ff =
size=3D2><SPAN=20
class=3D343562918-09112004>Thanks</SPAN></FONT></DIV>
<DIV dir=3Dltr align=3Dleft><FONT face=3DArial color=3D#0000ff =
size=3D2><SPAN=20
class=3D343562918-09112004>Koushik</SPAN></FONT></DIV>
<DIV dir=3Dltr align=3Dleft><FONT face=3DArial color=3D#0000ff =
size=3D2><SPAN=20
class=3D343562918-09112004></SPAN></FONT><FONT face=3DArial =
color=3D#0000ff=20
size=3D2><SPAN =
class=3D343562918-09112004>&nbsp;</SPAN></FONT></DIV><FONT face=3DArial=20
color=3D#0000ff size=3D2></FONT><BR>
<BLOCKQUOTE dir=3Dltr=20
style=3D"PADDING-LEFT: 5px; MARGIN-LEFT: 5px; BORDER-LEFT: #0000ff 2px =
solid; MARGIN-RIGHT: 0px">
  <DIV class=3DOutlookMessageHeader lang=3Den-us dir=3Dltr align=3Dleft>
  <HR tabIndex=3D-1>
  <FONT face=3DTahoma size=3D2><B>From:</B> Krishna Kumar=20
  [mailto:kumarkr@us.ibm.com] <BR><B>Sent:</B> Monday, November 08, 2004 =
4:41=20
  PM<BR><B>To:</B> raghavendra.koushik@s2io.com<BR><B>Cc:</B> =
jgarzik@pobox.com;=20
  netdev@oss.sgi.com; raghavendra.koushik@s2io.com; =
ravinandan.arakali@s2io.com;=20
  romieu@fr.zoreil.com<BR><B>Subject:</B> Re: [PATCH 2.6.9-rc2 8/12] =
S2io: two=20
  buffer mode<BR></FONT><BR></DIV>
  <DIV></DIV>
  <P>Sorry if my mailer mangles the mail, but ...<BR><BR>This code looks =
like it=20
  can cause an oops on failure to alloc cases. I havent read the code =
very much=20
  other than the<BR>init and the free routines.<BR><BR><TT>+#ifdef=20
  CONFIG_2BUFF_MODE<BR>+ /* Freeing buffer storage addresses in 2BUFF =
mode.=20
  */<BR>+ for (i =3D 0; i &lt; config-&gt;rx_ring_num; i++) {<BR>+ =
blk_cnt =3D<BR>+=20
  &nbsp; &nbsp; config-&gt;rx_cfg[i].num_rxd / (MAX_RXDS_PER_BLOCK + =
1);<BR>+=20
  for (j =3D 0; j &lt; blk_cnt; j++) {<BR>+ int k =3D 0;<BR>+ if=20
  (!nic-&gt;ba[i][j])<BR>+ continue;<BR>+ while (k !=3D =
MAX_RXDS_PER_BLOCK) {<BR>+=20
  buffAdd_t *ba =3D &amp;nic-&gt;ba[i][j][k];<BR>+ =
kfree(ba-&gt;ba_0_org);<BR>+=20
  kfree(ba-&gt;ba_1_org);<BR>+ k++;<BR>+ }<BR>+ =
kfree(nic-&gt;ba[i][j]);<BR>+=20
  }<BR>+ if (nic-&gt;ba[i])<BR>+ kfree(nic-&gt;ba[i]);<BR>+=20
  }<BR>+#endif</TT><BR><BR>Shouldn't this be something like (check ba[i] =
at the=20
  top to avoid MMU) :<BR><BR><TT>+#ifdef CONFIG_2BUFF_MODE<BR>+ /* =
Freeing=20
  buffer storage addresses in 2BUFF mode. */<BR>+ for (i =3D 0; i &lt;=20
  config-&gt;rx_ring_num; i++) {</TT><BR><TT>+ if (!nic-&gt;ba[i]) /* if =
there=20
  are no holes, we are done */</TT><BR><TT>+ break;<BR>+ blk_cnt =
=3D<BR>+ &nbsp;=20
  &nbsp; config-&gt;rx_cfg[i].num_rxd / (MAX_RXDS_PER_BLOCK + 1);<BR>+ =
for (j =3D=20
  0; j &lt; blk_cnt; j++) {<BR>+ int k =3D 0;<BR>+ if =
(!nic-&gt;ba[i][j])<BR>+=20
  continue;</TT><BR><TT>&gt;&gt; Should this be a break ? Can you have =
holes in=20
  the middle ?</TT><BR><TT>+ while (k !=3D MAX_RXDS_PER_BLOCK) {<BR>+ =
buffAdd_t=20
  *ba =3D &amp;nic-&gt;ba[i][j][k];<BR>+ kfree(ba-&gt;ba_0_org);<BR>+=20
  kfree(ba-&gt;ba_1_org);</TT><BR><TT>&gt;&gt; Actually if no holes are =
allowed,=20
  you can break out if the above pointers become</TT><BR><TT>&gt;&gt; =
NULL=20
  instead of iterating MAX_RXDS_PER_BLOCK (127) times.<BR>+ k++;<BR>+ =
}<BR>+=20
  kfree(nic-&gt;ba[i][j]);<BR>+ }<BR>+ kfree(nic-&gt;ba[i]);<BR>+=20
  }<BR>+#endif</TT><BR><BR>thx,<BR><BR>- KK<BR><BR><IMG height=3D16=20
  alt=3D"Inactive hide details for raghavendra.koushik@s2io.com"=20
  src=3D"cid:343562918@09112004-2616"=20
  width=3D16>raghavendra.koushik@s2io.com<BR><BR><BR>
  <TABLE cellSpacing=3D0 cellPadding=3D0 width=3D"100%" border=3D0>
    <TBODY>
    <TR vAlign=3Dtop>
      <TD=20
      style=3D"BACKGROUND-IMAGE: =
url(cid:30__=3D07BBE5D4DF915B888f9e8a93df938@us.ibm.com); =
BACKGROUND-REPEAT: no-repeat"=20
      width=3D"40%">
        <UL>
          <UL>
            <UL>
              <UL><B><FONT =
size=3D2>raghavendra.koushik@s2io.com</FONT></B><FONT=20
                size=3D2> </FONT><BR><FONT size=3D2>Sent by:=20
                netdev-bounce@oss.sgi.com</FONT>=20
                <P><FONT size=3D2>11/08/2004 08:16 =
AM</FONT></P></UL></UL></UL></UL></TD>
      <TD width=3D"60%">
        <TABLE cellSpacing=3D0 cellPadding=3D0 width=3D"100%" =
border=3D0>
          <TBODY>
          <TR vAlign=3Dtop>
            <TD vAlign=3Dcenter width=3D"1%"><IMG height=3D1 alt=3D""=20
              src=3D"cid:343562918@09112004-261D" width=3D58 =
border=3D0><BR>
              <DIV align=3Dright><FONT size=3D2>To</FONT></DIV></TD>
            <TD width=3D"100%"><IMG height=3D1 alt=3D""=20
              src=3D"cid:343562918@09112004-261D" width=3D1 =
border=3D0><BR><FONT=20
              size=3D2>jgarzik@pobox.com, romieu@fr.zoreil.com,=20
              netdev@oss.sgi.com</FONT></TD></TR>
          <TR vAlign=3Dtop>
            <TD vAlign=3Dcenter width=3D"1%"><IMG height=3D1 alt=3D""=20
              src=3D"cid:343562918@09112004-261D" width=3D58 =
border=3D0><BR>
              <DIV align=3Dright><FONT size=3D2>cc</FONT></DIV></TD>
            <TD width=3D"100%"><IMG height=3D1 alt=3D""=20
              src=3D"cid:343562918@09112004-261D" width=3D1 =
border=3D0><BR><FONT=20
              size=3D2>ravinandan.arakali@s2io.com,=20
              raghavendra.koushik@s2io.com</FONT></TD></TR>
          <TR vAlign=3Dtop>
            <TD vAlign=3Dcenter width=3D"1%"><IMG height=3D1 alt=3D""=20
              src=3D"cid:343562918@09112004-261D" width=3D58 =
border=3D0><BR>
              <DIV align=3Dright><FONT =
size=3D2>Subject</FONT></DIV></TD>
            <TD width=3D"100%"><IMG height=3D1 alt=3D""=20
              src=3D"cid:343562918@09112004-261D" width=3D1 =
border=3D0><BR><FONT=20
              size=3D2>[PATCH 2.6.9-rc2 8/12] S2io: two buffer=20
          mode</FONT></TD></TR></TBODY></TABLE>
        <TABLE cellSpacing=3D0 cellPadding=3D0 border=3D0>
          <TBODY>
          <TR vAlign=3Dtop>
            <TD width=3D58><IMG height=3D1 alt=3D""=20
              src=3D"cid:343562918@09112004-261D" width=3D1 =
border=3D0></TD>
            <TD width=3D336><IMG height=3D1 alt=3D""=20
              src=3D"cid:343562918@09112004-261D" width=3D1=20
        =
border=3D0></TD></TR></TBODY></TABLE></TD></TR></TBODY></TABLE><BR><TT>Hi=
,<BR>Attached=20
  is the patch for implementing 2-buffer mode on Rx path.<BR>More =
description of=20
  this mode of operation follows.<BR><BR>On certain systems when a DMA =
has to=20
  happen on an un-aligned memory location performance will take a =
significant=20
  hit. It's standard<BR>practice to offset the Rx buffer address by 2 =
(as Mac=20
  header is 14 bytes) so the IP header starts from an aligned=20
  location.<BR>Obviously using a single Rx buffer both cannot be =
achieved. Thus=20
  XFrame supports something called 2 buffer Rx mode, where in =
the<BR>Rx'ed frame=20
  is split into 2 parts, one is the Ethernet header and the other is the =

  Ethernet payload. So now we can allocate proper<BR>aligned memory for =
both=20
  buffers, hence the DMA is not slowed down. Also, the Ethernet =
payload(starting=20
  from L3 header) is on an<BR>aligned location so OS need not have to do =

  un-aligned accesses to process IP header. To achieve this, the kernel=20
  function<BR>eth_type_trans functionality has to be partially =
implemented in=20
  the driver itself.<BR><BR>Signed-off-by: Raghavendra Koushik=20
  &lt;raghavendra.koushik@s2io.com&gt;<BR>Signed-off-by: Ravinandan =
Arakali=20
  &lt;ravinandan.arakali@s2io.com&gt;<BR>---<BR>diff -urN=20
  vanilla-linux/drivers/net/Kconfig =
linux-2.6.8.1/drivers/net/Kconfig<BR>---=20
  vanilla-linux/drivers/net/Kconfig 2004-10-06 15:15:04.000000000 =
-0700<BR>+++=20
  linux-2.6.8.1/drivers/net/Kconfig 2004-10-11 20:06:36.000000000 =
-0700<BR>@@=20
  -2267,6 +2267,17 @@<BR><BR>&nbsp; If in doubt, say N.<BR><BR>+config=20
  2BUFF_MODE<BR>+ bool "Use 2 Buffer Mode on Rx side."<BR>+ depends on =
S2IO<BR>+=20
  ---help---<BR>+ On enabling the 2 buffer mode, the received frame will =
be<BR>+=20
  split into 2 parts before being DMA'ed to the hosts memory.<BR>+ The =
parts are=20
  the ethernet header and ethernet payload. <BR>+ This is useful on =
systems=20
  where DMA'ing to to unaligned <BR>+ physical memory loactions comes =
with a=20
  heavy price.<BR>+ If not sure please say =
N.<BR>+<BR>endmenu<BR><BR>source=20
  "drivers/net/tokenring/Kconfig"<BR>diff -urN =
vanilla-linux/drivers/net/s2io.c=20
  linux-2.6.8.1/drivers/net/s2io.c<BR>--- =
vanilla-linux/drivers/net/s2io.c=20
  2004-10-11 21:21:49.000000000 -0700<BR>+++ =
linux-2.6.8.1/drivers/net/s2io.c=20
  2004-10-12 16:49:27.796331624 -0700<BR>@@ -325,6 +325,10 @@<BR>int i, =
j,=20
  blk_cnt;<BR>int lst_size, lst_per_page;<BR>struct net_device *dev =3D=20
  nic-&gt;dev;<BR>+#ifdef CONFIG_2BUFF_MODE<BR>+ u64 tmp;<BR>+ buffAdd_t =

  *ba;<BR>+#endif<BR><BR>mac_info_t *mac_control;<BR>struct config_param =

  *config;<BR>@@ -425,7 +429,11 @@<BR>&nbsp; &nbsp; =
config-&gt;rx_cfg[i].num_rxd=20
  / (MAX_RXDS_PER_BLOCK + 1);<BR>/* &nbsp;Allocating all the Rx blocks =
*/<BR>for=20
  (j =3D 0; j &lt; blk_cnt; j++) {<BR>+#ifndef CONFIG_2BUFF_MODE<BR>size =
=3D=20
  (MAX_RXDS_PER_BLOCK + 1) * (sizeof(RxD_t));<BR>+#else<BR>+ size =3D=20
  SIZE_OF_BLOCK;<BR>+#endif<BR>tmp_v_addr =3D =
pci_alloc_consistent(nic-&gt;pdev,=20
  size,<BR>&nbsp; &amp;tmp_p_addr);<BR>if (tmp_v_addr =3D=3D NULL) =
{<BR>@@ -458,13=20
  +466,60 @@<BR>pre_rxd_blk-&gt;reserved_1 =3D END_OF_BLOCK; /* last RxD =

  <BR>&nbsp;* marker.<BR>&nbsp;*/<BR>+#ifndef=20
  CONFIG_2BUFF_MODE<BR>pre_rxd_blk-&gt;reserved_2_pNext_RxD_block =
=3D<BR>&nbsp;=20
  &nbsp; (unsigned long)=20
  tmp_v_addr_next;<BR>+#endif<BR>pre_rxd_blk-&gt;pNext_RxD_Blk_physical=20
  =3D<BR>&nbsp; &nbsp; (u64) tmp_p_addr_next;<BR>}<BR>}<BR><BR>+#ifdef=20
  CONFIG_2BUFF_MODE<BR>+ /* <BR>+ &nbsp;* Allocation of Storages for =
buffer=20
  addresses in 2BUFF mode<BR>+ &nbsp;* and the buffers as well.<BR>+=20
  &nbsp;*/<BR>+ for (i =3D 0; i &lt; config-&gt;rx_ring_num; i++) {<BR>+ =
blk_cnt=20
  =3D<BR>+ &nbsp; &nbsp; config-&gt;rx_cfg[i].num_rxd / =
(MAX_RXDS_PER_BLOCK +=20
  1);<BR>+ nic-&gt;ba[i] =3D kmalloc((sizeof(buffAdd_t *) * =
blk_cnt),<BR>+ &nbsp;=20
  &nbsp; &nbsp;GFP_KERNEL);<BR>+ if (!nic-&gt;ba[i])<BR>+ return =
-ENOMEM;<BR>+=20
  for (j =3D 0; j &lt; blk_cnt; j++) {<BR>+ int k =3D 0;<BR>+ =
nic-&gt;ba[i][j] =3D=20
  kmalloc((sizeof(buffAdd_t) *<BR>+ &nbsp;(MAX_RXDS_PER_BLOCK + =
1)),<BR>+=20
  GFP_KERNEL);<BR>+ if (!nic-&gt;ba[i][j])<BR>+ return -ENOMEM;<BR>+ =
while (k !=3D=20
  MAX_RXDS_PER_BLOCK) {<BR>+ ba =3D &amp;nic-&gt;ba[i][j][k];<BR>+<BR>+=20
  ba-&gt;ba_0_org =3D (void *) kmalloc<BR>+ &nbsp; &nbsp; (BUF0_LEN + =
ALIGN_SIZE,=20
  GFP_ATOMIC);<BR>+ if (!ba-&gt;ba_0_org)<BR>+ return -ENOMEM;<BR>+ tmp =
=3D (u64)=20
  ba-&gt;ba_0_org;<BR>+ tmp +=3D ALIGN_SIZE;<BR>+ tmp &amp;=3D ~((u64)=20
  ALIGN_SIZE);<BR>+ ba-&gt;ba_0 =3D (void *) tmp;<BR>+<BR>+ =
ba-&gt;ba_1_org =3D=20
  (void *) kmalloc<BR>+ &nbsp; &nbsp; (BUF1_LEN + ALIGN_SIZE, =
GFP_ATOMIC);<BR>+=20
  if (!ba-&gt;ba_1_org)<BR>+ return -ENOMEM;<BR>+ tmp =3D (u64)=20
  ba-&gt;ba_1_org;<BR>+ tmp +=3D ALIGN_SIZE;<BR>+ tmp &amp;=3D ~((u64)=20
  ALIGN_SIZE);<BR>+ ba-&gt;ba_1 =3D (void *) tmp;<BR>+ k++;<BR>+ }<BR>+ =
}<BR>+=20
  }<BR>+#endif<BR>+<BR>/* Allocation and initialization of Statistics =
block=20
  */<BR>size =3D sizeof(StatInfo_t);<BR>mac_control-&gt;stats_mem =3D=20
  pci_alloc_consistent<BR>@@ -532,7 +587,11=20
  @@<BR>kfree(nic-&gt;list_info[i]);<BR>}<BR><BR>+#ifndef=20
  CONFIG_2BUFF_MODE<BR>size =3D (MAX_RXDS_PER_BLOCK + 1) *=20
  (sizeof(RxD_t));<BR>+#else<BR>+ size =3D =
SIZE_OF_BLOCK;<BR>+#endif<BR>for (i =3D=20
  0; i &lt; config-&gt;rx_ring_num; i++) {<BR>blk_cnt =3D=20
  nic-&gt;block_count[i];<BR>for (j =3D 0; j &lt; blk_cnt; j++) {<BR>@@ =
-545,6=20
  +604,27 @@<BR>}<BR>}<BR><BR>+#ifdef CONFIG_2BUFF_MODE<BR>+ /* Freeing =
buffer=20
  storage addresses in 2BUFF mode. */<BR>+ for (i =3D 0; i &lt;=20
  config-&gt;rx_ring_num; i++) {<BR>+ blk_cnt =3D<BR>+ &nbsp; &nbsp;=20
  config-&gt;rx_cfg[i].num_rxd / (MAX_RXDS_PER_BLOCK + 1);<BR>+ for (j =
=3D 0; j=20
  &lt; blk_cnt; j++) {<BR>+ int k =3D 0;<BR>+ if =
(!nic-&gt;ba[i][j])<BR>+=20
  continue;<BR>+ while (k !=3D MAX_RXDS_PER_BLOCK) {<BR>+ buffAdd_t *ba =
=3D=20
  &amp;nic-&gt;ba[i][j][k];<BR>+ kfree(ba-&gt;ba_0_org);<BR>+=20
  kfree(ba-&gt;ba_1_org);<BR>+ k++;<BR>+ }<BR>+ =
kfree(nic-&gt;ba[i][j]);<BR>+=20
  }<BR>+ if (nic-&gt;ba[i])<BR>+ kfree(nic-&gt;ba[i]);<BR>+=20
  }<BR>+#endif<BR><BR>if (mac_control-&gt;stats_mem)=20
  {<BR>pci_free_consistent(nic-&gt;pdev,<BR>@@ -1366,10 +1446,21 =
@@<BR>&nbsp;=20
  &nbsp; &nbsp; &nbsp;&amp;bar0-&gt;prc_rxd0_n[i]);<BR><BR>val64 =3D=20
  readq(&amp;bar0-&gt;prc_ctrl_n[i]);<BR>+#ifndef =
CONFIG_2BUFF_MODE<BR>val64 |=3D=20
  PRC_CTRL_RC_ENABLED;<BR>+#else<BR>+ val64 |=3D PRC_CTRL_RC_ENABLED |=20
  PRC_CTRL_RING_MODE_3;<BR>+#endif<BR>writeq(val64,=20
  &amp;bar0-&gt;prc_ctrl_n[i]);<BR>}<BR><BR>+#ifdef =
CONFIG_2BUFF_MODE<BR>+ /*=20
  Enabling 2 buffer mode by writing into Rx_pa_cfg reg. */<BR>+ val64 =
=3D=20
  readq(&amp;bar0-&gt;rx_pa_cfg);<BR>+ val64 |=3D =
RX_PA_CFG_IGNORE_L2_ERR;<BR>+=20
  writeq(val64, &amp;bar0-&gt;rx_pa_cfg);<BR>+#endif<BR>+<BR>/* =
<BR>&nbsp;*=20
  Enabling MC-RLDRAM. After enabling the device, we timeout<BR>&nbsp;* =
for=20
  around 100ms, which is approximately the time required<BR>@@ -1437,6 =
+1528,12=20
  @@<BR>}<BR><BR>/* <BR>+ &nbsp;* Don't see link state interrupts on =
certain=20
  switches, so <BR>+ &nbsp;* directly scheduling a link state task from=20
  here.<BR>+ &nbsp;*/<BR>+ =
schedule_work(&amp;nic-&gt;set_link_task);<BR>+<BR>+=20
  /* <BR>&nbsp;* Here we are performing soft reset on XGXS to =
<BR>&nbsp;* force=20
  link down. Since link is already up, we will get<BR>&nbsp;* link state =
change=20
  interrupt after this reset<BR>@@ -1565,6 +1662,13 @@<BR>&nbsp; &nbsp;=20
  atomic_read(&amp;nic-&gt;rx_bufs_left[ring_no]);<BR>mac_info_t=20
  *mac_control;<BR>struct config_param *config;<BR>+#ifdef=20
  CONFIG_2BUFF_MODE<BR>+ RxD_t *rxdpnext;<BR>+ int nextblk;<BR>+ u64 =
tmp;<BR>+=20
  buffAdd_t *ba;<BR>+ dma_addr_t rxdpphys;<BR>+#endif<BR>#ifndef=20
  CONFIG_S2IO_NAPI<BR>unsigned long flags;<BR>#endif<BR>@@ -1589,10 =
+1693,14=20
  @@<BR>&nbsp; &nbsp; block_index;<BR>off =3D=20
  mac_control-&gt;rx_curr_put_info[ring_no].offset;<BR>off1 =3D=20
  mac_control-&gt;rx_curr_get_info[ring_no].offset;<BR>+#ifndef=20
  CONFIG_2BUFF_MODE<BR>offset =3D block_no * (MAX_RXDS_PER_BLOCK + 1) +=20
  off;<BR>offset1 =3D block_no1 * (MAX_RXDS_PER_BLOCK + 1) +=20
  off1;<BR>+#else<BR>offset =3D block_no * (MAX_RXDS_PER_BLOCK) + =
off;<BR>offset1=20
  =3D block_no1 * (MAX_RXDS_PER_BLOCK) + off1;<BR>+#endif<BR>+<BR>rxdp =
=3D=20
  nic-&gt;rx_blocks[ring_no][block_no].<BR>&nbsp; &nbsp; block_virt_addr =
+=20
  off;<BR>if ((offset =3D=3D offset1) &amp;&amp; =
(rxdp-&gt;Host_Control)) {<BR>@@=20
  -1600,6 +1708,7 @@<BR>DBG_PRINT(INTR_DBG, " info equated\n");<BR>goto=20
  end;<BR>}<BR>+#ifndef CONFIG_2BUFF_MODE<BR>if (rxdp-&gt;Control_1 =
=3D=3D=20
  END_OF_BLOCK) =
{<BR>mac_control-&gt;rx_curr_put_info[ring_no].<BR>&nbsp; &nbsp;=20
  block_index++;<BR>@@ -1617,23 +1726,81 @@<BR>}<BR>#ifndef=20
  CONFIG_S2IO_NAPI<BR>spin_lock_irqsave(&amp;nic-&gt;put_lock, =
flags);<BR>+=20
  nic-&gt;put_pos[ring_no] =3D<BR>+ &nbsp; &nbsp; (block_no * =
(MAX_RXDS_PER_BLOCK=20
  + 1)) + off;<BR>+ spin_unlock_irqrestore(&amp;nic-&gt;put_lock,=20
  flags);<BR>+#endif<BR>+#else<BR>+ if (rxdp-&gt;Host_Control =3D=3D =
END_OF_BLOCK)=20
  {<BR>+ mac_control-&gt;rx_curr_put_info[ring_no].<BR>+ &nbsp; &nbsp;=20
  block_index++;<BR>+ mac_control-&gt;rx_curr_put_info[ring_no].<BR>+ =
&nbsp;=20
  &nbsp; block_index %=3D nic-&gt;block_count[ring_no];<BR>+ block_no =
=3D=20
  mac_control-&gt;rx_curr_put_info<BR>+ &nbsp; &nbsp;=20
  [ring_no].block_index;<BR>+ off =3D 0;<BR>+ DBG_PRINT(INTR_DBG, "%s: =
block%d at:=20
  0x%llx\n",<BR>+ &nbsp; dev-&gt;name, block_no,<BR>+ &nbsp; (unsigned =
long=20
  long) rxdp-&gt;Control_1);<BR>+=20
  mac_control-&gt;rx_curr_put_info[ring_no].offset =3D<BR>+ &nbsp; =
&nbsp;=20
  off;<BR>+ rxdp =3D nic-&gt;rx_blocks[ring_no][block_no].<BR>+ &nbsp; =
&nbsp;=20
  block_virt_addr;<BR>+ }<BR>+#ifndef CONFIG_S2IO_NAPI<BR>+=20
  spin_lock_irqsave(&amp;nic-&gt;put_lock, =
flags);<BR>nic-&gt;put_pos[ring_no] =3D=20
  (block_no *<BR>&nbsp;(MAX_RXDS_PER_BLOCK + 1)) +=20
  off;<BR>spin_unlock_irqrestore(&amp;nic-&gt;put_lock,=20
  flags);<BR>#endif<BR>+#endif<BR><BR>- if (rxdp-&gt;Control_1 &amp;=20
  RXD_OWN_XENA) {<BR>+#ifndef CONFIG_2BUFF_MODE<BR>+ if =
(rxdp-&gt;Control_1=20
  &amp; RXD_OWN_XENA)<BR>+#else<BR>+ if (rxdp-&gt;Control_2 &amp;=20
  BIT(0))<BR>+#endif<BR>+=20
  {<BR>mac_control-&gt;rx_curr_put_info[ring_no].<BR>&nbsp; &nbsp; =
offset =3D=20
  off;<BR>goto end;<BR>}<BR>+#ifdef CONFIG_2BUFF_MODE<BR>+ /* <BR>+ =
&nbsp;* RxDs=20
  Spanning cache lines will be replenished only <BR>+ &nbsp;* if the =
succeeding=20
  RxD is also owned by Host. It <BR>+ &nbsp;* will always be the =
((8*i)+3) and=20
  ((8*i)+6) <BR>+ &nbsp;* descriptors for the 48 byte descriptor. The =
offending=20
  <BR>+ &nbsp;* decsriptor is of-course the 3rd descriptor.<BR>+ =
&nbsp;*/<BR>+=20
  rxdpphys =3D nic-&gt;rx_blocks[ring_no][block_no].<BR>+ &nbsp; &nbsp;=20
  block_dma_addr + (off * sizeof(RxD_t));<BR>+ if (((u64) (rxdpphys)) % =
128 &gt;=20
  80) {<BR>+ rxdpnext =3D nic-&gt;rx_blocks[ring_no][block_no].<BR>+ =
&nbsp; &nbsp;=20
  block_virt_addr + (off + 1);<BR>+ if (rxdpnext-&gt;Host_Control =3D=3D =

  END_OF_BLOCK) {<BR>+ nextblk =3D (block_no + 1) %<BR>+ &nbsp; &nbsp;=20
  (nic-&gt;block_count[ring_no]);<BR>+ rxdpnext =3D=20
  nic-&gt;rx_blocks[ring_no]<BR>+ &nbsp; &nbsp; =
[nextblk].block_virt_addr;<BR>+=20
  }<BR>+ if (rxdpnext-&gt;Control_2 &amp; BIT(0))<BR>+ goto end;<BR>+=20
  }<BR>+#endif<BR><BR>+#ifndef CONFIG_2BUFF_MODE<BR>skb =3D =
dev_alloc_skb(size +=20
  NET_IP_ALIGN);<BR>+#else<BR>+ skb =3D dev_alloc_skb(dev-&gt;mtu + =
ALIGN_SIZE=20
  +<BR>+ &nbsp; &nbsp; /*BUF0_LEN + */ 22);<BR>+#endif<BR>if (!skb)=20
  {<BR>DBG_PRINT(ERR_DBG, "%s: Out of ", =
dev-&gt;name);<BR>DBG_PRINT(ERR_DBG,=20
  "memory to allocate SKBs\n");<BR>return -ENOMEM;<BR>}<BR>+#ifndef=20
  CONFIG_2BUFF_MODE<BR>skb_reserve(skb, NET_IP_ALIGN);<BR>memset(rxdp, =
0,=20
  sizeof(RxD_t));<BR>rxdp-&gt;Buffer0_ptr =3D pci_map_single<BR>@@ =
-1645,6=20
  +1812,33 @@<BR>off++;<BR>off %=3D (MAX_RXDS_PER_BLOCK +=20
  1);<BR>mac_control-&gt;rx_curr_put_info[ring_no].offset =3D =
off;<BR>+#else<BR>+=20
  ba =3D &amp;nic-&gt;ba[ring_no][block_no][off];<BR>+ tmp =3D (u64)=20
  skb-&gt;data;<BR>+ tmp +=3D ALIGN_SIZE;<BR>+ tmp &amp;=3D =
~ALIGN_SIZE;<BR>+=20
  skb-&gt;data =3D (void *) tmp;<BR>+<BR>+ memset(rxdp, 0, =
sizeof(RxD_t));<BR>+=20
  rxdp-&gt;Buffer2_ptr =3D pci_map_single<BR>+ &nbsp; &nbsp; =
(nic-&gt;pdev,=20
  skb-&gt;data, dev-&gt;mtu + 22,<BR>+ &nbsp; &nbsp;=20
  &nbsp;PCI_DMA_FROMDEVICE);<BR>+ rxdp-&gt;Buffer0_ptr =3D<BR>+ &nbsp; =
&nbsp;=20
  pci_map_single(nic-&gt;pdev, ba-&gt;ba_0, BUF0_LEN,<BR>+ &nbsp;=20
  &nbsp;PCI_DMA_FROMDEVICE);<BR>+ rxdp-&gt;Buffer1_ptr =3D<BR>+ &nbsp; =
&nbsp;=20
  pci_map_single(nic-&gt;pdev, ba-&gt;ba_1, BUF1_LEN,<BR>+ &nbsp;=20
  &nbsp;PCI_DMA_FROMDEVICE);<BR>+<BR>+ rxdp-&gt;Control_2 =3D=20
  SET_BUFFER2_SIZE(dev-&gt;mtu + 22);<BR>+ rxdp-&gt;Control_2 |=3D=20
  SET_BUFFER0_SIZE(BUF0_LEN);<BR>+ rxdp-&gt;Control_2 |=3D =
SET_BUFFER1_SIZE(1); /*=20
  dummy. */<BR>+ rxdp-&gt;Control_2 |=3D BIT(0); /* Set Buffer_Empty =
bit. */<BR>+=20
  rxdp-&gt;Host_Control =3D (u64) ((unsigned long) (skb));<BR>+ =
rxdp-&gt;Control_1=20
  |=3D RXD_OWN_XENA;<BR>+ off++;<BR>+=20
  mac_control-&gt;rx_curr_put_info[ring_no].offset =3D=20
  =
off;<BR>+#endif<BR>atomic_inc(&amp;nic-&gt;rx_bufs_left[ring_no]);<BR>all=
oc_tab++;<BR>}<BR>@@=20
  -1670,6 +1864,9 @@<BR>struct sk_buff *skb;<BR>mac_info_t=20
  *mac_control;<BR>struct config_param *config;<BR>+#ifdef=20
  CONFIG_2BUFF_MODE<BR>+ buffAdd_t *ba;<BR>+#endif<BR><BR>mac_control =
=3D=20
  &amp;sp-&gt;mac_control;<BR>config =3D &amp;sp-&gt;config;<BR>@@ =
-1679,6 +1876,7=20
  @@<BR>off =3D j % (MAX_RXDS_PER_BLOCK + 1);<BR>rxdp =3D=20
  sp-&gt;rx_blocks[i][blk].block_virt_addr + off;<BR><BR>+#ifndef=20
  CONFIG_2BUFF_MODE<BR>if (rxdp-&gt;Control_1 =3D=3D END_OF_BLOCK) =
{<BR>rxdp=20
  =3D<BR>&nbsp; &nbsp; (RxD_t *) ((unsigned long) rxdp-&gt;<BR>@@ =
-1686,6 +1884,12=20
  @@<BR>j++;<BR>blk++;<BR>}<BR>+#else<BR>+ if (rxdp-&gt;Host_Control =
=3D=3D=20
  END_OF_BLOCK) {<BR>+ blk++;<BR>+ continue;<BR>+ }<BR>+#endif<BR><BR>if =

  (!(rxdp-&gt;Control_1 &amp; RXD_OWN_XENA)) {<BR>memset(rxdp, 0,=20
  sizeof(RxD_t));<BR>@@ -1696,6 +1900,7 @@<BR>&nbsp; &nbsp; (struct =
sk_buff *)=20
  ((unsigned long) rxdp-&gt;<BR>Host_Control);<BR>if (skb) {<BR>+#ifndef =

  CONFIG_2BUFF_MODE<BR>pci_unmap_single(sp-&gt;pdev,=20
  (dma_addr_t)<BR>&nbsp;rxdp-&gt;Buffer0_ptr,<BR>&nbsp;dev-&gt;mtu =
+<BR>@@=20
  -1703,6 +1908,21 @@<BR>&nbsp;+ HEADER_802_2_SIZE=20
  =
+<BR>&nbsp;HEADER_SNAP_SIZE,<BR>&nbsp;PCI_DMA_FROMDEVICE);<BR>+#else<BR>+=
 ba =3D=20
  &amp;sp-&gt;ba[i][blk][off];<BR>+ pci_unmap_single(sp-&gt;pdev,=20
  (dma_addr_t)<BR>+ &nbsp;rxdp-&gt;Buffer0_ptr,<BR>+ =
&nbsp;BUF0_LEN,<BR>+=20
  &nbsp;PCI_DMA_FROMDEVICE);<BR>+ pci_unmap_single(sp-&gt;pdev,=20
  (dma_addr_t)<BR>+ &nbsp;rxdp-&gt;Buffer1_ptr,<BR>+ =
&nbsp;BUF1_LEN,<BR>+=20
  &nbsp;PCI_DMA_FROMDEVICE);<BR>+ pci_unmap_single(sp-&gt;pdev,=20
  (dma_addr_t)<BR>+ &nbsp;rxdp-&gt;Buffer2_ptr,<BR>+ &nbsp;dev-&gt;mtu + =

  22,<BR>+=20
  =
&nbsp;PCI_DMA_FROMDEVICE);<BR>+#endif<BR>dev_kfree_skb(skb);<BR>atomic_de=
c(&amp;sp-&gt;rx_bufs_left[i]);<BR>buf_cnt++;<BR>@@=20
  -1741,11 +1961,16 @@<BR>register u64 val64 =3D =
0;<BR>rx_curr_get_info_t=20
  get_info, put_info;<BR>int i, get_block, put_block, get_offset, =
put_offset,=20
  ring_bufs;<BR>+#ifndef CONFIG_2BUFF_MODE<BR>u16 val16,=20
  cksum;<BR>+#endif<BR>struct sk_buff *skb;<BR>RxD_t =
*rxdp;<BR>mac_info_t=20
  *mac_control;<BR>struct config_param *config;<BR>+#ifdef=20
  CONFIG_2BUFF_MODE<BR>+ buffAdd_t *ba;<BR>+#endif<BR><BR>mac_control =
=3D=20
  &amp;nic-&gt;mac_control;<BR>config =3D &amp;nic-&gt;config;<BR>@@ =
-1764,6=20
  +1989,7 @@<BR>ring_bufs =3D config-&gt;rx_cfg[i].num_rxd;<BR>rxdp =3D=20
  nic-&gt;rx_blocks[i][get_block].block_virt_addr +<BR>&nbsp; &nbsp;=20
  get_info.offset;<BR>+#ifndef CONFIG_2BUFF_MODE<BR>get_offset =3D =
(get_block *=20
  (MAX_RXDS_PER_BLOCK + 1)) +<BR>&nbsp; &nbsp; =
get_info.offset;<BR>put_offset =3D=20
  (put_block * (MAX_RXDS_PER_BLOCK + 1)) +<BR>@@ -1820,6 +2046,66=20
  @@<BR>mac_control-&gt;rx_curr_get_info[i].offset =3D<BR>&nbsp; &nbsp;=20
  get_info.offset;<BR>}<BR>+#else<BR>+ get_offset =3D (get_block *=20
  (MAX_RXDS_PER_BLOCK + 1)) +<BR>+ &nbsp; &nbsp; get_info.offset;<BR>+=20
  put_offset =3D (put_block * (MAX_RXDS_PER_BLOCK + 1)) +<BR>+ &nbsp; =
&nbsp;=20
  put_info.offset;<BR>+ while (((!(rxdp-&gt;Control_1 &amp; =
RXD_OWN_XENA))=20
  &amp;&amp;<BR>+ !(rxdp-&gt;Control_2 &amp; BIT(0))) &amp;&amp;<BR>+ =
&nbsp;=20
  &nbsp; &nbsp; &nbsp;(((get_offset + 1) % ring_bufs) !=3D put_offset)) =
{<BR>+ if=20
  (--pkts_to_process &lt; 0) {<BR>+ goto no_rx;<BR>+ }<BR>+ skb =3D =
(struct=20
  sk_buff *) ((unsigned long)<BR>+ &nbsp; rxdp-&gt;Host_Control);<BR>+ =
if (skb=20
  =3D=3D NULL) {<BR>+ DBG_PRINT(ERR_DBG, "%s: The skb is ",<BR>+ &nbsp;=20
  dev-&gt;name);<BR>+ DBG_PRINT(ERR_DBG, "Null in Rx Intr\n");<BR>+ goto =

  no_rx;<BR>+ }<BR>+<BR>+ pci_unmap_single(nic-&gt;pdev, =
(dma_addr_t)<BR>+=20
  &nbsp;rxdp-&gt;Buffer0_ptr,<BR>+ &nbsp;BUF0_LEN, =
PCI_DMA_FROMDEVICE);<BR>+=20
  pci_unmap_single(nic-&gt;pdev, (dma_addr_t)<BR>+=20
  &nbsp;rxdp-&gt;Buffer1_ptr,<BR>+ &nbsp;BUF1_LEN, =
PCI_DMA_FROMDEVICE);<BR>+=20
  pci_unmap_single(nic-&gt;pdev, (dma_addr_t)<BR>+=20
  &nbsp;rxdp-&gt;Buffer2_ptr,<BR>+ &nbsp;dev-&gt;mtu + 22,<BR>+=20
  &nbsp;PCI_DMA_FROMDEVICE);<BR>+ ba =3D=20
  &amp;nic-&gt;ba[i][get_block][get_info.offset];<BR>+<BR>+ =
rx_osm_handler(nic,=20
  rxdp, i, ba);<BR>+<BR>+ get_info.offset++;<BR>+=20
  mac_control-&gt;rx_curr_get_info[i].offset =3D<BR>+ &nbsp; &nbsp;=20
  get_info.offset;<BR>+ rxdp =3D<BR>+ &nbsp; &nbsp;=20
  nic-&gt;rx_blocks[i][get_block].block_virt_addr +<BR>+ &nbsp; &nbsp;=20
  get_info.offset;<BR>+<BR>+ if (get_info.offset &amp;&amp;<BR>+ &nbsp; =
&nbsp;=20
  (!(get_info.offset % MAX_RXDS_PER_BLOCK))) {<BR>+ get_info.offset =3D =
0;<BR>+=20
  mac_control-&gt;rx_curr_get_info[i].<BR>+ &nbsp; &nbsp; offset =3D=20
  get_info.offset;<BR>+ get_block++;<BR>+ get_block %=3D=20
  nic-&gt;block_count[i];<BR>+ mac_control-&gt;rx_curr_get_info[i].<BR>+ =
&nbsp;=20
  &nbsp; block_index =3D get_block;<BR>+ rxdp =3D<BR>+ &nbsp; &nbsp;=20
  nic-&gt;rx_blocks[i][get_block].<BR>+ &nbsp; &nbsp; =
block_virt_addr;<BR>+=20
  }<BR>+ get_offset =3D<BR>+ &nbsp; &nbsp; (get_block * =
(MAX_RXDS_PER_BLOCK + 1))=20
  +<BR>+ &nbsp; &nbsp; get_info.offset;<BR>+ pkt_cnt++;<BR>+=20
  }<BR>+#endif<BR>}<BR>if (!pkt_cnt)<BR>pkt_cnt =3D 1;<BR>@@ -1873,12 =
+2159,17=20
  @@<BR>rx_curr_get_info_t get_info, put_info;<BR>RxD_t *rxdp;<BR>struct =
sk_buff=20
  *skb;<BR>+#ifndef CONFIG_2BUFF_MODE<BR>u16 val16,=20
  cksum;<BR>+#endif<BR>register u64 val64 =3D 0;<BR>int get_block, =
get_offset,=20
  put_block, put_offset, ring_bufs;<BR>int i, pkt_cnt =3D =
0;<BR>mac_info_t=20
  *mac_control;<BR>struct config_param *config;<BR>+#ifdef=20
  CONFIG_2BUFF_MODE<BR>+ buffAdd_t *ba;<BR>+#endif<BR><BR>mac_control =
=3D=20
  &amp;nic-&gt;mac_control;<BR>config =3D &amp;nic-&gt;config;<BR>@@ =
-1898,6=20
  +2189,7 @@<BR>ring_bufs =3D config-&gt;rx_cfg[i].num_rxd;<BR>rxdp =3D=20
  nic-&gt;rx_blocks[i][get_block].block_virt_addr +<BR>&nbsp; &nbsp;=20
  get_info.offset;<BR>+#ifndef CONFIG_2BUFF_MODE<BR>get_offset =3D =
(get_block *=20
  (MAX_RXDS_PER_BLOCK + 1)) +<BR>&nbsp; &nbsp;=20
  get_info.offset;<BR>spin_lock(&amp;nic-&gt;put_lock);<BR>@@ -1953,6 =
+2245,67=20
  @@<BR>&nbsp; &nbsp; &amp;&amp; (pkt_cnt &gt;=20
  indicate_max_pkts))<BR>break;<BR>}<BR>+#else<BR>+ get_offset =3D =
(get_block *=20
  (MAX_RXDS_PER_BLOCK + 1)) +<BR>+ &nbsp; &nbsp; get_info.offset;<BR>+=20
  spin_lock(&amp;nic-&gt;put_lock);<BR>+ put_offset =3D =
nic-&gt;put_pos[i];<BR>+=20
  spin_unlock(&amp;nic-&gt;put_lock);<BR>+ while (((!(rxdp-&gt;Control_1 =
&amp;=20
  RXD_OWN_XENA)) &amp;&amp;<BR>+ !(rxdp-&gt;Control_2 &amp; BIT(0)))=20
  &amp;&amp;<BR>+ &nbsp; &nbsp; &nbsp; &nbsp;(((get_offset + 1) % =
ring_bufs) !=3D=20
  put_offset)) {<BR>+ skb =3D (struct sk_buff *) ((unsigned long)<BR>+ =
&nbsp;=20
  rxdp-&gt;Host_Control);<BR>+ if (skb =3D=3D NULL) {<BR>+ =
DBG_PRINT(ERR_DBG, "%s:=20
  The skb is ",<BR>+ &nbsp; dev-&gt;name);<BR>+ DBG_PRINT(ERR_DBG, "Null =
in Rx=20
  Intr\n");<BR>+ return;<BR>+ }<BR>+<BR>+ pci_unmap_single(nic-&gt;pdev, =

  (dma_addr_t)<BR>+ &nbsp;rxdp-&gt;Buffer0_ptr,<BR>+ &nbsp;BUF0_LEN,=20
  PCI_DMA_FROMDEVICE);<BR>+ pci_unmap_single(nic-&gt;pdev, =
(dma_addr_t)<BR>+=20
  &nbsp;rxdp-&gt;Buffer1_ptr,<BR>+ &nbsp;BUF1_LEN, =
PCI_DMA_FROMDEVICE);<BR>+=20
  pci_unmap_single(nic-&gt;pdev, (dma_addr_t)<BR>+=20
  &nbsp;rxdp-&gt;Buffer2_ptr,<BR>+ &nbsp;dev-&gt;mtu + 22,<BR>+=20
  &nbsp;PCI_DMA_FROMDEVICE);<BR>+ ba =3D=20
  &amp;nic-&gt;ba[i][get_block][get_info.offset];<BR>+<BR>+ =
rx_osm_handler(nic,=20
  rxdp, i, ba);<BR>+<BR>+ get_info.offset++;<BR>+=20
  mac_control-&gt;rx_curr_get_info[i].offset =3D<BR>+ &nbsp; &nbsp;=20
  get_info.offset;<BR>+ rxdp =3D<BR>+ &nbsp; &nbsp;=20
  nic-&gt;rx_blocks[i][get_block].block_virt_addr +<BR>+ &nbsp; &nbsp;=20
  get_info.offset;<BR>+<BR>+ if (get_info.offset &amp;&amp;<BR>+ &nbsp; =
&nbsp;=20
  (!(get_info.offset % MAX_RXDS_PER_BLOCK))) {<BR>+ get_info.offset =3D =
0;<BR>+=20
  mac_control-&gt;rx_curr_get_info[i].<BR>+ &nbsp; &nbsp; offset =3D=20
  get_info.offset;<BR>+ get_block++;<BR>+ get_block %=3D=20
  nic-&gt;block_count[i];<BR>+ mac_control-&gt;rx_curr_get_info[i].<BR>+ =
&nbsp;=20
  &nbsp; block_index =3D get_block;<BR>+ rxdp =3D<BR>+ &nbsp; &nbsp;=20
  nic-&gt;rx_blocks[i][get_block].<BR>+ &nbsp; &nbsp; =
block_virt_addr;<BR>+=20
  }<BR>+ get_offset =3D<BR>+ &nbsp; &nbsp; (get_block * =
(MAX_RXDS_PER_BLOCK + 1))=20
  +<BR>+ &nbsp; &nbsp; get_info.offset;<BR>+ pkt_cnt++;<BR>+ if=20
  ((indicate_max_pkts)<BR>+ &nbsp; &nbsp; &amp;&amp; (pkt_cnt &gt;=20
  indicate_max_pkts))<BR>+ break;<BR>+ }<BR>+#endif<BR>if =
((indicate_max_pkts)=20
  &amp;&amp; (pkt_cnt &gt; indicate_max_pkts))<BR>break;<BR>}<BR>@@ =
-4096,12=20
  +4449,21 @@</TT><BR><TT>&nbsp;* &nbsp; Return value:<BR>&nbsp;* &nbsp; =
SUCCESS=20
  on success and -1 on failure.<BR>&nbsp;*/<BR>+#ifndef=20
  CONFIG_2BUFF_MODE<BR>static int rx_osm_handler(nic_t * sp, u16 len, =
RxD_t *=20
  rxdp, int ring_no)<BR>+#else<BR>+static int rx_osm_handler(nic_t * sp, =
RxD_t *=20
  rxdp, int ring_no,<BR>+ &nbsp; buffAdd_t * =
ba)<BR>+#endif<BR>{<BR>struct=20
  net_device *dev =3D (struct net_device *) sp-&gt;dev;<BR>struct =
sk_buff *skb=20
  =3D<BR>&nbsp; &nbsp; (struct sk_buff *) ((unsigned long)=20
  rxdp-&gt;Host_Control);<BR>u16 l3_csum, l4_csum;<BR>+#ifdef=20
  CONFIG_2BUFF_MODE<BR>+ int buf0_len, buf2_len;<BR>+ struct ethhdr *eth =
=3D=20
  (struct ethhdr *) ba-&gt;ba_0;<BR>+#endif<BR><BR>l3_csum =3D=20
  RXD_GET_L3_CKSUM(rxdp-&gt;Control_1);<BR>if ((rxdp-&gt;Control_1 &amp; =

  TCP_OR_UDP_FRAME) &amp;&amp; (sp-&gt;rx_csum)) {<BR>@@ -4129,10 =
+4491,32=20
  @@<BR>DBG_PRINT(ERR_DBG, "%s: Rx error Value: 0x%llx\n",<BR>&nbsp;=20
  dev-&gt;name, err);<BR>}<BR>+#ifdef CONFIG_2BUFF_MODE<BR>+ buf0_len =
=3D=20
  RXD_GET_BUFFER0_SIZE(rxdp-&gt;Control_2);<BR>+ buf2_len =3D=20
  =
RXD_GET_BUFFER2_SIZE(rxdp-&gt;Control_2);<BR>+#endif<BR><BR>skb-&gt;dev =
=3D=20
  dev;<BR>+#ifndef CONFIG_2BUFF_MODE<BR>skb_put(skb, =
len);<BR>skb-&gt;protocol =3D=20
  eth_type_trans(skb, dev);<BR>+#else<BR>+ skb_put(skb, buf2_len);<BR>+ =
/* <BR>+=20
  &nbsp;* Reproducing eth_type_trans functionality and running<BR>+ =
&nbsp;* on=20
  the ethernet header 'eth' stripped and given to us<BR>+ &nbsp;* by the =

  hardware in 2Buff mode.<BR>+ &nbsp;*/<BR>+ if (*eth-&gt;h_dest &amp; =
1) {<BR>+=20
  if (!memcmp(eth-&gt;h_dest, dev-&gt;broadcast, ETH_ALEN))<BR>+=20
  skb-&gt;pkt_type =3D PACKET_BROADCAST;<BR>+ else<BR>+ skb-&gt;pkt_type =
=3D=20
  PACKET_MULTICAST;<BR>+ } else if (memcmp(eth-&gt;h_dest, =
dev-&gt;dev_addr,=20
  ETH_ALEN)) {<BR>+ skb-&gt;pkt_type =3D PACKET_OTHERHOST;<BR>+ }<BR>+=20
  skb-&gt;protocol =3D eth-&gt;h_proto;<BR>+#endif<BR><BR>#ifdef=20
  CONFIG_S2IO_NAPI<BR>netif_receive_skb(skb);<BR>@@ -4143,7 +4527,11=20
  @@<BR>dev-&gt;last_rx =3D=20
  =
jiffies;<BR>sp-&gt;rx_pkt_count++;<BR>sp-&gt;stats.rx_packets++;<BR>+#ifn=
def=20
  CONFIG_2BUFF_MODE<BR>sp-&gt;stats.rx_bytes +=3D len;<BR>+#else<BR>+=20
  sp-&gt;stats.rx_bytes +=3D buf0_len +=20
  =
buf2_len;<BR>+#endif<BR><BR>atomic_dec(&amp;sp-&gt;rx_bufs_left[ring_no])=
;<BR>rxdp-&gt;Host_Control=20
  =3D 0;<BR>diff -urN vanilla-linux/drivers/net/s2io.h=20
  linux-2.6.8.1/drivers/net/s2io.h<BR>--- =
vanilla-linux/drivers/net/s2io.h=20
  2004-10-11 21:21:49.000000000 -0700<BR>+++ =
linux-2.6.8.1/drivers/net/s2io.h=20
  2004-10-11 21:22:23.000000000 -0700<BR>@@ -466,19 +466,46 =
@@<BR>#define=20
  RXD_GET_L4_CKSUM(val) &nbsp; ((u16)(val) &amp; 0xFFFF)<BR><BR>u64=20
  Control_2;<BR>+#ifndef CONFIG_2BUFF_MODE<BR>#define MASK_BUFFER0_SIZE =
&nbsp;=20
  &nbsp; &nbsp; vBIT(0xFFFF,0,16)<BR>#define SET_BUFFER0_SIZE(val) =
&nbsp;=20
  vBIT(val,0,16)<BR>+#else<BR>+#define MASK_BUFFER0_SIZE &nbsp; &nbsp; =
&nbsp;=20
  vBIT(0xFF,0,16)<BR>+#define MASK_BUFFER1_SIZE &nbsp; &nbsp; &nbsp;=20
  vBIT(0xFFFF,16,16)<BR>+#define MASK_BUFFER2_SIZE &nbsp; &nbsp; &nbsp;=20
  vBIT(0xFFFF,32,16)<BR>+#define SET_BUFFER0_SIZE(val) &nbsp;=20
  vBIT(val,8,8)<BR>+#define SET_BUFFER1_SIZE(val) &nbsp;=20
  vBIT(val,16,16)<BR>+#define SET_BUFFER2_SIZE(val) &nbsp;=20
  vBIT(val,32,16)<BR>+#endif<BR>+<BR>#define MASK_VLAN_TAG &nbsp; &nbsp; =
&nbsp;=20
  &nbsp; &nbsp; vBIT(0xFFFF,48,16)<BR>#define SET_VLAN_TAG(val) &nbsp; =
&nbsp;=20
  &nbsp; vBIT(val,48,16)<BR>#define SET_NUM_TAG(val) &nbsp; &nbsp; =
&nbsp;=20
  vBIT(val,16,32)<BR><BR>+#ifndef CONFIG_2BUFF_MODE<BR>#define=20
  RXD_GET_BUFFER0_SIZE(Control_2) (u64)((Control_2 &amp;=20
  vBIT(0xFFFF,0,16)))<BR>+#else<BR>+#define =
RXD_GET_BUFFER0_SIZE(Control_2)=20
  (u8)((Control_2 &amp; MASK_BUFFER0_SIZE) \<BR>+ &gt;&gt; =
48)<BR>+#define=20
  RXD_GET_BUFFER1_SIZE(Control_2) (u16)((Control_2 &amp; =
MASK_BUFFER1_SIZE)=20
  \<BR>+ &gt;&gt; 32)<BR>+#define RXD_GET_BUFFER2_SIZE(Control_2)=20
  (u16)((Control_2 &amp; MASK_BUFFER2_SIZE) \<BR>+ &gt;&gt; =
16)<BR>+#define=20
  BUF0_LEN 40<BR>+#define BUF1_LEN 1<BR>+#endif<BR>+<BR>u64=20
  Buffer0_ptr;<BR>+#ifdef CONFIG_2BUFF_MODE<BR>+ u64 Buffer1_ptr;<BR>+ =
u64=20
  Buffer2_ptr;<BR>+#endif<BR>} RxD_t;<BR><BR>/* Structure that =
represents the Rx=20
  descriptor block which contains <BR>&nbsp;* 128 Rx=20
  descriptors.<BR>&nbsp;*/<BR>+#ifndef CONFIG_2BUFF_MODE<BR>typedef =
struct=20
  _RxD_block {<BR>#define MAX_RXDS_PER_BLOCK &nbsp; &nbsp; &nbsp; &nbsp; =
&nbsp;=20
  &nbsp; 127<BR>RxD_t rxd[MAX_RXDS_PER_BLOCK];<BR>@@ -492,6 +519,27=20
  @@<BR>&nbsp;* the upper 32 bits should <BR>&nbsp;* be 0 */<BR>}=20
  RxD_block_t;<BR>+#else<BR>+typedef struct _RxD_block {<BR>+#define=20
  MAX_RXDS_PER_BLOCK &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; 85<BR>+ =
RxD_t=20
  rxd[MAX_RXDS_PER_BLOCK];<BR>+<BR>+#define END_OF_BLOCK &nbsp;=20
  &nbsp;0xFEFFFFFFFFFFFFFFULL<BR>+ u64 reserved_1; /* 0xFEFFFFFFFFFFFFFF =
to mark=20
  last Rxd <BR>+ &nbsp;* in this blk */<BR>+ u64 pNext_RxD_Blk_physical; =
/* Phy=20
  ponter to next blk. */<BR>+} RxD_block_t;<BR>+#define SIZE_OF_BLOCK=20
  4096<BR>+<BR>+/* Structure to hold virtual addresses of Buf0 and Buf1 =
in <BR>+=20
  * 2buf mode. */<BR>+typedef struct bufAdd {<BR>+ void *ba_0_org;<BR>+ =
void=20
  *ba_1_org;<BR>+ void *ba_0;<BR>+ void *ba_1;<BR>+}=20
  buffAdd_t;<BR>+#endif<BR><BR>/* Structure which stores all the MAC =
control=20
  parameters */<BR><BR>@@ -677,6 +725,10 @@<BR>#define LINK_DOWN =
1<BR>#define=20
  LINK_UP 2<BR><BR>+#ifdef CONFIG_2BUFF_MODE<BR>+ /* Buffer Address =
store.=20
  */<BR>+ buffAdd_t **ba[MAX_RX_RINGS];<BR>+#endif<BR>int =
task_flag;<BR>}=20
  nic_t;<BR><BR>@@ -802,7 +854,12 @@<BR>static void =
s2io_tx_watchdog(struct=20
  net_device *dev);<BR>static void s2io_tasklet(unsigned long=20
  dev_addr);<BR>static void s2io_set_multicast(struct net_device=20
  *dev);<BR>+#ifndef CONFIG_2BUFF_MODE<BR>static int =
rx_osm_handler(nic_t * sp,=20
  u16 len, RxD_t * rxdp, int ring_no);<BR>+#else<BR>+static int=20
  rx_osm_handler(nic_t * sp, RxD_t * rxdp, int ring_no,<BR>+ &nbsp; =
buffAdd_t *=20
  ba);<BR>+#endif<BR>void s2io_link(nic_t * sp, int link);<BR>void=20
  s2io_reset(nic_t * sp);<BR>#ifdef=20
CONFIG_S2IO_NAPI<BR><BR></TT><BR></P></BLOCKQUOTE></BODY></HTML>

------=_NextPart_001_001B_01C4C649.C6348720--

------=_NextPart_000_001A_01C4C649.C6321620
Content-Type: image/gif;
	name="graycol.gif"
Content-Transfer-Encoding: base64
Content-ID: <343562918@09112004-2616>

R0lGODlhEAAQAKECAMzMzAAAAP///wAAACH5BAEAAAIALAAAAAAQABAAAAIXlI+py+0PopwxUbpu
ZRfKZ2zgSJbmSRYAIf4fT3B0aW1pemVkIGJ5IFVsZWFkIFNtYXJ0U2F2ZXIhAAA7

------=_NextPart_000_001A_01C4C649.C6321620
Content-Type: image/gif;
	name="ecblank.gif"
Content-Transfer-Encoding: base64
Content-ID: <343562918@09112004-261D>

R0lGODlhEAABAIAAAAAAAP///yH5BAEAAAEALAAAAAAQAAEAAAIEjI8ZBQA7

------=_NextPart_000_001A_01C4C649.C6321620--
