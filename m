From: Eric Lemoine <eric.lemoine@gmail.com>
Subject: Re: [PATCH] LLTX for tg3
Date: Sun, 12 Sep 2004 19:06:26 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <5cac192f040912100616feb28a@mail.gmail.com>
References: <20040907121841.GA4398@wotan.suse.de>
Reply-To: Eric Lemoine <eric.lemoine@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20040907121841.GA4398@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Add LLTX suppor to tg3.  Locking was already safe for it, so only
> trivial changes.

tg3_set_rx_mode() (dev->set_multicast_list()) and tg3_start_xmit()
used to synchronise thanks to dev->lock_xmit. With your LLTX patches
they don't synchronise anymore (I don't think tg3_set_rx_mode() grabs
tp->tx_lock) ; isn't it an issue?

PS: your LLTX patch to e1000 seems to have the needed extra locking in
e1000_set_multi() though.

> Depends on the LLTX patch sent earlier.
> 
> diff -u linux-2.6.8/drivers/net/tg3.c-o linux-2.6.8/drivers/net/tg3.c
> --- linux-2.6.8/drivers/net/tg3.c-o     2004-09-04 13:10:46.000000000 +0000
> +++ linux-2.6.8/drivers/net/tg3.c       2004-09-07 08:17:36.000000000 +0000
> @@ -3036,7 +3036,11 @@
>          * So we really do need to disable interrupts when taking
>          * tx_lock here.
>          */
> -       spin_lock_irqsave(&tp->tx_lock, flags);
> +       local_irq_save(flags);
> +       if (!spin_trylock(&tp->tx_lock)) {
> +               local_irq_restore(flags);
> +               return -1;
> +       }
> 
>         /* This is a hard error, log it. */
>         if (unlikely(TX_BUFFS_AVAIL(tp) <= (skb_shinfo(skb)->nr_frags + 1))) {
> @@ -8255,6 +8259,7 @@
> 
>         if (pci_using_dac)
>                 dev->features |= NETIF_F_HIGHDMA;
> +       dev->features |= NETIF_F_LLTX;
>  #if TG3_VLAN_TAG_USED
>         dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
>         dev->vlan_rx_register = tg3_vlan_rx_register;
> 
> 

-- 
Eric
