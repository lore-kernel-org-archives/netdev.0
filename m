From: Amir Vadai <amir@vadai.me>
Subject: Re: [PATCH net-next V2 01/10] net/flower: Introduce hardware offload
 support
Date: Sun, 6 Mar 2016 11:00:10 +0200
Message-ID: <20160306090010.GB3246@office.Home>
References: <1457016960-27832-1-git-send-email-amir@vadai.me>
 <1457016960-27832-2-git-send-email-amir@vadai.me>
 <56D9BF73.3050101@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	John Fastabend <john.r.fastabend@intel.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Rony Efraim <ronye@mellanox.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36098 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751138AbcCFI4e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Mar 2016 03:56:34 -0500
Received: by mail-wm0-f66.google.com with SMTP id l68so5727759wml.3
        for <netdev@vger.kernel.org>; Sun, 06 Mar 2016 00:56:33 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <56D9BF73.3050101@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 04, 2016 at 09:01:39AM -0800, John Fastabend wrote:
> On 16-03-03 06:55 AM, Amir Vadai wrote:
> > This patch is based on a patch made by John Fastabend.
> > It adds support for offloading cls_flower.
> > when NETIF_F_HW_TC is on:
> >   flags = 0       => Rule will be processed twice - by hardware, and if
> >                      still relevant, by software.
> >   flags = SKIP_HW => Rull will be processed by software only
> > 
> > If hardare fail/not capabale to apply the rule, operation will fail.
> > 
> > Suggested-by: John Fastabend <john.r.fastabend@intel.com>
> > Signed-off-by: Amir Vadai <amir@vadai.me>
> > ---
> 
> [...]
> 
> >  static bool fl_destroy(struct tcf_proto *tp, bool force)
> >  {
> >  	struct cls_fl_head *head = rtnl_dereference(tp->root);
> > @@ -174,6 +220,7 @@ static bool fl_destroy(struct tcf_proto *tp, bool force)
> >  		return false;
> >  
> >  	list_for_each_entry_safe(f, next, &head->filters, list) {
> > +		fl_hw_destroy_filter(tp, (u64)f);
> >  		list_del_rcu(&f->list);
> >  		call_rcu(&f->rcu, fl_destroy_filter);
> >  	}
> > @@ -454,11 +501,13 @@ static int fl_change(struct net *net, struct sk_buff *in_skb,
> >  		     u32 handle, struct nlattr **tca,
> >  		     unsigned long *arg, bool ovr)
> >  {
> > +	struct net_device *dev = tp->q->dev_queue->dev;
> >  	struct cls_fl_head *head = rtnl_dereference(tp->root);
> >  	struct cls_fl_filter *fold = (struct cls_fl_filter *) *arg;
> >  	struct cls_fl_filter *fnew;
> >  	struct nlattr *tb[TCA_FLOWER_MAX + 1];
> >  	struct fl_flow_mask mask = {};
> > +	u32 flags = 0;
> >  	int err;
> >  
> >  	if (!tca[TCA_OPTIONS])
> > @@ -486,6 +535,9 @@ static int fl_change(struct net *net, struct sk_buff *in_skb,
> >  	}
> >  	fnew->handle = handle;
> >  
> > +	if (tb[TCA_FLOWER_FLAGS])
> > +		flags = nla_get_u32(tb[TCA_FLOWER_FLAGS]);
> > +
> >  	err = fl_set_parms(net, tp, fnew, &mask, base, tb, tca[TCA_RATE], ovr);
> >  	if (err)
> >  		goto errout;
> > @@ -498,9 +550,22 @@ static int fl_change(struct net *net, struct sk_buff *in_skb,
> >  				     head->ht_params);
> >  	if (err)
> >  		goto errout;
> > -	if (fold)
> > +
> > +	err = fl_hw_replace_filter(tp,
> > +				   &head->dissector,
> > +				   &mask.key,
> > +				   &fnew->key,
> > +				   &fnew->exts,
> > +				   (u64)fnew,
> > +				   flags);
> > +	if (err)
> > +		goto err_hash_remove;
> > +
> 
> This behaviour is different than how I did u32 in the u32 case I just
> let the software case get loaded and do not throw any errors. The
> intent was if we required a HW entry we would explicitly state that
> with the SKIP_SW (to be implemented) flag. This error path seems
> to block the software filter when the hardware fails.
Makes sense.

> 
> I think it would be best to do the same as u32 here and use the error
> path only if SKIP_SW is set. Or if you really want an error path on
> SW/HW loads then use another bit in the flag to specify STRICT or
> something along those lines.
I will do the same as u32. I won't add this STRICT flag, because I don't
have any use case for this mode in which processing is done in both SW
and HW.

> 
> 
> > +	if (fold) {
> >  		rhashtable_remove_fast(&head->ht, &fold->ht_node,
> >  				       head->ht_params);
> > +		fl_hw_destroy_filter(tp, (u64)fold);
> > +	}
> >  
> >  	*arg = (unsigned long) fnew;
> >  
> > @@ -514,6 +579,9 @@ static int fl_change(struct net *net, struct sk_buff *in_skb,
> >  
> >  	return 0;
> >  
> > +err_hash_remove:
> > +	rhashtable_remove_fast(&head->ht, &fnew->ht_node, head->ht_params);
> > +
> >  errout:
> >  	kfree(fnew);
> >  	return err;
> > @@ -527,6 +595,7 @@ static int fl_delete(struct tcf_proto *tp, unsigned long arg)
> >  	rhashtable_remove_fast(&head->ht, &f->ht_node,
> >  			       head->ht_params);
> >  	list_del_rcu(&f->list);
> > +	fl_hw_destroy_filter(tp, (u64)f);
> >  	tcf_unbind_filter(tp, &f->res);
> >  	call_rcu(&f->rcu, fl_destroy_filter);
> >  	return 0;
> > 
> 
