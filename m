From: Krishna Kumar <kumarkr@us.ibm.com>
Subject: Re: [PATCH 2.6.9-rc2 8/12] S2io: two buffer mode
Date: Mon, 8 Nov 2004 16:41:01 -0800
Message-ID: <OF3217E79B.191DEEB3-ON88256F47.0002DD18-88256F47.0003C162@us.ibm.com>
References: <20041108161634.D459A3291A@linux.site>
Mime-Version: 1.0
Content-Type: multipart/related;
	Boundary="0__=07BBE5D4DF915B888f9e8a93df938690918c07BBE5D4DF915B88"
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, raghavendra.koushik@s2io.com,
        ravinandan.arakali@s2io.com, romieu@fr.zoreil.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20041108161634.D459A3291A@linux.site>
To: raghavendra.koushik@s2io.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=07BBE5D4DF915B888f9e8a93df938690918c07BBE5D4DF915B88
Content-type: multipart/alternative;
	Boundary="1__=07BBE5D4DF915B888f9e8a93df938690918c07BBE5D4DF915B88"

--1__=07BBE5D4DF915B888f9e8a93df938690918c07BBE5D4DF915B88
Content-type: text/plain; charset=US-ASCII
Content-transfer-encoding: quoted-printable






Sorry if my mailer mangles the mail, but ...

This code looks like it can cause an oops on failure to alloc cases. I
havent read the code very much other than the
init and the free routines.

+#ifdef CONFIG_2BUFF_MODE
+            /* Freeing buffer storage addresses in 2BUFF mode. */
+            for (i =3D 0; i < config->rx_ring_num; i++) {
+                        blk_cnt =3D
+                            config->rx_cfg[i].num_rxd /
(MAX_RXDS_PER_BLOCK + 1);
+                        for (j =3D 0; j < blk_cnt; j++) {
+                                    int k =3D 0;
+                                    if (!nic->ba[i][j])
+                                                continue;
+                                    while (k !=3D MAX_RXDS_PER_BLOCK) =
{
+                                                buffAdd_t *ba =3D
&nic->ba[i][j][k];
+                                                kfree(ba->ba_0_org);
+                                                kfree(ba->ba_1_org);
+                                                k++;
+                                    }
+                                    kfree(nic->ba[i][j]);
+                        }
+                        if (nic->ba[i])
+                                    kfree(nic->ba[i]);
+            }
+#endif

Shouldn't this be something like (check ba[i] at the top to avoid MMU) =
:

+#ifdef CONFIG_2BUFF_MODE
+            /* Freeing buffer storage addresses in 2BUFF mode. */
+            for (i =3D 0; i < config->rx_ring_num; i++) {
+                        if (!nic->ba[i]) /* if there are no holes, we =
are
done */
+                             break;
+                        blk_cnt =3D
+                            config->rx_cfg[i].num_rxd /
(MAX_RXDS_PER_BLOCK + 1);
+                        for (j =3D 0; j < blk_cnt; j++) {
+                                    int k =3D 0;
+                                    if (!nic->ba[i][j])
+                                                continue;
>> Should this be a break ? Can you have holes in the middle ?
+                                    while (k !=3D MAX_RXDS_PER_BLOCK) =
{
+                                                buffAdd_t *ba =3D
&nic->ba[i][j][k];
+                                                kfree(ba->ba_0_org);
+                                                kfree(ba->ba_1_org);
>> Actually if no holes are allowed, you can break out if the above
pointers become
>> NULL instead of iterating MAX_RXDS_PER_BLOCK (127) times.
+                                                k++;
+                                    }
+                                    kfree(nic->ba[i][j]);
+                        }
+                        kfree(nic->ba[i]);
+            }
+#endif

thx,

- KK



                                                                       =
    
             raghavendra.koush                                         =
    
             ik@s2io.com                                               =
    
             Sent by:                                                  =
 To 
             netdev-bounce@oss         jgarzik@pobox.com,              =
    
             .sgi.com                  romieu@fr.zoreil.com,           =
    
                                       netdev@oss.sgi.com              =
    
                                                                       =
 cc 
             11/08/2004 08:16          ravinandan.arakali@s2io.com,    =
    
             AM                        raghavendra.koushik@s2io.com    =
    
                                                                   Subj=
ect 
                                       [PATCH 2.6.9-rc2 8/12] S2io: two=
    
                                       buffer mode                     =
    
                                                                       =
    
                                                                       =
    
                                                                       =
    
                                                                       =
    
                                                                       =
    
                                                                       =
    




Hi,
Attached is the patch for implementing 2-buffer mode on Rx path.
More description of this mode of operation follows.

On certain systems when a DMA has to happen on an un-aligned memory
location performance will take a significant hit. It's standard
practice to offset the Rx buffer address by 2 (as Mac header is 14 byte=
s)
so the IP header starts from an aligned location.
Obviously using a single Rx buffer both cannot be achieved. Thus XFrame=

supports something called 2 buffer Rx mode, where in the
Rx'ed frame is split into 2 parts, one is the Ethernet header and the o=
ther
is the Ethernet payload. So now we can allocate proper
aligned memory for both buffers, hence the DMA is not slowed down. Also=
,
the Ethernet payload(starting from L3 header) is on an
aligned location so OS need not have to do un-aligned accesses to proce=
ss
IP header. To achieve this, the kernel function
eth_type_trans functionality has to be partially implemented in the dri=
ver
itself.

Signed-off-by: Raghavendra Koushik <raghavendra.koushik@s2io.com>
Signed-off-by: Ravinandan Arakali <ravinandan.arakali@s2io.com>
---
diff -urN vanilla-linux/drivers/net/Kconfig linux-2.6.8.1
/drivers/net/Kconfig
--- vanilla-linux/drivers/net/Kconfig            2004-10-06
15:15:04.000000000 -0700
+++ linux-2.6.8.1/drivers/net/Kconfig            2004-10-11
20:06:36.000000000 -0700
@@ -2267,6 +2267,17 @@

               If in doubt, say N.

+config 2BUFF_MODE
+            bool "Use 2 Buffer Mode on Rx side."
+            depends on S2IO
+            ---help---
+            On enabling the 2 buffer mode, the received frame will be
+            split into 2 parts before being DMA'ed to the hosts memory=
.
+            The parts are the ethernet header and ethernet payload.
+            This is useful on systems where DMA'ing to to unaligned
+            physical memory loactions comes with a heavy price.
+            If not sure please say N.
+
 endmenu

 source "drivers/net/tokenring/Kconfig"
diff -urN vanilla-linux/drivers/net/s2io.c linux-2.6.8.1/drivers/net/s2=
io.c
--- vanilla-linux/drivers/net/s2io.c             2004-10-11
21:21:49.000000000 -0700
+++ linux-2.6.8.1/drivers/net/s2io.c             2004-10-12
16:49:27.796331624 -0700
@@ -325,6 +325,10 @@
             int i, j, blk_cnt;
             int lst_size, lst_per_page;
             struct net_device *dev =3D nic->dev;
+#ifdef CONFIG_2BUFF_MODE
+            u64 tmp;
+            buffAdd_t *ba;
+#endif

             mac_info_t *mac_control;
             struct config_param *config;
@@ -425,7 +429,11 @@
                             config->rx_cfg[i].num_rxd /
(MAX_RXDS_PER_BLOCK + 1);
                         /*  Allocating all the Rx blocks */
                         for (j =3D 0; j < blk_cnt; j++) {
+#ifndef CONFIG_2BUFF_MODE
                                     size =3D (MAX_RXDS_PER_BLOCK + 1) =
*
(sizeof(RxD_t));
+#else
+                                    size =3D SIZE_OF_BLOCK;
+#endif
                                     tmp_v_addr =3D
pci_alloc_consistent(nic->pdev, size,

         &tmp_p_addr);
                                     if (tmp_v_addr =3D=3D NULL) {
@@ -458,13 +466,60 @@
                                     pre_rxd_blk->reserved_1 =3D
END_OF_BLOCK;            /* last RxD

                    * marker.

                    */
+#ifndef           CONFIG_2BUFF_MODE

pre_rxd_blk->reserved_2_pNext_RxD_block =3D
                                         (unsigned long) tmp_v_addr_nex=
t;
+#endif
                                     pre_rxd_blk->pNext_RxD_Blk_physica=
l =3D
                                         (u64) tmp_p_addr_next;
                         }
             }

+#ifdef CONFIG_2BUFF_MODE
+            /*
+             * Allocation of Storages for buffer addresses in 2BUFF mo=
de
+             * and the buffers as well.
+             */
+            for (i =3D 0; i < config->rx_ring_num; i++) {
+                        blk_cnt =3D
+                            config->rx_cfg[i].num_rxd /
(MAX_RXDS_PER_BLOCK + 1);
+                        nic->ba[i] =3D kmalloc((sizeof(buffAdd_t *) *
blk_cnt),
+                                                     GFP_KERNEL);
+                        if (!nic->ba[i])
+                                    return -ENOMEM;
+                        for (j =3D 0; j < blk_cnt; j++) {
+                                    int k =3D 0;
+                                    nic->ba[i][j] =3D
kmalloc((sizeof(buffAdd_t) *
+
(MAX_RXDS_PER_BLOCK + 1)),
+
GFP_KERNEL);
+                                    if (!nic->ba[i][j])
+                                                return -ENOMEM;
+                                    while (k !=3D MAX_RXDS_PER_BLOCK) =
{
+                                                ba =3D &nic->ba[i][j][=
k];
+
+                                                ba->ba_0_org =3D (void=
 *)
kmalloc
+                                                    (BUF0_LEN +
ALIGN_SIZE, GFP_ATOMIC);
+                                                if (!ba->ba_0_org)
+                                                            return
-ENOMEM;
+                                                tmp =3D (u64) ba->ba_0=
_org;
+                                                tmp +=3D ALIGN_SIZE;
+                                                tmp &=3D ~((u64)
ALIGN_SIZE);
+                                                ba->ba_0 =3D (void *) =
tmp;
+
+                                                ba->ba_1_org =3D (void=
 *)
kmalloc
+                                                    (BUF1_LEN +
ALIGN_SIZE, GFP_ATOMIC);
+                                                if (!ba->ba_1_org)
+                                                            return
-ENOMEM;
+                                                tmp =3D (u64) ba->ba_1=
_org;
+                                                tmp +=3D ALIGN_SIZE;
+                                                tmp &=3D ~((u64)
ALIGN_SIZE);
+                                                ba->ba_1 =3D (void *) =
tmp;
+                                                k++;
+                                    }
+                        }
+            }
+#endif
+
             /* Allocation and initialization of Statistics block */
             size =3D sizeof(StatInfo_t);
             mac_control->stats_mem =3D pci_alloc_consistent
@@ -532,7 +587,11 @@
                         kfree(nic->list_info[i]);
             }

+#ifndef CONFIG_2BUFF_MODE
             size =3D (MAX_RXDS_PER_BLOCK + 1) * (sizeof(RxD_t));
+#else
+            size =3D SIZE_OF_BLOCK;
+#endif
             for (i =3D 0; i < config->rx_ring_num; i++) {
                         blk_cnt =3D nic->block_count[i];
                         for (j =3D 0; j < blk_cnt; j++) {
@@ -545,6 +604,27 @@
                         }
             }

+#ifdef CONFIG_2BUFF_MODE
+            /* Freeing buffer storage addresses in 2BUFF mode. */
+            for (i =3D 0; i < config->rx_ring_num; i++) {
+                        blk_cnt =3D
+                            config->rx_cfg[i].num_rxd /
(MAX_RXDS_PER_BLOCK + 1);
+                        for (j =3D 0; j < blk_cnt; j++) {
+                                    int k =3D 0;
+                                    if (!nic->ba[i][j])
+                                                continue;
+                                    while (k !=3D MAX_RXDS_PER_BLOCK) =
{
+                                                buffAdd_t *ba =3D
&nic->ba[i][j][k];
+                                                kfree(ba->ba_0_org);
+                                                kfree(ba->ba_1_org);
+                                                k++;
+                                    }
+                                    kfree(nic->ba[i][j]);
+                        }
+                        if (nic->ba[i])
+                                    kfree(nic->ba[i]);
+            }
+#endif

             if (mac_control->stats_mem) {
                         pci_free_consistent(nic->pdev,
@@ -1366,10 +1446,21 @@
                                &bar0->prc_rxd0_n[i]);

                         val64 =3D readq(&bar0->prc_ctrl_n[i]);
+#ifndef CONFIG_2BUFF_MODE
                         val64 |=3D PRC_CTRL_RC_ENABLED;
+#else
+                        val64 |=3D PRC_CTRL_RC_ENABLED |
PRC_CTRL_RING_MODE_3;
+#endif
                         writeq(val64, &bar0->prc_ctrl_n[i]);
             }

