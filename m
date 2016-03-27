From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: Re: BUG: net/netfilter: KASAN: stack-out-of-bounds in tcp_packet
Date: Mon, 28 Mar 2016 00:25:59 +0200 (CEST)
Message-ID: <alpine.DEB.2.10.1603280024160.19777@blackhole.kfki.hu>
References: <56F7D3AD.10003@gmail.com> <alpine.DEB.2.10.1603280010120.19633@blackhole.kfki.hu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Baozeng Ding <sploving1@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.10.1603280010120.19633@blackhole.kfki.hu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 28 Mar 2016, Jozsef Kadlecsik wrote:

> On Sun, 27 Mar 2016, Baozeng Ding wrote:
> 
> > The following program triggers stack-out-of-bounds in tcp_packet. The
> > kernel version is 4.5 (on Mar 16 commit
> > 09fd671ccb2475436bd5f597f751ca4a7d177aea).
> > Uncovered with syzkaller. Thanks.
> > 
> > ==================================================================
> > BUG: KASAN: stack-out-of-bounds in tcp_packet+0x4b77/0x51c0 at addr
> > ffff8800a45df3c8
> > Read of size 1 by task 0327/11132
> > page:ffffea00029177c0 count:0 mapcount:0 mapping:          (null) index:0x0
> > flags: 0x1fffc0000000000()
> > page dumped because: kasan: bad access detected
> > CPU: 1 PID: 11132 Comm: 0327 Tainted: G    B           4.5.0+ #12
> > Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS
> > rel-1.8.2-0-g33fbe13 by qemu-project.org 04/01/2014
> >  0000000000000001 ffff8800a45df148 ffffffff82945051 ffff8800a45df1d8
> >  ffff8800a45df3c8 0000000000000027 0000000000000001 ffff8800a45df1c8
> >  ffffffff81709f88 ffff8800b4f7e3d0 0000000000000028 0000000000000286
> > Call Trace:
> > [<     inline     >] __dump_stack /kernel/lib/dump_stack.c:15
> > [<ffffffff82945051>] dump_stack+0xb3/0x112 /kernel/lib/dump_stack.c:51
> > [<     inline     >] print_address_description /kernel/mm/kasan/report.c:150
> > [<ffffffff81709f88>] kasan_report_error+0x4f8/0x530
> > /kernel/mm/kasan/report.c:236
> > [<ffffffff84c54b8d>] ? skb_copy_bits+0x49d/0x6d0
> > /kernel/net/core/skbuff.c:1675
> > [<     inline     >] ? spin_lock_bh /kernel/include/linux/spinlock.h:307
> > [<ffffffff84e0e9b9>] ? tcp_packet+0x1c9/0x51c0
> > /kernel/net/netfilter/nf_conntrack_proto_tcp.c:833
> > [<     inline     >] kasan_report /kernel/mm/kasan/report.c:259
> > [<ffffffff81709ffe>] __asan_report_load1_noabort+0x3e/0x40
> > /kernel/mm/kasan/report.c:277
> > [<     inline     >] ? tcp_sack
> > /kernel/net/netfilter/nf_conntrack_proto_tcp.c:473
> > [<     inline     >] ? tcp_in_window
> > /kernel/net/netfilter/nf_conntrack_proto_tcp.c:527
> > [<ffffffff84e13367>] ? tcp_packet+0x4b77/0x51c0
> > /kernel/net/netfilter/nf_conntrack_proto_tcp.c:1036
> > [<     inline     >] tcp_sack
> > /kernel/net/netfilter/nf_conntrack_proto_tcp.c:473
> > [<     inline     >] tcp_in_window
> > /kernel/net/netfilter/nf_conntrack_proto_tcp.c:527
> > [<ffffffff84e13367>] tcp_packet+0x4b77/0x51c0
> > /kernel/net/netfilter/nf_conntrack_proto_tcp.c:1036
> > [<ffffffff817094b8>] ? memset+0x28/0x30 /kernel/mm/kasan/kasan.c:302
> > [<ffffffff84e0dd74>] ? tcp_new+0x1a4/0xc20
> > /kernel/net/netfilter/nf_conntrack_proto_tcp.c:1122
> > [<     inline     >] ? build_report /kernel/include/net/netlink.h:499
> > [<ffffffff8518c4d6>] ? xfrm_send_report+0x426/0x450
> > /kernel/net/xfrm/xfrm_user.c:3039
> > [<ffffffff84e0e7f0>] ? tcp_new+0xc20/0xc20
> > /kernel/net/netfilter/nf_conntrack_proto_tcp.c:1169
> > [<ffffffff84dfb03a>] ? init_conntrack+0xca/0x9e0
> > /kernel/net/netfilter/nf_conntrack_core.c:972
> > [<ffffffff84dfaf70>] ? nf_conntrack_alloc+0x40/0x40
> > /kernel/net/netfilter/nf_conntrack_core.c:903
> > [<ffffffff84e0cdf0>] ? tcp_init_net+0x6e0/0x6e0
> > /kernel/include/net/netfilter/nf_conntrack_l4proto.h:137
> > [<ffffffff85121732>] ? ipv4_get_l4proto+0x262/0x390
> > /kernel/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c:89
> > [<ffffffff84df372f>] ? nf_ct_get_tuple+0xaf/0x190
> > /kernel/net/netfilter/nf_conntrack_core.c:197
> > [<ffffffff84dfc23e>] nf_conntrack_in+0x8ee/0x1170
> > /kernel/net/netfilter/nf_conntrack_core.c:1177
> > [<ffffffff84dfb950>] ? init_conntrack+0x9e0/0x9e0
> > /kernel/net/netfilter/nf_conntrack_core.c:287
> > [<ffffffff8512ab06>] ? ipt_do_table+0xa16/0x1260
> > /kernel/net/ipv4/netfilter/ip_tables.c:423
> > [<ffffffff81405ced>] ? trace_hardirqs_on+0xd/0x10
> > /kernel/kernel/locking/lockdep.c:2635
> > [<ffffffff81311fcb>] ? __local_bh_enable_ip+0x6b/0xc0
> > /kernel/kernel/softirq.c:175
> > [<ffffffff8512a0f0>] ? check_entry.isra.4+0x190/0x190
> > /kernel/net/ipv6/netfilter/ip6_tables.c:594
> > [<ffffffff84f9d4e0>] ? ip_reply_glue_bits+0xc0/0xc0
> > /kernel/net/ipv4/ip_output.c:1530
> > [<ffffffff851219ae>] ipv4_conntrack_local+0x14e/0x1a0
> > /kernel/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c:161
> > [<ffffffff85131b3d>] ? iptable_raw_hook+0x9d/0x1e0
> > /kernel/net/ipv4/netfilter/iptable_raw.c:32
> > [<ffffffff84de5b7d>] nf_iterate+0x15d/0x230 /kernel/net/netfilter/core.c:274
> > [<ffffffff84de5c50>] ? nf_iterate+0x230/0x230 /kernel/net/netfilter/core.c:268
> > [<ffffffff84de5dfd>] nf_hook_slow+0x1ad/0x310 /kernel/net/netfilter/core.c:306
> > [<ffffffff84de5c50>] ? nf_iterate+0x230/0x230 /kernel/net/netfilter/core.c:268
> > [<ffffffff84de5c50>] ? nf_iterate+0x230/0x230 /kernel/net/netfilter/core.c:268
> > [<ffffffff82979274>] ? prandom_u32+0x24/0x30 /kernel/lib/random32.c:83
> > [<ffffffff84f747ff>] ? ip_idents_reserve+0x9f/0xf0
> > /kernel/net/ipv4/route.c:484
> > [<     inline     >] nf_hook_thresh /kernel/include/linux/netfilter.h:187
> > [<     inline     >] nf_hook /kernel/include/linux/netfilter.h:197
> > [<ffffffff84fa4f53>] __ip_local_out+0x263/0x3c0
> > /kernel/net/ipv4/ip_output.c:104
> > [<ffffffff84fa4cf0>] ? ip_finish_output+0xd00/0xd00
> > /kernel/include/net/ip.h:322
> > [<ffffffff84fa0230>] ? __ip_flush_pending_frames.isra.45+0x2e0/0x2e0
> > /kernel/net/ipv4/ip_output.c:1337
> > [<ffffffff84faa336>] ? __ip_make_skb+0xfe6/0x1610
> > /kernel/net/ipv4/ip_output.c:1436
> > [<ffffffff84fa50dd>] ip_local_out+0x2d/0x1c0 /kernel/net/ipv4/ip_output.c:113
> > [<ffffffff84faa99c>] ip_send_skb+0x3c/0xc0 /kernel/net/ipv4/ip_output.c:1443
> > [<ffffffff84faaa84>] ip_push_pending_frames+0x64/0x80
> > /kernel/net/ipv4/ip_output.c:1463
> > [<     inline     >] rcu_read_unlock /kernel/include/linux/rcupdate.h:922
> > [<ffffffff8504e10b>] raw_sendmsg+0x17bb/0x25c0
> > /kernel/net/ieee802154/socket.c:53
> > [<ffffffff8504c950>] ? dst_output+0x190/0x190 /kernel/include/net/dst.h:492
> > [<     inline     >] ? trace_mm_page_alloc
> > /kernel/include/trace/events/kmem.h:217
> > [<ffffffff81621609>] ? __alloc_pages_nodemask+0x559/0x16b0
> > /kernel/mm/page_alloc.c:3368
> > [<ffffffff81406260>] ? debug_check_no_locks_freed+0x290/0x290
> > /kernel/kernel/locking/lockdep.c:4104
> > [<ffffffff814c0e30>] ? is_module_text_address+0x10/0x20
> > /kernel/kernel/module.c:4057
> > [<ffffffff81360533>] ? __kernel_text_address+0x73/0xa0
> > /kernel/kernel/extable.c:103
> > [<ffffffff81406260>] ? debug_check_no_locks_freed+0x290/0x290
> > /kernel/kernel/locking/lockdep.c:4104
> > [<ffffffff81406260>] ? debug_check_no_locks_freed+0x290/0x290
> > /kernel/kernel/locking/lockdep.c:4104
> > [<ffffffff81405ced>] ? trace_hardirqs_on+0xd/0x10
> > /kernel/kernel/locking/lockdep.c:2635
> > [<ffffffff81406260>] ? debug_check_no_locks_freed+0x290/0x290
> > /kernel/kernel/locking/lockdep.c:4104
> > [<     inline     >] ? sock_rps_record_flow /kernel/include/net/sock.h:874
> > [<ffffffff85089113>] ? inet_sendmsg+0x73/0x4c0 /kernel/net/ipv4/af_inet.c:729
> > [<     inline     >] ? rcu_read_unlock /kernel/include/linux/rcupdate.h:922
> > [<     inline     >] ? sock_rps_record_flow_hash
> > /kernel/include/net/sock.h:867
> > [<     inline     >] ? sock_rps_record_flow /kernel/include/net/sock.h:874
> > [<ffffffff8508929a>] ? inet_sendmsg+0x1fa/0x4c0 /kernel/net/ipv4/af_inet.c:729
> > [<ffffffff85089395>] inet_sendmsg+0x2f5/0x4c0 /kernel/net/ipv4/af_inet.c:736
> > [<     inline     >] ? sock_rps_record_flow /kernel/include/net/sock.h:874
> > [<ffffffff85089113>] ? inet_sendmsg+0x73/0x4c0 /kernel/net/ipv4/af_inet.c:729
> > [<ffffffff850890a0>] ? inet_recvmsg+0x4a0/0x4a0
> > /kernel/include/linux/compiler.h:222
> > [<     inline     >] sock_sendmsg_nosec /kernel/net/socket.c:611
> > [<ffffffff84c3434a>] sock_sendmsg+0xca/0x110 /kernel/net/socket.c:621
> > [<ffffffff84c35448>] SYSC_sendto+0x208/0x350 /kernel/net/socket.c:1651
> > [<ffffffff84c35240>] ? SYSC_connect+0x2e0/0x2e0 /kernel/net/socket.c:1543
> > [<ffffffff81698650>] ? __pmd_alloc+0x350/0x350 /kernel/mm/memory.c:3928
> > [<ffffffff81230b3b>] ? __do_page_fault+0x2ab/0x8e0
> > /kernel/arch/x86/mm/fault.c:1184
> > [<ffffffff81230c30>] ? __do_page_fault+0x3a0/0x8e0
> > /kernel/arch/x86/mm/fault.c:1271
> > [<ffffffff813fb5da>] ? up_read+0x1a/0x40 /kernel/kernel/locking/rwsem.c:79
> > [<ffffffff81230a29>] ? __do_page_fault+0x199/0x8e0
> > /kernel/arch/x86/mm/fault.c:1187
> > [<ffffffff84c379b0>] SyS_sendto+0x40/0x50 /kernel/net/socket.c:1619
> > [<ffffffff85dab940>] entry_SYSCALL_64_fastpath+0x23/0xc1
> > /kernel/arch/x86/entry/entry_64.S:207
> > Memory state around the buggy address:
> >  ffff8800a45df280: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> >  ffff8800a45df300: f1 f1 f1 f1 00 00 04 f4 f2 f2 f2 f2 00 00 04 f4
> > > ffff8800a45df380: f2 f2 f2 f2 00 00 00 00 00 f4 f4 f4 f3 f3 f3 f3
> >                                               ^
> >  ffff8800a45df400: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> >  ffff8800a45df480: 00 00 00 00 00 00 00 00 f1 f1 f1 f1 01 f4 f4 f4
> > ==================================================================
> > 
> > #include <unistd.h>
> > #include <sys/syscall.h>
> > #include <string.h>
> > #include <stdint.h>
> > #include <pthread.h>
> > #include <sys/socket.h>
> > #include <sys/mman.h>
> > #include <netinet/in.h>
> > int main()
> > {
> >         mmap((void *)0x20000000ul, 0x19000ul, PROT_READ|PROT_WRITE,
> > MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0);
> >         int sock = socket(AF_INET, SOCK_RAW, IPPROTO_TCP);
> >         int sock_dup = dup(sock);
> >         memcpy((void*)0x2000b000,
> > "\x11\xaf\x7d\x99\x91\x3c\x87\x34\x85\x18\xc4\xd6\xf2\x30\x0a", 15);
> >         *(uint16_t*)0x20002fec = (uint16_t)0x2;
> >         *(uint16_t*)0x20002fee = (uint16_t)0x11ab;
> >         *(uint32_t*)0x20002ff0 = (uint32_t)0x100007f;
> >         sendto(sock_dup, (void *)0x2000b000ul, 0xful, 0x8800ul, (struct
> > sockaddr *)0x20002fe4ul, 0x1cul);
> >         memcpy((void*)0x2001504f,
> > "\x7e\xb1\x52\x5b\x78\x85\x27\xe7\xcc\x3d\xf5\x18\x1b\xba\xda\x97\x6c\x18\x72\x0c\xd2\x0a\xa6\x77\xb7\x8b\xa2\xd2\x1d\xf0\x6b\xf6\x1a\x27\x6b\x98\x3e\x0b\x49\x8d\x54\x6e\x9e\xbb\x21\x4a\x72\x79\x1f\x82\xaf\x89\x2c\xf6\xd3\xc9\xd7\xed\x18\x29\x4d\x2e\x03\x15\xe2\x03\x14\xd0\xac\xa5\x81\x37\x73\x88\xa9\xf5\x08\xe5\xef\x5b\x56\xb7\x18\x8f\xe6\x19\xea\x91\x82\x23\xdd\x2c\x5c\xa5\xf0\xfc\xd8\xe2\x8b\x91\x48\x70\x24\xed\xae\xf9\x06\xac\xc4\x53\x01\xc3\xf5\xa3\x10\xef\xf1\xa6\x2b\xae\x72\xc7\x1a\x02\xee\x78\xcd\xd1\x7e\x8c\x9c\x1a\x36\xc7\xd4\x7c\x82\x64\xf7\x8b\x5a\xb0\x72\xa8\x87\x3c\xdc\xd0\xba\xfe\x70\x7d\x8c\x23\x78\xad\x7c\x31\x04\xec\xab\x1e\x4c\xee\xae\x84\xd8\x1a\x1d\x85\xa5\x57\xa8\x24\x53\x08\x1c\x4f\xda\x49\xe5\x3a\x99\x8c\x29\xa1\xed\x4b\x42\x7a\x15\x48\x2a\x22\x3b\x81\xfe\x47\x7
 4\xc1\x2f\x64\xcf\x10\xd4\x71\x72\x50\x71\xd7\xf6\xb0\xca\x41\x9a\x5e\x3e\xe4\x31\x19\xd1\x19\x46\x20\x66\x4c\x2f\xea\x76\x17\x2d\x94",
> > 232);
> >         *(uint16_t*)0x2001501c = (uint16_t)0xa;
> >         *(uint16_t*)0x2001501e = (uint16_t)0x11ab;
> >         *(uint32_t*)0x20015020 = (uint32_t)0xbdc;
> >         *(uint32_t*)0x20015024 = (uint32_t)0x0;
> >         *(uint32_t*)0x20015028 = (uint32_t)0x0;
> >         *(uint32_t*)0x2001502c = (uint32_t)0x0;
> >         *(uint32_t*)0x20015030 = (uint32_t)0x1000000;
> >         *(uint32_t*)0x20015034 = (uint32_t)0x3;
> >         sendto(sock_dup, (void *)0x2001504ful, 0xe8ul, 0x880ul, (struct
> > sockaddr *)0x20015000ul, 0x1cul);
> >         return 0;
> > }

