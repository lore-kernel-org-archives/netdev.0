From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net: use after free in ip6_make_skb
Date: Sat, 28 Nov 2015 09:10:19 -0800
Message-ID: <1448730619.24696.93.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5659D757.4040108@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>
To: Sasha Levin <sasha.levin@oracle.com>,
	Vlad Yasevich <vyasevich@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5659D757.4040108@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2015-11-28 at 11:33 -0500, Sasha Levin wrote:
> Hi,
> 
> Fuzzing with syzkaller on the latest -next kernel produced this error:
> 
> [  891.389013] ==================================================================
> 
> [  891.390006] BUG: KASAN: use-after-free in ip6_make_skb+0x106/0x3d0 at addr ffff8806e9773a34
> 
> [  891.393459] Read of size 2 by task syzkaller_execu/8350
> 
> [  891.394128] =============================================================================
> 
> [  891.395121] BUG kmalloc-64 (Not tainted): kasan: bad access detected
> 
> [  891.395886] -----------------------------------------------------------------------------
> 
> [  891.395886]
> 
> [  891.398479] Disabling lock debugging due to kernel taint
> 
> [  891.399156] INFO: Allocated in p9pdu_vreadf+0x7d4/0x1da0 age=2 cpu=12 pid=8331
> 
> [  891.400255] 	___slab_alloc+0x434/0x5b0
> 
> [  891.400917] 	__slab_alloc.isra.37+0x79/0xd0
> 
> [  891.401642] 	__kmalloc+0x12f/0x390
> 
> [  891.402172] 	pipe_fcntl+0x195/0x4c0
> 
> [  891.402743] 	SyS_fcntl+0xd70/0xe50
> 
> [  891.403162] 	entry_SYSCALL_64_fastpath+0x35/0x9e
> 
> [  891.403715] INFO: Freed in kfree_put_link+0x1a/0x20 age=6 cpu=12 pid=8331
> 
> [  891.404349] 	__slab_free+0x5c/0x2b0
> 
> [  891.404665] 	kfree+0x281/0x2f0
> 
> [  891.404915] 	kfree_put_link+0x1a/0x20
> 
> [  891.405201] 	path_openat+0x391f/0x5040
> 
> [  891.405508] 	do_filp_open+0x1b8/0x250
> 
> [  891.405814] 	do_open_execat+0x105/0x4d0
> 
> [  891.406295] 	open_exec+0x3b/0x60
> 
> [  891.406802] INFO: Slab 0xffffea001ba5dc00 objects=41 used=20 fp=0xffff8806e9773a30 flags=0x2fffff80004080
> 
> [  891.407978] INFO: Object 0xffff8806e9773a30 @offset=14896 fp=0xffff8806e9772028
> 
> [  891.407978]
> 
> [  891.408888] Bytes b4 ffff8806e9773a20: e3 07 05 00 01 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a  ........ZZZZZZZZ
> 
> [  891.410121] Object ffff8806e9773a30: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> 
> [  891.411425] Object ffff8806e9773a40: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> 
> [  891.412603] Object ffff8806e9773a50: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> 
> [  891.413775] Object ffff8806e9773a60: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5  kkkkkkkkkkkkkkk.
> 
> [  891.414977] Redzone ffff8806e9773a70: bb bb bb bb bb bb bb bb                          ........
> 
> [  891.416092] Padding ffff8806e9773bb0: 5a 5a 5a 5a 5a 5a 5a 5a                          ZZZZZZZZ
> 
> [  891.417221] CPU: 7 PID: 8350 Comm: syzkaller_execu Tainted: G    B           4.4.0-rc2-next-20151126-sasha-00007-g7083bec-dirty #2655
> 
> [  891.424771] Call Trace:
> 
> [  891.425454] dump_stack (lib/dump_stack.c:52)
> [  891.426433] print_trailer (mm/slub.c:655)
> [  891.427482] object_err (mm/slub.c:662)
> [  891.428495] kasan_report_error (mm/kasan/report.c:138 mm/kasan/report.c:236)
> [  891.430825] __asan_report_load2_noabort (mm/kasan/report.c:278)
> [  891.432908] ip6_make_skb (net/ipv6/ip6_output.c:1757)
> [  891.446294] udpv6_sendmsg (include/linux/err.h:40 net/ipv6/udp.c:1319)
> [  891.461731] inet_sendmsg (net/ipv4/af_inet.c:733)
> [  891.465359] sock_sendmsg (net/socket.c:611 net/socket.c:620)
> [  891.466211] sock_write_iter (net/socket.c:820)
> [  891.470869] __vfs_write (fs/read_write.c:480 fs/read_write.c:492)
> [  891.473525] vfs_write (fs/read_write.c:540)
> [  891.474341] SyS_write (fs/read_write.c:587 fs/read_write.c:578)
> [  891.477995] entry_SYSCALL_64_fastpath (arch/x86/entry/entry_64.S:188)
> [  891.478975] Memory state around the buggy address:
> 
> [  891.479722]  ffff8806e9773900: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
> 
> [  891.480830]  ffff8806e9773980: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
> 
> [  891.481954] >ffff8806e9773a00: fc fc fc fc fc fc 00 00 00 00 00 00 00 fc fc fc
> 
> [  891.483025]                                      ^
> 
> [  891.483622]  ffff8806e9773a80: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
> 
> [  891.484469]  ffff8806e9773b00: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
> 
> [  891.485307] ==================================================================
> 
> 
> Thanks,
> Sasha

Very similar to a report sent earlier by Dmitry.

Bug probably added by :

commit 03485f2adcde0c2d4e9228b659be78e872486bbb
Author: Vlad Yasevich <vyasevich@gmail.com>
Date:   Sat Jan 31 10:40:17 2015 -0500

    udpv6: Add lockless sendmsg() support
    
    This commit adds the same functionaliy to IPv6 that
    commit 903ab86d195cca295379699299c5fc10beba31c7
    Author: Herbert Xu <herbert@gondor.apana.org.au>
    Date:   Tue Mar 1 02:36:48 2011 +0000
    
        udp: Add lockless transmit path
    
    added to IPv4.
    
    UDP transmit path can now run without a socket lock,
    thus allowing multiple threads to send to a single socket
    more efficiently.
    This is only used when corking/MSG_MORE is not used.
    
    Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>
