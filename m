From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] udp: prevent bugcheck if filter truncates packet
 too much
Date: Sat, 09 Jul 2016 01:31:40 +0200
Message-ID: <1468020700.30694.38.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160708155233.C78AAA0ECC@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	samanthakumar <samanthakumar@google.com>,
	Marco Grassi <marco.gra@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Michal Kubecek <mkubecek@suse.cz>,
	Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33813 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756299AbcGHXbo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2016 19:31:44 -0400
In-Reply-To: <20160708155233.C78AAA0ECC@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-07-08 at 17:52 +0200, Michal Kubecek wrote:
> If socket filter truncates an udp packet below the length of UDP header
> in udpv6_queue_rcv_skb() or udp_queue_rcv_skb(), it will trigger a
> BUG_ON in skb_pull_rcsum(). This BUG_ON (and therefore a system crash if
> kernel is configured that way) can be easily enforced by an unprivileged
> user which was reported as CVE-2016-6162. For a reproducer, see
> http://seclists.org/oss-sec/2016/q3/8
> 
> Fixes: e6afc8ace6dd ("udp: remove headers from UDP packets before queueing")
> Reported-by: Marco Grassi <marco.gra@gmail.com>
> Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
> ---
>  net/ipv4/udp.c | 2 ++
>  net/ipv6/udp.c | 2 ++
>  2 files changed, 4 insertions(+)
> 
> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index ca5e8ea29538..4aed8fc23d32 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -1583,6 +1583,8 @@ int udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
>  
>  	if (sk_filter(sk, skb))
>  		goto drop;
> +	if (unlikely(skb->len < sizeof(struct udphdr)))
> +		goto drop;
>  
>  	udp_csum_pull_header(skb);
>  	if (sk_rcvqueues_full(sk, sk->sk_rcvbuf)) {
> diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
> index 005dc82c2138..acc09705618b 100644
> --- a/net/ipv6/udp.c
> +++ b/net/ipv6/udp.c
> @@ -620,6 +620,8 @@ int udpv6_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
>  
>  	if (sk_filter(sk, skb))
>  		goto drop;
> +	if (unlikely(skb->len < sizeof(struct udphdr)))
> +		goto drop;
>  
>  	udp_csum_pull_header(skb);
>  	if (sk_rcvqueues_full(sk, sk->sk_rcvbuf)) {


Arg :(

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks !
