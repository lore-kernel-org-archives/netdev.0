From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] af-unix: fix use-after-free with concurrent readers
 while splicing
Date: Tue, 10 Nov 2015 15:33:32 +0100
Message-ID: <1447166012.759777.434994833.3D15D18F@webmail.messagingengine.com>
References: <1447165595-28340-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Dmitry Vyukov <dvyukov@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:60976 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752323AbbKJOdd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2015 09:33:33 -0500
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 6EFF5212A0
	for <netdev@vger.kernel.org>; Tue, 10 Nov 2015 09:33:32 -0500 (EST)
In-Reply-To: <1447165595-28340-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 10, 2015, at 15:26, Hannes Frederic Sowa wrote:
>  net/unix/af_unix.c | 18 +++++++++++++++++-
>  1 file changed, 17 insertions(+), 1 deletion(-)
> 
> diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
> index aaa0b58..b2c4131 100644
> --- a/net/unix/af_unix.c
> +++ b/net/unix/af_unix.c
> @@ -441,6 +441,7 @@ static void unix_release_sock(struct sock *sk, int
> embrion)
>  		if (state == TCP_LISTEN)
>  			unix_release_sock(skb->sk, 1);
>  		/* passed fds are erased in the kfree_skb hook	      */
> +               UNIXCB(skb).consumed = skb->len;
>  		kfree_skb(skb);
>  	}
>  
> @@ -2152,7 +2153,7 @@ unlock:
>  		}
>  
>  		chunk = min_t(unsigned int, unix_skb_len(skb) - skip, size);
> -               chunk = state->recv_actor(skb, skip, chunk, state);
> +               chunk = state->recv_actor(skb_get(skb), skip, chunk,
> state);
>  		if (chunk < 0) {
>  			if (copied == 0)
>  				copied = -EFAULT;

I forgot a consume_skb here. Will send v2. Seems like I can review
patches much better in a mail client. :}

Bye,
Hannes
