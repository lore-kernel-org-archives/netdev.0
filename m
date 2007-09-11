From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [RFC PATCH 1/2] SCTP: Add RCU synchronization around sctp_localaddr_list
Date: Tue, 11 Sep 2007 10:05:10 -0400
Message-ID: <46E6A096.9010208@hp.com>
References: <11894535901969-git-send-email-vladislav.yasevich@hp.com> <11894535913932-git-send-email-vladislav.yasevich@hp.com> <20070910214712.GI11801@linux.vnet.ibm.com> <46E642AA.7090703@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com, netdev@vger.kernel.org,
	lksctp-developers@lists.sourceforge.net
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:44920 "EHLO atlrel9.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750852AbXIKOFN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Sep 2007 10:05:13 -0400
In-Reply-To: <46E642AA.7090703@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sridhar, Paul

Thanks for review.  Some answers and questions below...

Sridhar Samudrala wrote:
> Paul E. McKenney wrote:
>> On Mon, Sep 10, 2007 at 03:46:29PM -0400, Vlad Yasevich wrote:
>>> sctp_localaddr_list is modified dynamically via NETDEV_UP
>>> and NETDEV_DOWN events, but there is not synchronization
>>> between writer (even handler) and readers.  As a result,
>>> the readers can access an entry that has been freed and
>>> crash the sytem.
>>
>> Good start, but few questions interspersed below...
>>
>>                             Thanx, Paul
>>

