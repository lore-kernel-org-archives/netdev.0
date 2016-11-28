From: =?gb2312?B?1cXKpL7Z?= <zhangshengju@cmss.chinamobile.com>
Subject: RE: [net,v2] neigh: fix the loop index error in neigh dump
Date: Mon, 28 Nov 2016 10:34:47 +0800
Message-ID: <001c01d2491f$fcd53250$f67f96f0$@cmss.chinamobile.com>
References: <1480296725-5563-1-git-send-email-zhangshengju@cmss.chinamobile.com> <caa11887-00b9-d2f1-7c0b-5b5096b42f56@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain;
        charset="gb2312"
Content-Transfer-Encoding: 7bit
To: "'David Ahern'" <dsa@cumulusnetworks.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta3.chinamobile.com ([221.176.66.81]:19227 "EHLO
        cmccmta3.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753647AbcK1Ceu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2016 21:34:50 -0500
In-Reply-To: <caa11887-00b9-d2f1-7c0b-5b5096b42f56@cumulusnetworks.com>
Content-Language: en-us
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Ahern [mailto:dsa@cumulusnetworks.com]
> Sent: Monday, November 28, 2016 10:10 AM
> To: Zhang Shengju <zhangshengju@cmss.chinamobile.com>;
> netdev@vger.kernel.org
> Subject: Re: [net,v2] neigh: fix the loop index error in neigh dump
> 
> On 11/27/16 6:32 PM, Zhang Shengju wrote:
> > Loop index in neigh dump function is not updated correctly under some
> > circumstances, this patch will fix it.
> 
> What's an example?

If dev is filtered out, the original code goes to next loop without updating
loop index 'idx'.

> 
> >
> > Fixes: 16660f0bd9 ("net: Add support for filtering neigh dump by
> > device index")
> > Fixes: 21fdd092ac ("net: Add support for filtering neigh dump by
> > master device")
> >
> > Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
> > ---
> >  net/core/neighbour.c | 39 ++++++++++++++++++---------------------
> >  1 file changed, 18 insertions(+), 21 deletions(-)
> >
> > diff --git a/net/core/neighbour.c b/net/core/neighbour.c index
> > 2ae929f..ce32e9c 100644
> > --- a/net/core/neighbour.c
> > +++ b/net/core/neighbour.c
> > @@ -2256,6 +2256,16 @@ static bool neigh_ifindex_filtered(struct
> net_device *dev, int filter_idx)
> >  	return false;
> >  }
> >
> > +static bool neigh_dump_filtered(struct net_device *dev, int filter_idx,
> > +		int filter_master_idx)
> > +{
> > +	if (neigh_ifindex_filtered(dev, filter_idx) ||
> > +	    neigh_master_filtered(dev, filter_master_idx))
> > +		return true;
> > +
> > +	return false;
> > +}
> > +
> >  static int neigh_dump_table(struct neigh_table *tbl, struct sk_buff
*skb,
> >  			    struct netlink_callback *cb)
> >  {
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
> > @@ -2306,8 +2311,6 @@ static int neigh_dump_table(struct neigh_table
> *tbl, struct sk_buff *skb,
> >  				rc = -1;
> >  				goto out;
> >  			}
> > -next:
> > -			idx++;
> >  		}
> >  	}
> >  	rc = skb->len;
> > @@ -2328,14 +2331,10 @@ static int pneigh_dump_table(struct
> > neigh_table *tbl, struct sk_buff *skb,
> >
> >  	read_lock_bh(&tbl->lock);
> >
> > -	for (h = s_h; h <= PNEIGH_HASHMASK; h++) {
> > -		if (h > s_h)
> > -			s_idx = 0;
> > -		for (n = tbl->phash_buckets[h], idx = 0; n; n = n->next) {
> > -			if (pneigh_net(n) != net)
> > +	for (h = s_h; h <= PNEIGH_HASHMASK; h++, s_idx = 0) {
> > +		for (n = tbl->phash_buckets[h], idx = 0; n; n = n->next,
idx++)
> {
> > +			if (idx < s_idx || pneigh_net(n) != net)
> >  				continue;
> > -			if (idx < s_idx)
> > -				goto next;
> >  			if (pneigh_fill_info(skb, n, NETLINK_CB(cb-
> >skb).portid,
> >  					    cb->nlh->nlmsg_seq,
> >  					    RTM_NEWNEIGH,
> > @@ -2344,8 +2343,6 @@ static int pneigh_dump_table(struct neigh_table
> *tbl, struct sk_buff *skb,
> >  				rc = -1;
> >  				goto out;
> >  			}
> > -		next:
> > -			idx++;
> >  		}
> >  	}
> >
> 
> This fix is way to be complicated to be fixing anything related to
16660f0bd9
> or 21fdd092ac. Both of those commits added a continue:
> 
>                         if (neigh_ifindex_filtered(n->dev, filter_idx))
>                                 continue;
>                         if (neigh_master_filtered(n->dev,
filter_master_idx))
>                                 continue;
> 
> At best the continue is replaced by 'goto next;' and I am not convinced
that is
> right.
> 
> You are completely rewriting the dump loops.

I put 'idx++' into for loop,  so I replace 'goto' with 'continue'.  The
other change is style related. 

Thanks,
Zhang Shengju
