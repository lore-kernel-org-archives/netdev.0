From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 1/3] ipv4: initialize fib_trie prior to register_netdev_notifier call.
Date: Wed, 19 Jul 2017 17:51:16 -0500
Message-ID: <87vamo9h23.fsf@xmission.com>
References: <20170719224133.34666-1-mahesh@bandewar.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        netdev <netdev@vger.kernel.org>,
        Mahesh Bandewar <maheshb@google.com>
To: Mahesh Bandewar <mahesh@bandewar.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:49338 "EHLO
        out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752102AbdGSW70 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2017 18:59:26 -0400
In-Reply-To: <20170719224133.34666-1-mahesh@bandewar.net> (Mahesh Bandewar's
        message of "Wed, 19 Jul 2017 15:41:33 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mahesh Bandewar <mahesh@bandewar.net> writes:

> From: Mahesh Bandewar <maheshb@google.com>
>
> Net stack initialization currently initializes fib-trie after the
> first call to netdevice_notifier() call. In fact fib_trie initialization
> needs to happen before first rtnl_register(). It does not cause any problem
> since there are no devices UP at this moment, but trying to bring 'lo'
> UP at initialization would make this assumption wrong and exposes the issue.
>
> Fixes following crash
>
>  Call Trace:
>   ? alternate_node_alloc+0x76/0xa0
>   fib_table_insert+0x1b7/0x4b0
>   fib_magic.isra.17+0xea/0x120
>   fib_add_ifaddr+0x7b/0x190
>   fib_netdev_event+0xc0/0x130
>   register_netdevice_notifier+0x1c1/0x1d0
>   ip_fib_init+0x72/0x85
>   ip_rt_init+0x187/0x1e9
>   ip_init+0xe/0x1a
>   inet_init+0x171/0x26c
>   ? ipv4_offload_init+0x66/0x66
>   do_one_initcall+0x43/0x160
>   kernel_init_freeable+0x191/0x219
>   ? rest_init+0x80/0x80
>   kernel_init+0xe/0x150
>   ret_from_fork+0x22/0x30
>  Code: f6 46 23 04 74 86 4c 89 f7 e8 ae 45 01 00 49 89 c7 4d 85 ff 0f 85 7b ff ff ff 31 db eb 08 4c 89 ff e8 16 47 01 00 48 8b 44 24 38 <45> 8b 6e 14 4d 63 76 74 48 89 04 24 0f 1f 44 00 00 48 83 c4 08
>  RIP: kmem_cache_alloc+0xcf/0x1c0 RSP: ffff9b1500017c28
>  CR2: 0000000000000014
>
> Fixes: 7b1a74fdbb9e ("[NETNS]: Refactor fib initialization so it can handle multiple namespaces.")
> Fixes: 7f9b80529b8a ("[IPV4]: fib hash|trie initialization")

Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>

>
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> ---
>  net/ipv4/fib_frontend.c | 9 +++++----
>  1 file changed, 5 insertions(+), 4 deletions(-)
>
> diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
> index 4e678fa892dd..044d2a159a3c 100644
> --- a/net/ipv4/fib_frontend.c
> +++ b/net/ipv4/fib_frontend.c
> @@ -1334,13 +1334,14 @@ static struct pernet_operations fib_net_ops = {
>  
>  void __init ip_fib_init(void)
>  {
> -	rtnl_register(PF_INET, RTM_NEWROUTE, inet_rtm_newroute, NULL, NULL);
> -	rtnl_register(PF_INET, RTM_DELROUTE, inet_rtm_delroute, NULL, NULL);
> -	rtnl_register(PF_INET, RTM_GETROUTE, NULL, inet_dump_fib, NULL);
> +	fib_trie_init();
>  
>  	register_pernet_subsys(&fib_net_ops);
> +
>  	register_netdevice_notifier(&fib_netdev_notifier);
>  	register_inetaddr_notifier(&fib_inetaddr_notifier);
>  
> -	fib_trie_init();
> +	rtnl_register(PF_INET, RTM_NEWROUTE, inet_rtm_newroute, NULL, NULL);
> +	rtnl_register(PF_INET, RTM_DELROUTE, inet_rtm_delroute, NULL, NULL);
> +	rtnl_register(PF_INET, RTM_GETROUTE, NULL, inet_dump_fib, NULL);
>  }
