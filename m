From: Mark McLoughlin <markmc@redhat.com>
Subject: net-next: broken IP_PKTINFO [was Re: [PATCH] net: release skb->dst
 in sock_queue_rcv_skb()]
Date: Wed, 17 Dec 2008 11:25:01 +0000
Message-ID: <1229513101.3685.57.camel@localhost.localdomain>
References: <492A7E85.3060502@cosmosbay.com>
	 <20081124.153954.215777060.davem@davemloft.net>
	 <492B8274.6080609@cosmosbay.com>
	 <20081124.210038.90767194.davem@davemloft.net>
	 <492C919E.3050108@cosmosbay.com>
Reply-To: Mark McLoughlin <markmc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, andi@firstfloor.org,
	netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:37126 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751010AbYLQLZX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Dec 2008 06:25:23 -0500
In-Reply-To: <492C919E.3050108@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Wed, 2008-11-26 at 01:00 +0100, Eric Dumazet wrote:

> [PATCH] net: release skb->dst in sock_queue_rcv_skb()
> 
> When queuing a skb to sk->sk_receive_queue, we can release its dst, not
> anymore needed.
> Since current cpu did the dst_hold(), refcount is probably still hot
> int this cpu caches.
> 
> This avoids readers to access the original dst to decrement its refcount,
> possibly a long time after packet reception. This should speedup UDP
> and RAW receive path.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
> plain text document attachment (sock_queue_rcv_skb.patch)
> diff --git a/net/core/sock.c b/net/core/sock.c
> index a4e840e..b287645 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -289,7 +289,11 @@ int sock_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
>  
>  	skb->dev = NULL;
>  	skb_set_owner_r(skb, sk);
> -
> +	/*
> +	 * release dst right now while its hot
> +	 */
> +	dst_release(skb->dst);
> +	skb->dst = NULL;

IP_PKTINFO cmsg data is one post-queueing user:

  static void ip_cmsg_recv_pktinfo(struct msghdr *msg, struct sk_buff *skb)
  {
          struct in_pktinfo info;
          struct rtable *rt = skb->rtable;

          info.ipi_addr.s_addr = ip_hdr(skb)->daddr;
          if (rt) {
                  info.ipi_ifindex = rt->rt_iif;
                  info.ipi_spec_dst.s_addr = rt->rt_spec_dst;
          } else {
                  info.ipi_ifindex = 0;
                  info.ipi_spec_dst.s_addr = 0;
          }

          put_cmsg(msg, SOL_IP, IP_PKTINFO, sizeof(info), &info);
  }

(i.e. skb->rtable is NULL at this point)

I'm seeing dnsmasq not working on net-next-2.6 because of this and
reverting commit 7035560 makes things work as expected again.

Cheers,
Mark.

