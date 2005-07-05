From: "Qinghua(Kevin) Ye" <qye@trlabs.ca>
Subject: tg3 polling extension
Date: Tue, 5 Jul 2005 15:32:48 -0600
Message-ID: <026f01c581a9$17a54390$e961b9c7@qinghua>
Reply-To: "Qinghua\(Kevin\) Ye" <qye@trlabs.ca>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: click@amsterdam.lcs.mit.edu
Return-path: <click-bounces@amsterdam.lcs.mit.edu>
To: <netdev@vger.kernel.org>
List-Unsubscribe: <https://amsterdam.lcs.mit.edu/mailman/listinfo/click>,
	<mailto:click-request@amsterdam.lcs.mit.edu?subject=unsubscribe>
List-Archive: <https://amsterdam.lcs.mit.edu/pipermail/click>
List-Post: <mailto:click@amsterdam.lcs.mit.edu>
List-Help: <mailto:click-request@amsterdam.lcs.mit.edu?subject=help>
List-Subscribe: <https://amsterdam.lcs.mit.edu/mailman/listinfo/click>,
	<mailto:click-request@amsterdam.lcs.mit.edu?subject=subscribe>
Sender: click-bounces@amsterdam.lcs.mit.edu
Errors-To: click-bounces@amsterdam.lcs.mit.edu
List-Id: netdev.vger.kernel.org

Hi, all,

I am thinking about extending the tg3 driver to support Click Polling. Clic=
k has its patch on linux kernel, and adds some callback functions and polli=
ng variable to the net_device struct(I did this work on 2.6.11 kernel, and =
on AMD opteron):

netdev->polling =3D 0;       // Check if click polling is enabled or not

netdev->rx_poll =3D tg3_rx_poll;=20=20=20
// Click calls rx_poll whenever PollDevice is scheduled. rx_poll
returns a list of sk_buff's that has been sitting in the NICs receive
buffer. rx_poll should NULL the sk_buff's send to Click.

netdev->rx_refill =3D tg3_rx_refill;
// If rx_poll returned any sk_buff's PollDevice then calls rx_refill
and passes a new list of sk_buff's to the driver. rx_refill should use
this list to update the drivers receive buffer and receive
descriptors.

netdev->tx_clean =3D tg3_tx_clean;
// Whenever ToDevice is scheduled it calls tx_clean to clean already
send sk_buffs from the NICs transmit queue. tx_clean should return
this list.

netdev->tx_queue =3D tg3_tx_pqueue;=20
//ToDevice then calls tx_queue and passes an sk_buff to the driver for
transmission.

netdev->tx_eob =3D tg3_tx_eob;
/tx_eob should set the TX Descriptor Tail

netdev->tx_start =3D tg3_tx_start;
//tc_start calls tx_eob - Anyone more info on this ?

netdev->poll_off =3D tg3_poll_off;
//disabling click polling and enabling the NICs irq

netdev->poll_on =3D tg3_poll_on;
//disabling the NICs irq and enabling click polling


Based on this extension, I wrote these functions as follows. However, it wo=
rks not well. For uni-process, it does work, but can only send thousands of=
 packet if there is no packet coming in, no matter how many packets suppose=
d to send out. I debugged it, seems that the problem is on the tg3_tx_clean=
 side. It cannot clean the packet buffer on time. So the interface will be =
timeout, and reseted again and again. However, once there are many packets =
comming, the tx can send more packets out comparative to the number of pack=
ets comming in.

Another problem is: When I start two processes to deal with two interface, =
the system will crash after process tens of thousands packets. Sometimes I =
got this message in syslog:


