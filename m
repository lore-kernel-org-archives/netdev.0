From: Cong Wang <cwang@twopensource.com>
Subject: Re: [Patch net 2/2] ipmr,ip6mr: call list_del_rcu() when deleting mr
 table from list
Date: Wed, 25 Mar 2015 15:33:31 -0700
Message-ID: <CAHA+R7Mj7BaVKmmt+0TvUb4a3-mTcP=8_-ZJfxRamOHkjCw-sA@mail.gmail.com>
References: <1427310345-29829-1-git-send-email-xiyou.wangcong@gmail.com>
	<1427310345-29829-2-git-send-email-xiyou.wangcong@gmail.com>
	<1427314022.3581245.245236665.477D7858@webmail.messagingengine.com>
	<1427314914.3584424.245242065.67DE2EEE@webmail.messagingengine.com>
	<1427317004.3592779.245256885.395A5939@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:34955 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751516AbbCYWdb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 18:33:31 -0400
Received: by igcau2 with SMTP id au2so114689695igc.0
        for <netdev@vger.kernel.org>; Wed, 25 Mar 2015 15:33:31 -0700 (PDT)
In-Reply-To: <1427317004.3592779.245256885.395A5939@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 25, 2015 at 1:56 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> On Wed, Mar 25, 2015, at 21:21, Hannes Frederic Sowa wrote:
>> On Wed, Mar 25, 2015, at 21:07, Hannes Frederic Sowa wrote:
>> > On Wed, Mar 25, 2015, at 20:05, Cong Wang wrote:
>> > > Probably not a big deal, just for corretness.
>> > >
>> > > Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>> > > ---
>> > >  net/ipv4/ipmr.c  | 2 +-
>> > >  net/ipv6/ip6mr.c | 2 +-
>> > >  2 files changed, 2 insertions(+), 2 deletions(-)
>> > >
>> > > diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
>> > > index d6fede8..68f67b8 100644
>> > > --- a/net/ipv4/ipmr.c
>> > > +++ b/net/ipv4/ipmr.c
>> > > @@ -280,7 +280,7 @@ static void __net_exit ipmr_rules_exit(struct net
>> > > *net)
>> > >
>> > >   rtnl_lock();
>> > >   list_for_each_entry_safe(mrt, next, &net->ipv4.mr_tables, list) {
>> > > -               list_del(&mrt->list);
>> > > +               list_del_rcu(&mrt->list);
>> > >           ipmr_free_table(mrt);
>> > >   }
>> > >   rtnl_unlock();
>> >
>> > I really do wonder if we have the rcu locking correct in there:
>> >
>> > Looking into getsockopt/setsockopt operations, we might have socket
>> > lock, but I cannot see where we lock rcu, so the ipmr_get_table call is
>> > safe. Do you also see the problem?

I see only ipmr_rule_action() really has RCU read lock, I think the sockopt
operations should take RCU read lock too, since it is supposed to be
protected by rcu+rtnl rather than rcu+sock lock?

>>
>> Also ipmr_free_table does need a kfree_rcu as we need to have those
>> tables rcu protected (we use them from softirq, so rtnl_lock is not
>> feasible here).
>
> So, ipmr_free_tables is only called from within netns cleanup, which is
> run after synchronize_rcu(), so the kfree is safe. We only add tables to
> the list, no tables are ever deleted until the namespace gets destroyed,
> so the locking seems ok to me, but please double check.
>

Right, I found this by code review, didn't see any real crash.

Thanks!
