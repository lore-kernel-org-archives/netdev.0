From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: tcp: remove per net tcp_sock
Date: Thu, 19 Jul 2012 08:35:44 -0700 (PDT)
Message-ID: <20120719.083544.1223522161508413373.davem@davemloft.net>
References: <1342688332.2626.4001.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com, wsommerfeld@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45302 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750942Ab2GSPfp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2012 11:35:45 -0400
In-Reply-To: <1342688332.2626.4001.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 19 Jul 2012 10:58:52 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> tcp_v4_send_reset() and tcp_v4_send_ack() use a single socket
> per network namespace.
> 
> This leads to bad behavior on multiqueue NICS, because many cpus
> contend for the socket lock and once socket lock is acquired, extra
> false sharing on various socket fields slow down the operations.
> 
> To better resist to attacks, we use a percpu socket. Each cpu can
> run without contention, using appropriate memory (local node)
> 
> Additional features :
> 
> 1) We also mirror the queue_mapping of the incoming skb, so that
> answers use the same queue if possible.
> 
> 2) Setting SOCK_USE_WRITE_QUEUE socket flag speedup sock_wfree()
> 
> 3) We now limit the number of in-flight RST/ACK [1] packets
> per cpu, instead of per namespace, and we honor the sysctl_wmem_default
> limit dynamically. (Prior to this patch, sysctl_wmem_default value was
> copied at boot time, so any further change would not affect tcp_sock
> limit)
> 
> 
> [1] These packets are only generated when no socket was matched for
> the incoming packet.
> 
> Reported-by: Bill Sommerfeld <wsommerfeld@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Looks great, applied, thanks Eric.

> @@ -2624,13 +2624,11 @@ EXPORT_SYMBOL(tcp_prot);
>  
>  static int __net_init tcp_sk_init(struct net *net)
>  {
> -	return inet_ctl_sock_create(&net->ipv4.tcp_sock,
> -				    PF_INET, SOCK_RAW, IPPROTO_TCP, net);
> +	return 0;
>  }
>  
>  static void __net_exit tcp_sk_exit(struct net *net)
>  {
> -	inet_ctl_sock_destroy(net->ipv4.tcp_sock);
>  }
>  
>  static void __net_exit tcp_sk_exit_batch(struct list_head *net_exit_list)

If these no longer really do anything, just send me a patch to kill
them off entirely.

Thanks again.