Jun 30 13:00:42 node13 kernel: Oops: 0000 [1] SMP=20
Jun 30 13:00:42 node13 kernel: CPU 0=20
Jun 30 13:00:42 node13 kernel: Modules linked in: click proclikefs tg3 nfs =
lockd sunrpc ib_mthca lp button autofs ib_ipoib ib_sa ib_mad ib_core ohci13=
94 ieee1394 floppy parport_pc parport usbcore ide_disk ide_core
Jun 30 13:00:42 node13 kernel: Pid: 4300, comm: kclick Tainted: GF     2.6.=
11.6-click
Jun 30 13:00:42 node13 kernel: RIP: 0010:[<ffffffff881dfc14>] <ffffffff881d=
fc14>{:click:_ZN10PollDevice8run_taskEv+196}
Jun 30 13:00:42 node13 kernel: RSP: 0018:ffff81007ee65e48  EFLAGS: 00010297
Jun 30 13:00:42 node13 kernel: RAX: 000000000000006b RBX: 0000000000000000 =
RCX: 0000000000000002
Jun 30 13:00:42 node13 kernel: RDX: 0000000000000740 RSI: ffff81007e681340 =
RDI: 0000000000000000
Jun 30 13:00:42 node13 kernel: RBP: ffff81007e681340 R08: 0000000000000000 =
R09: 0000000000000000
Jun 30 13:00:42 node13 kernel: R10: 0000000000000690 R11: 0000000000000000 =
R12: ffff8100e605ce00
Jun 30 13:00:42 node13 kernel: R13: 0000000000000000 R14: 0000000000000001 =
R15: ffff81007ee65e58
Jun 30 13:00:42 node13 kernel: FS:  00002aaaaae044c0(0000) GS:ffffffff8047a=
980(0000) knlGS:0000000000000000
Jun 30 13:00:42 node13 kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 00000000800=
5003b
Jun 30 13:00:42 node13 kernel: CR2: 0000000000000000 CR3: 00000000e616c000 =
CR4: 00000000000006e0
Jun 30 13:00:42 node13 kernel: Process kclick (pid: 4300, threadinfo ffff81=
007ee64000, task ffff81007fc190d0)
Jun 30 13:00:42 node13 kernel: Stack: 0000000000000000 0000000200000000 000=
0000042c4415a 0000000000082509=20
Jun 30 13:00:42 node13 kernel:        ffff8100e60899c0 ffff8100e605cea0 000=
0000000000006 0000000000000046=20
Jun 30 13:00:42 node13 kernel:        ffff8100e60899c0 0000000000000000=20
Jun 30 13:00:42 node13 kernel: Call Trace:<ffffffff881a420d>{:click:_ZN12Ro=
uterThread6driverEv+973}=20
Jun 30 13:00:42 node13 kernel:        <ffffffff8820324a>{:click:_Z11click_s=
chedPv+170} <ffffffff8010ef9f>{child_rip+8}=20
Jun 30 13:00:42 node13 kernel:        <ffffffff882031a0>{:click:_Z11click_s=
chedPv+0} <ffffffff8010ef97>{child_rip+0}=20
Jun 30 13:00:42 node13 kernel:=20=20=20=20=20=20=20=20
Jun 30 13:00:42 node13 kernel:=20
Jun 30 13:00:42 node13 kernel: Code: 4d 8b 6d 00 48 c7 03 00 00 00 00 4d 85=
 ed 74 10 41 0f 18 4d=20
Jun 30 13:00:42 node13 kernel: RIP <ffffffff881dfc14>{:click:_ZN10PollDevic=
e8run_taskEv+196} RSP <ffff81007ee65e48>
Jun 30 13:00:42 node13 kernel: CR2: 0000000000000000


Any idea will be appreciated! Thanks.

Qinghua


