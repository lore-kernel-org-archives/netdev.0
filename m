From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: Re: [PATCH 1/6] netxen: cleanup unused variables/functions
Date: Tue, 22 Jul 2008 14:53:29 -0700
Message-ID: <488656D9.1060006@netxen.com>
References: <> <1215890720-29744-2-git-send-email-dhananjay@netxen.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "jeff@garzik.org" <jeff@garzik.org>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.netxen.com ([66.126.254.36]:32636 "EHLO nxexch.unminc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753019AbYGVVxe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jul 2008 17:53:34 -0400
In-Reply-To: <1215890720-29744-2-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Another marker to invalidate this 6 patch series. This is superseded by 
11 patch series prefixed RESENDv2.

Thanks,
-Dhananjay

Dhananjay Phadke wrote:
> o Reduce access to global arrays in data path.
> o Remove duplicate/unused variables, unecessary alignment constraints.
> o Use correct pci_dev instead of fallback device for consistent
>   allocations.
> o Disable ethtool set_eeprom functionality for now, it was only used
>   for flashing firmware.
>
> Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
> ---
>  drivers/net/netxen/netxen_nic.h          |   19 +--
>  drivers/net/netxen/netxen_nic_ethtool.c  |    5 +-
>  drivers/net/netxen/netxen_nic_hw.c       |  270 +++++++-----------------------
>  drivers/net/netxen/netxen_nic_init.c     |   88 +++-------
>  drivers/net/netxen/netxen_nic_main.c     |   74 ++-------
>  drivers/net/netxen/netxen_nic_phan_reg.h |   17 +--
>  6 files changed, 113 insertions(+), 360 deletions(-)
>
> diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
> index da4c4fb..149bb60 100644
> --- a/drivers/net/netxen/netxen_nic.h
> +++ b/drivers/net/netxen/netxen_nic.h
> @@ -132,7 +132,6 @@
>  #define RX_JUMBO_DMA_MAP_LEN   \
>         (MAX_RX_JUMBO_BUFFER_LENGTH - 2)
>  #define RX_LRO_DMA_MAP_LEN             (MAX_RX_LRO_BUFFER_LENGTH - 2)
> -#define NETXEN_ROM_ROUNDUP             0x80000000ULL
>
>  /*
>   * Maximum number of ring contexts
> @@ -219,8 +218,6 @@ enum {
>  #define MPORT_MULTI_FUNCTION_MODE 0x2222
>
>  #include "netxen_nic_phan_reg.h"
> -extern unsigned long long netxen_dma_mask;
> -extern unsigned long last_schedule_time;
>
>  /*
>   * NetXen host-peg signal message structure
> @@ -765,7 +762,6 @@ struct netxen_rx_buffer {
>   * contains interrupt info as well shared hardware info.
>   */
>  struct netxen_hardware_context {
> -       struct pci_dev *pdev;
>         void __iomem *pci_base0;
>         void __iomem *pci_base1;
>         void __iomem *pci_base2;
> @@ -781,7 +777,6 @@ struct netxen_hardware_context {
>         u32 qg_linksup;
>         /* Address of cmd ring in Phantom */
>         struct cmd_desc_type0 *cmd_desc_head;
> -       struct pci_dev *cmd_desc_pdev;
>         dma_addr_t cmd_desc_phys_addr;
>         struct netxen_adapter *adapter;
>         int pci_func;
> @@ -816,9 +811,8 @@ struct netxen_adapter_stats {
>  struct netxen_rcv_desc_ctx {
>         u32 flags;
>         u32 producer;
> -       u32 rcv_pending;        /* Num of bufs posted in phantom */
>         dma_addr_t phys_addr;
> -       struct pci_dev *phys_pdev;
> +       u32 crb_rcv_producer;   /* reg offset */
>         struct rcv_desc *desc_head;     /* address of rx ring in Phantom */
>         u32 max_rx_desc_count;
>         u32 dma_size;
> @@ -835,10 +829,9 @@ struct netxen_rcv_desc_ctx {
>   */
>  struct netxen_recv_context {
>         struct netxen_rcv_desc_ctx rcv_desc[NUM_RCV_DESC_RINGS];
> -       u32 status_rx_producer;
>         u32 status_rx_consumer;
> +       u32 crb_sts_consumer;   /* reg offset */
>         dma_addr_t rcv_status_desc_phys_addr;
> -       struct pci_dev *rcv_status_desc_pdev;
>         struct status_desc *rcv_status_desc_head;
>  };
>
> @@ -854,7 +847,6 @@ struct netxen_dummy_dma {
>  struct netxen_adapter {
>         struct netxen_hardware_context ahw;
>
> -       struct netxen_adapter *master;
>         struct net_device *netdev;
>         struct pci_dev *pdev;
>         struct napi_struct napi;
> @@ -873,6 +865,8 @@ struct netxen_adapter {
>         u32 cmd_producer;
>         __le32 *cmd_consumer;
>         u32 last_cmd_consumer;
> +       u32 crb_addr_cmd_producer;
> +       u32 crb_addr_cmd_consumer;
>
>         u32 max_tx_desc_count;
>         u32 max_rx_desc_count;
> @@ -886,14 +880,12 @@ struct netxen_adapter {
>
>         struct netxen_adapter_stats stats;
>
> -       u16 portno;
>         u16 link_speed;
>         u16 link_duplex;
>         u16 state;
>         u16 link_autoneg;
>         int rx_csum;
>         int status;
> -       spinlock_t stats_lock;
>
>         struct netxen_cmd_buffer *cmd_buf_arr;  /* Command buffers for xmit */
>
> @@ -908,7 +900,6 @@ struct netxen_adapter {
>
>         /* Context interface shared between card and host */
>         struct netxen_ring_ctx *ctx_desc;
> -       struct pci_dev *ctx_desc_pdev;
>         dma_addr_t ctx_desc_phys_addr;
>         int intr_scheme;
>         int msi_mode;
> @@ -1034,8 +1025,6 @@ int netxen_rom_se(struct netxen_adapter *adapter, int addr);
>
>  /* Functions from netxen_nic_isr.c */
>  void netxen_initialize_adapter_sw(struct netxen_adapter *adapter);
> -void *netxen_alloc(struct pci_dev *pdev, size_t sz, dma_addr_t * ptr,
> -                  struct pci_dev **used_dev);
>  void netxen_initialize_adapter_ops(struct netxen_adapter *adapter);
>  int netxen_init_firmware(struct netxen_adapter *adapter);
>  void netxen_free_hw_resources(struct netxen_adapter *adapter);
> diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netxen/netxen_nic_ethtool.c
> index 723487b..99071c2 100644
> --- a/drivers/net/netxen/netxen_nic_ethtool.c
> +++ b/drivers/net/netxen/netxen_nic_ethtool.c
> @@ -427,6 +427,7 @@ netxen_nic_get_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom,
>         return 0;
>  }
>
> +#if 0
>  static int
>  netxen_nic_set_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom,
>                         u8 * bytes)
> @@ -447,7 +448,6 @@ netxen_nic_set_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom,
>                 }
>                 printk(KERN_INFO "%s: flash unlocked. \n",
>                         netxen_nic_driver_name);
> -               last_schedule_time = jiffies;
>                 ret = netxen_flash_erase_secondary(adapter);
>                 if (ret != FLASH_SUCCESS) {
>                         printk(KERN_ERR "%s: Flash erase failed.\n",
> @@ -497,6 +497,7 @@ netxen_nic_set_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom,
>
>         return netxen_rom_fast_write_words(adapter, offset, bytes, eeprom->len);
>  }
> +#endif /* 0 */
>
>  static void
>  netxen_nic_get_ringparam(struct net_device *dev, struct ethtool_ringparam *ring)
> @@ -745,7 +746,9 @@ struct ethtool_ops netxen_nic_ethtool_ops = {
>         .get_link = ethtool_op_get_link,
>         .get_eeprom_len = netxen_nic_get_eeprom_len,
>         .get_eeprom = netxen_nic_get_eeprom,
> +#if 0
>         .set_eeprom = netxen_nic_set_eeprom,
> +#endif
>         .get_ringparam = netxen_nic_get_ringparam,
>         .get_pauseparam = netxen_nic_get_pauseparam,
>         .set_pauseparam = netxen_nic_set_pauseparam,
> diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
> index c43d06b..fa6d034 100644
> --- a/drivers/net/netxen/netxen_nic_hw.c
> +++ b/drivers/net/netxen/netxen_nic_hw.c
> @@ -43,203 +43,61 @@ struct netxen_recv_crb recv_crb_registers[] = {
>          * Instance 0.
>          */
>         {
> -        /* rcv_desc_crb: */
> -        {
> -         {
> -          /* crb_rcv_producer_offset: */
> -          NETXEN_NIC_REG(0x100),
> -          /* crb_rcv_consumer_offset: */
> -          NETXEN_NIC_REG(0x104),
> -          /* crb_gloablrcv_ring: */
> -          NETXEN_NIC_REG(0x108),
> -          /* crb_rcv_ring_size */
> -          NETXEN_NIC_REG(0x10c),
> -
> -          },
> -         /* Jumbo frames */
> -         {
> -          /* crb_rcv_producer_offset: */
> -          NETXEN_NIC_REG(0x110),
> -          /* crb_rcv_consumer_offset: */
> -          NETXEN_NIC_REG(0x114),
> -          /* crb_gloablrcv_ring: */
> -          NETXEN_NIC_REG(0x118),
> -          /* crb_rcv_ring_size */
> -          NETXEN_NIC_REG(0x11c),
> -          },
> -         /* LRO */
> -         {
> -          /* crb_rcv_producer_offset: */
> -          NETXEN_NIC_REG(0x120),
> -          /* crb_rcv_consumer_offset: */
> -          NETXEN_NIC_REG(0x124),
> -          /* crb_gloablrcv_ring: */
> -          NETXEN_NIC_REG(0x128),
> -          /* crb_rcv_ring_size */
> -          NETXEN_NIC_REG(0x12c),
> -          }
> -         },
> -        /* crb_rcvstatus_ring: */
> -        NETXEN_NIC_REG(0x130),
> -        /* crb_rcv_status_producer: */
> -        NETXEN_NIC_REG(0x134),
> -        /* crb_rcv_status_consumer: */
> -        NETXEN_NIC_REG(0x138),
> -        /* crb_rcvpeg_state: */
> -        NETXEN_NIC_REG(0x13c),
> -        /* crb_status_ring_size */
> -        NETXEN_NIC_REG(0x140),
> -
> -        },
> +               /* crb_rcv_producer: */
> +               {
> +                       NETXEN_NIC_REG(0x100),
> +                       /* Jumbo frames */
> +                       NETXEN_NIC_REG(0x110),
> +                       /* LRO */
> +                       NETXEN_NIC_REG(0x120)
> +               },
> +               /* crb_sts_consumer: */
> +               NETXEN_NIC_REG(0x138),
> +       },
>         /*
>          * Instance 1,
>          */
>         {
> -        /* rcv_desc_crb: */
> -        {
> -         {
> -          /* crb_rcv_producer_offset: */
> -          NETXEN_NIC_REG(0x144),
> -          /* crb_rcv_consumer_offset: */
> -          NETXEN_NIC_REG(0x148),
> -          /* crb_globalrcv_ring: */
> -          NETXEN_NIC_REG(0x14c),
> -          /* crb_rcv_ring_size */
> -          NETXEN_NIC_REG(0x150),
> -
> -          },
> -         /* Jumbo frames */
> -         {
> -          /* crb_rcv_producer_offset: */
> -          NETXEN_NIC_REG(0x154),
> -          /* crb_rcv_consumer_offset: */
> -          NETXEN_NIC_REG(0x158),
> -          /* crb_globalrcv_ring: */
> -          NETXEN_NIC_REG(0x15c),
> -          /* crb_rcv_ring_size */
> -          NETXEN_NIC_REG(0x160),
> -          },
> -         /* LRO */
> -         {
> -          /* crb_rcv_producer_offset: */
> -          NETXEN_NIC_REG(0x164),
> -          /* crb_rcv_consumer_offset: */
> -          NETXEN_NIC_REG(0x168),
> -          /* crb_globalrcv_ring: */
> -          NETXEN_NIC_REG(0x16c),
> -          /* crb_rcv_ring_size */
> -          NETXEN_NIC_REG(0x170),
> -          }
> -
> -         },
> -        /* crb_rcvstatus_ring: */
> -        NETXEN_NIC_REG(0x174),
> -        /* crb_rcv_status_producer: */
> -        NETXEN_NIC_REG(0x178),
> -        /* crb_rcv_status_consumer: */
> -        NETXEN_NIC_REG(0x17c),
> -        /* crb_rcvpeg_state: */
> -        NETXEN_NIC_REG(0x180),
> -        /* crb_status_ring_size */
> -        NETXEN_NIC_REG(0x184),
> -        },
> +               /* crb_rcv_producer: */
> +               {
> +                       NETXEN_NIC_REG(0x144),
> +                       /* Jumbo frames */
> +                       NETXEN_NIC_REG(0x154),
> +                       /* LRO */
> +                       NETXEN_NIC_REG(0x164)
> +               },
> +               /* crb_sts_consumer: */
> +               NETXEN_NIC_REG(0x17c),
> +       },
>         /*
>          * Instance 2,
>          */
>         {
> -         {
> -           {
> -           /* crb_rcv_producer_offset: */
> -           NETXEN_NIC_REG(0x1d8),
> -           /* crb_rcv_consumer_offset: */
> -           NETXEN_NIC_REG(0x1dc),
> -           /* crb_gloablrcv_ring: */
> -           NETXEN_NIC_REG(0x1f0),
> -           /* crb_rcv_ring_size */
> -           NETXEN_NIC_REG(0x1f4),
> -           },
> -           /* Jumbo frames */
> -           {
> -           /* crb_rcv_producer_offset: */
> -           NETXEN_NIC_REG(0x1f8),
> -           /* crb_rcv_consumer_offset: */
> -           NETXEN_NIC_REG(0x1fc),
> -           /* crb_gloablrcv_ring: */
> -           NETXEN_NIC_REG(0x200),
> -           /* crb_rcv_ring_size */
> -           NETXEN_NIC_REG(0x204),
> -           },
> -           /* LRO */
> -           {
> -           /* crb_rcv_producer_offset: */
> -           NETXEN_NIC_REG(0x208),
> -           /* crb_rcv_consumer_offset: */
> -           NETXEN_NIC_REG(0x20c),
> -           /* crb_gloablrcv_ring: */
> -           NETXEN_NIC_REG(0x210),
> -           /* crb_rcv_ring_size */
> -           NETXEN_NIC_REG(0x214),
> -           }
> -         },
> -         /* crb_rcvstatus_ring: */
> -         NETXEN_NIC_REG(0x218),
> -         /* crb_rcv_status_producer: */
> -         NETXEN_NIC_REG(0x21c),
> -         /* crb_rcv_status_consumer: */
> -         NETXEN_NIC_REG(0x220),
> -         /* crb_rcvpeg_state: */
> -         NETXEN_NIC_REG(0x224),
> -         /* crb_status_ring_size */
> -         NETXEN_NIC_REG(0x228),
> +               /* crb_rcv_producer: */
> +               {
> +                       NETXEN_NIC_REG(0x1d8),
> +                       /* Jumbo frames */
> +                       NETXEN_NIC_REG(0x1f8),
> +                       /* LRO */
> +                       NETXEN_NIC_REG(0x208)
> +               },
> +               /* crb_sts_consumer: */
> +               NETXEN_NIC_REG(0x220),
>         },
>         /*
>          * Instance 3,
>          */
>         {
> -         {
> -           {
> -           /* crb_rcv_producer_offset: */
> -           NETXEN_NIC_REG(0x22c),
> -           /* crb_rcv_consumer_offset: */
> -           NETXEN_NIC_REG(0x230),
> -           /* crb_gloablrcv_ring: */
> -           NETXEN_NIC_REG(0x234),
> -           /* crb_rcv_ring_size */
> -           NETXEN_NIC_REG(0x238),
> -           },
> -           /* Jumbo frames */
> -           {
> -           /* crb_rcv_producer_offset: */
> -           NETXEN_NIC_REG(0x23c),
> -           /* crb_rcv_consumer_offset: */
> -           NETXEN_NIC_REG(0x240),
> -           /* crb_gloablrcv_ring: */
> -           NETXEN_NIC_REG(0x244),
> -           /* crb_rcv_ring_size */
> -           NETXEN_NIC_REG(0x248),
> -           },
> -           /* LRO */
> -           {
> -           /* crb_rcv_producer_offset: */
> -           NETXEN_NIC_REG(0x24c),
> -           /* crb_rcv_consumer_offset: */
> -           NETXEN_NIC_REG(0x250),
> -           /* crb_gloablrcv_ring: */
> -           NETXEN_NIC_REG(0x254),
> -           /* crb_rcv_ring_size */
> -           NETXEN_NIC_REG(0x258),
> -           }
> -         },
> -         /* crb_rcvstatus_ring: */
> -         NETXEN_NIC_REG(0x25c),
> -         /* crb_rcv_status_producer: */
> -         NETXEN_NIC_REG(0x260),
> -         /* crb_rcv_status_consumer: */
> -         NETXEN_NIC_REG(0x264),
> -         /* crb_rcvpeg_state: */
> -         NETXEN_NIC_REG(0x268),
> -         /* crb_status_ring_size */
> -         NETXEN_NIC_REG(0x26c),
> +               /* crb_rcv_producer: */
> +               {
> +                       NETXEN_NIC_REG(0x22c),
> +                       /* Jumbo frames */
> +                       NETXEN_NIC_REG(0x23c),
> +                       /* LRO */
> +                       NETXEN_NIC_REG(0x24c)
> +               },
> +               /* crb_sts_consumer: */
> +               NETXEN_NIC_REG(0x264),
>         },
>  };
>
> @@ -375,16 +233,12 @@ int netxen_nic_hw_resources(struct netxen_adapter *adapter)
>                 loops = 0;
>                 state = 0;
>                 /* Window 1 call */
> -               state = readl(NETXEN_CRB_NORMALIZE(adapter,
> -                                                  recv_crb_registers[ctx].
> -                                                  crb_rcvpeg_state));
> +               state = readl(NETXEN_CRB_NORMALIZE(adapter, CRB_RCVPEG_STATE));
>                 while (state != PHAN_PEG_RCV_INITIALIZED && loops < 20) {
>                         msleep(1);
>                         /* Window 1 call */
>                         state = readl(NETXEN_CRB_NORMALIZE(adapter,
> -                                                          recv_crb_registers
> -                                                          [ctx].
> -                                                          crb_rcvpeg_state));
> +                                       CRB_RCVPEG_STATE));
>                         loops++;
>                 }
>                 if (loops >= 20) {
> @@ -399,11 +253,9 @@ int netxen_nic_hw_resources(struct netxen_adapter *adapter)
>         adapter->msi_mode = readl(
>                 NETXEN_CRB_NORMALIZE(adapter, CRB_NIC_MSI_MODE_FW));
>
> -       addr = netxen_alloc(adapter->ahw.pdev,
> -                           sizeof(struct netxen_ring_ctx) +
> -                           sizeof(uint32_t),
> -                           (dma_addr_t *) & adapter->ctx_desc_phys_addr,
> -                           &adapter->ctx_desc_pdev);
> +       addr = pci_alloc_consistent(adapter->pdev,
> +                           sizeof(struct netxen_ring_ctx) + sizeof(uint32_t),
> +                           &adapter->ctx_desc_phys_addr);
>
>         if (addr == NULL) {
>                 DPRINTK(ERR, "bad return from pci_alloc_consistent\n");
> @@ -419,11 +271,10 @@ int netxen_nic_hw_resources(struct netxen_adapter *adapter)
>         adapter->cmd_consumer = (__le32 *) (((char *)addr) +
>                                               sizeof(struct netxen_ring_ctx));
>
> -       addr = netxen_alloc(adapter->ahw.pdev,
> +       addr = pci_alloc_consistent(adapter->pdev,
>                             sizeof(struct cmd_desc_type0) *
>                             adapter->max_tx_desc_count,
> -                           (dma_addr_t *) & hw->cmd_desc_phys_addr,
> -                           &adapter->ahw.cmd_desc_pdev);
> +                           &hw->cmd_desc_phys_addr);
>
>         if (addr == NULL) {
>                 DPRINTK(ERR, "bad return from pci_alloc_consistent\n");
> @@ -443,10 +294,9 @@ int netxen_nic_hw_resources(struct netxen_adapter *adapter)
>
>                 for (ring = 0; ring < NUM_RCV_DESC_RINGS; ring++) {
>                         rcv_desc = &recv_ctx->rcv_desc[ring];
> -                       addr = netxen_alloc(adapter->ahw.pdev,
> +                       addr = pci_alloc_consistent(adapter->pdev,
>                                             RCV_DESC_RINGSIZE,
> -                                           &rcv_desc->phys_addr,
> -                                           &rcv_desc->phys_pdev);
> +                                           &rcv_desc->phys_addr);
>                         if (addr == NULL) {
>                                 DPRINTK(ERR, "bad return from "
>                                         "pci_alloc_consistent\n");
> @@ -459,11 +309,13 @@ int netxen_nic_hw_resources(struct netxen_adapter *adapter)
>                             cpu_to_le64(rcv_desc->phys_addr);
>                         adapter->ctx_desc->rcv_ctx[ring].rcv_ring_size =
>                             cpu_to_le32(rcv_desc->max_rx_desc_count);
> +                       rcv_desc->crb_rcv_producer =
> +                                   recv_crb_registers[adapter->portnum].
> +                                   crb_rcv_producer[ring];
>                 }
>
> -               addr = netxen_alloc(adapter->ahw.pdev, STATUS_DESC_RINGSIZE,
> -                                   &recv_ctx->rcv_status_desc_phys_addr,
> -                                   &recv_ctx->rcv_status_desc_pdev);
> +               addr = pci_alloc_consistent(adapter->pdev, STATUS_DESC_RINGSIZE,
> +                                   &recv_ctx->rcv_status_desc_phys_addr);
>                 if (addr == NULL) {
>                         DPRINTK(ERR, "bad return from"
>                                 " pci_alloc_consistent\n");
> @@ -476,6 +328,8 @@ int netxen_nic_hw_resources(struct netxen_adapter *adapter)
>                     cpu_to_le64(recv_ctx->rcv_status_desc_phys_addr);
>                 adapter->ctx_desc->sts_ring_size =
>                     cpu_to_le32(adapter->max_rx_desc_count);
> +               recv_ctx->crb_sts_consumer =
> +                       recv_crb_registers[adapter->portnum].crb_sts_consumer;
>
>         }
>         /* Window = 1 */
> @@ -496,7 +350,7 @@ void netxen_free_hw_resources(struct netxen_adapter *adapter)
>         int ctx, ring;
>
>         if (adapter->ctx_desc != NULL) {
> -               pci_free_consistent(adapter->ctx_desc_pdev,
> +               pci_free_consistent(adapter->pdev,
>                                     sizeof(struct netxen_ring_ctx) +
>                                     sizeof(uint32_t),
>                                     adapter->ctx_desc,
> @@ -505,7 +359,7 @@ void netxen_free_hw_resources(struct netxen_adapter *adapter)
>         }
>
>         if (adapter->ahw.cmd_desc_head != NULL) {
> -               pci_free_consistent(adapter->ahw.cmd_desc_pdev,
> +               pci_free_consistent(adapter->pdev,
>                                     sizeof(struct cmd_desc_type0) *
>                                     adapter->max_tx_desc_count,
>                                     adapter->ahw.cmd_desc_head,
> @@ -519,7 +373,7 @@ void netxen_free_hw_resources(struct netxen_adapter *adapter)
>                         rcv_desc = &recv_ctx->rcv_desc[ring];
>
>                         if (rcv_desc->desc_head != NULL) {
> -                               pci_free_consistent(rcv_desc->phys_pdev,
> +                               pci_free_consistent(adapter->pdev,
>                                                     RCV_DESC_RINGSIZE,
>                                                     rcv_desc->desc_head,
>                                                     rcv_desc->phys_addr);
> @@ -528,7 +382,7 @@ void netxen_free_hw_resources(struct netxen_adapter *adapter)
>                 }
>
>                 if (recv_ctx->rcv_status_desc_head != NULL) {
> -                       pci_free_consistent(recv_ctx->rcv_status_desc_pdev,
> +                       pci_free_consistent(adapter->pdev,
>                                             STATUS_DESC_RINGSIZE,
>                                             recv_ctx->rcv_status_desc_head,
>                                             recv_ctx->
> diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
> index 70d1b22..37fd6bc 100644
> --- a/drivers/net/netxen/netxen_nic_init.c
> +++ b/drivers/net/netxen/netxen_nic_init.c
> @@ -42,8 +42,6 @@ struct crb_addr_pair {
>         u32 data;
>  };
>
> -unsigned long last_schedule_time;
> -
>  #define NETXEN_MAX_CRB_XFORM 60
>  static unsigned int crb_addr_xform[NETXEN_MAX_CRB_XFORM];
>  #define NETXEN_ADDR_ERROR (0xffffffff)
> @@ -155,24 +153,6 @@ int netxen_init_firmware(struct netxen_adapter *adapter)
>         return err;
>  }
>
> -#define NETXEN_ADDR_LIMIT 0xffffffffULL
> -
> -void *netxen_alloc(struct pci_dev *pdev, size_t sz, dma_addr_t * ptr,
> -                  struct pci_dev **used_dev)
> -{
> -       void *addr;
> -
> -       addr = pci_alloc_consistent(pdev, sz, ptr);
> -       if ((unsigned long long)(*ptr) < NETXEN_ADDR_LIMIT) {
> -               *used_dev = pdev;
> -               return addr;
> -       }
> -       pci_free_consistent(pdev, sz, addr, *ptr);
> -       addr = pci_alloc_consistent(NULL, sz, ptr);
> -       *used_dev = NULL;
> -       return addr;
> -}
> -
>  void netxen_initialize_adapter_sw(struct netxen_adapter *adapter)
>  {
>         int ctxid, ring;
> @@ -270,7 +250,9 @@ static u32 netxen_decode_crb_addr(u32 addr)
>
>  static long rom_max_timeout = 100;
>  static long rom_lock_timeout = 10000;
> +#if 0
>  static long rom_write_timeout = 700;
> +#endif
>
>  static int rom_lock(struct netxen_adapter *adapter)
>  {
> @@ -319,6 +301,7 @@ static int netxen_wait_rom_done(struct netxen_adapter *adapter)
>         return 0;
>  }
>
> +#if 0
>  static int netxen_rom_wren(struct netxen_adapter *adapter)
>  {
>         /* Set write enable latch in ROM status register */
> @@ -348,6 +331,7 @@ static int netxen_do_rom_rdsr(struct netxen_adapter *adapter)
>         }
>         return netxen_rdcrbreg(adapter, NETXEN_ROMUSB_ROM_RDATA);
>  }
> +#endif
>
>  static void netxen_rom_unlock(struct netxen_adapter *adapter)
>  {
> @@ -358,6 +342,7 @@ static void netxen_rom_unlock(struct netxen_adapter *adapter)
>
>  }
>
> +#if 0
>  static int netxen_rom_wip_poll(struct netxen_adapter *adapter)
>  {
>         long timeout = 0;
> @@ -393,6 +378,7 @@ static int do_rom_fast_write(struct netxen_adapter *adapter, int addr,
>
>         return netxen_rom_wip_poll(adapter);
>  }
> +#endif
>
>  static int do_rom_fast_read(struct netxen_adapter *adapter,
>                             int addr, int *valp)
> @@ -475,7 +461,6 @@ int netxen_rom_fast_write(struct netxen_adapter *adapter, int addr, int data)
>         netxen_rom_unlock(adapter);
>         return ret;
>  }
> -#endif  /*  0  */
>
>  static int do_rom_fast_write_words(struct netxen_adapter *adapter,
>                                    int addr, u8 *bytes, size_t size)
> @@ -740,13 +725,12 @@ int netxen_flash_unlock(struct netxen_adapter *adapter)
>
>         return ret;
>  }
> +#endif  /*  0  */
>
>  #define NETXEN_BOARDTYPE               0x4008
>  #define NETXEN_BOARDNUM                0x400c
>  #define NETXEN_CHIPNUM                 0x4010
>  #define NETXEN_ROMBUS_RESET            0xFFFFFFFF
> -#define NETXEN_ROM_FIRST_BARRIER       0x800000000ULL
> -#define NETXEN_ROM_FOUND_INIT          0x400
>
>  int netxen_pinit_from_rom(struct netxen_adapter *adapter, int verbose)
>  {
> @@ -776,10 +760,9 @@ int netxen_pinit_from_rom(struct netxen_adapter *adapter, int verbose)
>                         printk("Could not read chip number\n");
>         }
>
> -       if (netxen_rom_fast_read(adapter, 0, &n) == 0
> -           && (n & NETXEN_ROM_FIRST_BARRIER)) {
> -               n &= ~NETXEN_ROM_ROUNDUP;
> -               if (n < NETXEN_ROM_FOUND_INIT) {
> +       if (netxen_rom_fast_read(adapter, 0, &n) == 0 && (n & 0x80000000)) {
> +               n &= ~0x80000000;
> +               if (n < 0x400) {
>                         if (verbose)
>                                 printk("%s: %d CRB init values found"
>                                        " in ROM.\n", netxen_nic_driver_name, n);
> @@ -829,16 +812,8 @@ int netxen_pinit_from_rom(struct netxen_adapter *adapter, int verbose)
>                                 buf[i].data = NETXEN_NIC_XDMA_RESET;
>                         }
>
> -                       if (ADDR_IN_WINDOW1(off)) {
> -                               writel(buf[i].data,
> -                                      NETXEN_CRB_NORMALIZE(adapter, off));
> -                       } else {
> -                               netxen_nic_pci_change_crbwindow(adapter, 0);
> -                               writel(buf[i].data,
> -                                      pci_base_offset(adapter, off));
> +                       netxen_nic_hw_write_wx(adapter, off, &buf[i].data, 4);
>
> -                               netxen_nic_pci_change_crbwindow(adapter, 1);
> -                       }
>                         if (init_delay == 1) {
>                                 msleep(1000);
>                                 init_delay = 0;
> @@ -897,7 +872,7 @@ int netxen_initialize_adapter_offload(struct netxen_adapter *adapter)
>         uint32_t lo;
>
>         adapter->dummy_dma.addr =
> -           pci_alloc_consistent(adapter->ahw.pdev,
> +           pci_alloc_consistent(adapter->pdev,
>                                  NETXEN_HOST_DUMMY_DMA_SIZE,
>                                  &adapter->dummy_dma.phys_addr);
>         if (adapter->dummy_dma.addr == NULL) {
> @@ -931,7 +906,7 @@ void netxen_free_adapter_offload(struct netxen_adapter *adapter)
>                 } while (--i);
>
>                 if (i) {
> -                       pci_free_consistent(adapter->ahw.pdev,
> +                       pci_free_consistent(adapter->pdev,
>                                     NETXEN_HOST_DUMMY_DMA_SIZE,
>                                     adapter->dummy_dma.addr,
>                                     adapter->dummy_dma.phys_addr);
> @@ -1104,8 +1079,6 @@ static void netxen_process_rcv(struct netxen_adapter *adapter, int ctxid,
>         ret = netif_receive_skb(skb);
>         netdev->last_rx = jiffies;
>
> -       rcv_desc->rcv_pending--;
> -
>         /*
>          * We just consumed one buffer so post a buffer.
>          */
> @@ -1125,7 +1098,6 @@ u32 netxen_process_rcv_ring(struct netxen_adapter *adapter, int ctxid, int max)
>         struct status_desc *desc_head = recv_ctx->rcv_status_desc_head;
>         struct status_desc *desc;       /* used to read status desc here */
>         u32 consumer = recv_ctx->status_rx_consumer;
> -       u32 producer = 0;
>         int count = 0, ring;
>
>         while (count < max) {
> @@ -1146,13 +1118,10 @@ u32 netxen_process_rcv_ring(struct netxen_adapter *adapter, int ctxid, int max)
>         /* update the consumer index in phantom */
>         if (count) {
>                 recv_ctx->status_rx_consumer = consumer;
> -               recv_ctx->status_rx_producer = producer;
>
>                 /* Window = 1 */
> -               writel(consumer,
> -                      NETXEN_CRB_NORMALIZE(adapter,
> -                                   recv_crb_registers[adapter->portnum].
> -                                           crb_rcv_status_consumer));
> +               writel(consumer, NETXEN_CRB_NORMALIZE(adapter,
> +                                       recv_ctx->crb_sts_consumer));
>         }
>
>         return count;
> @@ -1231,7 +1200,7 @@ int netxen_process_cmd_ring(struct netxen_adapter *adapter)
>   */
>  void netxen_post_rx_buffers(struct netxen_adapter *adapter, u32 ctx, u32 ringid)
>  {
> -       struct pci_dev *pdev = adapter->ahw.pdev;
> +       struct pci_dev *pdev = adapter->pdev;
>         struct sk_buff *skb;
>         struct netxen_recv_context *recv_ctx = &(adapter->recv_ctx[ctx]);
>         struct netxen_rcv_desc_ctx *rcv_desc = NULL;
> @@ -1294,16 +1263,11 @@ void netxen_post_rx_buffers(struct netxen_adapter *adapter, u32 ctx, u32 ringid)
>         /* if we did allocate buffers, then write the count to Phantom */
>         if (count) {
>                 rcv_desc->begin_alloc = index;
> -               rcv_desc->rcv_pending += count;
>                 rcv_desc->producer = producer;
>                         /* Window = 1 */
> -                       writel((producer - 1) &
> -                              (rcv_desc->max_rx_desc_count - 1),
> -                              NETXEN_CRB_NORMALIZE(adapter,
> -                                                   recv_crb_registers[
> -                                                   adapter->portnum].
> -                                                   rcv_desc_crb[ringid].
> -                                                   crb_rcv_producer_offset));
> +               writel((producer - 1) & (rcv_desc->max_rx_desc_count - 1),
> +                      NETXEN_CRB_NORMALIZE(adapter,
> +                              rcv_desc->crb_rcv_producer));
>                         /*
>                          * Write a doorbell msg to tell phanmon of change in
>                          * receive ring producer
> @@ -1325,7 +1289,7 @@ void netxen_post_rx_buffers(struct netxen_adapter *adapter, u32 ctx, u32 ringid)
>  static void netxen_post_rx_buffers_nodb(struct netxen_adapter *adapter,
>                                         uint32_t ctx, uint32_t ringid)
>  {
> -       struct pci_dev *pdev = adapter->ahw.pdev;
> +       struct pci_dev *pdev = adapter->pdev;
>         struct sk_buff *skb;
>         struct netxen_recv_context *recv_ctx = &(adapter->recv_ctx[ctx]);
>         struct netxen_rcv_desc_ctx *rcv_desc = NULL;
> @@ -1370,7 +1334,6 @@ static void netxen_post_rx_buffers_nodb(struct netxen_adapter *adapter,
>                 pdesc->reference_handle = cpu_to_le16(buffer->ref_handle);
>                 pdesc->buffer_length = cpu_to_le32(rcv_desc->dma_size);
>                 pdesc->addr_buffer = cpu_to_le64(buffer->dma);
> -               DPRINTK(INFO, "done writing descripter\n");
>                 producer =
>                     get_next_index(producer, rcv_desc->max_rx_desc_count);
>                 index = get_next_index(index, rcv_desc->max_rx_desc_count);
> @@ -1380,16 +1343,11 @@ static void netxen_post_rx_buffers_nodb(struct netxen_adapter *adapter,
>         /* if we did allocate buffers, then write the count to Phantom */
>         if (count) {
>                 rcv_desc->begin_alloc = index;
> -               rcv_desc->rcv_pending += count;
>                 rcv_desc->producer = producer;
>                         /* Window = 1 */
> -                       writel((producer - 1) &
> -                              (rcv_desc->max_rx_desc_count - 1),
> -                              NETXEN_CRB_NORMALIZE(adapter,
> -                                                   recv_crb_registers[
> -                                                   adapter->portnum].
> -                                                   rcv_desc_crb[ringid].
> -                                                   crb_rcv_producer_offset));
> +               writel((producer - 1) & (rcv_desc->max_rx_desc_count - 1),
> +                      NETXEN_CRB_NORMALIZE(adapter,
> +                              rcv_desc->crb_rcv_producer));
>                         wmb();
>         }
>  }
> diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
> index 63cd67b..91b02eb 100644
> --- a/drivers/net/netxen/netxen_nic_main.c
> +++ b/drivers/net/netxen/netxen_nic_main.c
> @@ -108,66 +108,30 @@ static struct workqueue_struct *netxen_workq;
>
>  static void netxen_watchdog(unsigned long);
>
> +static uint32_t crb_cmd_producer[4] = {
> +       CRB_CMD_PRODUCER_OFFSET, CRB_CMD_PRODUCER_OFFSET_1,
> +       CRB_CMD_PRODUCER_OFFSET_2, CRB_CMD_PRODUCER_OFFSET_3
> +};
> +
>  static void netxen_nic_update_cmd_producer(struct netxen_adapter *adapter,
>                                            uint32_t crb_producer)
>  {
> -       switch (adapter->portnum) {
> -               case 0:
> -                       writel(crb_producer, NETXEN_CRB_NORMALIZE
> -                                       (adapter, CRB_CMD_PRODUCER_OFFSET));
> -                       return;
> -               case 1:
> -                       writel(crb_producer, NETXEN_CRB_NORMALIZE
> -                                       (adapter, CRB_CMD_PRODUCER_OFFSET_1));
> -                       return;
> -               case 2:
> -                       writel(crb_producer, NETXEN_CRB_NORMALIZE
> -                                       (adapter, CRB_CMD_PRODUCER_OFFSET_2));
> -                       return;
> -               case 3:
> -                       writel(crb_producer, NETXEN_CRB_NORMALIZE
> -                                       (adapter, CRB_CMD_PRODUCER_OFFSET_3));
> -                       return;
> -               default:
> -                       printk(KERN_WARNING "We tried to update "
> -                                       "CRB_CMD_PRODUCER_OFFSET for invalid "
> -                                       "PCI function id %d\n",
> -                                       adapter->portnum);
> -                       return;
> -       }
> +       writel(crb_producer, NETXEN_CRB_NORMALIZE(adapter,
> +                               adapter->crb_addr_cmd_producer));
>  }
>
> +static uint32_t crb_cmd_consumer[4] = {
> +       CRB_CMD_CONSUMER_OFFSET, CRB_CMD_CONSUMER_OFFSET_1,
> +       CRB_CMD_CONSUMER_OFFSET_2, CRB_CMD_CONSUMER_OFFSET_3
> +};
> +
>  static void netxen_nic_update_cmd_consumer(struct netxen_adapter *adapter,
>                                            u32 crb_consumer)
>  {
> -       switch (adapter->portnum) {
> -               case 0:
> -                       writel(crb_consumer, NETXEN_CRB_NORMALIZE
> -                               (adapter, CRB_CMD_CONSUMER_OFFSET));
> -                       return;
> -               case 1:
> -                       writel(crb_consumer, NETXEN_CRB_NORMALIZE
> -                               (adapter, CRB_CMD_CONSUMER_OFFSET_1));
> -                       return;
> -               case 2:
> -                       writel(crb_consumer, NETXEN_CRB_NORMALIZE
> -                               (adapter, CRB_CMD_CONSUMER_OFFSET_2));
> -                       return;
> -               case 3:
> -                       writel(crb_consumer, NETXEN_CRB_NORMALIZE
> -                               (adapter, CRB_CMD_CONSUMER_OFFSET_3));
> -                       return;
> -               default:
> -                       printk(KERN_WARNING "We tried to update "
> -                                       "CRB_CMD_PRODUCER_OFFSET for invalid "
> -                                       "PCI function id %d\n",
> -                                       adapter->portnum);
> -                       return;
> -       }
> +       writel(crb_consumer, NETXEN_CRB_NORMALIZE(adapter,
> +                               adapter->crb_addr_cmd_consumer));
>  }
>
> -#define        ADAPTER_LIST_SIZE 12
> -
>  static uint32_t msi_tgt_status[4] = {
>         ISR_INT_TARGET_STATUS, ISR_INT_TARGET_STATUS_F1,
>         ISR_INT_TARGET_STATUS_F2, ISR_INT_TARGET_STATUS_F3
> @@ -334,7 +298,6 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
>
>         adapter = netdev->priv;
>
> -       adapter->ahw.pdev = pdev;
>         adapter->ahw.pci_func  = pci_func_id;
>
>         /* remap phys address */
> @@ -552,12 +515,13 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
>         adapter->watchdog_timer.function = &netxen_watchdog;
>         adapter->watchdog_timer.data = (unsigned long)adapter;
>         INIT_WORK(&adapter->watchdog_task, netxen_watchdog_task);
> -       adapter->ahw.pdev = pdev;
>         adapter->ahw.revision_id = pdev->revision;
>
>         /* make sure Window == 1 */
>         netxen_nic_pci_change_crbwindow(adapter, 1);
>
> +       adapter->crb_addr_cmd_producer = crb_cmd_producer[adapter->portnum];
> +       adapter->crb_addr_cmd_consumer = crb_cmd_consumer[adapter->portnum];
>         netxen_nic_update_cmd_producer(adapter, 0);
>         netxen_nic_update_cmd_consumer(adapter, 0);
>         writel(0, NETXEN_CRB_NORMALIZE(adapter, CRB_HOST_CMD_ADDR_LO));
> @@ -816,7 +780,7 @@ static int netxen_nic_open(struct net_device *netdev)
>                         for (ring = 0; ring < NUM_RCV_DESC_RINGS; ring++)
>                                 netxen_post_rx_buffers(adapter, ctx, ring);
>                 }
> -               adapter->irq = adapter->ahw.pdev->irq;
> +               adapter->irq = adapter->pdev->irq;
>                 if (adapter->flags & NETXEN_NIC_MSI_ENABLED)
>                         handler = netxen_msi_intr;
>                 else {
> @@ -1220,10 +1184,6 @@ module_init(netxen_init_module);
>
>  static void __exit netxen_exit_module(void)
>  {
> -       /*
> -        * Wait for some time to allow the dma to drain, if any.
> -        */
> -       msleep(100);
>         pci_unregister_driver(&netxen_driver);
>         destroy_workqueue(netxen_workq);
>  }
> diff --git a/drivers/net/netxen/netxen_nic_phan_reg.h b/drivers/net/netxen/netxen_nic_phan_reg.h
> index a566b50..db2202a 100644
> --- a/drivers/net/netxen/netxen_nic_phan_reg.h
> +++ b/drivers/net/netxen/netxen_nic_phan_reg.h
> @@ -98,6 +98,7 @@
>  #define CRB_JUMBO_BUFFER_PROD       NETXEN_NIC_REG(0xf4)
>  #define CRB_JUMBO_BUFFER_CONS       NETXEN_NIC_REG(0xf8)
>
> +#define CRB_RCVPEG_STATE            NETXEN_NIC_REG(0x13c)
>  #define CRB_CMD_PRODUCER_OFFSET_1   NETXEN_NIC_REG(0x1ac)
>  #define CRB_CMD_CONSUMER_OFFSET_1   NETXEN_NIC_REG(0x1b0)
>  #define CRB_CMD_PRODUCER_OFFSET_2   NETXEN_NIC_REG(0x1b8)
> @@ -147,25 +148,13 @@
>  #define nx_get_temp_state(x)           ((x) & 0xffff)
>  #define nx_encode_temp(val, state)     (((val) << 16) | (state))
>
> -/* CRB registers per Rcv Descriptor ring */
> -struct netxen_rcv_desc_crb {
> -       u32 crb_rcv_producer_offset __attribute__ ((aligned(512)));
> -       u32 crb_rcv_consumer_offset;
> -       u32 crb_globalrcv_ring;
> -       u32 crb_rcv_ring_size;
> -};
> -
>  /*
>   * CRB registers used by the receive peg logic.
>   */
>
>  struct netxen_recv_crb {
> -       struct netxen_rcv_desc_crb rcv_desc_crb[NUM_RCV_DESC_RINGS];
> -       u32 crb_rcvstatus_ring;
> -       u32 crb_rcv_status_producer;
> -       u32 crb_rcv_status_consumer;
> -       u32 crb_rcvpeg_state;
> -       u32 crb_status_ring_size;
> +       u32 crb_rcv_producer[NUM_RCV_DESC_RINGS];
> +       u32 crb_sts_consumer;
>  };
>
>  extern struct netxen_recv_crb recv_crb_registers[];
> --
> 1.5.4.3
>
>
> No virus found in this incoming message.
> Checked by AVG.
> Version: 7.5.526 / Virus Database: 270.4.9/1548 - Release Date: 7/12/2008 07:40
>
>   

