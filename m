From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 1/2] ipv4: initialize fib_trie prior to register_netdev_notifier call.
Date: Wed, 05 Jul 2017 11:24:22 -0500
Message-ID: <87lgo2g8cp.fsf@xmission.com>
References: <20170704191620.6503-1-mahesh@bandewar.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        netdev <netdev@vger.kernel.org>,
        Mahesh Bandewar <maheshb@google.com>
To: Mahesh Bandewar <mahesh@bandewar.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:46741 "EHLO
        out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751756AbdGEQcZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Jul 2017 12:32:25 -0400
In-Reply-To: <20170704191620.6503-1-mahesh@bandewar.net> (Mahesh Bandewar's
        message of "Tue, 4 Jul 2017 12:16:20 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mahesh Bandewar <mahesh@bandewar.net> writes:

> From: Mahesh Bandewar <maheshb@google.com>
>
> Net stack initialization currently initializes fib-trie after the
> first call to netdevice_notifier() call. It does not cause any problem
> since there are no devices UP at this moment, but trying to bring 'lo'
> UP at initialization would make this assumption wrong. However changing
> order solves the issue.

This looks like a real issue and you are part of the way to a real fix.
The principle being you should not register things notifications until
you are ready to handle them.

As such fib_trie_init (which allocates the slabs) needs to come before
rtnl_register.  As a rtnl message can trigger slab allocation.

I have not traced it through but I suspect
register_pernet_subsys(&fib_net_ops) also needs to come before
rtnl_register.

Sigh.  It looks like this patch can be labeled:

Fixes: 7b1a74fdbb9e ("[NETNS]: Refactor fib initialization so it can handle multiple namespaces.")
Fixes: 7f9b80529b8a ("[IPV4]: fib hash|trie initialization")

So I really think the code needs to say:

void __init ip_fib_init(void)
{
	fib_trie_init();
	register_pernet_subsys(&fib_net_ops);

	register_netdevice_notifier(&fib_netdev_notifier);
	register_inetaddr_notifier(&fib_inetaddr_notifier);

	rtnl_register(PF_INET, RTM_NEWROUTE, inet_rtm_newroute, NULL, NULL);
	rtnl_register(PF_INET, RTM_DELROUTE, inet_rtm_delroute, NULL, NULL);
	rtnl_register(PF_INET, RTM_GETROUTE, NULL, inet_dump_fib, NULL);
}

Eric
