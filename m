From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net 4/4] tcp: various missing rcu_read_lock around
 __sk_dst_get
Date: Fri, 1 Apr 2016 03:58:48 +0200
Message-ID: <56FDD5D8.2040300@stressinduktion.org>
References: <1459466982-20432-1-git-send-email-hannes@stressinduktion.org>
 <1459466982-20432-5-git-send-email-hannes@stressinduktion.org>
 <1459467595.6473.233.camel@edumazet-glaptop3.roam.corp.google.com>
 <56FDBA6E.5030508@stressinduktion.org>
 <1459469572.6473.239.camel@edumazet-glaptop3.roam.corp.google.com>
 <56FDBF0E.8020309@stressinduktion.org>
 <1459473592.6473.243.camel@edumazet-glaptop3.roam.corp.google.com>
 <1459474618.3751123.565321858.30DF1858@webmail.messagingengine.com>
 <1459474756.6473.248.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	sasha.levin@oracle.com, daniel@iogearbox.net,
	alexei.starovoitov@gmail.com, mkubecek@suse.cz
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:41485 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752210AbcDAB6x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2016 21:58:53 -0400
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id 948472038A
	for <netdev@vger.kernel.org>; Thu, 31 Mar 2016 21:58:52 -0400 (EDT)
In-Reply-To: <1459474756.6473.248.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01.04.2016 03:39, Eric Dumazet wrote:
> On Fri, 2016-04-01 at 03:36 +0200, Hannes Frederic Sowa wrote:
>> On Fri, Apr 1, 2016, at 03:19, Eric Dumazet wrote:
>>> Thanks.
>>>
>>> As you can see, release_sock() messes badly lockdep (once your other
>>> patches are in )
>>>
>>> Once we properly fix release_sock() and/or __release_sock(), all these
>>> false positives disappear.
>>
>> This was a loopback connection. I need to study release_sock and
>> __release_sock more as I cannot currently see an issue with the lockdep
>> handling.
>
> Okay, please try :
>
> diff --git a/net/core/sock.c b/net/core/sock.c
> index b67b9aedb230..570dcd91d64e 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -2429,10 +2429,6 @@ EXPORT_SYMBOL(lock_sock_nested);
>
>   void release_sock(struct sock *sk)
>   {
> -	/*
> -	 * The sk_lock has mutex_unlock() semantics:
> -	 */
> -	mutex_release(&sk->sk_lock.dep_map, 1, _RET_IP_);
>
>   	spin_lock_bh(&sk->sk_lock.slock);
>   	if (sk->sk_backlog.tail)
> @@ -2445,6 +2441,10 @@ void release_sock(struct sock *sk)
>   		sk->sk_prot->release_cb(sk);
>
>   	sock_release_ownership(sk);
> +	/*
> +	 * The sk_lock has mutex_unlock() semantics:
> +	 */
> +	mutex_release(&sk->sk_lock.dep_map, 1, _RET_IP_);
>   	if (waitqueue_active(&sk->sk_lock.wq))
>   		wake_up(&sk->sk_lock.wq);
>   	spin_unlock_bh(&sk->sk_lock.slock);


Looks much better with your patch already. I slowly begin to understand, 
this is really tricky... :)

Bye,
Hannes
