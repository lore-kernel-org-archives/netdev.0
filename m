From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next] cxgb4: Fix trace observed while dumping clip_tbl
Date: Mon,  9 Feb 2015 09:47:10 +0530
Message-ID: <1423455430-13444-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:12489 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751552AbbBIELd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Feb 2015 23:11:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Handle clip_tbl debugfs entry, when clip_tbl isn't allocated.
In commit b5a02f503caa0837 ("cxgb4: Update ipv6 address handling api") wrong
argument was passed for single_open for clip_tbl debugfs entry, which led to
below trace. Fixing it.

======
call Trace:
 [<ffffffffa073c606>] clip_tbl_open+0x16/0x30 [cxgb4]
 [<ffffffff8119e2fa>] do_dentry_open+0x21a/0x370
 [<ffffffff8119e499>] vfs_open+0x49/0x50
 [<ffffffff811b0d0e>] do_last+0x21e/0x800
 [<ffffffff811b1382>] path_openat+0x92/0x470
 [<ffffffff8110569f>] ? rb_reserve_next_event+0xaf/0x380
 [<ffffffff8110569f>] ? rb_reserve_next_event+0xaf/0x380
 [<ffffffff811b189a>] do_filp_open+0x4a/0xa0
 [<ffffffff811bdc5d>] ? __alloc_fd+0xcd/0x140
 [<ffffffff8119fa4a>] do_sys_open+0x11a/0x230
 [<ffffffff8101219f>] ? syscall_trace_enter_phase2+0xaf/0x1b0
 [<ffffffff8119fb9e>] SyS_open+0x1e/0x20
 [<ffffffff815bf6f0>] tracesys_phase2+0xd4/0xd9
Code: 89 e5 66 66 66 66 90 48 8b 47 e0 48 8b 40 30 48 8b 40 58 c9 c3 66 0f 1f
84 00 00 00 00 00 55 48 89 e5 66 66 66 66 90 48 8b 47 e0 <48> 8b 40 58 c9 c3 66
66 66 66 2e 0f 1f 84 00 00 00 00 00 55 48
RIP  [<ffffffff8120898d>] PDE_DATA+0xd/0x20
 RSP <ffff8800b08c3c48>
CR2: 0000000000000058

=====

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/clip_tbl.c      |    3 +++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c |    2 +-
 2 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/clip_tbl.c b/drivers/net/ethernet/chelsio/cxgb4/clip_tbl.c
index 2b407b6..9062a84 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/clip_tbl.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/clip_tbl.c
@@ -81,6 +81,9 @@ int cxgb4_clip_get(const struct net_device *dev, const u32 *lip, u8 v6)
 	int addr_len;
 	int ret = 0;
 
+	if (!ctbl)
+		return 0;
+
 	if (v6)
 		addr_len = 16;
 	else
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
index a1029ee..d221f6b 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
@@ -1237,7 +1237,7 @@ DEFINE_SIMPLE_DEBUGFS_FILE(sensors);
 #if IS_ENABLED(CONFIG_IPV6)
 static int clip_tbl_open(struct inode *inode, struct file *file)
 {
-	return single_open(file, clip_tbl_show, PDE_DATA(inode));
+	return single_open(file, clip_tbl_show, inode->i_private);
 }
 
 static const struct file_operations clip_tbl_debugfs_fops = {
-- 
1.7.1
