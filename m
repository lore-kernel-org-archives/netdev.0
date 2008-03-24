From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26 5/5][NETNS]: Minor information leak via /proc/net/ptype
 file.
Date: Mon, 24 Mar 2008 13:55:09 +0300
Message-ID: <47E7888D.5080308@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org,
	Daniel Lezcano <dlezcano@fr.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:53643 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757342AbYCXKzM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Mar 2008 06:55:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This file displays the registered packet types, but some of them
(packet sockets creates such) can be bound to a net device and
showing them in a wrong namespace is not correct.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/core/dev.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index f973e38..aebd086 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2615,7 +2615,7 @@ static int ptype_seq_show(struct seq_file *seq, void *v)
 
 	if (v == SEQ_START_TOKEN)
 		seq_puts(seq, "Type Device      Function\n");
-	else {
+	else if (pt->dev == NULL || pt->dev->nd_net == seq_file_net(seq)) {
 		if (pt->type == htons(ETH_P_ALL))
 			seq_puts(seq, "ALL ");
 		else
@@ -2639,7 +2639,8 @@ static const struct seq_operations ptype_seq_ops = {
 
 static int ptype_seq_open(struct inode *inode, struct file *file)
 {
-	return seq_open(file, &ptype_seq_ops);
+	return seq_open_net(inode, file, &ptype_seq_ops,
+			sizeof(struct seq_net_private));
 }
 
 static const struct file_operations ptype_seq_fops = {
@@ -2647,7 +2648,7 @@ static const struct file_operations ptype_seq_fops = {
 	.open    = ptype_seq_open,
 	.read    = seq_read,
 	.llseek  = seq_lseek,
-	.release = seq_release,
+	.release = seq_release_net,
 };
 
 
-- 
1.5.3.4

