From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH net-next-2.6] bonding: allow arp_ip_targets to be on a
	separate vlan from bond device
Date: Tue, 1 Dec 2009 18:07:58 -0500
Message-ID: <20091201230758.GJ1639@gospo.rdu.redhat.com>
References: <20091130201453.GF1639@gospo.rdu.redhat.com> <29892.1259625638@death.nxdomain.ibm.com> <20091201012145.GH1639@gospo.rdu.redhat.com> <6611.1259632635@death.nxdomain.ibm.com> <20091201144410.GI1639@gospo.rdu.redhat.com> <21331.1259702893@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50038 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752749AbZLAXHy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Dec 2009 18:07:54 -0500
Content-Disposition: inline
In-Reply-To: <21331.1259702893@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 01, 2009 at 01:28:13PM -0800, Jay Vosburgh wrote:
> Andy Gospodarek <andy@greyhouse.net> wrote:
> [...]
> >I am using arp_validate, actually.  I forgot that the arp_validate
> >option doesn't show up in the output of /proc/net/bonding/bondX and I
> >intended to have that in the subject, but somehow dropped it.
> 
> 	Ok, I was doing it wrong earlier; it works with arp_validate.
> I'm seeing one problem with tcpdump, though, which I'll get to in a
> minute.
> 
> 	Could you update the summary / changelog message to mention that
> this patch fixes the specific case of arp_validate + arp_ip_target on
> VLAN?
> 

Yep, I would be glad to do that.

> 	Second, in regards to this:
> 
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2439,8 +2439,8 @@ int netif_receive_skb(struct sk_buff *skb)
>  		skb->skb_iif = skb->dev->ifindex;
> 
>  	null_or_orig = NULL;
> -	orig_dev = skb->dev;
> -	if (orig_dev->master) {
> +	orig_dev = __dev_get_by_index(dev_net(skb->dev),skb->skb_iif);
> +	if (orig_dev->master && !(skb->dev->priv_flags & IFF_802_1Q_VLAN)) {
>  		if (skb_bond_should_drop(skb))
>  			null_or_orig = orig_dev; /* deliver only exact match */
>  		else
> 
> 	Would it be useful to add a comment to the effect that VLAN
> packets are run through skb_bond_should_drop at the VLAN layer?
> 
> 	Lastly, in regards to this:
> 
> @@ -2492,7 +2492,7 @@ ncls:
>  			&ptype_base[ntohs(type) & PTYPE_HASH_MASK], list) {
>  		if (ptype->type == type &&
>  		    (ptype->dev == null_or_orig || ptype->dev == skb->dev ||
> -		     ptype->dev == orig_dev)) {
> +		     ptype->dev == orig_dev || ptype->dev == orig_dev->master)) {
>  			if (pt_prev)
>  				ret = deliver_skb(skb, pt_prev, orig_dev);
>  			pt_prev = ptype;
> 
> 	This is presumably here because orig_dev will now be the actual
> slave the packet arrived on, but we want to additionally deliver to the
> master, correct?

Yes, that is exactly right.

> 
> 	Lastly, tcpdump.
> 
> 	This patch appears to affect what traffic tcpdump of a slave or
> the bonding master itself will capture.  Previously, tcpdump of the
> active slave would see only the transmitted packets sent over the bond,
> and tcpdump of the inactive slave would see incoming Ethernet-layer
> multicast or broadcasts sent to its switch port.  Tcpdump on the master
> would see all sent and non-VLAN received traffic, and tcpdump of the
> VLAN interface over the master would see just the VLAN traffic.
> 
> 	After this change, tcpdump of the active slave or of the bonding
> master (bond0) sees both sent and received traffic for the VLAN, but
> nothing for the non-VLAN traffic other than incoming broadcast /
> multicasts.  This holds true whether or not a VLAN is configured.
> 
> 	I added a "ptype->dev == orig_dev->master" test to the ptype_all
> receive block in netif_receive_skb, but it didn't help.  At the moment,
> I'm not exactly sure why tcpdump breaks.
> 

This is interesting; I'll investigate.

> 	-J
> 
> ---
> 	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
