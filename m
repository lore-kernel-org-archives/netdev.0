From: =?gb2312?B?1cXKpL7Z?= <zhangshengju@cmss.chinamobile.com>
Subject: RE: [net-next] neigh: remove duplicate check for same neigh
Date: Wed, 30 Nov 2016 09:27:48 +0800
Message-ID: <000201d24aa8$f63c6500$e2b52f00$@cmss.chinamobile.com>
References: <1480407771-12884-1-git-send-email-zhangshengju@cmss.chinamobile.com> <d641245a-8442-9238-a507-6f94184354a0@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain;
        charset="gb2312"
Content-Transfer-Encoding: 7bit
To: "'David Ahern'" <dsa@cumulusnetworks.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta3.chinamobile.com ([221.176.66.81]:19228 "EHLO
        cmccmta3.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752694AbcK3B2B (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 20:28:01 -0500
In-Reply-To: <d641245a-8442-9238-a507-6f94184354a0@cumulusnetworks.com>
Content-Language: en-us
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Ahern [mailto:dsa@cumulusnetworks.com]
> Sent: Wednesday, November 30, 2016 12:23 AM
> To: Zhang Shengju <zhangshengju@cmss.chinamobile.com>;
> netdev@vger.kernel.org
> Subject: Re: [net-next] neigh: remove duplicate check for same neigh
> 
> On 11/29/16 1:22 AM, Zhang Shengju wrote:
> > @@ -2285,20 +2295,15 @@ static int neigh_dump_table(struct neigh_table
> *tbl, struct sk_buff *skb,
> >  	rcu_read_lock_bh();
> >  	nht = rcu_dereference_bh(tbl->nht);
> >
> > -	for (h = s_h; h < (1 << nht->hash_shift); h++) {
> > -		if (h > s_h)
> > -			s_idx = 0;
> > +	for (h = s_h; h < (1 << nht->hash_shift); h++, s_idx = 0) {
> >  		for (n = rcu_dereference_bh(nht->hash_buckets[h]), idx = 0;
> >  		     n != NULL;
> > -		     n = rcu_dereference_bh(n->next)) {
> > -			if (!net_eq(dev_net(n->dev), net))
> > -				continue;
> > -			if (neigh_ifindex_filtered(n->dev, filter_idx))
> > +		     n = rcu_dereference_bh(n->next), idx++) {
> 
> incrementing idx here ...
> 
> > +			if (idx < s_idx || !net_eq(dev_net(n->dev), net))
> >  				continue;
> > -			if (neigh_master_filtered(n->dev,
filter_master_idx))
> > +			if (neigh_dump_filtered(n->dev, filter_idx,
> > +						filter_master_idx))
> >  				continue;
> > -			if (idx < s_idx)
> > -				goto next;
> >  			if (neigh_fill_info(skb, n, NETLINK_CB(cb-
> >skb).portid,
> >  					    cb->nlh->nlmsg_seq,
> >  					    RTM_NEWNEIGH,
> 
> ... causes a missed entry when an error happens here
> 
> idx is only incremented when a neigh has been successfully added to the
skb.

If an error happens, we just goto 'out' and exit this loop, this will skip
the 'idx++'.  
So no missed entry, right?

> 
> 
> Your intention is to save a few cycles by making idx an absolute index
within
> the hash bucket and jumping to the next entry to be dumped without
> evaluating any filters per entry.
> 
> So why not keep it simple and do this:

This has less changes, but I preferred to add a new function to do the
filter logic, this is the same as your code  @rtnl_dump_ifinfo().

And for the 'idx', it should be increased when neigh entry is filter out or
is successfully added to the skb. Isn't it straight-forward to put it in for
loop?

> 
> diff --git a/net/core/neighbour.c b/net/core/neighbour.c index
> 2ae929f9bd06..2e49a85e696a 100644
> --- a/net/core/neighbour.c
> +++ b/net/core/neighbour.c
> @@ -2291,14 +2291,12 @@ static int neigh_dump_table(struct neigh_table
> *tbl, struct sk_buff *skb,
>                 for (n = rcu_dereference_bh(nht->hash_buckets[h]), idx =
0;
>                      n != NULL;
>                      n = rcu_dereference_bh(n->next)) {
> -                       if (!net_eq(dev_net(n->dev), net))
> -                               continue;
> -                       if (neigh_ifindex_filtered(n->dev, filter_idx))
> -                               continue;
> -                       if (neigh_master_filtered(n->dev,
filter_master_idx))
> -                               continue;
>                         if (idx < s_idx)
>                                 goto next;
> +                       if (!net_eq(dev_net(n->dev), net) ||
> +                           neigh_ifindex_filtered(n->dev, filter_idx) ||
> +                           neigh_master_filtered(n->dev,
filter_master_idx))
> +                               goto next;
>                         if (neigh_fill_info(skb, n,
NETLINK_CB(cb->skb).portid,
>                                             cb->nlh->nlmsg_seq,
>                                             RTM_NEWNEIGH,
