From: Mike Waychison <mikew@google.com>
Subject: [PATCH v3 21/22] netoops: Add user-programmable boot_id
Date: Tue, 14 Dec 2010 13:30:49 -0800
Message-ID: <20101214213048.17022.58746.stgit@mike.mtv.corp.google.com>
References: <20101214212846.17022.64836.stgit@mike.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: adurbin@google.com, linux-kernel@vger.kernel.org,
	chavey@google.com, Greg KH <greg@kroah.com>,
	netdev@vger.kernel.org,
	=?utf-8?q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>,
	akpm@linux-foundation.org, linux-api@vger.kernel.org
To: simon.kagstrom@netinsight.net, davem@davemloft.net,
	nhorman@tuxdriver.com, Matt Mackall <mpm@selenic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101214212846.17022.64836.stgit@mike.mtv.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add support for letting userland define a 32bit boot id.  This is useful
for users to be able to correlate netoops reports to specific boot
instances offline.

Signed-off-by: Mike Waychison <mikew@google.com>
---
Changelog:
- v3
  - boot_id is always little-endian on the network.
  - This patch adds a dependency on sysfs.  Declare the dependency in
    the Kconfig.
---
 drivers/net/Kconfig   |    1 +
 drivers/net/netoops.c |   64 ++++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 64 insertions(+), 1 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 0e9fae3..0098124 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -3396,6 +3396,7 @@ config NETCONSOLE_DYNAMIC
 
 config NETOOPS
 	tristate "Network oops support"
+	depends on SYSFS
 	select NETPOLL_TARGETS
 	select NETPOLL_TARGETS_DYNAMIC
 	help
diff --git a/drivers/net/netoops.c b/drivers/net/netoops.c
index f7665ad..6c4c0f2 100644
--- a/drivers/net/netoops.c
+++ b/drivers/net/netoops.c
@@ -91,6 +91,7 @@ struct netoops_msg {
 		__le16 type;
 		__le32 packet_count;
 		__le32 packet_no;
+		__le32 boot_id;
 		/*
 		 * NOTE: fixed length strings for a packet.  NULL
 		 * termination not required.
@@ -103,6 +104,8 @@ struct netoops_msg {
 
 static struct netoops_msg msg;
 
+static u32 netoops_boot_id;
+
 static void setup_packet_header(int packet_count, struct pt_regs *regs,
 				int soft_dump)
 {
@@ -116,6 +119,7 @@ static void setup_packet_header(int packet_count, struct pt_regs *regs,
 	h->type = cpu_to_le16(soft_dump ? NETOOPS_TYPE_PRINTK_BUFFER_SOFT :
 					  NETOOPS_TYPE_PRINTK_BUFFER);
 	h->packet_count = cpu_to_le32(packet_count);
+	h->boot_id = cpu_to_le32(netoops_boot_id);
 	strncpy(h->kernel_version, utsname()->release,
 		min(sizeof(msg.header.kernel_version),
 		    sizeof(utsname()->release)));
@@ -217,6 +221,49 @@ static void netoops(struct kmsg_dumper *dumper, enum kmsg_dump_reason reason,
 	spin_unlock_irqrestore(&targets.lock, flags);
 }
 
+static ssize_t netoops_show(struct kobject *kobj,
+			    struct kobj_attribute *attr,
+			    char *buf) {
+	if (!strcmp(attr->attr.name, "netoops_boot_id"))
+		snprintf(buf, PAGE_SIZE, "%d\n", netoops_boot_id);
+	buf[PAGE_SIZE - 1] = '\0';
+	return strnlen(buf, PAGE_SIZE);
+}
+
+static ssize_t netoops_store(struct kobject *kobj,
+			     struct kobj_attribute *attr,
+			     const char *buf,
+			     size_t count) {
+	if (!count)
+		return count;
+
+	if (!strcmp(attr->attr.name, "netoops_boot_id")) {
+		unsigned long tmp;
+		if (strict_strtoul(buf, 0, &tmp))
+			return -EINVAL;
+		if (tmp > UINT_MAX)
+			printk("Warning: truncating boot_id to 32bits.");
+		netoops_boot_id = tmp;
+	} else
+		return -EINVAL;
+
+	return count;
+}
+
+static struct kobj_attribute netoops_boot_number_attribute =
+	__ATTR(netoops_boot_id, 0666, netoops_show, netoops_store);
+
+static struct attribute *attrs[] = {
+	&netoops_boot_number_attribute.attr,
+	NULL,
+};
+
+static struct attribute_group attr_group = {
+	.attrs = attrs,
+};
+
+static struct kobject *netoops_kobj;
+
 static struct kmsg_dumper netoops_dumper = {
 	.dump = netoops,
 };
@@ -233,6 +280,7 @@ static int __init netoops_init(void)
 	BUILD_BUG_ON(offsetof(struct netoops_msg, header.type) != 10);
 	BUILD_BUG_ON(offsetof(struct netoops_msg, header.packet_count) != 12);
 	BUILD_BUG_ON(offsetof(struct netoops_msg, header.packet_no) != 16);
+	BUILD_BUG_ON(offsetof(struct netoops_msg, header.boot_id) != 20);
 
 	targets.default_local_port = NETOOPS_PORT;
 	targets.default_remote_port = NETOOPS_PORT;
@@ -242,11 +290,23 @@ static int __init netoops_init(void)
 	if (retval)
 		goto out;
 
+	netoops_kobj = kobject_create_and_add("netoops", kernel_kobj);
+	if (!netoops_kobj)
+		goto out_targets;
+
+	retval = sysfs_create_group(netoops_kobj, &attr_group);
+	if (retval)
+		goto out_kobj;
+
 	retval = kmsg_dump_register(&netoops_dumper);
 	if (retval)
-		goto out_targets;
+		goto out_sysfs_group;
 
 	return 0;
+out_sysfs_group:
+	sysfs_remove_group(netoops_kobj, &attr_group);
+out_kobj:
+	kobject_put(netoops_kobj);
 out_targets:
 	unregister_netpoll_targets(&targets);
 out:
@@ -256,6 +316,8 @@ out:
 static void __exit netoops_exit(void)
 {
 	kmsg_dump_unregister(&netoops_dumper);
+	sysfs_remove_group(netoops_kobj, &attr_group);
+	kobject_put(netoops_kobj);
 	unregister_netpoll_targets(&targets);
 }
 
