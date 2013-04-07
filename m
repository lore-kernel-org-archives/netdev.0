From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] ipv6/tcp: Stop processing ICMPv6 redirect messages
Date: Sun, 07 Apr 2013 08:02:22 -0700
Message-ID: <1365346942.3887.6.camel@edumazet-glaptop>
References: <1365346395-18016-1-git-send-email-christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	djduanjiong@gmail.com, steffen.klassert@secunet.com,
	Neal Cardwell <ncardwell@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Christoph Paasch <christoph.paasch@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:59230 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933878Ab3DGPC0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Apr 2013 11:02:26 -0400
Received: by mail-pa0-f51.google.com with SMTP id jh10so2798392pab.24
        for <netdev@vger.kernel.org>; Sun, 07 Apr 2013 08:02:26 -0700 (PDT)
In-Reply-To: <1365346395-18016-1-git-send-email-christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-04-07 at 16:53 +0200, Christoph Paasch wrote:
> Tetja Rediske found that if the host receives an ICMPv6 redirect message
> after sending a SYN+ACK, the connection will be reset.
> 
> He bisected it down to 093d04d (ipv6: Change skb->data before using
> icmpv6_notify() to propagate redirect), but the origin of the bug comes
> from ec18d9a26 (ipv6: Add redirect support to all protocol icmp error
> handlers.). The bug simply did not trigger prior to 093d04d, because
> skb->data did not point to the inner IP header and thus icmpv6_notify
> did not call the correct err_handler.
> 
> This patch adds the missing "goto out;" in tcp_v6_err. After receiving
> an ICMPv6 Redirect, we should not continue processing the ICMP in
> tcp_v6_err, as this may trigger the removal of request-socks or setting
> sk_err(_soft).
> 
> Reported-by: Tetja Rediske <tetja@tetja.de>
> Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
> ---
> v2: Removed code-cleanup from the patch and improved the commit-message upon 
> suggestion from Eric Dumazet.
> 
>  net/ipv6/tcp_ipv6.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
> index 1033d2b..e51bd1a 100644
> --- a/net/ipv6/tcp_ipv6.c
> +++ b/net/ipv6/tcp_ipv6.c
> @@ -386,6 +386,7 @@ static void tcp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
>  
>  		if (dst)
>  			dst->ops->redirect(dst, sk, skb);
> +		goto out;
>  	}
>  
>  	if (type == ICMPV6_PKT_TOOBIG) {


Thanks for sorting this out.

Acked-by: Eric Dumazet <edumazet@google.com>