+#ifdef CONFIG_2BUFF_MODE
+            /* Enabling 2 buffer mode by writing into Rx_pa_cfg reg. *=
/
+            val64 =3D readq(&bar0->rx_pa_cfg);
+            val64 |=3D RX_PA_CFG_IGNORE_L2_ERR;
+            writeq(val64, &bar0->rx_pa_cfg);
+#endif
+
             /*
              * Enabling MC-RLDRAM. After enabling the device, we timeo=
ut
              * for around 100ms, which is approximately the time requi=
red
@@ -1437,6 +1528,12 @@
             }

             /*
+             * Don't see link state interrupts on certain switches, so=

+             * directly scheduling a link state task from here.
+             */
+            schedule_work(&nic->set_link_task);
+
+            /*
              * Here we are performing soft reset on XGXS to
              * force link down. Since link is already up, we will get
              * link state change interrupt after this reset
@@ -1565,6 +1662,13 @@
                 atomic_read(&nic->rx_bufs_left[ring_no]);
             mac_info_t *mac_control;
             struct config_param *config;
+#ifdef CONFIG_2BUFF_MODE
+            RxD_t *rxdpnext;
+            int nextblk;
+            u64 tmp;
+            buffAdd_t *ba;
+            dma_addr_t rxdpphys;
+#endif
 #ifndef CONFIG_S2IO_NAPI
             unsigned long flags;
 #endif
@@ -1589,10 +1693,14 @@
                             block_index;
                         off =3D
mac_control->rx_curr_put_info[ring_no].offset;
                         off1 =3D
mac_control->rx_curr_get_info[ring_no].offset;
+#ifndef CONFIG_2BUFF_MODE
                         offset =3D block_no * (MAX_RXDS_PER_BLOCK + 1)=
 +
off;
                         offset1 =3D block_no1 * (MAX_RXDS_PER_BLOCK + =
1) +
off1;
+#else
                         offset =3D block_no * (MAX_RXDS_PER_BLOCK) + o=
ff;
                         offset1 =3D block_no1 * (MAX_RXDS_PER_BLOCK) +=
 off1;
+#endif
+
                         rxdp =3D nic->rx_blocks[ring_no][block_no].
                             block_virt_addr + off;
                         if ((offset =3D=3D offset1) && (rxdp->Host_Con=
trol)) {
@@ -1600,6 +1708,7 @@
                                     DBG_PRINT(INTR_DBG, " info
equated\n");
                                     goto end;
                         }
+#ifndef           CONFIG_2BUFF_MODE
                         if (rxdp->Control_1 =3D=3D END_OF_BLOCK) {

mac_control->rx_curr_put_info[ring_no].
                                         block_index++;
@@ -1617,23 +1726,81 @@
                         }
 #ifndef CONFIG_S2IO_NAPI
                         spin_lock_irqsave(&nic->put_lock, flags);
+                        nic->put_pos[ring_no] =3D
+                            (block_no * (MAX_RXDS_PER_BLOCK + 1)) + of=
f;
+                        spin_unlock_irqrestore(&nic->put_lock, flags);=

+#endif
+#else
+                        if (rxdp->Host_Control =3D=3D END_OF_BLOCK) {
+
mac_control->rx_curr_put_info[ring_no].
+                                        block_index++;
+
mac_control->rx_curr_put_info[ring_no].
+                                        block_index %=3D
nic->block_count[ring_no];
+                                    block_no =3D
mac_control->rx_curr_put_info
+                                        [ring_no].block_index;
+                                    off =3D 0;
+                                    DBG_PRINT(INTR_DBG, "%s: block%d a=
t:
0x%llx\n",
+                                                  dev->name, block_no,=

+                                                  (unsigned long long)=

rxdp->Control_1);
+
mac_control->rx_curr_put_info[ring_no].offset =3D
+                                        off;
+                                    rxdp =3D
nic->rx_blocks[ring_no][block_no].
+                                        block_virt_addr;
+                        }
+#ifndef CONFIG_S2IO_NAPI
+                        spin_lock_irqsave(&nic->put_lock, flags);
                         nic->put_pos[ring_no] =3D (block_no *

(MAX_RXDS_PER_BLOCK + 1)) + off;
                         spin_unlock_irqrestore(&nic->put_lock, flags);=

 #endif
+#endif

-                        if (rxdp->Control_1 & RXD_OWN_XENA) {
+#ifndef           CONFIG_2BUFF_MODE
+                        if (rxdp->Control_1 & RXD_OWN_XENA)
+#else
+                        if (rxdp->Control_2 & BIT(0))
+#endif
+                        {

mac_control->rx_curr_put_info[ring_no].
                                         offset =3D off;
                                     goto end;
                         }
+#ifdef            CONFIG_2BUFF_MODE
+                        /*
+                         * RxDs Spanning cache lines will be replenish=
ed
only
+                         * if the succeeding RxD is also owned by Host=
. It

+                         * will always be the ((8*i)+3) and ((8*i)+6)
+                         * descriptors for the 48 byte descriptor. The=

offending
+                         * decsriptor is of-course the 3rd descriptor.=

+                         */
+                        rxdpphys =3D nic->rx_blocks[ring_no][block_no]=
.
+                            block_dma_addr + (off * sizeof(RxD_t));
+                        if (((u64) (rxdpphys)) % 128 > 80) {
+                                    rxdpnext =3D
nic->rx_blocks[ring_no][block_no].
+                                        block_virt_addr + (off + 1);
+                                    if (rxdpnext->Host_Control =3D=3D
END_OF_BLOCK) {
+                                                nextblk =3D (block_no =
+ 1) %
+
(nic->block_count[ring_no]);
+                                                rxdpnext =3D
nic->rx_blocks[ring_no]
+
[nextblk].block_virt_addr;
+                                    }
+                                    if (rxdpnext->Control_2 & BIT(0))
+                                                goto end;
+                        }
+#endif

+#ifndef           CONFIG_2BUFF_MODE
                         skb =3D dev_alloc_skb(size + NET_IP_ALIGN);
+#else
+                        skb =3D dev_alloc_skb(dev->mtu + ALIGN_SIZE +
+                                                    /*BUF0_LEN + */ 22=
);
+#endif
                         if (!skb) {
                                     DBG_PRINT(ERR_DBG, "%s: Out of ",
dev->name);
                                     DBG_PRINT(ERR_DBG, "memory to allo=
cate
SKBs\n");
                                     return -ENOMEM;
                         }
+#ifndef           CONFIG_2BUFF_MODE
                         skb_reserve(skb, NET_IP_ALIGN);
                         memset(rxdp, 0, sizeof(RxD_t));
                         rxdp->Buffer0_ptr =3D pci_map_single
@@ -1645,6 +1812,33 @@
                         off++;
                         off %=3D (MAX_RXDS_PER_BLOCK + 1);
                         mac_control->rx_curr_put_info[ring_no].offset =
=3D
off;
+#else
+                        ba =3D &nic->ba[ring_no][block_no][off];
+                        tmp =3D (u64) skb->data;
+                        tmp +=3D ALIGN_SIZE;
+                        tmp &=3D ~ALIGN_SIZE;
+                        skb->data =3D (void *) tmp;
+
+                        memset(rxdp, 0, sizeof(RxD_t));
+                        rxdp->Buffer2_ptr =3D pci_map_single
+                            (nic->pdev, skb->data, dev->mtu + 22,
+                             PCI_DMA_FROMDEVICE);
+                        rxdp->Buffer0_ptr =3D
+                            pci_map_single(nic->pdev, ba->ba_0, BUF0_L=
EN,
+                                                   PCI_DMA_FROMDEVICE)=
;
+                        rxdp->Buffer1_ptr =3D
+                            pci_map_single(nic->pdev, ba->ba_1, BUF1_L=
EN,
+                                                   PCI_DMA_FROMDEVICE)=
;
+
+                        rxdp->Control_2 =3D SET_BUFFER2_SIZE(dev->mtu =
+ 22);
+                        rxdp->Control_2 |=3D SET_BUFFER0_SIZE(BUF0_LEN=
);
+                        rxdp->Control_2 |=3D SET_BUFFER1_SIZE(1);     =
    /*
dummy. */
+                        rxdp->Control_2 |=3D BIT(0);          /* Set
Buffer_Empty bit. */
+                        rxdp->Host_Control =3D (u64) ((unsigned long)
(skb));
+                        rxdp->Control_1 |=3D RXD_OWN_XENA;
+                        off++;
+                        mac_control->rx_curr_put_info[ring_no].offset =
=3D
off;
+#endif
                         atomic_inc(&nic->rx_bufs_left[ring_no]);
                         alloc_tab++;
             }
@@ -1670,6 +1864,9 @@
             struct sk_buff *skb;
             mac_info_t *mac_control;
             struct config_param *config;
+#ifdef CONFIG_2BUFF_MODE
+            buffAdd_t *ba;
+#endif

             mac_control =3D &sp->mac_control;
             config =3D &sp->config;
@@ -1679,6 +1876,7 @@
                                     off =3D j % (MAX_RXDS_PER_BLOCK + =
1);
                                     rxdp =3D
sp->rx_blocks[i][blk].block_virt_addr + off;

+#ifndef CONFIG_2BUFF_MODE
                                     if (rxdp->Control_1 =3D=3D END_OF_=
BLOCK) {
                                                 rxdp =3D
                                                     (RxD_t *) ((unsign=
ed
long) rxdp->
@@ -1686,6 +1884,12 @@
                                                 j++;
                                                 blk++;
                                     }
+#else
+                                    if (rxdp->Host_Control =3D=3D
END_OF_BLOCK) {
+                                                blk++;
+                                                continue;
+                                    }
+#endif

                                     if (!(rxdp->Control_1 & RXD_OWN_XE=
NA))
{
                                                 memset(rxdp, 0,
sizeof(RxD_t));
@@ -1696,6 +1900,7 @@
                                         (struct sk_buff *) ((unsigned
long) rxdp->

Host_Control);
                                     if (skb) {
+#ifndef CONFIG_2BUFF_MODE
                                                 pci_unmap_single(sp->p=
dev,
(dma_addr_t)

rxdp->Buffer0_ptr,

dev->mtu +
@@ -1703,6 +1908,21 @@
                                                                       =
   +
HEADER_802_2_SIZE +

HEADER_SNAP_SIZE,

PCI_DMA_FROMDEVICE);
+#else
+                                                ba =3D &sp->ba[i][blk]=
[off];
+                                                pci_unmap_single(sp->p=
dev,
(dma_addr_t)
+
rxdp->Buffer0_ptr,
+
BUF0_LEN,
+
PCI_DMA_FROMDEVICE);
+                                                pci_unmap_single(sp->p=
dev,
(dma_addr_t)
+
rxdp->Buffer1_ptr,
+
BUF1_LEN,
+
PCI_DMA_FROMDEVICE);
+                                                pci_unmap_single(sp->p=
dev,
(dma_addr_t)
+
rxdp->Buffer2_ptr,
+
dev->mtu + 22,
+
PCI_DMA_FROMDEVICE);
+#endif
                                                 dev_kfree_skb(skb);

atomic_dec(&sp->rx_bufs_left[i]);
                                                 buf_cnt++;
@@ -1741,11 +1961,16 @@
             register u64 val64 =3D 0;
             rx_curr_get_info_t get_info, put_info;
             int i, get_block, put_block, get_offset, put_offset,
ring_bufs;
+#ifndef CONFIG_2BUFF_MODE
             u16 val16, cksum;
+#endif
             struct sk_buff *skb;
             RxD_t *rxdp;
             mac_info_t *mac_control;
             struct config_param *config;
+#ifdef CONFIG_2BUFF_MODE
+            buffAdd_t *ba;
+#endif

             mac_control =3D &nic->mac_control;
             config =3D &nic->config;
@@ -1764,6 +1989,7 @@
                         ring_bufs =3D config->rx_cfg[i].num_rxd;
                         rxdp =3D
nic->rx_blocks[i][get_block].block_virt_addr +
                             get_info.offset;
+#ifndef           CONFIG_2BUFF_MODE
                         get_offset =3D (get_block * (MAX_RXDS_PER_BLOC=
K +
1)) +
                             get_info.offset;
                         put_offset =3D (put_block * (MAX_RXDS_PER_BLOC=
K +
1)) +
@@ -1820,6 +2046,66 @@

mac_control->rx_curr_get_info[i].offset =3D
                                         get_info.offset;
                         }
+#else
+                        get_offset =3D (get_block * (MAX_RXDS_PER_BLOC=
K +
1)) +
+                            get_info.offset;
+                        put_offset =3D (put_block * (MAX_RXDS_PER_BLOC=
K +
1)) +
+                            put_info.offset;
+                        while (((!(rxdp->Control_1 & RXD_OWN_XENA)) &&=

+                                    !(rxdp->Control_2 & BIT(0))) &&
+                               (((get_offset + 1) % ring_bufs) !=3D
put_offset)) {
+                                    if (--pkts_to_process < 0) {
+                                                goto no_rx;
+                                    }
+                                    skb =3D (struct sk_buff *) ((unsig=
ned
long)
+
rxdp->Host_Control);
+                                    if (skb =3D=3D NULL) {
+                                                DBG_PRINT(ERR_DBG, "%s=
:
The skb is ",
+                                                              dev->nam=
e);
+                                                DBG_PRINT(ERR_DBG, "Nu=
ll
in Rx Intr\n");
+                                                goto no_rx;
+                                    }
+
+                                    pci_unmap_single(nic->pdev,
(dma_addr_t)
+
rxdp->Buffer0_ptr,
+                                                             BUF0_LEN,=

PCI_DMA_FROMDEVICE);
+                                    pci_unmap_single(nic->pdev,
(dma_addr_t)
+
rxdp->Buffer1_ptr,
+                                                             BUF1_LEN,=

PCI_DMA_FROMDEVICE);
+                                    pci_unmap_single(nic->pdev,
(dma_addr_t)
+
rxdp->Buffer2_ptr,
+                                                             dev->mtu =
+
22,
+
PCI_DMA_FROMDEVICE);
+                                    ba =3D
&nic->ba[i][get_block][get_info.offset];
+
+                                    rx_osm_handler(nic, rxdp, i, ba);
+
+                                    get_info.offset++;
+
mac_control->rx_curr_get_info[i].offset =3D
+                                        get_info.offset;
+                                    rxdp =3D
+
nic->rx_blocks[i][get_block].block_virt_addr +
+                                        get_info.offset;
+
+                                    if (get_info.offset &&
+                                        (!(get_info.offset %
MAX_RXDS_PER_BLOCK))) {
+                                                get_info.offset =3D 0;=

+
mac_control->rx_curr_get_info[i].
+                                                    offset =3D
get_info.offset;
+                                                get_block++;
+                                                get_block %=3D
nic->block_count[i];
+
mac_control->rx_curr_get_info[i].
+                                                    block_index =3D
get_block;
+                                                rxdp =3D
+
nic->rx_blocks[i][get_block].
+                                                    block_virt_addr;
+                                    }
+                                    get_offset =3D
+                                        (get_block * (MAX_RXDS_PER_BLO=
CK +
1)) +
+                                        get_info.offset;
+                                    pkt_cnt++;
+                        }
+#endif
             }
             if (!pkt_cnt)
                         pkt_cnt =3D 1;
@@ -1873,12 +2159,17 @@
             rx_curr_get_info_t get_info, put_info;
             RxD_t *rxdp;
             struct sk_buff *skb;
+#ifndef CONFIG_2BUFF_MODE
             u16 val16, cksum;
+#endif
             register u64 val64 =3D 0;
             int get_block, get_offset, put_block, put_offset, ring_buf=
s;
             int i, pkt_cnt =3D 0;
             mac_info_t *mac_control;
             struct config_param *config;
+#ifdef CONFIG_2BUFF_MODE
+            buffAdd_t *ba;
+#endif

             mac_control =3D &nic->mac_control;
             config =3D &nic->config;
@@ -1898,6 +2189,7 @@
                         ring_bufs =3D config->rx_cfg[i].num_rxd;
                         rxdp =3D
nic->rx_blocks[i][get_block].block_virt_addr +
                             get_info.offset;
+#ifndef           CONFIG_2BUFF_MODE
                         get_offset =3D (get_block * (MAX_RXDS_PER_BLOC=
K +
1)) +
                             get_info.offset;
                         spin_lock(&nic->put_lock);
@@ -1953,6 +2245,67 @@
                                         && (pkt_cnt > indicate_max_pkt=
s))
                                                 break;
                         }
