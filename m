From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCHv2 net-next 4/6] sctp: add the sctp_diag.c file
Date: Fri, 08 Apr 2016 22:51:56 -0700
Message-ID: <1460181116.6473.483.camel@edumazet-glaptop3.roam.corp.google.com>
References: <cover.1460177331.git.lucien.xin@gmail.com>
	 <c507274a984bd1b0a7e7a59d1e825352536efd25.1460177331.git.lucien.xin@gmail.com>
	 <a3703f4379eeb3a385d3cc000dd621f77540608e.1460177331.git.lucien.xin@gmail.com>
	 <5408d667c2a83b8917a501b92810c82f9a66f584.1460177331.git.lucien.xin@gmail.com>
	 <ac19f4966c7df6399c2a3bfa0f7f9589b9ff536f.1460177331.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net,
	davem@davemloft.net
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f45.google.com ([209.85.192.45]:34219 "EHLO
	mail-qg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750897AbcDIFwB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Apr 2016 01:52:01 -0400
In-Reply-To: <ac19f4966c7df6399c2a3bfa0f7f9589b9ff536f.1460177331.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2016-04-09 at 12:53 +0800, Xin Long wrote:
> This one will implement all the interface of inet_diag, inet_diag_handler.
> which includes sctp_diag_dump, sctp_diag_dump_one and sctp_diag_get_info.


> +static int inet_assoc_diag_fill(struct sock *sk,
> +				struct sctp_association *asoc,
> +				struct sk_buff *skb,
> +				const struct inet_diag_req_v2 *req,
> +				struct user_namespace *user_ns,
> +				int portid, u32 seq, u16 nlmsg_flags,
> +				const struct nlmsghdr *unlh)
> +{
> +	const struct inet_sock *inet = inet_sk(sk);
> +	const struct inet_diag_handler *handler;
> +	int ext = req->idiag_ext;
> +	struct inet_diag_msg *r;
> +	struct nlmsghdr  *nlh;
> +	struct nlattr *attr;
> +	void *info = NULL;
> +	union sctp_addr laddr, paddr;
> +	struct dst_entry *dst;
> +	struct sctp_infox infox;
> +
> +	handler = inet_diag_get_handler(req->sdiag_protocol);
> +	BUG_ON(!handler);
> +
> +	nlh = nlmsg_put(skb, portid, seq, unlh->nlmsg_type, sizeof(*r),
> +			nlmsg_flags);
> +	if (!nlh)
> +		return -EMSGSIZE;
> +
> +	r = nlmsg_data(nlh);
> +	BUG_ON(!sk_fullsock(sk));
> +
> +	laddr = list_entry(asoc->base.bind_addr.address_list.next,
> +			   struct sctp_sockaddr_entry, list)->a;
> +	paddr = asoc->peer.primary_path->ipaddr;
> +	dst = asoc->peer.primary_path->dst;
> +
> +	r->idiag_family = sk->sk_family;
> +	r->id.idiag_sport = htons(asoc->base.bind_addr.port);
> +	r->id.idiag_dport = htons(asoc->peer.port);
> +	r->id.idiag_if = dst ? dst->dev->ifindex : 0;
> +	sock_diag_save_cookie(sk, r->id.idiag_cookie);
> +
> +#if IS_ENABLED(CONFIG_IPV6)
> +	if (sk->sk_family == AF_INET6) {
> +		*(struct in6_addr *)r->id.idiag_src = laddr.v6.sin6_addr;
> +		*(struct in6_addr *)r->id.idiag_dst = paddr.v6.sin6_addr;
> +	} else
> +#endif
> +	{
> +		memset(&r->id.idiag_src, 0, sizeof(r->id.idiag_src));
> +		memset(&r->id.idiag_dst, 0, sizeof(r->id.idiag_dst));
> +
> +		r->id.idiag_src[0] = laddr.v4.sin_addr.s_addr;
> +		r->id.idiag_dst[0] = paddr.v4.sin_addr.s_addr;
> +	}
> +
> +	r->idiag_state = asoc->state;
> +	r->idiag_timer = SCTP_EVENT_TIMEOUT_T3_RTX;
> +	r->idiag_retrans = asoc->rtx_data_chunks;
> +#define EXPIRES_IN_MS(tmo)  DIV_ROUND_UP((tmo - jiffies) * 1000, HZ)
> +	r->idiag_expires =
> +		EXPIRES_IN_MS(asoc->timeouts[SCTP_EVENT_TIMEOUT_T3_RTX]);
> +#undef EXPIRES_IN_MS
> +
> +	if (nla_put_u8(skb, INET_DIAG_SHUTDOWN, sk->sk_shutdown))
> +		goto errout;
> +
> +	/* IPv6 dual-stack sockets use inet->tos for IPv4 connections,
> +	 * hence this needs to be included regardless of socket family.
> +	 */
> +	if (ext & (1 << (INET_DIAG_TOS - 1)))
> +		if (nla_put_u8(skb, INET_DIAG_TOS, inet->tos) < 0)
> +			goto errout;
> +
> +#if IS_ENABLED(CONFIG_IPV6)
> +	if (r->idiag_family == AF_INET6) {
> +		if (ext & (1 << (INET_DIAG_TCLASS - 1)))
> +			if (nla_put_u8(skb, INET_DIAG_TCLASS,
> +				       inet6_sk(sk)->tclass) < 0)
> +				goto errout;
> +
> +		if (((1 << sk->sk_state) & (TCPF_LISTEN | TCPF_CLOSE)) &&
> +		    nla_put_u8(skb, INET_DIAG_SKV6ONLY, ipv6_only_sock(sk)))
> +			goto errout;
> +	}
> +#endif
> +
> +	r->idiag_uid = from_kuid_munged(user_ns, sock_i_uid(sk));
> +	r->idiag_inode = sock_i_ino(sk);
> +
> +	if (ext & (1 << (INET_DIAG_MEMINFO - 1))) {
> +		struct inet_diag_meminfo minfo = {
> +			.idiag_rmem = sk_rmem_alloc_get(sk),
> +			.idiag_wmem = sk->sk_wmem_queued,
> +			.idiag_fmem = sk->sk_forward_alloc,
> +			.idiag_tmem = sk_wmem_alloc_get(sk),
> +		};
> +

All this code looks familiar.

Why inet_sk_diag_fill() is not used instead ?

> +		if (nla_put(skb, INET_DIAG_MEMINFO, sizeof(minfo), &minfo) < 0)
> +			goto errout;
> +	}
> +
> +	if (ext & (1 << (INET_DIAG_SKMEMINFO - 1)))
> +		if (sock_diag_put_meminfo(sk, skb, INET_DIAG_SKMEMINFO))
> +			goto errout;
> +
> +	if ((ext & (1 << (INET_DIAG_INFO - 1))) && handler->idiag_info_size) {
> +		attr = nla_reserve(skb, INET_DIAG_INFO,
> +				   handler->idiag_info_size);
> +		if (!attr)
> +			goto errout;
> +
> +		info = nla_data(attr);
> +	}
> +	infox.sctpinfo = (struct sctp_info *)info;
> +	infox.asoc = asoc;
> +	handler->idiag_get_info(sk, r, &infox);
> +
> +	if (ext & (1 << (INET_DIAG_CONG - 1)))
> +		if (nla_put_string(skb, INET_DIAG_CONG, "reno") < 0)
> +			goto errout;
> +
> +	if (inet_sctp_fill_laddrs(skb, &asoc->base.bind_addr.address_list))
> +		goto errout;
> +
> +	if (inet_sctp_fill_paddrs(skb, asoc))
> +		goto errout;
> +
> +	nlmsg_end(skb, nlh);
> +	return 0;
> +
> +errout:
> +	nlmsg_cancel(skb, nlh);
> +	return -EMSGSIZE;
> +}
> +
> +static int inet_ep_diag_fill(struct sock *sk, struct sctp_endpoint *ep,
> +			     struct sk_buff *skb,
> +			     const struct inet_diag_req_v2 *req,
> +			     struct user_namespace *user_ns,
> +			     u32 portid, u32 seq, u16 nlmsg_flags,
> +			     const struct nlmsghdr *unlh)
> +{
> +	const struct inet_sock *inet = inet_sk(sk);
> +	const struct inet_diag_handler *handler;
> +	int ext = req->idiag_ext;
> +	struct inet_diag_msg *r;
> +	struct nlmsghdr  *nlh;
> +	struct nlattr *attr;
> +	void *info = NULL;
> +	struct sctp_infox infox;
> +
> +	handler = inet_diag_get_handler(req->sdiag_protocol);
> +	BUG_ON(!handler);
> +
> +	nlh = nlmsg_put(skb, portid, seq, unlh->nlmsg_type, sizeof(*r),
> +			nlmsg_flags);
> +	if (!nlh)
> +		return -EMSGSIZE;
> +
> +	r = nlmsg_data(nlh);
> +	BUG_ON(!sk_fullsock(sk));
> +
> +	inet_diag_msg_common_fill(r, sk);
> +	r->idiag_state = sk->sk_state;
> +	r->idiag_timer = 0;
> +	r->idiag_retrans = 0;
> +
> +	if (nla_put_u8(skb, INET_DIAG_SHUTDOWN, sk->sk_shutdown))
> +		goto errout;
> +
> +	/* IPv6 dual-stack sockets use inet->tos for IPv4 connections,
> +	 * hence this needs to be included regardless of socket family.
> +	 */
> +	if (ext & (1 << (INET_DIAG_TOS - 1)))
> +		if (nla_put_u8(skb, INET_DIAG_TOS, inet->tos) < 0)
> +			goto errout;
> +
> +#if IS_ENABLED(CONFIG_IPV6)
> +	if (r->idiag_family == AF_INET6) {
> +		if (ext & (1 << (INET_DIAG_TCLASS - 1)))
> +			if (nla_put_u8(skb, INET_DIAG_TCLASS,
> +				       inet6_sk(sk)->tclass) < 0)
> +				goto errout;
> +
> +		if (((1 << sk->sk_state) & (TCPF_LISTEN | TCPF_CLOSE)) &&
> +		    nla_put_u8(skb, INET_DIAG_SKV6ONLY, ipv6_only_sock(sk)))
> +			goto errout;
> +	}
> +#endif
> +
> +	r->idiag_uid = from_kuid_munged(user_ns, sock_i_uid(sk));
> +	r->idiag_inode = sock_i_ino(sk);
> +
> +	if (ext & (1 << (INET_DIAG_MEMINFO - 1))) {
> +		struct inet_diag_meminfo minfo = {
> +			.idiag_rmem = sk_rmem_alloc_get(sk),
> +			.idiag_wmem = sk->sk_wmem_queued,
> +			.idiag_fmem = sk->sk_forward_alloc,
> +			.idiag_tmem = sk_wmem_alloc_get(sk),
> +		};
> +

Again, looks a lot of duplication.

Also you missed that INET_DIAG_MEMINFO is kind of obsolete,
now we have sock_diag_put_meminfo()


> +		if (nla_put(skb, INET_DIAG_MEMINFO, sizeof(minfo), &minfo) < 0)
> +			goto errout;
> +	}
> +
> +	if (ext & (1 << (INET_DIAG_SKMEMINFO - 1)))
> +		if (sock_diag_put_meminfo(sk, skb, INET_DIAG_SKMEMINFO))
> +			goto errout;
> +
> +	if ((ext & (1 << (INET_DIAG_INFO - 1))) && handler->idiag_info_size) {
> +		attr = nla_reserve(skb, INET_DIAG_INFO,
> +				   handler->idiag_info_size);
> +		if (!attr)
> +			goto errout;
> +
> +		info = nla_data(attr);
> +	}
> +	infox.sctpinfo = (struct sctp_info *)info;
> +	infox.asoc = NULL;
> +	handler->idiag_get_info(sk, r, &infox);
> +
> +	if (inet_sctp_fill_laddrs(skb, &ep->base.bind_addr.address_list))
> +		goto errout;
> +
> +	nlmsg_end(skb, nlh);
> +	return 0;
> +
> +errout:
> +	nlmsg_cancel(skb, nlh);
> +	return -EMSGSIZE;
> +}
> +
> +static size_t inet_assoc_attr_size(struct sctp_association *asoc)
> +{
> +	int addrlen = sizeof(struct sockaddr_storage);
> +	int addrcnt = 0;
> +	struct sctp_sockaddr_entry *laddr;
> +
> +	list_for_each_entry_rcu(laddr, &asoc->base.bind_addr.address_list,
> +				list)
> +		addrcnt++;
> +
> +	return	  nla_total_size(sizeof(struct tcp_info))

Are you sure you want to use tcp_info ???

> +		+ nla_total_size(1) /* INET_DIAG_SHUTDOWN */
> +		+ nla_total_size(1) /* INET_DIAG_TOS */
> +		+ nla_total_size(1) /* INET_DIAG_TCLASS */
> +		+ nla_total_size(addrlen * asoc->peer.transport_count)
> +		+ nla_total_size(addrlen * addrcnt)
> +		+ nla_total_size(sizeof(struct inet_diag_meminfo))
> +		+ nla_total_size(sizeof(struct inet_diag_msg))
> +		+ nla_total_size(sizeof(struct sctp_info))
> +		+ 64;
> +}
