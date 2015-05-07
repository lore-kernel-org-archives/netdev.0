From: Cong Wang <cwang@twopensource.com>
Subject: Re: [RFC PATCH net-next 00/11] netns: don't switch namespace while
 creating kernel sockets
Date: Thu, 7 May 2015 11:19:05 -0700
Message-ID: <CAHA+R7NuxGDnCSfVXJ4tcqYNZGu6RetYLvtrMo4SSqRFHKCFPg@mail.gmail.com>
References: <1430988770-28907-1-git-send-email-ying.xue@windriver.com>
	<87wq0kcqlm.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ying Xue <ying.xue@windriver.com>, netdev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>, xemul@openvz.org,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>, maxk@qti.qualcomm.com,
	Stephen Hemminger <stephen@networkplumber.org>,
	Thomas Graf <tgraf@suug.ch>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Tom Herbert <tom@herbertland.com>,
	James Chapman <jchapman@katalix.com>,
	Erik Hugne <erik.hugne@ericsson.com>, jon.maloy@ericsson.com,
	horms@verge.net.au
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f52.google.com ([209.85.215.52]:34324 "EHLO
	mail-la0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752122AbbEGSTH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2015 14:19:07 -0400
Received: by laat2 with SMTP id t2so36760536laa.1
        for <netdev@vger.kernel.org>; Thu, 07 May 2015 11:19:05 -0700 (PDT)
In-Reply-To: <87wq0kcqlm.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 7, 2015 at 9:14 AM, Eric W. Biederman <ebiederm@xmission.com> wrote:
> Ying Xue <ying.xue@windriver.com> writes:
>
>> When commit 23fe18669e7f ("[NETNS]: Fix race between put_net() and
>> netlink_kernel_create().") attempted to fix the race between put_net()
>> and kernel socket's creation, it adopted a complex solution: create
>> netlink socket inside init_net namespace and then re-attach it to the
>> desired one right after the socket is created; similarly, when close
>> the socket, move back its namespace to init_net so that the socket can
>> be destroyed in the context which is same as the socket creation.
>>
>> But the solution artificially makes the whole thing complex as its
>> design is not only weird, but also it causes a bad consequence that
>> when all kernel modules create kernel sockets, they have to follow
>> the model of namespace switch. More importantly, with the way kernel
>> sockets are created in init_net namespace, but they are released in
>> another new ones. This inconsistent namespace brings some modules many
>> inconvenience. For example, what tipc socket is inserted to rhashtable
>> happens in socket's creation, and different namespace has different
>> rhashtable for tipc socket. With the approach, a tipc kernel socket
>> will be inserted into the rhashtable of init_net. But as releasing
>> the socket happens in another one, it causes what the socket cannot
>> be found from the rhashtable of the new namespace.
>>
>> Therefore, we propose a simpler solution to avoid the race: if we
>> find there is still pending a cleanup work in __put_net(), we don't
>> queue a new cleanup work to stop the cleanup process. The new proposal
>> not only successfully solves the race, but also it can help us to
>> avoid unnecessary namespace switches when creating kernel sockets.
>> Moreover, it can guarantee that both creation and release of kernel
>> sockets happen in the same namespace at all time.
>>
>> In the series, we first resolve the race with patch #1, and then
>> prevent namespace switches from happening in all relevant kernel
>> modules one by one from patch #2 to patch #9. Until now, as all
>> dependencies on sk_change_net() are killed, we can delete the
>> interface completely in patch #10. Lastly, we simplify the code of
>> creating kernel sockets through changing the original behaviours
>> of sock_create_kern() and sk_release_kernel(). If a kernel socket
>> is created within a namespace which is different with init_net,
>> we must put the reference counter of the namespace once the socket
>> is successfully allocated in sk_alloc(), otherwise, the namespace
>> is probably unable to be shut down finally. Therefore, we decrease
>> namespace's reference counter once a kernel socket is created
>> successfully by sock_create_kern() within a namespace which is
>> different with init_net. Similarly, namespace's reference counter
>> must be increased back before the socket is destroyed in
>> sk_release_kernel().
>>
>> Welcome to any comments.
>
> I agree that commit 23fe18669e7f ("[NETNS]: Fix race between put_net()
> and netlink_kernel_create()."  was a hack.
>
> However it is not appropriate to call get_net on a network namespace
> whose count might be zero.  I believe all of your patches rely on that
> currently.  Instead we need to build something like sk_release_kernel
> that does not increase the network namespace reference count if you are
> going to avoid changing the network namespace on a socket (a worthy
> goal).
>
> The following change shows how it is possible to always know that your
> network namespace has a non-zero reference count in the network
> namespace initialization methods.  My implementation of
> lock_network_namespaces is problematic in that it does not sleep
> while network namespaces are unregistering.  But it is enough to show
> how the locking and reference counting can be fixed.

Why does this have to be so complicated? We can simply avoid
calling ops_init() by skipping those in cleanup_list, no?

diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 78fc04a..c7cbd5a 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -242,6 +242,7 @@ static __net_init int setup_net(struct net *net,
struct user_namespace *user_ns)
        net->dev_base_seq = 1;
        net->user_ns = user_ns;
        idr_init(&net->netns_ids);
+       INIT_LIST_HEAD(&net->cleanup_list);

        list_for_each_entry(ops, &pernet_list, list) {
                error = ops_init(ops, net);
@@ -737,6 +738,8 @@ static int __register_pernet_operations(struct
list_head *list,
        list_add_tail(&ops->list, list);
        if (ops->init || (ops->id && ops->size)) {
                for_each_net(net) {
+                       if (!list_empty(net->cleanup_list)) // <---
Need a big comment here;
+                               continue;
                        error = ops_init(ops, net);
                        if (error)
                                goto out_undo;
