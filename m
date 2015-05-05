From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [RFC PATCH net-next] netlink: avoid namespace change while creating
 socket
Date: Tue, 5 May 2015 10:25:09 +0800
Message-ID: <55482A05.1020809@windriver.com>
References: <1430731339-22292-1-git-send-email-ying.xue@windriver.com> <20150505015204.GA4993@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <xemul@openvz.org>, <den@openvz.org>, <davem@davemloft.net>,
	<avagin@gmail.com>, <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:36179 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754980AbbEEC0p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 22:26:45 -0400
In-Reply-To: <20150505015204.GA4993@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/05/2015 09:52 AM, Herbert Xu wrote:
> On Mon, May 04, 2015 at 05:22:19PM +0800, Ying Xue wrote:
>> Commit 23fe18669e7f ("[NETNS]: Fix race between put_net() and
>> netlink_kernel_create().") attempts to fix the following race
>> scenario:
>>
>> put_net()
>>   if (atomic_dec_and_test(&net->refcnt))
>>     /* true */
>>       __put_net(net);
>>         queue_work(...);
>>
>> /*
>>  * note: the net now has refcnt 0, but still in
>>  * the global list of net namespaces
>>  */
>>
>> == re-schedule ==
>>
>> register_pernet_subsys(&some_ops);
>>   register_pernet_operations(&some_ops);
>>     (*some_ops)->init(net);
>>       /*
>>        * we call netlink_kernel_create() here
>>        * in some places
>>        */
>>       netlink_kernel_create();
>>          sk_alloc();
>>             get_net(net); /* refcnt = 1 */
>>          /*
>>           * now we drop the net refcount not to
>>           * block the net namespace exit in the
>>           * future (or this can be done on the
>>           * error path)
>>           */
>>          put_net(sk->sk_net);
>>              if (atomic_dec_and_test(&...))
>>                    /*
>>                     * true. BOOOM! The net is
>>                     * scheduled for release twice
>>                     */
> 
> Surely the problem here is that the caller of netlink_kernel_create
> should hold a ref count on net, so why doesn't it?
> 

I guess the main reason is because calling netlink_kernel_create() just happens
on the path of registering a network namespace subsystem. When
__register_pernet_operations() iterates the global list of net namespace(ie,
net_namespace_list) with for_each_net() to call each net's ops_init(ops, net),
it's supposed that it's safe to touch net instance without holding its refcount
as the net_namespace_list is being protected by net_mutex lock. More
importantly, even if the net refcount is decremented to 0 in putnet(), the net
is still in the global list of net namesapces(ie, net_namespace_list). This is
why the race happens.

Regards,
Ying


> Cheers,
> 
