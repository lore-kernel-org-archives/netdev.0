From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH net-next v5 2/2] tcp_diag: report TCP MD5 signing keys
 and addresses
Date: Fri, 1 Sep 2017 01:26:33 +0200
Message-ID: <20170831232633.GA678@bistromath.localdomain>
References: <20170831165939.5121-1-colona@arista.com>
 <20170831165939.5121-3-colona@arista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>,
        Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Ivan Delalande <colona@arista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41648 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751307AbdHaX0h (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 31 Aug 2017 19:26:37 -0400
Content-Disposition: inline
In-Reply-To: <20170831165939.5121-3-colona@arista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2017-08-31, 09:59:39 -0700, Ivan Delalande wrote:
> diff --git a/net/ipv4/tcp_diag.c b/net/ipv4/tcp_diag.c
> index a748c74aa8b7..abbf0edcf6c2 100644
> --- a/net/ipv4/tcp_diag.c
> +++ b/net/ipv4/tcp_diag.c
[...]
> +static int tcp_diag_get_aux(struct sock *sk, bool net_admin,
> +			    struct sk_buff *skb)
> +{
> +#ifdef CONFIG_TCP_MD5SIG
> +	if (net_admin) {

In tcp_diag_get_aux_size() you put a check for sk_fullsock. I don't
see anything preventing you from reaching this with a !fullsock?


> +		struct tcp_md5sig_info *md5sig;
> +		int err = 0;
> +
> +		rcu_read_lock();
> +		md5sig = rcu_dereference(tcp_sk(sk)->md5sig_info);
> +		if (md5sig)
> +			err = tcp_diag_put_md5sig(skb, md5sig);
> +		rcu_read_unlock();
> +		if (err < 0)
> +			return err;
> +	}
> +#endif
> +
> +	return 0;
> +}
> +
> +static size_t tcp_diag_get_aux_size(struct sock *sk, bool net_admin)
> +{
> +	size_t size = 0;
> +
> +#ifdef CONFIG_TCP_MD5SIG
> +	if (net_admin && sk_fullsock(sk)) {
> +		const struct tcp_md5sig_info *md5sig;
> +		const struct tcp_md5sig_key *key;
> +		size_t md5sig_count = 0;
> +
> +		rcu_read_lock();
> +		md5sig = rcu_dereference(tcp_sk(sk)->md5sig_info);
> +		if (md5sig) {
> +			hlist_for_each_entry_rcu(key, &md5sig->head, node)
> +				md5sig_count++;
> +		}
> +		rcu_read_unlock();
> +		size += nla_total_size(md5sig_count *
> +				       sizeof(struct tcp_diag_md5sig));
> +	}
> +#endif
> +
> +	return size;
> +}
> +
>  static void tcp_diag_dump(struct sk_buff *skb, struct netlink_callback *cb,
>  			  const struct inet_diag_req_v2 *r, struct nlattr *bc)
>  {

-- 
Sabrina