Extended functions:
static struct sk_buff *
tg3_rx_poll(struct net_device *dev, int *want)
{
        struct tg3 *tp=3Ddev->priv;
        int budget =3D *want;
=20=20=20=20=20=20=20=20
        struct sk_buff *skb_head =3D 0, *skb_last =3D 0;
        int skb_size;
        u32 rx_rcb_ptr;
        u16 hw_idx, sw_idx;
        int received;
        int has_jumbo=3D0;
        struct tg3_hw_status *sblk =3D tp->hw_status;
=20=20=20=20=20=20=20=20

         /* process the reset request to avoid reenable ints*/
        if(tp->reset =3D=3D 1){
                tp->reset =3D 0;
                tg3_reset_task(tp);
                spin_lock(&tp->lock);
                tg3_disable_ints(tp);
                spin_unlock(&tp->lock);
        }
=20=20=20=20=20=20=20
=20
        *want =3D 0;
        rx_rcb_ptr=3Dtp->rx_rcb_ptr;
        hw_idx =3D tp->hw_status->idx[0].rx_producer;
        /*
         * We need to order the read of hw_idx and the read of
         * the opaque cookie.
         */
        rmb();
        spin_lock(&tp->lock);
        sw_idx =3D rx_rcb_ptr % TG3_RX_RCB_RING_SIZE(tp);
        received =3D 0;
=20=20=20=20=20=20=20
        while (sw_idx !=3D hw_idx && budget > 0) {
                struct tg3_rx_buffer_desc *desc =3D &tp->rx_rcb[sw_idx];
                unsigned int len;
                struct sk_buff *skb;
                dma_addr_t dma_addr;
                u32 opaque_key, desc_idx, *post_ptr;
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20
                desc_idx =3D desc->opaque & RXD_OPAQUE_INDEX_MASK;
                opaque_key =3D desc->opaque & RXD_OPAQUE_RING_MASK;
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20
                if (opaque_key =3D=3D RXD_OPAQUE_RING_STD) {
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20
                        if ((desc->err_vlan & RXD_ERR_MASK) !=3D 0 &&
                        (desc->err_vlan !=3D RXD_ERR_ODD_NIBBLE_RCVD_MII)) =
{                                rx_rcb_ptr++;
                                sw_idx =3D rx_rcb_ptr % TG3_RX_RCB_RING_SIZ=
E(tp);
                                continue;
                        }
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20
                        dma_addr =3D pci_unmap_addr(&tp->rx_std_buffers[des=
c_idx],                                                  mapping);
                        skb =3D tp->rx_std_buffers[desc_idx].skb;
                        if(!skb){

                  rx_rcb_ptr++;
                  sw_idx =3D rx_rcb_ptr % TG3_RX_RCB_RING_SIZE(tp);
                    continue;=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20
}
                        skb_size =3D RX_PKT_BUF_SZ;
                } else if (opaque_key =3D=3D RXD_OPAQUE_RING_JUMBO) {
                        /* Qinghua: We do not need jumbo packet, just take =
as error*/
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20
                        post_ptr =3D &tp->rx_jumbo_ptr;
                        tg3_recycle_rx(tp, opaque_key,
                                       desc_idx, *post_ptr);
                        *post_ptr++;
                        has_jumbo=3D1;
                        rx_rcb_ptr++;
                        sw_idx =3D rx_rcb_ptr % TG3_RX_RCB_RING_SIZE(tp);
                        continue;
                }
                else {
                        /* other case, do nothing */
                        rx_rcb_ptr++;
                        sw_idx =3D rx_rcb_ptr % TG3_RX_RCB_RING_SIZE(tp);
                        continue;
                }

                /* get the length of packet */
                len =3D ((desc->idx_len & RXD_LEN_MASK) >> RXD_LEN_SHIFT) -
4; /*omit crc */
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20
                pci_unmap_single(tp->pdev, dma_addr,
                                 skb_size - tp->rx_offset,
                                 PCI_DMA_FROMDEVICE);

                tp->rx_std_buffers[desc_idx].skb=3DNULL;
                skb_put(skb, len);
                //skb->protocol =3D eth_type_trans(skb, tp->dev);
                skb_pull(skb,dev->hard_header_len);

  /* process checksum */
               if ((tp->tg3_flags & TG3_FLAG_RX_CHECKSUMS) &&
                    (desc->type_flags & RXD_FLAG_TCPUDP_CSUM) &&
                    (((desc->ip_tcp_csum & RXD_TCPCSUM_MASK)
                      >> RXD_TCPCSUM_SHIFT) =3D=3D 0xffff))
                        skb->ip_summed =3D CHECKSUM_UNNECESSARY;
                else
                        skb->ip_summed =3D CHECKSUM_NONE;
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20
                /* let Click process it *
#if TG3_VLAN_TAG_USED
                if (tp->vlgrp !=3D NULL &&
                    desc->type_flags & RXD_FLAG_VLAN) {
                        tg3_vlan_rx(tp, skb,
                                    desc->err_vlan & RXD_VLAN_MASK);
                } else
#endif
                        netif_receive_skb(skb, skb->protocol, 0);
                */
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20
                if (received =3D=3D 0) {
                        skb_head =3D skb;
                        skb_last =3D skb;
                        skb_last->next =3D NULL;
                } else {
                        skb_last->next =3D skb;
                        skb->next =3D NULL;
                        skb_last =3D skb;
                }
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20
                tp->dev->last_rx =3D jiffies;
                received++;
                budget--;
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20
                rx_rcb_ptr++;
                sw_idx =3D rx_rcb_ptr % TG3_RX_RCB_RING_SIZE(tp);
        }
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20
        /* ACK the status ring. */
        if(tp->rx_rcb_ptr!=3Drx_rcb_ptr){
                tp->rx_rcb_ptr =3D rx_rcb_ptr;
                tw32_rx_mbox(MAILBOX_RCVRET_CON_IDX_0 + TG3_64BIT_REG_LOW,(=
rx_rcb_ptr % TG3_RX_RCB_RING_SIZE(tp)));
                mmiowb();
        }
        /* Refill RX ring(s). */
=20=20=20=20=20=20=20
        if (has_jumbo) {
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20
                sw_idx =3D tp->rx_jumbo_ptr % TG3_RX_JUMBO_RING_SIZE;
                tw32_rx_mbox(MAILBOX_RCV_JUMBO_PROD_IDX + TG3_64BIT_REG_LOW,
                             sw_idx);
                mmiowb();
        }
=20=20=20=20=20=20=20=20
        *want =3D received;
        spin_unlock(&tp->lock);
        return skb_head;
}


