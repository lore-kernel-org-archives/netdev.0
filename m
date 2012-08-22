From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] packet: Protect packet sk list with mutex (v2)
Date: Wed, 22 Aug 2012 08:59:17 +0200
Message-ID: <1345618757.5158.612.camel@edumazet-glaptop>
References: <50336BC7.7030209@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:51573 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752698Ab2HVG7W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 02:59:22 -0400
Received: by bkwj10 with SMTP id j10so169807bkw.19
        for <netdev@vger.kernel.org>; Tue, 21 Aug 2012 23:59:21 -0700 (PDT)
In-Reply-To: <50336BC7.7030209@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-08-21 at 15:06 +0400, Pavel Emelyanov wrote:
> Change since v1:
> 
> * Fixed inuse counters access spotted by Eric
> 
> In patch eea68e2f (packet: Report socket mclist info via diag module) I've
> introduced a "scheduling in atomic" problem in packet diag module -- the
> socket list is traversed under rcu_read_lock() while performed under it sk
> mclist access requires rtnl lock (i.e. -- mutex) to be taken.
> 
> [152363.820563] BUG: scheduling while atomic: crtools/12517/0x10000002
> [152363.820573] 4 locks held by crtools/12517:
> [152363.820581]  #0:  (sock_diag_mutex){+.+.+.}, at: [<ffffffff81a2dcb5>] sock_diag_rcv+0x1f/0x3e
> [152363.820613]  #1:  (sock_diag_table_mutex){+.+.+.}, at: [<ffffffff81a2de70>] sock_diag_rcv_msg+0xdb/0x11a
> [152363.820644]  #2:  (nlk->cb_mutex){+.+.+.}, at: [<ffffffff81a67d01>] netlink_dump+0x23/0x1ab
> [152363.820693]  #3:  (rcu_read_lock){.+.+..}, at: [<ffffffff81b6a049>] packet_diag_dump+0x0/0x1af
> 
> Similar thing was then re-introduced by further packet diag patches (fanount 
> mutex and pgvec mutex for rings) :(
> 
> Apart from being terribly sorry for the above, I propose to change the packet
> sk list protection from spinlock to mutex. This lock currently protects two
> modifications:
> 
> * sklist
> * prot inuse counters
> 
> The sklist modifications can be just reprotected with mutex since they already
> occur in a sleeping context. The inuse counters modifications are trickier -- the
> __this_cpu_-s are used inside, thus requiring the caller to handle the potential
> issues with contexts himself. Since packet sockets' counters are modified in two 
> places only (packet_create and packet_release) we only need to protect the context 
> from being preempted. BH disabling is not required in this case.
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
> index 226b2cd..79bc69c 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -2308,10 +2308,13 @@ static int packet_release(struct socket *sock)
>  	net = sock_net(sk);
>  	po = pkt_sk(sk);
>  
> -	spin_lock_bh(&net->packet.sklist_lock);
> +	mutex_lock(&net->packet.sklist_lock);
>  	sk_del_node_init_rcu(sk);
> +	mutex_unlock(&net->packet.sklist_lock);

I am still a bit uncomfortable : are we allowed to sleep in a release()
handler ?

It seems yes, so :

Acked-by: Eric Dumazet <edumazet@google.com>
