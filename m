From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/4] veth: move loopback logic to common location
Date: Tue, 24 Nov 2009 10:51:19 +0100
Message-ID: <4B0BAC97.6010000@trash.net>
References: <1259024166-28158-1-git-send-email-arnd@arndb.de> <1259024166-28158-2-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Patrick Mullaney <pmullaney@novell.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Edge Virtual Bridging <evb@yahoogroups.com>,
	Anna Fischer <anna.fischer@hp.com>,
	bridge@lists.linux-foundation.org,
	virtualization@lists.linux-foundation.org,
	Jens Osterkamp <jens@linux.vnet.ibm.com>,
	Gerhard Stenzel <gerhard.stenzel@de.ibm.com>,
	Mark Smith <lk-netdev@lk-netdev.nosense.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63668 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932460AbZKXJvQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2009 04:51:16 -0500
In-Reply-To: <1259024166-28158-2-git-send-email-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arnd Bergmann wrote:
> +int dev_forward_skb(struct net_device *dev, struct sk_buff *skb)
> +{
> +	skb_orphan(skb);
> +
> +	if (!(dev->flags & IFF_UP))
> +		return NET_RX_DROP;
> +
> +	if (skb->len > (dev->mtu + dev->hard_header_len))
> +		return NET_RX_DROP;
> +
> +	skb_dst_drop(skb);
> +	skb->tstamp.tv64 = 0;
> +	skb->pkt_type = PACKET_HOST;
> +	skb->protocol = eth_type_trans(skb, dev);
> +	skb->mark = 0;

skb->mark clearing should stay private to veth since its usually
supposed to stay intact. The only exception is packets crossing
namespaces, where they should appear like a freshly received skbs.

> +	secpath_reset(skb);
> +	nf_reset(skb);
> +	return netif_rx(skb);
> +}
> +EXPORT_SYMBOL_GPL(dev_forward_skb);
