From: Lance Richardson <lrichard@redhat.com>
Subject: Re: [PATCH v3 net-next 05/16] tcp: switch back to proper tcp_skb_cb
 size check in tcp_init()
Date: Mon, 19 Sep 2016 10:37:06 -0400 (EDT)
Message-ID: <270694554.494524.1474295826754.JavaMail.zimbra@redhat.com>
References: <1474236233-28511-1-git-send-email-ncardwell@google.com> <1474236233-28511-6-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        Eric Dumazet <edumazet@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Yuchung Cheng <ycheng@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4-phx2.redhat.com ([209.132.183.25]:57393 "EHLO
        mx4-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750745AbcISOhL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 10:37:11 -0400
In-Reply-To: <1474236233-28511-6-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: "Neal Cardwell" <ncardwell@google.com>
> To: "David Miller" <davem@davemloft.net>
> Cc: netdev@vger.kernel.org, "Eric Dumazet" <edumazet@google.com>, "Soheil Hassas Yeganeh" <soheil@google.com>, "Neal
> Cardwell" <ncardwell@google.com>, "Yuchung Cheng" <ycheng@google.com>
> Sent: Sunday, September 18, 2016 6:03:42 PM
> Subject: [PATCH v3 net-next 05/16] tcp: switch back to proper tcp_skb_cb size check in tcp_init()
> 
> From: Eric Dumazet <edumazet@google.com>
> 
> Revert to the tcp_skb_cb size check that tcp_init() had before commit
> b4772ef879a8 ("net: use common macro for assering skb->cb[] available
> size in protocol families"). As related commit 744d5a3e9fe2 ("net:
> move skb->dropcount to skb->cb[]") explains, the
> sock_skb_cb_check_size() mechanism was added to ensure that there is
> space for dropcount, "for protocol families using it". But TCP is not
> a protocol using dropcount, so tcp_init() doesn't need to provision
> space for dropcount in the skb->cb[], and thus we can revert to the
> older form of the tcp_skb_cb size check. Doing so allows TCP to use 4
> more bytes of the skb->cb[] space.
> 
> Fixes: b4772ef879a8 ("net: use common macro for assering skb->cb[] available
> size in protocol families")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> ---
>  net/ipv4/tcp.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index 5b0b49c..53798e1 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -3244,11 +3244,12 @@ static void __init tcp_init_mem(void)
>  
>  void __init tcp_init(void)
>  {
> -	unsigned long limit;
>  	int max_rshare, max_wshare, cnt;
> +	unsigned long limit;
> +	struct sk_buff *skb;
>  	unsigned int i;
>  
> -	sock_skb_cb_check_size(sizeof(struct tcp_skb_cb));
> +	BUILD_BUG_ON(sizeof(struct tcp_skb_cb) > sizeof(skb->cb));
>  
The skb local variable could be avoided via:

        BUILD_BUG_ON(sizeof(struct tcp_skb_cb) > FIELD_SIZEOF(struct sk_buff, cb));

>  	percpu_counter_init(&tcp_sockets_allocated, 0, GFP_KERNEL);
>  	percpu_counter_init(&tcp_orphan_count, 0, GFP_KERNEL);
> --
> 2.8.0.rc3.226.g39d4020
> 
> 
