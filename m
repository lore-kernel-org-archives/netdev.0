From: "David S. Miller" <davem@davemloft.net>
Subject: Re: LLTX and netif_stop_queue
Date: Fri, 17 Dec 2004 21:44:32 -0800
Message-ID: <20041217214432.07b7b21e.davem@davemloft.net>
References: <52llbwoaej.fsf@topspin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: Roland Dreier <roland@topspin.com>
In-Reply-To: <52llbwoaej.fsf@topspin.com>
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

On Fri, 17 Dec 2004 13:57:40 -0800
Roland Dreier <roland@topspin.com> wrote:

> While testing my IP-over-InfiniBand driver, I discovered that if a net
> device sets NETIF_F_LLTX, it seems the device's hard_start_xmit method
> can be called even after a netif_stop_queue().
> 
> This is because in the LLTX case, qdisc_restart() holds no locks while
> calling hard_start_xmit, so something like the following can happen:

 ...
>  	if (TX_BUFFS_AVAIL(gp) <= (skb_shinfo(skb)->nr_frags + 1)) {
>  		netif_stop_queue(dev);
>  		spin_unlock_irqrestore(&gp->tx_lock, flags);
> -		printk(KERN_ERR PFX "%s: BUG! Tx Ring full when queue awake!\n",
> -		       dev->name);
>  		return NETDEV_TX_BUSY;
>  	}

I understand the bug, but we're not going to fix it this way.
This is a crucial invariant that we need to check for because it
indicates a pretty serious state error except in this bug case
you've discovered.

Perhaps one way to fix this is to add a pointer to a spinlock to
the netdev struct, and have hold that the upper level grab that
when NETIF_F_LLTX when doing queue state checks.  Actually, that
could end up being racy too.

If we can't find a good fix for this, besides removing the necessary
debugging message, we might have to pull NETIF_F_LLTX out or disable it
temporarily until we figure out a way.
