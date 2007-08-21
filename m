From: Benjamin Thery <benjamin.thery@bull.net>
Subject: [PATCH 0/1] net/core: Crash in dev_mc_sync() when putting macvlan interface up
Date: Tue, 21 Aug 2007 18:29:22 +0200
Message-ID: <20070821162922.149199466@frecb000701.frec.bull.fr>
Cc: Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:38550 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755033AbXHUQco (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2007 12:32:44 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

My kernel crashed while testing macvlan interfaces on 2.6.23-rc2.
(See kernel panic below)

The culprit is dev_mc_sync(). In this routine, we delete 
elements from 'from->mc_list' unsafely. 
While going through the list, we may delete one of the element 
(__dev_addr_delete(from->mc_list,...)), and then try to continue
from that same element that have just been freed: for(..., da = da->next).

It took me some time to understand why only one of my test machines
was crashing. After a while I discovered my crashing victim has 
CONFIG_DEBUG_SLAB=y set, which poisons the freed 'struct dev_addr_list'.
(Now I love poison!)

The crash can be reproduced by setting the option CONFIG_DEBUG_SLAB=y.
Then, add a macvlan interface and set it up.

$ ip link add link eth0 type macvlan

$ ip link macvlan0 up

BUG: unable to handle kernel paging request at virtual address 6b6b6b6b
 printing eip:
c025e9b4
*pde = 00000000
Oops: 0000 [#1]
Modules linked in:
CPU:    0
EIP:    0060:[<c025e9b4>]    Not tainted VLI
EFLAGS: 00000282   (2.6.23-rc2-eb-netns #6)
EIP is at dev_mc_sync+0x5f/0x197
eax: 00000025   ebx: c11e5dec   ecx: ffffffff   edx: 00000046
esi: 6b6b6b6b   edi: c1134060   ebp: c742fe6c   esp: c742fe48
ds: 007b   es: 007b   fs: 0000  gs: 0033  ss: 0068
Process ifconfig (pid: 937, ti=c742e000 task=c1128000 task.ti=c742e000)
Stack: c034c6dc 6b6b6b6b c1134060 c7bd2180 00000000 c1134218 c7bd2180 c7bd2338 
       00001002 c742fe74 c02238a4 c742fe80 c025a9d8 c7bd2180 c742fe90 c025ab78 
       c7bd2180 00001043 c742fe9c c025ce66 c7bd2180 c742fec0 c025b034 c7bd2180 
Call Trace:
 [<c0102c66>] show_trace_log_lvl+0x1a/0x2f
 [<c0102d18>] show_stack_log_lvl+0x9d/0xa5
 [<c0102ede>] show_registers+0x1be/0x28f
 [<c0103097>] die+0xe8/0x208
 [<c010d555>] do_page_fault+0x4ba/0x595
 [<c02e3e62>] error_code+0x6a/0x70
 [<c02238a4>] macvlan_set_multicast_list+0x15/0x17
 [<c025a9d8>] __dev_set_rx_mode+0x7e/0x81
 [<c025ab78>] dev_set_rx_mode+0x25/0x3a
 [<c025ce66>] dev_open+0x4b/0x6a
 [<c025b034>] dev_change_flags+0xa4/0x159
 [<c028da20>] devinet_ioctl+0x204/0x506
 [<c028e082>] inet_ioctl+0x86/0xa4
 [<c02538f6>] sock_ioctl+0x159/0x177
 [<c0152ac4>] do_ioctl+0x1c/0x51
 [<c0152ce5>] vfs_ioctl+0x1ec/0x203
 [<c0152d2d>] sys_ioctl+0x31/0x48
 [<c01025ea>] syscall_call+0x7/0xb
 =======================
Code: 87 c8 01 00 00 00 00 00 00 8b b0 f8 00 00 00 c7 45 ec 00 00 00 00 e9 0a 01 00 00 89 74 24 04 c7 04 24 dc c6 34 c0 e8 57 44 eb ff <8b> 06 c7 04 24 f9 c6 34 c0 89 44 24 04 e8 45 44 eb ff 80 7e 25 
EIP: [<c025e9b4>] dev_mc_sync+0x5f/0x197 SS:ESP 0068:c742fe48
Kernel panic - not syncing: Fatal exception in interrupt


I think the problem may also exist in dev_mc_unsync().

I have a patch that seems to fix the issue for me.

Hope this helps.

Regards,
Benjamin
-- 
