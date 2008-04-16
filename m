From: Stephen Hemminger <shemminger@vyatta.com>
Subject: gianfar: rx buffer management
Date: Wed, 16 Apr 2008 15:10:58 -0700
Message-ID: <20080416151058.26ceaf42@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>, Andy@mail.vyatta.com,
	"Fleming <afleming"@freescale.com,
	Becky Bruce <bgill@freescale.com>,
	Kumar Gala <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:53208 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752772AbYDPWLE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Apr 2008 18:11:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I was looking at all drivers to update them to use netdev_alloc_skb
and noticed this turd in the gianfar.c driver:

struct sk_buff * gfar_new_skb(struct net_device *dev, struct rxbd8 *bdp)
{
	unsigned int alignamount;
	struct gfar_private *priv = netdev_priv(dev);
	struct sk_buff *skb = NULL;
	unsigned int timeout = SKB_ALLOC_TIMEOUT;

	/* We have to allocate the skb, so keep trying till we succeed */
	while ((!skb) && timeout--)
		skb = dev_alloc_skb(priv->rx_buffer_size + RXBUF_ALIGNMENT);


Trying a million times in softirq is not going to work. Please change to use
a more sane strategy. Probably the simples would be to allocate a new skb
before processing the current buffer and if that fails, just drop the current
rx packet and reuse the skb.