+#else
+                        get_offset =3D (get_block * (MAX_RXDS_PER_BLOC=
K +
1)) +
+                            get_info.offset;
+                        spin_lock(&nic->put_lock);
+                        put_offset =3D nic->put_pos[i];
+                        spin_unlock(&nic->put_lock);
+                        while (((!(rxdp->Control_1 & RXD_OWN_XENA)) &&=

+                                    !(rxdp->Control_2 & BIT(0))) &&
+                               (((get_offset + 1) % ring_bufs) !=3D
put_offset)) {
+                                    skb =3D (struct sk_buff *) ((unsig=
ned
long)
+
rxdp->Host_Control);
+                                    if (skb =3D=3D NULL) {
+                                                DBG_PRINT(ERR_DBG, "%s=
:
The skb is ",
+                                                              dev->nam=
e);
+                                                DBG_PRINT(ERR_DBG, "Nu=
ll
in Rx Intr\n");
+                                                return;
+                                    }
+
+                                    pci_unmap_single(nic->pdev,
(dma_addr_t)
+
rxdp->Buffer0_ptr,
+                                                             BUF0_LEN,=

PCI_DMA_FROMDEVICE);
+                                    pci_unmap_single(nic->pdev,
(dma_addr_t)
+
rxdp->Buffer1_ptr,
+                                                             BUF1_LEN,=

PCI_DMA_FROMDEVICE);
+                                    pci_unmap_single(nic->pdev,
(dma_addr_t)
+
rxdp->Buffer2_ptr,
+                                                             dev->mtu =
+
22,
+
PCI_DMA_FROMDEVICE);
+                                    ba =3D
&nic->ba[i][get_block][get_info.offset];
+
+                                    rx_osm_handler(nic, rxdp, i, ba);
+
+                                    get_info.offset++;
+
mac_control->rx_curr_get_info[i].offset =3D
+                                        get_info.offset;
+                                    rxdp =3D
+
nic->rx_blocks[i][get_block].block_virt_addr +
+                                        get_info.offset;
+
+                                    if (get_info.offset &&
+                                        (!(get_info.offset %
MAX_RXDS_PER_BLOCK))) {
+                                                get_info.offset =3D 0;=

+
mac_control->rx_curr_get_info[i].
+                                                    offset =3D
get_info.offset;
+                                                get_block++;
+                                                get_block %=3D
nic->block_count[i];
+
mac_control->rx_curr_get_info[i].
+                                                    block_index =3D
get_block;
+                                                rxdp =3D
+
nic->rx_blocks[i][get_block].
+                                                    block_virt_addr;
+                                    }
+                                    get_offset =3D=

+                                        (get_block * (MAX_RXDS_PER_BLO=
CK +
1)) +
+                                        get_info.offset;
+                                    pkt_cnt++;
+                                    if ((indicate_max_pkts)
+                                        && (pkt_cnt > indicate_max_pkt=
s))
+                                                break;
+                        }
+#endif
                         if ((indicate_max_pkts) && (pkt_cnt >
indicate_max_pkts))
                                     break;
             }
@@ -4096,12 +4449,21 @@
  *   Return value:
  *   SUCCESS on success and -1 on failure.
  */
+#ifndef CONFIG_2BUFF_MODE
 static int rx_osm_handler(nic_t * sp, u16 len, RxD_t * rxdp, int ring_=
no)
+#else
+static int rx_osm_handler(nic_t * sp, RxD_t * rxdp, int ring_no,
+                                      buffAdd_t * ba)
+#endif
 {
             struct net_device *dev =3D (struct net_device *) sp->dev;
             struct sk_buff *skb =3D
                 (struct sk_buff *) ((unsigned long) rxdp->Host_Control=
);
             u16 l3_csum, l4_csum;
+#ifdef CONFIG_2BUFF_MODE
+            int buf0_len, buf2_len;
+            struct ethhdr *eth =3D (struct ethhdr *) ba->ba_0;
+#endif

             l3_csum =3D RXD_GET_L3_CKSUM(rxdp->Control_1);
             if ((rxdp->Control_1 & TCP_OR_UDP_FRAME) && (sp->rx_csum))=
 {
@@ -4129,10 +4491,32 @@
                         DBG_PRINT(ERR_DBG, "%s: Rx error Value: 0x%llx=
\n",
                                       dev->name, err);
             }
+#ifdef CONFIG_2BUFF_MODE
+            buf0_len =3D RXD_GET_BUFFER0_SIZE(rxdp->Control_2);
+            buf2_len =3D RXD_GET_BUFFER2_SIZE(rxdp->Control_2);
+#endif

             skb->dev =3D dev;
+#ifndef CONFIG_2BUFF_MODE
             skb_put(skb, len);
             skb->protocol =3D eth_type_trans(skb, dev);
+#else
+            skb_put(skb, buf2_len);
+            /*
+             * Reproducing eth_type_trans functionality and running
+             * on the ethernet header 'eth' stripped and given to us
+             * by the hardware in 2Buff mode.
+             */
+            if (*eth->h_dest & 1) {
+                        if (!memcmp(eth->h_dest, dev->broadcast,
ETH_ALEN))
+                                    skb->pkt_type =3D PACKET_BROADCAST=
;
+                        else
+                                    skb->pkt_type =3D PACKET_MULTICAST=
;
+            } else if (memcmp(eth->h_dest, dev->dev_addr, ETH_ALEN)) {=

+                        skb->pkt_type =3D PACKET_OTHERHOST;
+            }
+            skb->protocol =3D eth->h_proto;
+#endif

 #ifdef CONFIG_S2IO_NAPI
             netif_receive_skb(skb);
@@ -4143,7 +4527,11 @@
             dev->last_rx =3D jiffies;
             sp->rx_pkt_count++;
             sp->stats.rx_packets++;
+#ifndef CONFIG_2BUFF_MODE
             sp->stats.rx_bytes +=3D len;
+#else
+            sp->stats.rx_bytes +=3D buf0_len + buf2_len;
+#endif

             atomic_dec(&sp->rx_bufs_left[ring_no]);
             rxdp->Host_Control =3D 0;
diff -urN vanilla-linux/drivers/net/s2io.h linux-2.6.8.1/drivers/net/s2=
io.h
--- vanilla-linux/drivers/net/s2io.h             2004-10-11
21:21:49.000000000 -0700
+++ linux-2.6.8.1/drivers/net/s2io.h             2004-10-11
21:22:23.000000000 -0700
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
+
       >> 48)
+#define RXD_GET_BUFFER1_SIZE(Control_2) (u16)((Control_2 &
MASK_BUFFER1_SIZE) \
+
       >> 32)
+#define RXD_GET_BUFFER2_SIZE(Control_2) (u16)((Control_2 &
MASK_BUFFER2_SIZE) \
+
       >> 16)
+#define BUF0_LEN        40
+#define BUF1_LEN        1
+#endif
+
             u64 Buffer0_ptr;
+#ifdef CONFIG_2BUFF_MODE
+            u64 Buffer1_ptr;
+            u64 Buffer2_ptr;
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
                                                              * the upp=
er
32 bits should
                                                              * be 0 */=

 } RxD_block_t;
+#else
+typedef struct _RxD_block {
+#define MAX_RXDS_PER_BLOCK             85
+            RxD_t rxd[MAX_RXDS_PER_BLOCK];
+
+#define END_OF_BLOCK    0xFEFFFFFFFFFFFFFFULL
+            u64 reserved_1;                     /* 0xFEFFFFFFFFFFFFFF =
to
mark last Rxd
+                                                 * in this blk */
+            u64 pNext_RxD_Blk_physical;         /* Phy ponter to next =
blk.
*/
+} RxD_block_t;
+#define SIZE_OF_BLOCK         4096
+
+/* Structure to hold virtual addresses of Buf0 and Buf1 in
+ * 2buf mode. */
+typedef struct bufAdd {
+            void *ba_0_org;
+            void *ba_1_org;
+            void *ba_0;
+            void *ba_1;
+} buffAdd_t;
+#endif

 /* Structure which stores all the MAC control parameters */

@@ -677,6 +725,10 @@
 #define           LINK_DOWN         1
 #define           LINK_UP                       2

+#ifdef CONFIG_2BUFF_MODE
+            /* Buffer Address store. */
+            buffAdd_t **ba[MAX_RX_RINGS];
+#endif
             int task_flag;
 } nic_t;

@@ -802,7 +854,12 @@
 static void s2io_tx_watchdog(struct net_device *dev);
 static void s2io_tasklet(unsigned long dev_addr);
 static void s2io_set_multicast(struct net_device *dev);
+#ifndef CONFIG_2BUFF_MODE
 static int rx_osm_handler(nic_t * sp, u16 len, RxD_t * rxdp, int ring_=
no);
+#else
+static int rx_osm_handler(nic_t * sp, RxD_t * rxdp, int ring_no,
+                                      buffAdd_t * ba);
+#endif
 void s2io_link(nic_t * sp, int link);
 void s2io_reset(nic_t * sp);
 #ifdef CONFIG_S2IO_NAPI

=

--1__=07BBE5D4DF915B888f9e8a93df938690918c07BBE5D4DF915B88
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline
Content-transfer-encoding: quoted-printable

