From: Andrew Morton <akpm@osdl.org>
Subject: Re: kernel 2.6.7 -> page allocation failure. order:1, mode:0x20
 (netfilter?)
Date: Sun, 25 Jul 2004 17:59:45 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040725175945.15999990.akpm@osdl.org>
References: <40FB93FE.90308@ovibes.net>
	<20040720024741.GF27487@obroa-skai.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: sebest@ovibes.net, linux-kernel@vger.kernel.org,
        netfilter-devel@lists.netfilter.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@netfilter.org>
In-Reply-To: <20040720024741.GF27487@obroa-skai.de.gnumonks.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Harald Welte <laforge@netfilter.org> wrote:
>
> what's worrying me is the part above... how would skb_checksum_help
>  directly end up in copy_from_user()?

That'll be leftover gunk on the stack.  Enabling frame pointers makes that
go away.

>  > swapper: page allocation failure. order:1, mode:0x20
>  > [<c013d770>] __alloc_pages+0x2da/0x34a
>  > [<c013d805>] __get_free_pages+0x25/0x3f
>  > [<c0140e28>] kmem_getpages+0x2b/0xdc
>  > [<c0141bfc>] kfree_skbmem+0x24/0x2c
>  > [<c0141c5d>] cache_grow+0xe5/0x2a4
>  > [<c0141f8a>] cache_grow+0x146/0x2a4
>  > [<c0295917>] cache_alloc_refill+0x1cf/0x29f
>  > [<c014262a>] __kmalloc+0x85/0x8c
>  > [<c02681f1>] tcp_transmit_skb+0x411/0x68a
>  > [<c0296621>] alloc_skb+0x47/0xe0
>  > [<c026875e>] tcp_write_xmit+0x16d/0x2d6
>  > [<c01da1ac>] skb_copy+0x33/0xde
>  > [<c026ca5b>] copy_from_user+0x42/0x6e
> 
>  Does anybody have a clue what's going on?

Networking tried to do an atomic 1-order allocation and there were no
1-order pages available in the free page pools.  It's pretty much
unavoidable, and the caller simply needs to handle it - presumably by
dropping the packet.

Its frequency can be reduced by increasing /proc/sys/vm/min_free_kbytes.

It can be eliminated by using GFP_KERNEL.  It can be hugely reduced by
sticking to 0-order allocations.

I wouldn't worry about this unless someone is seeing a lot of them (a
significant number of packets are getting dropped)
