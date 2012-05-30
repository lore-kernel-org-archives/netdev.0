From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH 4/4] inet: use second hash in inet_csk_get_port
Date: Wed, 30 May 2012 19:20:56 +0200
Message-ID: <1338398456.2760.338.camel@edumazet-glaptop>
References: <1338363410-6562-1-git-send-email-alex.mihai.c@gmail.com>
	 <1338363410-6562-5-git-send-email-alex.mihai.c@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, gerrit@erg.abdn.ac.uk, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev@vger.kernel.org, Daniel Baluta <dbaluta@ixiacom.com>,
	Lucian Grijincu <lucian.grijincu@gmail.com>
To: Alexandru Copot <alex.mihai.c@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:55522 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754170Ab2E3RVD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2012 13:21:03 -0400
Received: by bkcji2 with SMTP id ji2so49767bkc.19
        for <netdev@vger.kernel.org>; Wed, 30 May 2012 10:21:01 -0700 (PDT)
In-Reply-To: <1338363410-6562-5-git-send-email-alex.mihai.c@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-05-30 at 10:36 +0300, Alexandru Copot wrote:

> +struct inet_bind_bucket *
> +inet4_find_bind_buckets(struct sock *sk,
> +			unsigned short port,
> +			struct inet_bind_hashbucket **p_bhead,
> +			struct inet_bind_hashbucket **p_portaddr_bhead)
> +{
> +	struct net *net = sock_net(sk);
> +	struct inet_hashinfo *hinfo = sk->sk_prot->h.hashinfo;
> +	struct inet_bind_bucket *tb = NULL;
> +	struct hlist_node *node;
> +
> +	struct inet_bind_hashbucket *bhead, *portaddr_bhead, *portaddrany_bhead;
> +	bhead = &hinfo->bhash[inet_bhashfn(net, port, hinfo->bhash_size)];
> +	portaddr_bhead = inet4_portaddr_hashbucket(hinfo, net,
> +				sk_rcv_saddr(sk), port);
> +	portaddrany_bhead = inet4_portaddr_hashbucket(hinfo, net,
> +						INADDR_ANY, port);
> +
> +	*p_portaddr_bhead = portaddr_bhead;
> +	*p_bhead = bhead;
> +
> +	/*
> +	 * prevent dead locks by always taking locks in a fixed order:
> +	 * - always take the port-only lock first. This is done because in some
> +	 *   other places this is the lock taken, being folllowed in only some
> +	 *   cases by the portaddr lock.
> +	 * - between portaddr and portaddrany always choose the one with the
> +	 *   lower address. Unlock ordering is not important, as long as the
> +	 *   locking order is consistent.
> +	 * - make sure to not take the same lock twice
> +	 */
> +	spin_lock(&bhead->lock);
> +	if (portaddr_bhead > portaddrany_bhead) {
> +		spin_lock(&portaddrany_bhead->lock);
> +		spin_lock(&portaddr_bhead->lock);
> +	} else if (portaddr_bhead < portaddrany_bhead) {
> +		spin_lock(&portaddr_bhead->lock);
> +		spin_lock(&portaddrany_bhead->lock);
> +	} else {
> +		spin_lock(&portaddr_bhead->lock);
> +	}
> +
> +	if (sk_rcv_saddr(sk) != INADDR_ANY) {
> +		struct inet_bind_hashbucket *_head;
> +
> +		_head = portaddr_bhead;
> +		if (bhead->count < portaddr_bhead->count) {
> +			_head = bhead;
> +			inet_bind_bucket_for_each(tb, node, &_head->chain)
> +				if ((net_eq(ib_net(tb), net)) &&
> +				    (tb->port == port) &&
> +				    (tb->ib_addr_ipv4 == sk_rcv_saddr(sk)))
> +					goto found;
> +		} else {
> +			inet_portaddr_bind_bucket_for_each(tb, node, &_head->chain)
> +				if ((net_eq(ib_net(tb), net)) &&
> +				    (tb->port == port) &&
> +				    (tb->ib_addr_ipv4 == sk_rcv_saddr(sk)))
> +					goto found;
> +		}
> +		_head = portaddrany_bhead;
> +		if (bhead->count < portaddrany_bhead->count) {
> +			_head = bhead;
> +			inet_bind_bucket_for_each(tb, node, &_head->chain)
> +				if ((ib_net(tb) == net) &&
> +				    (tb->port == port) &&
> +				    (tb->ib_addr_ipv4 == INADDR_ANY))
> +					goto found;
> +		} else {
> +			inet_portaddr_bind_bucket_for_each(tb, node, &_head->chain)
> +				if ((ib_net(tb) == net) &&
> +				    (tb->port == port) &&
> +				    (tb->ib_addr_ipv4 == INADDR_ANY))
> +					goto found;
> +		}
> +	} else {
> +		inet_bind_bucket_for_each(tb, node, &bhead->chain)
> +			if ((ib_net(tb) == net) && (tb->port == port))
> +				goto found;
> +	}
> +
> +	tb = NULL;
> +found:
> +	if (portaddr_bhead != portaddrany_bhead)
> +		spin_unlock(&portaddrany_bhead->lock);
> +
> +	/* the other locks remain taken, as the caller
> +	 * may want to change the hash tabels */
> +	return tb;
> +}
> +
> +

How this is going to work with IPv6 sockets in the middle of the
chains ?

Also, comments are not properly formatted, they should all look like :

	/* the other locks remain taken, as the caller
	 * may want to change the hash tables
	 */

And finally, make sure LOCKDEP is happy with your locking code.
