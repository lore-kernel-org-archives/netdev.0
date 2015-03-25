From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [Patch net 2/2] ipmr,ip6mr: call list_del_rcu() when deleting mr
 table from list
Date: Wed, 25 Mar 2015 21:56:44 +0100
Message-ID: <1427317004.3592779.245256885.395A5939@webmail.messagingengine.com>
References: <1427310345-29829-1-git-send-email-xiyou.wangcong@gmail.com>
 <1427310345-29829-2-git-send-email-xiyou.wangcong@gmail.com>
 <1427314022.3581245.245236665.477D7858@webmail.messagingengine.com>
 <1427314914.3584424.245242065.67DE2EEE@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:47852 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750863AbbCYU4p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 16:56:45 -0400
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by mailout.nyi.internal (Postfix) with ESMTP id 4F6EA2088D
	for <netdev@vger.kernel.org>; Wed, 25 Mar 2015 16:56:42 -0400 (EDT)
In-Reply-To: <1427314914.3584424.245242065.67DE2EEE@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 25, 2015, at 21:21, Hannes Frederic Sowa wrote:
> On Wed, Mar 25, 2015, at 21:07, Hannes Frederic Sowa wrote:
> > On Wed, Mar 25, 2015, at 20:05, Cong Wang wrote:
> > > Probably not a big deal, just for corretness.
> > > 
> > > Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> > > ---
> > >  net/ipv4/ipmr.c  | 2 +-
> > >  net/ipv6/ip6mr.c | 2 +-
> > >  2 files changed, 2 insertions(+), 2 deletions(-)
> > > 
> > > diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
> > > index d6fede8..68f67b8 100644
> > > --- a/net/ipv4/ipmr.c
> > > +++ b/net/ipv4/ipmr.c
> > > @@ -280,7 +280,7 @@ static void __net_exit ipmr_rules_exit(struct net
> > > *net)
> > >  
> > >  	rtnl_lock();
> > >  	list_for_each_entry_safe(mrt, next, &net->ipv4.mr_tables, list) {
> > > -               list_del(&mrt->list);
> > > +               list_del_rcu(&mrt->list);
> > >  		ipmr_free_table(mrt);
> > >  	}
> > >  	rtnl_unlock();
> > 
> > I really do wonder if we have the rcu locking correct in there:
> > 
> > Looking into getsockopt/setsockopt operations, we might have socket
> > lock, but I cannot see where we lock rcu, so the ipmr_get_table call is
> > safe. Do you also see the problem?
> 
> Also ipmr_free_table does need a kfree_rcu as we need to have those
> tables rcu protected (we use them from softirq, so rtnl_lock is not
> feasible here).

So, ipmr_free_tables is only called from within netns cleanup, which is
run after synchronize_rcu(), so the kfree is safe. We only add tables to
the list, no tables are ever deleted until the namespace gets destroyed,
so the locking seems ok to me, but please double check.

Thus I agree with your conclusion it should not really matter, so

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks,
Hannes
