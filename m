From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netfilter: replace horrible hack with ksize()
Date: Thu, 06 Mar 2008 15:03:35 +0100
Message-ID: <47CFF9B7.5060803@trash.net>
References: <Pine.LNX.4.64.0803052319210.15759@sbz-30.cs.Helsinki.FI>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, clameter@sgi.com, joe@perches.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Pekka J Enberg <penberg@cs.helsinki.fi>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0803052319210.15759@sbz-30.cs.Helsinki.FI>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pekka J Enberg wrote:
> From: Pekka Enberg <penberg@cs.helsinki.fi>
> 
> There's a horrible slab abuse in net/netfilter/nf_conntrack_extend.c that 
> can be replaced with a call to ksize().

This doesn't look right.

> @@ -95,7 +85,7 @@ void *__nf_ct_ext_add(struct nf_conn *ct
>  	newlen = newoff + t->len;
>  	rcu_read_unlock();
>  
> -	if (newlen >= ct->ext->real_len) {
> +	if (newlen >= ksize(ct->ext)) {


This needs to look at the currently allocated size, otherwise
it will always realloc when adding new extensions after having
used up ksize(ct->ext) space.

>  		new = kmalloc(newlen, gfp);

And this should use ksize(newlen) and store the real length
in real_len below.

>  		if (!new)
>  			return NULL;
> @@ -114,7 +104,6 @@ void *__nf_ct_ext_add(struct nf_conn *ct
>  			rcu_read_unlock();
>  		}
>  		kfree(ct->ext);
> -		new->real_len = newlen;
>  		ct->ext = new;
>  	}

