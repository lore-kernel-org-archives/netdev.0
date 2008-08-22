From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [PATCH 1/1] icmp: icmp_sk() should not use smp_processor_id()
 in preemptible code
Date: Sat, 23 Aug 2008 01:15:05 +0200
Message-ID: <48AF4879.9070005@fr.ibm.com>
References: <20080821122040.GA2497@x200.localdomain> <1219413273-14281-1-git-send-email-den@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, adobriyan@gmail.com,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: "Denis V. Lunev" <den@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.de.ibm.com ([195.212.29.157]:38844 "EHLO
	mtagate8.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753828AbYHVXPU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2008 19:15:20 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate8.de.ibm.com (8.13.8/8.13.8) with ESMTP id m7MNFFl0709312
	for <netdev@vger.kernel.org>; Fri, 22 Aug 2008 23:15:15 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m7MNFFEF1319118
	for <netdev@vger.kernel.org>; Sat, 23 Aug 2008 01:15:15 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m7MNFBTK007410
	for <netdev@vger.kernel.org>; Sat, 23 Aug 2008 01:15:12 +0200
In-Reply-To: <1219413273-14281-1-git-send-email-den@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denis V. Lunev wrote:
> Pass namespace into icmp_xmit_lock, obtain socket inside and return
> it as a result for caller.
> 
> Thanks Alexey Dobryan for this report:
> 
> Steps to reproduce:
> 
> 	CONFIG_PREEMPT=y
> 	CONFIG_DEBUG_PREEMPT=y
> 	tracepath <something>
> 
> BUG: using smp_processor_id() in preemptible [00000000] code: tracepath/3205
> caller is icmp_sk+0x15/0x30
> Pid: 3205, comm: tracepath Not tainted 2.6.27-rc4 #1
> 
> Call Trace:
>  [<ffffffff8031af14>] debug_smp_processor_id+0xe4/0xf0
>  [<ffffffff80409405>] icmp_sk+0x15/0x30
>  [<ffffffff8040a17b>] icmp_send+0x4b/0x3f0
>  [<ffffffff8025a415>] ? trace_hardirqs_on_caller+0xd5/0x160
>  [<ffffffff8025a4ad>] ? trace_hardirqs_on+0xd/0x10
>  [<ffffffff8023a475>] ? local_bh_enable_ip+0x95/0x110
>  [<ffffffff804285b9>] ? _spin_unlock_bh+0x39/0x40
>  [<ffffffff8025a26c>] ? mark_held_locks+0x4c/0x90
>  [<ffffffff8025a4ad>] ? trace_hardirqs_on+0xd/0x10
>  [<ffffffff8025a415>] ? trace_hardirqs_on_caller+0xd5/0x160
>  [<ffffffff803e91b4>] ip_fragment+0x8d4/0x900
>  [<ffffffff803e7030>] ? ip_finish_output2+0x0/0x290
>  [<ffffffff803e91e0>] ? ip_finish_output+0x0/0x60
>  [<ffffffff803e6650>] ? dst_output+0x0/0x10
>  [<ffffffff803e922c>] ip_finish_output+0x4c/0x60
>  [<ffffffff803e92e3>] ip_output+0xa3/0xf0
>  [<ffffffff803e68d0>] ip_local_out+0x20/0x30
>  [<ffffffff803e753f>] ip_push_pending_frames+0x27f/0x400
>  [<ffffffff80406313>] udp_push_pending_frames+0x233/0x3d0
>  [<ffffffff804067d1>] udp_sendmsg+0x321/0x6f0
>  [<ffffffff8040d155>] inet_sendmsg+0x45/0x80
>  [<ffffffff803b967f>] sock_sendmsg+0xdf/0x110
>  [<ffffffff8024a100>] ? autoremove_wake_function+0x0/0x40
>  [<ffffffff80257ce5>] ? validate_chain+0x415/0x1010
>  [<ffffffff8027dc10>] ? __do_fault+0x140/0x450
>  [<ffffffff802597d0>] ? __lock_acquire+0x260/0x590
>  [<ffffffff803b9e55>] ? sockfd_lookup_light+0x45/0x80
>  [<ffffffff803ba50a>] sys_sendto+0xea/0x120
>  [<ffffffff80428e42>] ? _spin_unlock_irqrestore+0x42/0x80
>  [<ffffffff803134bc>] ? __up_read+0x4c/0xb0
>  [<ffffffff8024e0c6>] ? up_read+0x26/0x30
>  [<ffffffff8020b8bb>] system_call_fastpath+0x16/0x1b
> 
> icmp6_sk() is similar.
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>
> ---
>  net/ipv4/icmp.c |   22 ++++++++++++++--------
>  net/ipv6/icmp.c |   23 ++++++++++++-----------
>  2 files changed, 26 insertions(+), 19 deletions(-)
> 
> diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
> index 8605586..55c355e 100644
> --- a/net/ipv4/icmp.c
> +++ b/net/ipv4/icmp.c
> @@ -204,18 +204,22 @@ static struct sock *icmp_sk(struct net *net)
>  	return net->ipv4.icmp_sk[smp_processor_id()];
>  }

