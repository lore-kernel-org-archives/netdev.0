From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] sit: reload iphdr in ipip6_rcv
Date: Mon, 05 Jun 2017 06:03:33 -0700
Message-ID: <1496667813.5031.20.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1496558623-11437-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Jesse Gross <jesse@kernel.org>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:35617 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751465AbdFENDh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 09:03:37 -0400
In-Reply-To: <1496558623-11437-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2017-06-04 at 14:43 +0800, Haishuang Yan wrote:
> Since iptunnel_pull_header() can call pskb_may_pull(),
> we must reload any pointer that was related to skb->head.
> 
> Fixes: a09a4c8dd1ec ("tunnels: Remove encapsulation offloads on decap")
> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
> ---
>  net/ipv6/sit.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
> index 61e5902..af832e7 100644
> --- a/net/ipv6/sit.c
> +++ b/net/ipv6/sit.c
> @@ -657,6 +657,7 @@ static int ipip6_rcv(struct sk_buff *skb)
>  		if (iptunnel_pull_header(skb, 0, htons(ETH_P_IPV6),
>  		    !net_eq(tunnel->net, dev_net(tunnel->dev))))
>  			goto out;
> +		iph = ip_hdr(skb);
>  
>  		err = IP_ECN_decapsulate(iph, skb);
>  		if (unlikely(err)) {

This seems unnecessary.

By the time ipip6_rcv() is called, we already have the guarantee the
IPv4 header is in skb linear part.

Otherwise we could not use iph->saddr and iph->daddr in the call to
ipip6_tunnel_lookup()

Therefore, the pskb_may_pull() is a nop in this particular case.
