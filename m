From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: [PATCH 6/9] irda: use sock slab cache
Date: Thu, 20 Jan 2005 12:55:45 -0200
Message-ID: <41EFC671.6000706@conectiva.com.br>
References: <41EF11AF.70203@conectiva.com.br> <20050120021607.GA11216@bougret.hpl.hp.com> <41EF29BE.2020807@conectiva.com.br> <20050120085454.GA31160@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jt@hpl.hp.com, "David S. Miller" <davem@davemloft.net>,
        irda-users@lists.sourceforge.net, netdev@oss.sgi.com,
        Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20050120085454.GA31160@infradead.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Christoph Hellwig escreveu:
> On Thu, Jan 20, 2005 at 01:47:10AM -0200, Arnaldo Carvalho de Melo wrote:
> 
>>>	I'm just curious about the overhead of adding a specific slab
>>>for IrDA sockets. Most users never create any (using IrCOMM), or
>>>maximum one (using Obex), so it's not like it will get a lot of use
>>>(except here, of course).
>>
>>Well, lets start with something that may sound funny: when this series
>>of patches is finished the overhead will _decrease_ for most people.
>>
>>Why? Today we have in most machines five slab caches of this nature:
>>udp_sock, raw_sock, tcp_sock, unix_sock (PF_LOCAL) and the generic,
>>sock, that only is used by the protocols that are using 
>>kmalloc(pritave_sock) +
>>sk_protinfo.
> 
> 
> But as Jean sais this type of socket is used very little, as are a few
> other probably (raw, pfkey?), so maybe those should just use kmalloc +
> kfree instead of their own slab?

OK, rethinking the scheme:

Now: rename the zero_it sk_alloc parameter to obj_size, kmalloc the whole
aggregate sock in sk_alloc (e.g. struct irda_sock in the patch that originated
this thread) and set sk->sk_slab to NULL, not using sk_cachep (the generic
"sock" slab), at sk_free time we use this logic:

	if (sk->sk_slab == NULL)
		kfree(sk);
	else
		kmem_cache_free(sk->sk_slab, sk);

This works well for the transitional case, i.e. for the protocols that
still use the "sock" generic slab cache, for the ones that already
use private slab caches (tcp, udp, etc) and for the ones that will
be using this new scheme, with just kmalloc/kfree aggregate, derived
from struct sock, i.e. we can even leave the parameter as "zero_it"
as is, as it will be removed in the future, final scheme, described
in the next paragraph.

Future: rename sk->sk_prot->slab_obj_size to sk->sk_prot->obj_size,
leave sk->sk_prot->slab as NULL, this will make sk_alloc use kmalloc to
allocate sk->sk_prot->obj_size bytes, and sk_free, will just use kfree
when sk->sk_prot->slab is NULL.

What do you guys think? Sane? :-)

David, please don't apply this series of patches, I'll rework it
with this new scheme if nobody pokes any hole in it and resent.

Best Regards,

- Arnaldo
