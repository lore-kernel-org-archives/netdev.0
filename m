From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 3/7] [PATCH 3/8] can: CAN Network device driver and
 Netlink interface
Date: Tue, 12 May 2009 23:30:52 -0700
Message-ID: <20090512233052.ecd600f1.akpm@linux-foundation.org>
References: <20090512092757.048938233@denx.de>
	<20090512092757.574693100@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:54448 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751436AbZEMGdP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2009 02:33:15 -0400
In-Reply-To: <20090512092757.574693100@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 12 May 2009 11:28:00 +0200 Wolfgang Grandegger <wg@grandegger.com> wrote:

> +int can_restart_now(struct net_device *dev)
> +{
> +	struct can_priv *priv = netdev_priv(dev);
> +	struct net_device_stats *stats = &dev->stats;
> +	struct sk_buff *skb;
> +	struct can_frame *cf;
> +	int err;
> +
> +	/* Synchronize with dev->hard_start_xmit() */
> +	netif_tx_lock(dev);
> +
> +	/* Ensure that no more messages can go out */
> +	if (netif_carrier_ok(dev))
> +		netif_carrier_off(dev);
> +
> +	/* Ensure that no more messages can come in */
> +	err = priv->do_set_mode(dev, CAN_MODE_STOP);
> +	if (err)
> +		return err;
> +
> +	/*  Now it's save to clean up */
> +	del_timer_sync(&priv->restart_timer);

This is deadlockable.

It calls del_timer_sync() while holding netif_tx_lock().  But the timer
handler (can_restart_now()) also takes netif_tx_lock().  So if the
timer handler is presently running, it's sitting there spinning in
netif_tx_lock().  And del_timer_sync() is sitting there waiting for the
timer handler to complete.


