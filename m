From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: fix broken locking in x25 ioctl error paths
Date: Fri, 28 Jun 2013 08:19:35 -0700
Message-ID: <1372432775.3301.285.camel@edumazet-glaptop>
References: <20130628151453.GA29428@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f53.google.com ([74.125.83.53]:42464 "EHLO
	mail-ee0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755393Ab3F1PT3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jun 2013 11:19:29 -0400
Received: by mail-ee0-f53.google.com with SMTP id c41so1104477eek.26
        for <netdev@vger.kernel.org>; Fri, 28 Jun 2013 08:19:27 -0700 (PDT)
In-Reply-To: <20130628151453.GA29428@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-06-28 at 11:14 -0400, Dave Jones wrote:
> Two of the x25 ioctl cases have error paths that break out of the function without
> unlocking the socket, leading to this warning:
> 
> 
> ================================================
> [ BUG: lock held when returning to user space! ]
> 3.10.0-rc7+ #36 Not tainted
> ------------------------------------------------
> trinity-child2/31407 is leaving the kernel with locks still held!
> 1 lock held by trinity-child2/31407:
>  #0:  (sk_lock-AF_X25){+.+.+.}, at: [<ffffffffa024b6da>] x25_ioctl+0x8a/0x740 [x25]
> 
> Signed-off-by: Dave Jones <davej@redhat.com>
> 
> diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
> index 37ca969..2c1e633 100644
> --- a/net/x25/af_x25.c
> +++ b/net/x25/af_x25.c
> @@ -1584,10 +1584,11 @@ out_cud_release:
>  		rc = -EINVAL;
>  		lock_sock(sk);
>  		if (sk->sk_state != TCP_CLOSE)
> -			break;
> +			goto out_callaccpt_release;
>  		clear_bit(X25_ACCPT_APPRV_FLAG, &x25->flags);
> -		release_sock(sk);
>  		rc = 0;
> +out_callaccpt_release:
> +		release_sock(sk);
>  		break;
>  	}

Or :

lock_sock(sk);
if (sk->sk_state == TCP_CLOSE) {
    clear_bit(X25_ACCPT_APPRV_FLAG, &x25->flags);
    rc = 0;
}
release_sock(sk);
break;
