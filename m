From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 2/2] net: Introduce sk_clone_lock() error path routine
Date: Fri, 3 Mar 2017 12:34:43 +0300
Message-ID: <f76e6407-424d-7441-34dd-06c0c03e4d9a@cogentembedded.com>
References: <20170301193508.25760-1-acme@kernel.org>
 <20170301193508.25760-2-acme@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Arnaldo Carvalho de Melo <acme@redhat.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Gerrit Renker <gerrit@erg.abdn.ac.uk>,
        Thomas Gleixner <tglx@linutronix.de>
To: Arnaldo Carvalho de Melo <acme@kernel.org>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f48.google.com ([209.85.215.48]:32889 "EHLO
        mail-lf0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751563AbdCCLXr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Mar 2017 06:23:47 -0500
Received: by mail-lf0-f48.google.com with SMTP id a6so46049596lfa.0
        for <netdev@vger.kernel.org>; Fri, 03 Mar 2017 03:23:45 -0800 (PST)
In-Reply-To: <20170301193508.25760-2-acme@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On 3/1/2017 10:35 PM, Arnaldo Carvalho de Melo wrote:

> From: Arnaldo Carvalho de Melo <acme@redhat.com>
>
> When handling problems in cloning a socket with the sk_clone_locked()
> function we need to perform several steps that were open coded in it and
> its callers, so introduce a routine to avoid this duplication:
> sk_free_unlock_clone().
>
> Cc: Cong Wang <xiyou.wangcong@gmail.com>
> Cc: Dmitry Vyukov <dvyukov@google.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Link: http://lkml.kernel.org/n/net-ui6laqkotycunhtmqryl9bfx@git.kernel.org
> Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
[...]
> diff --git a/net/core/sock.c b/net/core/sock.c
> index 4eca27dc5c94..a3d9bb20f65d 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -1540,11 +1540,7 @@ struct sock *sk_clone_lock(const struct sock *sk, const gfp_t priority)
>  			is_charged = sk_filter_charge(newsk, filter);
>
>  		if (unlikely(!is_charged || xfrm_sk_clone_policy(newsk, sk))) {
> -			/* It is still raw copy of parent, so invalidate
> -			 * destructor and make plain sk_free() */
> -			newsk->sk_destruct = NULL;
> -			bh_unlock_sock(newsk);
> -			sk_free(newsk);
> +			sk_free_unlock_clone(newsk);
>  			newsk = NULL;
>  			goto out;
>  		}
> @@ -1593,6 +1589,16 @@ struct sock *sk_clone_lock(const struct sock *sk, const gfp_t priority)
>  }
>  EXPORT_SYMBOL_GPL(sk_clone_lock);
>
> +void sk_free_unlock_clone(struct sock *sk)
> +{
> +	/* It is still raw copy of parent, so invalidate
> +	 * destructor and make plain sk_free() */

    Could fix the comment style to the preferred one, while at it:

/* bla
  * bla
  */

> +	sk->sk_destruct = NULL;
> +	bh_unlock_sock(sk);
> +	sk_free(sk);
> +}
> +EXPORT_SYMBOL_GPL(sk_free_unlock_clone);
> +
>  void sk_setup_caps(struct sock *sk, struct dst_entry *dst)
>  {
>  	u32 max_segs = 1;
[...]

MBR, Sergei