<html><body>
<p>Sorry if my mailer mangles the mail, but ...<br>
<br>
This code looks like it can cause an oops on failure to alloc cases. I =
havent read the code very much other than the<br>
init and the free routines.<br>
<br>
<tt>+#ifdef CONFIG_2BUFF_MODE<br>
+		 /* Freeing buffer storage addresses in 2BUFF mode. */<br>
+		 for (i =3D 0; i &lt; config-&gt;rx_ring_num; i++) {<br>
+		 		 blk_cnt =3D<br>
+		 		 &nbsp; &nbsp; config-&gt;rx_cfg[i].num_rxd / (MAX_RXDS_PER_BLOCK=
 + 1);<br>
+		 		 for (j =3D 0; j &lt; blk_cnt; j++) {<br>
+		 		 		 int k =3D 0;<br>
+		 		 		 if (!nic-&gt;ba[i][j])<br>
+		 		 		 		 continue;<br>
+		 		 		 while (k !=3D MAX_RXDS_PER_BLOCK) {<br>
+		 		 		 		 buffAdd_t *ba =3D &amp;nic-&gt;ba[i][j][k];<br>
+		 		 		 		 kfree(ba-&gt;ba_0_org);<br>
+		 		 		 		 kfree(ba-&gt;ba_1_org);<br>
+		 		 		 		 k++;<br>
+		 		 		 }<br>
+		 		 		 kfree(nic-&gt;ba[i][j]);<br>
+		 		 }<br>
+		 		 if (nic-&gt;ba[i])<br>
+		 		 		 kfree(nic-&gt;ba[i]);<br>
+		 }<br>
+#endif</tt><br>
<br>
Shouldn't this be something like (check ba[i] at the top to avoid MMU) =
:<br>
<br>
<tt>+#ifdef CONFIG_2BUFF_MODE<br>
+		 /* Freeing buffer storage addresses in 2BUFF mode. */<br>
+		 for (i =3D 0; i &lt; config-&gt;rx_ring_num; i++) {</tt><br>
<tt>+				 if (!nic-&gt;ba[i]) /* if there are no holes, we are done */<=
/tt><br>
<tt>+					break;<br>
+		 		 blk_cnt =3D<br>
+		 		 &nbsp; &nbsp; config-&gt;rx_cfg[i].num_rxd / (MAX_RXDS_PER_BLOCK=
 + 1);<br>
+		 		 for (j =3D 0; j &lt; blk_cnt; j++) {<br>
+		 		 		 int k =3D 0;<br>
+		 		 		 if (!nic-&gt;ba[i][j])<br>
+		 		 		 		 continue;</tt><br>
<tt>&gt;&gt; Should this be a break ? Can you have holes in the middle =
?</tt><br>
<tt>+		 		 		 while (k !=3D MAX_RXDS_PER_BLOCK) {<br>
+		 		 		 		 buffAdd_t *ba =3D &amp;nic-&gt;ba[i][j][k];<br>
+		 		 		 		 kfree(ba-&gt;ba_0_org);<br>
+		 		 		 		 kfree(ba-&gt;ba_1_org);</tt><br>
<tt>&gt;&gt; Actually if no holes are allowed, you can break out if the=
 above pointers become</tt><br>
<tt>&gt;&gt; NULL instead of iterating MAX_RXDS_PER_BLOCK (127) times.<=
br>
+		 		 		 		 k++;<br>
+		 		 		 }<br>
+		 		 		 kfree(nic-&gt;ba[i][j]);<br>
+		 		 }<br>
+		 		 kfree(nic-&gt;ba[i]);<br>
+		 }<br>
+#endif</tt><br>
<br>
thx,<br>
<br>
- KK<br>
<br>
<img src=3D"cid:20__=3D07BBE5D4DF915B888f9e8a93df938@us.ibm.com" width=3D=
"16" height=3D"16" alt=3D"Inactive hide details for raghavendra.koushik=
@s2io.com">raghavendra.koushik@s2io.com<br>
<br>
<br>

<table width=3D"100%" border=3D"0" cellspacing=3D"0" cellpadding=3D"0">=

<tr valign=3D"top"><td style=3D"background-image:url(cid:30__=3D07BBE5D=
4DF915B888f9e8a93df938@us.ibm.com); background-repeat: no-repeat; " wid=
th=3D"40%">
<ul>
<ul>
<ul>
<ul><b><font size=3D"2">raghavendra.koushik@s2io.com</font></b><font si=
ze=3D"2"> </font><br>
<font size=3D"2">Sent by: netdev-bounce@oss.sgi.com</font>
<p><font size=3D"2">11/08/2004 08:16 AM</font></ul>
</ul>
</ul>
</ul>
</td><td width=3D"60%">
<table width=3D"100%" border=3D"0" cellspacing=3D"0" cellpadding=3D"0">=

<tr valign=3D"top"><td width=3D"1%" valign=3D"middle"><img src=3D"cid:4=
0__=3D07BBE5D4DF915B888f9e8a93df938@us.ibm.com" border=3D"0" height=3D"=
1" width=3D"58" alt=3D""><br>
<div align=3D"right"><font size=3D"2">To</font></div></td><td width=3D"=
100%"><img src=3D"cid:40__=3D07BBE5D4DF915B888f9e8a93df938@us.ibm.com" =
border=3D"0" height=3D"1" width=3D"1" alt=3D""><br>
<font size=3D"2">jgarzik@pobox.com, romieu@fr.zoreil.com, netdev@oss.sg=
i.com</font></td></tr>

<tr valign=3D"top"><td width=3D"1%" valign=3D"middle"><img src=3D"cid:4=
0__=3D07BBE5D4DF915B888f9e8a93df938@us.ibm.com" border=3D"0" height=3D"=
1" width=3D"58" alt=3D""><br>
<div align=3D"right"><font size=3D"2">cc</font></div></td><td width=3D"=
100%"><img src=3D"cid:40__=3D07BBE5D4DF915B888f9e8a93df938@us.ibm.com" =
border=3D"0" height=3D"1" width=3D"1" alt=3D""><br>
<font size=3D"2">ravinandan.arakali@s2io.com, raghavendra.koushik@s2io.=
com</font></td></tr>

<tr valign=3D"top"><td width=3D"1%" valign=3D"middle"><img src=3D"cid:4=
0__=3D07BBE5D4DF915B888f9e8a93df938@us.ibm.com" border=3D"0" height=3D"=
1" width=3D"58" alt=3D""><br>
<div align=3D"right"><font size=3D"2">Subject</font></div></td><td widt=
h=3D"100%"><img src=3D"cid:40__=3D07BBE5D4DF915B888f9e8a93df938@us.ibm.=
com" border=3D"0" height=3D"1" width=3D"1" alt=3D""><br>
<font size=3D"2">[PATCH 2.6.9-rc2 8/12] S2io: two buffer mode</font></t=
d></tr>
</table>

<table border=3D"0" cellspacing=3D"0" cellpadding=3D"0">
<tr valign=3D"top"><td width=3D"58"><img src=3D"cid:40__=3D07BBE5D4DF91=
5B888f9e8a93df938@us.ibm.com" border=3D"0" height=3D"1" width=3D"1" alt=
=3D""></td><td width=3D"336"><img src=3D"cid:40__=3D07BBE5D4DF915B888f9=
e8a93df938@us.ibm.com" border=3D"0" height=3D"1" width=3D"1" alt=3D""><=
/td></tr>
</table>
</td></tr>
</table>
<br>
<tt>Hi,<br>
Attached is the patch for implementing 2-buffer mode on Rx path.<br>
More description of this mode of operation follows.<br>
<br>
On certain systems when a DMA has to happen on an un-aligned memory loc=
ation performance will take a significant hit. It's standard<br>
practice to offset the Rx buffer address by 2 (as Mac header is 14 byte=
s) so the IP header starts from an aligned location.<br>
Obviously using a single Rx buffer both cannot be achieved. Thus XFrame=
 supports something called 2 buffer Rx mode, where in the<br>
Rx'ed frame is split into 2 parts, one is the Ethernet header and the o=
ther is the Ethernet payload. So now we can allocate proper<br>
aligned memory for both buffers, hence the DMA is not slowed down. Also=
, the Ethernet payload(starting from L3 header) is on an<br>
aligned location so OS need not have to do un-aligned accesses to proce=
ss IP header. To achieve this, the kernel function<br>
eth_type_trans functionality has to be partially implemented in the dri=
ver itself.<br>
<br>
Signed-off-by: Raghavendra Koushik &lt;raghavendra.koushik@s2io.com&gt;=
<br>
Signed-off-by: Ravinandan Arakali &lt;ravinandan.arakali@s2io.com&gt;<b=
r>
---<br>
diff -urN vanilla-linux/drivers/net/Kconfig linux-2.6.8.1/drivers/net/K=
config<br>
--- vanilla-linux/drivers/net/Kconfig		 2004-10-06 15:15:04.000000000 -=
0700<br>
+++ linux-2.6.8.1/drivers/net/Kconfig		 2004-10-11 20:06:36.000000000 -=
0700<br>
@@ -2267,6 +2267,17 @@<br>
 <br>
 		 &nbsp; If in doubt, say N.<br>
 <br>
+config 2BUFF_MODE<br>
+		 bool &quot;Use 2 Buffer Mode on Rx side.&quot;<br>
+		 depends on S2IO<br>
+		 ---help---<br>
+		 On enabling the 2 buffer mode, the received frame will be<br>
+		 split into 2 parts before being DMA'ed to the hosts memory.<br>
+		 The parts are the ethernet header and ethernet payload. <br>
+		 This is useful on systems where DMA'ing to to unaligned <br>
+		 physical memory loactions comes with a heavy price.<br>
+		 If not sure please say N.<br>
+<br>
 endmenu<br>
 <br>
 source &quot;drivers/net/tokenring/Kconfig&quot;<br>
diff -urN vanilla-linux/drivers/net/s2io.c linux-2.6.8.1/drivers/net/s2=
io.c<br>
--- vanilla-linux/drivers/net/s2io.c		 2004-10-11 21:21:49.000000000 -0=
700<br>
+++ linux-2.6.8.1/drivers/net/s2io.c		 2004-10-12 16:49:27.796331624 -0=
700<br>
@@ -325,6 +325,10 @@<br>
 		 int i, j, blk_cnt;<br>
 		 int lst_size, lst_per_page;<br>
 		 struct net_device *dev =3D nic-&gt;dev;<br>
+#ifdef CONFIG_2BUFF_MODE<br>
+		 u64 tmp;<br>
+		 buffAdd_t *ba;<br>
+#endif<br>
 <br>
 		 mac_info_t *mac_control;<br>
 		 struct config_param *config;<br>
@@ -425,7 +429,11 @@<br>
 		 		 &nbsp; &nbsp; config-&gt;rx_cfg[i].num_rxd / (MAX_RXDS_PER_BLOCK=
 + 1);<br>
 		 		 /* &nbsp;Allocating all the Rx blocks */<br>
 		 		 for (j =3D 0; j &lt; blk_cnt; j++) {<br>
+#ifndef CONFIG_2BUFF_MODE<br>
 		 		 		 size =3D (MAX_RXDS_PER_BLOCK + 1) * (sizeof(RxD_t));<br>
+#else<br>
+		 		 		 size =3D SIZE_OF_BLOCK;<br>
+#endif<br>
 		 		 		 tmp_v_addr =3D pci_alloc_consistent(nic-&gt;pdev, size,<br>
 		 		 		 		 		 		 		 &nbsp; &amp;tmp_p_addr);<br>
 		 		 		 if (tmp_v_addr =3D=3D NULL) {<br>
@@ -458,13 +466,60 @@<br>
 		 		 		 pre_rxd_blk-&gt;reserved_1 =3D END_OF_BLOCK;		 /* last RxD <b=
r>
 		 		 		 		 		 		 		 		 &nbsp;* marker.<br>
 		 		 		 		 		 		 		 		 &nbsp;*/<br>
+#ifndef		 CONFIG_2BUFF_MODE<br>
 		 		 		 pre_rxd_blk-&gt;reserved_2_pNext_RxD_block =3D<br>
 		 		 		 &nbsp; &nbsp; (unsigned long) tmp_v_addr_next;<br>
+#endif<br>
 		 		 		 pre_rxd_blk-&gt;pNext_RxD_Blk_physical =3D<br>
 		 		 		 &nbsp; &nbsp; (u64) tmp_p_addr_next;<br>
 		 		 }<br>
 		 }<br>
 <br>
