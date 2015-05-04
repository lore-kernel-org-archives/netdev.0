From: Tejun Heo <tj@kernel.org>
Subject: [PATCH v3 3/3] netconsole: implement extended console support
Date: Mon, 4 May 2015 16:04:56 -0400
Message-ID: <20150504200456.GI1971@htj.duckdns.org>
References: <1430505220-25160-1-git-send-email-tj@kernel.org>
 <1430505220-25160-4-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net, akpm@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1430505220-25160-4-git-send-email-tj@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>From f9530ac244c12a89837736269a1930291a360875 Mon Sep 17 00:00:00 2001
From: Tejun Heo <tj@kernel.org>
Date: Mon, 4 May 2015 15:57:54 -0400

printk logbuf keeps various metadata and optional key=value dictionary
for structured messages, both of which are stripped when messages are
handed to regular console drivers.

It can be useful to have this metadata and dictionary available to
netconsole consumers.  This obviously makes logging via netconsole
more complete and the sequence number in particular is useful in
environments where messages may be lost or reordered in transit -
e.g. when netconsole is used to collect messages in a large cluster
where packets may have to travel congested hops to reach the
aggregator.  The lost and reordered messages can easily be identified
and handled accordingly using the sequence numbers.

printk recently added extended console support which can be selected
by setting CON_EXTENDED flag.  From console driver side, not much
changes.  The only difference is that the text passed to the write
callback is formatted the same way as /dev/kmsg.

This patch implements extended console support for netconsole which
can be enabled by either prepending "+" to a netconsole boot param
entry or echoing 1 to "extended" file in configfs.  When enabled,
netconsole transmits extended log messages with headers identical to
/dev/kmsg output.

There's one complication due to message fragments.  netconsole limits
the maximum message size to 1k and messages longer than that are split
into multiple fragments.  As all extended console messages should
carry matching headers and be uniquely identifiable, each extended
message fragment carries full copy of the metadata and an extra header
field to identify the specific fragment.  The optional header is of
the form "ncfrag=OFF/LEN" where OFF is the byte offset into the
message body and LEN is the total length.

To avoid unnecessarily making printk format extended messages,
Extended netconsole is registered with printk when the first extended
netconsole is configured.

v3: Tweaked documentation to make clarify that the example assumes a
    lot smaller chunk size.  Updated to apply on top of spurious
    target get/put removal in write_msg().

v2: Dropped dynamic unregistration of extended console driver, which
    added complexity while not being too beneficial given that most
    netconsole configurations are static.  ncfrag updated to use just
    byte offset and message length.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: David Miller <davem@davemloft.net>
---
Hello,

If anyone wants the whole series to be reposted, please let me know.
The updated patchset is available in the following git branch.

 git://git.kernel.org/pub/scm/linux/kernel/git/tj/misc.git review-netconsole-ext-console

Thanks.

 Documentation/networking/netconsole.txt |  35 +++++++-
 drivers/net/netconsole.c                | 149 +++++++++++++++++++++++++++++++-
 2 files changed, 181 insertions(+), 3 deletions(-)

diff --git a/Documentation/networking/netconsole.txt b/Documentation/networking/netconsole.txt
index a5d574a..30409a3 100644
--- a/Documentation/networking/netconsole.txt
+++ b/Documentation/networking/netconsole.txt
@@ -2,6 +2,7 @@
 started by Ingo Molnar <mingo@redhat.com>, 2001.09.17
 2.6 port and netpoll api by Matt Mackall <mpm@selenic.com>, Sep 9 2003
 IPv6 support by Cong Wang <xiyou.wangcong@gmail.com>, Jan 1 2013
+Extended console support by Tejun Heo <tj@kernel.org>, May 1 2015
 
 Please send bug reports to Matt Mackall <mpm@selenic.com>
 Satyam Sharma <satyam.sharma@gmail.com>, and Cong Wang <xiyou.wangcong@gmail.com>
@@ -24,9 +25,10 @@ Sender and receiver configuration:
 It takes a string configuration parameter "netconsole" in the
 following format:
 
- netconsole=[src-port]@[src-ip]/[<dev>],[tgt-port]@<tgt-ip>/[tgt-macaddr]
+ netconsole=[+][src-port]@[src-ip]/[<dev>],[tgt-port]@<tgt-ip>/[tgt-macaddr]
 
    where
+        +             if present, enable extended console support
         src-port      source for UDP packets (defaults to 6665)
         src-ip        source IP to use (interface address)
         dev           network interface (eth0)
@@ -107,6 +109,7 @@ To remove a target:
 The interface exposes these parameters of a netconsole target to userspace:
 
 	enabled		Is this target currently enabled?	(read-write)
