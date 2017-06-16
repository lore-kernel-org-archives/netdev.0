From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [RFC PATCH net-next v2 10/15] bpf: Add support for changing congestion
 control
Date: Fri, 16 Jun 2017 15:58:55 +0200
Message-ID: <5943E41F.2050006@iogearbox.net>
References: <20170615200844.2752485-1-brakmo@fb.com> <20170615200844.2752485-11-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Kernel Team <kernel-team@fb.com>, Blake Matheny <bmatheny@fb.com>,
        Alexei Starovoitov <ast@fb.com>,
        David Ahern <dsa@cumulusnetworks.com>
To: Lawrence Brakmo <brakmo@fb.com>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:33100 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752762AbdFPN65 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 09:58:57 -0400
In-Reply-To: <20170615200844.2752485-11-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/15/2017 10:08 PM, Lawrence Brakmo wrote:
> Added support for changing congestion control for SOCKET_OPS bps
> programs through the setsockopt bpf helper function. It also adds
> a new SOCKET_OPS op, BPF_SOCKET_OPS_NEEDS_ECN, that is needed for
> congestion controls, like dctcp, that need to enable ECN in the
> SYN packets.
>
> Signed-off-by: Lawrence Brakmo <brakmo@fb.com>

I like the use-case! ;)

> ---
>   include/net/tcp.h        |  9 ++++++++-
>   include/uapi/linux/bpf.h |  3 +++
>   net/core/filter.c        | 11 +++++++++--
>   net/ipv4/tcp.c           |  2 +-
>   net/ipv4/tcp_cong.c      | 15 ++++++++++-----
>   net/ipv4/tcp_input.c     |  3 ++-
>   net/ipv4/tcp_output.c    |  8 +++++---
>   7 files changed, 38 insertions(+), 13 deletions(-)
>
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index 29c27dc..371b1bd 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -1001,7 +1001,9 @@ void tcp_get_default_congestion_control(char *name);
>   void tcp_get_available_congestion_control(char *buf, size_t len);
>   void tcp_get_allowed_congestion_control(char *buf, size_t len);
>   int tcp_set_allowed_congestion_control(char *allowed);
> -int tcp_set_congestion_control(struct sock *sk, const char *name);
> +int tcp_set_congestion_control(struct sock *sk, const char *name, bool load);
> +void tcp_reinit_congestion_control(struct sock *sk,
> +				   const struct tcp_congestion_ops *ca);
>   u32 tcp_slow_start(struct tcp_sock *tp, u32 acked);
>   void tcp_cong_avoid_ai(struct tcp_sock *tp, u32 w, u32 acked);
>
> @@ -2039,4 +2041,9 @@ static inline u32 tcp_rwnd_init_bpf(struct sock *sk, bool is_req_sock)
>   		rwnd = 0;
>   	return rwnd;
>   }
> +
> +static inline bool tcp_bpf_ca_needs_ecn(struct sock *sk)
> +{
> +	return (tcp_call_bpf(sk, true, BPF_SOCKET_OPS_NEEDS_ECN) == 1);
> +}
>   #endif	/* _TCP_H */
> diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
> index c3490d3..8d1d2b7 100644
> --- a/include/uapi/linux/bpf.h
> +++ b/include/uapi/linux/bpf.h
> @@ -776,6 +776,9 @@ enum {
>   						 * passive connection is
>   						 * established
>   						 */
> +	BPF_SOCKET_OPS_NEEDS_ECN,	/* If connection's congestion control
> +					 * needs ECN
> +					 */
>   };
>
>   #endif /* _UAPI__LINUX_BPF_H__ */
> diff --git a/net/core/filter.c b/net/core/filter.c
> index 9ff567c..4325aba 100644
> --- a/net/core/filter.c
> +++ b/net/core/filter.c
> @@ -2716,8 +2716,15 @@ BPF_CALL_5(bpf_setsockopt, struct bpf_socket_ops_kern *, bpf_socket,
>   		}
>   	} else if (level == SOL_TCP &&
>   		   bpf_socket->sk->sk_prot->setsockopt == tcp_setsockopt) {
> -		/* Place holder */
> -		ret = -EINVAL;
> +		if (optname == TCP_CONGESTION) {
> +			ret = tcp_set_congestion_control(sk, optval, false);
> +			if (!ret && bpf_socket->op > BPF_SOCKET_OPS_NEEDS_ECN)
> +				/* replacing an existing ca */
> +				tcp_reinit_congestion_control(sk,
> +					inet_csk(sk)->icsk_ca_ops);

Can you elaborate on the sematics of BPF_SOCKET_OPS_NEEDS_ECN?

It's called from tcp_bpf_ca_needs_ecn(), so if someone sets a cong ctl
from that callback, or any other bpf_socket->op > BPF_SOCKET_OPS_NEEDS_ECN
then we call tcp_reinit_congestion_control()? Why 'bpf_socket->op > ..'?

Could the needs_ecn implementation detail be hidden altogether from the
BPF prog?

> +		} else {
> +			ret = -EINVAL;
> +		}
>   	} else {
>   		ret = -EINVAL;
>   	}
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index cc8fd8b..07984ea 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -2478,7 +2478,7 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
>   		name[val] = 0;
>
>   		lock_sock(sk);
> -		err = tcp_set_congestion_control(sk, name);
> +		err = tcp_set_congestion_control(sk, name, true);
>   		release_sock(sk);
>   		return err;
>   	}
> diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
> index 324c9bc..e6f3717 100644
> --- a/net/ipv4/tcp_cong.c
> +++ b/net/ipv4/tcp_cong.c
> @@ -189,8 +189,8 @@ void tcp_init_congestion_control(struct sock *sk)
>   		INET_ECN_dontxmit(sk);
>   }
>
> -static void tcp_reinit_congestion_control(struct sock *sk,
> -					  const struct tcp_congestion_ops *ca)
> +void tcp_reinit_congestion_control(struct sock *sk,
> +				   const struct tcp_congestion_ops *ca)
>   {
>   	struct inet_connection_sock *icsk = inet_csk(sk);
>
> @@ -334,7 +334,7 @@ int tcp_set_allowed_congestion_control(char *val)
>   }
>
>   /* Change congestion control for socket */
> -int tcp_set_congestion_control(struct sock *sk, const char *name)
> +int tcp_set_congestion_control(struct sock *sk, const char *name, bool load)
>   {
>   	struct inet_connection_sock *icsk = inet_csk(sk);
>   	const struct tcp_congestion_ops *ca;
> @@ -344,7 +344,10 @@ int tcp_set_congestion_control(struct sock *sk, const char *name)
>   		return -EPERM;
>
>   	rcu_read_lock();
> -	ca = __tcp_ca_find_autoload(name);
> +	if (!load)
> +		ca = tcp_ca_find(name);
> +	else
> +		ca = __tcp_ca_find_autoload(name);

 From BPF program side, we call with !load since we're not allowed
to sleep under RCU, that's correct ...

>   	/* No change asking for existing value */
>   	if (ca == icsk->icsk_ca_ops) {
>   		icsk->icsk_ca_setsockopt = 1;
> @@ -352,8 +355,10 @@ int tcp_set_congestion_control(struct sock *sk, const char *name)
>   	}
>   	if (!ca)
>   		err = -ENOENT;
> +	else if (!load)
> +		icsk->icsk_ca_ops = ca;

... but don't we also need to hold a module ref in this case as done
below?

Meaning, tcp_ca_find() could return a ca that was previously loaded
to the tcp_cong_list as module, then resulting in ref count imbalance
when set from BPF?

>   	else if (!((ca->flags & TCP_CONG_NON_RESTRICTED) ||
> -		   ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN)))
> +			   ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN)))

