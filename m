From: Andrew Vagin <avagin@parallels.com>
Subject: Re: [PATCH] netfilter: nf_conntrack: fix RCU race in
 nf_conntrack_find_get (v3)
Date: Tue, 14 Jan 2014 14:51:47 +0400
Message-ID: <20140114105147.GA14538@paralelels.com>
References: <1389188841.26646.87.camel@edumazet-glaptop2.roam.corp.google.com>
 <1389549033-23523-1-git-send-email-avagin@openvz.org>
 <1389558074.31367.187.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Andrey Vagin <avagin@openvz.org>,
	<netfilter-devel@vger.kernel.org>, <netfilter@vger.kernel.org>,
	<coreteam@netfilter.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <vvs@openvz.org>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	Cyrill Gorcunov <gorcunov@openvz.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1389558074.31367.187.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 12, 2014 at 12:21:14PM -0800, Eric Dumazet wrote:
> On Sun, 2014-01-12 at 21:50 +0400, Andrey Vagin wrote:
> > Lets look at destroy_conntrack:
> > 
> > hlist_nulls_del_rcu(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode);
> > ...
> > nf_conntrack_free(ct)
> > 	kmem_cache_free(net->ct.nf_conntrack_cachep, ct);
> > 
> > net->ct.nf_conntrack_cachep is created with SLAB_DESTROY_BY_RCU.
> > 
> > The hash is protected by rcu, so readers look up conntracks without
> > locks.
> > A conntrack is removed from the hash, but in this moment a few readers
> > still can use the conntrack. Then this conntrack is released and another
> > thread creates conntrack with the same address and the equal tuple.
> > After this a reader starts to validate the conntrack:
> > * It's not dying, because a new conntrack was created
> > * nf_ct_tuple_equal() returns true.
> ...
> 
> 
> > v2: move nf_ct_is_confirmed into the unlikely() annotation
> > v3: Eric suggested to fix refcnt, so that it becomes zero before adding
> >     in a hash, but we can't find a way how to do that. Another way is to
> >     interpret the confirm bit as part of a search key and check it in
> >     ____nf_conntrack_find() too.
> > 
> > Cc: Eric Dumazet <eric.dumazet@gmail.com>
> > Cc: Florian Westphal <fw@strlen.de>
> > Cc: Pablo Neira Ayuso <pablo@netfilter.org>
> > Cc: Patrick McHardy <kaber@trash.net>
> > Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
> > Cc: "David S. Miller" <davem@davemloft.net>
> > Cc: Cyrill Gorcunov <gorcunov@openvz.org>
> > Signed-off-by: Andrey Vagin <avagin@openvz.org>
> > ---
> 
> Acked-by: Eric Dumazet <edumazet@google.com>
> 
> Thanks Andrey !
> 

