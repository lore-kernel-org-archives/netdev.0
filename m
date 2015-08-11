From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 6/9] net: Fix up inet_addr_type checks
Date: Tue, 11 Aug 2015 11:14:57 -0700 (PDT)
Message-ID: <20150811.111457.652499160223100513.davem@davemloft.net>
References: <1439229037-79213-1-git-send-email-dsa@cumulusnetworks.com>
	<1439229037-79213-7-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shm@cumulusnetworks.com,
	roopa@cumulusnetworks.com, gospo@cumulusnetworks.com,
	jtoppins@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	ddutt@cumulusnetworks.com, hannes@stressinduktion.org,
	nicolas.dichtel@6wind.com, stephen@networkplumber.org,
	hadi@mojatatu.com, ebiederm@xmission.com, svaidya@brocade.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50766 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751662AbbHKSO7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2015 14:14:59 -0400
In-Reply-To: <1439229037-79213-7-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Mon, 10 Aug 2015 11:50:33 -0600

> @@ -427,6 +428,7 @@ int inet_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
>  	struct net *net = sock_net(sk);
>  	unsigned short snum;
>  	int chk_addr_ret;
> +	int tb_id = 0;
>  	int err;
>  
>  	/* If the socket has its own bind function then use it. (RAW) */
> @@ -448,7 +450,16 @@ int inet_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
>  			goto out;
>  	}
>  
> -	chk_addr_ret = inet_addr_type(net, addr->sin_addr.s_addr);
> +	if (sk->sk_bound_dev_if) {
> +		struct net_device *dev;
> +
> +		rcu_read_lock();
> +		dev = dev_get_by_index_rcu(net, sk->sk_bound_dev_if);
> +		if (dev)
> +			tb_id = vrf_dev_table_rcu(dev);
> +		rcu_read_unlock();
> +	}
> +	chk_addr_ret = inet_addr_type_table(net, addr->sin_addr.s_addr, tb_id);
>  
>  	/* Not specified by any standard per-se, however it breaks too
>  	 * many applications when removed.  It is unfortunate since
 ...
> diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
> index b11321a8e58d..d84ae0e30369 100644
> --- a/net/ipv4/fib_frontend.c
> +++ b/net/ipv4/fib_frontend.c
> @@ -226,6 +226,9 @@ static inline unsigned int __inet_dev_addr_type(struct net *net,
>  
>  	rcu_read_lock();
>  
> +	if (!tb_id)
> +		tb_id = RT_TABLE_LOCAL;
> +
>  	table = fib_get_table(net, tb_id);

All of this code that quietly translates table ID zero into RT_TABLE_LOCAL is
confusing.

It would be so much easier to understand if the code was structured like:

	int tb_id = RT_TABLE_LOCAL;

	if (doing_vrf_stuff)
		tb_id = foo;
