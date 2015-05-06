From: Cong Wang <cwang@twopensource.com>
Subject: Re: [RFC PATCH v2 net-next] netlink: avoid namespace change while
 creating socket
Date: Wed, 6 May 2015 16:03:48 -0700
Message-ID: <CAHA+R7N4R4-=XKTpRzT1zvR61MZuwiQgk-+SgHiCvACq58fzSw@mail.gmail.com>
References: <1430892526-2446-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>, xemul@openvz.org,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f50.google.com ([74.125.82.50]:33815 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751459AbbEFXDt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 19:03:49 -0400
Received: by wgic8 with SMTP id c8so354895wgi.1
        for <netdev@vger.kernel.org>; Wed, 06 May 2015 16:03:48 -0700 (PDT)
In-Reply-To: <1430892526-2446-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 5, 2015 at 11:08 PM, Ying Xue <ying.xue@windriver.com> wrote:
> Commit 23fe18669e7f ("[NETNS]: Fix race between put_net() and
> netlink_kernel_create().") attempts to fix the following race
> scenario:
>
> put_net()
>   if (atomic_dec_and_test(&net->refcnt))
>     /* true */
>       __put_net(net);
>         queue_work(...);
>
> /*
>  * note: the net now has refcnt 0, but still in
>  * the global list of net namespaces
>  */
>
> == re-schedule ==
>
> register_pernet_subsys(&some_ops);
>   register_pernet_operations(&some_ops);
>     (*some_ops)->init(net);
>       /*
>        * we call netlink_kernel_create() here
>        * in some places
>        */
>       netlink_kernel_create();
>          sk_alloc();
>             get_net(net); /* refcnt = 1 */
>          /*
>           * now we drop the net refcount not to
>           * block the net namespace exit in the
>           * future (or this can be done on the
>           * error path)
>           */
>          put_net(sk->sk_net);
>              if (atomic_dec_and_test(&...))
>                    /*
>                     * true. BOOOM! The net is
>                     * scheduled for release twice
>                     */
>
> In order to prevent the race from happening, the commit adopted the
> following solution: create netlink socket inside init_net namespace
> and then re-attach it to the desired one right after the socket is
> created; similarly, when close the socket, move back its namespace
> to init_net so that the socket can be destroyed in the context which
> is same as the socket creation.
>
> Actually the proposal artificially makes the whole thing complex.
> Instead there exists a simpler solution to avoid the risk of net
> double release: if we find that the net reference counter reaches
> zero before the reference counter will be increased in sk_alloc(),
> we can identify that the process of the net namespace exit happening
> in workqueue is not finished yet. At the moment, we should immediately
> exit from sk_alloc() to avoid the risk. This is because once refcount
> reaches zero, the net will be definetely destroyed later in workqueue
> whatever we take its refcount or not. This solution is not only simple
> and easily understandable, but also it can help to avoid the redundant
> namespace change.
>

Hmm, why does the caller have to handle some race condition of the callee?
Isn't this solvable at netns API layer?

How about the following patch (PoC ONLY) ? __put_net() should be able
to detect a pending cleanup work, shouldn't it?

diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 78fc04a..ded15a7 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -242,6 +242,7 @@ static __net_init int setup_net(struct net *net,
struct user_namespace *user_ns)
        net->dev_base_seq = 1;
        net->user_ns = user_ns;
        idr_init(&net->netns_ids);
+       LIST_HEAD_INIT(&net->cleanup_list);

        list_for_each_entry(ops, &pernet_list, list) {
                error = ops_init(ops, net);
@@ -409,12 +410,17 @@ void __put_net(struct net *net)
 {
        /* Cleanup the network namespace in process context */
        unsigned long flags;
+       bool added = false;

        spin_lock_irqsave(&cleanup_list_lock, flags);
-       list_add(&net->cleanup_list, &cleanup_list);
+       if (list_empty(&net->cleanup_list)) {
+               list_add(&net->cleanup_list, &cleanup_list);
+               added = true;
+       }
        spin_unlock_irqrestore(&cleanup_list_lock, flags);

-       queue_work(netns_wq, &net_cleanup_work);
+       if (added)
+               queue_work(netns_wq, &net_cleanup_work);
 }
 EXPORT_SYMBOL_GPL(__put_net);
