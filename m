From: Grant Grundler <grundler@parisc-linux.org>
Subject: Re: [PATCH 14/19] tulip: convert drivers to netdev_tx_t
Date: Tue, 1 Sep 2009 23:48:01 -0600
Message-ID: <20090902054801.GB28972@lackof.org>
References: <20090901055039.824876937@vyatta.com> <20090901055129.814907029@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Grant Grundler <grundler@parisc-linux.org>,
	Kyle McMartin <kyle@mcmartin.ca>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from complete.lackof.org ([198.49.126.79]:43574 "EHLO
	complete.lackof.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752954AbZIBFr7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2009 01:47:59 -0400
Content-Disposition: inline
In-Reply-To: <20090901055129.814907029@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 31, 2009 at 10:50:53PM -0700, Stephen Hemminger wrote:
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> ---
>  drivers/net/tulip/de2104x.c     |    3 ++-
>  drivers/net/tulip/de4x5.c       |   11 +++++------
>  drivers/net/tulip/dmfe.c        |    5 +++--
>  drivers/net/tulip/tulip_core.c  |    5 +++--
>  drivers/net/tulip/uli526x.c     |    6 ++++--
>  drivers/net/tulip/winbond-840.c |    4 ++--
>  drivers/net/tulip/xircom_cb.c   |    6 ++++--
>  7 files changed, 23 insertions(+), 17 deletions(-)
> 
> --- a/drivers/net/tulip/de2104x.c	2009-08-29 23:10:19.609527457 -0700
> +++ b/drivers/net/tulip/de2104x.c	2009-08-29 23:12:54.117527675 -0700
> @@ -599,7 +599,8 @@ next:
>  		netif_wake_queue(de->dev);
>  }
>  
> -static int de_start_xmit (struct sk_buff *skb, struct net_device *dev)
> +static netdev_tx_t de_start_xmit (struct sk_buff *skb,
> +					struct net_device *dev)

Stephen,
The patches look harmless and I'm inclined to ACK them...but google can't find
any context or explanation for "netdev_tx_t". URL to email which proposed
netdev_tx_t?

