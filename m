From: Willem de Bruijn <willemb@google.com>
Subject: Re: [RFC PATCH v2 2/2] net: ixgbe: implement af_packet direct queue mappings
Date: Tue, 13 Jan 2015 13:58:47 -0500
Message-ID: <CA+FuTSdP8xJvuWutvcZ7Dk5_nDYtP7WYwdXfQj__BA-FHP0vxA@mail.gmail.com>
References: <20150113043509.29985.33515.stgit@nitbit.x32> <20150113043542.29985.15658.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
	"Zhou, Danny" <danny.zhou@intel.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	brouer@redhat.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f171.google.com ([209.85.216.171]:51596 "EHLO
	mail-qc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751975AbbAMS7S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 13:59:18 -0500
Received: by mail-qc0-f171.google.com with SMTP id r5so3791858qcx.2
        for <netdev@vger.kernel.org>; Tue, 13 Jan 2015 10:59:17 -0800 (PST)
In-Reply-To: <20150113043542.29985.15658.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 12, 2015 at 11:35 PM, John Fastabend
<john.fastabend@gmail.com> wrote:
> This allows driver queues to be split off and mapped into user
> space using af_packet.
>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe.h         |   17 +
>  drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |   23 +
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |  407 ++++++++++++++++++++++
>  drivers/net/ethernet/intel/ixgbe/ixgbe_type.h    |    1
>  4 files changed, 440 insertions(+), 8 deletions(-)
>
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
> index 38fc64c..aa4960e 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
> @@ -204,6 +204,20 @@ struct ixgbe_tx_queue_stats {
>         u64 tx_done_old;
>  };
>
> +#define MAX_USER_DMA_REGIONS_PER_SOCKET  16
> +
> +struct ixgbe_user_dma_region {
> +       dma_addr_t dma_region_iova;
> +       unsigned long dma_region_size;
> +       int direction;
> +};
> +
> +struct ixgbe_user_queue_info {
> +       struct sock *sk_handle;
> +       struct ixgbe_user_dma_region regions[MAX_USER_DMA_REGIONS_PER_SOCKET];
> +       int num_of_regions;
> +};
> +
>  struct ixgbe_rx_queue_stats {
>         u64 rsc_count;
>         u64 rsc_flush;
> @@ -673,6 +687,9 @@ struct ixgbe_adapter {
>
>         struct ixgbe_q_vector *q_vector[MAX_Q_VECTORS];
>
> +       /* Direct User Space Queues */
> +       struct ixgbe_user_queue_info user_queue_info[MAX_RX_QUEUES];
> +
>         /* DCB parameters */
>         struct ieee_pfc *ixgbe_ieee_pfc;
>         struct ieee_ets *ixgbe_ieee_ets;
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
> index e5be0dd..f180a58 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
> @@ -2598,12 +2598,17 @@ static int ixgbe_add_ethtool_fdir_entry(struct ixgbe_adapter *adapter,
>         if (!(adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE))
>                 return -EOPNOTSUPP;
>
> +       if (fsp->ring_cookie > MAX_RX_QUEUES)
> +               return -EINVAL;
> +
>         /*
>          * Don't allow programming if the action is a queue greater than
> -        * the number of online Rx queues.
> +        * the number of online Rx queues unless it is a user space
> +        * queue.
>          */
>         if ((fsp->ring_cookie != RX_CLS_FLOW_DISC) &&
> -           (fsp->ring_cookie >= adapter->num_rx_queues))
> +           (fsp->ring_cookie >= adapter->num_rx_queues) &&
> +           !adapter->user_queue_info[fsp->ring_cookie].sk_handle)
>                 return -EINVAL;
>
>         /* Don't allow indexes to exist outside of available space */
> @@ -2680,12 +2685,18 @@ static int ixgbe_add_ethtool_fdir_entry(struct ixgbe_adapter *adapter,
>         /* apply mask and compute/store hash */
>         ixgbe_atr_compute_perfect_hash_82599(&input->filter, &mask);
>
> +       /* Set input action to reg_idx for driver owned queues otherwise
> +        * use the absolute index for user space queues.
> +        */
> +       if (fsp->ring_cookie < adapter->num_rx_queues &&
> +           fsp->ring_cookie != IXGBE_FDIR_DROP_QUEUE)
> +               input->action = adapter->rx_ring[input->action]->reg_idx;
> +
>         /* program filters to filter memory */
>         err = ixgbe_fdir_write_perfect_filter_82599(hw,
> -                               &input->filter, input->sw_idx,
> -                               (input->action == IXGBE_FDIR_DROP_QUEUE) ?
> -                               IXGBE_FDIR_DROP_QUEUE :
> -                               adapter->rx_ring[input->action]->reg_idx);
> +                                                   &input->filter,
> +                                                   input->sw_idx,
> +                                                   input->action);
>         if (err)
>                 goto err_out_w_lock;
>
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> index 2ed2c7d..be5bde86 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> @@ -50,6 +50,9 @@
>  #include <linux/if_bridge.h>
>  #include <linux/prefetch.h>
>  #include <scsi/fc/fc_fcoe.h>
> +#include <linux/mm.h>
> +#include <linux/if_packet.h>
> +#include <linux/iommu.h>
>
>  #ifdef CONFIG_OF
>  #include <linux/of_net.h>
> @@ -80,6 +83,12 @@ const char ixgbe_driver_version[] = DRV_VERSION;
>  static const char ixgbe_copyright[] =
>                                 "Copyright (c) 1999-2014 Intel Corporation.";
>
> +static unsigned int *dummy_page_buf;
> +
> +#ifndef CONFIG_DMA_MEMORY_PROTECTION
> +#define CONFIG_DMA_MEMORY_PROTECTION
> +#endif
> +
>  static const struct ixgbe_info *ixgbe_info_tbl[] = {
>         [board_82598]           = &ixgbe_82598_info,
>         [board_82599]           = &ixgbe_82599_info,
> @@ -167,6 +176,76 @@ MODULE_DESCRIPTION("Intel(R) 10 Gigabit PCI Express Network Driver");
>  MODULE_LICENSE("GPL");
>  MODULE_VERSION(DRV_VERSION);
>
> +enum ixgbe_legacy_rx_enum {
> +       IXGBE_LEGACY_RX_FIELD_PKT_ADDR = 0,     /* Packet buffer address */
> +       IXGBE_LEGACY_RX_FIELD_LENGTH,           /* Packet length */
> +       IXGBE_LEGACY_RX_FIELD_CSUM,             /* Fragment checksum */
> +       IXGBE_LEGACY_RX_FIELD_STATUS,           /* Descriptors status */
> +       IXGBE_LEGACY_RX_FIELD_ERRORS,           /* Receive errors */
> +       IXGBE_LEGACY_RX_FIELD_VLAN,             /* VLAN tag */
> +};
> +
> +enum ixgbe_legacy_tx_enum {
> +       IXGBE_LEGACY_TX_FIELD_PKT_ADDR = 0,     /* Packet buffer address */
> +       IXGBE_LEGACY_TX_FIELD_LENGTH,           /* Packet length */
> +       IXGBE_LEGACY_TX_FIELD_CSO,              /* Checksum offset*/
> +       IXGBE_LEGACY_TX_FIELD_CMD,              /* Descriptor control */
> +       IXGBE_LEGACY_TX_FIELD_STATUS,           /* Descriptor status */
> +       IXGBE_LEGACY_TX_FIELD_RSVD,             /* Reserved */
> +       IXGBE_LEGACY_TX_FIELD_CSS,              /* Checksum start */
> +       IXGBE_LEGACY_TX_FIELD_VLAN_TAG,         /* VLAN tag */
> +};
> +
> +/* IXGBE Receive Descriptor - Legacy */
> +static const struct tpacket_nic_desc_fld ixgbe_legacy_rx_desc[] = {
> +       /* Packet buffer address */
> +       {PACKET_NIC_DESC_FIELD(IXGBE_LEGACY_RX_FIELD_PKT_ADDR,
> +                               0,  64, 64,  BO_NATIVE)},
> +       /* Packet length */
> +       {PACKET_NIC_DESC_FIELD(IXGBE_LEGACY_RX_FIELD_LENGTH,
> +                               64, 16, 8,  BO_NATIVE)},
> +       /* Fragment checksum */
> +       {PACKET_NIC_DESC_FIELD(IXGBE_LEGACY_RX_FIELD_CSUM,
> +                               80, 16, 8,  BO_NATIVE)},
> +       /* Descriptors status */
> +       {PACKET_NIC_DESC_FIELD(IXGBE_LEGACY_RX_FIELD_STATUS,
> +                               96, 8, 8,  BO_NATIVE)},
> +       /* Receive errors */
> +       {PACKET_NIC_DESC_FIELD(IXGBE_LEGACY_RX_FIELD_ERRORS,
> +                               104, 8, 8,  BO_NATIVE)},
> +       /* VLAN tag */
> +       {PACKET_NIC_DESC_FIELD(IXGBE_LEGACY_RX_FIELD_VLAN,
> +                               112, 16, 8,  BO_NATIVE)},
> +};
> +
> +/* IXGBE Transmit Descriptor - Legacy */
> +static const struct tpacket_nic_desc_fld ixgbe_legacy_tx_desc[] = {
> +       /* Packet buffer address */
> +       {PACKET_NIC_DESC_FIELD(IXGBE_LEGACY_TX_FIELD_PKT_ADDR,
> +                               0,   64, 64,  BO_NATIVE)},
> +       /* Data buffer length */
> +       {PACKET_NIC_DESC_FIELD(IXGBE_LEGACY_TX_FIELD_LENGTH,
> +                               64,  16, 8,  BO_NATIVE)},
> +       /* Checksum offset */
> +       {PACKET_NIC_DESC_FIELD(IXGBE_LEGACY_TX_FIELD_CSO,
> +                               80,  8, 8,  BO_NATIVE)},
> +       /* Command byte */
> +       {PACKET_NIC_DESC_FIELD(IXGBE_LEGACY_TX_FIELD_CMD,
> +                               88,  8, 8,  BO_NATIVE)},
> +       /* Transmitted status */
> +       {PACKET_NIC_DESC_FIELD(IXGBE_LEGACY_TX_FIELD_STATUS,
> +                               96,  4, 1,  BO_NATIVE)},
> +       /* Reserved */
> +       {PACKET_NIC_DESC_FIELD(IXGBE_LEGACY_TX_FIELD_RSVD,
> +                               100, 4, 1,  BO_NATIVE)},
> +       /* Checksum start */
> +       {PACKET_NIC_DESC_FIELD(IXGBE_LEGACY_TX_FIELD_CSS,
> +                               104, 8, 8,  BO_NATIVE)},
> +       /* VLAN tag */
> +       {PACKET_NIC_DESC_FIELD(IXGBE_LEGACY_TX_FIELD_VLAN_TAG,
> +                               112, 16, 8,  BO_NATIVE)},
> +};
> +
>  static bool ixgbe_check_cfg_remove(struct ixgbe_hw *hw, struct pci_dev *pdev);
>
>  static int ixgbe_read_pci_cfg_word_parent(struct ixgbe_adapter *adapter,
> @@ -3137,6 +3216,17 @@ static void ixgbe_enable_rx_drop(struct ixgbe_adapter *adapter,
>         IXGBE_WRITE_REG(hw, IXGBE_SRRCTL(reg_idx), srrctl);
>  }
>
> +static bool ixgbe_have_user_queues(struct ixgbe_adapter *adapter)
> +{
> +       int i;
> +
> +       for (i = 0; i < MAX_RX_QUEUES; i++) {
> +               if (adapter->user_queue_info[i].sk_handle)
> +                       return true;
> +       }
> +       return false;
> +}
> +
>  static void ixgbe_disable_rx_drop(struct ixgbe_adapter *adapter,
>                                   struct ixgbe_ring *ring)
>  {
> @@ -3171,7 +3261,8 @@ static void ixgbe_set_rx_drop_en(struct ixgbe_adapter *adapter)
>          *  and performance reasons.
>          */
>         if (adapter->num_vfs || (adapter->num_rx_queues > 1 &&
> -           !(adapter->hw.fc.current_mode & ixgbe_fc_tx_pause) && !pfc_en)) {
> +           !(adapter->hw.fc.current_mode & ixgbe_fc_tx_pause) && !pfc_en) ||
> +           ixgbe_have_user_queues(adapter)) {
>                 for (i = 0; i < adapter->num_rx_queues; i++)
>                         ixgbe_enable_rx_drop(adapter, adapter->rx_ring[i]);
>         } else {
> @@ -7938,6 +8029,306 @@ static void ixgbe_fwd_del(struct net_device *pdev, void *priv)
>         kfree(fwd_adapter);
>  }
>
> +static int ixgbe_ndo_split_queue_pairs(struct net_device *dev,
> +                                      unsigned int start_from,
> +                                      unsigned int qpairs_num,
> +                                      struct sock *sk)
> +{
> +       struct ixgbe_adapter *adapter = netdev_priv(dev);
> +       unsigned int qpair_index;
> +
> +       /* allocate whatever available qpairs */
> +       if (start_from == -1) {

When is this wildcard case used? If the nic is configured to send
specific traffic to a specific rxqueue, then that queue has to be
mapped. When is an arbitrary queue acceptable?

> +               unsigned int count = 0;
> +
> +               for (qpair_index = adapter->num_rx_queues;
> +                    qpair_index < MAX_RX_QUEUES;
> +                    qpair_index++) {
> +                       if (!adapter->user_queue_info[qpair_index].sk_handle) {
> +                               count++;
> +                               if (count == qpairs_num) {
> +                                       start_from = qpair_index - count + 1;
> +                                       break;
> +                               }
> +                       } else {
> +                               count = 0;
> +                       }
> +               }
> +       }
> +
> +       /* otherwise the caller specified exact queues */
> +       if ((start_from > MAX_TX_QUEUES) ||
> +           (start_from > MAX_RX_QUEUES) ||
> +           (start_from + qpairs_num > MAX_TX_QUEUES) ||
> +           (start_from + qpairs_num > MAX_RX_QUEUES))
> +               return -EINVAL;
> +
> +       /* If the qpairs are being used by the driver do not let user space
> +        * consume the queues. Also if the queue has already been allocated
> +        * to a socket do fail the request.
> +        */
> +       for (qpair_index = start_from;
> +            qpair_index < start_from + qpairs_num;
> +            qpair_index++) {
> +               if ((qpair_index < adapter->num_tx_queues) ||
> +                   (qpair_index < adapter->num_rx_queues))
> +                       return -EINVAL;

is there a similar check to ensure that the driver does not increase its
number of queues with ethtool -X and subsumes user queues?

> +
> +               if (adapter->user_queue_info[qpair_index].sk_handle)
> +                       return -EBUSY;
> +       }
> +
> +       /* remember the sk handle for each queue pair */
> +       for (qpair_index = start_from;
> +            qpair_index < start_from + qpairs_num;
> +            qpair_index++) {
> +               adapter->user_queue_info[qpair_index].sk_handle = sk;
> +               adapter->user_queue_info[qpair_index].num_of_regions = 0;
> +       }
> +
> +       return 0;
> +}
> +
> +static int ixgbe_ndo_get_split_queue_pairs(struct net_device *dev,
> +                                          unsigned int *start_from,
> +                                          unsigned int *qpairs_num,
> +                                          struct sock *sk)
> +{
> +       struct ixgbe_adapter *adapter = netdev_priv(dev);
> +       unsigned int qpair_index;
> +       *qpairs_num = 0;
> +
> +       for (qpair_index = adapter->num_tx_queues;
> +            qpair_index < MAX_RX_QUEUES;
> +            qpair_index++) {
> +               if (adapter->user_queue_info[qpair_index].sk_handle == sk) {
> +                       if (*qpairs_num == 0)
> +                               *start_from = qpair_index;
> +                       *qpairs_num = *qpairs_num + 1;
> +               }
> +       }
> +
> +       return 0;
> +}
> +
> +static int ixgbe_ndo_return_queue_pairs(struct net_device *dev, struct sock *sk)
> +{
> +       struct ixgbe_adapter *adapter = netdev_priv(dev);
> +       struct ixgbe_user_queue_info *info;
> +       unsigned int qpair_index;
> +
> +       for (qpair_index = adapter->num_tx_queues;
> +            qpair_index < MAX_RX_QUEUES;
> +            qpair_index++) {
> +               info = &adapter->user_queue_info[qpair_index];
> +
> +               if (info->sk_handle == sk) {
> +                       info->sk_handle = NULL;
> +                       info->num_of_regions = 0;
> +               }
> +       }
> +
> +       return 0;
> +}
> +
> +/* Rx descriptor starts from 0x1000 and Tx descriptor starts from 0x6000
> + * both the TX and RX descriptors use 4K pages.
> + */
> +#define RX_DESC_ADDR_OFFSET            0x1000
> +#define TX_DESC_ADDR_OFFSET            0x6000
> +#define PAGE_SIZE_4K                   4096
> +
> +static int
> +ixgbe_ndo_qpair_map_region(struct net_device *dev,
> +                          struct tpacket_dev_qpair_map_region_info *info)
> +{
> +       struct ixgbe_adapter *adapter = netdev_priv(dev);
> +
> +       /* no need to map systme memory to userspace for ixgbe */
> +       info->tp_dev_sysm_sz = 0;
> +       info->tp_num_sysm_map_regions = 0;
> +
> +       info->tp_dev_bar_sz = pci_resource_len(adapter->pdev, 0);
> +       info->tp_num_map_regions = 2;
> +
> +       info->tp_regions[0].page_offset = RX_DESC_ADDR_OFFSET;
> +       info->tp_regions[0].page_sz = PAGE_SIZE;
> +       info->tp_regions[0].page_cnt = 1;
> +       info->tp_regions[1].page_offset = TX_DESC_ADDR_OFFSET;
> +       info->tp_regions[1].page_sz = PAGE_SIZE;
> +       info->tp_regions[1].page_cnt = 1;
> +
> +       return 0;
> +}
> +
> +static int ixgbe_ndo_get_device_desc_info(struct net_device *dev,
> +                                         struct tpacket_dev_info *dev_info)
> +{
> +       struct ixgbe_adapter *adapter = netdev_priv(dev);
> +       int max_queues;
> +       int i;
> +       __u8 flds_rx = sizeof(ixgbe_legacy_rx_desc) /
> +                      sizeof(struct tpacket_nic_desc_fld);
> +       __u8 flds_tx = sizeof(ixgbe_legacy_tx_desc) /
> +                      sizeof(struct tpacket_nic_desc_fld);
> +
> +       max_queues = max(adapter->num_rx_queues, adapter->num_tx_queues);
> +
> +       dev_info->tp_device_id = adapter->hw.device_id;
> +       dev_info->tp_vendor_id = adapter->hw.vendor_id;
> +       dev_info->tp_subsystem_device_id = adapter->hw.subsystem_device_id;
> +       dev_info->tp_subsystem_vendor_id = adapter->hw.subsystem_vendor_id;
> +       dev_info->tp_revision_id = adapter->hw.revision_id;
> +       dev_info->tp_numa_node = dev_to_node(&dev->dev);
> +
> +       dev_info->tp_num_total_qpairs = min(MAX_RX_QUEUES, MAX_TX_QUEUES);
> +       dev_info->tp_num_inuse_qpairs = max_queues;
> +
> +       dev_info->tp_num_rx_desc_fmt = 1;
> +       dev_info->tp_num_tx_desc_fmt = 1;
> +
> +       dev_info->tp_rx_dexpr[0].version = 1;
> +       dev_info->tp_rx_dexpr[0].size = sizeof(union ixgbe_adv_rx_desc);
> +       dev_info->tp_rx_dexpr[0].byte_order = BO_NATIVE;
> +       dev_info->tp_rx_dexpr[0].num_of_fld = flds_rx;
> +       for (i = 0; i < dev_info->tp_rx_dexpr[0].num_of_fld; i++)
> +               memcpy(&dev_info->tp_rx_dexpr[0].fields[i],
> +                      &ixgbe_legacy_rx_desc[i],
> +                      sizeof(struct tpacket_nic_desc_fld));
> +
> +       dev_info->tp_tx_dexpr[0].version = 1;
> +       dev_info->tp_tx_dexpr[0].size = sizeof(union ixgbe_adv_tx_desc);
> +       dev_info->tp_tx_dexpr[0].byte_order = BO_NATIVE;
> +       dev_info->tp_tx_dexpr[0].num_of_fld = flds_tx;
> +       for (i = 0; i < dev_info->tp_rx_dexpr[0].num_of_fld; i++)
> +               memcpy(&dev_info->tp_tx_dexpr[0].fields[i],
> +                      &ixgbe_legacy_tx_desc[i],
> +                      sizeof(struct tpacket_nic_desc_fld));
> +
> +       return 0;
> +}
> +
> +static int
> +ixgbe_ndo_qpair_page_map(struct vm_area_struct *vma, struct net_device *dev)
> +{
> +       struct ixgbe_adapter *adapter = netdev_priv(dev);
> +       phys_addr_t phy_addr = pci_resource_start(adapter->pdev, 0);
> +       unsigned long pfn_rx = (phy_addr + RX_DESC_ADDR_OFFSET) >> PAGE_SHIFT;
> +       unsigned long pfn_tx = (phy_addr + TX_DESC_ADDR_OFFSET) >> PAGE_SHIFT;
> +       unsigned long dummy_page_phy;
> +       pgprot_t pre_vm_page_prot;
> +       unsigned long start;
> +       unsigned int i;
> +       int err;
> +
> +       if (!dummy_page_buf) {
> +               dummy_page_buf = kzalloc(PAGE_SIZE_4K, GFP_KERNEL);
> +               if (!dummy_page_buf)
> +                       return -ENOMEM;
> +
> +               for (i = 0; i < PAGE_SIZE_4K / sizeof(unsigned int); i++)
> +                       dummy_page_buf[i] = 0xdeadbeef;
> +       }
> +
> +       dummy_page_phy = virt_to_phys(dummy_page_buf);
> +       pre_vm_page_prot = vma->vm_page_prot;
> +       vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
> +
> +       /* assume the vm_start is 4K aligned address */
> +       for (start = vma->vm_start;
> +            start < vma->vm_end;
> +            start += PAGE_SIZE_4K) {
> +               if (start == vma->vm_start + RX_DESC_ADDR_OFFSET) {
> +                       err = remap_pfn_range(vma, start, pfn_rx, PAGE_SIZE_4K,
> +                                             vma->vm_page_prot);
> +                       if (err)
> +                               return -EAGAIN;
> +               } else if (start == vma->vm_start + TX_DESC_ADDR_OFFSET) {
> +                       err = remap_pfn_range(vma, start, pfn_tx, PAGE_SIZE_4K,
> +                                             vma->vm_page_prot);
> +                       if (err)
> +                               return -EAGAIN;
> +               } else {
> +                       unsigned long addr = dummy_page_phy > PAGE_SHIFT;
> +
> +                       err = remap_pfn_range(vma, start, addr, PAGE_SIZE_4K,
> +                                             pre_vm_page_prot);
> +                       if (err)
> +                               return -EAGAIN;
> +               }
> +       }
> +       return 0;
> +}
> +
> +static int
> +ixgbe_ndo_val_dma_mem_region_map(struct net_device *dev,
> +                                struct tpacket_dma_mem_region *region,
> +                                struct sock *sk)
> +{
> +       struct ixgbe_adapter *adapter = netdev_priv(dev);
> +       unsigned int qpair_index, i;
> +       struct ixgbe_user_queue_info *info;
> +
> +#ifdef CONFIG_DMA_MEMORY_PROTECTION
> +       /* IOVA not equal to physical address means IOMMU takes effect */
> +       if (region->phys_addr == region->iova)
> +               return -EFAULT;
> +#endif
> +
> +       for (qpair_index = adapter->num_tx_queues;
> +            qpair_index < MAX_RX_QUEUES;
> +            qpair_index++) {
> +               info = &adapter->user_queue_info[qpair_index];
> +               i = info->num_of_regions;
> +
> +               if (info->sk_handle != sk)
> +                       continue;
> +
> +               if (info->num_of_regions >= MAX_USER_DMA_REGIONS_PER_SOCKET)
> +                       return -EFAULT;
> +
> +               info->regions[i].dma_region_size = region->size;
> +               info->regions[i].direction = region->direction;
> +               info->regions[i].dma_region_iova = region->iova;
> +               info->num_of_regions++;
> +       }
> +
> +       return 0;
> +}
> +
> +static int
> +ixgbe_get_dma_region_info(struct net_device *dev,
> +                         struct tpacket_dma_mem_region *region,
> +                         struct sock *sk)
> +{
> +       struct ixgbe_adapter *adapter = netdev_priv(dev);
> +       struct ixgbe_user_queue_info *info;
> +       unsigned int qpair_index;
> +
> +       for (qpair_index = adapter->num_tx_queues;
> +            qpair_index < MAX_RX_QUEUES;
> +            qpair_index++) {
> +               int i;
> +
> +               info = &adapter->user_queue_info[qpair_index];
> +               if (info->sk_handle != sk)
> +                       continue;
> +
> +               for (i = 0; i <= info->num_of_regions; i++) {
> +                       struct ixgbe_user_dma_region *r;
> +
> +                       r = &info->regions[i];
> +                       if ((r->dma_region_size == region->size) &&
> +                           (r->direction == region->direction)) {
> +                               region->iova = r->dma_region_iova;
> +                               return 0;
> +                       }
> +               }
> +       }
> +
> +       return -1;
> +}
> +
>  static const struct net_device_ops ixgbe_netdev_ops = {
>         .ndo_open               = ixgbe_open,
>         .ndo_stop               = ixgbe_close,
> @@ -7982,6 +8373,15 @@ static const struct net_device_ops ixgbe_netdev_ops = {
>         .ndo_bridge_getlink     = ixgbe_ndo_bridge_getlink,
>         .ndo_dfwd_add_station   = ixgbe_fwd_add,
>         .ndo_dfwd_del_station   = ixgbe_fwd_del,
> +
> +       .ndo_split_queue_pairs  = ixgbe_ndo_split_queue_pairs,
> +       .ndo_get_split_queue_pairs = ixgbe_ndo_get_split_queue_pairs,
> +       .ndo_return_queue_pairs    = ixgbe_ndo_return_queue_pairs,
> +       .ndo_get_device_desc_info  = ixgbe_ndo_get_device_desc_info,
> +       .ndo_direct_qpair_page_map = ixgbe_ndo_qpair_page_map,
> +       .ndo_get_dma_region_info   = ixgbe_get_dma_region_info,
> +       .ndo_get_device_qpair_map_region_info = ixgbe_ndo_qpair_map_region,
> +       .ndo_validate_dma_mem_region_map = ixgbe_ndo_val_dma_mem_region_map,
>  };
>
>  /**
> @@ -8203,7 +8603,9 @@ static int ixgbe_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
>         hw->back = adapter;
>         adapter->msg_enable = netif_msg_init(debug, DEFAULT_MSG_ENABLE);
>
> -       hw->hw_addr = ioremap(pci_resource_start(pdev, 0),
> +       hw->pci_hw_addr = pci_resource_start(pdev, 0);
> +
> +       hw->hw_addr = ioremap(hw->pci_hw_addr,
>                               pci_resource_len(pdev, 0));
>         adapter->io_addr = hw->hw_addr;
>         if (!hw->hw_addr) {
> @@ -8875,6 +9277,7 @@ module_init(ixgbe_init_module);
>   **/
>  static void __exit ixgbe_exit_module(void)
>  {
> +       kfree(dummy_page_buf);
>  #ifdef CONFIG_IXGBE_DCA
>         dca_unregister_notify(&dca_notifier);
>  #endif
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
> index d101b25..4034d31 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
> @@ -3180,6 +3180,7 @@ struct ixgbe_mbx_info {
>
>  struct ixgbe_hw {
>         u8 __iomem                      *hw_addr;
> +       phys_addr_t                     pci_hw_addr;
>         void                            *back;
>         struct ixgbe_mac_info           mac;
>         struct ixgbe_addr_filter_info   addr_ctrl;
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
