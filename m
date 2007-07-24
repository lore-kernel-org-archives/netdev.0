From: Mike Galbraith <efault@gmx.de>
Subject: Re: 2.6.23-rc1: BUG_ON in kmap_atomic_prot()
Date: Tue, 24 Jul 2007 12:01:09 +0200
Message-ID: <1185271269.6479.7.camel@Homer.simpson.net>
References: <alpine.LFD.0.999.0707221351030.3607@woody.linux-foundation.org>
	 <20070723183839.GA5874@martell.zuzino.mipt.ru>
	 <20070723190152.GA5755@martell.zuzino.mipt.ru>
	 <20070723132431.42afbae8.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Alexey Dobriyan <adobriyan@gmail.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:33402 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S932541AbXGXK3h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jul 2007 06:29:37 -0400
In-Reply-To: <20070723132431.42afbae8.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-07-23 at 13:24 -0700, Andrew Morton wrote:

> You're using DEBUG_PAGEALLOC, but I was not, so I think we can rule that out.

My box bugged during boot the first time I booted 23-rc1, but nothing
made it to the console, and I didn't have a serial console running.  I
didn't have DEBUG_PAGEALLOC or friends set.

> I haven't worked out where that kmap_atomic() call is coming from yet. 
> Both traces point up into the page allocator, but I _think_ that's stack
> gunk.

I just enabled all debug options, and was just rewarded with the below.

[  119.079531] eth1: link up, 100Mbps, full-duplex, lpa 0x45E1
[  119.558867] ------------[ cut here ]------------
[  119.572197] kernel BUG at arch/i386/mm/highmem.c:38!
[  119.585804] invalid opcode: 0000 [#1]
[  119.598013] PREEMPT SMP DEBUG_PAGEALLOC
[  119.610103] Modules linked in: edd button battery ac ip6t_REJECT xt_tcpudp ipt_REJECT xt_state iptable_mangle iptable_nat nf_nat iptable_filter ip6table_mangle nf_conntrack_ipv4 nf_conntrack nfnetlink ip_tables ip6table_filter ip6_tables x_tables nls_iso8859_1 nls_cp437 nls_utf8 snd_intel8x0 snd_ac97_codec ac97_bus snd_mpu401 snd_pcm prism54 snd_timer snd_mpu401_uart snd_rawmidi snd_seq_device snd intel_agp agpgart soundcore snd_page_alloc i2c_i801 fan thermal processor
[  119.698063] CPU:    1
[  119.698065] EIP:    0060:[<c011cd2d>]    Not tainted VLI
[  119.698067] EFLAGS: 00010006   (2.6.23-rc1-smp #75)
[  119.736358] EIP is at kmap_atomic_prot+0xa7/0xab
[  119.749647] eax: 3d07f163   ebx: c166db80   ecx: c0750e60   edx: 00000007
[  119.765417] esi: 00000022   edi: 00000163   ebp: c069dcd4   esp: c069dcc8
[  119.781273] ds: 007b   es: 007b   fs: 00d8  gs: 0033  ss: 0068
[  119.796378] Process udevd (pid: 4775, ti=c069d000 task=f31aea60 task.ti=f477d000)
[  119.804068] Stack: c166db80 00000000 c166db80 c069dcdc c011cd3f c069dd40 c015b6e0 00000001 
[  119.822272]        00000044 00000163 00000000 00000001 c165f4e0 00000001 c165f4e0 00000001 
[  119.840762]        00000000 00028020 c061e71c c166db80 00000046 00000080 00000001 c011e4de 
[  119.859389] Call Trace:
[  119.881302]  [<c0105144>] show_trace_log_lvl+0x1a/0x30
[  119.896319]  [<c01051ff>] show_stack_log_lvl+0xa5/0xca
[  119.911171]  [<c0105420>] show_registers+0x1fc/0x343
[  119.925756]  [<c0105689>] die+0x122/0x249
[  119.939241]  [<c0105834>] do_trap+0x84/0xad
[  119.952897]  [<c0105b1c>] do_invalid_op+0x88/0x92
[  119.967118]  [<c04cf3c2>] error_code+0x72/0x78
[  119.980948]  [<c011cd3f>] kmap_atomic+0xe/0x10
[  119.994642]  [<c015b6e0>] get_page_from_freelist+0x39e/0x45e
[  120.009485]  [<c015b7fb>] __alloc_pages+0x5b/0x2db
[  120.023342]  [<c0172872>] cache_alloc_refill+0x380/0x6f2
[  120.037623]  [<c0172e7a>] kmem_cache_alloc+0xa1/0xa5
[  120.051426]  [<c03fb397>] neigh_create+0x5f/0x506
[  120.064894]  [<c046e25d>] ndisc_dst_alloc+0x122/0x151
[  120.078769]  [<c0471b0b>] __ndisc_send+0x8d/0x4fa
[  120.092340]  [<c0472915>] ndisc_send_ns+0x5f/0x7d
[  120.105848]  [<c0469ff5>] addrconf_dad_timer+0xdb/0xe0
[  120.119758]  [<c012f8a0>] run_timer_softirq+0x130/0x191
[  120.133717]  [<c012c06d>] __do_softirq+0x76/0xe4
[  120.147475]  [<c0106b48>] do_softirq+0x63/0xac
[  120.147488]  [<c012bff5>] 

(gdb) list *neigh_create+0x5f
0xc03fb397 is in neigh_create (include/linux/slab.h:259).
254     /*
255      * Shortcuts
256      */
257     static inline void *kmem_cache_zalloc(struct kmem_cache *k, gfp_t flags)
258     {
259             return kmem_cache_alloc(k, flags | __GFP_ZERO);
260     }
261
262     /**
263      * kzalloc - allocate memory. The memory is set to zero.
(gdb) list *kmem_cache_alloc+0xa1
0xc0172e7a is in kmem_cache_alloc (mm/slab.c:3176).
3171                    STATS_INC_ALLOCHIT(cachep);
3172                    ac->touched = 1;
3173                    objp = ac->entry[--ac->avail];
3174            } else {
3175                    STATS_INC_ALLOCMISS(cachep);
3176                    objp = cache_alloc_refill(cachep, flags);
3177            }
3178            return objp;
3179    }
3180
(gdb) list *cache_alloc_refill+0x380
0xc0172872 is in cache_alloc_refill (include/linux/gfp.h:154).
149
150             /* Unknown node is current node */
151             if (nid < 0)
152                     nid = numa_node_id();
153
154             return __alloc_pages(gfp_mask, order,
155                     NODE_DATA(nid)->node_zonelists + gfp_zone(gfp_mask));
156     }
157
158     #ifdef CONFIG_NUMA
(gdb) list *__alloc_pages+0x5b
0xc015b7fb is in __alloc_pages (mm/page_alloc.c:1248).
1243            if (unlikely(*z == NULL)) {
1244                    /* Should this ever happen?? */
1245                    return NULL;
1246            }
1247
1248            page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, order,
1249                                    zonelist, ALLOC_WMARK_LOW|ALLOC_CPUSET);
1250            if (page)
1251                    goto got_pg;
1252
(gdb) list *get_page_from_freelist+0x39e
0xc015b6e0 is in get_page_from_freelist (include/linux/highmem.h:122).
117             return __alloc_zeroed_user_highpage(__GFP_MOVABLE, vma, vaddr);
118     }
119
120     static inline void clear_highpage(struct page *page)
121     {
122             void *kaddr = kmap_atomic(page, KM_USER0);
123             clear_page(kaddr);
124             kunmap_atomic(kaddr, KM_USER0);
125     }
126



