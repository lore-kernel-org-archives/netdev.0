From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/3] udp: avoid a cache miss on dequeue
Date: Wed, 31 May 2017 10:00:43 -0700
Message-ID: <1496250043.27480.6.camel@edumazet-glaptop3.roam.corp.google.com>
References: <cover.1496070490.git.pabeni@redhat.com>
         <b07f7111480bb0ca2d98fe9fef49a593ab1c4787.1496070490.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:33730 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751100AbdEaRAp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 13:00:45 -0400
Received: by mail-pg0-f67.google.com with SMTP id s62so2546241pgc.0
        for <netdev@vger.kernel.org>; Wed, 31 May 2017 10:00:45 -0700 (PDT)
In-Reply-To: <b07f7111480bb0ca2d98fe9fef49a593ab1c4787.1496070490.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-05-29 at 17:27 +0200, Paolo Abeni wrote:
> Since UDP no more uses sk->destructor, we can clear completely
> the skb head state before enqueuing.

...

> @@ -1739,6 +1740,9 @@ static int __udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
>  		sk_mark_napi_id_once(sk, skb);
>  	}
>  
> +	/* drop all pending head states; dst, nf and sk are dropped by caller */
> +	secpath_reset(skb);
> +

I wonder if using skb_release_head_state() would be more appropriate ?

Surely more descriptive and probably not more expensive since all
cache lines should be already hot at this point.

>  	rc = __udp_enqueue_schedule_skb(sk, skb);
>  	if (rc < 0) {
>  		int is_udplite = IS_UDPLITE(sk);