int
tg3_rx_refill(struct net_device *dev, struct sk_buff **skbs)//, int rcb_idx)
{
        struct tg3 *tp=3Ddev->priv;
        struct tg3_rx_buffer_desc *desc;
        struct ring_info *map;
        dma_addr_t mapping;
        u16 sw_idx;
        int nfilled =3D 0, last_filled =3D -1;
        struct sk_buff *skb_list;
        u32 rcb_idx,post_idx;
        u32 rx_rcb_ptr=3Dtp->rx_rcb_ptr-1;
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20
        rmb();
        if(skbs =3D=3D 0){
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20
                return (rcb_idx-post_idx)%TG3_RX_RING_SIZE;
        }
        sw_idx=3Drx_rcb_ptr%TG3_RX_RCB_RING_SIZE(tp);
        desc=3D&tp->rx_rcb[sw_idx];
        post_idx=3Dtp->rx_std_ptr;
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20
        rcb_idx=3Ddesc->opaque&RXD_OPAQUE_INDEX_MASK;

 /* if this is not a std ring index, or the ring is full, return */
        if(((desc->opaque&RXD_OPAQUE_RING_MASK)!=3DRXD_OPAQUE_RING_STD)||((=
rcb_idx-post_idx)%TG3_RX_RING_SIZE=3D=3D0)){
                return 0;
        }
=20
        spin_lock(&tp->lock);
=20=20=20=20=20=20=20=20
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20
        map =3D &tp->rx_std_buffers[post_idx];
        skb_list =3D *skbs;
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20
        while(((rcb_idx - post_idx)%TG3_RX_RING_SIZE!=3D0)&& skb_list){
                struct sk_buff *skb =3D skb_list;
                if(map->skb!=3DNULL) {
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20
                        post_idx =3D (post_idx + 1) % TG3_RX_RING_SIZE;
                        map =3D &tp->rx_std_buffers[post_idx];
                        continue;
                }
                skb_list =3D skb_list->next;
                desc =3D &tp->rx_std[post_idx];
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20
                skb->dev =3D dev;
                mapping =3D pci_map_single(tp->pdev, skb->data,
                                 RX_PKT_BUF_SZ - tp->rx_offset,
                                 PCI_DMA_FROMDEVICE);
=20=20=20=20=20=20=20=20
                map->skb =3D skb;
                pci_unmap_addr_set(map, mapping, mapping);
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20
                desc->addr_hi =3D ((u64)mapping >> 32);
                desc->addr_lo =3D ((u64)mapping & 0xffffffff);
                last_filled =3D post_idx;
                post_idx =3D (post_idx + 1) % TG3_RX_RING_SIZE;
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20
                nfilled++;
                map =3D &tp->rx_std_buffers[post_idx];
        }
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20
        /* Return the unsed list of skb */
        *skbs =3D skb_list;
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20
        /* Refill RX ring(s). */
        //dest_idx =3D &tp->rx_std_ptr % TG3_RX_RING_SIZE;
        if(post_idx!=3Dtp->rx_std_ptr){
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20
                tp->rx_std_ptr =3D post_idx ;
                tw32_rx_mbox(MAILBOX_RCV_STD_PROD_IDX + TG3_64BIT_REG_LOW,p=
ost_idx);
                mmiowb();
        }
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20
 spin_unlock(&tp->lock);
=20=20=20=20=20=20

 return (rcb_idx-post_idx)%TG3_RX_RING_SIZE;
}
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20
static int
tg3_poll_on(struct net_device *dev)
{
        struct tg3 *tp =3D dev->priv;
        unsigned long flags;
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20
        if (!dev->polling) {
                spin_lock_irqsave(&tp->lock,flags);
                dev->polling =3D 2;
                tp->reset =3D 0;
                tg3_disable_ints(tp);
                spin_unlock_irqrestore(&tp->lock,flags);
        }
        //printk("tg3_poll_on\n");
        return 0;
}

