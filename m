From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [RFC PATCH net-next 01/11] netns: Fix race between put_net()
 and netlink_kernel_create()
Date: Fri, 8 May 2015 19:20:37 +0800
Message-ID: <554C9C05.9020803@windriver.com>
References: <1430988770-28907-1-git-send-email-ying.xue@windriver.com>	<1430988770-28907-2-git-send-email-ying.xue@windriver.com>	<20150507090450.GA31792@gondor.apana.org.au> <CAHA+R7Mc==jHi-vtyNwboYW-ysacgbA-yAG+tetx8HJFUrrf9Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, <xemul@openvz.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	<maxk@qti.qualcomm.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Thomas Graf <tgraf@suug.ch>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Tom Herbert <tom@herbertland.com>,
	James Chapman <jchapman@katalix.com>,
	Erik Hugne <erik.hugne@ericsson.com>, <jon.maloy@ericsson.com>,
	<horms@verge.net.au>
To: Cong Wang <cwang@twopensource.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:63788 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750886AbbEHLVO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2015 07:21:14 -0400
In-Reply-To: <CAHA+R7Mc==jHi-vtyNwboYW-ysacgbA-yAG+tetx8HJFUrrf9Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thank everyone for the review, comments, and suggestions!
Please see my inline responses to your inputs.

On 05/08/2015 01:19 AM, Cong Wang wrote:
> On Thu, May 7, 2015 at 2:04 AM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
>> On Thu, May 07, 2015 at 04:52:40PM +0800, Ying Xue wrote:
>>>
>>> @@ -409,12 +410,17 @@ void __put_net(struct net *net)
>>>  {
>>>       /* Cleanup the network namespace in process context */
>>>       unsigned long flags;
>>> +     bool added = false;
>>>
>>>       spin_lock_irqsave(&cleanup_list_lock, flags);
>>> -     list_add(&net->cleanup_list, &cleanup_list);
>>> +     if (list_empty(&net->cleanup_list)) {
>>> +             list_add(&net->cleanup_list, &cleanup_list);
>>> +             added = true;
>>> +     }
>>
>> Stop right there.  If a ref count is hitting zero twice you've
>> got big problems.  Because it means that after hitting zero the
>> first time it'll become positive again (if only briefly) which
>> opens you up to a race against the cleanup.
> 
> That is true.
> 
>>
>> So this idea is a non-starter.
>>
>> The rules for ref counts are really simple, if you hit zero then
>> you're dead.  Can someone explain to me in simple terms why this
>> ref count is special and needs to hit zero twice?
> 
> Because after it hits zero, it queues the final cleanup to a workqueue,
> which could be delayed (depends on when the worker will be scheduled),
> therefore there is a small window that new ->init() could come in.
> 
> You can argue that netns->init() should not see a dead netns, but
> unfortunately that seems even harder since removing netns from global
> netns list requires rtnl lock which is not doable in __put_net().
> 
> 

Cong's understanding about the race between put_net and kernel creation is right.

But in my opinion the patch is still able to cover all kinds of race conditions.
You may ask why we can get reference count of a dead net again. As the race
scenario is a bit complex, please let me spend a little more time explaining why
it's safe for us. To make the case clear, please let us consider tipc module as
an example:

//Shutdown a namesapce thread:
put_net()
  if (atomic_dec_and_test(&net->refcnt))
    /* true */ -----> the net's refcount is zero now
      __put_net(net);
        queue_work(netns_wq, &net_cleanup_work);

//Worker thread:
cleanup_net()
  mutex_lock(&net_mutex);
  rtnl_lock();
  list_del_rcu(&net->list); //delete a net from net_namespace_list
  rtnl_unlock();
  list_for_each_entry_reverse(ops, &pernet_list, list)
    ops_exit_list()
       ops->exit(net)
  mutex_unlock(&net_mutex);
  net_free(ns);

== re-schedule ==
//the thread of inserting tipc module:
tipc_init()
 register_pernet_subsys(&tipc_net_ops);
 mutex_lock(&net_mutex);
  __register_pernet_operations(&tipc_net_ops)
   for_each_net(net) //iterate the net_namespace_list
    ops_init(ops, net_dead)
      tipc_init_net(net_dead)
        tipc_topsrv_start(net_dead)
          tipc_create_listen_sock(net_dead)
            sock_create_kern(net_dead)
              sk_alloc();
                get_net(net_dead); /* refcnt = 1 */
              put_net(net_dead)
               __put_net(net_dead); /* refcnt = 0 */
                if (!list_empty(&net->cleanup_list))
                   queue_work(netns_wq, &net_cleanup_work);
           /*
            * As the net_dead is linked in net_namespace_list, we don't queue
            * the cleanup work again. cleanup_net() is not called, which means
            * the risk of double free of net is avoided.
            */

The reason why the original risk occurs is that destroying a net has to be done
in a worker thread. After a net refcount is decreased to 0, and before the
process of destroying net is finished in cleanup_net(), there remains a small
race window for us. In above case, during the tiny time, tipc module may be
inserted in another thread in which a TIPC kernel socket is created. During the
socket creation, a dead net refcout is increased from 0 to 1 in sk_allc(), and
then decreased to 0 in sk_change_net(). At the moment, the net's refcout
secondly hits zero in put_net(), subsequently __put_net() is called again, which
means cleanup_net() will be secondly called. So releasing a net twice happens!

However, as __register_pernet_operations() is protected by net_mutex and
cleanup_net() also needs to grab the net_mutex before it destroys a net, the
dead net is temporarily valid during the registration. Therefore, during this
time, we can safely operate a net to be dead like what we are doing in
tipc_init_net(), such as, get its refcout in sk_alloc() and subsequently
decrease it after socket creation. But after the registration is over, the dead
net will be freed when cleanup net thread worker is scheduled.

Actually there is another possible method to avoid namespace change. For
example, when we create a kernel socket, we don't crease its net's refcount at
all in sk_alloc(), correspondingly we don't decrease the net refcout for a
kernel socket in __sk_free(). However, it needs to change many code, and the
solution is also ugly, so it's not feasible.

Of course, if you find other race with the solution, please let me know.

Thanks,
Ying
