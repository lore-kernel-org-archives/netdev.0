From: Maxim Levitsky <maximlevitsky@gmail.com>
Subject: Re: [PATCH 3/5] NET: IPV4: ARP: allow to invalidate specific ARP
 entries
Date: Sun, 05 Dec 2010 01:15:14 +0200
Message-ID: <1291504514.1874.92.camel@maxim-laptop>
References: <1290996593-32416-1-git-send-email-maximlevitsky@gmail.com>
	 <1290996593-32416-4-git-send-email-maximlevitsky@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stefan Richter <stefanr@s5r6.in-berlin.de>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Patrick McHardy <kaber@trash.net>
To: linux1394-devel <linux1394-devel@lists.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:62286 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755025Ab0LDXPS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Dec 2010 18:15:18 -0500
Received: by bwz15 with SMTP id 15so9485509bwz.19
        for <netdev@vger.kernel.org>; Sat, 04 Dec 2010 15:15:17 -0800 (PST)
In-Reply-To: <1290996593-32416-4-git-send-email-maximlevitsky@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-11-29 at 04:09 +0200, Maxim Levitsky wrote:
> IPv4 over firewire needs to be able to remove ARP entries
> from the ARP cache that belong to nodes that are removed, because
> IPv4 over firewire uses ARP packets for private information
> about nodes.
> 
> This information becomes invalid as soon as node drops
> off the bus and when it reconnects, its only possible
> to start takling to is after it responded to an ARP packet.
> But ARP cache prevents such packets from being sent.
> 
> CC: netdev@vger.kernel.org
> CC: "David S. Miller" <davem@davemloft.net>
> CC: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
> CC: James Morris <jmorris@namei.org>
> CC: Patrick McHardy <kaber@trash.net>

Anybody?

Best regards,
	Maxim Levitsky
> 
> 
> Signed-off-by: Maxim Levitsky <maximlevitsky@gmail.com>
> ---
>  include/net/arp.h |    1 +
>  net/ipv4/arp.c    |   29 ++++++++++++++++++-----------
>  2 files changed, 19 insertions(+), 11 deletions(-)
> 
> diff --git a/include/net/arp.h b/include/net/arp.h
> index f4cf6ce..91f0568 100644
> --- a/include/net/arp.h
> +++ b/include/net/arp.h
> @@ -25,5 +25,6 @@ extern struct sk_buff *arp_create(int type, int ptype, __be32 dest_ip,
>  				  const unsigned char *src_hw,
>  				  const unsigned char *target_hw);
>  extern void arp_xmit(struct sk_buff *skb);
> +int arp_invalidate(struct net_device *dev, __be32 ip);
>  
>  #endif	/* _ARP_H */
> diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
> index d8e540c..35b1272 100644
> --- a/net/ipv4/arp.c
> +++ b/net/ipv4/arp.c
> @@ -1142,6 +1142,23 @@ static int arp_req_get(struct arpreq *r, struct net_device *dev)
>  	return err;
>  }
>  
> +int arp_invalidate(struct net_device *dev, __be32 ip)
> +{
> +	int err = -ENXIO;
> +	struct neighbour *neigh = neigh_lookup(&arp_tbl, &ip, dev);
> +
> +	if (neigh) {
> +		if (neigh->nud_state & ~NUD_NOARP)
> +			err = neigh_update(neigh, NULL, NUD_FAILED,
> +					   NEIGH_UPDATE_F_OVERRIDE|
> +					   NEIGH_UPDATE_F_ADMIN);
> +		neigh_release(neigh);
> +	}
> +
> +	return err;
> +}
> +EXPORT_SYMBOL(arp_invalidate);
> +
>  static int arp_req_delete_public(struct net *net, struct arpreq *r,
>  		struct net_device *dev)
>  {
> @@ -1162,7 +1179,6 @@ static int arp_req_delete(struct net *net, struct arpreq *r,
>  {
>  	int err;
>  	__be32 ip;
> -	struct neighbour *neigh;
>  
>  	if (r->arp_flags & ATF_PUBL)
>  		return arp_req_delete_public(net, r, dev);
> @@ -1180,16 +1196,7 @@ static int arp_req_delete(struct net *net, struct arpreq *r,
>  		if (!dev)
>  			return -EINVAL;
>  	}
> -	err = -ENXIO;
> -	neigh = neigh_lookup(&arp_tbl, &ip, dev);
> -	if (neigh) {
> -		if (neigh->nud_state & ~NUD_NOARP)
> -			err = neigh_update(neigh, NULL, NUD_FAILED,
> -					   NEIGH_UPDATE_F_OVERRIDE|
> -					   NEIGH_UPDATE_F_ADMIN);
> -		neigh_release(neigh);
> -	}
> -	return err;
> +	return arp_invalidate(dev, ip);
>  }
>  
>  /*


