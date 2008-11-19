From: "Tomas Winkler" <tomasw@gmail.com>
Subject: Re: pull request: wireless-2.6 2008-11-18
Date: Wed, 19 Nov 2008 08:46:28 +0200
Message-ID: <1ba2fa240811182246m17a6baf0ybde19af030a65819@mail.gmail.com>
References: <20081119000719.GA19756@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	sfr@canb.auug.org.au
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.239]:32583 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751673AbYKSGq3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2008 01:46:29 -0500
Received: by rv-out-0506.google.com with SMTP id k40so3270736rvb.1
        for <netdev@vger.kernel.org>; Tue, 18 Nov 2008 22:46:28 -0800 (PST)
In-Reply-To: <20081119000719.GA19756@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 19, 2008 at 2:07 AM, John W. Linville
<linville@tuxdriver.com> wrote:
> Dave,
>
> Three fixes from Johannes, intended for 2.6.28...  One fixes a 32/64
> issue in libertas_tf, another removes a mac80211 callback only used
> by iwlwifi which is not obviously needed and which is causing locking
> issues, and a final one fixes some mysterious DMA alignment problems
> that have been plaguing iwlwifi for some time.
>
> Please let me know if there are problems!
>
> Thanks,
>
> John
>
> P.S.  The libertas_tf is actually already in net-next-2.6.  Also,
> the other fixes cause merge conflicts with net-next-2.6 -- I'll
> included a merge-test branch in wireless-next-2.6 to indicates how
> those conflicts should be resolved.
>
> ---
>
> Individual patches are available here:
>
>        http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/
>
> ---
>
> The following changes since commit 5f9021cfdc3524a4c5e3d7ae2d049eb7adcd6776:
>  Johannes Berg (1):
>        rtnetlink: propagate error from dev_change_flags in do_setlink()
>
> are available in the git repository at:
>
>  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master
>
> Johannes Berg (3):
>      libertas_tf: fix skb tail pointer
>      mac80211: remove ieee80211_notify_mac
>      iwlagn: fix RX skb alignment

IMHO its premature pushing ttese 2 patches up, they came in yestrday
and nobody here has run tthe code
Tomas