Actually, in order to fix the non-conntrack case too, I believe the next 
patch is required:

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index d4c5115..365f4fb 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3716,6 +3716,8 @@ void tcp_parse_options(const struct sk_buff *skb,
 			length--;
 			continue;
 		default:
+			if (length < 2)
+				return;
 			opsize = *ptr++;
 			if (opsize < 2) /* "silly options" */
 				return;
@@ -3873,6 +3875,8 @@ const u8 *tcp_parse_md5sig_option(const struct tcphdr *th)
 			length--;
 			continue;
 		default:
+			if (length < 2)
+				return;
 			opsize = *ptr++;
 			if (opsize < 2 || opsize > length)
 				return NULL;
diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index 278f3b9..7cc1d9c 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -410,6 +410,8 @@ static void tcp_options(const struct sk_buff *skb,
 			length--;
 			continue;
 		default:
+			if (length < 2)
+				return;
 			opsize=*ptr++;
 			if (opsize < 2) /* "silly options" */
 				return;
@@ -470,6 +472,8 @@ static void tcp_sack(const struct sk_buff *skb, unsigned int dataoff,
 			length--;
 			continue;
 		default:
+			if (length < 2)
+				return;
 			opsize = *ptr++;
 			if (opsize < 2) /* "silly options" */
 				return;

Best regards,
Jozsef
-
E-mail  : kadlec@blackhole.kfki.hu, kadlecsik.jozsef@wigner.mta.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : Wigner Research Centre for Physics, Hungarian Academy of Sciences
          H-1525 Budapest 114, POB. 49, Hungary
