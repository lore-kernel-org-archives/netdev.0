From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Lockdep warning in vxlan
Date: Thu, 20 Dec 2012 10:22:12 -0800
Message-ID: <20121220102212.03dd1a3d@nehalam.linuxnetplumber.net>
References: <50D31A00.7060905@mellanox.com>
	<20121220083436.0c7fc33f@nehalam.linuxnetplumber.net>
	<1356027360.21834.2973.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Yan Burman <yanb@mellanox.com>, netdev@vger.kernel.org
To: Eric Dumazet <erdnetdev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37770 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750875Ab2LTSX2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Dec 2012 13:23:28 -0500
In-Reply-To: <1356027360.21834.2973.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 20 Dec 2012 10:16:00 -0800
Eric Dumazet <erdnetdev@gmail.com> wrote:

> On Thu, 2012-12-20 at 08:34 -0800, Stephen Hemminger wrote:
> > On Thu, 20 Dec 2012 16:00:32 +0200
> > Yan Burman <yanb@mellanox.com> wrote:
> >   
> > > Hi.
> > > 
> > > When working with vxlan from current net-next, I got a lockdep warning 
> > > (below).
> > > It seems to happen when I have host B pinging host A and while the pings 
> > > continue,
> > > I do "ip link del" on the vxlan interface on host A. The lockdep warning 
> > > is on host A.
> > > Tell me if you need some more info.
> > >   
> > 
> > Looks like the case of nested ARP requests, the initial request is coming
> > from neigh_timer (ARP retransmit), but inside neigh_probe the lock
> > is dropped?  
> 
> Bug is from arp_solicit(), releasing the lock after arp_send()
> 
> Its used to protect neigh->ha
> 
> We could instead copy neigh->ha, without taking n->lock but ha_lock
> seqlock, using neigh_ha_snapshot() helper
> 
> Yan, could you test the following patch ?
> 
> Thanks
> diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
> index ce6fbdf..1169ed4 100644
> --- a/net/ipv4/arp.c
> +++ b/net/ipv4/arp.c
> @@ -321,7 +321,7 @@ static void arp_error_report(struct neighbour *neigh, struct sk_buff *skb)
>  static void arp_solicit(struct neighbour *neigh, struct sk_buff *skb)
>  {
>  	__be32 saddr = 0;
> -	u8  *dst_ha = NULL;
> +	u8 dst_ha[MAX_ADDR_LEN];
>  	struct net_device *dev = neigh->dev;
>  	__be32 target = *(__be32 *)neigh->primary_key;
>  	int probes = atomic_read(&neigh->probes);
> @@ -363,9 +363,9 @@ static void arp_solicit(struct neighbour *neigh, struct sk_buff *skb)
>  	if (probes < 0) {
>  		if (!(neigh->nud_state & NUD_VALID))
>  			pr_debug("trying to ucast probe in NUD_INVALID\n");
> -		dst_ha = neigh->ha;
> -		read_lock_bh(&neigh->lock);
> +		neigh_ha_snapshot(dst_ha, neigh, dev);
>  	} else {
> +		memset(dst_ha, 0, dev->addr_len);
>  		probes -= neigh->parms->app_probes;
>  		if (probes < 0) {
>  #ifdef CONFIG_ARPD
> @@ -377,8 +377,6 @@ static void arp_solicit(struct neighbour *neigh, struct sk_buff *skb)
>  
>  	arp_send(ARPOP_REQUEST, ETH_P_ARP, target, dev, saddr,
>  		 dst_ha, dev->dev_addr, NULL);
> -	if (dst_ha)
> -		read_unlock_bh(&neigh->lock);
>  }
>  
>  static int arp_ignore(struct in_device *in_dev, __be32 sip, __be32 tip)

I like this. Getting rid of yet another read lock
