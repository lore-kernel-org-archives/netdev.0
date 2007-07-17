From: Patrick McHardy <kaber@trash.net>
Subject: Re: [patch 2/3] netlink: allow removing multicast groups
Date: Tue, 17 Jul 2007 17:50:25 +0200
Message-ID: <469CE541.9090708@trash.net>
References: <20070717122706.899784000@sipsolutions.net> <20070717123643.626951000@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Zhang Rui <rui.zhang@intel.com>, jamal <hadi@cyberus.ca>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47505 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935361AbXGQPub (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2007 11:50:31 -0400
In-Reply-To: <20070717123643.626951000@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Johannes Berg wrote:
> +static void netlink_update_socket_mc(struct netlink_sock *nlk,
> +				     unsigned int group,
> +				     int is_new)
> +{
> +	int old, new = !!is_new, subscriptions;
> +
> +	netlink_table_grab();


Having the caller lock the table would save lots of atomic operation
in case of netlink_clear_multicast_users.

> +	old = test_bit(group - 1, nlk->groups);
> +	subscriptions = nlk->subscriptions - old + new;
> +	if (new)
> +		__set_bit(group - 1, nlk->groups);
> +	else
> +		__clear_bit(group - 1, nlk->groups);
> +	netlink_update_subscriptions(&nlk->sk, subscriptions);
> +	netlink_update_listeners(&nlk->sk);
> +	netlink_table_ungrab();
> +}
> +

> +void netlink_clear_multicast_users(int unit, unsigned int group)

Same as in the last patch, passing the kernel socket would be nicer IMO.

> +{
> +	struct sock *sk;
> +	struct hlist_node *node;
> +
> +	read_lock(&nl_table_lock);

Won't this deadlock? netlink_table_grab takes a write-lock.

> +
> +	sk_for_each_bound(sk, node, &nl_table[unit].mc_list)
> +		netlink_update_socket_mc(nlk_sk(sk), group, 0);
> +
> +	read_unlock(&nl_table_lock);
> +}
> +EXPORT_SYMBOL(netlink_clear_multicast_users);
> +
>  void netlink_set_nonroot(int protocol, unsigned int flags)
>  {
>  	if ((unsigned int)protocol < MAX_LINKS)
> 

