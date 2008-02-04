From: Ivan Dichev <idichev@obs.bg>
Subject: Re: Slow OOM in netif_RX function
Date: Mon, 04 Feb 2008 16:54:56 +0200
Message-ID: <47A72740.9030706@obs.bg>
References: <4798CAA9.1080005@obs.bg> <4798E32E.6080003@cosmosbay.com> <20080124211810.3E24A46E9A@smtp.obs.bg> <p73tzl282ij.fsf@bingen.suse.de> <20080125141204.GA25510@ghostprotocols.net> <47A315DC.3070101@obs.bg> <47A31BBA.8040307@cosmosbay.com> <47A33D02.8050503@obs.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from obs.bg ([213.91.169.3]:48544 "EHLO smtp.obs.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750835AbYBDOy7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Feb 2008 09:54:59 -0500
In-Reply-To: <47A33D02.8050503@obs.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Thanks again for your help...

Here's more debug info (long email !):

We installed crash, compiled a kernel with debug symbols, dumped all the
allocated size-2048 slabs, waited some time, and re-dumped them. Then we
compared both dumps: we assumed that slab dumps which were not modified
could be considered as leaks (see end of mail for commands we used).

>From the 3c59x driver source, boomerang_rx() has only a "struct
net_device" as argument, so the idea was to take a dumped slab that
looked like a leak, remove any offset, and "apply" a struct net_device
to the dumped slab data. Then we could have a clue on which interface
the problem happens, and dig deeper to find - say - the packet ip header.

Result: none of the "leaked" slabs seem to match struct net_device.
"Valid" slabs are found in the dumps though, but not in the leaked one.

Example:

a valid slab hexdump:

c0 88 56 63 c5 56 41 d8  00 00 00 00 00 00 00 00  |..Vc.VA.........|
00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
65 74 68 32 00 00 00 00  00 00 00 00 00 00 00 00  |eth2............|
00 00 00 00 28 6f 37 c0  00 00 00 00 00 00 00 00  |....(o7.........|
00 20 82 d0 0c 00 00 00  08 00 00 00 06 00 00 00  |. ..............|
[...]

There seems to be a 32 byts slab header, then struct net_device which
begins with a 16 bytes interface name (here eth2). If we "apply" a
struct net_device, we can also find the irq, in this case 12, which is
the correct value on our machine.


Now, with a "leaked" slab:

c0 88 56 63 c5 56 41 d8  5a 5a 5a 5a 5a 5a 5a 5a  |..Vc.VA.ZZZZZZZZ|
5a 5a 5a 5a 5a 5a 5a 5a  5a 5a 00 0a 5e 5d cf 88  |ZZZZZZZZZZ..^]..|
00 11 20 da 91 01 08 00  45 20 05 d8 5e de 00 00  |.. .....E ..^...|
38 32 00 00 d5 5b 97 c2  55 5f 42 32 61 14 cd 3b  |82...[..U_B2a..;|
[...]

Nothing that looks like a struct net_device. All the dumped leaked slab
look the same until "45 20 05 d8" (the ascii 'E' on the 3rd line).


It took quite a bit of time to dig that far (for non kernel experts like
us!), and we're now out of ideas. Is it possible to have something else
than a struct net_device for boomerang_rx() ? Any idea ? Writing a patch
with the ideas mentioned before in this thread is above my level...


Things are also quite weird since we don't seem to have this problem on
two other similar machines (one 100% identical with less traffic, and
another one with the same distro/soft but different hardware).
Also note that all the machines use the out-of-tree openswan ipsec.ko
module, but it doesn't seem to be the problem since the other 2 machines
don't leak, and we didn't find any correlation between plotted IKE
packets / VPN traffic against slab leaks.

Another weird fact is that the leak increase is somewhat correlated to
network traffic - it grows slowly - but there are huge steps (ie. 1000+
more slabs in a few minutes) that are not bound to any traffic peak; if
needed, I can upload the graphs somewhere.

Some other things that might be useful: when we switched from 2.6.16.x
to 2.6.23.14, we began to have "eth1: Too much work in interrupt, status
8401" messages. Playing with 3c59x driver option "max_interrupt_work"
didn't help.

When doing tests with a kernel with slub instead of slab and misc
changes - I think we tried tickless, but not sure - we also got the
following oopses (once):

swapper: page allocation failure. order:1, mode:0x4020
 [<c0136e1a>] __alloc_pages+0x295/0x2a4
 [<c0149a77>] allocate_slab+0x59/0x96
 [<c0149b05>] new_slab+0x32/0x126
 [<c014982a>] alloc_debug_processing+0xcf/0x10c
 [<c0149eee>] __slab_alloc+0x80/0xdb
 [<d088731f>] boomerang_rx+0x30d/0x40d [3c59x]
 [<d088731f>] boomerang_rx+0x30d/0x40d [3c59x]
 [<c014ada5>] __kmalloc_track_caller+0x44/0x91
 [<d088731f>] boomerang_rx+0x30d/0x40d [3c59x]
 [<c021ee94>] __alloc_skb+0x46/0xef
 [<d088731f>] boomerang_rx+0x30d/0x40d [3c59x]
 [<d0886b0d>] boomerang_interrupt+0x11e/0x324 [3c59x]
 [<c011295b>] profile_tick+0x38/0x52
 [<c0131c31>] handle_IRQ_event+0x1a/0x3f
 [<c0132782>] handle_level_irq+0x0/0x85
 [<c01327d2>] handle_level_irq+0x50/0x85
 [<c010356e>] do_IRQ+0x7d/0xa3
 [<c010cc7e>] update_stats_wait_end+0xa5/0xc2
 [<c0102547>] common_interrupt+0x23/0x28
 [<c010083c>] default_idle+0x0/0x39
 [<c0100863>] default_idle+0x27/0x39
 [<c01008bc>] cpu_idle+0x44/0x60
 [<c031c7b5>] start_kernel+0x1cd/0x1d1
 [<c031c33f>] unknown_bootoption+0x0/0x139


swapper: page allocation failure. order:1, mode:0x4020
 [<c0136e1a>] __alloc_pages+0x295/0x2a4
 [<c0149a77>] allocate_slab+0x59/0x96
 [<c0149b05>] new_slab+0x32/0x126
 [<c014982a>] alloc_debug_processing+0xcf/0x10c
 [<c0149eee>] __slab_alloc+0x80/0xdb
 [<d088731f>] boomerang_rx+0x30d/0x40d [3c59x]
 [<d088731f>] boomerang_rx+0x30d/0x40d [3c59x]
 [<c014ada5>] __kmalloc_track_caller+0x44/0x91
 [<d088731f>] boomerang_rx+0x30d/0x40d [3c59x]
 [<c021ee94>] __alloc_skb+0x46/0xef
 [<d088731f>] boomerang_rx+0x30d/0x40d [3c59x]
 [<d0886b0d>] boomerang_interrupt+0x11e/0x324 [3c59x]
 [<c0131c31>] handle_IRQ_event+0x1a/0x3f
 [<c01327d2>] handle_level_irq+0x50/0x85
 [<c0103579>] do_IRQ+0x88/0xa3
 [<c0102547>] common_interrupt+0x23/0x28
 [<c0131c2d>] handle_IRQ_event+0x16/0x3f
 [<c01327d2>] handle_level_irq+0x50/0x85
 [<c0103579>] do_IRQ+0x88/0xa3
 [<c0102547>] common_interrupt+0x23/0x28
 [<c0131c2d>] handle_IRQ_event+0x16/0x3f
 [<c01327d2>] handle_level_irq+0x50/0x85
 [<c0103579>] do_IRQ+0x88/0xa3
 [<c0149a77>] allocate_slab+0x59/0x96
 [<c0102547>] common_interrupt+0x23/0x28
 [<c014adb7>] __kmalloc_track_caller+0x56/0x91
 [<d088731f>] boomerang_rx+0x30d/0x40d [3c59x]
 [<c021ee94>] __alloc_skb+0x46/0xef
 [<d088731f>] boomerang_rx+0x30d/0x40d [3c59x]
 [<d0886b0d>] boomerang_interrupt+0x11e/0x324 [3c59x]
 [<c011295b>] profile_tick+0x38/0x52
 [<c0131c31>] handle_IRQ_event+0x1a/0x3f
 [<c0132782>] handle_level_irq+0x0/0x85
 [<c01327d2>] handle_level_irq+0x50/0x85
 [<c010356e>] do_IRQ+0x7d/0xa3
 [<c010cc7e>] update_stats_wait_end+0xa5/0xc2
 [<c0102547>] common_interrupt+0x23/0x28
 [<c010083c>] default_idle+0x0/0x39
 [<c0100863>] default_idle+0x27/0x39
 [<c01008bc>] cpu_idle+0x44/0x60
 [<c031c7b5>] start_kernel+0x1cd/0x1d1
 [<c031c33f>] unknown_bootoption+0x0/0x139

swapper: page allocation failure. order:1, mode:0x4020
 [<c0136e1a>] __alloc_pages+0x295/0x2a4
 [<c0149a77>] allocate_slab+0x59/0x96
 [<c0149b05>] new_slab+0x32/0x126
 [<c014982a>] alloc_debug_processing+0xcf/0x10c
 [<c0149eee>] __slab_alloc+0x80/0xdb
 [<d088731f>] boomerang_rx+0x30d/0x40d [3c59x]
 [<d088731f>] boomerang_rx+0x30d/0x40d [3c59x]
 [<c014ada5>] __kmalloc_track_caller+0x44/0x91
 [<d088731f>] boomerang_rx+0x30d/0x40d [3c59x]
 [<c021ee94>] __alloc_skb+0x46/0xef
 [<d088731f>] boomerang_rx+0x30d/0x40d [3c59x]
 [<d0886b0d>] boomerang_interrupt+0x11e/0x324 [3c59x]
 [<c011295b>] profile_tick+0x38/0x52
 [<c0131c31>] handle_IRQ_event+0x1a/0x3f
 [<c0132782>] handle_level_irq+0x0/0x85
 [<c01327d2>] handle_level_irq+0x50/0x85
 [<c010356e>] do_IRQ+0x7d/0xa3
 [<c010cc7e>] update_stats_wait_end+0xa5/0xc2
 [<c0102547>] common_interrupt+0x23/0x28
 [<c010083c>] default_idle+0x0/0x39
 [<c0100863>] default_idle+0x27/0x39
 [<c01008bc>] cpu_idle+0x44/0x60
 [<c031c7b5>] start_kernel+0x1cd/0x1d1
 [<c031c33f>] unknown_bootoption+0x0/0x139


(I'm wondering what's the unknown_bootoption; ours are "ro root=/dev/md1
nousb panic=10").


Slab dump commands:

# in crash:
 kmem -S size-2048 > kmem_S

# in another shell:
 awk -f extract_slabs.awk kmem_S > dump_cmds

# in crash:
 source dump_cmds

then redo a dump later and find the same slabs; these should be leaks:

for i in $(ls memdump/); do
        [ -f memdump1/$i ] || continue
        cmp -s memdump/$i memdump1/$i || continue
        echo $i
done > same_slabs



extract_slabs.awk:
/ *\[[a-f0-9]+\] */ {
        beg_hex = strtonum(gensub(/ *\[([a-f0-9]+)\] */, "0x\\1", "g",
$1));
        printf("dump memory /home/slab_analysis/memdump/memdump-%x 0x%x
0x%x\n", beg_hex, beg_hex, beg_hex + 2072);
}


Ivan Dichev
