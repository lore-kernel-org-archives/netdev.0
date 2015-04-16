From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 12/16] netconsole: implement extended console support
Date: Thu, 16 Apr 2015 19:03:49 -0400
Message-ID: <1429225433-11946-13-git-send-email-tj@kernel.org>
References: <1429225433-11946-1-git-send-email-tj@kernel.org>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Tejun Heo <tj@kernel.org>
To: akpm@linux-foundation.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1429225433-11946-1-git-send-email-tj@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

netconsole transmits raw console messages using one or multiple UDP
packets and there's no way to find out whether the packets are lost in
transit or received out of order.  Depending on the setup, this can
make the logging significantly unreliable and untrustworthy.

With the new extended console support, printk now can be told to
expose log metadata including the message sequence number to console
drivers which can be used by log receivers to determine whether and
which messages are missing and reorder messages received out of order.

This patch implements extended console support for netconsole which
can be enabled by either prepending "+" to a netconsole boot param
entry or echoing 1 to "extended" file in configfs.  When enabled,
netconsole transmits extended log messages with headers identical to
/dev/kmsg output.

netconsole may have to split a single messages to multiple fragments.
In this case, if the extended mode is enabled, an optional header of
the form "ncfrag=OFF@IDX/NR" is added to each fragment where OFF is
the byte offset of the message body, IDX is the 0-based fragment index
and NR is the number of total fragments for this message.

To avoid unnecessarily forcing printk to format extended messages,
extended netconsole is registered with printk iff it's actually used.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: David Miller <davem@davemloft.net>
---
 drivers/net/netconsole.c | 159 ++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 158 insertions(+), 1 deletion(-)

diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
index d72d902..626d9f0 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -83,6 +83,10 @@ static LIST_HEAD(target_list);
 /* protects target creation/destruction and enable/disable */
 static DEFINE_MUTEX(netconsole_mutex);
 
+static bool netconsole_ext_used_during_init;
+static bool netconsole_ext_registered;
+static struct console netconsole_ext;
+
 static struct console netconsole;
 
 /**
@@ -112,6 +116,7 @@ struct netconsole_target {
 #endif
 	bool			enabled;
 	bool			disable_scheduled;
+	bool			extended;
 	struct netpoll		np;
 };
 
@@ -194,6 +199,81 @@ static struct netconsole_target *alloc_netconsole_target(void)
 	return nt;
 }
 
+/**
+ * send_ext_msg_udp - send extended log message to target
+ * @nt: target to send message to
+ * @msg: extended log message to send
+ * @msg_len: length of message
+ *
+ * Transfer extended log @msg to @nt.  If @msg is too long, it'll be split
+ * and transmitted in multiple chunks with ncfrag header field added to
+ * enable correct reassembly.
+ */
+static void send_ext_msg_udp(struct netconsole_target *nt, const char *msg,
+			     int msg_len)
+{
+	static char buf[MAX_PRINT_CHUNK];
+	const int max_extra_len = sizeof(",ncfrag=0000@00/00");
+	const char *header, *body;
+	int header_len = msg_len, body_len = 0;
+	int chunk_len, nr_chunks, i;
+
+	if (!nt->enabled || !netif_running(nt->np.dev))
+		return;
+
+	if (msg_len <= MAX_PRINT_CHUNK) {
+		netpoll_send_udp(&nt->np, msg, msg_len);
+		return;
+	}
+
+	/* need to insert extra header fields, detect header and body */
+	header = msg;
+	body = memchr(msg, ';', msg_len);
+	if (body) {
+		header_len = body - header;
+		body_len = msg_len - header_len - 1;
+		body++;
+	}
+
+	chunk_len = MAX_PRINT_CHUNK - header_len - max_extra_len;
+	if (WARN_ON_ONCE(chunk_len <= 0))
+		return;
+
+	/*
+	 * Transfer possibly multiple chunks with extra header fields.
+	 *
+	 * If @msg needs to be split to fit MAX_PRINT_CHUNK, add
+	 * "ncfrag=<byte-offset>@<0-based-chunk-index>/<total-chunks>" to
+	 * enable proper reassembly on receiver side.
+	 */
+	memcpy(buf, header, header_len);
+	nr_chunks = DIV_ROUND_UP(body_len, chunk_len);
+
+	for (i = 0; i < nr_chunks; i++) {
+		int this_header = header_len;
+		int this_chunk;
+
+		if (nr_chunks > 1)
+			this_header += scnprintf(buf + this_header,
+						 sizeof(buf) - this_header,
+						 ",ncfrag=%d@%d/%d",
+						 i * chunk_len, i, nr_chunks);
+		if (this_header < sizeof(buf))
+			buf[this_header++] = ';';
+
+		if (WARN_ON_ONCE(this_header + chunk_len > MAX_PRINT_CHUNK))
+			return;
+
+		this_chunk = min(body_len, chunk_len);
+		memcpy(buf + this_header, body, this_chunk);
+
+		netpoll_send_udp(&nt->np, buf, this_header + this_chunk);
+
+		body += this_chunk;
+		body_len -= this_chunk;
+	}
+}
+
 static int netconsole_enable(struct netconsole_target *nt)
 {
 	int err;
@@ -241,6 +321,11 @@ static int create_param_target(char *target_config)
 	if (!nt)
 		goto fail;
 
+	if (*target_config == '+') {
+		nt->extended = 1;
+		target_config++;
+	}
+
 	/* Parse parameters and setup netpoll */
 	err = netpoll_parse_options(&nt->np, target_config);
 	if (err)
@@ -255,7 +340,12 @@ static int create_param_target(char *target_config)
 		goto fail_del;
 
 	/* Dump existing printks when we register */
-	netconsole.flags |= CON_PRINTBUFFER;
+	if (nt->extended) {
+		netconsole_ext.flags |= CON_PRINTBUFFER;
+		netconsole_ext_used_during_init = true;
+	} else {
+		netconsole.flags |= CON_PRINTBUFFER;
+	}
 
 	return 0;
 
@@ -313,6 +403,11 @@ static ssize_t show_enabled(struct netconsole_target *nt, char *buf)
 	return snprintf(buf, PAGE_SIZE, "%d\n", nt->enabled);
 }
 
