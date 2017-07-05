From: =?UTF-8?B?TWFoZXNoIEJhbmRld2FyICjgpK7gpLngpYfgpLYg4KSs4KSC4KSh4KWH4KS14KS+4KSwKQ==?=
        <maheshb@google.com>
Subject: Re: [PATCH 1/2] ipv4: initialize fib_trie prior to
 register_netdev_notifier call.
Date: Wed, 5 Jul 2017 10:23:06 -0700
Message-ID: <CAF2d9jgxOPxo9muz0qFcD1+GyidoPavsooeHxvQ3GNqwLWi4LQ@mail.gmail.com>
References: <20170704191620.6503-1-mahesh@bandewar.net> <87lgo2g8cp.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Mahesh Bandewar <mahesh@bandewar.net>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        netdev <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f53.google.com ([209.85.214.53]:36156 "EHLO
        mail-it0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750896AbdGERX2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Jul 2017 13:23:28 -0400
Received: by mail-it0-f53.google.com with SMTP id m68so118502748ith.1
        for <netdev@vger.kernel.org>; Wed, 05 Jul 2017 10:23:28 -0700 (PDT)
In-Reply-To: <87lgo2g8cp.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 5, 2017 at 9:24 AM, Eric W. Biederman <ebiederm@xmission.com> wrote:
> Mahesh Bandewar <mahesh@bandewar.net> writes:
>
>> From: Mahesh Bandewar <maheshb@google.com>
>>
>> Net stack initialization currently initializes fib-trie after the
>> first call to netdevice_notifier() call. It does not cause any problem
>> since there are no devices UP at this moment, but trying to bring 'lo'
>> UP at initialization would make this assumption wrong. However changing
>> order solves the issue.
>
> This looks like a real issue and you are part of the way to a real fix.
> The principle being you should not register things notifications until
> you are ready to handle them.
>
> As such fib_trie_init (which allocates the slabs) needs to come before
> rtnl_register.  As a rtnl message can trigger slab allocation.
>
> I have not traced it through but I suspect
> register_pernet_subsys(&fib_net_ops) also needs to come before
> rtnl_register.
>
> Sigh.  It looks like this patch can be labeled:
>
> Fixes: 7b1a74fdbb9e ("[NETNS]: Refactor fib initialization so it can handle multiple namespaces.")
> Fixes: 7f9b80529b8a ("[IPV4]: fib hash|trie initialization")
>
> So I really think the code needs to say:
>
> void __init ip_fib_init(void)
> {
>         fib_trie_init();
>         register_pernet_subsys(&fib_net_ops);
>
>         register_netdevice_notifier(&fib_netdev_notifier);
>         register_inetaddr_notifier(&fib_inetaddr_notifier);
>
>         rtnl_register(PF_INET, RTM_NEWROUTE, inet_rtm_newroute, NULL, NULL);
>         rtnl_register(PF_INET, RTM_DELROUTE, inet_rtm_delroute, NULL, NULL);
>         rtnl_register(PF_INET, RTM_GETROUTE, NULL, inet_dump_fib, NULL);
> }
>
Will update in the next version.

thanks,
--mahesh..
> Eric