+#ifdef CONFIG_2BUFF_MODE<br>
+		 /* <br>
+		 &nbsp;* Allocation of Storages for buffer addresses in 2BUFF mode<b=
r>
+		 &nbsp;* and the buffers as well.<br>
+		 &nbsp;*/<br>
+		 for (i =3D 0; i &lt; config-&gt;rx_ring_num; i++) {<br>
+		 		 blk_cnt =3D<br>
+		 		 &nbsp; &nbsp; config-&gt;rx_cfg[i].num_rxd / (MAX_RXDS_PER_BLOCK=
 + 1);<br>
+		 		 nic-&gt;ba[i] =3D kmalloc((sizeof(buffAdd_t *) * blk_cnt),<br>
+		 		 		 		 &nbsp; &nbsp; &nbsp;GFP_KERNEL);<br>
+		 		 if (!nic-&gt;ba[i])<br>
+		 		 		 return -ENOMEM;<br>
+		 		 for (j =3D 0; j &lt; blk_cnt; j++) {<br>
+		 		 		 int k =3D 0;<br>
+		 		 		 nic-&gt;ba[i][j] =3D kmalloc((sizeof(buffAdd_t) *<br>
+		 		 		 		 		 		 &nbsp;(MAX_RXDS_PER_BLOCK + 1)),<br>
+		 		 		 		 		 		 GFP_KERNEL);<br>
+		 		 		 if (!nic-&gt;ba[i][j])<br>
+		 		 		 		 return -ENOMEM;<br>
+		 		 		 while (k !=3D MAX_RXDS_PER_BLOCK) {<br>
+		 		 		 		 ba =3D &amp;nic-&gt;ba[i][j][k];<br>
+<br>
+		 		 		 		 ba-&gt;ba_0_org =3D (void *) kmalloc<br>
+		 		 		 		 &nbsp; &nbsp; (BUF0_LEN + ALIGN_SIZE, GFP_ATOMIC);<br>
+		 		 		 		 if (!ba-&gt;ba_0_org)<br>
+		 		 		 		 		 return -ENOMEM;<br>
+		 		 		 		 tmp =3D (u64) ba-&gt;ba_0_org;<br>
+		 		 		 		 tmp +=3D ALIGN_SIZE;<br>
+		 		 		 		 tmp &amp;=3D ~((u64) ALIGN_SIZE);<br>
+		 		 		 		 ba-&gt;ba_0 =3D (void *) tmp;<br>
+<br>
+		 		 		 		 ba-&gt;ba_1_org =3D (void *) kmalloc<br>
+		 		 		 		 &nbsp; &nbsp; (BUF1_LEN + ALIGN_SIZE, GFP_ATOMIC);<br>
+		 		 		 		 if (!ba-&gt;ba_1_org)<br>
+		 		 		 		 		 return -ENOMEM;<br>
+		 		 		 		 tmp =3D (u64) ba-&gt;ba_1_org;<br>
+		 		 		 		 tmp +=3D ALIGN_SIZE;<br>
+		 		 		 		 tmp &amp;=3D ~((u64) ALIGN_SIZE);<br>
+		 		 		 		 ba-&gt;ba_1 =3D (void *) tmp;<br>
+		 		 		 		 k++;<br>
+		 		 		 }<br>
+		 		 }<br>
+		 }<br>
+#endif<br>
+<br>
 		 /* Allocation and initialization of Statistics block */<br>
 		 size =3D sizeof(StatInfo_t);<br>
 		 mac_control-&gt;stats_mem =3D pci_alloc_consistent<br>
@@ -532,7 +587,11 @@<br>
 		 		 kfree(nic-&gt;list_info[i]);<br>
 		 }<br>
 <br>
+#ifndef CONFIG_2BUFF_MODE<br>
 		 size =3D (MAX_RXDS_PER_BLOCK + 1) * (sizeof(RxD_t));<br>
+#else<br>
+		 size =3D SIZE_OF_BLOCK;<br>
+#endif<br>
 		 for (i =3D 0; i &lt; config-&gt;rx_ring_num; i++) {<br>
 		 		 blk_cnt =3D nic-&gt;block_count[i];<br>
 		 		 for (j =3D 0; j &lt; blk_cnt; j++) {<br>
@@ -545,6 +604,27 @@<br>
 		 		 }<br>
 		 }<br>
 <br>
+#ifdef CONFIG_2BUFF_MODE<br>
+		 /* Freeing buffer storage addresses in 2BUFF mode. */<br>
+		 for (i =3D 0; i &lt; config-&gt;rx_ring_num; i++) {<br>
+		 		 blk_cnt =3D<br>
+		 		 &nbsp; &nbsp; config-&gt;rx_cfg[i].num_rxd / (MAX_RXDS_PER_BLOCK=
 + 1);<br>
+		 		 for (j =3D 0; j &lt; blk_cnt; j++) {<br>
+		 		 		 int k =3D 0;<br>
+		 		 		 if (!nic-&gt;ba[i][j])<br>
+		 		 		 		 continue;<br>
+		 		 		 while (k !=3D MAX_RXDS_PER_BLOCK) {<br>
+		 		 		 		 buffAdd_t *ba =3D &amp;nic-&gt;ba[i][j][k];<br>
+		 		 		 		 kfree(ba-&gt;ba_0_org);<br>
+		 		 		 		 kfree(ba-&gt;ba_1_org);<br>
+		 		 		 		 k++;<br>
+		 		 		 }<br>
+		 		 		 kfree(nic-&gt;ba[i][j]);<br>
+		 		 }<br>
+		 		 if (nic-&gt;ba[i])<br>
+		 		 		 kfree(nic-&gt;ba[i]);<br>
+		 }<br>
+#endif<br>
 <br>
 		 if (mac_control-&gt;stats_mem) {<br>
 		 		 pci_free_consistent(nic-&gt;pdev,<br>
@@ -1366,10 +1446,21 @@<br>
 		 		 &nbsp; &nbsp; &nbsp; &nbsp;&amp;bar0-&gt;prc_rxd0_n[i]);<br>
 <br>
 		 		 val64 =3D readq(&amp;bar0-&gt;prc_ctrl_n[i]);<br>
+#ifndef CONFIG_2BUFF_MODE<br>
 		 		 val64 |=3D PRC_CTRL_RC_ENABLED;<br>
+#else<br>
+		 		 val64 |=3D PRC_CTRL_RC_ENABLED | PRC_CTRL_RING_MODE_3;<br>
+#endif<br>
 		 		 writeq(val64, &amp;bar0-&gt;prc_ctrl_n[i]);<br>
 		 }<br>
 <br>
+#ifdef CONFIG_2BUFF_MODE<br>
+		 /* Enabling 2 buffer mode by writing into Rx_pa_cfg reg. */<br>
+		 val64 =3D readq(&amp;bar0-&gt;rx_pa_cfg);<br>
+		 val64 |=3D RX_PA_CFG_IGNORE_L2_ERR;<br>
+		 writeq(val64, &amp;bar0-&gt;rx_pa_cfg);<br>
+#endif<br>
+<br>
 		 /* <br>
 		 &nbsp;* Enabling MC-RLDRAM. After enabling the device, we timeout<b=
r>
 		 &nbsp;* for around 100ms, which is approximately the time required<=
br>
@@ -1437,6 +1528,12 @@<br>
 		 }<br>
 <br>
 		 /* <br>
+		 &nbsp;* Don't see link state interrupts on certain switches, so <br=
>
+		 &nbsp;* directly scheduling a link state task from here.<br>
+		 &nbsp;*/<br>
+		 schedule_work(&amp;nic-&gt;set_link_task);<br>
+<br>
+		 /* <br>
 		 &nbsp;* Here we are performing soft reset on XGXS to <br>
 		 &nbsp;* force link down. Since link is already up, we will get<br>
 		 &nbsp;* link state change interrupt after this reset<br>
@@ -1565,6 +1662,13 @@<br>
 		 &nbsp; &nbsp; atomic_read(&amp;nic-&gt;rx_bufs_left[ring_no]);<br>
 		 mac_info_t *mac_control;<br>
 		 struct config_param *config;<br>
+#ifdef CONFIG_2BUFF_MODE<br>
+		 RxD_t *rxdpnext;<br>
+		 int nextblk;<br>
+		 u64 tmp;<br>
+		 buffAdd_t *ba;<br>
+		 dma_addr_t rxdpphys;<br>
+#endif<br>
 #ifndef CONFIG_S2IO_NAPI<br>
 		 unsigned long flags;<br>
 #endif<br>
@@ -1589,10 +1693,14 @@<br>
 		 		 &nbsp; &nbsp; block_index;<br>
 		 		 off =3D mac_control-&gt;rx_curr_put_info[ring_no].offset;<br>
 		 		 off1 =3D mac_control-&gt;rx_curr_get_info[ring_no].offset;<br>
+#ifndef CONFIG_2BUFF_MODE<br>
 		 		 offset =3D block_no * (MAX_RXDS_PER_BLOCK + 1) + off;<br>
 		 		 offset1 =3D block_no1 * (MAX_RXDS_PER_BLOCK + 1) + off1;<br>
+#else<br>
 		 		 offset =3D block_no * (MAX_RXDS_PER_BLOCK) + off;<br>
 		 		 offset1 =3D block_no1 * (MAX_RXDS_PER_BLOCK) + off1;<br>
+#endif<br>
+<br>
 		 		 rxdp =3D nic-&gt;rx_blocks[ring_no][block_no].<br>
 		 		 &nbsp; &nbsp; block_virt_addr + off;<br>
 		 		 if ((offset =3D=3D offset1) &amp;&amp; (rxdp-&gt;Host_Control)) =
{<br>
@@ -1600,6 +1708,7 @@<br>
 		 		 		 DBG_PRINT(INTR_DBG, &quot; info equated\n&quot;);<br>
 		 		 		 goto end;<br>
 		 		 }<br>
+#ifndef		 CONFIG_2BUFF_MODE<br>
 		 		 if (rxdp-&gt;Control_1 =3D=3D END_OF_BLOCK) {<br>
 		 		 		 mac_control-&gt;rx_curr_put_info[ring_no].<br>
 		 		 		 &nbsp; &nbsp; block_index++;<br>
@@ -1617,23 +1726,81 @@<br>
 		 		 }<br>
 #ifndef CONFIG_S2IO_NAPI<br>
 		 		 spin_lock_irqsave(&amp;nic-&gt;put_lock, flags);<br>
+		 		 nic-&gt;put_pos[ring_no] =3D<br>
+		 		 &nbsp; &nbsp; (block_no * (MAX_RXDS_PER_BLOCK + 1)) + off;<br>
+		 		 spin_unlock_irqrestore(&amp;nic-&gt;put_lock, flags);<br>
+#endif<br>
+#else<br>
+		 		 if (rxdp-&gt;Host_Control =3D=3D END_OF_BLOCK) {<br>
+		 		 		 mac_control-&gt;rx_curr_put_info[ring_no].<br>
+		 		 		 &nbsp; &nbsp; block_index++;<br>
+		 		 		 mac_control-&gt;rx_curr_put_info[ring_no].<br>
+		 		 		 &nbsp; &nbsp; block_index %=3D nic-&gt;block_count[ring_no];<=
br>
+		 		 		 block_no =3D mac_control-&gt;rx_curr_put_info<br>
+		 		 		 &nbsp; &nbsp; [ring_no].block_index;<br>
+		 		 		 off =3D 0;<br>
+		 		 		 DBG_PRINT(INTR_DBG, &quot;%s: block%d at: 0x%llx\n&quot;,<br>=

+		 		 		 		 &nbsp; dev-&gt;name, block_no,<br>
+		 		 		 		 &nbsp; (unsigned long long) rxdp-&gt;Control_1);<br>
+		 		 		 mac_control-&gt;rx_curr_put_info[ring_no].offset =3D<br>
+		 		 		 &nbsp; &nbsp; off;<br>
+		 		 		 rxdp =3D nic-&gt;rx_blocks[ring_no][block_no].<br>
+		 		 		 &nbsp; &nbsp; block_virt_addr;<br>
+		 		 }<br>
+#ifndef CONFIG_S2IO_NAPI<br>
+		 		 spin_lock_irqsave(&amp;nic-&gt;put_lock, flags);<br>
 		 		 nic-&gt;put_pos[ring_no] =3D (block_no *<br>
 		 		 		 		 		 &nbsp;(MAX_RXDS_PER_BLOCK + 1)) + off;<br>
 		 		 spin_unlock_irqrestore(&amp;nic-&gt;put_lock, flags);<br>
 #endif<br>
+#endif<br>
 <br>
-		 		 if (rxdp-&gt;Control_1 &amp; RXD_OWN_XENA) {<br>
+#ifndef		 CONFIG_2BUFF_MODE<br>
+		 		 if (rxdp-&gt;Control_1 &amp; RXD_OWN_XENA)<br>
+#else<br>
+		 		 if (rxdp-&gt;Control_2 &amp; BIT(0))<br>
+#endif<br>
+		 		 {<br>
 		 		 		 mac_control-&gt;rx_curr_put_info[ring_no].<br>
 		 		 		 &nbsp; &nbsp; offset =3D off;<br>
 		 		 		 goto end;<br>
 		 		 }<br>
+#ifdef		 CONFIG_2BUFF_MODE<br>
+		 		 /* <br>
+		 		 &nbsp;* RxDs Spanning cache lines will be replenished only <br>
+		 		 &nbsp;* if the succeeding RxD is also owned by Host. It <br>
+		 		 &nbsp;* will always be the ((8*i)+3) and ((8*i)+6) <br>
+		 		 &nbsp;* descriptors for the 48 byte descriptor. The offending <b=
r>
+		 		 &nbsp;* decsriptor is of-course the 3rd descriptor.<br>
+		 		 &nbsp;*/<br>
+		 		 rxdpphys =3D nic-&gt;rx_blocks[ring_no][block_no].<br>
+		 		 &nbsp; &nbsp; block_dma_addr + (off * sizeof(RxD_t));<br>
+		 		 if (((u64) (rxdpphys)) % 128 &gt; 80) {<br>
+		 		 		 rxdpnext =3D nic-&gt;rx_blocks[ring_no][block_no].<br>
+		 		 		 &nbsp; &nbsp; block_virt_addr + (off + 1);<br>
+		 		 		 if (rxdpnext-&gt;Host_Control =3D=3D END_OF_BLOCK) {<br>
+		 		 		 		 nextblk =3D (block_no + 1) %<br>
+		 		 		 		 &nbsp; &nbsp; (nic-&gt;block_count[ring_no]);<br>
+		 		 		 		 rxdpnext =3D nic-&gt;rx_blocks[ring_no]<br>
+		 		 		 		 &nbsp; &nbsp; [nextblk].block_virt_addr;<br>
+		 		 		 }<br>
+		 		 		 if (rxdpnext-&gt;Control_2 &amp; BIT(0))<br>
+		 		 		 		 goto end;<br>
+		 		 }<br>
+#endif<br>
 <br>
