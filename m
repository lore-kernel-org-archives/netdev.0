From: Cong Wang <cwang@twopensource.com>
Subject: Re: [RFC PATCH net-next 00/11] netns: don't switch namespace while
 creating kernel sockets
Date: Thu, 7 May 2015 12:29:55 -0700
Message-ID: <CAHA+R7N9BuJGnA1r_K886pr45EP6ry85T2pbr2u8neJs-ROrYw@mail.gmail.com>
References: <1430988770-28907-1-git-send-email-ying.xue@windriver.com>
	<87wq0kcqlm.fsf@x220.int.ebiederm.org>
	<CAHA+R7NuxGDnCSfVXJ4tcqYNZGu6RetYLvtrMo4SSqRFHKCFPg@mail.gmail.com>
	<871tisckgr.fsf@x220.int.ebiederm.org>
	<CAHA+R7POE-X0Tbn6XEGSta=tDZQ_+EDg0ruSxy3qMFNm9Rd0oQ@mail.gmail.com>
	<87twvob4fe.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ying Xue <ying.xue@windriver.com>, netdev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Pavel Emelyanov <xemul@openvz.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>, maxk@qti.qualcomm.com,
	Stephen Hemminger <stephen@networkplumber.org>,
	Thomas Graf <tgraf@suug.ch>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Tom Herbert <tom@herbertland.com>,
	James Chapman <jchapman@katalix.com>,
	Erik Hugne <erik.hugne@ericsson.com>, jon.maloy@ericsson.com,
	Simon Horman <horms@verge.net.au>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f43.google.com ([74.125.82.43]:35254 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751236AbbEGT34 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2015 15:29:56 -0400
Received: by wgyo15 with SMTP id o15so53438059wgy.2
        for <netdev@vger.kernel.org>; Thu, 07 May 2015 12:29:55 -0700 (PDT)
In-Reply-To: <87twvob4fe.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 7, 2015 at 11:58 AM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
> Cong Wang <cwang@twopensource.com> writes:
>
>> On Thu, May 7, 2015 at 11:26 AM, Eric W. Biederman
>> <ebiederm@xmission.com> wrote:
>>> Cong Wang <cwang@twopensource.com> writes:
>>>
>>>>
>>>> Why does this have to be so complicated? We can simply avoid
>>>> calling ops_init() by skipping those in cleanup_list, no?
>>>
>>> The problem is that there is a single list of methods to call and if you
>>> simply skip calling the initialization methods for a struct net and add
>>> yourself to the list cleanup_net will then call the cleanup methods
>>> without calling the cleanup methods.
>>
>> If you mean pernet_list, ops->list has been already added before
>> for_each_net().
>>
>>>
>>> Simply limiting new network namespace registrations to a point when
>>> network namespaces are not being registered or unregisted seems like
>>> the simplest way to achieve this effect.
>>>
>>
>> Literally, any point before ops_init().
>
> Think about what that what it means to add a set of operations to the
> pernet_list and then to skip a network namespace with a count of 0 and
> then to have that network namespace exit with those methods on
> pernet_list.
>

That is easy to solve, isn't it?

diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 78fc04a..d2af11e 100644
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
@@ -734,20 +735,21 @@ static int __register_pernet_operations(struct
list_head *list,
        int error;
        LIST_HEAD(net_exit_list);

-       list_add_tail(&ops->list, list);
        if (ops->init || (ops->id && ops->size)) {
                for_each_net(net) {
+                       if (!list_empty(&net->cleanup_list))
+                               continue;
                        error = ops_init(ops, net);
                        if (error)
                                goto out_undo;
                        list_add_tail(&net->exit_list, &net_exit_list);
                }
        }
+       list_add_tail(&ops->list, list);
        return 0;

 out_undo:
        /* If I have an error cleanup all namespaces I initialized */
-       list_del(&ops->list);
        ops_exit_list(ops, &net_exit_list);
        ops_free_list(ops, &net_exit_list);
        return error;


The problem with your approach is that the code is over complicated,
the netns core code is already too complicated. ;)
