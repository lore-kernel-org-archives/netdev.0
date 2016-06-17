From: Eric Dumazet <edumazet@google.com>
Subject: Re: act_mirred: remove spinlock in fast path
Date: Fri, 17 Jun 2016 14:24:37 -0700
Message-ID: <CANn89iJj6aqqm0AwQnFR6NJSADje4FS64dzF2-Ac8hSpECG=sQ@mail.gmail.com>
References: <CAM_iQpU42hydN_akrr8EGuN8OGifyjM3j+W44hjOvRxxM52HbA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f171.google.com ([209.85.161.171]:34825 "EHLO
	mail-yw0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750986AbcFQVYj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2016 17:24:39 -0400
Received: by mail-yw0-f171.google.com with SMTP id z186so82669706ywd.2
        for <netdev@vger.kernel.org>; Fri, 17 Jun 2016 14:24:38 -0700 (PDT)
In-Reply-To: <CAM_iQpU42hydN_akrr8EGuN8OGifyjM3j+W44hjOvRxxM52HbA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 17, 2016 at 2:03 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> Hi, Eric
>
> During code review, I notice we might have some problem after we go
> lockless for the fast path in act_mirred.
>
> That is, what prevents us from the following possible race condition?
>
> change a standalone action with tcf_mirred_init():
>   // search for an existing action in hash
>   // found it and got struct tcf_common
>   m = to_mirred(a);
>   m->tcf_action = parm->action;
>   // Interrupted by BH
>
> tcf_mirred() jumps in:
>   rcu_read_lock()
>   retval = READ_ONCE(m->tcf_action);
>   if (m->tcfm_eaction != TCA_EGRESS_MIRROR)
>   ....
>   rcu_unread_lock()
>
> now go back to tcf_mirred_init():
>   m->tcfm_eaction = parm->eaction;
>   ....
>
> IOW, the fast path could read a partially written change which could
> be a problem? We need to allocate a new copy and then replace the old
> one with it via RCU, don't we?
>
> I can work on some patches, I want to make sure I don't miss anything here.
>
> Thanks!

Well, I added a READ_ONCE() to read tcf_action once.

Adding rcu here would mean adding a pointer and extra cache line, to
deref the values.

IMHO the race here has no effect . You either read the old or new value.

If the packet is processed before or after the 'change' it would have
the same 'race'

All these fields are integers, they never are 'partially written'.

The only case m->tcfm_eaction could be read twice is in the error
path. Who cares ?
