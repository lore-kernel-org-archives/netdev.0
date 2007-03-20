From: Keiichi KII <k-keiichi@bx.jp.nec.com>
Subject: [RFC][PATCH -mm take3 5/6][resend] switch function of netpoll
Date: Tue, 20 Mar 2007 21:31:47 +0900
Message-ID: <45FFD433.8060706@bx.jp.nec.com>
References: <45FFCF31.3040000@bx.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: mpm@selenic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO201.gate.nec.co.jp ([202.32.8.193]:35200 "EHLO
	tyo201.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932398AbXCTMby (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2007 08:31:54 -0400
In-Reply-To: <45FFCF31.3040000@bx.jp.nec.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Keiichi KII <k-keiichi@bx.jp.nec.com>

This patch contains switch function of netpoll.

If "enabled" attribute of certain port is '1', this port is used
and the configurations of this port are uable to change.

If "enabled" attribute of certain port is '0', this port isn't used
and the configurations of this port are able to change.

-+- /sys/class/misc/
|-+- netconsole/
  |-+- port1/
  | |--- id          [r--r--r--]  id
  | |--- enabled     [rw-r--r--]  0: disable 1: enable, writable
  | ...
  |--- port2/
  ...

Signed-off-by: Keiichi KII <k-keiichi@bx.jp.nec.com>
Signed-off-by: Takayoshi Kochi <t-kochi@bq.jp.nec.com>
---
Index: linux-2.6.19.5/drivers/net/netconsole.c
===================================================================
--- linux-2.6.19.5.orig/drivers/net/netconsole.c
+++ linux-2.6.19.5/drivers/net/netconsole.c
@@ -60,6 +60,7 @@ struct netconsole_target {
 	struct list_head list;
 	struct kobject obj;
 	int id;
+	int enabled;
 	struct netpoll np;
 };
 
@@ -128,10 +129,19 @@ static ssize_t show_remote_mac(struct ne
 		       nt->np.remote_mac[4], nt->np.remote_mac[5]);
 }
 
+static ssize_t show_enabled(struct netconsole_target *nt, char *buf)
+{
+	return sprintf(buf, "%d\n", nt->enabled);
+}
+
 static ssize_t store_local_port(struct netconsole_target *nt, const char *buf,
 				size_t count)
 {
 	spin_lock(&target_list_lock);
+	if (nt->enabled) {
+		spin_unlock(&target_list_lock);
+		return -EINVAL;
+	}
 	nt->np.local_port = simple_strtol(buf, NULL, 10);
 	spin_unlock(&target_list_lock);
 
@@ -142,6 +152,10 @@ static ssize_t store_remote_port(struct 
 				size_t count)
 {
 	spin_lock(&target_list_lock);
+	if (nt->enabled) {
+		spin_unlock(&target_list_lock);
+		return -EINVAL;
+	}
 	nt->np.remote_port = simple_strtol(buf, NULL, 10);
 	spin_unlock(&target_list_lock);
 
@@ -152,6 +166,10 @@ static ssize_t store_local_ip(struct net
 			      size_t count)
 {
 	spin_lock(&target_list_lock);
+	if (nt->enabled) {
+		spin_unlock(&target_list_lock);
+		return -EINVAL;
+	}
 	nt->np.local_ip = ntohl(in_aton(buf));
 	spin_unlock(&target_list_lock);
 
@@ -162,6 +180,10 @@ static ssize_t store_remote_ip(struct ne
 			       size_t count)
 {
 	spin_lock(&target_list_lock);
+	if (nt->enabled) {
+		spin_unlock(&target_list_lock);
+		return -EINVAL;
+	}
 	nt->np.remote_ip = ntohl(in_aton(buf));
 	spin_unlock(&target_list_lock);
 
@@ -184,12 +206,39 @@ static ssize_t store_remote_mac(struct n
 	if (i != ETH_ALEN)
 		return -EINVAL;
 	spin_lock(&target_list_lock);
+	if (nt->enabled) {
+		spin_unlock(&target_list_lock);
+		return -EINVAL;
+	}
 	memcpy(nt->np.remote_mac, input_mac, ETH_ALEN);
 	spin_unlock(&target_list_lock);
 
 	return count;
 }
 
+static ssize_t store_enabled(struct netconsole_target *nt, const char *buf,
+			    size_t count)
+{
+	int enabled = 0;
+
+	if (count >= 2 && (count != 2 || buf[count - 1] != '\n')) {
+		printk(KERN_ERR "netconsole: invalid argument: %s\n", buf);
+		return -EINVAL;
+	} else if (strncmp(buf, "1", 1) == 0) {
+		enabled = 1;
+	} else if(strncmp(buf, "0", 1) == 0) {
+		enabled = 0;
+	} else {
+		printk(KERN_ERR "netconsole: invalid argument: %s\n", buf);
+		return -EINVAL;
+	}
+	spin_lock(&target_list_lock);
+	nt->enabled = enabled;
+	spin_unlock(&target_list_lock);
+
+	return count;
+}
+
 #define NETCON_CLASS_ATTR(_name, _mode, _show, _store) \
 struct target_attr target_attr_##_name = \
                            __ATTR(_name, _mode, _show, _store)
@@ -206,6 +255,8 @@ static NETCON_CLASS_ATTR(remote_ip, S_IR
 static NETCON_CLASS_ATTR(local_mac, S_IRUGO, show_local_mac, NULL);
 static NETCON_CLASS_ATTR(remote_mac, S_IRUGO | S_IWUSR,
 			 show_remote_mac, store_remote_mac);
+static NETCON_CLASS_ATTR(enabled, S_IRUGO | S_IWUSR,
+			 show_enabled, store_enabled);
 
 static struct attribute *target_attrs[] = {
 	&target_attr_id.attr,
@@ -215,6 +266,7 @@ static struct attribute *target_attrs[] 
 	&target_attr_remote_ip.attr,
 	&target_attr_local_mac.attr,
 	&target_attr_remote_mac.attr,
+	&target_attr_enabled.attr,
 	NULL
 };
 
@@ -313,6 +365,7 @@ static int add_target(char* target_confi
 
 	atomic_inc(&target_count);
 	new_target->id = atomic_read(&target_count);
+	new_target->enabled = 1;
 
 	printk(KERN_INFO "netconsole: add target: "
 	       "remote ip_addr=%d.%d.%d.%d remote port=%d\n",
@@ -420,7 +473,8 @@ static void write_msg(struct console *co
 	for(left = len; left; ) {
 		frag = min(left, MAX_PRINT_CHUNK);
 		list_for_each_entry(target, &target_list, list) {
-			netpoll_send_udp(&target->np, msg, frag);
+			if (target->enabled)
+				netpoll_send_udp(&target->np, msg, frag);
 		}
 		msg += frag;
 		left -= frag;

-- 


