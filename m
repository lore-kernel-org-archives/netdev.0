From: Andrew Morton <akpm@osdl.org>
Subject: Re: [Fwd: [Bug 3003] New: might_sleep warning when setting up IPSec
 with IPCOMP]
Date: Fri, 2 Jul 2004 14:39:49 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040702143949.21a50b74.akpm@osdl.org>
References: <40E5A1B3.2020202@us.ibm.com>
	<40E5D326.5000509@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: niv@us.ibm.com, jmorris@intercode.com.au, netdev@oss.sgi.com,
        christophe@saout.de, mjbligh@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Nivedita Singhvi <niv@us.ibm.com>
In-Reply-To: <40E5D326.5000509@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Nivedita Singhvi <niv@us.ibm.com> wrote:
>
> Nivedita Singhvi wrote:
> 
> > James, Andrew,
> > 
> > Looks like deflate_comp_init() is not calling
> > __vmalloc in a kosher way.
> 
> > Jul  2 18:39:04 websrv Debug: sleeping function called from invalid 
> > context at
> > mm/slab.c:1994
> > Jul  2 18:39:04 websrv in_atomic():1, irqs_disabled():0
> > Jul  2 18:39:04 websrv [<c0106c37>] dump_stack+0x17/0x20
> > Jul  2 18:39:04 websrv [<c0118fb4>] __might_sleep+0xb4/0xe0
> > Jul  2 18:39:04 websrv [<c0139fbc>] kmem_cache_alloc+0x5c/0x60
> > Jul  2 18:39:04 websrv [<c0147bc0>] __get_vm_area+0x20/0xf0
> > Jul  2 18:39:04 websrv [<c0147cb4>] get_vm_area+0x24/0x30
> > Jul  2 18:39:04 websrv [<c0147f1c>] __vmalloc+0x3c/0x100
> > Jul  2 18:39:04 websrv [<c01ecdca>] deflate_comp_init+0x4a/0xf0
> > Jul  2 18:39:04 websrv [<c01ecf44>] deflate_compress+0x24/0x80
> > Jul  2 18:39:04 websrv [<c01e8a84>] crypto_compress+0x24/0x30
> > Jul  2 18:39:04 websrv [<c031744c>] ipcomp_compress+0x6c/0x110
> > Jul  2 18:39:04 websrv [<c0317681>] ipcomp_output+0xc1/0x370
> 
> We are grabbing dst->xfrm lock in ipcomp_output(),
> and have it held when we call ipcomp_compress().
> 
> Is that the issue? I don't have the crypto module
> code, but in_atomic() will be true.
> 

Yes, that is the issue.

>From a design point-of-view, it is not idiomatic for deflate_compress() to
be doing this magical lazy initialisation.  It would be better if the
client of the deflate.c code were to explicitly initialise the context
before diving in and using it.

	/*
	 * Lazy initialization to make interface simple without allocating
	 * un-needed workspaces.  Thus can be called in softirq context.
	 */
	static int deflate_comp_init(struct deflate_ctx *ctx)

Well no.  Those games with deflate_gfp() really need to go away. 
in_atomic() works OK if CONFIG_PREEMPT is enabled.  But with
CONFIG_PREEMPT=n, in_atomic() returns false inside spinlock.  And
in_atomic()'s return value is unaffected by local_irq_disable().

This all needs to be redesigned, sorry.