static int
tg3_poll_off(struct net_device *dev)
{
        struct tg3 *tp =3D dev->priv;
        unsigned long flags;
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20
        printk("tg3_poll_off:begin\n");
        if (dev->polling > 0) {
                dev->polling =3D 0;
                spin_lock(&tp->lock);
                tg3_restart_ints(tp);
                spin_unlock(&tp->lock);
                //printk("tg3_poll_off\n");
        }
        printk("tg3_poll_off:end\n");
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20
        return 0;
}

static int
tg3_tx_eob(struct net_device *dev)
{
        struct tg3 *tp =3D dev->priv;
 struct tg3_hw_status *sblk =3D tp->hw_status;
=20=20=20=20=20=20=20=20
=20
 // handle link change and other phy events=20
 if (sblk->status & SD_STATUS_UPDATED) {
  spin_lock(&tp->lock);
  tw32_mailbox(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW,
        0x00000001);
  tr32(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW);
  sblk->status &=3D ~SD_STATUS_UPDATED;
  spin_unlock(&tp->lock);
 }
        if (!(tp->tg3_flags &
              (TG3_FLAG_USE_LINKCHG_REG |
               TG3_FLAG_POLL_SERDES))) {
                if (sblk->status & SD_STATUS_LINK_CHG) {
   spin_lock(&tp->lock);
                        sblk->status =3D SD_STATUS_UPDATED |
                                (sblk->status & ~SD_STATUS_LINK_CHG);
                        tg3_setup_phy(tp, 0);
   spin_unlock(&tp->lock);
                }
        }
=20
 spin_lock(&tp->tx_lock);
=20
 /* Packets are ready, update Tx producer idx local and on card. */
 tw32_tx_mbox((MAILBOX_SNDHOST_PROD_IDX_0 + TG3_64BIT_REG_LOW), tp->tx_prod=
);
     mmiowb();
 spin_unlock(&tp->tx_lock);
        return 0;
}
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20
static int
tg3_tx_start(struct net_device *dev)
{
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20
        //printk("tg3_tx_start\n");
        tg3_tx_eob(dev);
        return 0;
}

