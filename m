From: Jiri Slaby <jslaby@suse.cz>
Subject: [PATCH] kcm: fix /proc memory leak
Date: Mon, 20 Jun 2016 11:36:28 +0200
Message-ID: <20160620093628.2784-1-jslaby@suse.cz>
Cc: linux-kernel@vger.kernel.org, Jiri Slaby <jslaby@suse.cz>,
	Tom Herbert <tom@herbertland.com>, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:52855 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751741AbcFTJzk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Jun 2016 05:55:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Every open of /proc/net/kcm leaks 16 bytes of memory as is reported by
kmemleak:
unreferenced object 0xffff88059c0e3458 (size 192):
  comm "cat", pid 1401, jiffies 4294935742 (age 310.720s)
  hex dump (first 32 bytes):
    28 45 71 96 05 88 ff ff 00 10 00 00 00 00 00 00  (Eq.............
    00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
  backtrace:
    [<ffffffff8156a2de>] kmem_cache_alloc_trace+0x16e/0x230
    [<ffffffff8162a479>] seq_open+0x79/0x1d0
    [<ffffffffa0578510>] kcm_seq_open+0x0/0x30 [kcm]
    [<ffffffff8162a479>] seq_open+0x79/0x1d0
    [<ffffffff8162a8cf>] __seq_open_private+0x2f/0xa0
    [<ffffffff81712548>] seq_open_net+0x38/0xa0
...

It is caused by a missing free in the ->release path. So fix it by
providing seq_release_net as the ->release method.

Signed-off-by: Jiri Slaby <jslaby@suse.cz>
Fixes: cd6e111bf5 (kcm: Add statistics and proc interfaces)
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Tom Herbert <tom@herbertland.com>
Cc: netdev@vger.kernel.org
---
 net/kcm/kcmproc.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/kcm/kcmproc.c b/net/kcm/kcmproc.c
index 738008726cc6..fda7f4715c58 100644
--- a/net/kcm/kcmproc.c
+++ b/net/kcm/kcmproc.c
@@ -241,6 +241,7 @@ static const struct file_operations kcm_seq_fops = {
 	.open		= kcm_seq_open,
 	.read		= seq_read,
 	.llseek		= seq_lseek,
+	.release	= seq_release_net,
 };
 
 static struct kcm_seq_muxinfo kcm_seq_muxinfo = {
-- 
2.9.0
