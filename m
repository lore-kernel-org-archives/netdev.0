From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [IPV4 3/5] fib_trie: dump doesnt use RCU
Date: Wed, 23 Jan 2008 22:45:02 -0800
Message-ID: <479833EE.1090905@linux-foundation.org>
References: <20080123224844.610730277@linux-foundation.org>	<20080123224858.918669715@linux-foundation.org> <20080123.205007.16809712.davem@davemloft.net> <47983304.3030309@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:42051 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754646AbYAXGol (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2008 01:44:41 -0500
In-Reply-To: <47983304.3030309@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
> David Miller wrote:
>> From: Stephen Hemminger <shemminger@linux-foundation.org>
>> Date: Wed, 23 Jan 2008 14:48:47 -0800
>>
>>  
>>> Since fib dump (via netlink) holds the RTNL mutex, it is unnecessary
>>> to use RCU, and it is impossible to get truncated (-EBUSY) result.
>>>
>>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>>>     
>>
>> You tested this patch, right? :-/
>>
>> The whole reason we need the nlk->cb[] state is to hold things across
>> multiple recvmsg() calls that might be necessary to obtain the full
>> dump.
>>
>> rtnetlink goes:
>>
>>     rtnl_lock();
>>     netlink_rcv_skb(skb, &rtnetlink_rcv_msg);
>>  ...
>> static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
>> {
>>  ...
>>     if (kind == 2 && nlh->nlmsg_flags&NLM_F_DUMP) {
>>         struct sock *rtnl;
>>         rtnl_dumpit_func dumpit;
>>
>>         dumpit = rtnl_get_dumpit(family, type);
>>         if (dumpit == NULL)
>>             return -EOPNOTSUPP;
>>
>>         __rtnl_unlock();
>>         rtnl = net->rtnl;
>>         err = netlink_dump_start(rtnl, skb, nlh, dumpit, NULL);
>>         rtnl_lock();
>>         return err;
>>
>> (NOTE: Drops RTNL semaphore for netlink_dump_start() call)
>>
>>  ...
>> int netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
>>                struct nlmsghdr *nlh,
>>                int (*dump)(struct sk_buff *skb,
>>                    struct netlink_callback *),
>>                int (*done)(struct netlink_callback *))
>> {
>>  ...
>>     cb->dump = dump;
>>     cb->done = done;
>>     cb->nlh = nlh;
>>     atomic_inc(&skb->users);
>>     cb->skb = skb;
>>  ...
>>     mutex_lock(nlk->cb_mutex);
>>  ...
>>     nlk->cb = cb;
>>     mutex_unlock(nlk->cb_mutex);
>>
>>     netlink_dump(sk);
>>  ...
>>
>> static int netlink_dump(struct sock *sk)
>> {
>>  ...
>>     mutex_lock(nlk->cb_mutex);
>>  ...
>>     len = cb->dump(skb, cb);
>>
>>     if (len > 0) {
>>         mutex_unlock(nlk->cb_mutex);
>>         skb_queue_tail(&sk->sk_receive_queue, skb);
>>         sk->sk_data_ready(sk, len);
>>         return 0;
>>     }
>>
>> (NOTE: Therefore cb->dump() runs without RTNL semaphore held)
>>
>>  ...
>> static int netlink_recvmsg(struct kiocb *kiocb, struct socket *sock,
>>                struct msghdr *msg, size_t len,
>>                int flags)
>> {
>>  ...
>>     if (nlk->cb && atomic_read(&sk->sk_rmem_alloc) <= sk->sk_rcvbuf / 2)
>>         netlink_dump(sk);
>>  ...
>>
>> Therefore, that RTNL assertion you added should have triggered on any
>> dump you may have tried since ->dump() is always invoked without the
>> RTNL semaphore since rtnetlink drops it around the ->dump() call and
>> the call chain for this fib_trie cause would be:
>>
>> inet_dump_fib()
>>  fn_trie_dump()
>>
>> and nothing in that code path retakes the RTNL semaphore.
>
> Actually we're always holding the rtnl during dumps, nlk->cb_mutex points
> to rtnl_mutex in case of rtnetlink. It used to be held only during the 
> first
> ->dump invocation and not on continuations, but I changed this a few 
> versions
> ago.
>
>
Yes, I tested, no the assert didn't hit... Actually, the reason I went 
down this path was
because I couldn't trigger -EBUSY with concurrent updates.

P.s: I checked and Quagga handles -EAGAIN, so if you need an error code that
would be the one to use.

