From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH 03/14 v2] ipv4, ipv6: use list_for_each_entry*
Date: Sat, 19 Dec 2015 15:58:29 +0100 (CET)
Message-ID: <alpine.DEB.2.10.1512191555420.2530@hadrien>
References: <08ea3b12ed228d7252ca6b14e2033c2bee20f78e.1450535467.git.geliangtang@163.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Geliang Tang <geliangtang@163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2-relais-roc.national.inria.fr ([192.134.164.83]:37218 "EHLO
	mail2-relais-roc.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753880AbbLSO6e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Dec 2015 09:58:34 -0500
In-Reply-To: <08ea3b12ed228d7252ca6b14e2033c2bee20f78e.1450535467.git.geliangtang@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Sat, 19 Dec 2015, Geliang Tang wrote:

> Use list_for_each_entry*() instead of list_for_each*() to simplify
> the code.

Is the code really simpler?  At least in the case of net/ipv6/addrconf.c,
I have the impression that there can be an access from a pointer that is
not really pointing to the thing indicated by its type.  The code seems to
work, but this doesn't seem like a good property for it to have.  In these
cases, you need access to both the list and to the entry.  The original
code seemed like a reasonable way to express that.

julia

> Signed-off-by: Geliang Tang <geliangtang@163.com>
> ---
> Changes in v2:
>  - bugfix for inet6_register_protosw in v1.
> ---
>  net/ipv4/af_inet.c    | 11 ++++-------
>  net/ipv4/tcp_output.c |  6 ++----
>  net/ipv6/addrconf.c   |  8 +++-----
>  net/ipv6/af_inet6.c   | 19 +++++--------------
>  4 files changed, 14 insertions(+), 30 deletions(-)
>
> diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
> index 11c4ca1..eedf814 100644
> --- a/net/ipv4/af_inet.c
> +++ b/net/ipv4/af_inet.c
> @@ -1028,10 +1028,8 @@ static struct inet_protosw inetsw_array[] =
>
>  void inet_register_protosw(struct inet_protosw *p)
>  {
> -	struct list_head *lh;
> -	struct inet_protosw *answer;
> +	struct inet_protosw *answer, *last_perm;
>  	int protocol = p->protocol;
> -	struct list_head *last_perm;
>
>  	spin_lock_bh(&inetsw_lock);
>
> @@ -1040,14 +1038,13 @@ void inet_register_protosw(struct inet_protosw *p)
>
>  	/* If we are trying to override a permanent protocol, bail. */
>  	last_perm = &inetsw[p->type];
> -	list_for_each(lh, &inetsw[p->type]) {
> -		answer = list_entry(lh, struct inet_protosw, list);
> +	list_for_each_entry(answer, &inetsw[p->type], list) {
>  		/* Check only the non-wild match. */
>  		if ((INET_PROTOSW_PERMANENT & answer->flags) == 0)
>  			break;
>  		if (protocol == answer->protocol)
>  			goto out_permanent;
> -		last_perm = lh;
> +		last_perm = answer;
>  	}
>
>  	/* Add the new entry after the last permanent entry if any, so that
> @@ -1056,7 +1053,7 @@ void inet_register_protosw(struct inet_protosw *p)
>  	 * non-permanent entry.  This means that when we remove this entry, the
>  	 * system automatically returns to the old behavior.
>  	 */
> -	list_add_rcu(&p->list, last_perm);
> +	list_add_rcu(&p->list, &last_perm->list);
>  out:
>  	spin_unlock_bh(&inetsw_lock);
>
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index a800cee..8810694 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -751,16 +751,14 @@ static void tcp_tasklet_func(unsigned long data)
>  	struct tsq_tasklet *tsq = (struct tsq_tasklet *)data;
>  	LIST_HEAD(list);
>  	unsigned long flags;
> -	struct list_head *q, *n;
> -	struct tcp_sock *tp;
> +	struct tcp_sock *tp, *n;
>  	struct sock *sk;
>
>  	local_irq_save(flags);
>  	list_splice_init(&tsq->head, &list);
>  	local_irq_restore(flags);
>
> -	list_for_each_safe(q, n, &list) {
> -		tp = list_entry(q, struct tcp_sock, tsq_node);
> +	list_for_each_entry_safe(tp, n, &list, tsq_node) {
>  		list_del(&tp->tsq_node);
>
>  		sk = (struct sock *)tp;
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 7082fb7..e293647 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -865,21 +865,19 @@ void inet6_ifa_finish_destroy(struct inet6_ifaddr *ifp)
>  static void
>  ipv6_link_dev_addr(struct inet6_dev *idev, struct inet6_ifaddr *ifp)
>  {
> -	struct list_head *p;
> +	struct inet6_ifaddr *ifa;
>  	int ifp_scope = ipv6_addr_src_scope(&ifp->addr);
>
>  	/*
>  	 * Each device address list is sorted in order of scope -
>  	 * global before linklocal.
>  	 */
> -	list_for_each(p, &idev->addr_list) {
> -		struct inet6_ifaddr *ifa
> -			= list_entry(p, struct inet6_ifaddr, if_list);
> +	list_for_each_entry(ifa, &idev->addr_list, if_list) {
>  		if (ifp_scope >= ipv6_addr_src_scope(&ifa->addr))
>  			break;
>  	}
>
> -	list_add_tail(&ifp->if_list, p);
> +	list_add_tail(&ifp->if_list, &ifa->if_list);
>  }
>
>  static u32 inet6_addr_hash(const struct in6_addr *addr)
> diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
> index 8ec0df7..437a500 100644
> --- a/net/ipv6/af_inet6.c
> +++ b/net/ipv6/af_inet6.c
> @@ -568,9 +568,7 @@ static const struct net_proto_family inet6_family_ops = {
>
>  int inet6_register_protosw(struct inet_protosw *p)
>  {
> -	struct list_head *lh;
> -	struct inet_protosw *answer;
> -	struct list_head *last_perm;
> +	struct inet_protosw *answer, *last_perm;
>  	int protocol = p->protocol;
>  	int ret;
>
> @@ -581,23 +579,16 @@ int inet6_register_protosw(struct inet_protosw *p)
>  		goto out_illegal;
>
>  	/* If we are trying to override a permanent protocol, bail. */
> -	answer = NULL;
>  	ret = -EPERM;
>  	last_perm = &inetsw6[p->type];
> -	list_for_each(lh, &inetsw6[p->type]) {
> -		answer = list_entry(lh, struct inet_protosw, list);
> -
> +	list_for_each_entry(answer, &inetsw6[p->type], list) {
>  		/* Check only the non-wild match. */
>  		if (INET_PROTOSW_PERMANENT & answer->flags) {
>  			if (protocol == answer->protocol)
> -				break;
> -			last_perm = lh;
> +				goto out_permanent;
> +			last_perm = answer;
>  		}
> -
> -		answer = NULL;
>  	}
> -	if (answer)
> -		goto out_permanent;
>
>  	/* Add the new entry after the last permanent entry if any, so that
>  	 * the new entry does not override a permanent entry when matched with
> @@ -605,7 +596,7 @@ int inet6_register_protosw(struct inet_protosw *p)
>  	 * non-permanent entry.  This means that when we remove this entry, the
>  	 * system automatically returns to the old behavior.
>  	 */
> -	list_add_rcu(&p->list, last_perm);
> +	list_add_rcu(&p->list, &last_perm->list);
>  	ret = 0;
>  out:
>  	spin_unlock_bh(&inetsw6_lock);
> --
> 2.5.0
>
>
>