static int
tg3_tx_pqueue(struct net_device *netdev, struct sk_buff *skb)
{
        //return tg3_start_xmit(skb,netdev);
 struct tg3 *tp =3D netdev_priv(netdev);
 dma_addr_t mapping;
 unsigned int i;
 u32 len, entry, base_flags, mss;
 int would_hit_hwbug;
 unsigned long flags;

 len =3D skb_headlen(skb);

 /* No BH disabling for tx_lock here.  We are running in BH disabled
  * context and TX reclaim runs via tp->poll inside of a software
  * interrupt.  Rejoice!
  *
  * Actually, things are not so simple.  If we are to take a hw
  * IRQ here, we can deadlock, consider:
  *
  *       CPU1  CPU2
  *   tg3_start_xmit
  *   take tp->tx_lock
  *   tg3_timer
  *   take tp->lock
  *   tg3_interrupt
  *   spin on tp->lock
  *   spin on tp->tx_lock
  *
  * So we really do need to disable interrupts when taking
  * tx_lock here.
  */
 if (!spin_trylock(&tp->tx_lock)) {=20
  return NETDEV_TX_LOCKED;=20
 }=20

 /* This is a hard error, log it. */
 if (unlikely(TX_BUFFS_AVAIL(tp) <=3D (skb_shinfo(skb)->nr_frags + 1))) {
  netif_stop_queue(netdev);
  spin_unlock(&tp->tx_lock);
  printk(KERN_ERR PFX "%s: BUG! Tx Ring full when queue awake!\n",
         netdev->name);
  return NETDEV_TX_BUSY;
 }

 entry =3D tp->tx_prod;
 base_flags =3D 0;
 if (skb->ip_summed =3D=3D CHECKSUM_HW)
  base_flags |=3D TXD_FLAG_TCPUDP_CSUM;
#if TG3_TSO_SUPPORT !=3D 0
 mss =3D 0;
 if (skb->len > (tp->dev->mtu + ETH_HLEN) &&
     (mss =3D skb_shinfo(skb)->tso_size) !=3D 0) {
  int tcp_opt_len, ip_tcp_len;

  tcp_opt_len =3D ((skb->h.th->doff - 5) * 4);
  ip_tcp_len =3D (skb->nh.iph->ihl * 4) + sizeof(struct tcphdr);

  base_flags |=3D (TXD_FLAG_CPU_PRE_DMA |
          TXD_FLAG_CPU_POST_DMA);

  skb->nh.iph->check =3D 0;
  skb->nh.iph->tot_len =3D ntohs(mss + ip_tcp_len + tcp_opt_len);
  if (tp->tg3_flags2 & TG3_FLG2_HW_TSO) {
   skb->h.th->check =3D 0;
   base_flags &=3D ~TXD_FLAG_TCPUDP_CSUM;
  }
  else {
   skb->h.th->check =3D
    ~csum_tcpudp_magic(skb->nh.iph->saddr,
         skb->nh.iph->daddr,
         0, IPPROTO_TCP, 0);
  }

  if ((tp->tg3_flags2 & TG3_FLG2_HW_TSO) ||
      (GET_ASIC_REV(tp->pci_chip_rev_id) =3D=3D ASIC_REV_5705)) {
   if (tcp_opt_len || skb->nh.iph->ihl > 5) {
    int tsflags;

    tsflags =3D ((skb->nh.iph->ihl - 5) +
        (tcp_opt_len >> 2));
    mss |=3D (tsflags << 11);
   }
  } else {
   if (tcp_opt_len || skb->nh.iph->ihl > 5) {
    int tsflags;

    tsflags =3D ((skb->nh.iph->ihl - 5) +
        (tcp_opt_len >> 2));
    base_flags |=3D tsflags << 12;
   }
  }
 }
#else
 mss =3D 0;
#endif
#if TG3_VLAN_TAG_USED
 if (tp->vlgrp !=3D NULL && vlan_tx_tag_present(skb))
  base_flags |=3D (TXD_FLAG_VLAN |
          (vlan_tx_tag_get(skb) << 16));
#endif

 /* Queue skb data, a.k.a. the main skb fragment. */
 mapping =3D pci_map_single(tp->pdev, skb->data, len, PCI_DMA_TODEVICE);

 tp->tx_buffers[entry].skb =3D skb;
 pci_unmap_addr_set(&tp->tx_buffers[entry], mapping, mapping);

 would_hit_hwbug =3D 0;

 if (tg3_4g_overflow_test(mapping, len))
  would_hit_hwbug =3D entry + 1;

 tg3_set_txd(tp, entry, mapping, len, base_flags,
      (skb_shinfo(skb)->nr_frags =3D=3D 0) | (mss << 1));

 entry =3D NEXT_TX(entry);

 /* Now loop through additional data fragments, and queue them. */
 if (skb_shinfo(skb)->nr_frags > 0) {
  unsigned int i, last;

  last =3D skb_shinfo(skb)->nr_frags - 1;
  for (i =3D 0; i <=3D last; i++) {
   skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];

   len =3D frag->size;
   mapping =3D pci_map_page(tp->pdev,
            frag->page,
            frag->page_offset,
            len, PCI_DMA_TODEVICE);

   tp->tx_buffers[entry].skb =3D NULL;
   pci_unmap_addr_set(&tp->tx_buffers[entry], mapping, mapping);

   if (tg3_4g_overflow_test(mapping, len)) {
    /* Only one should match. */
    if (would_hit_hwbug)
     BUG();
    would_hit_hwbug =3D entry + 1;
   }

   if (tp->tg3_flags2 & TG3_FLG2_HW_TSO)
    tg3_set_txd(tp, entry, mapping, len,
         base_flags, (i =3D=3D last)|(mss << 1));
   else
    tg3_set_txd(tp, entry, mapping, len,
         base_flags, (i =3D=3D last));

   entry =3D NEXT_TX(entry);
  }
 }

 if (would_hit_hwbug) {
  u32 last_plus_one =3D entry;
  u32 start;
  unsigned int len =3D 0;

  would_hit_hwbug -=3D 1;
  entry =3D entry - 1 - skb_shinfo(skb)->nr_frags;
  entry &=3D (TG3_TX_RING_SIZE - 1);
  start =3D entry;
  i =3D 0;
  while (entry !=3D last_plus_one) {
   if (i =3D=3D 0)
    len =3D skb_headlen(skb);
   else
    len =3D skb_shinfo(skb)->frags[i-1].size;

   if (entry =3D=3D would_hit_hwbug)
    break;

   i++;
   entry =3D NEXT_TX(entry);

  }

  /* If the workaround fails due to memory/mapping
   * failure, silently drop this packet.
   */
  if (tigon3_4gb_hwbug_workaround(tp, skb,
      entry, len,
      last_plus_one,
      &start, mss))
   goto queue_out;

  entry =3D start;
 }


 tp->tx_prod =3D entry;
 if (TX_BUFFS_AVAIL(tp) <=3D (MAX_SKB_FRAGS + 1))
  netif_stop_queue(netdev);

