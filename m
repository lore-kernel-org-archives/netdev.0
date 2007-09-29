From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/5] net: Make rtnetlink infrastructure network namespace
 aware
Date: Sat, 29 Sep 2007 17:44:35 +0200
Message-ID: <46FE72E3.3000402@trash.net>
References: <m1myv69tfu.fsf@ebiederm.dsl.xmission.com> <m1hcle9td8.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Linux Containers <containers@lists.osdl.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:50762 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755220AbXI2Po5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Sep 2007 11:44:57 -0400
In-Reply-To: <m1hcle9td8.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric W. Biederman wrote:
>  void rtnl_unlock(void)
>  {
> -	mutex_unlock(&rtnl_mutex);
> -	if (rtnl && rtnl->sk_receive_queue.qlen)
> +	struct net *net;
> +
> +	/*
> +	 * Loop through all of the rtnl sockets until none of them (in
> +	 * a live network namespace) have queue packets.
> +	 *
> +	 * We have to be careful with the locking here as
> +	 * sk_data_ready aka rtnetlink_rcv takes the rtnl_mutex.
> +	 *
> +	 * To ensure the network namespace does not exit while
> +	 * we are processing packets on it's rtnl socket we
> +	 * grab a reference to the network namespace, ignoring
> +	 * it if the network namespace has already exited.
> +	 */
> +retry:
> +	for_each_net(net) {
> +		struct sock *rtnl = net->rtnl;
> +
> +		if (!rtnl || !rtnl->sk_receive_queue.qlen)
> +			continue;
> +
> +		if (!maybe_get_net(net))
> +			continue;
> +
> +		mutex_unlock(&rtnl_mutex);
>  		rtnl->sk_data_ready(rtnl, 0);
> +		mutex_lock(&rtnl_mutex);
> +		put_net(net);
> +		goto retry;
> +	}
> +	mutex_unlock(&rtnl_mutex);
> +
>  	netdev_run_todo();
>  }


I'm wondering why this receive queue processing on unlock is still
necessary today, we don't do trylock in rtnetlink_rcv anymore, so
all senders will simply wait until the lock is released and then
process the queue.