+	extended	Extended mode enabled			(read-write)
 	dev_name	Local network interface name		(read-write)
 	local_port	Source UDP port to use			(read-write)
 	remote_port	Remote agent's UDP port			(read-write)
@@ -132,6 +135,36 @@ You can also update the local interface dynamically. This is especially
 useful if you want to use interfaces that have newly come up (and may not
 have existed when netconsole was loaded / initialized).
 
+Extended console:
+=================
+
+If '+' is prefixed to the configuration line or "extended" config file
+is set to 1, extended console support is enabled. An example boot
+param follows.
+
+ linux netconsole=+4444@10.0.0.1/eth1,9353@10.0.0.2/12:34:56:78:9a:bc
+
+Log messages are transmitted with extended metadata header in the
+following format which is the same as /dev/kmsg.
+
+ <level>,<sequnum>,<timestamp>,<contflag>;<message text>
+
+Non printable characters in <message text> are escaped using "\xff"
+notation. If the message contains optional dictionary, verbatim
+newline is used as the delimeter.
+
+If a message doesn't fit in certain number of bytes (currently 1000),
+the message is split into multiple fragments by netconsole. These
+fragments are transmitted with "ncfrag" header field added.
+
+ ncfrag=<byte-offset>/<total-bytes>
+
+For example, assuming a lot smaller chunk size, a message "the first
+chunk, the 2nd chunk." may be split as follows.
+
+ 6,416,1758426,-,ncfrag=0/31;the first chunk,
+ 6,416,1758426,-,ncfrag=16/31; the 2nd chunk.
+
 Miscellaneous notes:
 ====================
 
diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
index 9b0c81e..cbc0654 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -79,6 +79,12 @@ static LIST_HEAD(target_list);
 /* This needs to be a spinlock because write_msg() cannot sleep */
 static DEFINE_SPINLOCK(target_list_lock);
 
+/*
+ * Console driver for extended netconsoles.  Registered on the first use to
+ * avoid unnecessarily enabling ext message formatting.
+ */
+static struct console netconsole_ext;
+
 /**
  * struct netconsole_target - Represents a configured netconsole target.
  * @list:	Links this target into the target_list.
@@ -105,6 +111,7 @@ struct netconsole_target {
 	struct config_item	item;
 #endif
 	bool			enabled;
+	bool			extended;
 	struct netpoll		np;
 };
 
@@ -187,6 +194,11 @@ static struct netconsole_target *alloc_param_target(char *target_config)
 	nt->np.remote_port = 6666;
 	eth_broadcast_addr(nt->np.remote_mac);
 
+	if (*target_config == '+') {
+		nt->extended = true;
+		target_config++;
+	}
+
 	/* Parse parameters and setup netpoll */
 	err = netpoll_parse_options(&nt->np, target_config);
 	if (err)