Nit: slipped in?

>   		err = -EPERM;
>   	else if (!try_module_get(ca->owner))
>   		err = -EBUSY;
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index e0d688a..14c889f 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -6192,7 +6192,8 @@ static void tcp_ecn_create_request(struct request_sock *req,
>   	ecn_ok = net->ipv4.sysctl_tcp_ecn || ecn_ok_dst;
>
>   	if ((!ect && ecn_ok) || tcp_ca_needs_ecn(listen_sk) ||
> -	    (ecn_ok_dst & DST_FEATURE_ECN_CA))
> +	    (ecn_ok_dst & DST_FEATURE_ECN_CA) ||
> +	    tcp_bpf_ca_needs_ecn((struct sock *)req))
>   		inet_rsk(req)->ecn_ok = 1;
>   }
>
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index 9124d3d..30660ee 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -316,7 +316,8 @@ static void tcp_ecn_send_synack(struct sock *sk, struct sk_buff *skb)
>   	TCP_SKB_CB(skb)->tcp_flags &= ~TCPHDR_CWR;
>   	if (!(tp->ecn_flags & TCP_ECN_OK))
>   		TCP_SKB_CB(skb)->tcp_flags &= ~TCPHDR_ECE;
> -	else if (tcp_ca_needs_ecn(sk))
> +	else if (tcp_ca_needs_ecn(sk) ||
> +		 tcp_bpf_ca_needs_ecn(sk))
>   		INET_ECN_xmit(sk);
>   }
>
> @@ -324,8 +325,9 @@ static void tcp_ecn_send_synack(struct sock *sk, struct sk_buff *skb)
>   static void tcp_ecn_send_syn(struct sock *sk, struct sk_buff *skb)
>   {
>   	struct tcp_sock *tp = tcp_sk(sk);
> +	bool bpf_needs_ecn = tcp_bpf_ca_needs_ecn(sk);
>   	bool use_ecn = sock_net(sk)->ipv4.sysctl_tcp_ecn == 1 ||
> -		       tcp_ca_needs_ecn(sk);
> +		tcp_ca_needs_ecn(sk) || bpf_needs_ecn;
>
>   	if (!use_ecn) {
>   		const struct dst_entry *dst = __sk_dst_get(sk);
> @@ -339,7 +341,7 @@ static void tcp_ecn_send_syn(struct sock *sk, struct sk_buff *skb)
>   	if (use_ecn) {
>   		TCP_SKB_CB(skb)->tcp_flags |= TCPHDR_ECE | TCPHDR_CWR;
>   		tp->ecn_flags = TCP_ECN_OK;
> -		if (tcp_ca_needs_ecn(sk))
> +		if (tcp_ca_needs_ecn(sk) || bpf_needs_ecn)
>   			INET_ECN_xmit(sk);
>   	}
>   }
>
