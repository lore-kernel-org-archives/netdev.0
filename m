From: "David S. Miller" <davem@davemloft.net>
Subject: LLTX fix proposal
Date: Sun, 30 Jan 2005 18:18:54 -0800
Message-ID: <20050130181854.7f088a95.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Ok, how about we do this for 2.6.11 before it goes out and
do something more sophisticated (if necessary) later.

The BUG() we're trying to catch in the ->hard_start_xmit()
routines is the illegal state:

	driver_tx_queue_empty() && !netif_queue_stopped(dev)

Therefore we could handle the race, and avoid the printk() in
the race case but not in the BUG() case above.  The test in
tg3.c is currently:

	/* This is a hard error, log it. */
	if (unlikely(TX_BUFFS_AVAIL(tp) <= (skb_shinfo(skb)->nr_frags + 1))) {
		netif_stop_queue(dev);
		spin_unlock_irqrestore(&tp->tx_lock, flags);
		printk(KERN_ERR PFX "%s: BUG! Tx Ring full when queue awake!\n",
		       dev->name);
		return NETDEV_TX_BUSY;
	}

and I'm proposing we change it to something like:

	if (unlikely(TX_BUFFS_AVAIL(tp) <= (skb_shinfo(skb)->nr_frags + 1))) {
		/* We can race with queue processing on another
		 * cpu due to LLTX.  If the queue is not stopped,
		 * that is a hard error, log it.
		 */
		if (!netif_queue_stopped(dev)) {
			netif_stop_queue(dev);
			printk(KERN_ERR PFX "%s: BUG! Tx Ring full when "
			       "queue awake!\n",
			       dev->name);
		}
		spin_unlock_irqrestore(&tp->tx_lock, flags);
		return NETDEV_TX_BUSY;
	}

Any objections?

Again, I'm not saying %100 this is what we should do long-term.
It's meant to be correct and eliminate the bogus log messages
when the LLTX race is hit.
