From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gianfar: reallocate skb when headroom is not enough
 for fcb
Date: Wed, 25 Mar 2009 14:49:59 -0700 (PDT)
Message-ID: <20090325.144959.02893509.davem@davemloft.net>
References: <20090325.000643.55804624.davem@davemloft.net>
	<1237972533-11195-1-git-send-email-leoli@freescale.com>
	<20090325085333.4bb73f55@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: leoli@freescale.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51477
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752974AbZCYVuL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 17:50:11 -0400
In-Reply-To: <20090325085333.4bb73f55@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 25 Mar 2009 08:53:33 -0700

> Overall, this looks like the wrong code (not copying back new skb)
> and in awkward place. Also your version doesn't handle case where
> skb headroom is not writable.

headroom is always writable and usable by the driver, this
is the exact same code sequence we use in drivers/net/niu.c
for this purpose:

	len = sizeof(struct tx_pkt_hdr) + 15;
	if (skb_headroom(skb) < len) {
		struct sk_buff *skb_new;

		skb_new = skb_realloc_headroom(skb, len);
		if (!skb_new) {
			rp->tx_errors++;
			goto out_drop;
		}
		kfree_skb(skb);
		skb = skb_new;

otherwise the code we just came from wouldn't be able
to push even the ethernet header there.