@@ -257,6 +269,11 @@ static ssize_t show_enabled(struct netconsole_target *nt, char *buf)
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
@@ -328,6 +345,11 @@ static ssize_t store_enabled(struct netconsole_target *nt,
 	}
 
 	if (enabled) {	/* true */
+		if (nt->extended && !(netconsole_ext.flags & CON_ENABLED)) {
+			netconsole_ext.flags |= CON_ENABLED;
+			register_console(&netconsole_ext);
+		}
+
 		/*
 		 * Skip netpoll_parse_options() -- all the attributes are
 		 * already configured via configfs. Just print them out.
@@ -355,6 +377,30 @@ static ssize_t store_enabled(struct netconsole_target *nt,
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
@@ -507,6 +553,7 @@ static struct netconsole_target_attr netconsole_target_##_name =	\
 	__CONFIGFS_ATTR(_name, S_IRUGO | S_IWUSR, show_##_name, store_##_name)
 
 NETCONSOLE_TARGET_ATTR_RW(enabled);
+NETCONSOLE_TARGET_ATTR_RW(extended);
 NETCONSOLE_TARGET_ATTR_RW(dev_name);
 NETCONSOLE_TARGET_ATTR_RW(local_port);
 NETCONSOLE_TARGET_ATTR_RW(remote_port);
@@ -517,6 +564,7 @@ NETCONSOLE_TARGET_ATTR_RW(remote_mac);
 
 static struct configfs_attribute *netconsole_target_attrs[] = {
 	&netconsole_target_enabled.attr,
+	&netconsole_target_extended.attr,
 	&netconsole_target_dev_name.attr,
 	&netconsole_target_local_port.attr,
 	&netconsole_target_remote_port.attr,
@@ -727,6 +775,90 @@ static struct notifier_block netconsole_netdev_notifier = {
 	.notifier_call  = netconsole_netdev_event,
 };
 
+/**
+ * send_ext_msg_udp - send extended log message to target
+ * @nt: target to send message to
+ * @msg: extended log message to send
+ * @msg_len: length of message
+ *
+ * Transfer extended log @msg to @nt.  If @msg is longer than
+ * MAX_PRINT_CHUNK, it'll be split and transmitted in multiple chunks with
+ * ncfrag header field added to identify them.
+ */
+static void send_ext_msg_udp(struct netconsole_target *nt, const char *msg,
+			     int msg_len)
+{
+	static char buf[MAX_PRINT_CHUNK];
+	const int max_extra_len = sizeof(",ncfrag=0000/0000");
+	const char *header, *body;
+	int header_len = msg_len, body_len = 0;
+	int chunk_len, nr_chunks, i;
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
+	 * "ncfrag=<byte-offset>/<total-bytes>" to identify each chunk.
+	 */
+	memcpy(buf, header, header_len);
+	nr_chunks = DIV_ROUND_UP(body_len, chunk_len);
+
+	for (i = 0; i < nr_chunks; i++) {
+		int offset = i * chunk_len;
+		int this_header = header_len;
+		int this_chunk = min(body_len - offset, chunk_len);
+
+		if (nr_chunks > 1)
+			this_header += scnprintf(buf + this_header,
+						 sizeof(buf) - this_header,
+						 ",ncfrag=%d/%d;",
+						 offset, body_len);
+
+		if (WARN_ON_ONCE(this_header + chunk_len > MAX_PRINT_CHUNK))
+			return;
+
+		memcpy(buf + this_header, body, this_chunk);
+
+		netpoll_send_udp(&nt->np, buf, this_header + this_chunk);
+
+		body += this_chunk;
+	}
+}
+
+static void write_ext_msg(struct console *con, const char *msg,
+			  unsigned int len)
+{
+	struct netconsole_target *nt;
+	unsigned long flags;
+
+	if ((oops_only && !oops_in_progress) || list_empty(&target_list))
+		return;
+
+	spin_lock_irqsave(&target_list_lock, flags);
+	list_for_each_entry(nt, &target_list, list)
+		if (nt->extended && nt->enabled && netif_running(nt->np.dev))
+			send_ext_msg_udp(nt, msg, len);
+	spin_unlock_irqrestore(&target_list_lock, flags);
+}
+
 static void write_msg(struct console *con, const char *msg, unsigned int len)
 {
 	int frag, left;
@@ -742,7 +874,7 @@ static void write_msg(struct console *con, const char *msg, unsigned int len)
 
 	spin_lock_irqsave(&target_list_lock, flags);
 	list_for_each_entry(nt, &target_list, list) {
-		if (nt->enabled && netif_running(nt->np.dev)) {
+		if (!nt->extended && nt->enabled && netif_running(nt->np.dev)) {
 			/*
 			 * We nest this inside the for-each-target loop above
 			 * so that we're able to get as much logging out to
@@ -761,6 +893,12 @@ static void write_msg(struct console *con, const char *msg, unsigned int len)
 	spin_unlock_irqrestore(&target_list_lock, flags);
 }
 
+static struct console netconsole_ext = {
+	.name	= "netcon_ext",
+	.flags	= CON_EXTENDED,	/* starts disabled, registered on first use */
+	.write	= write_ext_msg,
+};
+
 static struct console netconsole = {
 	.name	= "netcon",
 	.flags	= CON_ENABLED,
@@ -783,7 +921,11 @@ static int __init init_netconsole(void)
 				goto fail;
 			}
 			/* Dump existing printks when we register */
-			netconsole.flags |= CON_PRINTBUFFER;
+			if (nt->extended)
+				netconsole_ext.flags |= CON_PRINTBUFFER |
+							CON_ENABLED;
+			else
+				netconsole.flags |= CON_PRINTBUFFER;
 
 			spin_lock_irqsave(&target_list_lock, flags);
 			list_add(&nt->list, &target_list);
@@ -799,6 +941,8 @@ static int __init init_netconsole(void)
 	if (err)
 		goto undonotifier;
 
+	if (netconsole_ext.flags & CON_ENABLED)
+		register_console(&netconsole_ext);
 	register_console(&netconsole);
 	pr_info("network logging started\n");
 
@@ -827,6 +971,7 @@ static void __exit cleanup_netconsole(void)
 {
 	struct netconsole_target *nt, *tmp;
 
+	unregister_console(&netconsole_ext);
 	unregister_console(&netconsole);
 	dynamic_netconsole_exit();
 	unregister_netdevice_notifier(&netconsole_netdev_notifier);
-- 
2.1.0
