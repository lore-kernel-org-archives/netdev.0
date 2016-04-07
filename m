From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] sock: make lockdep_sock_is_held static inline
Date: Fri, 8 Apr 2016 00:47:57 +0200
Message-ID: <5706E39D.3060206@stressinduktion.org>
References: <1460066015-22105-1-git-send-email-hannes@stressinduktion.org>
 <1460068227.6473.422.camel@edumazet-glaptop3.roam.corp.google.com>
 <1460068652.6473.423.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:53681 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752898AbcDGWsB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 18:48:01 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 3A1BF20307
	for <netdev@vger.kernel.org>; Thu,  7 Apr 2016 18:48:00 -0400 (EDT)
In-Reply-To: <1460068652.6473.423.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08.04.2016 00:37, Eric Dumazet wrote:
> On Thu, 2016-04-07 at 15:30 -0700, Eric Dumazet wrote:
>
>> But... this wont solve the compiler error ?
>>
>> include/net/sock.h: In function 'lockdep_sock_is_held':
>> include/net/sock.h:1367:2: error: implicit declaration of function
>> 'lockdep_is_held' [-Werror=implicit-function-declaration]
>> In file included from security/lsm_audit.c:20:0:
>> include/net/sock.h: In function 'lockdep_sock_is_held':
>> include/net/sock.h:1367:2: error: implicit declaration of function
>> 'lockdep_is_held' [-Werror=implicit-function-declaration]
>>
>> $ egrep "LOCKDEP|PROVE" .config
>> CONFIG_LOCKDEP_SUPPORT=y
>> # CONFIG_PROVE_LOCKING is not set
>> # CONFIG_PROVE_RCU is not set
>>
>
> Better use something like :
>
> diff --git a/include/net/sock.h b/include/net/sock.h
> index eb2d7c3e120b..ab6b6b9469ad 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -1360,13 +1360,15 @@ do {                                                                    \
>          lockdep_init_map(&(sk)->sk_lock.dep_map, (name), (key), 0);     \
>   } while (0)
>
> -static bool lockdep_sock_is_held(const struct sock *csk)
> +#ifdef CONFIG_PROVE_RCU
> +static inline bool lockdep_sock_is_held(const struct sock *csk)
>   {
>          struct sock *sk = (struct sock *)csk;
>
>          return lockdep_is_held(&sk->sk_lock) ||
>                 lockdep_is_held(&sk->sk_lock.slock);
>   }
> +#endif

I see... hmpf.

Wouldn't it be nicer if I include a helper a la:

#define lockdep_is_held(lock)  1

in lockdep.h in case lockdep is globally not enabled? I do actually have 
already another user for this outside of PROVE_RCU.

Thanks,
Hannes