+#ifndef		 CONFIG_2BUFF_MODE<br>
 		 		 skb =3D dev_alloc_skb(size + NET_IP_ALIGN);<br>
+#else<br>
+		 		 skb =3D dev_alloc_skb(dev-&gt;mtu + ALIGN_SIZE +<br>
+		 		 		 		 &nbsp; &nbsp; /*BUF0_LEN + */ 22);<br>
+#endif<br>
 		 		 if (!skb) {<br>
 		 		 		 DBG_PRINT(ERR_DBG, &quot;%s: Out of &quot;, dev-&gt;name);<br=
>
 		 		 		 DBG_PRINT(ERR_DBG, &quot;memory to allocate SKBs\n&quot;);<br=
>
 		 		 		 return -ENOMEM;<br>
 		 		 }<br>
+#ifndef		 CONFIG_2BUFF_MODE<br>
 		 		 skb_reserve(skb, NET_IP_ALIGN);<br>
 		 		 memset(rxdp, 0, sizeof(RxD_t));<br>
 		 		 rxdp-&gt;Buffer0_ptr =3D pci_map_single<br>
@@ -1645,6 +1812,33 @@<br>
 		 		 off++;<br>
 		 		 off %=3D (MAX_RXDS_PER_BLOCK + 1);<br>
 		 		 mac_control-&gt;rx_curr_put_info[ring_no].offset =3D off;<br>
+#else<br>
+		 		 ba =3D &amp;nic-&gt;ba[ring_no][block_no][off];<br>
+		 		 tmp =3D (u64) skb-&gt;data;<br>
+		 		 tmp +=3D ALIGN_SIZE;<br>
+		 		 tmp &amp;=3D ~ALIGN_SIZE;<br>
+		 		 skb-&gt;data =3D (void *) tmp;<br>
+<br>
+		 		 memset(rxdp, 0, sizeof(RxD_t));<br>
+		 		 rxdp-&gt;Buffer2_ptr =3D pci_map_single<br>
+		 		 &nbsp; &nbsp; (nic-&gt;pdev, skb-&gt;data, dev-&gt;mtu + 22,<br>=

+		 		 &nbsp; &nbsp; &nbsp;PCI_DMA_FROMDEVICE);<br>
+		 		 rxdp-&gt;Buffer0_ptr =3D<br>
+		 		 &nbsp; &nbsp; pci_map_single(nic-&gt;pdev, ba-&gt;ba_0, BUF0_LEN=
,<br>
+		 		 		 		 &nbsp; &nbsp;PCI_DMA_FROMDEVICE);<br>
+		 		 rxdp-&gt;Buffer1_ptr =3D<br>
+		 		 &nbsp; &nbsp; pci_map_single(nic-&gt;pdev, ba-&gt;ba_1, BUF1_LEN=
,<br>
+		 		 		 		 &nbsp; &nbsp;PCI_DMA_FROMDEVICE);<br>
+<br>
+		 		 rxdp-&gt;Control_2 =3D SET_BUFFER2_SIZE(dev-&gt;mtu + 22);<br>
+		 		 rxdp-&gt;Control_2 |=3D SET_BUFFER0_SIZE(BUF0_LEN);<br>
+		 		 rxdp-&gt;Control_2 |=3D SET_BUFFER1_SIZE(1);		 /* dummy. */<br>
+		 		 rxdp-&gt;Control_2 |=3D BIT(0);		 /* Set Buffer_Empty bit. */<br=
>
+		 		 rxdp-&gt;Host_Control =3D (u64) ((unsigned long) (skb));<br>
+		 		 rxdp-&gt;Control_1 |=3D RXD_OWN_XENA;<br>
+		 		 off++;<br>
+		 		 mac_control-&gt;rx_curr_put_info[ring_no].offset =3D off;<br>
+#endif<br>
 		 		 atomic_inc(&amp;nic-&gt;rx_bufs_left[ring_no]);<br>
 		 		 alloc_tab++;<br>
 		 }<br>
@@ -1670,6 +1864,9 @@<br>
 		 struct sk_buff *skb;<br>
 		 mac_info_t *mac_control;<br>
 		 struct config_param *config;<br>
+#ifdef CONFIG_2BUFF_MODE<br>
+		 buffAdd_t *ba;<br>
+#endif<br>
 <br>
 		 mac_control =3D &amp;sp-&gt;mac_control;<br>
 		 config =3D &amp;sp-&gt;config;<br>
@@ -1679,6 +1876,7 @@<br>
 		 		 		 off =3D j % (MAX_RXDS_PER_BLOCK + 1);<br>
 		 		 		 rxdp =3D sp-&gt;rx_blocks[i][blk].block_virt_addr + off;<br>
 <br>
+#ifndef CONFIG_2BUFF_MODE<br>
 		 		 		 if (rxdp-&gt;Control_1 =3D=3D END_OF_BLOCK) {<br>
 		 		 		 		 rxdp =3D<br>
 		 		 		 		 &nbsp; &nbsp; (RxD_t *) ((unsigned long) rxdp-&gt;<br>
@@ -1686,6 +1884,12 @@<br>
 		 		 		 		 j++;<br>
 		 		 		 		 blk++;<br>
 		 		 		 }<br>
+#else<br>
+		 		 		 if (rxdp-&gt;Host_Control =3D=3D END_OF_BLOCK) {<br>
+		 		 		 		 blk++;<br>
+		 		 		 		 continue;<br>
+		 		 		 }<br>
+#endif<br>
 <br>
 		 		 		 if (!(rxdp-&gt;Control_1 &amp; RXD_OWN_XENA)) {<br>
 		 		 		 		 memset(rxdp, 0, sizeof(RxD_t));<br>
@@ -1696,6 +1900,7 @@<br>
 		 		 		 &nbsp; &nbsp; (struct sk_buff *) ((unsigned long) rxdp-&gt;<b=
r>
 		 		 		 		 		 		 Host_Control);<br>
 		 		 		 if (skb) {<br>
+#ifndef CONFIG_2BUFF_MODE<br>
 		 		 		 		 pci_unmap_single(sp-&gt;pdev, (dma_addr_t)<br>
 		 		 		 		 		 		 &nbsp;rxdp-&gt;Buffer0_ptr,<br>
 		 		 		 		 		 		 &nbsp;dev-&gt;mtu +<br>
@@ -1703,6 +1908,21 @@<br>
 		 		 		 		 		 		 &nbsp;+ HEADER_802_2_SIZE +<br>
 		 		 		 		 		 		 &nbsp;HEADER_SNAP_SIZE,<br>
 		 		 		 		 		 		 &nbsp;PCI_DMA_FROMDEVICE);<br>
+#else<br>
+		 		 		 		 ba =3D &amp;sp-&gt;ba[i][blk][off];<br>
+		 		 		 		 pci_unmap_single(sp-&gt;pdev, (dma_addr_t)<br>
+		 		 		 		 		 		 &nbsp;rxdp-&gt;Buffer0_ptr,<br>
+		 		 		 		 		 		 &nbsp;BUF0_LEN,<br>
+		 		 		 		 		 		 &nbsp;PCI_DMA_FROMDEVICE);<br>
+		 		 		 		 pci_unmap_single(sp-&gt;pdev, (dma_addr_t)<br>
+		 		 		 		 		 		 &nbsp;rxdp-&gt;Buffer1_ptr,<br>
+		 		 		 		 		 		 &nbsp;BUF1_LEN,<br>
+		 		 		 		 		 		 &nbsp;PCI_DMA_FROMDEVICE);<br>
+		 		 		 		 pci_unmap_single(sp-&gt;pdev, (dma_addr_t)<br>
+		 		 		 		 		 		 &nbsp;rxdp-&gt;Buffer2_ptr,<br>
+		 		 		 		 		 		 &nbsp;dev-&gt;mtu + 22,<br>
+		 		 		 		 		 		 &nbsp;PCI_DMA_FROMDEVICE);<br>
+#endif<br>
 		 		 		 		 dev_kfree_skb(skb);<br>
 		 		 		 		 atomic_dec(&amp;sp-&gt;rx_bufs_left[i]);<br>
 		 		 		 		 buf_cnt++;<br>
@@ -1741,11 +1961,16 @@<br>
 		 register u64 val64 =3D 0;<br>
 		 rx_curr_get_info_t get_info, put_info;<br>
 		 int i, get_block, put_block, get_offset, put_offset, ring_bufs;<br>=

+#ifndef CONFIG_2BUFF_MODE<br>
 		 u16 val16, cksum;<br>
+#endif<br>
 		 struct sk_buff *skb;<br>
 		 RxD_t *rxdp;<br>
 		 mac_info_t *mac_control;<br>
 		 struct config_param *config;<br>
+#ifdef CONFIG_2BUFF_MODE<br>
+		 buffAdd_t *ba;<br>
+#endif<br>
 <br>
 		 mac_control =3D &amp;nic-&gt;mac_control;<br>
 		 config =3D &amp;nic-&gt;config;<br>
@@ -1764,6 +1989,7 @@<br>
 		 		 ring_bufs =3D config-&gt;rx_cfg[i].num_rxd;<br>
 		 		 rxdp =3D nic-&gt;rx_blocks[i][get_block].block_virt_addr +<br>
 		 		 &nbsp; &nbsp; get_info.offset;<br>
+#ifndef		 CONFIG_2BUFF_MODE<br>
 		 		 get_offset =3D (get_block * (MAX_RXDS_PER_BLOCK + 1)) +<br>
 		 		 &nbsp; &nbsp; get_info.offset;<br>
 		 		 put_offset =3D (put_block * (MAX_RXDS_PER_BLOCK + 1)) +<br>
@@ -1820,6 +2046,66 @@<br>
 		 		 		 mac_control-&gt;rx_curr_get_info[i].offset =3D<br>
 		 		 		 &nbsp; &nbsp; get_info.offset;<br>
 		 		 }<br>
+#else<br>
+		 		 get_offset =3D (get_block * (MAX_RXDS_PER_BLOCK + 1)) +<br>
+		 		 &nbsp; &nbsp; get_info.offset;<br>
+		 		 put_offset =3D (put_block * (MAX_RXDS_PER_BLOCK + 1)) +<br>
+		 		 &nbsp; &nbsp; put_info.offset;<br>
+		 		 while (((!(rxdp-&gt;Control_1 &amp; RXD_OWN_XENA)) &amp;&amp;<br=
>
+		 		 		 !(rxdp-&gt;Control_2 &amp; BIT(0))) &amp;&amp;<br>
+		 		 &nbsp; &nbsp; &nbsp; &nbsp;(((get_offset + 1) % ring_bufs) !=3D =
put_offset)) {<br>
+		 		 		 if (--pkts_to_process &lt; 0) {<br>
+		 		 		 		 goto no_rx;<br>
+		 		 		 }<br>
+		 		 		 skb =3D (struct sk_buff *) ((unsigned long)<br>
+		 		 		 		 		 		 &nbsp; rxdp-&gt;Host_Control);<br>
+		 		 		 if (skb =3D=3D NULL) {<br>
+		 		 		 		 DBG_PRINT(ERR_DBG, &quot;%s: The skb is &quot;,<br>
+		 		 		 		 		 &nbsp; dev-&gt;name);<br>
+		 		 		 		 DBG_PRINT(ERR_DBG, &quot;Null in Rx Intr\n&quot;);<br>
+		 		 		 		 goto no_rx;<br>
+		 		 		 }<br>
+<br>
+		 		 		 pci_unmap_single(nic-&gt;pdev, (dma_addr_t)<br>
+		 		 		 		 		 &nbsp;rxdp-&gt;Buffer0_ptr,<br>
+		 		 		 		 		 &nbsp;BUF0_LEN, PCI_DMA_FROMDEVICE);<br>
+		 		 		 pci_unmap_single(nic-&gt;pdev, (dma_addr_t)<br>
+		 		 		 		 		 &nbsp;rxdp-&gt;Buffer1_ptr,<br>
+		 		 		 		 		 &nbsp;BUF1_LEN, PCI_DMA_FROMDEVICE);<br>
+		 		 		 pci_unmap_single(nic-&gt;pdev, (dma_addr_t)<br>
+		 		 		 		 		 &nbsp;rxdp-&gt;Buffer2_ptr,<br>
+		 		 		 		 		 &nbsp;dev-&gt;mtu + 22,<br>
+		 		 		 		 		 &nbsp;PCI_DMA_FROMDEVICE);<br>
+		 		 		 ba =3D &amp;nic-&gt;ba[i][get_block][get_info.offset];<br>
+<br>
+		 		 		 rx_osm_handler(nic, rxdp, i, ba);<br>
+<br>
+		 		 		 get_info.offset++;<br>
+		 		 		 mac_control-&gt;rx_curr_get_info[i].offset =3D<br>
+		 		 		 &nbsp; &nbsp; get_info.offset;<br>
+		 		 		 rxdp =3D<br>
+		 		 		 &nbsp; &nbsp; nic-&gt;rx_blocks[i][get_block].block_virt_addr=
 +<br>
+		 		 		 &nbsp; &nbsp; get_info.offset;<br>
+<br>
+		 		 		 if (get_info.offset &amp;&amp;<br>
+		 		 		 &nbsp; &nbsp; (!(get_info.offset % MAX_RXDS_PER_BLOCK))) {<br=
>
+		 		 		 		 get_info.offset =3D 0;<br>
+		 		 		 		 mac_control-&gt;rx_curr_get_info[i].<br>
+		 		 		 		 &nbsp; &nbsp; offset =3D get_info.offset;<br>
+		 		 		 		 get_block++;<br>
+		 		 		 		 get_block %=3D nic-&gt;block_count[i];<br>
+		 		 		 		 mac_control-&gt;rx_curr_get_info[i].<br>
+		 		 		 		 &nbsp; &nbsp; block_index =3D get_block;<br>
+		 		 		 		 rxdp =3D<br>
+		 		 		 		 &nbsp; &nbsp; nic-&gt;rx_blocks[i][get_block].<br>
+		 		 		 		 &nbsp; &nbsp; block_virt_addr;<br>
+		 		 		 }<br>
+		 		 		 get_offset =3D<br>
+		 		 		 &nbsp; &nbsp; (get_block * (MAX_RXDS_PER_BLOCK + 1)) +<br>
+		 		 		 &nbsp; &nbsp; get_info.offset;<br>
+		 		 		 pkt_cnt++;<br>
+		 		 }<br>
+#endif<br>
 		 }<br>
 		 if (!pkt_cnt)<br>
 		 		 pkt_cnt =3D 1;<br>
@@ -1873,12 +2159,17 @@<br>
 		 rx_curr_get_info_t get_info, put_info;<br>
 		 RxD_t *rxdp;<br>
 		 struct sk_buff *skb;<br>
+#ifndef CONFIG_2BUFF_MODE<br>
 		 u16 val16, cksum;<br>
+#endif<br>
 		 register u64 val64 =3D 0;<br>
 		 int get_block, get_offset, put_block, put_offset, ring_bufs;<br>
 		 int i, pkt_cnt =3D 0;<br>
 		 mac_info_t *mac_control;<br>
 		 struct config_param *config;<br>
+#ifdef CONFIG_2BUFF_MODE<br>
+		 buffAdd_t *ba;<br>
+#endif<br>
 <br>
 		 mac_control =3D &amp;nic-&gt;mac_control;<br>
 		 config =3D &amp;nic-&gt;config;<br>
@@ -1898,6 +2189,7 @@<br>
 		 		 ring_bufs =3D config-&gt;rx_cfg[i].num_rxd;<br>
 		 		 rxdp =3D nic-&gt;rx_blocks[i][get_block].block_virt_addr +<br>
 		 		 &nbsp; &nbsp; get_info.offset;<br>
+#ifndef		 CONFIG_2BUFF_MODE<br>
 		 		 get_offset =3D (get_block * (MAX_RXDS_PER_BLOCK + 1)) +<br>
 		 		 &nbsp; &nbsp; get_info.offset;<br>
 		 		 spin_lock(&amp;nic-&gt;put_lock);<br>
@@ -1953,6 +2245,67 @@<br>
 		 		 		 &nbsp; &nbsp; &amp;&amp; (pkt_cnt &gt; indicate_max_pkts))<br=
