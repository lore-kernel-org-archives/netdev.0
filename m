From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 2/2] net/sched: fix filter flushing
Date: Mon, 22 May 2017 14:36:20 +0200
Message-ID: <20170522123620.GA1845@nanopsycho>
References: <20170520130132.1626-1-jiri@resnulli.us>
 <20170520130132.1626-2-jiri@resnulli.us>
 <CAM_iQpWha6aCV3kOfCEFsBLNiC7LFTh=K=QaL17rH4=PUoeUmQ@mail.gmail.com>
 <20170521055416.GA1848@nanopsycho>
 <CAM_iQpVPuC-FQ3R4QNDCBWxrX5s7Q4bENxMU7+1LooCdHdMZhw@mail.gmail.com>
 <20170521191941.GA4278@nanopsycho>
 <ebf100e6-e927-35bd-3c3a-9bd481237979@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Simon Horman <simon.horman@netronome.com>, mlxsw@mellanox.com,
        Colin King <colin.king@canonical.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34344 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751537AbdEVMgX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 08:36:23 -0400
Received: by mail-wm0-f67.google.com with SMTP id d127so32966405wmf.1
        for <netdev@vger.kernel.org>; Mon, 22 May 2017 05:36:22 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <ebf100e6-e927-35bd-3c3a-9bd481237979@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, May 22, 2017 at 12:42:44PM CEST, jhs@mojatatu.com wrote:
>On 17-05-21 03:19 PM, Jiri Pirko wrote:
>> Sun, May 21, 2017 at 08:27:21PM CEST, xiyou.wangcong@gmail.com wrote:
>> > On Sat, May 20, 2017 at 10:54 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>> > > Sun, May 21, 2017 at 02:16:45AM CEST, xiyou.wangcong@gmail.com wrote:
>> > > > On Sat, May 20, 2017 at 6:01 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>> > > > > +static void tcf_chain_destroy(struct tcf_chain *chain)
>> > > > > +{
>> > > > > +       list_del(&chain->list);
>> > > > > +       tcf_chain_flush(chain);
>> > > > >          kfree(chain);
>> > > > >   }
>> > > > > 
>> > > > > @@ -510,7 +517,7 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n,
>> > > > > 
>> > > > >          if (n->nlmsg_type == RTM_DELTFILTER && prio == 0) {
>> > > > >                  tfilter_notify_chain(net, skb, n, chain, RTM_DELTFILTER);
>> > > > > -               tcf_chain_destroy(chain);
>> > > > > +               tcf_chain_flush(chain);
>> > > > 
>> > > > 
>> > > > I wonder if we should return EBUSY and do nothing in case of busy?
>> > > > The chain is no longer visual to new actions after your list_del(), but
>> > > > the old one could still use and see it.
>> > > 
>> > > No. User request to flush the chain, that is what happens in the past
>> > > and that is what should happen now.
>> > > If there is still a reference, the chain_put will keep the empty chain.
>> > 
>> > But if you dump the actions, this chain is still shown "goto chain"?
>> 
>> Yes, it will be shown there.
>> 
>> 
>> > You can't claim you really delete it as long as actions can still
>> > see it and dump it.
>> 
>> No, user just wants to delete all the filters. That is done. User does
>> not care if the actual chain structure is there or not.
>> 
>
>I am trying to visualize a scenario where this is a problem.
>Using gact action it may be  possible to cause issues (requires
>validating - when i get time I will test).
>Steps are something like:
>
>1. create filter on chain 11 (refcnt = 1)

refcnt will be 0, chain->filter_chain will be non-NULL.
Please see the code before you assume anything. Namely tcf_chain_get and
tcf_chain_put.


>2. create gact action index 5 goto chain 11 (refcnt =2)

refcnt will be 1 after this


>3'. create new filter on chain 0 ... action gact index 5
>3''. create new filter on chain 0 ... action gact index 5
>
>
>None of the #3 steps will increment the refcnt.

Right


>Delete the filter from #1 (refcnt becomes 1)

Right, refcnt was 1, after delete will still be 1


>Delete the filter from #3'1 (refcnt = 0, destroy happens)

No. refcnt will still be 1.


>Filter #3'' is still hanging there. Dump that and strange things
>happen.

No. I see nothing strange.


>
>cheers,
>jamal
