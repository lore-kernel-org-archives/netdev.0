From: Artem Savkov <asavkov@redhat.com>
Subject: Re: [PATCH] ebtables: fix race condition in frame_filter_net_init()
Date: Tue, 26 Sep 2017 16:34:11 +0200
Message-ID: <20170926143411.ztr5g5wjtiu47fil@shodan.usersys.redhat.com>
References: <20170926122938.11603-1-asavkov@redhat.com>
 <20170926124211.GA14971@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39052 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S936599AbdIZOeM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 26 Sep 2017 10:34:12 -0400
Content-Disposition: inline
In-Reply-To: <20170926124211.GA14971@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 26, 2017 at 02:42:11PM +0200, Florian Westphal wrote:
> Artem Savkov <asavkov@redhat.com> wrote:
> > It is possible for ebt_in_hook to be triggered before ebt_table is assigned
> > resulting in a NULL-pointer dereference. Make sure hooks are
> > registered as the last step.
> 
> Right, thanks for the patch.
> 
> > --- a/net/bridge/netfilter/ebtable_broute.c
> > +++ b/net/bridge/netfilter/ebtable_broute.c
> > @@ -65,7 +65,7 @@ static int ebt_broute(struct sk_buff *skb)
> >  
> >  static int __net_init broute_net_init(struct net *net)
> >  {
> > -	net->xt.broute_table = ebt_register_table(net, &broute_table, NULL);
> > +	net->xt.broute_table = ebt_register_table(net, &broute_table);
> 
> I wonder if it makes more sense to model this like the iptables version,
> i.e. pass net->xt.table_name as last arg to ebt_register_table ...
> 
> > +int ebt_register_hooks(struct net *net, struct ebt_table *table,
> > +		      const struct nf_hook_ops *ops)
> > +{
> > +	int ret = nf_register_net_hooks(net, ops, hweight32(table->valid_hooks));
> > +
> > +	if (ret)
> > +		__ebt_unregister_table(net, table);
> > +
> > +	return ret;
> > +}
> 
> ... because this looks strange (unregister of table/not-so-obvious error
> unwinding ...)
> 
> > @@ -1252,15 +1262,6 @@ ebt_register_table(struct net *net, const struct ebt_table *input_table,
> >  	list_add(&table->list, &net->xt.tables[NFPROTO_BRIDGE]);
> >  	mutex_unlock(&ebt_mutex);
> 
> ... here one could then assign the net->xt.table_X pointer, and then do
> the hook registration right after.
> 
> However i have no strong opinion here.

Agreed, that does look better and requires less changes. I'll send a v2.

-- 
Regards,
  Artem
