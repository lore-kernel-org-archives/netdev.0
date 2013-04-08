From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: assign the sock correctly to an outgoing SYNACK
 packet
Date: Mon, 08 Apr 2013 09:19:23 -0700
Message-ID: <1365437963.3887.19.camel@edumazet-glaptop>
References: <20130408154519.18177.57709.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Miroslav Vadkerti <mvadkert@redhat.com>
To: Paul Moore <pmoore@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f173.google.com ([209.85.214.173]:46630 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935002Ab3DHQT1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 12:19:27 -0400
Received: by mail-ob0-f173.google.com with SMTP id wn14so4868085obc.4
        for <netdev@vger.kernel.org>; Mon, 08 Apr 2013 09:19:26 -0700 (PDT)
In-Reply-To: <20130408154519.18177.57709.stgit@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-04-08 at 11:45 -0400, Paul Moore wrote:
> Commit 90ba9b1986b5ac4b2d184575847147ea7c4280a2 converted
> tcp_make_synack() to use alloc_skb() directly instead of calling
> sock_wmalloc(), the goal being the elimination of two atomic
> operations.  Unfortunately, in doing so the change broke certain
> SELinux/NetLabel configurations by no longer correctly assigning
> the sock to the outgoing packet.
> 
> This patch fixes this regression by doing the skb->sk assignment
> directly inside tcp_make_synack().
> 
> Reported-by: Miroslav Vadkerti <mvadkert@redhat.com>
> Signed-off-by: Paul Moore <pmoore@redhat.com>
> ---
>  net/ipv4/tcp_output.c |    2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index 5d0b438..23cc295 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -2705,6 +2705,8 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
>  		dst_release(dst);
>  		return NULL;
>  	}
> +	skb->sk = sk;
> +

Hmm...

Keeping a pointer on a socket without taking a refcount is not going to
work.

We are trying to make the stack scale, so you need to add a selinux call
to take a ref count only if needed.

That is : If selinux is not used, we don't need to slow down the stack.
 