>
 		 		 		 		 break;<br>
 		 		 }<br>
+#else<br>
+		 		 get_offset =3D (get_block * (MAX_RXDS_PER_BLOCK + 1)) +<br>
+		 		 &nbsp; &nbsp; get_info.offset;<br>
+		 		 spin_lock(&amp;nic-&gt;put_lock);<br>
+		 		 put_offset =3D nic-&gt;put_pos[i];<br>
+		 		 spin_unlock(&amp;nic-&gt;put_lock);<br>
+		 		 while (((!(rxdp-&gt;Control_1 &amp; RXD_OWN_XENA)) &amp;&amp;<br=
>
+		 		 		 !(rxdp-&gt;Control_2 &amp; BIT(0))) &amp;&amp;<br>
+		 		 &nbsp; &nbsp; &nbsp; &nbsp;(((get_offset + 1) % ring_bufs) !=3D =
put_offset)) {<br>
+		 		 		 skb =3D (struct sk_buff *) ((unsigned long)<br>
+		 		 		 		 		 		 &nbsp; rxdp-&gt;Host_Control);<br>
+		 		 		 if (skb =3D=3D NULL) {<br>
+		 		 		 		 DBG_PRINT(ERR_DBG, &quot;%s: The skb is &quot;,<br>
+		 		 		 		 		 &nbsp; dev-&gt;name);<br>
+		 		 		 		 DBG_PRINT(ERR_DBG, &quot;Null in Rx Intr\n&quot;);<br>
+		 		 		 		 return;<br>
+		 		 		 }<br>
+<br>
+		 		 		 pci_unmap_single(nic-&gt;pdev, (dma_addr_t)<br>
+		 		 		 		 		 &nbsp;rxdp-&gt;Buffer0_ptr,<br>
+		 		 		 		 		 &nbsp;BUF0_LEN, PCI_DMA_FROMDEVICE);<br>
+		 		 		 pci_unmap_single(nic-&gt;pdev, (dma_addr_t)<br>
+		 		 		 		 		 &nbsp;rxdp-&gt;Buffer1_ptr,<br>
+		 		 		 		 		 &nbsp;BUF1_LEN, PCI_DMA_FROMDEVICE);<br>
+		 		 		 pci_unmap_single(nic-&gt;pdev, (dma_addr_t)<br>
+		 		 		 		 		 &nbsp;rxdp-&gt;Buffer2_ptr,<br>
+		 		 		 		 		 &nbsp;dev-&gt;mtu + 22,<br>
+		 		 		 		 		 &nbsp;PCI_DMA_FROMDEVICE);<br>
+		 		 		 ba =3D &amp;nic-&gt;ba[i][get_block][get_info.offset];<br>
+<br>
+		 		 		 rx_osm_handler(nic, rxdp, i, ba);<br>
+<br>
+		 		 		 get_info.offset++;<br>
+		 		 		 mac_control-&gt;rx_curr_get_info[i].offset =3D<br>
+		 		 		 &nbsp; &nbsp; get_info.offset;<br>
+		 		 		 rxdp =3D<br>
+		 		 		 &nbsp; &nbsp; nic-&gt;rx_blocks[i][get_block].block_virt_addr=
 +<br>
+		 		 		 &nbsp; &nbsp; get_info.offset;<br>
+<br>
+		 		 		 if (get_info.offset &amp;&amp;<br>
+		 		 		 &nbsp; &nbsp; (!(get_info.offset % MAX_RXDS_PER_BLOCK))) {<br=
>
+		 		 		 		 get_info.offset =3D 0;<br>
+		 		 		 		 mac_control-&gt;rx_curr_get_info[i].<br>
+		 		 		 		 &nbsp; &nbsp; offset =3D get_info.offset;<br>
+		 		 		 		 get_block++;<br>
+		 		 		 		 get_block %=3D nic-&gt;block_count[i];<br>
+		 		 		 		 mac_control-&gt;rx_curr_get_info[i].<br>
+		 		 		 		 &nbsp; &nbsp; block_index =3D get_block;<br>
+		 		 		 		 rxdp =3D<br>
+		 		 		 		 &nbsp; &nbsp; nic-&gt;rx_blocks[i][get_block].<br>
+		 		 		 		 &nbsp; &nbsp; block_virt_addr;<br>
+		 		 		 }<br>
+		 		 		 get_offset =3D<br>
+		 		 		 &nbsp; &nbsp; (get_block * (MAX_RXDS_PER_BLOCK + 1)) +<br>
+		 		 		 &nbsp; &nbsp; get_info.offset;<br>
+		 		 		 pkt_cnt++;<br>
+		 		 		 if ((indicate_max_pkts)<br>
+		 		 		 &nbsp; &nbsp; &amp;&amp; (pkt_cnt &gt; indicate_max_pkts))<br=
>
+		 		 		 		 break;<br>
+		 		 }<br>
+#endif<br>
 		 		 if ((indicate_max_pkts) &amp;&amp; (pkt_cnt &gt; indicate_max_pk=
ts))<br>
 		 		 		 break;<br>
 		 }<br>
@@ -4096,12 +4449,21 @@</tt><br>
<tt> &nbsp;* &nbsp; Return value:<br>
 &nbsp;* &nbsp; SUCCESS on success and -1 on failure.<br>
 &nbsp;*/<br>
+#ifndef CONFIG_2BUFF_MODE<br>
 static int rx_osm_handler(nic_t * sp, u16 len, RxD_t * rxdp, int ring_=
no)<br>
+#else<br>
+static int rx_osm_handler(nic_t * sp, RxD_t * rxdp, int ring_no,<br>
+		 		 		 &nbsp; buffAdd_t * ba)<br>
+#endif<br>
 {<br>
 		 struct net_device *dev =3D (struct net_device *) sp-&gt;dev;<br>
 		 struct sk_buff *skb =3D<br>
 		 &nbsp; &nbsp; (struct sk_buff *) ((unsigned long) rxdp-&gt;Host_Con=
trol);<br>
 		 u16 l3_csum, l4_csum;<br>
+#ifdef CONFIG_2BUFF_MODE<br>
+		 int buf0_len, buf2_len;<br>
+		 struct ethhdr *eth =3D (struct ethhdr *) ba-&gt;ba_0;<br>
+#endif<br>
 <br>
 		 l3_csum =3D RXD_GET_L3_CKSUM(rxdp-&gt;Control_1);<br>
 		 if ((rxdp-&gt;Control_1 &amp; TCP_OR_UDP_FRAME) &amp;&amp; (sp-&gt;=
rx_csum)) {<br>
@@ -4129,10 +4491,32 @@<br>
 		 		 DBG_PRINT(ERR_DBG, &quot;%s: Rx error Value: 0x%llx\n&quot;,<br>=

 		 		 		 &nbsp; dev-&gt;name, err);<br>
 		 }<br>
+#ifdef CONFIG_2BUFF_MODE<br>
+		 buf0_len =3D RXD_GET_BUFFER0_SIZE(rxdp-&gt;Control_2);<br>
+		 buf2_len =3D RXD_GET_BUFFER2_SIZE(rxdp-&gt;Control_2);<br>
+#endif<br>
 <br>
 		 skb-&gt;dev =3D dev;<br>
+#ifndef CONFIG_2BUFF_MODE<br>
 		 skb_put(skb, len);<br>
 		 skb-&gt;protocol =3D eth_type_trans(skb, dev);<br>
+#else<br>
+		 skb_put(skb, buf2_len);<br>
+		 /* <br>
+		 &nbsp;* Reproducing eth_type_trans functionality and running<br>
+		 &nbsp;* on the ethernet header 'eth' stripped and given to us<br>
+		 &nbsp;* by the hardware in 2Buff mode.<br>
+		 &nbsp;*/<br>
+		 if (*eth-&gt;h_dest &amp; 1) {<br>
+		 		 if (!memcmp(eth-&gt;h_dest, dev-&gt;broadcast, ETH_ALEN))<br>
+		 		 		 skb-&gt;pkt_type =3D PACKET_BROADCAST;<br>
+		 		 else<br>
+		 		 		 skb-&gt;pkt_type =3D PACKET_MULTICAST;<br>
+		 } else if (memcmp(eth-&gt;h_dest, dev-&gt;dev_addr, ETH_ALEN)) {<br=
>
+		 		 skb-&gt;pkt_type =3D PACKET_OTHERHOST;<br>
+		 }<br>
+		 skb-&gt;protocol =3D eth-&gt;h_proto;<br>
+#endif<br>
 <br>
 #ifdef CONFIG_S2IO_NAPI<br>
 		 netif_receive_skb(skb);<br>
@@ -4143,7 +4527,11 @@<br>
 		 dev-&gt;last_rx =3D jiffies;<br>
 		 sp-&gt;rx_pkt_count++;<br>
 		 sp-&gt;stats.rx_packets++;<br>
+#ifndef CONFIG_2BUFF_MODE<br>
 		 sp-&gt;stats.rx_bytes +=3D len;<br>
+#else<br>
+		 sp-&gt;stats.rx_bytes +=3D buf0_len + buf2_len;<br>
+#endif<br>
 <br>
 		 atomic_dec(&amp;sp-&gt;rx_bufs_left[ring_no]);<br>
 		 rxdp-&gt;Host_Control =3D 0;<br>
diff -urN vanilla-linux/drivers/net/s2io.h linux-2.6.8.1/drivers/net/s2=
io.h<br>
--- vanilla-linux/drivers/net/s2io.h		 2004-10-11 21:21:49.000000000 -0=
700<br>
+++ linux-2.6.8.1/drivers/net/s2io.h		 2004-10-11 21:22:23.000000000 -0=
700<br>
@@ -466,19 +466,46 @@<br>
 #define RXD_GET_L4_CKSUM(val) &nbsp; ((u16)(val) &amp; 0xFFFF)<br>
 <br>
 		 u64 Control_2;<br>
+#ifndef CONFIG_2BUFF_MODE<br>
 #define MASK_BUFFER0_SIZE &nbsp; &nbsp; &nbsp; vBIT(0xFFFF,0,16)<br>
 #define SET_BUFFER0_SIZE(val) &nbsp; vBIT(val,0,16)<br>
+#else<br>
+#define MASK_BUFFER0_SIZE &nbsp; &nbsp; &nbsp; vBIT(0xFF,0,16)<br>
+#define MASK_BUFFER1_SIZE &nbsp; &nbsp; &nbsp; vBIT(0xFFFF,16,16)<br>
+#define MASK_BUFFER2_SIZE &nbsp; &nbsp; &nbsp; vBIT(0xFFFF,32,16)<br>
+#define SET_BUFFER0_SIZE(val) &nbsp; vBIT(val,8,8)<br>
+#define SET_BUFFER1_SIZE(val) &nbsp; vBIT(val,16,16)<br>
+#define SET_BUFFER2_SIZE(val) &nbsp; vBIT(val,32,16)<br>
+#endif<br>
+<br>
 #define MASK_VLAN_TAG &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; vBIT(0xFFFF,4=
8,16)<br>
 #define SET_VLAN_TAG(val) &nbsp; &nbsp; &nbsp; vBIT(val,48,16)<br>
 #define SET_NUM_TAG(val) &nbsp; &nbsp; &nbsp; vBIT(val,16,32)<br>
 <br>