>
>  drivers/net/wireless/iwlwifi/iwl-agn.c      |    7 +++----
>  drivers/net/wireless/iwlwifi/iwl-dev.h      |    3 ++-
>  drivers/net/wireless/iwlwifi/iwl-rx.c       |   26 +++++++++++++++++---------
>  drivers/net/wireless/iwlwifi/iwl3945-base.c |    1 -
>  drivers/net/wireless/libertas_tf/if_usb.c   |    2 +-
>  include/net/mac80211.h                      |   20 --------------------
>  net/mac80211/mlme.c                         |   22 ----------------------
>  7 files changed, 23 insertions(+), 58 deletions(-)
>
> diff --git a/drivers/net/wireless/iwlwifi/iwl-agn.c b/drivers/net/wireless/iwlwifi/iwl-agn.c
> index 8d690a0..444c5cc 100644
> --- a/drivers/net/wireless/iwlwifi/iwl-agn.c
> +++ b/drivers/net/wireless/iwlwifi/iwl-agn.c
> @@ -1384,7 +1384,7 @@ void iwl_rx_handle(struct iwl_priv *priv)
>
>                rxq->queue[i] = NULL;
>
> -               pci_dma_sync_single_for_cpu(priv->pci_dev, rxb->dma_addr,
> +               pci_dma_sync_single_for_cpu(priv->pci_dev, rxb->aligned_dma_addr,
>                                            priv->hw_params.rx_buf_size,
>                                            PCI_DMA_FROMDEVICE);
>                pkt = (struct iwl_rx_packet *)rxb->skb->data;
> @@ -1436,8 +1436,8 @@ void iwl_rx_handle(struct iwl_priv *priv)
>                        rxb->skb = NULL;
>                }
>
> -               pci_unmap_single(priv->pci_dev, rxb->dma_addr,
> -                                priv->hw_params.rx_buf_size,
> +               pci_unmap_single(priv->pci_dev, rxb->real_dma_addr,
> +                                priv->hw_params.rx_buf_size + 256,
>                                 PCI_DMA_FROMDEVICE);
>                spin_lock_irqsave(&rxq->lock, flags);
>                list_add_tail(&rxb->list, &priv->rxq.rx_used);
> @@ -2341,7 +2341,6 @@ static void iwl_bg_alive_start(struct work_struct *data)
>        mutex_lock(&priv->mutex);
>        iwl_alive_start(priv);
>        mutex_unlock(&priv->mutex);
> -       ieee80211_notify_mac(priv->hw, IEEE80211_NOTIFY_RE_ASSOC);
>  }
>
>  static void iwl4965_bg_rf_kill(struct work_struct *work)
> diff --git a/drivers/net/wireless/iwlwifi/iwl-dev.h b/drivers/net/wireless/iwlwifi/iwl-dev.h
> index c018121..9966d4e 100644
> --- a/drivers/net/wireless/iwlwifi/iwl-dev.h
> +++ b/drivers/net/wireless/iwlwifi/iwl-dev.h
> @@ -89,7 +89,8 @@ extern struct iwl_cfg iwl5100_abg_cfg;
>  #define        DEFAULT_LONG_RETRY_LIMIT  4U
>
>  struct iwl_rx_mem_buffer {
> -       dma_addr_t dma_addr;
> +       dma_addr_t real_dma_addr;
> +       dma_addr_t aligned_dma_addr;
>        struct sk_buff *skb;
>        struct list_head list;
>  };
> diff --git a/drivers/net/wireless/iwlwifi/iwl-rx.c b/drivers/net/wireless/iwlwifi/iwl-rx.c
> index 7cde9d7..0509c16 100644
> --- a/drivers/net/wireless/iwlwifi/iwl-rx.c
> +++ b/drivers/net/wireless/iwlwifi/iwl-rx.c
> @@ -204,7 +204,7 @@ int iwl_rx_queue_restock(struct iwl_priv *priv)
>                list_del(element);
>
>                /* Point to Rx buffer via next RBD in circular buffer */
> -               rxq->bd[rxq->write] = iwl_dma_addr2rbd_ptr(priv, rxb->dma_addr);
> +               rxq->bd[rxq->write] = iwl_dma_addr2rbd_ptr(priv, rxb->aligned_dma_addr);
>                rxq->queue[rxq->write] = rxb;
>                rxq->write = (rxq->write + 1) & RX_QUEUE_MASK;
>                rxq->free_count--;
> @@ -251,7 +251,7 @@ void iwl_rx_allocate(struct iwl_priv *priv)
>                rxb = list_entry(element, struct iwl_rx_mem_buffer, list);
>
>                /* Alloc a new receive buffer */
> -               rxb->skb = alloc_skb(priv->hw_params.rx_buf_size,
> +               rxb->skb = alloc_skb(priv->hw_params.rx_buf_size + 256,
>                                __GFP_NOWARN | GFP_ATOMIC);
>                if (!rxb->skb) {
>                        if (net_ratelimit())
> @@ -266,9 +266,17 @@ void iwl_rx_allocate(struct iwl_priv *priv)
>                list_del(element);
>
>                /* Get physical address of RB/SKB */
> -               rxb->dma_addr =
> -                   pci_map_single(priv->pci_dev, rxb->skb->data,
> -                          priv->hw_params.rx_buf_size, PCI_DMA_FROMDEVICE);
> +               rxb->real_dma_addr = pci_map_single(
> +                                       priv->pci_dev,
> +                                       rxb->skb->data,
> +                                       priv->hw_params.rx_buf_size + 256,
> +                                       PCI_DMA_FROMDEVICE);
> +               /* dma address must be no more than 36 bits */
> +               BUG_ON(rxb->real_dma_addr & ~DMA_BIT_MASK(36));
> +               /* and also 256 byte aligned! */
> +               rxb->aligned_dma_addr = ALIGN(rxb->real_dma_addr, 256);
> +               skb_reserve(rxb->skb, rxb->aligned_dma_addr - rxb->real_dma_addr);
> +
>                list_add_tail(&rxb->list, &rxq->rx_free);
>                rxq->free_count++;
>        }
> @@ -300,8 +308,8 @@ void iwl_rx_queue_free(struct iwl_priv *priv, struct iwl_rx_queue *rxq)
>        for (i = 0; i < RX_QUEUE_SIZE + RX_FREE_BUFFERS; i++) {
>                if (rxq->pool[i].skb != NULL) {
>                        pci_unmap_single(priv->pci_dev,
> -                                        rxq->pool[i].dma_addr,
> -                                        priv->hw_params.rx_buf_size,
> +                                        rxq->pool[i].real_dma_addr,
> +                                        priv->hw_params.rx_buf_size + 256,
>                                         PCI_DMA_FROMDEVICE);
>                        dev_kfree_skb(rxq->pool[i].skb);
>                }
> @@ -354,8 +362,8 @@ void iwl_rx_queue_reset(struct iwl_priv *priv, struct iwl_rx_queue *rxq)
>                 * to an SKB, so we need to unmap and free potential storage */
>                if (rxq->pool[i].skb != NULL) {
>                        pci_unmap_single(priv->pci_dev,
> -                                        rxq->pool[i].dma_addr,
> -                                        priv->hw_params.rx_buf_size,
> +                                        rxq->pool[i].real_dma_addr,
> +                                        priv->hw_params.rx_buf_size + 256,
>                                         PCI_DMA_FROMDEVICE);
>                        priv->alloc_rxb_skb--;
>                        dev_kfree_skb(rxq->pool[i].skb);
> diff --git a/drivers/net/wireless/iwlwifi/iwl3945-base.c b/drivers/net/wireless/iwlwifi/iwl3945-base.c
> index 285b53e..45a6b0c 100644
> --- a/drivers/net/wireless/iwlwifi/iwl3945-base.c
> +++ b/drivers/net/wireless/iwlwifi/iwl3945-base.c
> @@ -6012,7 +6012,6 @@ static void iwl3945_bg_alive_start(struct work_struct *data)
>        mutex_lock(&priv->mutex);
>        iwl3945_alive_start(priv);
>        mutex_unlock(&priv->mutex);
> -       ieee80211_notify_mac(priv->hw, IEEE80211_NOTIFY_RE_ASSOC);
>  }
>
>  static void iwl3945_bg_rf_kill(struct work_struct *work)
> diff --git a/drivers/net/wireless/libertas_tf/if_usb.c b/drivers/net/wireless/libertas_tf/if_usb.c
> index 1cc03a8..59634c3 100644
> --- a/drivers/net/wireless/libertas_tf/if_usb.c
> +++ b/drivers/net/wireless/libertas_tf/if_usb.c
> @@ -331,7 +331,7 @@ static int __if_usb_submit_rx_urb(struct if_usb_card *cardp,
>        /* Fill the receive configuration URB and initialise the Rx call back */
>        usb_fill_bulk_urb(cardp->rx_urb, cardp->udev,
>                          usb_rcvbulkpipe(cardp->udev, cardp->ep_in),
> -                         (void *) (skb->tail),
> +                         skb_tail_pointer(skb),
>                          MRVDRV_ETH_RX_PACKET_BUFFER_SIZE, callbackfn, cardp);
>
>        cardp->rx_urb->transfer_flags |= URB_ZERO_PACKET;
> diff --git a/include/net/mac80211.h b/include/net/mac80211.h
> index 8856e2d..73d81bc 100644
> --- a/include/net/mac80211.h
> +++ b/include/net/mac80211.h
> @@ -74,14 +74,6 @@
>  */
>
>  /**
> - * enum ieee80211_notification_type - Low level driver notification
> - * @IEEE80211_NOTIFY_RE_ASSOC: start the re-association sequence
> - */
> -enum ieee80211_notification_types {
> -       IEEE80211_NOTIFY_RE_ASSOC,
> -};
> -
> -/**
>  * struct ieee80211_ht_bss_info - describing BSS's HT characteristics
>  *
>  * This structure describes most essential parameters needed
> @@ -1798,18 +1790,6 @@ void ieee80211_stop_tx_ba_cb_irqsafe(struct ieee80211_hw *hw, const u8 *ra,
>                                     u16 tid);
>
>  /**
> - * ieee80211_notify_mac - low level driver notification
> - * @hw: pointer as obtained from ieee80211_alloc_hw().
> - * @notif_type: enum ieee80211_notification_types
> - *
> - * This function must be called by low level driver to inform mac80211 of
> - * low level driver status change or force mac80211 to re-assoc for low
> - * level driver internal error that require re-assoc.
> - */
> -void ieee80211_notify_mac(struct ieee80211_hw *hw,
> -                         enum ieee80211_notification_types  notif_type);
> -
> -/**
>  * ieee80211_find_sta - find a station
>  *
>  * @hw: pointer as obtained from ieee80211_alloc_hw()
> diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
> index 14d165f..409bb77 100644
> --- a/net/mac80211/mlme.c
> +++ b/net/mac80211/mlme.c
> @@ -2560,25 +2560,3 @@ void ieee80211_mlme_notify_scan_completed(struct ieee80211_local *local)
>                ieee80211_restart_sta_timer(sdata);
>        rcu_read_unlock();
>  }
> -
> -/* driver notification call */
> -void ieee80211_notify_mac(struct ieee80211_hw *hw,
> -                         enum ieee80211_notification_types  notif_type)
> -{
> -       struct ieee80211_local *local = hw_to_local(hw);
> -       struct ieee80211_sub_if_data *sdata;
> -
> -       switch (notif_type) {
> -       case IEEE80211_NOTIFY_RE_ASSOC:
> -               rtnl_lock();
> -               list_for_each_entry(sdata, &local->interfaces, list) {
> -                       if (sdata->vif.type != NL80211_IFTYPE_STATION)
> -                               continue;
> -
> -                       ieee80211_sta_req_auth(sdata, &sdata->u.sta);
> -               }
> -               rtnl_unlock();
> -               break;
> -       }
> -}
> -EXPORT_SYMBOL(ieee80211_notify_mac);
> --
> John W. Linville                Linux should be at the core
> linville@tuxdriver.com                  of your literate lifestyle.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>
