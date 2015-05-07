From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [RFC PATCH v2 net-next] netlink: avoid namespace change while
 creating socket
Date: Thu, 7 May 2015 16:57:24 +0800
Message-ID: <554B28F4.8060301@windriver.com>
References: <1430892526-2446-1-git-send-email-ying.xue@windriver.com> <CAHA+R7N4R4-=XKTpRzT1zvR61MZuwiQgk-+SgHiCvACq58fzSw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>, <xemul@openvz.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:35658 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750725AbbEGI67 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2015 04:58:59 -0400
In-Reply-To: <CAHA+R7N4R4-=XKTpRzT1zvR61MZuwiQgk-+SgHiCvACq58fzSw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/07/2015 07:03 AM, Cong Wang wrote:
> On Tue, May 5, 2015 at 11:08 PM, Ying Xue <ying.xue@windriver.com> wrote:
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
>>
>> In order to prevent the race from happening, the commit adopted the
>> following solution: create netlink socket inside init_net namespace
>> and then re-attach it to the desired one right after the socket is
>> created; similarly, when close the socket, move back its namespace
>> to init_net so that the socket can be destroyed in the context which
>> is same as the socket creation.
>>
>> Actually the proposal artificially makes the whole thing complex.
>> Instead there exists a simpler solution to avoid the risk of net
>> double release: if we find that the net reference counter reaches
>> zero before the reference counter will be increased in sk_alloc(),
>> we can identify that the process of the net namespace exit happening
>> in workqueue is not finished yet. At the moment, we should immediately
>> exit from sk_alloc() to avoid the risk. This is because once refcount
>> reaches zero, the net will be definetely destroyed later in workqueue
>> whatever we take its refcount or not. This solution is not only simple
>> and easily understandable, but also it can help to avoid the redundant
>> namespace change.
>>
> 
> Hmm, why does the caller have to handle some race condition of the callee?
> Isn't this solvable at netns API layer?
> 
> How about the following patch (PoC ONLY) ? __put_net() should be able
> to detect a pending cleanup work, shouldn't it?
> 

Thanks to Cong! Your below idea is absolutely better than mine.

I have created a whole series based on the idea. Please review them.
In addition, I am not sure whether I should use your "Suggested-by" or
"Signed-off-by" tag in the first patch. But I finally selected the
"Suggested-by". If you think the tag is inappropriate, please let me know. I
will replace it with "Signed-off-by" tag in next version.

Thanks,
Ying

> diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
> index 78fc04a..ded15a7 100644
> --- a/net/core/net_namespace.c
> +++ b/net/core/net_namespace.c
> @@ -242,6 +242,7 @@ static __net_init int setup_net(struct net *net,
> struct user_namespace *user_ns)
>         net->dev_base_seq = 1;
>         net->user_ns = user_ns;
>         idr_init(&net->netns_ids);
> +       LIST_HEAD_INIT(&net->cleanup_list);
> 
>         list_for_each_entry(ops, &pernet_list, list) {
>                 error = ops_init(ops, net);
> @@ -409,12 +410,17 @@ void __put_net(struct net *net)
>  {
>         /* Cleanup the network namespace in process context */
>         unsigned long flags;
> +       bool added = false;
> 
>         spin_lock_irqsave(&cleanup_list_lock, flags);
> -       list_add(&net->cleanup_list, &cleanup_list);
> +       if (list_empty(&net->cleanup_list)) {
> +               list_add(&net->cleanup_list, &cleanup_list);
> +               added = true;
> +       }
>         spin_unlock_irqrestore(&cleanup_list_lock, flags);
> 
> -       queue_work(netns_wq, &net_cleanup_work);
> +       if (added)
> +               queue_work(netns_wq, &net_cleanup_work);
>  }
>  EXPORT_SYMBOL_GPL(__put_net);
> 
> 
