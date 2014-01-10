From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Layer 2 acceleration vs GSO
Date: Fri, 10 Jan 2014 20:05:39 +0000
Message-ID: <1389384339.2025.88.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	netdev <netdev@vger.kernel.org>
To: John Fastabend <john.r.fastabend@intel.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:43831 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751262AbaAJUFo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 15:05:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

What happens when an skb to be sent through ndo_dfwd_start_xmit()
requires software GSO?

dev_hard_start_xmit() will segment it and then submit each segment, and
then:

> gso:
> 	do {
[...]
> 		if (accel_priv)
> 			rc = ops->ndo_dfwd_start_xmit(nskb, dev, accel_priv);
> 		else
> 			rc = ops->ndo_start_xmit(nskb, dev);
> 		trace_net_dev_xmit(nskb, rc, dev, skb_len);
[...]
> 		txq_trans_update(txq);

Oops, txq is NULL.  And once we add the obvious condition to that,

> 		if (unlikely(netif_xmit_stopped(txq) && skb->next))
> 			return NETDEV_TX_BUSY;

How can we tell if the hardware transmit queue filled up?

It seems like this feature currently relies on the driver returning
NETDEV_TX_BUSY when the TX queue is already full, like ixgbe does.  But
that is exactly what drivers are *not* supposed to do.

Ben.

> 	} while (skb->next);

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
