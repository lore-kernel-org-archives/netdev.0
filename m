From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2] Add support for ethtool operations to RDC R6040.
Date: Mon, 10 Oct 2016 00:53:36 -0700
Message-ID: <9d61e9ec-3bb5-93b3-0f39-ee3320163d7a@gmail.com>
References: <1475998782-10593-1-git-send-email-venkat.prashanth2498@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fengguang.wu@intel.com
To: VENKAT PRASHANTH B U <venkat.prashanth2498@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:35314 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751966AbcJJHyM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Oct 2016 03:54:12 -0400
Received: by mail-lf0-f68.google.com with SMTP id x79so5141991lff.2
        for <netdev@vger.kernel.org>; Mon, 10 Oct 2016 00:53:39 -0700 (PDT)
In-Reply-To: <1475998782-10593-1-git-send-email-venkat.prashanth2498@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/09/2016 12:39 AM, VENKAT PRASHANTH B U wrote:
> Signed-off-by: Venkat Prashanth B U <venkat.prashanth2498@gmail.com>

This should be the last line in your commit message, not the first one.

> 
> Changes since v1:
> 1. Made the commit message more clear
> 2. Add enumeration data type RTL_FLAG_MAX
> 3. Modified the locking interface used in r6040_get_regs()
>    
> 4. Initialized mutex dynamically in a function r6040_get_regs()
>    
> 5. Declared u32 msg_enable in struct r6040_private

The changelog between versions of the patches should be below a --- line
such that it gets ignored when the patch gets applied.

> ---
>  drivers/net/ethernet/rdc/r6040.c | 95 ++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 95 insertions(+)
> 
> diff --git a/drivers/net/ethernet/rdc/r6040.c b/drivers/net/ethernet/rdc/r6040.c
> index cb29ee2..167ff59 100644
> --- a/drivers/net/ethernet/rdc/r6040.c
> +++ b/drivers/net/ethernet/rdc/r6040.c
> @@ -183,6 +183,10 @@ struct r6040_descriptor {
>  	u32	rev2;			/* 1C-1F */
>  } __aligned(32);
>  
> +enum rtl_flag {
> +	RTL_FLAG_MAX
> +};
> +
>  struct r6040_private {
>  	spinlock_t lock;		/* driver lock */
>  	struct pci_dev *pdev;
> @@ -196,12 +200,18 @@ struct r6040_private {
>  	dma_addr_t tx_ring_dma;
>  	u16	tx_free_desc;
>  	u16	mcr0;
> +	u32 msg_enable;
>  	struct net_device *dev;
>  	struct mii_bus *mii_bus;
>  	struct napi_struct napi;
>  	void __iomem *base;
>  	int old_link;
>  	int old_duplex;
> +	struct {
> +		DECLARE_BITMAP(flags, RTL_FLAG_MAX);
> +		struct mutex mutex;
> +		struct work_struct work;
> +	} wk;

Is that necessary?

>  };
>  
>  static char version[] = DRV_NAME
> @@ -955,12 +965,97 @@ static void netdev_get_drvinfo(struct net_device *dev,
>  	strlcpy(info->bus_info, pci_name(rp->pdev), sizeof(info->bus_info));
>  }
>  
> +static void r6040_lock_work(struct r6040_private *tp)
> +{
> +	mutex_lock(&tp->wk.mutex);
> +}
> +
> +static void r6040_unlock_work(struct r6040_private *tp)
> +{
> +	mutex_unlock(&tp->wk.mutex);
> +}
> +
> +static int r6040_get_regs_len (struct net_device *dev)
> +{
> +  return R6040_IO_SIZE;
> +}

Please check your tabs vs. space indentation, kernel coding style is
documented in Documentation/CodingStyle.

> +
> +static void r6040_get_regs (struct net_device *dev, struct ethtool_regs *regs, void *p)
> +{
> +  struct r6040_private *tp = netdev_priv (dev);
> +  u32 __iomem *data = tp->base;
> +  u32 *dw = p;
> +  int i;
> +
> +  r6040_lock_work (tp);
> +  for (i = 0; i < R6040_IO_SIZE; i += 4)
> +    memcpy_fromio (dw++, data++, 4);
> +  r6040_unlock_work (tp);

r6040 registers are typically 16-bits wide, and should be accessed using
ioread16(), did you check this produces the expected result?

> +}
> +
> +static u32 r6040_get_msglevel (struct net_device *dev)
> +{
> +  struct r6040_private *tp = netdev_priv (dev);
> +
> +  return tp->msg_enable;
> +}

That alone does not do anything useful until you start using netif_*
prints in the driver.

> +
> +static void r6040_set_msglevel (struct net_device *dev, u32 value)
> +{
> +  struct r6040_private *tp = netdev_priv (dev);
> +
> +  tp->msg_enable = value;
> +}
> +
> +static const char r6040_gstrings[][ETH_GSTRING_LEN] = {
> +  "tx_packets",
> +  "rx_packets",
> +  "tx_errors",
> +  "rx_errors",
> +  "rx_missed",
> +  "align_errors",
> +  "tx_single_collisions",
> +  "tx_multi_collisions",
> +  "unicast",
> +  "broadcast",
> +  "multicast",
> +  "tx_aborted",
> +  "tx_underrun",
> +};
> +
> +static int r6040_get_sset_count (struct net_device *dev, int sset)
> +{
> +  switch (sset)
> +    {
> +    case ETH_SS_STATS:
> +      return ARRAY_SIZE (r6040_gstrings);
> +    default:
> +      return -EOPNOTSUPP;
> +    }
> +}
> +
> +static void r6040_get_strings (struct net_device *dev, u32 stringset, u8 * data)
> +{
> +  switch (stringset)
> +    {
> +    case ETH_SS_STATS:
> +      memcpy (data, *r6040_gstrings, sizeof (r6040_gstrings));
> +      break;
> +    }
> +}

Where do we actually obtain the statistics from if we do not implement a
get_ethtool_stats callback that fills in these values from either a HW
read or a shadow copy in SW?

Do you have the HW to test these changes?
-- 
Florian
