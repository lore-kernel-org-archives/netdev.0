From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: BUG: 2.6.25-rc1: iptables postrouting setup causes oops
Date: Wed, 13 Feb 2008 00:48:29 -0800
Message-ID: <20080213004829.fd8afdc7.akpm@linux-foundation.org>
References: <1202816761.3299.19.camel@moss.renham>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Haavard Skinnemoen <hskinnemoen@atmel.com>
To: Ben Nizette <bn@niasdigital.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1202816761.3299.19.camel@moss.renham>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 12 Feb 2008 22:46:01 +1100 Ben Nizette <bn@niasdigital.com> wrote:

> 
> On an AVR32, root over NFS, config attached, running (from a startup
> script):
> 
> iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
> 
> Results in (dmesg extract including a bit of context for good measure):
> -------------8<----------------
> VFS: Mounted root (nfs filesystem).
> Freeing init memory: 72K (90000000 - 90012000)
> eth0: no IPv6 routers present
> warning: `dnsmasq' uses 32-bit capabilities (legacy support in use)
> ip_tables: (C) 2000-2006 Netfilter Core Team
> nf_conntrack version 0.5.0 (1024 buckets, 4096 max)
> Unable to handle kernel paging request at virtual address d76a7138
> ptbr = 91d3b000 pgd = 0000e5f3 pte = 00014370
> Oops: Kernel access of bad area, sig: 11 [#1]
> FRAME_POINTER chip: 0x01f:0x1e82 rev 2
> Modules linked in: nf_conntrack_ipv4(+) nf_conntrack ip_tables
> PC is at kmem_cache_alloc+0x2c/0x54
> LR is at nf_conntrack_l4proto_register+0x34/0x9c [nf_conntrack]

I take it that the above means that the crash is in kmem_cache_alloc()?

> pc : [<9004fa78>]    lr : [<c08537d8>]    Not tainted
> sp : 91eb5e9c  r12: 901cc588  r11: 000000d0
> r10: 901e03a0  r9 : 00000002  r8 : 91d33800
> r7 : 91eb5e9c  r6 : 901d9138  r5 : 901cc588  r4 : 0007a008
> r3 : 000000d0  r2 : 00400005  r1 : c085f9c0  r0 : c08c1424
> Flags: qvNzc
> Mode bits: hjmde....G
> CPU Mode: Supervisor
> Process: insmod [250] (task: 91d789c0 thread: 91eb4000)
> Stack: (0x91eb5e9c to 0x91eb6000)
> 5e80:                                                                c08537d8
> 5ea0: 91eb5ec0 c085a6b4 00000000 0007a008 fffffff0 00000027 c085f9c0 c08c1424
> 5ec0: c0861024 91eb5ee4 00000000 c085f654 0007a008 901d31b0 00000027 c085f9c0
> 5ee0: c08c1424 900358d4 91eb5f94 91d6ddf0 901d31b8 0007a008 91eb5f08 0007a008
> 5f00: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
> 5f20: 0000000c 00000000 00000000 00000000 00000007 c08df440 91d1c660 c08c19ec
> 5f40: c08c16a4 c0881000 00000000 000000b2 000000b2 c085e17c 90022414 00000027
> 5f60: c08c12c3 c08c1424 c08c1a3c c08c1a14 00000027 00000025 00060000 2ab17000
> 5f80: 90047080 91eb5f94 91eb4000 00000000 c087ef80 90012132 00000000 00072e14
> 5fa0: 0000535e 0007a008 00072858 7f89ff73 80000000 91eb4000 00000001 2aae23ec
> 5fc0: 7f89fd98 7f89fd88 2ab17008 0005edf5 0007a008 0005edf5 00000073 7f89fedc
> 5fe0: 00072e14 0000535e 0007a008 00072858 7f89ff73 00000002 00059538 2ab17008
> Call trace:
>  [<c08537d8>] nf_conntrack_l4proto_register+0x34/0x9c [nf_conntrack]
>  [<c0861024>] nf_conntrack_l3proto_ipv4_init+0x24/0x108 [nf_conntrack_ipv4]
>  [<900358d4>] sys_init_module+0xf78/0x1028
>  [<90012132>] syscall_return+0x0/0x12
> 
> iptable_nat: gave up waiting for init of module nf_conntrack_ipv4.
> iptable_nat: Unknown symbol need_ipv4_conntrack
> ----------------8<---------------------------------
> 
> iptables version 1.3.8

If so, the bug could be almost anywhere - in slab, or in some random piece
of code which scribbles on slab's data structures.

> Perfectly repeatable.

If my theory is correct, changing pretty much anything in the kernel config
might just make it go away.  But still, it would be most valuable if you
could try running a bisection search, as described in
http://www.kernel.org/doc/local/git-quick.html, thanks.