queue_out:
 spin_unlock(&tp->tx_lock);

 netdev->trans_start =3D jiffies;

 return NETDEV_TX_OK;
}

static struct sk_buff *
tg3_tx_poll(struct tg3 *tp)
{
 u32 hw_idx =3D tp->hw_status->idx[0].tx_consumer;
 u32 sw_idx =3D tp->tx_cons;
        struct sk_buff *skb_head,*skb_last;

 skb_head=3Dskb_last=3D0;

 while (sw_idx !=3D hw_idx) {
  struct tx_ring_info *ri =3D &tp->tx_buffers[sw_idx];
  struct sk_buff *skb =3D ri->skb;
  int i;

  if (unlikely(skb =3D=3D NULL))
   BUG();

  pci_unmap_single(tp->pdev,
     pci_unmap_addr(ri, mapping),
     skb_headlen(skb),
     PCI_DMA_TODEVICE);

  ri->skb =3D NULL;

  sw_idx =3D NEXT_TX(sw_idx);

  for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i++) {
   if (unlikely(sw_idx =3D=3D hw_idx))
    BUG();

   ri =3D &tp->tx_buffers[sw_idx];
   if (unlikely(ri->skb !=3D NULL))
    BUG();

   pci_unmap_page(tp->pdev,
           pci_unmap_addr(ri, mapping),
           skb_shinfo(skb)->frags[i].size,
           PCI_DMA_TODEVICE);

   sw_idx =3D NEXT_TX(sw_idx);
  }
=20=20=20=20=20
                if (skb_head =3D=3D 0) {
                        skb_head =3D skb;
                        skb_last =3D skb;
                        skb_last->next =3D NULL;
                } else {
                        skb_last->next =3D skb;
                        skb->next =3D NULL;
                        skb_last =3D skb;
                }
=20=20=20=20=20=20=20=20
//  dev_kfree_skb_irq(skb);
 }

 tp->tx_cons =3D sw_idx;

 if (netif_queue_stopped(tp->dev) &&
     (TX_BUFFS_AVAIL(tp) > TG3_TX_WAKEUP_THRESH))
  netif_wake_queue(tp->dev);
 return skb_head;
}