thanks,
grant
>  {
>  	struct de_private *de = netdev_priv(dev);
>  	unsigned int entry, tx_free;
> --- a/drivers/net/tulip/de4x5.c	2009-08-29 23:10:19.553491700 -0700
> +++ b/drivers/net/tulip/de4x5.c	2009-08-29 23:12:54.125526807 -0700
> @@ -895,7 +895,8 @@ static struct {
>  ** Public Functions
>  */
>  static int     de4x5_open(struct net_device *dev);
> -static int     de4x5_queue_pkt(struct sk_buff *skb, struct net_device *dev);
> +static netdev_tx_t de4x5_queue_pkt(struct sk_buff *skb,
> +					 struct net_device *dev);
>  static irqreturn_t de4x5_interrupt(int irq, void *dev_id);
>  static int     de4x5_close(struct net_device *dev);
>  static struct  net_device_stats *de4x5_get_stats(struct net_device *dev);
> @@ -1456,18 +1457,16 @@ de4x5_sw_reset(struct net_device *dev)
>  /*
>  ** Writes a socket buffer address to the next available transmit descriptor.
>  */
> -static int
> +static netdev_tx_t
>  de4x5_queue_pkt(struct sk_buff *skb, struct net_device *dev)
>  {
>      struct de4x5_private *lp = netdev_priv(dev);
>      u_long iobase = dev->base_addr;
> -    int status = NETDEV_TX_OK;
>      u_long flags = 0;
>  
>      netif_stop_queue(dev);
> -    if (!lp->tx_enable) {                   /* Cannot send for now */
> +    if (!lp->tx_enable)                   /* Cannot send for now */
>  	return NETDEV_TX_LOCKED;
> -    }
>  
>      /*
>      ** Clean out the TX ring asynchronously to interrupts - sometimes the
> @@ -1521,7 +1520,7 @@ de4x5_queue_pkt(struct sk_buff *skb, str
>  
>      lp->cache.lock = 0;
>  
> -    return status;
> +    return NETDEV_TX_OK;
>  }
>  
>  /*
> --- a/drivers/net/tulip/dmfe.c	2009-08-29 23:10:19.521492310 -0700
> +++ b/drivers/net/tulip/dmfe.c	2009-08-29 23:12:54.129527736 -0700
> @@ -311,7 +311,7 @@ static u8 SF_mode;		/* Special Function:
>  
>  /* function declaration ------------------------------------- */
>  static int dmfe_open(struct DEVICE *);
> -static int dmfe_start_xmit(struct sk_buff *, struct DEVICE *);
> +static netdev_tx_t dmfe_start_xmit(struct sk_buff *, struct DEVICE *);
>  static int dmfe_stop(struct DEVICE *);
>  static void dmfe_set_filter_mode(struct DEVICE *);
>  static const struct ethtool_ops netdev_ethtool_ops;
> @@ -661,7 +661,8 @@ static void dmfe_init_dm910x(struct DEVI
>   *	Send a packet to media from the upper layer.
>   */
>  
> -static int dmfe_start_xmit(struct sk_buff *skb, struct DEVICE *dev)
> +static netdev_tx_t dmfe_start_xmit(struct sk_buff *skb,
> +					 struct DEVICE *dev)
>  {
>  	struct dmfe_board_info *db = netdev_priv(dev);
>  	struct tx_desc *txptr;
> --- a/drivers/net/tulip/tulip_core.c	2009-08-29 23:10:19.589491808 -0700
> +++ b/drivers/net/tulip/tulip_core.c	2009-08-29 23:12:54.129527736 -0700
> @@ -256,7 +256,8 @@ const char tulip_media_cap[32] =
>  static void tulip_tx_timeout(struct net_device *dev);
>  static void tulip_init_ring(struct net_device *dev);
>  static void tulip_free_ring(struct net_device *dev);
> -static int tulip_start_xmit(struct sk_buff *skb, struct net_device *dev);
> +static netdev_tx_t tulip_start_xmit(struct sk_buff *skb,
> +					  struct net_device *dev);
>  static int tulip_open(struct net_device *dev);
>  static int tulip_close(struct net_device *dev);
>  static void tulip_up(struct net_device *dev);
> @@ -645,7 +646,7 @@ static void tulip_init_ring(struct net_d
>  	tp->tx_ring[i-1].buffer2 = cpu_to_le32(tp->tx_ring_dma);
>  }
>  
> -static int
> +static netdev_tx_t
>  tulip_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  {
>  	struct tulip_private *tp = netdev_priv(dev);
> --- a/drivers/net/tulip/uli526x.c	2009-08-29 23:10:19.637530461 -0700
> +++ b/drivers/net/tulip/uli526x.c	2009-08-29 23:12:54.133492067 -0700
> @@ -215,7 +215,8 @@ static int mode = 8;
>  
>  /* function declaration ------------------------------------- */
>  static int uli526x_open(struct net_device *);
> -static int uli526x_start_xmit(struct sk_buff *, struct net_device *);
> +static netdev_tx_t uli526x_start_xmit(struct sk_buff *,
> +					    struct net_device *);
>  static int uli526x_stop(struct net_device *);
>  static void uli526x_set_filter_mode(struct net_device *);
>  static const struct ethtool_ops netdev_ethtool_ops;
> @@ -567,7 +568,8 @@ static void uli526x_init(struct net_devi
>   *	Send a packet to media from the upper layer.
>   */
>  
> -static int uli526x_start_xmit(struct sk_buff *skb, struct net_device *dev)
> +static netdev_tx_t uli526x_start_xmit(struct sk_buff *skb,
> +					    struct net_device *dev)
>  {
>  	struct uli526x_board_info *db = netdev_priv(dev);
>  	struct tx_desc *txptr;
> --- a/drivers/net/tulip/winbond-840.c	2009-08-29 23:10:19.537492110 -0700
> +++ b/drivers/net/tulip/winbond-840.c	2009-08-29 23:12:54.133492067 -0700
> @@ -333,7 +333,7 @@ static void init_registers(struct net_de
>  static void tx_timeout(struct net_device *dev);
>  static int alloc_ringdesc(struct net_device *dev);
>  static void free_ringdesc(struct netdev_private *np);
> -static int  start_tx(struct sk_buff *skb, struct net_device *dev);
> +static netdev_tx_t start_tx(struct sk_buff *skb, struct net_device *dev);
>  static irqreturn_t intr_handler(int irq, void *dev_instance);
>  static void netdev_error(struct net_device *dev, int intr_status);
>  static int  netdev_rx(struct net_device *dev);
> @@ -997,7 +997,7 @@ static void free_ringdesc(struct netdev_
>  
>  }
>  
> -static int start_tx(struct sk_buff *skb, struct net_device *dev)
> +static netdev_tx_t start_tx(struct sk_buff *skb, struct net_device *dev)
>  {
>  	struct netdev_private *np = netdev_priv(dev);
>  	unsigned entry;
> --- a/drivers/net/tulip/xircom_cb.c	2009-08-29 23:10:19.505491812 -0700
> +++ b/drivers/net/tulip/xircom_cb.c	2009-08-29 23:12:54.137512691 -0700
> @@ -113,7 +113,8 @@ struct xircom_private {
>  static int xircom_probe(struct pci_dev *pdev, const struct pci_device_id *id);
>  static void xircom_remove(struct pci_dev *pdev);
>  static irqreturn_t xircom_interrupt(int irq, void *dev_instance);
> -static int xircom_start_xmit(struct sk_buff *skb, struct net_device *dev);
> +static netdev_tx_t xircom_start_xmit(struct sk_buff *skb,
> +					   struct net_device *dev);
>  static int xircom_open(struct net_device *dev);
>  static int xircom_close(struct net_device *dev);
>  static void xircom_up(struct xircom_private *card);
> @@ -384,7 +385,8 @@ static irqreturn_t xircom_interrupt(int 
>  	return IRQ_HANDLED;
>  }
>  
> -static int xircom_start_xmit(struct sk_buff *skb, struct net_device *dev)
> +static netdev_tx_t xircom_start_xmit(struct sk_buff *skb,
> +					   struct net_device *dev)
>  {
>  	struct xircom_private *card;
>  	unsigned long flags;
> 
> -- 
