From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26] Use existing device list walker for /proc/dev_mcast.
Date: Fri, 29 Feb 2008 19:12:30 +0300
Message-ID: <47C82EEE.1040409@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:40681 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758911AbYB2QMd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Feb 2008 11:12:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The seq_file_operations' dev_mc_seq_xxx callbacks do the same 
thing as the dev_seq_xxx ones do, but skip the SEQ_START_TOKEN.

So use the existing exported dev_seq_xxx calls and handle the 
SEQ_START_TOKEN in the dev_mc_seq_show().

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/core/dev_mcast.c b/net/core/dev_mcast.c
index cec5825..f8a3455 100644
--- a/net/core/dev_mcast.c
+++ b/net/core/dev_mcast.c
@@ -156,39 +156,14 @@ void dev_mc_unsync(struct net_device *to, struct net_device *from)
 EXPORT_SYMBOL(dev_mc_unsync);
 
 #ifdef CONFIG_PROC_FS
-static void *dev_mc_seq_start(struct seq_file *seq, loff_t *pos)
-	__acquires(dev_base_lock)
-{
-	struct net *net = seq_file_net(seq);
-	struct net_device *dev;
-	loff_t off = 0;
-
-	read_lock(&dev_base_lock);
-	for_each_netdev(net, dev) {
-		if (off++ == *pos)
-			return dev;
-	}
-	return NULL;
-}
-
-static void *dev_mc_seq_next(struct seq_file *seq, void *v, loff_t *pos)
-{
-	++*pos;
-	return next_net_device((struct net_device *)v);
-}
-
-static void dev_mc_seq_stop(struct seq_file *seq, void *v)
-	__releases(dev_base_lock)
-{
-	read_unlock(&dev_base_lock);
-}
-
-
 static int dev_mc_seq_show(struct seq_file *seq, void *v)
 {
 	struct dev_addr_list *m;
 	struct net_device *dev = v;
 
+	if (v == SEQ_START_TOKEN)
+		return 0;
+
 	netif_tx_lock_bh(dev);
 	for (m = dev->mc_list; m; m = m->next) {
 		int i;
@@ -206,9 +181,9 @@ static int dev_mc_seq_show(struct seq_file *seq, void *v)
 }
 
 static const struct seq_operations dev_mc_seq_ops = {
-	.start = dev_mc_seq_start,
-	.next  = dev_mc_seq_next,
-	.stop  = dev_mc_seq_stop,
+	.start = dev_seq_start,
+	.next  = dev_seq_next,
+	.stop  = dev_seq_stop,
 	.show  = dev_mc_seq_show,
 };
 