>>> diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
>>> index f8aa23d..fc2e4e2 100644
>>> --- a/net/sctp/ipv6.c
>>> +++ b/net/sctp/ipv6.c
>>> @@ -77,13 +77,18 @@
>>>
>>>  #include <asm/uaccess.h>
>>>
>>> -/* Event handler for inet6 address addition/deletion events.  */
>>> +/* Event handler for inet6 address addition/deletion events.
>>> + * This even is part of the atomic notifier call chain
>>> + * and thus happens atomically and can NOT sleep.  As a result
>>> + * we can't and really don't need to add any locks to guard the
>>> + * RCU.
>>> + */
>>>  static int sctp_inet6addr_event(struct notifier_block *this,
>>> unsigned long ev,
>>>                  void *ptr)
>>>  {
>>>      struct inet6_ifaddr *ifa = (struct inet6_ifaddr *)ptr;
>>> -    struct sctp_sockaddr_entry *addr;
>>> -    struct list_head *pos, *temp;
>>> +    struct sctp_sockaddr_entry *addr = NULL;
>>> +    struct sctp_sockaddr_entry *temp;
>>>
>>>      switch (ev) {
>>>      case NETDEV_UP:
>>> @@ -94,19 +99,26 @@ static int sctp_inet6addr_event(struct
>>> notifier_block *this, unsigned long ev,
>>>              memcpy(&addr->a.v6.sin6_addr, &ifa->addr,
>>>                   sizeof(struct in6_addr));
>>>              addr->a.v6.sin6_scope_id = ifa->idev->dev->ifindex;
>>> -            list_add_tail(&addr->list, &sctp_local_addr_list);
>>> +            addr->valid = 1;
>>> +            rcu_read_lock();
>>> +            list_add_tail_rcu(&addr->list, &sctp_local_addr_list);
>>> +            rcu_read_unlock();
>>
>> If we are under the protection of the update-side mutex, the
>> rcu_read_lock()
>> and rcu_read_unlock() are (harmlessly) redundant.  If we are not under
>> the protection of some mutex, what prevents concurrent
>> list_add_tail_rcu()
>> calls from messing up the sctp_sockaddr_entry list?
> 
> This is an atomic notifier call chain event and as such can be called
> from a
> softirq. So i think we need a spin_lock_bh here.

But the question is, can two notifiers be called at the same time?
If yes, then I think there is need for spin lock protection.  (and I think
bonding might need that too).

> 
>>
>>>          }
>>>          break;
>>>      case NETDEV_DOWN:
>>> -        list_for_each_safe(pos, temp, &sctp_local_addr_list) {
>>> -            addr = list_entry(pos, struct sctp_sockaddr_entry, list);
>>> -            if (ipv6_addr_equal(&addr->a.v6.sin6_addr, &ifa->addr)) {
>>> -                list_del(pos);
>>> -                kfree(addr);
>>> +        rcu_read_lock();
>>> +        list_for_each_entry_safe(addr, temp,
>>> +                    &sctp_local_addr_list, list) {
>>> +            if (ipv6_addr_equal(&addr->a.v6.sin6_addr,
>>> +                         &ifa->addr)) {
>>> +                addr->valid = 0;
>>> +                list_del_rcu(&addr->list);
>>>                  break;
>>>              }
>>>          }
>>> -
>>> +        rcu_read_unlock();
>>> +        if (addr && !addr->valid)
>>> +            call_rcu(&addr->rcu, sctp_local_addr_free);
>>
>> Are we under the protection of the update-side lock here?  If not,
>> what prevents two different tasks from executing this in parallel,
>> potentially tangling both the list that the sctp_sockaddr_entry list and
>> the internal RCU lists?  (It is forbidden to call_rcu() a given element
>> twice concurrently.)
>>
>> If we are in fact under the protection of the update-side lock, the
>> rcu_read_lock() and rcu_read_unlock() pairs are redundant (though this
>> is harmless, aside from the (small) potential for confusion).
> 
> There is no update-side lock protection here. We need a spin_lock_bh().

Recurring theme.  Same questions about notifiers apply.

> 
>>
>>>          break;
>>>      }
>>>
>>> @@ -368,6 +380,7 @@ static void sctp_v6_copy_addrlist(struct
>>> list_head *addrlist,
>>>              addr->a.v6.sin6_addr = ifp->addr;
>>>              addr->a.v6.sin6_scope_id = dev->ifindex;
>>>              INIT_LIST_HEAD(&addr->list);
>>> +            INIT_RCU_HEAD(&addr->rcu);
>>>              list_add_tail(&addr->list, addrlist);
>>>          }
>>>      }
>>> diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
>>> index e98579b..ac52f9e 100644
>>> --- a/net/sctp/protocol.c
>>> +++ b/net/sctp/protocol.c
>>> @@ -153,6 +153,7 @@ static void sctp_v4_copy_addrlist(struct
>>> list_head *addrlist,
>>>              addr->a.v4.sin_family = AF_INET;
>>>              addr->a.v4.sin_port = 0;
>>>              addr->a.v4.sin_addr.s_addr = ifa->ifa_local;
>>> +            INIT_RCU_HEAD(&addr->rcu);
>>>              list_add_tail(&addr->list, addrlist);
>>>          }
>>>      }
>>> @@ -192,16 +193,24 @@ static void sctp_free_local_addr_list(void)
>>>      }
>>>  }
>>>
>>> +void sctp_local_addr_free(struct rcu_head *head)
>>> +{
>>> +    struct sctp_sockaddr_entry *e = container_of(head,
>>> +                struct sctp_sockaddr_entry, rcu);
>>> +    kfree(e);
>>> +}
>>> +
>>>  /* Copy the local addresses which are valid for 'scope' into 'bp'.  */
>>>  int sctp_copy_local_addr_list(struct sctp_bind_addr *bp,
>>> sctp_scope_t scope,
>>>                    gfp_t gfp, int copy_flags)
>>>  {
>>>      struct sctp_sockaddr_entry *addr;
>>>      int error = 0;
>>> -    struct list_head *pos, *temp;
>>>
>>> -    list_for_each_safe(pos, temp, &sctp_local_addr_list) {
>>> -        addr = list_entry(pos, struct sctp_sockaddr_entry, list);
>>> +    rcu_read_lock();
>>> +    list_for_each_entry_rcu(addr, &sctp_local_addr_list, list) {
>>> +        if (!addr->valid)
>>> +            continue;
>>
>> What happens if the update-side code removes the element from the list
>> and marks it !->valid right here?
>>
>> If this turns out to be harmless, why not just dispense with the ->valid
>> flag entirely?
> 
> It should be OK if an address gets removed from the list. So i agree that
> ->valid flag is not really useful.

I added the valid flag because we don't really want to give back addresses that
are going away at the rcu quiescent state.  I agree, there is a race between
notifier marking the address invalid, and these checks on the reader side.   This
was modeled after other code that uses similar semantics.

> 
>>
>>>          if (sctp_in_scope(&addr->a, scope)) {
>>>              /* Now that the address is in scope, check to see if
>>>               * the address type is really supported by the local
>>> @@ -221,6 +230,7 @@ int sctp_copy_local_addr_list(struct
>>> sctp_bind_addr *bp, sctp_scope_t scope,
>>>      }
>>>
>>>  end_copy:
>>> +    rcu_read_unlock();
>>>      return error;
>>>  }
>>>
>>> @@ -600,13 +610,17 @@ static void sctp_v4_seq_dump_addr(struct
>>> seq_file *seq, union sctp_addr *addr)
>>>      seq_printf(seq, "%d.%d.%d.%d ", NIPQUAD(addr->v4.sin_addr));
>>>  }
>>>
>>> -/* Event handler for inet address addition/deletion events.  */
>>> +/* Event handler for inet address addition/deletion events.
>>> + * This is part of the blocking notifier call chain that is
>>> + * guarted by a mutex.  As a result we don't need to add
>>> + * any additional guards for the RCU
>>> + */
>>>  static int sctp_inetaddr_event(struct notifier_block *this, unsigned
>>> long ev,
>>>                     void *ptr)
>>>  {
>>>      struct in_ifaddr *ifa = (struct in_ifaddr *)ptr;
>>> -    struct sctp_sockaddr_entry *addr;
>>> -    struct list_head *pos, *temp;
>>> +    struct sctp_sockaddr_entry *addr = NULL;
>>> +    struct sctp_sockaddr_entry *temp;
>>>
>>>      switch (ev) {
>>>      case NETDEV_UP:
>>> @@ -615,19 +629,25 @@ static int sctp_inetaddr_event(struct
>>> notifier_block *this, unsigned long ev,
>>>              addr->a.v4.sin_family = AF_INET;
>>>              addr->a.v4.sin_port = 0;
>>>              addr->a.v4.sin_addr.s_addr = ifa->ifa_local;
>>> -            list_add_tail(&addr->list, &sctp_local_addr_list);
>>> +            addr->valid = 1;
>>> +            rcu_read_lock();
>>> +            list_add_tail_rcu(&addr->list, &sctp_local_addr_list);
>>> +            rcu_read_unlock();
>>
>> Based on the additions to the header comment, I am assuming that we
>> hold an update-side mutex.  This means that the rcu_read_lock() and
>> rcu_read_unlock() are (harmlessly) redundant.
> 
> This is called via a blocking notifier call chain and hence we could
> protect using an update-side mutex. But considering that
> sctp_inet6addr_event
> requires a spin_lock_bh(), may be we should use it here also to make it
> simple.

This again boils down the question of whether notifiers can be running concurrently...
If yes, then spin_lock_bh is the right choice.


>>
>>>          }
>>>          break;
>>>      case NETDEV_DOWN:
>>> -        list_for_each_safe(pos, temp, &sctp_local_addr_list) {
>>> -            addr = list_entry(pos, struct sctp_sockaddr_entry, list);
>>> +        rcu_read_lock();
>>> +        list_for_each_entry_safe(addr, temp,
>>> +                    &sctp_local_addr_list, list) {
>>>              if (addr->a.v4.sin_addr.s_addr == ifa->ifa_local) {
>>> -                list_del(pos);
>>> -                kfree(addr);
>>> +                addr->valid = 0;
>>> +                list_del_rcu(&addr->list);
>>>                  break;
>>>              }
>>>          }
>>> -
>>> +        rcu_read_unlock();
>>
>> Ditto.
>>
>>> +        if (addr && !addr->valid)
>>> +            call_rcu(&addr->rcu, sctp_local_addr_free);
>>
>> This one is OK, since we hold the update-side mutex.

This would need to be protected as well, if the answer to the notifier
question is yes.

>>
>>>          break;
>>>      }
>>>
>>> @@ -1227,6 +1247,9 @@ SCTP_STATIC __exit void sctp_exit(void)
>>>      sctp_v6_del_protocol();
>>>      inet_del_protocol(&sctp_protocol, IPPROTO_SCTP);
>>>
>>> +    /* Unregister notifier for inet address additions/deletions. */
>>> +    unregister_inetaddr_notifier(&sctp_inetaddr_notifier);
>>> +
>>>      /* Free the local address list.  */
>>>      sctp_free_local_addr_list();
>>>
>>> @@ -1240,9 +1263,6 @@ SCTP_STATIC __exit void sctp_exit(void)
>>>      inet_unregister_protosw(&sctp_stream_protosw);
>>>      inet_unregister_protosw(&sctp_seqpacket_protosw);
>>>
>>> -    /* Unregister notifier for inet address additions/deletions. */
>>> -    unregister_inetaddr_notifier(&sctp_inetaddr_notifier);
>>> -
>>>      sctp_sysctl_unregister();
>>>      list_del(&sctp_ipv4_specific.list);
>>>
>>> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
>>> index 3335460..a3acf78 100644
>>> --- a/net/sctp/socket.c
>>> +++ b/net/sctp/socket.c
>>> @@ -4057,9 +4057,9 @@ static int
>>> sctp_getsockopt_local_addrs_num_old(struct sock *sk, int len,
>>>                             int __user *optlen)
>>>  {
>>>      sctp_assoc_t id;
>>> +    struct list_head *pos;
>>>      struct sctp_bind_addr *bp;
>>>      struct sctp_association *asoc;
>>> -    struct list_head *pos, *temp;
>>>      struct sctp_sockaddr_entry *addr;
>>>      rwlock_t *addr_lock;
>>>      int cnt = 0;
>>> @@ -4096,15 +4096,19 @@ static int
>>> sctp_getsockopt_local_addrs_num_old(struct sock *sk, int len,
>>>          addr = list_entry(bp->address_list.next,
>>>                    struct sctp_sockaddr_entry, list);
>>>          if (sctp_is_any(&addr->a)) {
>>> -            list_for_each_safe(pos, temp, &sctp_local_addr_list) {
>>> -                addr = list_entry(pos,
>>> -                          struct sctp_sockaddr_entry,
>>> -                          list);
>>> +            rcu_read_lock();
>>> +            list_for_each_entry_rcu(addr,
>>> +                        &sctp_local_addr_list, list) {
>>> +                if (!addr->valid)
>>> +                    continue;
>>> +
>>
>> Again, what happens if the element is deleted just at this point?
>> If harmless, might be good to get rid of ->valid.
>>
>>>                  if ((PF_INET == sk->sk_family) &&
>>>                      (AF_INET6 == addr->a.sa.sa_family))
>>>                      continue;
>>> +
>>>                  cnt++;
>>>              }
>>> +            rcu_read_unlock();
>>
>> We are just counting these things, right?  If on the other hand we are
>> keeping a reference outside of rcu_read_lock() protection, then there
>> needs to be some explicit mechanism preventing the corresponding entry
>> from being freed.

In this particular case, we are just counting.  There are other cases,
we make a copy of the address in the list.  The goal was to reduce the
probability that an address that is about to be deleted at the rcu
quiescent state will not be copied/counted.

My other thought was to use atomics, but with all the yelling about atomic_read(),
that didn't seem any better then a simple __u8 flag.

Thanks
-vlad
