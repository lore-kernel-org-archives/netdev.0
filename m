From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: [PATCH net-2.6.25 3/3] Uninline the inet_twsk_put function
Date: Thu, 20 Dec 2007 19:32:45 +0100
Message-ID: <200712201932.45900.netdev@axxeo.de>
References: <4768F8CD.2050209@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.axxeo.de ([82.100.226.146]:3020 "EHLO mail.axxeo.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751016AbXLTTDE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Dec 2007 14:03:04 -0500
In-Reply-To: <4768F8CD.2050209@openvz.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov schrieb:
> This one is not that big, but is widely used: saves 1200 bytes 
> from net/ipv4/built-in.o
> +void inet_twsk_put(struct inet_timewait_sock *tw)
> +{
> +	if (atomic_dec_and_test(&tw->tw_refcnt)) {
> +		struct module *owner = tw->tw_prot->owner;
> +		twsk_destructor((struct sock *)tw);
> +#ifdef SOCK_REFCNT_DEBUG
> +		printk(KERN_DEBUG "%s timewait_sock %p released\n",
> +		       tw->tw_prot->name, tw);
> +#endif
> +		kmem_cache_free(tw->tw_prot->twsk_prot->twsk_slab, tw);
> +		module_put(owner);
> +	}
> +}
> +EXPORT_SYMBOL_GPL(inet_twsk_put);

More correct fix seems to be conversion to kref.

Just create out of line inet_twsk_release() containing
sth. similiar to the code inside these braces and modify 
inet_twsk_put() to sth. like this:

static inline inet_twsk_put(struct inet_timewait_sock *tw)
{
	kref_put(&tw->kref, inet_twsk_release);
}

David, can you see any reason (e.g. some crazy lock stuff) NOT to do this?


Best Regards

Ingo Oeser
