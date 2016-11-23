From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next] net/sched: cls_flower: verify root pointer
 before dereferncing it
Date: Wed, 23 Nov 2016 11:29:02 -0800
Message-ID: <CAM_iQpVLd8tka7=9iQ_jSKD-jy2uLi9DL1xDnG1oK8hxBUrugA@mail.gmail.com>
References: <1479824726-62607-1-git-send-email-roid@mellanox.com>
 <20161122144844.GB1819@nanopsycho> <58346C7B.7090006@iogearbox.net>
 <20161122161159.GC1819@nanopsycho> <CAM_iQpVTtqQRg7KgQbMQSxxVJRB8a46DGgfU52m=SxF1uYDFWQ@mail.gmail.com>
 <5834AD97.1020600@iogearbox.net> <5834D670.2050301@gmail.com>
 <CAM_iQpWhGfrZgBD1Li+efZCv4Q6uGno1ttXcBL4C_F+4es4e_A@mail.gmail.com> <58357D7E.3010100@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: John Fastabend <john.fastabend@gmail.com>,
        Jiri Pirko <jiri@resnulli.us>, Roi Dayan <roid@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Cong Wang <cwang@twopensource.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f172.google.com ([209.85.161.172]:35196 "EHLO
        mail-yw0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933604AbcKWT3Y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 14:29:24 -0500
Received: by mail-yw0-f172.google.com with SMTP id i145so20470612ywg.2
        for <netdev@vger.kernel.org>; Wed, 23 Nov 2016 11:29:23 -0800 (PST)
In-Reply-To: <58357D7E.3010100@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 23, 2016 at 3:29 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
>
> Can't we drop the 'force' parameter from tcf_destroy() and related cls
> destroy() callbacks, and change the logic roughly like this:
>
> [...]
>         case RTM_DELTFILTER:
>                 err = tp->ops->delete(tp, fh, &drop_tp);
>                 if (err == 0) {
>                         struct tcf_proto *next = rtnl_dereference(tp->next);
>
>                         tfilter_notify(net, skb, n, tp,
>                                        t->tcm_handle,
>                                        RTM_DELTFILTER, false);
>                         if (drop_tp) {
>                                 RCU_INIT_POINTER(*back, next);
>                                 tcf_destroy(tp);
>                         }
>                 }
>                 goto errout;
> [...]
>
> This one was the only tcf_destroy() instance with force=false. Why can't
> the prior delete() callback make the decision whether the tp now has no
> further internal filters and thus can be dropped. Afaik, delete() and
> destroy() are protected by RTNL anyway. Thus, we could unlink the tp from
> the list before tcf_destroy(), which should then work with grace period
> as well. Given we remove the setting of tp->root to NULL, any outstanding
> readers for that grace period should either still execute the 'scheduled
> for removal' filter we just dropped, or find an empty list of filters.

This is exactly why I said "the semantic of ->destroy() needs to revise too",
this is a reasonable revision of course, but the change is still large because
we need to move that logic from ->destroy() to ->delete(). I was trying to find
a relatively small fix for -net and -stable, for -net-next we could do
aggressive
change as long as it's necessary. This is why I am still thinking about it,
perhaps there is no quick fix for this bug.


>
>> Hmm, perhaps we really have to switch to a doubly-linked list, that is
>> list_head. I need to double check. And also the semantic of ->destroy()
>> needs to revise too.
>
>
> Can you elaborate why double-linked list? Isn't the tp list always protected
> from modifications via RTNL in control path, and walked via
> rcu_dereference_bh()
> in data path?

At least two benefits we can get from using doubly-linked list:

1) No need to pass a 'prev' pointer if we want to remove tp in a RCU callback,
list_del_rcu(&tp->head) is just enough.

2) No need to worry about RCU pointers because list_head has RCU API's
already, much more readable to me.

Of course, the size of struct tcf_proto will grow a bit, but it doesn't seem to
be a problem.
