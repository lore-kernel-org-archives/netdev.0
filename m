From: Keiichi KII <k-keiichi@bx.jp.nec.com>
Subject: [RFC][PATCH -mm take5 5/7] switch function of netpoll
Date: Wed, 13 Jun 2007 19:30:02 +0900
Message-ID: <466FC72A.3090508@bx.jp.nec.com>
References: <466FC455.5060001@bx.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Matt Mackall <mpm@selenic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO201.gate.nec.co.jp ([202.32.8.193]:57027 "EHLO
	tyo201.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757251AbXFMKaV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2007 06:30:21 -0400
In-Reply-To: <466FC455.5060001@bx.jp.nec.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Keiichi KII <k-keiichi@bx.jp.nec.com>

This patch contains switch function of netpoll.

If "enabled" attribute of certain port is '1', this port is used
and the configurations of this port are unable to change.

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
Index: mm/drivers/net/netconsole.c
===================================================================
--- mm.orig/drivers/net/netconsole.c
+++ mm/drivers/net/netconsole.c
@@ -71,6 +71,7 @@ struct netconsole_target {
 	struct list_head list;
 	struct kobject obj;
 	int id;
+	int enabled;
 	struct netpoll np;
 };
 
@@ -121,9 +122,16 @@ static ssize_t show_remote_mac(struct ne
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
+	if (nt->enabled)
+		return -EINVAL;
 	nt->np.local_port = simple_strtol(buf, NULL, 10);
 
 	return count;
@@ -132,6 +140,8 @@ static ssize_t store_local_port(struct n
 static ssize_t store_remote_port(struct netconsole_target *nt, const char *buf,
 				size_t count)
 {
+	if (nt->enabled)
+		return -EINVAL;
 	nt->np.remote_port = simple_strtol(buf, NULL, 10);
 
 	return count;
@@ -140,6 +150,8 @@ static ssize_t store_remote_port(struct 
 static ssize_t store_local_ip(struct netconsole_target *nt, const char *buf,
 			      size_t count)
 {
+	if (nt->enabled)
+		return -EINVAL;
 	nt->np.local_ip = ntohl(in_aton(buf));
 
 	return count;
@@ -148,6 +160,8 @@ static ssize_t store_local_ip(struct net
 static ssize_t store_remote_ip(struct netconsole_target *nt, const char *buf,
 			       size_t count)
 {
+	if (nt->enabled)
+		return -EINVAL;
 	nt->np.remote_ip = ntohl(in_aton(buf));
 
 	return count;
@@ -166,13 +180,34 @@ static ssize_t store_remote_mac(struct n
 		cur++;
 		input_mac[i++] = simple_strtol(cur, NULL, 16);
 	}
-	if (i != ETH_ALEN)
+	if (i != ETH_ALEN || nt->enabled)
 		return -EINVAL;
 	memcpy(nt->np.remote_mac, input_mac, ETH_ALEN);
 
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
+	} else if (buf[0] == '1')
+		enabled = 1;
+	else if (buf[0] == '0')
+		enabled = 0;
+	else {
+		printk(KERN_ERR "netconsole: invalid argument: %s\n", buf);
+		return -EINVAL;
+	}
+	nt->enabled = enabled;
+
+	return count;
+}
+
 struct target_attr {
 	struct attribute attr;
 	ssize_t (*show)(struct netconsole_target*, char*);
@@ -196,6 +231,8 @@ static NETCON_CLASS_ATTR(remote_ip, S_IR
 static NETCON_CLASS_ATTR(local_mac, S_IRUGO, show_local_mac, NULL);
 static NETCON_CLASS_ATTR(remote_mac, S_IRUGO | S_IWUSR,
 			 show_remote_mac, store_remote_mac);
+static NETCON_CLASS_ATTR(enabled, S_IRUGO | S_IWUSR,
+			 show_enabled, store_enabled);
 
 static struct attribute *target_attrs[] = {
 	&target_attr_id.attr,
@@ -205,6 +242,7 @@ static struct attribute *target_attrs[] 
 	&target_attr_remote_ip.attr,
 	&target_attr_local_mac.attr,
 	&target_attr_remote_mac.attr,
+	&target_attr_enabled.attr,
 	NULL
 };
 
@@ -336,6 +374,7 @@ static int add_target(char* target_confi
 	}
 
 	new_target->id = atomic_inc_return(&target_count);
+	new_target->enabled = 1;
 
 	printk(KERN_INFO "netconsole: add target: "
 	       "remote ip_addr=%d.%d.%d.%d remote port=%d\n",
@@ -420,7 +459,8 @@ static void write_msg(struct console *co
 	for (left = len; left; ) {
 		frag = min(left, MAX_PRINT_CHUNK);
 		list_for_each_entry(target, &target_list, list)
-			netpoll_send_udp(&target->np, msg, frag);
+			if (target->enabled)
+				netpoll_send_udp(&target->np, msg, frag);
 		msg += frag;
 		left -= frag;
 	}

-- 


