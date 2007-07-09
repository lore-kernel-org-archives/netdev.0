From: akpm@linux-foundation.org
Subject: [patch 1/8] Make ATM driver use seq_list_xxx helpers
Date: Mon, 09 Jul 2007 11:51:09 -0700
Message-ID: <200707091851.l69Ip9PI001723@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, xemul@sw.ru,
	xemul@openvz.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:39958 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759696AbXGISwX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2007 14:52:23 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelianov <xemul@sw.ru>

The .show callback receives the list_head pointer now, not the struct
br2684_dev one.

Signed-off-by: Pavel Emelianov <xemul@openvz.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 net/atm/br2684.c |   22 ++++------------------
 1 files changed, 4 insertions(+), 18 deletions(-)

diff -puN net/atm/br2684.c~make-atm-driver-use-seq_list_xxx-helpers net/atm/br2684.c
--- a/net/atm/br2684.c~make-atm-driver-use-seq_list_xxx-helpers
+++ a/net/atm/br2684.c
@@ -699,28 +699,13 @@ static struct atm_ioctl br2684_ioctl_ops
 #ifdef CONFIG_PROC_FS
 static void *br2684_seq_start(struct seq_file *seq, loff_t *pos)
 {
-	loff_t offs = 0;
-	struct br2684_dev *brd;
-
 	read_lock(&devs_lock);
-
-	list_for_each_entry(brd, &br2684_devs, br2684_devs) {
-		if (offs == *pos)
-			return brd;
-		++offs;
-	}
-	return NULL;
+	return seq_list_start(&br2684_devs, *pos);
 }
 
 static void *br2684_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
-	struct br2684_dev *brd = v;
-
-	++*pos;
-
-	brd = list_entry(brd->br2684_devs.next,
-			 struct br2684_dev, br2684_devs);
-	return (&brd->br2684_devs != &br2684_devs) ? brd : NULL;
+	return seq_list_next(v, &br2684_devs, pos);
 }
 
 static void br2684_seq_stop(struct seq_file *seq, void *v)
@@ -730,7 +715,8 @@ static void br2684_seq_stop(struct seq_f
 
 static int br2684_seq_show(struct seq_file *seq, void *v)
 {
-	const struct br2684_dev *brdev = v;
+	const struct br2684_dev *brdev = list_entry(v, struct br2684_dev,
+			br2684_devs);
 	const struct net_device *net_dev = brdev->net_dev;
 	const struct br2684_vcc *brvcc;
 
_
