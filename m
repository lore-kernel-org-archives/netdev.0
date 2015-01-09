From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next 2/3] netlink: eliminate nl_sk_hash_lock
Date: Fri, 9 Jan 2015 10:55:16 +0000
Message-ID: <20150109105516.GA1600@casper.infradead.org>
References: <1420791818-22150-1-git-send-email-ying.xue@windriver.com>
 <1420791818-22150-3-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:51896 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932338AbbAIKzS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2015 05:55:18 -0500
Content-Disposition: inline
In-Reply-To: <1420791818-22150-3-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/09/15 at 04:23pm, Ying Xue wrote:
>  static struct sock *netlink_lookup(struct net *net, int protocol, u32 portid)
>  {
>  	struct netlink_table *table = &nl_table[protocol];
> @@ -1041,41 +1050,33 @@ netlink_update_listeners(struct sock *sk)
>  static int netlink_insert(struct sock *sk, struct net *net, u32 portid)
>  {
>  	struct netlink_table *table = &nl_table[sk->sk_protocol];
> -	int err = -EADDRINUSE;
> -
> -	mutex_lock(&nl_sk_hash_lock);
> -	if (__netlink_lookup(table, portid, net))
> -		goto err;
>  
> -	err = -EBUSY;
>  	if (nlk_sk(sk)->portid)
> -		goto err;
> +		return -EBUSY;
>  
> -	err = -ENOMEM;
>  	if (BITS_PER_LONG > 32 &&
>  	    unlikely(atomic_read(&table->hash.nelems) >= UINT_MAX))
> -		goto err;
> +		return -ENOMEM;
>  
>  	nlk_sk(sk)->portid = portid;

Since this code can now run in parallel, there is a race between
checking portid and then setting it. CPU#1 could overwrite portid after
CPU#0 has already checked portid, this would then insert the socket on
CPU#0 with the portid created on CPU#1. So this would need some kind
of atomic operation.
