From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: [PATCH 6/9] irda: use sock slab cache
Date: Thu, 20 Jan 2005 13:20:49 -0200
Message-ID: <41EFCC51.8030700@conectiva.com.br>
References: <41EF11AF.70203@conectiva.com.br> <20050120021607.GA11216@bougret.hpl.hp.com> <41EF29BE.2020807@conectiva.com.br> <20050120085454.GA31160@infradead.org> <41EFC671.6000706@conectiva.com.br>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050006080901010504050201"
Cc: jt@hpl.hp.com, "David S. Miller" <davem@davemloft.net>,
        irda-users@lists.sourceforge.net, netdev@oss.sgi.com,
        Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <41EFC671.6000706@conectiva.com.br>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050006080901010504050201
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Arnaldo Carvalho de Melo escreveu:
> Christoph Hellwig escreveu:
> 
>> On Thu, Jan 20, 2005 at 01:47:10AM -0200, Arnaldo Carvalho de Melo wrote:
>>
>>>>     I'm just curious about the overhead of adding a specific slab
>>>> for IrDA sockets. Most users never create any (using IrCOMM), or
>>>> maximum one (using Obex), so it's not like it will get a lot of use
>>>> (except here, of course).
>>>
>>>
>>> Well, lets start with something that may sound funny: when this series
>>> of patches is finished the overhead will _decrease_ for most people.
>>>
>>> Why? Today we have in most machines five slab caches of this nature:
>>> udp_sock, raw_sock, tcp_sock, unix_sock (PF_LOCAL) and the generic,
>>> sock, that only is used by the protocols that are using 
>>> kmalloc(pritave_sock) +
>>> sk_protinfo.
>>
>>
>>
>> But as Jean sais this type of socket is used very little, as are a few
>> other probably (raw, pfkey?), so maybe those should just use kmalloc +
>> kfree instead of their own slab?
> 
> 
> OK, rethinking the scheme:
> 
> Now: rename the zero_it sk_alloc parameter to obj_size, kmalloc the whole
> aggregate sock in sk_alloc (e.g. struct irda_sock in the patch that 
> originated
> this thread) and set sk->sk_slab to NULL, not using sk_cachep (the generic
> "sock" slab), at sk_free time we use this logic:
> 
>     if (sk->sk_slab == NULL)
>         kfree(sk);
>     else
>         kmem_cache_free(sk->sk_slab, sk);
> 
> This works well for the transitional case, i.e. for the protocols that
> still use the "sock" generic slab cache, for the ones that already
> use private slab caches (tcp, udp, etc) and for the ones that will
> be using this new scheme, with just kmalloc/kfree aggregate, derived
> from struct sock, i.e. we can even leave the parameter as "zero_it"
> as is, as it will be removed in the future, final scheme, described
> in the next paragraph.
> 
> Future: rename sk->sk_prot->slab_obj_size to sk->sk_prot->obj_size,
> leave sk->sk_prot->slab as NULL, this will make sk_alloc use kmalloc to
> allocate sk->sk_prot->obj_size bytes, and sk_free, will just use kfree
> when sk->sk_prot->slab is NULL.
> 
> What do you guys think? Sane? :-)
> 
> David, please don't apply this series of patches, I'll rework it
> with this new scheme if nobody pokes any hole in it and resent.

Take a look at this patch, it shows how I think the transitional
stage should be, the protocols will just use (IRDA for the example):

sk = sk_alloc(PF_IRDA, GFP_KERNEL, sizeof(struct irda_sock), NULL);

The ones still using the generic "sock" slab are using this, that
works with the patch attached:

sk = sk_alloc(PF_AX25, GFP_KERNEL, 1, NULL);
sk->sk_protinfo = kmalloc(sizeof(struct ax25_cb), GFP_KERNEL);

And the ones already using private slab caches:

sk = sk_alloc(PF_UNIX, GFP_KERNEL, sizeof(struct unix_sock), unix_sk_cachep);

All of this should work and when the transition to stop using sk->sk_protinfo
is finished the generic "sock" cache can be safely removed and the logic
in sk_alloc/sk_free will just not use it.

Further on, when all families are converted to using sk->sk_prot sk_alloc will
have this prototype:

struct sock *sk_alloc(struct proto *prot, int priority, int zero_it)

it will get the family from prot->family, the slab from prot->slab and
the size of the object, if zero_it, that will be just a boolean, like it
was before sock slab caches were introduced, is true, we use prot->obj_size
to do the zeroing using memset.

- Arnaldo


--------------050006080901010504050201
Content-Type: text/plain;
 name="sk_slab.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="sk_slab.patch"

===== net/core/sock.c 1.57 vs edited =====
--- 1.57/net/core/sock.c	2005-01-10 18:23:56 -02:00
+++ edited/net/core/sock.c	2005-01-20 13:04:13 -02:00
@@ -621,9 +621,17 @@
 {
 	struct sock *sk = NULL;
 
-	if (!slab)
-		slab = sk_cachep;
-	sk = kmem_cache_alloc(slab, priority);
+	/* FIXME:
+	 * Transitional, will be removed when all the families stop
+	 * using sk->sk_protinfo
+	 */
+	if (zero_it > 1)
+		sk = kmalloc(zero_it, priority);
+	else {
+		if (!slab)
+			slab = sk_cachep;
+		sk = kmem_cache_alloc(slab, priority);
+	}
 	if (sk) {
 		if (zero_it) {
 			memset(sk, 0,
@@ -631,10 +639,15 @@
 			sk->sk_family = family;
 			sock_lock_init(sk);
 		}
-		sk->sk_slab = slab;
+
+		if (zero_it != 1)
+			sk->sk_slab = slab;
 		
 		if (security_sk_alloc(sk, family, priority)) {
-			kmem_cache_free(slab, sk);
+			if (sk->sk_slab)
+				kmem_cache_free(slab, sk);
+			else
+				kfree(sk);
 			sk = NULL;
 		}
 	}
@@ -662,7 +675,10 @@
 		       __FUNCTION__, atomic_read(&sk->sk_omem_alloc));
 
 	security_sk_free(sk);
-	kmem_cache_free(sk->sk_slab, sk);
+	if (sk->sk_slab)
+		kmem_cache_free(sk->sk_slab, sk);
+	else
+		kfree(sk);
 	module_put(owner);
 }
 

--------------050006080901010504050201--
