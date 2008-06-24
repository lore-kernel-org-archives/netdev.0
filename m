From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH (regression)] Fragments: fix race between
	inet_frag_find and   inet_frag_secret_rebuild
Date: Tue, 24 Jun 2008 20:07:14 +0200
Message-ID: <20080624180714.GA3125@ami.dom.local>
References: <4860CFC5.90702@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:20880 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750789AbYFXSFx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2008 14:05:53 -0400
Received: by ug-out-1314.google.com with SMTP id h2so763736ugf.16
        for <netdev@vger.kernel.org>; Tue, 24 Jun 2008 11:05:51 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4860CFC5.90702@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov wrote, On 06/24/2008 12:43 PM:

> The problem is that while we work w/o the inet_frags.lock even
> read-locked the secret rebuild timer may occur (on another CPU,
- since BHs are still disables in the inet_frag_find) and change 

+ since BHs are still disabled in the inet_frag_find) and change 

> the rnd seed for ipv4/6 fragments.
> 
> It was caused by my patch fd9e63544cac30a34c951f0ec958038f0529e244
> ([INET]: Omit double hash calculations in xxx_frag_intern) late 
> in the 2.6.24 kernel, so this should probably be queued to -stable.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> 
> ---
> 
> diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
> index 4ed429b..0546a0b 100644
> --- a/net/ipv4/inet_fragment.c
> +++ b/net/ipv4/inet_fragment.c
> @@ -192,14 +192,21 @@ EXPORT_SYMBOL(inet_frag_evictor);
>  
>  static struct inet_frag_queue *inet_frag_intern(struct netns_frags *nf,
>  		struct inet_frag_queue *qp_in, struct inet_frags *f,
> -		unsigned int hash, void *arg)
> +		void *arg)
>  {
>  	struct inet_frag_queue *qp;
>  #ifdef CONFIG_SMP
>  	struct hlist_node *n;
>  #endif
> +	unsigned int hash;
>  
>  	write_lock(&f->lock);
> +	/*
> +	 * While we stayed w/o the lock other CPU could update
> +	 * the rnd seed, so we need to re-calculate the hash
> +	 * chain. Fortunatelly the qp_in can be used to get one.
> +	 */
> +	hash = f->hashfn(qp_in);
>  #ifdef CONFIG_SMP
>  	/* With SMP race we have to recheck hash table, because
>  	 * such entry could be created on other cpu, while we

Maybe it's a matter of taste: since there is this "#ifdef CONFIG_SMP",
and the new comment concerns with "other CPU", why this re-calculation
isn't done only for SMP? And, btw., probably __acquires/__releases
annotations could be added with this patch.

Regards,
Jarek P.
