From: Andrew Morton <akpm@osdl.org>
Subject: Re: kernel BUG at page_alloc.c:98 -- compiling with distcc
Date: Fri, 2 Apr 2004 15:36:28 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040402153628.4a09d979.akpm@osdl.org>
References: <406D3E8F.20902@abbeynet.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Marco Fais <marco.fais@abbeynet.it>
In-Reply-To: <406D3E8F.20902@abbeynet.it>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


(linux-2.4.25) 

Marco Fais <marco.fais@abbeynet.it> wrote:
>
> kernel BUG at page_alloc.c:98!
> 

uh-oh.

> 
> > >EIP; c01372ae <__free_pages_ok+26e/280>   <=====
> 
> > >ebx; c14b3f00 <_end+116e728/204d48a8>
> > >ecx; c14b3f00 <_end+116e728/204d48a8>
> > >edi; dec11340 <_end+1e8cbb68/204d48a8>
> > >ebp; c02f1d04 <init_task_union+1d04/2000>
> > >esp; c02f1cd4 <init_task_union+1cd4/2000>
> 
> Trace; c0135a76 <kmem_cache_free_one+f6/210>
> Trace; c021667b <skb_release_data+6b/90>
> Trace; c02166b4 <kfree_skbmem+14/70>
> Trace; c0216816 <__kfree_skb+106/160>
> Trace; c023be39 <tcp_clean_rtx_queue+139/330>
> Trace; c023c385 <tcp_ack+c5/380>
> Trace; c023f51c <tcp_rcv_state_process+19c/a90>
> Trace; c02465a9 <tcp_v4_do_rcv+a9/130>
> Trace; c0246a76 <tcp_v4_rcv+446/560>
> Trace; c022dad0 <ip_local_deliver_finish+0/180>
> Trace; c022dc25 <ip_local_deliver_finish+155/180>
> Trace; c0222780 <nf_hook_slow+b0/170>
> Trace; c022dad0 <ip_local_deliver_finish+0/180>
> Trace; c022d88f <ip_local_deliver+4f/70>
> Trace; c022dad0 <ip_local_deliver_finish+0/180>
> Trace; c022de3a <ip_rcv_finish+1ea/270>
> Trace; e08d7eab <[8139too]rtl8139_rx_interrupt+6b/3b0>
> Trace; c021ad14 <netif_receive_skb+c4/180>
> Trace; c021ae3f <process_backlog+6f/120>
> Trace; c021af5a <net_rx_action+6a/100>
> Trace; c0121cd7 <do_softirq+97/a0>
> Trace; c010a66d <do_IRQ+bd/f0>

distcc uses sendfile().  The 8139too hardware and driver are
zerocopy-capable so the kernel uses zerocopy direct-from-user-pages for
sendfile().

The bug is that the networking layer is releasing the final ref to user
pages from softirq context.  Those pages are still on the page LRU so
__free_pages_ok() will take them off.

Problem is, removing these pages from the LRU requires that the
pagemap_lru_lock be taken, and that lock may not be taken from interrupt
context.   So we go BUG instead.

This was all discussed fairly extensively a couple of years back and I
thought it ended up being fixed.
