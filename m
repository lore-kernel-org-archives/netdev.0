From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: net/sctp: out-of-bounds access in sctp_add_bind_addr
Date: Mon, 25 Jan 2016 09:31:30 -0500
Message-ID: <20160125143130.GB29690@hmsreliant.think-freely.org>
References: <CACT4Y+YNM_C1_mBBiq40-xe+dTKdsfmxri2SeDyRKSVpw+7nLQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vlad Yasevich <vyasevich@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-sctp@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	Eric Dumazet <edumazet@google.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:45941 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755501AbcAYOcE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2016 09:32:04 -0500
Content-Disposition: inline
In-Reply-To: <CACT4Y+YNM_C1_mBBiq40-xe+dTKdsfmxri2SeDyRKSVpw+7nLQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 25, 2016 at 03:02:38PM +0100, Dmitry Vyukov wrote:
> Hello,
> 
> I've git the following error report while running syzkaller fuzzer:
> 
> ==================================================================
> BUG: KASAN: slab-out-of-bounds in memcpy+0x1d/0x40 at addr ffff88006c6361e8
> Read of size 28 by task syz-executor/12551
> =============================================================================
> BUG kmalloc-16 (Not tainted): kasan: bad access detected
> -----------------------------------------------------------------------------
> 
> INFO: Allocated in sctp_setsockopt_bindx+0xd2/0x3e0 age=12 cpu=2 pid=12551
> [<     inline     >] kmalloc include/linux/slab.h:468
> [<      none      >] sctp_setsockopt_bindx+0xd2/0x3e0 net/sctp/socket.c:975
> [<      none      >] sctp_setsockopt+0x1493/0x3630 net/sctp/socket.c:3711
> [<      none      >] sock_common_setsockopt+0x97/0xd0 net/core/sock.c:2620
> [<     inline     >] SYSC_setsockopt net/socket.c:1752
> [<      none      >] SyS_setsockopt+0x15b/0x250 net/socket.c:1731
> [<      none      >] entry_SYSCALL_64_fastpath+0x16/0x7a
> arch/x86/entry/entry_64.S:185
> 
> INFO: Slab 0xffffea0001b18d80 objects=16 used=4 fp=0xffff88006c6376e0
> flags=0x5fffc0000004080
> INFO: Object 0xffff88006c6361e8 @offset=488 fp=0x0000000000000002
> Bytes b4 ffff88006c6361d8: 00 00 00 00 00 00 00 00 2f 98 34 88 ff ff
> ff ff  ......../.4.....
> Object ffff88006c6361e8: 02 00 00 00 00 00 00 00 02 00 ab 07 7f 00 00
> 01  ................
> CPU: 2 PID: 12551 Comm: syz-executor Tainted: G    B           4.5.0-rc1+ #278
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
>  00000000ffffffff ffff880036397928 ffffffff8299a02d ffff88003e807900
>  ffff88006c6361e8 ffff88006c636000 ffff880036397958 ffffffff81752814
>  ffff88003e807900 ffffea0001b18d80 ffff88006c6361e8 ffff88006c6361e8
> 
> Call Trace:
>  [<ffffffff8175ad54>] __asan_loadN+0x124/0x1a0 mm/kasan/kasan.c:512
>  [<ffffffff8175b2dd>] memcpy+0x1d/0x40 mm/kasan/kasan.c:297
>  [<ffffffff85dcb249>] sctp_add_bind_addr+0xa9/0x270 net/sctp/bind_addr.c:162
>  [<ffffffff85dcfd66>] sctp_do_bind+0x336/0x580 net/sctp/socket.c:389
>  [<ffffffff85dd16ec>] sctp_bindx_add+0xac/0x1a0 net/sctp/socket.c:471
>  [<ffffffff85dd5cc8>] sctp_setsockopt_bindx+0x2f8/0x3e0 net/sctp/socket.c:1010
>  [<ffffffff85dde283>] sctp_setsockopt+0x1493/0x3630 net/sctp/socket.c:3711
>  [<ffffffff851f5ae7>] sock_common_setsockopt+0x97/0xd0 net/core/sock.c:2620
>  [<     inline     >] SYSC_setsockopt net/socket.c:1752
>  [<ffffffff851f2c3b>] SyS_setsockopt+0x15b/0x250 net/socket.c:1731
>  [<ffffffff863595f6>] entry_SYSCALL_64_fastpath+0x16/0x7a
> arch/x86/entry/entry_64.S:185
> 
> Memory state around the buggy address:
>  ffff88006c636080: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
>  ffff88006c636100: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
> >ffff88006c636180: fc fc fc fc fc fc fc fc fc fc fc fc fc 00 00 fc
>                                                                 ^
>  ffff88006c636200: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
>  ffff88006c636280: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
> ==================================================================
> 
> 
> sctp_setsockopt_bindx verifies that the user-passed address has valid
> len for the specified family, but then sctp_add_bind_addr copies whole
> sctp_addr from there. This causes heap out-of-bounds access and can
> crash kernel. Not sure if it is possible to copy out the trailing
> garbage to user-space later.
> 

It does more than that though.  sctp_setsockopt_bindx checks the following:
1) That passed addr_size is greater than zero
2) that the entire range of memory between addrs and addrs+addr_size is readable
3) That at least one address structure worth of data is available (implicit in
the while (walk_size < addr_size) loop).

Could one of the sockaddr_len fields in one of the addresses have been mangled
so that it appeared shorter in the the while loop from (3), so that a copy of
sizeof(sctp_addr in sctp_add_bind_addr overrun the allocated memory?

Neil

> On commit 92e963f50fc74041b5e9e744c330dca48e04f08d (Jan 25).
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
