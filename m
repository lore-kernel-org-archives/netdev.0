From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [RFC PATCH net-next] netlink: avoid namespace change while creating
 socket
Date: Tue, 5 May 2015 10:38:52 +0800
Message-ID: <55482D3C.9070405@windriver.com>
References: <1430731339-22292-1-git-send-email-ying.xue@windriver.com> <20150505015204.GA4993@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <xemul@openvz.org>, <den@openvz.org>, <davem@davemloft.net>,
	<avagin@gmail.com>, <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:34343 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755364AbbEECjJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 22:39:09 -0400
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

In addition, even if the caller of netlink_kernel_create() holds the net
refcount again, it's still unable to prevent the issue of releasing net twice
from happening. This is because the net's refcount is already decreased to 0 in
put_net(), which means the net will be destroyed in the future whatever we take
its refcount or not. In other words, once refcount reaches zero, we absolutely
should not touch the net again.

Regards,
Ying

> Cheers,
> 
