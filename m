From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 11/14][VLAN]: Make /proc/net/vlan/conf file show per-net info.
Date: Thu, 10 Apr 2008 19:19:36 +0400
Message-ID: <47FE3008.5020205@openvz.org>
References: <47FE2AD4.9080609@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Daniel Lezcano <dlezcano@fr.ibm.com>, Denis Lunev <den@openvz.org>,
	Linux Containers <containers@lists.osdl.org>,
	Benjamin Thery <benjamin.thery@bull.net>
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:40134 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755914AbYDJOzi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Apr 2008 10:55:38 -0400
In-Reply-To: <47FE2AD4.9080609@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

And this one if PATCH #9 part 3 :)
After this proc may show relevant to each net namespace info.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/8021q/vlanproc.c |   13 ++++++++-----
 1 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/net/8021q/vlanproc.c b/net/8021q/vlanproc.c
index 995544b..cc17b72 100644
--- a/net/8021q/vlanproc.c
+++ b/net/8021q/vlanproc.c
@@ -80,7 +80,8 @@ static const struct seq_operations vlan_seq_ops = {
 
 static int vlan_seq_open(struct inode *inode, struct file *file)
 {
-	return seq_open(file, &vlan_seq_ops);
+	return seq_open_net(inode, file, &vlan_seq_ops,
+			sizeof(struct seq_net_private));
 }
 
 static const struct file_operations vlan_fops = {
@@ -88,7 +89,7 @@ static const struct file_operations vlan_fops = {
 	.open    = vlan_seq_open,
 	.read    = seq_read,
 	.llseek  = seq_lseek,
-	.release = seq_release,
+	.release = seq_release_net,
 };
 
 /*
@@ -211,6 +212,7 @@ static void *vlan_seq_start(struct seq_file *seq, loff_t *pos)
 	__acquires(dev_base_lock)
 {
 	struct net_device *dev;
+	struct net *net = seq_file_net(seq);
 	loff_t i = 1;
 
 	read_lock(&dev_base_lock);
@@ -218,7 +220,7 @@ static void *vlan_seq_start(struct seq_file *seq, loff_t *pos)
 	if (*pos == 0)
 		return SEQ_START_TOKEN;
 
-	for_each_netdev(&init_net, dev) {
+	for_each_netdev(net, dev) {
 		if (!is_vlan_dev(dev))
 			continue;
 
@@ -232,14 +234,15 @@ static void *vlan_seq_start(struct seq_file *seq, loff_t *pos)
 static void *vlan_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
 	struct net_device *dev;
+	struct net *net = seq_file_net(seq);
 
 	++*pos;
 
 	dev = (struct net_device *)v;
 	if (v == SEQ_START_TOKEN)
-		dev = net_device_entry(&init_net.dev_base_head);
+		dev = net_device_entry(&net->dev_base_head);
 
-	for_each_netdev_continue(&init_net, dev) {
+	for_each_netdev_continue(net, dev) {
 		if (!is_vlan_dev(dev))
 			continue;
 
-- 
1.5.3.4

