From: khalasa@piap.pl (Krzysztof =?utf-8?Q?Ha=C5=82asa?=)
Subject: BUG: NULL ptr dereference in v3.19: rpc_mount
Date: Sat, 21 Feb 2015 12:33:28 +0100
Message-ID: <m3sidzjy7r.fsf@t19.piap.pl>
Mime-Version: 1.0
Content-Type: text/plain
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ni.piap.pl ([195.187.100.4]:43018 "EHLO ni.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751717AbbBULda (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Feb 2015 06:33:30 -0500
Received: from ni.piap.pl (localhost.localdomain [127.0.0.1])
	by ni.piap.pl (Postfix) with ESMTP id EA7904418B3
	for <netdev@vger.kernel.org>; Sat, 21 Feb 2015 12:33:28 +0100 (CET)
Received: from t19.piap.pl (OSB1819.piap.pl [10.0.9.19])
	by ni.piap.pl (Postfix) with ESMTP id E8A0444182F
	for <netdev@vger.kernel.org>; Sat, 21 Feb 2015 12:33:28 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I'm getting a NULL ptr dereference in the RPC code, any ideas?
This is a new instalation, so can't bisect.
Is it caused by the lack of namespace support (in the config)?
This is basically a Fedora 21 with a custom x86-64 3.19 kernel.

BUG: unable to handle kernel NULL pointer dereference at rpc_mount+0x17/0x20 [sunrpc]
CPU: 0 PID: 342 Comm: mount Not tainted 3.19.0+ #6
task: ffff88013a6923f0 ti: ffff8800370e0000 task.ti: ffff8800370e0000
RSP: 0018:ffff8800370e3e70  EFLAGS: 00010246
RAX: 0000000000000000 RBX: ffff8800ba6fdc80 RCX: ffffffffa0032a20
RDX: ffff8800bad51918 RSI: 0000000000000000 RDI: ffffffffa003d0e0
RBP: ffffffffa003d0e0 R08: ffffffff8165b480 R09: ffff88013fd17b10
R10: 0000000000000684 R11: 0000000000017b09 R12: ffffffffa003d0e0
R13: 0000000000000000 R14: 0000000000000000 R15: ffff8800372e5670
FS:  00007f36f1720840(0000) GS:ffff88013fc00000(0000)
knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000000000028 CR3: 000000003716c000 CR4: 00000000000407f0

Stack:
 ffffffff810f58fc ffff8800ba6fdc80 ffffffffa003d0e0 ffff8800bad51918
 ffffffff8110d3dd ffffffff81627b80 0000000000000020 0000000000000000
 ffffffffa003d0e0 ffff8800bad51918 ffffffff8110fde0 0000000000000000

Call Trace:
 [<ffffffff810f58fc>] ? mount_fs+0xc/0xc0
 [<ffffffff8110d3dd>] ? vfs_kern_mount+0x5d/0x100
 [<ffffffff8110fde0>] ? do_mount+0x1b0/0xa60
 [<ffffffff810c17a8>] ? memdup_user+0x38/0x70
 [<ffffffff81110987>] ? SyS_mount+0x67/0xc0
 [<ffffffff813d8152>] ? system_call_fastpath+0x12/0x17

static struct dentry *
rpc_mount(struct file_system_type *fs_type,
                int flags, const char *dev_name, void *data)
{
	****** current->nsproxy seems to be NULL here: *****
	return mount_ns(fs_type, flags, current->nsproxy->net_ns, rpc_fill_super);
}

<rpc_mount>:
     c70:       65 48 8b 04 25 00 00    mov    %gs:0x0,%rax
     c77:       00 00
     c75: R_X86_64_32S       current_task
     c79:       48 8b 80 38 05 00 00    mov    0x538(%rax),%rax
     c80:       48 c7 c1 00 00 00 00    mov    $0x0,%rcx
     c83: R_X86_64_32S       .text+0x18b0
     c87:       48 8b 50 28             mov    0x28(%rax),%rdx
     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
     c8b:       e9 00 00 00 00          jmpq   c90 <rpc_destroy_inode>
     c8c: R_X86_64_PC32      mount_ns-0x4

# CONFIG_NAMESPACES is not set
CONFIG_KERNFS=y
# CONFIG_NFS_FS is not set
CONFIG_NFSD=m
CONFIG_NFSD_V3=y
# CONFIG_NFSD_V3_ACL is not set
# CONFIG_NFSD_V4 is not set
CONFIG_GRACE_PERIOD=m
CONFIG_LOCKD=m
CONFIG_LOCKD_V4=y
CONFIG_NFS_COMMON=y
CONFIG_SUNRPC=m
# CONFIG_SUNRPC_DEBUG is not set

Full .config etc. are available of course.
-- 
Krzysztof Halasa

Research Institute for Automation and Measurements PIAP
Al. Jerozolimskie 202, 02-486 Warsaw, Poland