static struct sk_buff *
tg3_tx_clean(struct net_device *netdev)
{
        struct tg3 *tp =3D netdev_priv(netdev);
        struct sk_buff *skb_head,*skb_last;
 u32 hw_idx =3D tp->hw_status->idx[0].tx_consumer;
 u32 sw_idx =3D tp->tx_cons;

 skb_head=3Dskb_last=3D0;
 rmb();=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20
                spin_lock(&tp->lock);

       if(tp->hw_status->idx[0].tx_consumer =3D=3D tp->tx_cons){

  spin_unlock(&tp->lock);
  return NULL;
        }

 spin_lock(&tp->tx_lock);
=20=20=20=20=20=20=20=20
//        skb_head =3D tg3_tx_poll(tp);


 while (sw_idx !=3D hw_idx) {
  struct tx_ring_info *ri =3D &tp->tx_buffers[sw_idx];
  struct sk_buff *skb =3D ri->skb;
  int i;

  if (unlikely(skb =3D=3D NULL))
   BUG();

  pci_unmap_single(tp->pdev,
     pci_unmap_addr(ri, mapping),
     skb_headlen(skb),
     PCI_DMA_TODEVICE);

  ri->skb =3D NULL;

  sw_idx =3D NEXT_TX(sw_idx);

  for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i++) {
   if (unlikely(sw_idx =3D=3D hw_idx))
    BUG();

   ri =3D &tp->tx_buffers[sw_idx];
   if (unlikely(ri->skb !=3D NULL))
    BUG();

   pci_unmap_page(tp->pdev,
           pci_unmap_addr(ri, mapping),
           skb_shinfo(skb)->frags[i].size,
           PCI_DMA_TODEVICE);

   sw_idx =3D NEXT_TX(sw_idx);
  }
=20=20=20=20=20
                if (skb_head =3D=3D 0) {
                        skb_head =3D skb;
                        skb_last =3D skb;
                        skb_last->next =3D NULL;
                } else {
                        skb_last->next =3D skb;
                        skb->next =3D NULL;
                        skb_last =3D skb;
                }
=20=20=20=20=20=20=20=20
//  dev_kfree_skb_irq(skb);
 }

 tp->tx_cons =3D sw_idx;

 if (netif_queue_stopped(tp->dev) &&
     (TX_BUFFS_AVAIL(tp) > TG3_TX_WAKEUP_THRESH))
  netif_wake_queue(tp->dev);
 //return skb_head;
/* the end of tx_poll function */
        spin_unlock(&tp->tx_lock);
        spin_unlock(&tp->lock);
        return skb_head;
}

=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20
