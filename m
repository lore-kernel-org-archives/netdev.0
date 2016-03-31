From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] tun, bpf: fix suspicious RCU usage in
 tun_{attach,detach}_filter
Date: Thu, 31 Mar 2016 21:24:12 +0200
Message-ID: <56FD795C.9090903@stressinduktion.org>
References: <56FD0B79.5020007@iogearbox.net>
 <1459425558.6473.229.camel@edumazet-glaptop3.roam.corp.google.com>
 <56FD1512.70409@iogearbox.net>
 <20160331.152149.396188904137423987.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, alexei.starovoitov@gmail.com,
	mkubecek@suse.cz, sasha.levin@oracle.com, jslaby@suse.cz,
	mst@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:35476 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752446AbcCaTYQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2016 15:24:16 -0400
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id 00AF820E2B
	for <netdev@vger.kernel.org>; Thu, 31 Mar 2016 15:24:15 -0400 (EDT)
In-Reply-To: <20160331.152149.396188904137423987.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On 31.03.2016 21:21, David Miller wrote:
> From: Daniel Borkmann <daniel@iogearbox.net>
> Date: Thu, 31 Mar 2016 14:16:18 +0200
>
>> On 03/31/2016 01:59 PM, Eric Dumazet wrote:
>>> On Thu, 2016-03-31 at 13:35 +0200, Daniel Borkmann wrote:
>>>
>>>> +static inline bool sock_owned_externally(const struct sock *sk)
>>>> +{
>>>> +	return sk->sk_flags & (1UL << SOCK_EXTERNAL_OWNER);
>>>> +}
>>>> +
>>>
>>> Have you reinvented sock_flag(sl, SOCK_EXTERNAL_OWNER) ? ;)
>>>
>>> Anyway, using a flag for this purpose sounds overkill to me.
>>
>> Right.
>>
>>> Setting it is a way to 'fool' lockdep anyway...
>>
>> Yep, correct, we'd be fooling the tun case, so this diff doesn't
>> really make it any better there.
>
> I like the currently proposed patch where TUN says that RTNL is what
> the synchronizing element is.
>
> Maybe we could make a helper of some sort but since we only have once
> case like this is just overkill.
>
> Alexei, do you really mind if I apply Danile's patch?

I proposed the following patch to Daniel and he seemed to like it. I
was just waiting for his feedback and tags and wanted to send it out
then.

What do you think?

lockdep_sock_is_held does also have some other applications in other
parts of the source.

Bye,
Hannes

diff --git a/include/net/sock.h b/include/net/sock.h
index 255d3e03727b73..651b84a38cfb9b 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1330,6 +1330,12 @@ static inline void sock_release_ownership(struct 
sock *sk)
  	sk->sk_lock.owned = 0;
  }

+static inline bool lockdep_sock_is_held(struct sock *sk)
+{
+	return lockdep_is_held(&sk->sk_lock) ||
+	       lockdep_is_held(&sk->sk_lock.slock);
+}
+
  /*
   * Macro so as to not evaluate some arguments when
   * lockdep is not enabled.
diff --git a/net/core/filter.c b/net/core/filter.c
index 4b81b71171b4ce..8ab270d5ce5507 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1166,7 +1166,8 @@ static int __sk_attach_prog(struct bpf_prog *prog, 
struct sock *sk)
  	}

  	old_fp = rcu_dereference_protected(sk->sk_filter,
-					   sock_owned_by_user(sk));
+					   lockdep_rtnl_is_held() ||
+					   lockdep_sock_is_held(sk));
  	rcu_assign_pointer(sk->sk_filter, fp);

  	if (old_fp)
@@ -2259,7 +2260,9 @@ int sk_detach_filter(struct sock *sk)
  		return -EPERM;

  	filter = rcu_dereference_protected(sk->sk_filter,
-					   sock_owned_by_user(sk));
+					   lockdep_rtnl_is_held() ||
+					   lockdep_sock_is_held(sk));
+
  	if (filter) {
  		RCU_INIT_POINTER(sk->sk_filter, NULL);
  		sk_filter_uncharge(sk, filter);

c