+#ifndef CONFIG_2BUFF_MODE<br>
 #define RXD_GET_BUFFER0_SIZE(Control_2) (u64)((Control_2 &amp; vBIT(0x=
FFFF,0,16)))<br>
+#else<br>
+#define RXD_GET_BUFFER0_SIZE(Control_2) (u8)((Control_2 &amp; MASK_BUF=
FER0_SIZE) \<br>
+		 		 		 		 		 		 		 &gt;&gt; 48)<br>
+#define RXD_GET_BUFFER1_SIZE(Control_2) (u16)((Control_2 &amp; MASK_BU=
FFER1_SIZE) \<br>
+		 		 		 		 		 		 		 &gt;&gt; 32)<br>
+#define RXD_GET_BUFFER2_SIZE(Control_2) (u16)((Control_2 &amp; MASK_BU=
FFER2_SIZE) \<br>
+		 		 		 		 		 		 		 &gt;&gt; 16)<br>
+#define BUF0_LEN		 40<br>
+#define BUF1_LEN		 1<br>
+#endif<br>
+<br>
 		 u64 Buffer0_ptr;<br>
+#ifdef CONFIG_2BUFF_MODE<br>
+		 u64 Buffer1_ptr;<br>
+		 u64 Buffer2_ptr;<br>
+#endif<br>
 } RxD_t;<br>
 <br>
 /* Structure that represents the Rx descriptor block which contains <b=
r>
 &nbsp;* 128 Rx descriptors.<br>
 &nbsp;*/<br>
+#ifndef CONFIG_2BUFF_MODE<br>
 typedef struct _RxD_block {<br>
 #define MAX_RXDS_PER_BLOCK &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; 1=
27<br>
 		 RxD_t rxd[MAX_RXDS_PER_BLOCK];<br>
@@ -492,6 +519,27 @@<br>
 		 		 		 		 		 &nbsp;* the upper 32 bits should <br>
 		 		 		 		 		 &nbsp;* be 0 */<br>
 } RxD_block_t;<br>
+#else<br>
+typedef struct _RxD_block {<br>
+#define MAX_RXDS_PER_BLOCK &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; 8=
5<br>
+		 RxD_t rxd[MAX_RXDS_PER_BLOCK];<br>
+<br>
+#define END_OF_BLOCK &nbsp; &nbsp;0xFEFFFFFFFFFFFFFFULL<br>
+		 u64 reserved_1;		 		 /* 0xFEFFFFFFFFFFFFFF to mark last Rxd <br>
+		 		 		 		 &nbsp;* in this blk */<br>
+		 u64 pNext_RxD_Blk_physical;		 /* Phy ponter to next blk. */<br>
+} RxD_block_t;<br>
+#define SIZE_OF_BLOCK		 4096<br>
+<br>
+/* Structure to hold virtual addresses of Buf0 and Buf1 in <br>
+ * 2buf mode. */<br>
+typedef struct bufAdd {<br>
+		 void *ba_0_org;<br>
+		 void *ba_1_org;<br>
+		 void *ba_0;<br>
+		 void *ba_1;<br>
+} buffAdd_t;<br>
+#endif<br>
 <br>
 /* Structure which stores all the MAC control parameters */<br>
 <br>
@@ -677,6 +725,10 @@<br>
 #define		 LINK_DOWN		 1<br>
 #define		 LINK_UP		 		 2<br>
 <br>
+#ifdef CONFIG_2BUFF_MODE<br>
+		 /* Buffer Address store. */<br>
+		 buffAdd_t **ba[MAX_RX_RINGS];<br>
+#endif<br>
 		 int task_flag;<br>
 } nic_t;<br>
 <br>
@@ -802,7 +854,12 @@<br>
 static void s2io_tx_watchdog(struct net_device *dev);<br>
 static void s2io_tasklet(unsigned long dev_addr);<br>
 static void s2io_set_multicast(struct net_device *dev);<br>
+#ifndef CONFIG_2BUFF_MODE<br>
 static int rx_osm_handler(nic_t * sp, u16 len, RxD_t * rxdp, int ring_=
no);<br>
+#else<br>
+static int rx_osm_handler(nic_t * sp, RxD_t * rxdp, int ring_no,<br>
+		 		 		 &nbsp; buffAdd_t * ba);<br>
+#endif<br>
 void s2io_link(nic_t * sp, int link);<br>
 void s2io_reset(nic_t * sp);<br>
 #ifdef CONFIG_S2IO_NAPI<br>
<br>
</tt><br>
</body></html>=


--1__=07BBE5D4DF915B888f9e8a93df938690918c07BBE5D4DF915B88--


--0__=07BBE5D4DF915B888f9e8a93df938690918c07BBE5D4DF915B88
Content-type: image/gif;
	name="graycol.gif"
Content-Disposition: inline; filename="graycol.gif"
Content-ID: <20__=07BBE5D4DF915B888f9e8a93df938@us.ibm.com>
Content-transfer-encoding: base64

R0lGODlhEAAQAKECAMzMzAAAAP///wAAACH5BAEAAAIALAAAAAAQABAAAAIXlI+py+0PopwxUbpu
ZRfKZ2zgSJbmSRYAIf4fT3B0aW1pemVkIGJ5IFVsZWFkIFNtYXJ0U2F2ZXIhAAA7

--0__=07BBE5D4DF915B888f9e8a93df938690918c07BBE5D4DF915B88
Content-type: image/gif;
	name="pic05579.gif"
Content-Disposition: inline; filename="pic05579.gif"
Content-ID: <30__=07BBE5D4DF915B888f9e8a93df938@us.ibm.com>
Content-transfer-encoding: base64

R0lGODlhWABDALP/AAAAAK04Qf79/o+Gm7WuwlNObwoJFCsoSMDAwGFsmIuezf///wAAAAAAAAAA
AAAAACH5BAEAAAgALAAAAABYAEMAQAT/EMlJq704682770RiFMRinqggEUNSHIchG0BCfHhOjAuh
EDeUqTASLCbBhQrhG7xis2j0lssNDopE4jfIJhDaggI8YB1sZeZgLVA9YVCpnGagVjV171aRVrYR
RghXcAGFhoUETwYxcXNyADJ3GlcSKGAwLwllVC1vjIUHBWsFilKQdI8GA5IcpApeJQt8L09lmgkH
LZikoU5wjqcyAMMFrJIDPAKvCFletKSev1HBw8KrxtjZ2tvc3d5VyKtCKW3jfz4uMKmq3xu4N0nK
BVoJQmx2LGVOmrqNjjJf2hHAQo/eDwJGTKhQMcgQEEAnEjFS98+RnW3smGkZU6ncCWav/4wYOnAI
TihRL/4FEwbp28BXMMcoscQCVxlepL4IGDSCyJyVQOu0o7CjmLN50OZlqWmyFy5/6yBBuji0AxFR
M00oQAqNIstqI6qKHUsWRAEAvagsmfUEAImyxgbmUpJk3IklNUtJOUAVLoUr1+wqDGTE4zk+T6FG
uQb3SizBCwatiiUgCBN8vrz+zFjVyQ8FWkOlg4NQiZMB5QS8QO3mpOaKnL0Z2EKvNMSILEThKhCg
zMKPVxYJh23qm9KNW7pArPynMqZDiErsTMqI+LRi3QAgkFUbXpuFKhSYZALd0O5RKa2z9EYKBbpb
qxIKsjUPRgD7I2XYV6wyrOw92ykExP8NW4URhknC5dKGE4v4NENQj2jXjmfNgOZDaXb5glRmXQ33
YEWQYNcZFnrYcIQLNzyTFDQNkXIff0ExVlY4srziQk43inZgL4rwxxINMvpFFAz1KOODHiu+4aEw
NEjFl5B3JIKWKF3k6I9bfUGp5ZZcdunll5IA4cuHvQQJ5gcsoCWOOUwgltIwAKRxJgbIkJAQZEq0
2YliZnpZZ4BH3CnYOXldOUOfQoYDqF1LFHbXCrO8xmRsfoXDXJ6ChjCAH3QlhJcT6VWE6FCkfCco
CgrMFsROrIEX3o2whVjWDjoJccN3LdggSGXLCdLEgHr1lyU3O3QxhgohNKXJCWv8JQr/PDdaqd6w
2rj1inLiGeiCJoDspAoQlYE6QWLSECehcWIYxIQES6zhbn1iImTHEQyqJ4eIxJJoUBc+3CbBuwZE
V5cJPPkIjFDdeEabQbd6WgICTxiiz0f5dBKquXF6k4senwEhYGnKEFJeGrxUZy8dB8gmAXI/sPvH
ESfCwVt5hTgYiqQqtdRNHQIU1PJ33ZqmzgE90OwLaoJcnMop1WiMmgkPHQRIrwgFuNV90A3doNKT
mrKIN07AnGcI9BQjhCBN4RfA1qIZnMqorJCogKfGQnxSCDilTVIA0yl5ciTovgLuBDKFUDE9aQcw
9SA+rjSNf9/M1gxrj6VwDTS0IUSElMzBfsj0NFXR2kwsV1A5IF1grLgLL/r1R40BZEnuBWgmQEyb
jqRwSAt6bqMCOFkvKFN2GPPkUzIm/SCF8z8pVzpbjVnMsy0vOr1hw3SaSRUhpY09v0z0J1FnwzPl
fmh+xl4WtR0zGu24I4KbMQm3lnVu2oNWxI9W/lcyzA+mCKF4DBikxb/+UWtOGRiFP8qEwAayIgIA
Ow==

--0__=07BBE5D4DF915B888f9e8a93df938690918c07BBE5D4DF915B88
Content-type: image/gif;
	name="ecblank.gif"
Content-Disposition: inline; filename="ecblank.gif"
Content-ID: <40__=07BBE5D4DF915B888f9e8a93df938@us.ibm.com>
Content-transfer-encoding: base64

R0lGODlhEAABAIAAAAAAAP///yH5BAEAAAEALAAAAAAQAAEAAAIEjI8ZBQA7

--0__=07BBE5D4DF915B888f9e8a93df938690918c07BBE5D4DF915B88--