Eh, looks like this path is incomplete too:(

I think we can't set a reference counter for objects which is allocated
from a SLAB_DESTROY_BY_RCU cache. Look at the following backtrace.

cpu1					cpu2
ct = ____nf_conntrack_find()
					destroy_conntrack
atomic_inc_not_zero(ct)
					__nf_conntrack_alloc
					atomic_set(&ct->ct_general.use, 1);
if (!nf_ct_key_equal(h, tuple, zone))
nf_ct_put(ct);
  destroy_conntrack(ct) !!!!
					/* continues to use the conntrack */


Did I miss something again?

I think __nf_conntrack_alloc must use atomic_inc instead of
atomic_set. And we must be sure, that the first object from a new page is
zeroized.

I am talking about this, because after this patch a bug was triggered from
another place:

<2>[67096.759353] kernel BUG at net/netfilter/nf_conntrack_core.c:211!
<4>[67096.759371] invalid opcode: 0000 [#1] SMP 
<4>[67096.759385] last sysfs file: /sys/devices/virtual/block/md0/md/metadata_version
<4>[67096.759414] CPU 2 
<4>[67096.759422] Modules linked in: xt_comment sch_sfq cls_fw sch_htb pio_nfs pio_direct pfmt_raw pfmt_ploop1 ploop simfs xt_string xt_hashlimit xt_recent xt_length xt_hl xt_tcpmss xt_TCPMSS xt_multiport xt_limit xt_dscp vzevent coretemp cpufreq_ondemand acpi_cpufreq freq_table mperf 8021q garp stp llc ipt_REJECT iptable_filter iptable_mangle xt_NOTRACK iptable_raw iptable_nat ip_tables ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 xt_state ip6table_filter ip6table_raw xt_MARK ip6table_mangle ip6_tables ext4 jbd2 tun ip_gre ipip vzethdev vznetdev vzrst nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 ipv6 vzcpt nf_conntrack vzdquota vzmon vziolimit vzdev tunnel4 nfsd nfs lockd fscache auth_rpcgss nfs_acl sunrpc tpm_tis tpm tpm_bios microcode serio_raw i2c_i801 sg iTCO_wdt iTCO_vendor_support e1000e
  ext3 jbd mbcache raid1 sd_mod crc_t10dif ata_piix ahci pata_acpi ata_generic i915 drm_kms_helper drm i2c_algo_bit i2c_core video output dm_mirror dm_region_hash dm_log dm_mod [last unloaded: scsi_wait_scan]
<4>[67096.759801] 
<4>[67096.759837] Pid: 498649, comm: atdd veid: 666 Tainted: G         C ---------------    2.6.32-042stab084.18 #1 042stab084_18                  /DQ45CB
<4>[67096.759932] RIP: 0010:[<ffffffffa03d99ac>]  [<ffffffffa03d99ac>] destroy_conntrack+0x15c/0x190 [nf_conntrack]
<4>[67096.760032] RSP: 0000:ffff88001ae378b8  EFLAGS: 00010246
<4>[67096.760075] RAX: 0000000000000000 RBX: ffff8801a57ac928 RCX: 0000000000065000
<4>[67096.760123] RDX: 000000000000f603 RSI: 0000000000000006 RDI: ffff8801a57ac928
<4>[67096.760174] RBP: ffff88001ae378d8 R08: 0000000000000002 R09: ffff8802373b06e0
<4>[67096.760221] R10: 0000000000000001 R11: 0000000000000000 R12: ffff88023928c080
<4>[67096.760255] R13: ffff880237e8c000 R14: 0000000000000002 R15: 0000000000000002
<4>[67096.760255] FS:  0000000000000000(0000) GS:ffff880028300000(0063) knlGS:00000000b63afbb0
<4>[67096.760255] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
<4>[67096.760255] CR2: 00000000b74f44c0 CR3: 00000000b89c6000 CR4: 00000000000007e0
<4>[67096.760255] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
<4>[67096.760255] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
<4>[67096.760255] Process atdd (pid: 498649, veid: 666, threadinfo ffff88001ae36000, task ffff88001deaa980)
<4>[67096.760255] Stack:
<4>[67096.760255]  ffff88001ae378e8 ffff88001ae37988 ffff88023928c080 0000000000000003
<4>[67096.760255] <d> ffff88001ae378e8 ffffffff814844a7 ffff88001ae37908 ffffffffa03d9bb5
<4>[67096.760255] <d> ffff88012dcae580 ffff88023928c080 ffff88001ae379e8 ffffffffa03d9fb2
<4>[67096.760255] Call Trace:
<4>[67096.760255]  [<ffffffff814844a7>] nf_conntrack_destroy+0x17/0x30
<4>[67096.760255]  [<ffffffffa03d9bb5>] nf_conntrack_find_get+0x85/0x130 [nf_conntrack]
<4>[67096.760255]  [<ffffffffa03d9fb2>] nf_conntrack_in+0x352/0xb60 [nf_conntrack]
<4>[67096.760255]  [<ffffffffa048c771>] ipv4_conntrack_local+0x51/0x60 [nf_conntrack_ipv4]
<4>[67096.760255]  [<ffffffff81484419>] nf_iterate+0x69/0xb0
<4>[67096.760255]  [<ffffffff814b5b00>] ? dst_output+0x0/0x20
<4>[67096.760255]  [<ffffffff814845d4>] nf_hook_slow+0x74/0x110
<4>[67096.760255]  [<ffffffff814b5b00>] ? dst_output+0x0/0x20
<4>[67096.760255]  [<ffffffff814b66d5>] raw_sendmsg+0x775/0x910
<4>[67096.760255]  [<ffffffff8104c5a8>] ? flush_tlb_others_ipi+0x128/0x130
<4>[67096.760255]  [<ffffffff8100bc4e>] ? apic_timer_interrupt+0xe/0x20
<4>[67096.760255]  [<ffffffff8100bc4e>] ? apic_timer_interrupt+0xe/0x20
<4>[67096.760255]  [<ffffffff814c136a>] inet_sendmsg+0x4a/0xb0
<4>[67096.760255]  [<ffffffff81444e93>] ? sock_sendmsg+0x13/0x140
<4>[67096.760255]  [<ffffffff81444f97>] sock_sendmsg+0x117/0x140
<4>[67096.760255]  [<ffffffff8102e299>] ? native_smp_send_reschedule+0x49/0x60
<4>[67096.760255]  [<ffffffff81519beb>] ? _spin_unlock_bh+0x1b/0x20
<4>[67096.760255]  [<ffffffff8109d930>] ? autoremove_wake_function+0x0/0x40
<4>[67096.760255]  [<ffffffff814960f0>] ? do_ip_setsockopt+0x90/0xd80
<4>[67096.760255]  [<ffffffff8100bc4e>] ? apic_timer_interrupt+0xe/0x20
<4>[67096.760255]  [<ffffffff8100bc4e>] ? apic_timer_interrupt+0xe/0x20
<4>[67096.760255]  [<ffffffff814457c9>] sys_sendto+0x139/0x190
<4>[67096.760255]  [<ffffffff810efa77>] ? audit_syscall_entry+0x1d7/0x200
<4>[67096.760255]  [<ffffffff810ef7c5>] ? __audit_syscall_exit+0x265/0x290
<4>[67096.760255]  [<ffffffff81474daf>] compat_sys_socketcall+0x13f/0x210
<4>[67096.760255]  [<ffffffff8104dea3>] ia32_sysret+0x0/0x5
<4>[67096.760255] Code: 0b ab 0a e1 eb b7 f6 05 34 f8 00 e2 20 74 b7 80 3d f0 b0 00 00 00 74 ae 48 89 de 48 c7 c7 20 16 3e a0 31 c0 e8 05 ca 13 e1 eb 9b <0f> 0b eb fe f6 05 0b f8 00 e2 20 0f 84 db fe ff ff 80 3d eb b0 
<1>[67096.760255] RIP  [<ffffffffa03d99ac>] destroy_conntrack+0x15c/0x190 [nf_conntrack]
<4>[67096.760255]  RSP <ffff88001ae378b8>
