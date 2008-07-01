From: "Vegard Nossum" <vegard.nossum@gmail.com>
Subject: kmemcheck detected possible information leak to userspace?
Date: Tue, 1 Jul 2008 11:16:15 +0200
Message-ID: <19f34abd0807010216k11a60382xf7a27b4b27f0819@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Pekka Enberg" <penberg@cs.helsinki.fi>,
	"Ingo Molnar" <mingo@elte.hu>, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.175]:5113 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754097AbYGAJQQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2008 05:16:16 -0400
Received: by wf-out-1314.google.com with SMTP id 27so1928747wfd.4
        for <netdev@vger.kernel.org>; Tue, 01 Jul 2008 02:16:15 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Running kmemcheck on -tip gives me the following warning:

kmemcheck: Caught 32-bit read from uninitialized memory (c72daa2e)
iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiuuuuiiiiuuuuuuuuuu
                                              ^

Pid: 1345, comm: dhclient3 Tainted: G        W
(2.6.26-rc8-tip-00186-ga644034 #60)
EIP: 0060:[<c028dd63>] EFLAGS: 00000206 CPU: 0
EIP is at __copy_user_intel+0x43/0xb0
EAX: 00000000 EBX: 0000024e ECX: 000000ce EDX: 00000000
ESI: c72da992 EDI: bff8e2f8 EBP: c68abd90 ESP: c0823f88
 DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
CR0: 8005003b CR2: c68a0328 CR3: 06899000 CR4: 00000690
DR0: c0b98b7c DR1: 00000000 DR2: 00000000 DR3: 00000000
DR6: 00004000 DR7: 00000000
 [<c028de27>] __copy_to_user_ll+0x57/0x60
 [<c028e3f8>] copy_to_user+0x48/0x60
 [<c04ade71>] memcpy_toiovec+0x41/0x60
 [<c04ae461>] skb_copy_datagram_iovec+0x131/0x1e0
 [<c05325c7>] packet_recvmsg+0xa7/0x1b0
 [<c04a5aa3>] sock_aio_read+0xf3/0x100
 [<c01a7c7d>] do_sync_read+0xcd/0x110
 [<c01a8556>] vfs_read+0x126/0x130
 [<c01a89ed>] sys_read+0x3d/0x70
 [<c0104017>] sysenter_past_esp+0x78/0xc5
 [<ffffffff>] 0xffffffff

..which is a bit worrying, because it means that we are copying
uninitialized data into userspace, i.e. this could be a data leak.
Most likely it's not very critical, but it would be nice to fix
anyway.

Relevant source lines are:

$ addr2line -e vmlinux -i c04ade71 # memcpy_toiovec
net/core/iovec.c:87

$ addr2line -e vmlinux -i c04ae461 # skb_copy_datagram_iovec
net/core/datagram.c:277

$ addr2line -e vmlinux -i c05325c7 # packet_recvmsg
net/packet/af_packet.c:1093


Vegard

-- 
"The animistic metaphor of the bug that maliciously sneaked in while
the programmer was not looking is intellectually dishonest as it
disguises that the error is the programmer's own creation."
	-- E. W. Dijkstra, EWD1036
