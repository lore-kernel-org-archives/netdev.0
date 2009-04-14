From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH] LSM: Add security_socket_post_accept() and security_socket_post_recv_datagram().
Date: Tue, 14 Apr 2009 18:59:56 -0400
Message-ID: <200904141859.57965.paul.moore@hp.com>
References: <200904141944.JFE64074.FHtOMOFQLFJOVS@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-security-module@vger.kernel.org, netdev@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <200904141944.JFE64074.FHtOMOFQLFJOVS@I-love.SAKURA.ne.jp>
Content-Disposition: inline
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 14 April 2009 06:44:35 am Tetsuo Handa wrote:
> Hello.
>
> The security_socket_post_accept() hook was recently removed because this
> hook was not used by any in-tree modules and its existence continued to
> cause problems by confusing people about what can be safely accomplished
> using this hook. Now, TOMOYO became in-tree and TOMOYO wants to add network
> access control in 2.6.31.
>
> TOMOYO is not a label based access control and won't cause packet labeling
> problem. TOMOYO won't care as long as packets are not copied to userspace.

We've discussed this issue several times on the mailing list so I won't go 
over all of the details again, but I will say that my main concern with the 
post_accept() hook is that you are rejecting a connection after is has already 
gone through the connection handshake.  I personally don't feel this is a good 
approach but I don't want to stand in your way if I am alone on this point.

I'm less concerned about the recv_datagram() hook although the issues you 
point out about sharing sockets across multiple processes does highlight what 
I believe are some fundamental issues regarding the TOMOYO network security 
model.  Once again, I'm not going to object if I am the only one.

Lastly, I think in order to review these patches we need to see how they are 
used.  Please submit a patch set that includes both this patch as well as a 
patch to TOMOYO which makes use of these changes; this way we can properly 
review your patches in context.  Regardless, I took a quick look and noticed a 
few things (below).

Thanks.

> --- security-testing-2.6.git.orig/net/core/datagram.c
> +++ security-testing-2.6.git/net/core/datagram.c
> @@ -55,6 +55,7 @@
>  #include <net/checksum.h>
>  #include <net/sock.h>
>  #include <net/tcp_states.h>
> +#include <linux/security.h>
>
>  /*
>   *	Is a socket 'connection oriented' ?
> @@ -148,6 +149,7 @@ struct sk_buff *__skb_recv_datagram(stru
>  {
>  	struct sk_buff *skb;
>  	long timeo;
> +	unsigned long cpu_flags;
>  	/*
>  	 * Caller is allowed not to check sk->sk_err before skb_recv_datagram()
>  	 */
> @@ -165,7 +167,6 @@ struct sk_buff *__skb_recv_datagram(stru
>  		 * Look at current nfs client by the way...
>  		 * However, this function was corrent in any case. 8)
>  		 */
> -		unsigned long cpu_flags;
>
>  		spin_lock_irqsave(&sk->sk_receive_queue.lock, cpu_flags);
>  		skb = skb_peek(&sk->sk_receive_queue);
> @@ -179,6 +180,14 @@ struct sk_buff *__skb_recv_datagram(stru
>  		}
>  		spin_unlock_irqrestore(&sk->sk_receive_queue.lock, cpu_flags);
>
> +		/* Filter packets from unwanted peers. */

It might be best to drop this comment, we don't want to speculate how the LSM 
might be making access controls decisions here.

> +		if (skb) {
> +			error = security_socket_post_recv_datagram(sk, skb,
> +								   flags);
> +			if (error)
> +				goto force_dequeue;
> +		}
> +
>  		if (skb)
>  			return skb;

Why check to see if skb != NULL twice?  I think you should be able to move the 
skb return statement into the body of the first if block.

> @@ -191,6 +200,24 @@ struct sk_buff *__skb_recv_datagram(stru
>
>  	return NULL;
>
> +force_dequeue:
> +	/* Drop this packet because LSM says "Don't pass it to the caller". */

Once again, remove this comment since we don't know what a LSM might decide.

> +	if (!(flags & MSG_PEEK))
> +		goto no_peek;
> +	/*
> +	 * If this packet is MSG_PEEK'ed, dequeue it forcibly
> +	 * so that this packet won't prevent the caller from picking up
> +	 * next packet.
> +	 */
> +	spin_lock_irqsave(&sk->sk_receive_queue.lock, cpu_flags);
> +	if (skb == skb_peek(&sk->sk_receive_queue)) {
> +		__skb_unlink(skb, &sk->sk_receive_queue);
> +		atomic_dec(&skb->users);
> +		/* Do I have something to do with skb->peeked ? */

I don't know but you should find out before this code is merged :)

> +	}
> +	spin_unlock_irqrestore(&sk->sk_receive_queue.lock, cpu_flags);
> +no_peek:
> +	kfree_skb(skb);
>  no_packet:
>  	*err = error;
>  	return NULL;

-- 
paul moore
linux @ hp

