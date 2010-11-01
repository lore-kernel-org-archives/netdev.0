From: walter harms <wharms@bfs.de>
Subject: Re: [PATCH 2/3] net: packet: fix information leak to userland
Date: Mon, 01 Nov 2010 10:14:10 +0100
Message-ID: <4CCE84E2.9050801@bfs.de>
References: <1288545028-16436-1-git-send-email-segooon@gmail.com>
Reply-To: wharms@bfs.de
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jpirko@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Vasiliy Kulikov <segooon@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx01.sz.bfs.de ([194.94.69.103]:63746 "EHLO mx01.sz.bfs.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754377Ab0KAJOP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Nov 2010 05:14:15 -0400
In-Reply-To: <1288545028-16436-1-git-send-email-segooon@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Vasiliy Kulikov schrieb:
> packet_getname_spkt() doesn't initialize all members of sa_data field of
> sockaddr struct if strlen(dev->name) < 13.  This structure is then copied
> to userland.  It leads to leaking of contents of kernel stack memory.
> We have to fully fill sa_data with strncpy() instead of strlcpy().
> 
> The same with packet_getname(): it doesn't initialize sll_pkttype field of
> sockaddr_ll.  Set it to zero.
> 
> Signed-off-by: Vasiliy Kulikov <segooon@gmail.com>
> ---
>  net/packet/af_packet.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index 3616f27..0856a13 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -1719,7 +1719,7 @@ static int packet_getname_spkt(struct socket *sock, struct sockaddr *uaddr,
>  	rcu_read_lock();
>  	dev = dev_get_by_index_rcu(sock_net(sk), pkt_sk(sk)->ifindex);
>  	if (dev)
> -		strlcpy(uaddr->sa_data, dev->name, 15);
> +		strncpy(uaddr->sa_data, dev->name, 14);
>  	else
>  		memset(uaddr->sa_data, 0, 14);

if i understand the code correcly the max size for dev->name is IFNAMSIZ.
You can simply that part:

memset(uaddr->sa_data, 0, IFNAMSIZ);
dev = dev_get_by_index_rcu(sock_net(sk), pkt_sk(sk)->ifindex);
if (dev)
	strlcpy(uaddr->sa_data, dev->name, IFNAMSIZ);


you should send that as separate patch.
re,
 wh


>  	rcu_read_unlock();
> @@ -1742,6 +1742,7 @@ static int packet_getname(struct socket *sock, struct sockaddr *uaddr,
>  	sll->sll_family = AF_PACKET;
>  	sll->sll_ifindex = po->ifindex;
>  	sll->sll_protocol = po->num;
> +	sll->sll_pkttype = 0;
>  	rcu_read_lock();
>  	dev = dev_get_by_index_rcu(sock_net(sk), po->ifindex);
>  	if (dev) {
