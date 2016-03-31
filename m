From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] tun, bpf: fix suspicious RCU usage in
 tun_{attach,detach}_filter
Date: Thu, 31 Mar 2016 21:48:27 +0200
Message-ID: <56FD7F0B.5090602@stressinduktion.org>
References: <56FD1512.70409@iogearbox.net>
 <20160331.152149.396188904137423987.davem@davemloft.net>
 <56FD795C.9090903@stressinduktion.org>
 <20160331.153630.1640223846173244431.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, eric.dumazet@gmail.com,
	alexei.starovoitov@gmail.com, mkubecek@suse.cz,
	sasha.levin@oracle.com, jslaby@suse.cz, mst@redhat.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:44387 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752578AbcCaTsc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2016 15:48:32 -0400
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id 18A1D22E2B
	for <netdev@vger.kernel.org>; Thu, 31 Mar 2016 15:48:32 -0400 (EDT)
In-Reply-To: <20160331.153630.1640223846173244431.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 31.03.2016 21:36, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Thu, 31 Mar 2016 21:24:12 +0200
>
>> diff --git a/net/core/filter.c b/net/core/filter.c
>> index 4b81b71171b4ce..8ab270d5ce5507 100644
>> --- a/net/core/filter.c
>> +++ b/net/core/filter.c
>> @@ -1166,7 +1166,8 @@ static int __sk_attach_prog(struct bpf_prog
>> *prog, struct sock *sk)
>>   	}
>>
>>   	old_fp = rcu_dereference_protected(sk->sk_filter,
>> -					   sock_owned_by_user(sk));
>> +					   lockdep_rtnl_is_held() ||
>> +					   lockdep_sock_is_held(sk));
>>   	rcu_assign_pointer(sk->sk_filter, fp);
>>
>>   	if (old_fp)
>
> I have the same objections Daniel did.
>
> Not all socket filter clients use RTNL as the synchornization
> mechanism.  The caller, or some descriptive element, should tell us
> what that synchronizing element is.
>
> Yes, I understand how these RTNL checks can pass "accidently" but
> the opposite is true too.  A socket locking synchornizing user,
> who didn't lock the socket, might now pass because RTNL happens
> to be held elsewhere.

Actually lockdep_rtnl_is_held checks if this specific code/thread holds 
the lock and no other cpu/thread. So it will not pass here in case 
another cpu has the lock.

lockdep stores the current held locks in current->held_locks, if we 
preempt we switch current pointer, if we take a spin_lock we can't sleep 
thus not preempt. Thus we always know that this specific code has the lock.

Using sock_owned_by_user actually has this problem, and thus I am 
replacing it. We don't know who has the socket locked.

Tightest solution would probably be to combine both patches.

bool called_by_tuntap;

old_fp = rcu_dereference_protected(sk->sk_filter, called_by_tuntap ? 
lockdep_rtnl_is_held() : lockdep_sock_is_held());

Bye,
Hannes
