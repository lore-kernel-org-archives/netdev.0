From: David Forster <dforster@brocade.com>
Subject: [PATCH] ipv4: panic in leaf_walk_rcu due to stale node pointer
Date: Wed, 3 Aug 2016 15:13:01 +0100
Message-ID: <1470233581-25728-1-git-send-email-dforster@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Dave Forster <dforster@brocade.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:29799 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755611AbcHCPD3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2016 11:03:29 -0400
Received: from pps.filterd (m0000700.ppops.net [127.0.0.1])
	by m0000700.ppops.net (8.16.0.11/8.16.0.11) with SMTP id u73EDKc0010318
	for <netdev@vger.kernel.org>; Wed, 3 Aug 2016 07:14:04 -0700
Received: from brmwp-exmb12.corp.brocade.com ([208.47.132.227])
	by mx0b-000f0801.pphosted.com with ESMTP id 24k0cacafm-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 03 Aug 2016 07:14:03 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Panic occurs when issuing "cat /proc/net/route" whilst
populating FIB with > 1M routes.

Use of cached node pointer in fib_route_get_idx is unsafe.

 BUG: unable to handle kernel paging request at ffffc90001630024
 IP: [<ffffffff814cf6a0>] leaf_walk_rcu+0x10/0xe0
 PGD 11b08d067 PUD 11b08e067 PMD dac4b067 PTE 0
 Oops: 0000 [#1] SMP
 Modules linked in: nfsd auth_rpcgss oid_registry nfs_acl nfs lockd grace fscac
 snd_hda_codec_generic snd_hda_intel snd_hda_codec snd_hda_core snd_hwdep virti
 acpi_cpufreq button parport_pc ppdev lp parport autofs4 ext4 crc16 mbcache jbd
tio_ring virtio floppy uhci_hcd ehci_hcd usbcore usb_common libata scsi_mod
 CPU: 1 PID: 785 Comm: cat Not tainted 4.2.0-rc8+ #4
 Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
 task: ffff8800da1c0bc0 ti: ffff88011a05c000 task.ti: ffff88011a05c000
 RIP: 0010:[<ffffffff814cf6a0>]  [<ffffffff814cf6a0>] leaf_walk_rcu+0x10/0xe0
 RSP: 0018:ffff88011a05fda0  EFLAGS: 00010202
 RAX: ffff8800d8a40c00 RBX: ffff8800da4af940 RCX: ffff88011a05ff20
 RDX: ffffc90001630020 RSI: 0000000001013531 RDI: ffff8800da4af950
 RBP: 0000000000000000 R08: ffff8800da1f9a00 R09: 0000000000000000
 R10: ffff8800db45b7e4 R11: 0000000000000246 R12: ffff8800da4af950
 R13: ffff8800d97a74c0 R14: 0000000000000000 R15: ffff8800d97a7480
 FS:  00007fd3970e0700(0000) GS:ffff88011fd00000(0000) knlGS:0000000000000000
 CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
 CR2: ffffc90001630024 CR3: 000000011a7e4000 CR4: 00000000000006e0
 Stack:
  ffffffff814d00d3 0000000000000000 ffff88011a05ff20 ffff8800da1f9a00
  ffffffff811dd8b9 0000000000000800 0000000000020000 00007fd396f35000
  ffffffff811f8714 0000000000003431 ffffffff8138dce0 0000000000000f80
 Call Trace:
  [<ffffffff814d00d3>] ? fib_route_seq_start+0x93/0xc0
  [<ffffffff811dd8b9>] ? seq_read+0x149/0x380
  [<ffffffff811f8714>] ? fsnotify+0x3b4/0x500
  [<ffffffff8138dce0>] ? process_echoes+0x70/0x70
  [<ffffffff8121cfa7>] ? proc_reg_read+0x47/0x70
  [<ffffffff811bb823>] ? __vfs_read+0x23/0xd0
  [<ffffffff811bbd42>] ? rw_verify_area+0x52/0xf0
  [<ffffffff811bbe61>] ? vfs_read+0x81/0x120
  [<ffffffff811bcbc2>] ? SyS_read+0x42/0xa0
  [<ffffffff81549ab2>] ? entry_SYSCALL_64_fastpath+0x16/0x75
 Code: 48 85 c0 75 d8 f3 c3 31 c0 c3 f3 c3 66 66 66 66 66 66 2e 0f 1f 84 00 00
a 04 89 f0 33 02 44 89 c9 48 d3 e8 0f b6 4a 05 49 89
 RIP  [<ffffffff814cf6a0>] leaf_walk_rcu+0x10/0xe0
  RSP <ffff88011a05fda0>
 CR2: ffffc90001630024

Signed-off-by: Dave Forster <dforster@brocade.com>
---
 net/ipv4/fib_trie.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index d07fc07..febca0f 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -2452,9 +2452,7 @@ struct fib_route_iter {
 static struct key_vector *fib_route_get_idx(struct fib_route_iter *iter,
 					    loff_t pos)
 {
-	struct fib_table *tb = iter->main_tb;
 	struct key_vector *l, **tp = &iter->tnode;
-	struct trie *t;
 	t_key key;
 
 	/* use cache location of next-to-find key */
@@ -2462,8 +2460,6 @@ static struct key_vector *fib_route_get_idx(struct fib_route_iter *iter,
 		pos -= iter->pos;
 		key = iter->key;
 	} else {
-		t = (struct trie *)tb->tb_data;
-		iter->tnode = t->kv;
 		iter->pos = 0;
 		key = 0;
 	}
@@ -2504,12 +2500,12 @@ static void *fib_route_seq_start(struct seq_file *seq, loff_t *pos)
 		return NULL;
 
 	iter->main_tb = tb;
+	t = (struct trie *)tb->tb_data;
+	iter->tnode = t->kv;
 
 	if (*pos != 0)
 		return fib_route_get_idx(iter, *pos);
 
-	t = (struct trie *)tb->tb_data;
-	iter->tnode = t->kv;
 	iter->pos = 0;
 	iter->key = 0;
 
-- 
1.9.1