Hi Denis,

thanks for the fix. For my personal knowledge, why can we just use in 
the icmp_sk function:
	{
		struct sock *isk = net->ipv4.icmp_sk[get_cpu()];
		put_cpu();
		return isk;
	}

?

> -static inline int icmp_xmit_lock(struct sock *sk)
> +static inline struct sock *icmp_xmit_lock(struct net *net)
>  {
> +	struct sock *sk;
> +
>  	local_bh_disable();
> 
> +	sk = icmp_sk(net);
> +
>  	if (unlikely(!spin_trylock(&sk->sk_lock.slock))) {
>  		/* This can happen if the output path signals a
>  		 * dst_link_failure() for an outgoing ICMP packet.
>  		 */
>  		local_bh_enable();
> -		return 1;
> +		return NULL;
>  	}
> -	return 0;
> +	return sk;
>  }
> 
>  static inline void icmp_xmit_unlock(struct sock *sk)
> @@ -354,15 +358,17 @@ static void icmp_reply(struct icmp_bxm *icmp_param, struct sk_buff *skb)
>  	struct ipcm_cookie ipc;
>  	struct rtable *rt = skb->rtable;
>  	struct net *net = dev_net(rt->u.dst.dev);
> -	struct sock *sk = icmp_sk(net);
> -	struct inet_sock *inet = inet_sk(sk);
> +	struct sock *sk;
> +	struct inet_sock *inet;
>  	__be32 daddr;
> 
>  	if (ip_options_echo(&icmp_param->replyopts, skb))
>  		return;
> 
> -	if (icmp_xmit_lock(sk))
> +	sk = icmp_xmit_lock(net);
> +	if (sk == NULL)
>  		return;
> +	inet = inet_sk(sk);
> 
>  	icmp_param->data.icmph.checksum = 0;
> 
> @@ -419,7 +425,6 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
>  	if (!rt)
>  		goto out;
>  	net = dev_net(rt->u.dst.dev);
> -	sk = icmp_sk(net);
> 
>  	/*
>  	 *	Find the original header. It is expected to be valid, of course.
> @@ -483,7 +488,8 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
>  		}
>  	}
> 
> -	if (icmp_xmit_lock(sk))
> +	sk = icmp_xmit_lock(net);
> +	if (sk == NULL)
>  		return;
> 
>  	/*
> diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
> index abedf95..b3157a0 100644
> --- a/net/ipv6/icmp.c
> +++ b/net/ipv6/icmp.c
> @@ -91,19 +91,22 @@ static struct inet6_protocol icmpv6_protocol = {
>  	.flags		=	INET6_PROTO_NOPOLICY|INET6_PROTO_FINAL,
>  };
> 
> -static __inline__ int icmpv6_xmit_lock(struct sock *sk)
> +static __inline__ struct sock *icmpv6_xmit_lock(struct net *net)
>  {
> +	struct sock *sk;
> +
>  	local_bh_disable();
> 
> +	sk = icmpv6_sk(net);
>  	if (unlikely(!spin_trylock(&sk->sk_lock.slock))) {
>  		/* This can happen if the output path (f.e. SIT or
>  		 * ip6ip6 tunnel) signals dst_link_failure() for an
>  		 * outgoing ICMP6 packet.
>  		 */
>  		local_bh_enable();
> -		return 1;
> +		return NULL;
>  	}
> -	return 0;
> +	return sk;
>  }
> 
>  static __inline__ void icmpv6_xmit_unlock(struct sock *sk)
> @@ -392,11 +395,10 @@ void icmpv6_send(struct sk_buff *skb, int type, int code, __u32 info,
>  	fl.fl_icmp_code = code;
>  	security_skb_classify_flow(skb, &fl);
> 
> -	sk = icmpv6_sk(net);
> -	np = inet6_sk(sk);
> -
> -	if (icmpv6_xmit_lock(sk))
> +	sk = icmpv6_xmit_lock(net);
> +	if (sk == NULL)
>  		return;
> +	np = inet6_sk(sk);
> 
>  	if (!icmpv6_xrlim_allow(sk, type, &fl))
>  		goto out;
> @@ -539,11 +541,10 @@ static void icmpv6_echo_reply(struct sk_buff *skb)
>  	fl.fl_icmp_type = ICMPV6_ECHO_REPLY;
>  	security_skb_classify_flow(skb, &fl);
> 
> -	sk = icmpv6_sk(net);
> -	np = inet6_sk(sk);
> -
> -	if (icmpv6_xmit_lock(sk))
> +	sk = icmpv6_xmit_lock(net);
> +	if (sk == NULL)
>  		return;
> +	np = inet6_sk(sk);
> 
>  	if (!fl.oif && ipv6_addr_is_multicast(&fl.fl6_dst))
>  		fl.oif = np->mcast_oif;