+static ssize_t show_extended(struct netconsole_target *nt, char *buf)
+{
+	return snprintf(buf, PAGE_SIZE, "%d\n", nt->extended);
+}
+
 static ssize_t show_dev_name(struct netconsole_target *nt, char *buf)
 {
 	return snprintf(buf, PAGE_SIZE, "%s\n", nt->np.dev_name);
@@ -401,6 +496,30 @@ static ssize_t store_enabled(struct netconsole_target *nt,
 	return strnlen(buf, count);
 }
 
+static ssize_t store_extended(struct netconsole_target *nt,
+			      const char *buf,
+			      size_t count)
+{
+	int extended;
+	int err;
+
+	if (nt->enabled) {
+		pr_err("target (%s) is enabled, disable to update parameters\n",
+		       config_item_name(&nt->item));
+		return -EINVAL;
+	}
+
+	err = kstrtoint(buf, 10, &extended);
+	if (err < 0)
+		return err;
+	if (extended < 0 || extended > 1)
+		return -EINVAL;
+
+	nt->extended = extended;
+
+	return strnlen(buf, count);
+}
+
 static ssize_t store_dev_name(struct netconsole_target *nt,
 			      const char *buf,
 			      size_t count)
@@ -553,6 +672,7 @@ static struct netconsole_target_attr netconsole_target_##_name =	\
 	__CONFIGFS_ATTR(_name, S_IRUGO | S_IWUSR, show_##_name, store_##_name)
 
 NETCONSOLE_TARGET_ATTR_RW(enabled);
+NETCONSOLE_TARGET_ATTR_RW(extended);
 NETCONSOLE_TARGET_ATTR_RW(dev_name);
 NETCONSOLE_TARGET_ATTR_RW(local_port);
 NETCONSOLE_TARGET_ATTR_RW(remote_port);
@@ -563,6 +683,7 @@ NETCONSOLE_TARGET_ATTR_RW(remote_mac);
 
 static struct configfs_attribute *netconsole_target_attrs[] = {
 	&netconsole_target_enabled.attr,
+	&netconsole_target_extended.attr,
 	&netconsole_target_dev_name.attr,
 	&netconsole_target_local_port.attr,
 	&netconsole_target_remote_port.attr,
@@ -645,9 +766,16 @@ static struct config_item *make_netconsole_target(struct config_group *group,
 
 	/* Adding, but it is disabled */
 	mutex_lock(&netconsole_mutex);
+
 	console_lock();
 	list_add(&nt->list, &target_list);
 	console_unlock();
+
+	if (nt->extended && !netconsole_ext_registered) {
+		register_console(&netconsole_ext);
+		netconsole_ext_registered = true;
+	}
+
 	mutex_unlock(&netconsole_mutex);
 
 	return &nt->item;
@@ -776,6 +904,19 @@ static struct notifier_block netconsole_netdev_notifier = {
 	.notifier_call  = netconsole_netdev_event,
 };
 
+static void write_ext_msg(struct console *con, const char *msg,
+			  unsigned int len)
+{
+	struct netconsole_target *nt;
+
+	if ((oops_only && !oops_in_progress) || list_empty(&target_list))
+		return;
+
+	list_for_each_entry(nt, &target_list, list)
+		if (nt->extended)
+			send_ext_msg_udp(nt, msg, len);
+}
+
 static void write_msg(struct console *con, const char *msg, unsigned int len)
 {
 	int frag, left;
@@ -789,6 +930,8 @@ static void write_msg(struct console *con, const char *msg, unsigned int len)
 		return;
 
 	list_for_each_entry(nt, &target_list, list) {
+		if (nt->extended)
+			continue;
 		if (nt->enabled && netif_running(nt->np.dev)) {
 			/*
 			 * We nest this inside the for-each-target loop above
@@ -807,6 +950,12 @@ static void write_msg(struct console *con, const char *msg, unsigned int len)
 	}
 }
 
+static struct console netconsole_ext = {
+	.name	= "netcon_ext",
+	.flags	= CON_ENABLED | CON_EXTENDED,
+	.write	= write_ext_msg,
+};
+
 static struct console netconsole = {
 	.name	= "netcon",
 	.flags	= CON_ENABLED,
@@ -851,6 +1000,11 @@ static int __init init_netconsole(void)
 	if (err)
 		goto undonotifier;
 
+	if (netconsole_ext_used_during_init) {
+		register_console(&netconsole_ext);
+		netconsole_ext_registered = true;
+	}
+
 	register_console(&netconsole);
 	pr_info("network logging started\n");
 
@@ -871,6 +1025,9 @@ static void __exit cleanup_netconsole(void)
 {
 	mutex_lock(&netconsole_mutex);
 
+	if (netconsole_ext_registered)
+		unregister_console(&netconsole_ext);
+
 	unregister_console(&netconsole);
 	dynamic_netconsole_exit();
 	unregister_netdevice_notifier(&netconsole_netdev_notifier);
-- 
2.1.0
