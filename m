From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 3/3] netfilter: ipv6: add getsockopt to retrieve origdst
Date: Tue, 13 Nov 2012 12:29:36 +0900
Message-ID: <50A1BEA0.8070504@linux-ipv6.org>
References: <1352765203-4160-1-git-send-email-pablo@netfilter.org> <1352765203-4160-4-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:33750 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752727Ab2KMD3j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Nov 2012 22:29:39 -0500
In-Reply-To: <1352765203-4160-4-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

pablo@netfilter.org wrote:
> From: Florian Westphal <fw@strlen.de>
> +static int
> +ipv6_getorigdst(struct sock *sk, int optval, void __user *user, int *len)
> +{
> +	const struct inet_sock *inet = inet_sk(sk);
> +	const struct ipv6_pinfo *inet6 = inet6_sk(sk);
> +	const struct nf_conntrack_tuple_hash *h;
> +	struct sockaddr_in6 sin6;
> +	struct nf_conntrack_tuple tuple = { .src.l3num = NFPROTO_IPV6 };
> +	struct nf_conn *ct;
> +
> +	tuple.src.u3.in6 = inet6->rcv_saddr;
> +	tuple.src.u.tcp.port = inet->inet_sport;
> +	tuple.dst.u3.in6 = inet6->daddr;
> +	tuple.dst.u.tcp.port = inet->inet_dport;
> +	tuple.dst.protonum = sk->sk_protocol;
> +
> +	if (sk->sk_protocol != IPPROTO_TCP && sk->sk_protocol != IPPROTO_SCTP)
> +		return -ENOPROTOOPT;
> +
> +	if (*len < 0 || (unsigned int) *len < sizeof(sin6))
> +		return -EINVAL;
> +
> +	h = nf_conntrack_find_get(sock_net(sk), NF_CT_DEFAULT_ZONE, &tuple);
> +	if (!h) {
> +		pr_debug("IP6T_SO_ORIGINAL_DST: Can't find %pI6c/%u-%pI6c/%u.\n",
> +			 &tuple.src.u3.ip6, ntohs(tuple.src.u.tcp.port),
> +			 &tuple.dst.u3.ip6, ntohs(tuple.dst.u.tcp.port));
> +		return -ENOENT;
> +	}
> +
> +	ct = nf_ct_tuplehash_to_ctrack(h);
> +
> +	sin6.sin6_family = AF_INET6;
> +	sin6.sin6_port = ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.dst.u.tcp.port;
> +	sin6.sin6_flowinfo = inet6->flow_label & IPV6_FLOWINFO_MASK;
> +	memcpy(&sin6.sin6_addr,
> +		&ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.dst.u3.in6,
> +					sizeof(sin6.sin6_addr));
> +	sin6.sin6_scope_id = sk->sk_bound_dev_if;
> +
> +	nf_ct_put(ct);
> +	return copy_to_user(user, &sin6, sizeof(sin6)) ? -EFAULT : 0;
> +}
> +

I think we should set sin6_scope_id to sk->sk_bound_dev_if only if the
destination is link-local address.

--yoshfuji
