From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH v2 3/7] [PATCH 3/8] can: CAN Network device driver and
 Netlink interface
Date: Thu, 14 May 2009 09:55:52 +0200
Message-ID: <4A0BCE88.6020801@grandegger.com>
References: <20090512092757.048938233@denx.de>	<20090512092757.574693100@denx.de> <20090513153112.0822809b@bike.lwn.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
To: Jonathan Corbet <corbet@lwn.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:46556 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760083AbZENHzy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2009 03:55:54 -0400
In-Reply-To: <20090513153112.0822809b@bike.lwn.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jonathan Corbet wrote:
> [Quick review ...]
> 
>> +/*
>> + * CAN device restart for bus-off recovery
>> + */
>> +int can_restart_now(struct net_device *dev)
>> +{
>> +	struct can_priv *priv = netdev_priv(dev);
>> +	struct net_device_stats *stats = &dev->stats;
>> +	struct sk_buff *skb;
>> +	struct can_frame *cf;
>> +	int err;
>> +
>> +	/* Synchronize with dev->hard_start_xmit() */
>> +	netif_tx_lock(dev);
>> +
>> +	/* Ensure that no more messages can go out */
>> +	if (netif_carrier_ok(dev))
>> +		netif_carrier_off(dev);
>> +
>> +	/* Ensure that no more messages can come in */
>> +	err = priv->do_set_mode(dev, CAN_MODE_STOP);
>> +	if (err)
>> +		return err;
> 
> This leaves _xmit_lock held and carrier off.  Is that really what you want
> to do?
> 
>> +
>> +	/*  Now it's save to clean up */
>> +	del_timer_sync(&priv->restart_timer);
>> +	can_flush_echo_skb(dev);
>> +
>> +	dev_dbg(dev->dev.parent, "restarted\n");
>> +	priv->can_stats.restarts++;
>> +
>> +	/* send restart message upstream */
>> +	skb = dev_alloc_skb(sizeof(struct can_frame));
>> +	if (skb == NULL)
>> +		return -ENOMEM;
> 
> ...here too...
> 
>> +	skb->dev = dev;
>> +	skb->protocol = htons(ETH_P_CAN);
>> +	cf = (struct can_frame *)skb_put(skb, sizeof(struct can_frame));
>> +	memset(cf, 0, sizeof(struct can_frame));
>> +	cf->can_id = CAN_ERR_FLAG | CAN_ERR_RESTARTED;
>> +	cf->can_dlc = CAN_ERR_DLC;
>> +
>> +	netif_rx(skb);
>> +
>> +	dev->last_rx = jiffies;
>> +	stats->rx_packets++;
>> +	stats->rx_bytes += cf->can_dlc;
>> +
>> +	/* Now restart the device */
>> +	err = priv->do_set_mode(dev, CAN_MODE_START);
>> +	if (err)
>> +		return err;
> 
> ...and here too.  Do you maybe want to get rid of the middle-of-function
> returns and switch to the "goto out" convention?

Right, needs to be fixed.

>> +	netif_carrier_on(dev);
>> +
>> +	netif_tx_unlock(dev);
>> +
>> +	return 0;
>> +}
>> +
>> +static void can_restart_after(unsigned long data)
>> +{
>> +	struct net_device *dev = (struct net_device *)data;
>> +
>> +	can_restart_now(dev);
>> +}
> 
> can_restart_after what?  I find myself confused by this function and
> wondering why it exists.

It's just a wrapper to make the compile happy. It's the timer callback
function used here:

          priv->restart_timer.function = can_restart_after;

in contrast to can_restart_now(), which can be called via netlink
interface as well. Would the name "can_restart_callback" be more
appropriate?

Wolfgang.
