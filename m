From: "Vernon Mauery" <vmauery@gmail.com>
Subject: Re: [PATCH 1/4] netxen: improve msi support
Date: Thu, 13 Mar 2008 09:42:42 -0700
Message-ID: <200495120803130942u3d6be8ddj31a3835ebfa309b5@mail.gmail.com>
References: <Pine.LNX.4.64.0803120059270.7717@unm84.unminc.com>
	 <Pine.LNX.4.64.0803120118400.7717@unm84.unminc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Jeff Garzik" <jeff@garzik.org>
To: "Dhananjay Phadke" <dhananjay@netxen.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from el-out-1112.google.com ([209.85.162.178]:60211 "EHLO
	el-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752137AbYCMQmp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Mar 2008 12:42:45 -0400
Received: by el-out-1112.google.com with SMTP id v27so2230426ele.17
        for <netdev@vger.kernel.org>; Thu, 13 Mar 2008 09:42:43 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.64.0803120118400.7717@unm84.unminc.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/12/08, Dhananjay Phadke <dhananjay@netxen.com> wrote:
>
>  Recent netxen firmware has new scheme of generating MSI interrupts, it
>  raises interrupt and blocks itself, waiting for driver to unmask. This
>  reduces chance of spurious interrupts.
>
>  The driver will be able to deal with older firmware as well.
>
>  Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>

I have tested this patch on my netxen hardware and found that it fixes
a TX timeout hang that I was seeing previously.

Tested-by: Vernon Mauery <vernux@us.ibm.com>

--Vernon

>  ---
>   drivers/net/netxen/netxen_nic.h          |    1 +
>   drivers/net/netxen/netxen_nic_hdr.h      |   12 ++++++
>   drivers/net/netxen/netxen_nic_hw.c       |    2 +
>   drivers/net/netxen/netxen_nic_init.c     |    2 +
>   drivers/net/netxen/netxen_nic_main.c     |   56 ++++++++++++-----------------
>   drivers/net/netxen/netxen_nic_phan_reg.h |    3 ++
>   6 files changed, 43 insertions(+), 33 deletions(-)
>
>  diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
>  index 2bc5eaa..876cd06 100644
>  --- a/drivers/net/netxen/netxen_nic.h
>  +++ b/drivers/net/netxen/netxen_nic.h
>  @@ -942,6 +942,7 @@ struct netxen_adapter {
>         struct pci_dev *ctx_desc_pdev;
>         dma_addr_t ctx_desc_phys_addr;
>         int intr_scheme;
>  +       int msi_mode;
>         int (*enable_phy_interrupts) (struct netxen_adapter *);
>         int (*disable_phy_interrupts) (struct netxen_adapter *);
>         void (*handle_phy_intr) (struct netxen_adapter *);
>  diff --git a/drivers/net/netxen/netxen_nic_hdr.h b/drivers/net/netxen/netxen_nic_hdr.h
>  index d72f8f8..160f605 100644
>  --- a/drivers/net/netxen/netxen_nic_hdr.h
>  +++ b/drivers/net/netxen/netxen_nic_hdr.h
>  @@ -456,6 +456,12 @@ enum {
>   #define ISR_INT_MASK_SLOW      (NETXEN_PCIX_PS_REG(PCIX_INT_MASK))
>   #define ISR_INT_TARGET_STATUS  (NETXEN_PCIX_PS_REG(PCIX_TARGET_STATUS))
>   #define ISR_INT_TARGET_MASK    (NETXEN_PCIX_PS_REG(PCIX_TARGET_MASK))
>  +#define ISR_INT_TARGET_STATUS_F1   (NETXEN_PCIX_PS_REG(PCIX_TARGET_STATUS_F1))
>  +#define ISR_INT_TARGET_MASK_F1     (NETXEN_PCIX_PS_REG(PCIX_TARGET_MASK_F1))
>  +#define ISR_INT_TARGET_STATUS_F2   (NETXEN_PCIX_PS_REG(PCIX_TARGET_STATUS_F2))
>  +#define ISR_INT_TARGET_MASK_F2     (NETXEN_PCIX_PS_REG(PCIX_TARGET_MASK_F2))
>  +#define ISR_INT_TARGET_STATUS_F3   (NETXEN_PCIX_PS_REG(PCIX_TARGET_STATUS_F3))
>  +#define ISR_INT_TARGET_MASK_F3     (NETXEN_PCIX_PS_REG(PCIX_TARGET_MASK_F3))
>
>   #define NETXEN_PCI_MAPSIZE     128
>   #define NETXEN_PCI_DDR_NET     (0x00000000UL)
>  @@ -662,6 +668,12 @@ enum {
>
>   #define PCIX_TARGET_STATUS     (0x10118)
>   #define PCIX_TARGET_MASK       (0x10128)
>  +#define PCIX_TARGET_STATUS_F1 (0x10160)
>  +#define PCIX_TARGET_MASK_F1   (0x10170)
>  +#define PCIX_TARGET_STATUS_F2 (0x10164)
>  +#define PCIX_TARGET_MASK_F2   (0x10174)
>  +#define PCIX_TARGET_STATUS_F3 (0x10168)
>  +#define PCIX_TARGET_MASK_F3   (0x10178)
>
>   #define PCIX_MSI_F0            (0x13000)
>   #define PCIX_MSI_F1            (0x13004)
>  diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
>  index 0135570..05748ca 100644
>  --- a/drivers/net/netxen/netxen_nic_hw.c
>  +++ b/drivers/net/netxen/netxen_nic_hw.c
>  @@ -398,6 +398,8 @@ int netxen_nic_hw_resources(struct netxen_adapter *adapter)
>                 NETXEN_CRB_NORMALIZE(adapter, CRB_NIC_CAPABILITIES_FW));
>         printk(KERN_NOTICE "%s: FW capabilities:0x%x\n", netxen_nic_driver_name,
>                         adapter->intr_scheme);
>  +       adapter->msi_mode = readl(
>  +               NETXEN_CRB_NORMALIZE(adapter, CRB_NIC_MSI_MODE_FW));
>         DPRINTK(INFO, "Receive Peg ready too. starting stuff\n");
>
>         addr = netxen_alloc(adapter->ahw.pdev,
>  diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
>  index 9e38bcb..43eb1f6 100644
>  --- a/drivers/net/netxen/netxen_nic_init.c
>  +++ b/drivers/net/netxen/netxen_nic_init.c
>  @@ -145,6 +145,8 @@ int netxen_init_firmware(struct netxen_adapter *adapter)
>         /* Window 1 call */
>         writel(INTR_SCHEME_PERPORT,
>                NETXEN_CRB_NORMALIZE(adapter, CRB_NIC_CAPABILITIES_HOST));
>  +       writel(MSI_MODE_MULTIFUNC,
>  +              NETXEN_CRB_NORMALIZE(adapter, CRB_NIC_MSI_MODE_HOST));
>         writel(MPORT_MULTI_FUNCTION_MODE,
>                NETXEN_CRB_NORMALIZE(adapter, CRB_MPORT_MODE));
>         writel(PHAN_INITIALIZE_ACK,
>  diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
>  index 9737eae..cd665da 100644
>  --- a/drivers/net/netxen/netxen_nic_main.c
>  +++ b/drivers/net/netxen/netxen_nic_main.c
>  @@ -149,33 +149,31 @@ static void netxen_nic_update_cmd_consumer(struct netxen_adapter *adapter,
>
>   #define        ADAPTER_LIST_SIZE 12
>
>  +static uint32_t msi_tgt_status[4] = {
>  +       ISR_INT_TARGET_STATUS, ISR_INT_TARGET_STATUS_F1,
>  +       ISR_INT_TARGET_STATUS_F2, ISR_INT_TARGET_STATUS_F3
>  +};
>  +
>  +static uint32_t sw_int_mask[4] = {
>  +       CRB_SW_INT_MASK_0, CRB_SW_INT_MASK_1,
>  +       CRB_SW_INT_MASK_2, CRB_SW_INT_MASK_3
>  +};
>  +
>   static void netxen_nic_disable_int(struct netxen_adapter *adapter)
>   {
>  -       uint32_t        mask = 0x7ff;
>  +       u32 mask = 0x7ff;
>         int retries = 32;
>  +       int port = adapter->portnum;
>  +       int pci_fn = adapter->ahw.pci_func;
>
>  -       DPRINTK(1, INFO, "Entered ISR Disable \n");
>  -
>  -       switch (adapter->portnum) {
>  -       case 0:
>  -               writel(0x0, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_0));
>  -               break;
>  -       case 1:
>  -               writel(0x0, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_1));
>  -               break;
>  -       case 2:
>  -               writel(0x0, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_2));
>  -               break;
>  -       case 3:
>  -               writel(0x0, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_3));
>  -               break;
>  +       if (adapter->msi_mode != MSI_MODE_MULTIFUNC) {
>  +               writel(0x0, NETXEN_CRB_NORMALIZE(adapter, sw_int_mask[port]));
>         }
>
>         if (adapter->intr_scheme != -1 &&
>             adapter->intr_scheme != INTR_SCHEME_PERPORT)
>                 writel(mask,PCI_OFFSET_SECOND_RANGE(adapter, ISR_INT_MASK));
>
>  -       /* Window = 0 or 1 */
>         if (!(adapter->flags & NETXEN_NIC_MSI_ENABLED)) {
>                 do {
>                         writel(0xffffffff,
>  @@ -190,14 +188,18 @@ static void netxen_nic_disable_int(struct netxen_adapter *adapter)
>                         printk(KERN_NOTICE "%s: Failed to disable interrupt completely\n",
>                                         netxen_nic_driver_name);
>                 }
>  +       } else {
>  +               if (adapter->msi_mode == MSI_MODE_MULTIFUNC) {
>  +                       writel(0xffffffff, PCI_OFFSET_SECOND_RANGE(adapter,
>  +                                               msi_tgt_status[pci_fn]));
>  +               }
>         }
>  -
>  -       DPRINTK(1, INFO, "Done with Disable Int\n");
>   }
>
>   static void netxen_nic_enable_int(struct netxen_adapter *adapter)
>   {
>         u32 mask;
>  +       int port = adapter->portnum;
>
>         DPRINTK(1, INFO, "Entered ISR Enable \n");
>
>  @@ -218,20 +220,7 @@ static void netxen_nic_enable_int(struct netxen_adapter *adapter)
>                 writel(mask, PCI_OFFSET_SECOND_RANGE(adapter, ISR_INT_MASK));
>         }
>
>  -       switch (adapter->portnum) {
>  -       case 0:
>  -               writel(0x1, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_0));
>  -               break;
>  -       case 1:
>  -               writel(0x1, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_1));
>  -               break;
>  -       case 2:
>  -               writel(0x1, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_2));
>  -               break;
>  -       case 3:
>  -               writel(0x1, NETXEN_CRB_NORMALIZE(adapter, CRB_SW_INT_MASK_3));
>  -               break;
>  -       }
>  +       writel(0x1, NETXEN_CRB_NORMALIZE(adapter, sw_int_mask[port]));
>
>         if (!(adapter->flags & NETXEN_NIC_MSI_ENABLED)) {
>                 mask = 0xbff;
>  @@ -401,6 +390,7 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
>
>         /* this will be read from FW later */
>         adapter->intr_scheme = -1;
>  +       adapter->msi_mode = -1;
>
>         /* This will be reset for mezz cards  */
>         adapter->portnum = pci_func_id;
>  diff --git a/drivers/net/netxen/netxen_nic_phan_reg.h b/drivers/net/netxen/netxen_nic_phan_reg.h
>  index ffa3b72..a566b50 100644
>  --- a/drivers/net/netxen/netxen_nic_phan_reg.h
>  +++ b/drivers/net/netxen/netxen_nic_phan_reg.h
>  @@ -126,8 +126,11 @@
>   */
>   #define CRB_NIC_CAPABILITIES_HOST      NETXEN_NIC_REG(0x1a8)
>   #define CRB_NIC_CAPABILITIES_FW                NETXEN_NIC_REG(0x1dc)
>  +#define CRB_NIC_MSI_MODE_HOST          NETXEN_NIC_REG(0x270)
>  +#define CRB_NIC_MSI_MODE_FW                    NETXEN_NIC_REG(0x274)
>
>   #define INTR_SCHEME_PERPORT            0x1
>  +#define MSI_MODE_MULTIFUNC             0x1
>
>   /* used for ethtool tests */
>   #define CRB_SCRATCHPAD_TEST        NETXEN_NIC_REG(0x280)
>
> --
>  To unsubscribe from this list: send the line "unsubscribe netdev" in
>  the body of a message to majordomo@vger.kernel.org
>  More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
