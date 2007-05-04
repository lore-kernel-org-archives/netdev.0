From: Andrew Morton <akpm@linux-foundation.org>
Subject: git-net locking bustage
Date: Fri, 4 May 2007 11:53:16 -0700
Message-ID: <20070504115316.998c7fd3.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:51519 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1161505AbXEDSyJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2007 14:54:09 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


My last pull was yesterday:



GIT fc38582db98533066f4ba64f948720483fbfe7b2 git+ssh://master.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.git

commit 
Author: Patrick McHardy <kaber@trash.net>
Date:   Thu May 3 03:36:16 2007 -0700

    [NETFILTER]: bridge netfilter: consolidate header pushing/pulling code
    
    Consolidate the common push/pull sequences into a few helper functions.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>
    Signed-off-by: David S. Miller <davem@davemloft.net>



and I don't see anything in there since then which would have fixed this:



SELinux: initialized (dev autofs, type autofs), uses genfs_contexts
SELinux: initialized (dev autofs, type autofs), uses genfs_contexts
SELinux: initialized (dev autofs, type autofs), uses genfs_contexts
eth0: no IPv6 routers present
------------[ cut here ]------------
kernel BUG at net/netlink/af_netlink.c:144!
invalid opcode: 0000 [1] SMP 
CPU 1 
Modules linked in: autofs4 hidp rfcomm l2cap bluetooth sunrpc ipv6 dm_mirror dm_multipath dm_mod video sbs dock button battery asus_acpi ac parport_pc lp parport floppy sg snd_hda_intel snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss snd_pcm snd_timer snd soundcore snd_page_alloc shpchp i2c_i801 i2c_core ide_cd cdrom serio_raw ehci_hcd ohci_hcd uhci_hcd
Pid: 3790, comm: sshd Not tainted 2.6.21-mm1 #1
RIP: 0010:[<ffffffff80466648>]  [<ffffffff80466648>] netlink_sock_destruct+0x10/0xe2
RSP: 0018:ffff81010edcfe68  EFLAGS: 00010297
RAX: ffffffff805fc460 RBX: ffff81010ac69400 RCX: 0000000000000000
RDX: 0000000000000001 RSI: 0000000000000246 RDI: ffff81010ac69400
RBP: 0000000000000000 R08: ffffffff80605d18 R09: 0000000000000000
R10: 0000000000000000 R11: ffffffff00000000 R12: ffff81010e1342c0
R13: ffff81010e134320 R14: ffff810100c83980 R15: ffff8101101af7b8
FS:  00002b5f58632250(0000) GS:ffff810100cd4dc0(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 00002b5f57f6f750 CR3: 000000010c8cb000 CR4: 00000000000006e0
Process sshd (pid: 3790, threadinfo ffff81010edce000, task ffff81010bb68100)
Stack:  ffff81010ac69400 ffffffff80449373 ffff81010ac695d8 ffff81010ac695d8
 ffff81010ac69400 ffffffff80466f61 0000000000000ece 0000000000000000
 0000000000000000 ffff81010e1342c0 ffff81010e134320 ffffffff80446f44
Call Trace:
 [<ffffffff80449373>] sk_free+0x22/0xdb
 [<ffffffff80466f61>] netlink_release+0x215/0x21f
 [<ffffffff80446f44>] sock_release+0x17/0x6f
 [<ffffffff80446fc8>] sock_close+0x2c/0x30
 [<ffffffff80292cc0>] __fput+0xc0/0x18c
 [<ffffffff80290aa1>] filp_close+0x5d/0x65
 [<ffffffff80291097>] sys_close+0x90/0xce
 [<ffffffff80209bee>] system_call+0x7e/0x83


Code: 0f 0b eb fe 48 8b bf 18 03 00 00 48 85 ff 74 17 48 8b 47 18 
RIP  [<ffffffff80466648>] netlink_sock_destruct+0x10/0xe2


It's hitting the

static void netlink_sock_destruct(struct sock *sk)
{
+       struct netlink_sock *nlk = nlk_sk(sk);
+
+       BUG_ON(mutex_is_locked(nlk_sk(sk)->cb_mutex));
+       if (nlk->cb) {

That's with the full -mm lineup.  I'll go repull and thin the patches down a bit.

