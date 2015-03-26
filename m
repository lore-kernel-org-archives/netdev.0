From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [Patch net 2/2] ipmr,ip6mr: call list_del_rcu() when deleting mr
 table from list
Date: Thu, 26 Mar 2015 13:23:39 +0100
Message-ID: <1427372619.2762618.245521141.61D660A6@webmail.messagingengine.com>
References: <1427310345-29829-1-git-send-email-xiyou.wangcong@gmail.com>
 <1427310345-29829-2-git-send-email-xiyou.wangcong@gmail.com>
 <1427314022.3581245.245236665.477D7858@webmail.messagingengine.com>
 <1427314914.3584424.245242065.67DE2EEE@webmail.messagingengine.com>
 <1427317004.3592779.245256885.395A5939@webmail.messagingengine.com>
 <CAHA+R7Mj7BaVKmmt+0TvUb4a3-mTcP=8_-ZJfxRamOHkjCw-sA@mail.gmail.com>
 <1427331669.3644952.245320733.5C7B84E1@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:34420 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751042AbbCZMXk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 08:23:40 -0400
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id 58ECE205F1
	for <netdev@vger.kernel.org>; Thu, 26 Mar 2015 08:23:37 -0400 (EDT)
In-Reply-To: <1427331669.3644952.245320733.5C7B84E1@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 26, 2015, at 02:01, Hannes Frederic Sowa wrote:
> On Wed, Mar 25, 2015, at 23:33, Cong Wang wrote:
> > On Wed, Mar 25, 2015 at 1:56 PM, Hannes Frederic Sowa
> > <hannes@stressinduktion.org> wrote:
> > > On Wed, Mar 25, 2015, at 21:21, Hannes Frederic Sowa wrote:
> > >> On Wed, Mar 25, 2015, at 21:07, Hannes Frederic Sowa wrote:
> > >> > On Wed, Mar 25, 2015, at 20:05, Cong Wang wrote:
> > >> > > Probably not a big deal, just for corretness.
> > >> > >
> > >> > > Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> > >> > > ---
> > >> > >  net/ipv4/ipmr.c  | 2 +-
> > >> > >  net/ipv6/ip6mr.c | 2 +-
> > >> > >  2 files changed, 2 insertions(+), 2 deletions(-)
> > >> > >
> > >> > > diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
> > >> > > index d6fede8..68f67b8 100644
> > >> > > --- a/net/ipv4/ipmr.c
> > >> > > +++ b/net/ipv4/ipmr.c
> > >> > > @@ -280,7 +280,7 @@ static void __net_exit ipmr_rules_exit(struct net
> > >> > > *net)
> > >> > >
> > >> > >   rtnl_lock();
> > >> > >   list_for_each_entry_safe(mrt, next, &net->ipv4.mr_tables, list) {
> > >> > > -               list_del(&mrt->list);
> > >> > > +               list_del_rcu(&mrt->list);
> > >> > >           ipmr_free_table(mrt);
> > >> > >   }
> > >> > >   rtnl_unlock();
> > >> >
> > >> > I really do wonder if we have the rcu locking correct in there:
> > >> >
> > >> > Looking into getsockopt/setsockopt operations, we might have socket
> > >> > lock, but I cannot see where we lock rcu, so the ipmr_get_table call is
> > >> > safe. Do you also see the problem?
> > 
> > I see only ipmr_rule_action() really has RCU read lock, I think the
> > sockopt
> > operations should take RCU read lock too, since it is supposed to be
> > protected by rcu+rtnl rather than rcu+sock lock?
> 
> Exactly, it would be canonical, especially because of lockdep. I am not
> sure yet about socket lock, but will review that tomorrow.

The rest of the locking seems to be fine. So only rcu_read_lock() is
missing for lockdep correctness.

Bye,
Hannes
