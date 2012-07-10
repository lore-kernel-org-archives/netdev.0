From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 03/16] tcp: Maintain dynamic metrics in local cache.
Date: Tue, 10 Jul 2012 10:02:04 -0700
Message-ID: <1341939724.6118.145.camel@joe2Laptop>
References: <20120710.080714.2272376193166978850.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:45172 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753203Ab2GJRCF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jul 2012 13:02:05 -0400
In-Reply-To: <20120710.080714.2272376193166978850.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-07-10 at 08:07 -0700, David Miller wrote:
> Maintain a local hash table of TCP dynamic metrics blobs.

Just trivia.

> diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
[]
> +static bool addr_same(const struct inetpeer_addr *a,
> +		      const struct inetpeer_addr *b)
> +{
> +	int i, n;
> +
> +	if (a->family != b->family)
> +		return false;
> +	n = (a->family == AF_INET ? 1 : 4);
> +	for (i = 0; i < n; i++) {
> +		if (a->addr.a6[i] != b->addr.a6[i])
> +			return false;
> +	}
> +	return true;

Maybe something like this is a bit more legible?
{
	if (a->family != b->family)
		return false;

	if (a->family == AF_INET)
		return a->addr.a4 == b->addr.a4;

	return ipv6_addr_equal((const struct in6_addr *)&a->addr.a6,
			       (const struct in6_addr *)&b->addr.a6);
}

> +static struct tcp_metrics_block *__tcp_get_metrics(const struct inetpeer_addr *addr,
> +						   unsigned int hash)
> +{
> +	struct tcp_metrics_block *tm;
> +	int depth = 0;
> +
> +	for (tm = rcu_dereference(tcp_metrics_hash[hash].chain); tm;
> +	     tm = rcu_dereference(tm->tcpm_next)) {
> +		if (addr_same(&tm->tcpm_addr, addr))
> +			break;
> +		depth++;
> +	}
> +	return (tm ? tm : (depth > TCP_METRICS_RECLAIM_DEPTH ?
> +			   TCP_METRICS_RECLAIM_PTR :
> +			   NULL));

Using multiple ?: in a single return can be a bit hard to read.

Maybe:

	if (tm)
		return tm;
	if (depth > TCP_METRICS_RECLAIM_DEPTH)
		return TCP_METRICS_RECLAIM_PTR;

	return NULL;

or move the "return tm" into the for loop and avoid
the break and test.

> +static struct tcp_metrics_block *__tcp_get_metrics_req(struct request_sock *req,
> +						       struct dst_entry *dst)
> +{
> +	struct tcp_metrics_block *tm;
> +	struct inetpeer_addr addr;
> +	unsigned int hash;
> +
> +	addr.family = req->rsk_ops->family;
> +	switch (addr.family) {
> +	case AF_INET:
> +		hash = addr.addr.a4 = inet_rsk(req)->rmt_addr;

Is this a sparse error?  __be32 to unsigned int?
Maybe it needs a __force?

> +		break;
> +	case AF_INET6:
> +		*(struct in6_addr *)addr.addr.a6 = inet6_rsk(req)->rmt_addr;
> +		hash = (addr.addr.a6[0] ^
> +			addr.addr.a6[1] ^
> +			addr.addr.a6[2] ^
> +			addr.addr.a6[3]);
> +		break;
> +	default:
> +		return NULL;
> +	}
> +
> +	hash ^= (hash >> 24) ^ (hash >> 16) ^ (hash >> 8);
> +	hash &= tcp_metrics_hash_mask;

[]

> +static struct tcp_metrics_block *tcp_get_metrics(struct sock *sk,
> +						 struct dst_entry *dst,
> +						 bool create)
> +{
> +	struct tcp_metrics_block *tm;
> +	struct inetpeer_addr addr;
> +	unsigned int hash;
> +	bool reclaim;
> +
> +	addr.family = sk->sk_family;
> +	switch (addr.family) {
> +	case AF_INET:
> +		hash = addr.addr.a4 = inet_sk(sk)->inet_daddr;
> +		break;
> +	case AF_INET6:
> +		*(struct in6_addr *)addr.addr.a6 = inet6_sk(sk)->daddr;
> +		hash = (addr.addr.a6[0] ^
> +			addr.addr.a6[1] ^
> +			addr.addr.a6[2] ^
> +			addr.addr.a6[3]);
> +		break;
> +	default:
> +		return NULL;
> +	}
> +
> +	hash ^= (hash >> 24) ^ (hash >> 16) ^ (hash >> 8);
> +	hash &= tcp_metrics_hash_mask;

Same sparse error?

Maybe this mostly duplicated bit could be consolidated
into some hash = calc_tcp_hash(&addr) function?
