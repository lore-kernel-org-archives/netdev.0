From: Paul Moore <paul.moore@hp.com>
Subject: Re: [IPSEC] flow: Cache negative results
Date: Wed, 10 Jan 2007 11:11:43 -0500
Message-ID: <200701101111.43688.paul.moore@hp.com>
References: <20070110072251.GA27030@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	James Morris <jmorris@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel7.hp.com ([156.153.255.213]:55293 "EHLO atlrel7.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964927AbXAJQLw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Jan 2007 11:11:52 -0500
To: Herbert Xu <herbert.xu@redhat.com>
In-Reply-To: <20070110072251.GA27030@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday, January 10 2007 2:22 am, Herbert Xu wrote:
> Hi:
>
> [IPSEC] flow: Cache negative security checks

Hi Herbert,

I'm far from a flow cache expert (David, James, and Venkat will probably be 
able to give you much better feedback) I did notice a few things which may or 
may not be issues ... comments below.  FWIW, I believe Venkat is right in 
that it shouldn't have any effect on the LSM code.

However, there is one other thing that came up when I was looking at your 
patch, unrelated to your changes, that I wanted to ask about: in 
net/core/flow.c:flow_entry_kill() ...

> static void flow_entry_kill(int cpu, struct flow_cache_entry *fle)
> {
>        if (fle->object)

Should this be "if (fle->object_ref)"?

>                atomic_dec(fle->object_ref);
>        kmem_cache_free(flow_cachep, fle);
>        flow_count(cpu)--; 
> }

Your changes:

> Index: net-2.6_review/net/core/flow.c
> ===================================================================
> --- net-2.6_review.orig/net/core/flow.c
> +++ net-2.6_review/net/core/flow.c
> @@ -197,12 +197,16 @@ void *flow_cache_lookup(struct flowi *ke
>                         if (fle->genid == atomic_read(&flow_cache_genid)) {
>                                 void *ret = fle->object;
> 
> -                               if (ret)
> +                               if (fle->object_ref)
>                                         atomic_inc(fle->object_ref);
>                                 local_bh_enable();
> 
>                                 return ret;
>                         }

This is a real nit, but would it be better to get rid of the "ret" variable 
entirely and simply "return (void *)fle->object" while you're at it?

> +
> +                       if (fle->object_ref)
> +                               atomic_dec(fle->object_ref);
> +                       fle->object_ref = NULL;
>                         break;

It seems that we could potentially save an operation in some cases by moving 
the "fle->object_ref = NULL" statement inside the if block, for example:

 if (fle->object_ref) {
         atomic_dec(fle->object_ref);
         fle->object_ref = NULL;
 }

> @@ -230,28 +234,20 @@ nocache:
>                 atomic_t *obj_ref;
> 
>                 err = resolver(key, family, dir, &obj, &obj_ref);
> +               if (err)
> +                       obj = ERR_PTR(err);
> 
>                 if (fle) {
> -                       if (err) {
> -                               /* Force security policy check on next ...
> -                               *head = fle->next;
> -                               flow_entry_kill(cpu, fle);
> -                       } else {
> -                               fle->genid = atomic_read(&flow_cache_genid);
> +                       fle->object = obj;
> +                       fle->genid = atomic_read(&flow_cache_genid);
> 
> -                               if (fle->object)
> -                                       atomic_dec(fle->object_ref);
> -
> -                               fle->object = obj;
> +                       if (!err && obj) {

Should this if statement be changed to "if (!err && obj_ref) {"?

>                                 fle->object_ref = obj_ref;
> -                               if (obj)
> -                                       atomic_inc(fle->object_ref);
> +                               atomic_inc(obj_ref);
>                         }
>                 }
>                 local_bh_enable();
> 
> -               if (err)
> -                       obj = ERR_PTR(err);
>                 return obj;
>         }
>  }

-- 
paul moore
linux security @ hp
