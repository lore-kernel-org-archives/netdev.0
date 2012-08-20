From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] packet: Protect packet sk list with mutex
Date: Mon, 20 Aug 2012 17:11:40 +0200
Message-ID: <1345475500.5158.321.camel@edumazet-glaptop>
References: <50324EBC.9060804@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:41249 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756790Ab2HTPLp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Aug 2012 11:11:45 -0400
Received: by bkwj10 with SMTP id j10so1891160bkw.19
        for <netdev@vger.kernel.org>; Mon, 20 Aug 2012 08:11:44 -0700 (PDT)
In-Reply-To: <50324EBC.9060804@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-08-20 at 18:50 +0400, Pavel Emelyanov wrote:
> In patch eea68e2f (packet: Report socket mclist info via diag module) I've
> introduced a "scheduling in atomic" problem in packet diag module -- the
> socket list is traversed under rcu_read_lock() while performed under it sk
> mclist access requires rtnl lock (i.e. -- mutex) to be taken. Similar thing
> was then re-introduced by further packet diag patches (fanount mutex and 
> pgvec mutex for rings) :(
> 
> Apart from being terribly sorry for the above, I propose to change the
> packet sk list protection from spinlock to mutex. This lock currently 
> protects only the sklist modifications (that already happen in sleeping 
> context) and nothing more.
> 
> Am I wrong again and a fine-grained atomic locking is required for
> everything that is reported by packet diag instead?
> 
> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
> 
> ---
> 
> diff --git a/include/net/netns/packet.h b/include/net/netns/packet.h
> index cb4e894..4780b08 100644
> --- a/include/net/netns/packet.h
> +++ b/include/net/netns/packet.h
> @@ -8,7 +8,7 @@
>  #include <linux/spinlock.h>
>  
>  struct netns_packet {
> -	spinlock_t		sklist_lock;
> +	struct mutex		sklist_lock;
>  	struct hlist_head	sklist;
>  };
>  
> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index 226b2cd..5048672 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -2308,10 +2308,10 @@ static int packet_release(struct socket *sock)
>  	net = sock_net(sk);
>  	po = pkt_sk(sk);
>  
> -	spin_lock_bh(&net->packet.sklist_lock);
> +	mutex_lock(&net->packet.sklist_lock);
>  	sk_del_node_init_rcu(sk);
>  	sock_prot_inuse_add(net, sk->sk_prot, -1);

Last time I checked, sock_prot_inuse_add() needed BH protection.

( This could be relaxed somehow on x86 thanks to this_cpu_add() ... but
thats another point)

Could you please report the full stack trace ?
