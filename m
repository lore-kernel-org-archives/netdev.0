From: Chris Snook <csnook@redhat.com>
Subject: Re: [PATCH] net: remove LLTX in atl2 driver
Date: Thu, 25 Sep 2008 16:30:21 -0400
Message-ID: <48DBF4DD.8060908@redhat.com>
References: <1222302922-13200-1-git-send-email-kexin.hao@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@redhat.com>,
	Jay Cliburn <jacliburn@bellsouth.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Kevin Hao <kexin.hao@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:56865 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752760AbYIYUbF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Sep 2008 16:31:05 -0400
In-Reply-To: <1222302922-13200-1-git-send-email-kexin.hao@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kevin Hao wrote:
> When NETIF_F_LLTX is set, the atlx driver will use a private lock.
> But in recent kernels this implementation seems redundant and
> can cause problems where AF_PACKET sees things twice. Since
> NETIF_F_LLTX is marked as deprecated and shouldn't be used in
> new driver, this patch removes NETIF_F_LLTX and adds a mmiowb
> before sending packet.
> 
> Signed-off-by: Kevin Hao <kexin.hao@windriver.com>

Can you explain a bit more concretely the problem this solves, and your testing? 
  Ultimately we'll want to merge this code with the atl1 code, so we need to be 
confident that we can and should make the same change there.

-- Chris

> ---
>  drivers/net/atlx/atl2.c |   24 +-----------------------
>  drivers/net/atlx/atl2.h |    1 -
>  2 files changed, 1 insertions(+), 24 deletions(-)
> 
> diff --git a/drivers/net/atlx/atl2.c b/drivers/net/atlx/atl2.c
> index b2995ac..3df4ee1 100644
> --- a/drivers/net/atlx/atl2.c
> +++ b/drivers/net/atlx/atl2.c
> @@ -116,7 +116,6 @@ static int __devinit atl2_sw_init(struct atl2_adapter *adapter)
>  	hw->max_frame_size = adapter->netdev->mtu;
>  
>  	spin_lock_init(&adapter->stats_lock);
> -	spin_lock_init(&adapter->tx_lock);
>  
>  	set_bit(__ATL2_DOWN, &adapter->flags);
>  
> @@ -749,11 +748,7 @@ static void atl2_down(struct atl2_adapter *adapter)
>  	 * reschedule our watchdog timer */
>  	set_bit(__ATL2_DOWN, &adapter->flags);
>  
> -#ifdef NETIF_F_LLTX
> -	netif_stop_queue(netdev);
> -#else
>  	netif_tx_disable(netdev);
> -#endif
>  
>  	/* reset MAC to disable all RX/TX */
>  	atl2_reset_hw(&adapter->hw);
> @@ -829,7 +824,6 @@ static inline int TxdFreeBytes(struct atl2_adapter *adapter)
>  static int atl2_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
>  {
>  	struct atl2_adapter *adapter = netdev_priv(netdev);
> -	unsigned long flags;
>  	struct tx_pkt_header *txph;
>  	u32 offset, copy_len;
>  	int txs_unused;
> @@ -845,16 +839,6 @@ static int atl2_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
>  		return NETDEV_TX_OK;
>  	}
>  
> -#ifdef NETIF_F_LLTX
> -	local_irq_save(flags);
> -	if (!spin_trylock(&adapter->tx_lock)) {
> -		/* Collision - tell upper layer to requeue */
> -		local_irq_restore(flags);
> -		return NETDEV_TX_LOCKED;
> -	}
> -#else
> -	spin_lock_irqsave(&adapter->tx_lock, flags);
> -#endif
>  	txs_unused = TxsFreeUnit(adapter);
>  	txbuf_unused = TxdFreeBytes(adapter);
>  
> @@ -862,7 +846,6 @@ static int atl2_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
>  		txs_unused < 1) {
>  		/* not enough resources */
>  		netif_stop_queue(netdev);
> -		spin_unlock_irqrestore(&adapter->tx_lock, flags);
>  		return NETDEV_TX_BUSY;
>  	}
>  
> @@ -908,8 +891,7 @@ static int atl2_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
>  	ATL2_WRITE_REGW(&adapter->hw, REG_MB_TXD_WR_IDX,
>  		(adapter->txd_write_ptr >> 2));
>  
> -	spin_unlock_irqrestore(&adapter->tx_lock, flags);
> -
> +	mmiowb();
>  	netdev->trans_start = jiffies;
>  	dev_kfree_skb_any(skb);
>  	return NETDEV_TX_OK;
> @@ -1447,10 +1429,6 @@ static int __devinit atl2_probe(struct pci_dev *pdev,
>  	netdev->features |= (NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX);
>  #endif
>  
> -#ifdef NETIF_F_LLTX
> -	netdev->features |= NETIF_F_LLTX;
> -#endif
> -
>  	/* Init PHY as early as possible due to power saving issue  */
>  	atl2_phy_init(&adapter->hw);
>  
> diff --git a/drivers/net/atlx/atl2.h b/drivers/net/atlx/atl2.h
> index 6e1f28f..09974df 100644
> --- a/drivers/net/atlx/atl2.h
> +++ b/drivers/net/atlx/atl2.h
> @@ -462,7 +462,6 @@ struct atl2_adapter {
>  	u16 link_duplex;
>  
>  	spinlock_t stats_lock;
> -	spinlock_t tx_lock;
>  
>  	struct work_struct reset_task;
>  	struct work_struct link_chg_task;

