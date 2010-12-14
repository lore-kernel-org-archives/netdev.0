From: Mike Waychison <mikew@google.com>
Subject: [PATCH v3 22/22] netoops: Add a user programmable blob to the netoops
	packet.
Date: Tue, 14 Dec 2010 13:30:55 -0800
Message-ID: <20101214213054.17022.64736.stgit@mike.mtv.corp.google.com>
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

In our environment, it is important for us to capture motherboard name
and firmware version for consideration when analyzing netoops dumps.

We would like to collect this information in userland at system startup
(in platform specific ways) and plug this information into the netoops
driver via /sys/kernel/netoops/netoops_user_blob.

Files introduced:
  /sys/kernel/netoops/netoops_user_blob

Signed-off-by: Mike Waychison <mikew@google.com>
---
Changelog:
- v3
  - Rewritten to support an opaque user blob, rather than fw_version and
    board_name specifically.
---
 drivers/net/netoops.c |   28 ++++++++++++++++++++++++----
 1 files changed, 24 insertions(+), 4 deletions(-)

diff --git a/drivers/net/netoops.c b/drivers/net/netoops.c
index 6c4c0f2..036e4d8 100644
--- a/drivers/net/netoops.c
+++ b/drivers/net/netoops.c
@@ -29,6 +29,7 @@
 #define NETOOPS_VERSION 0x0003
 #define NETOOPS_PORT 2004
 #define NETOOPS_RETRANSMIT_COUNT 3
+#define NETOOPS_BLOB_BYTES (size_t)128
 
 static DEFINE_NETPOLL_TARGETS(targets);
 
@@ -97,6 +98,11 @@ struct netoops_msg {
 		 * termination not required.
 		 */
 		char kernel_version[64];
+		/*
+		 * Data that comes from userland.  Can be anything, but
+		 * is currently capped at NETOOPS_BLOB_BYTES.
+		 */
+		char user_blob[NETOOPS_BLOB_BYTES];
 	} __attribute__ ((packed)) header;
 	struct netoops_arch_data arch_data;
 	char data[NETOOPS_DATA_BYTES];
@@ -104,6 +110,8 @@ struct netoops_msg {
 
 static struct netoops_msg msg;
 
+static size_t netoops_user_blob_length;
+static char netoops_user_blob[NETOOPS_BLOB_BYTES];
 static u32 netoops_boot_id;
 
 static void setup_packet_header(int packet_count, struct pt_regs *regs,
@@ -120,6 +128,7 @@ static void setup_packet_header(int packet_count, struct pt_regs *regs,
 					  NETOOPS_TYPE_PRINTK_BUFFER);
 	h->packet_count = cpu_to_le32(packet_count);
 	h->boot_id = cpu_to_le32(netoops_boot_id);
+	memcpy(h->user_blob, netoops_user_blob, netoops_user_blob_length);
 	strncpy(h->kernel_version, utsname()->release,
 		min(sizeof(msg.header.kernel_version),
 		    sizeof(utsname()->release)));
@@ -224,10 +233,15 @@ static void netoops(struct kmsg_dumper *dumper, enum kmsg_dump_reason reason,
 static ssize_t netoops_show(struct kobject *kobj,
 			    struct kobj_attribute *attr,
 			    char *buf) {
-	if (!strcmp(attr->attr.name, "netoops_boot_id"))
+	if (!strcmp(attr->attr.name, "netoops_user_blob")) {
+		memcpy(buf, netoops_user_blob, netoops_user_blob_length);
+		return netoops_user_blob_length;
+	}
+	if (!strcmp(attr->attr.name, "netoops_boot_id")) {
 		snprintf(buf, PAGE_SIZE, "%d\n", netoops_boot_id);
-	buf[PAGE_SIZE - 1] = '\0';
-	return strnlen(buf, PAGE_SIZE);
+		return strnlen(buf, PAGE_SIZE);
+	}
+	return -EINVAL;
 }
 
 static ssize_t netoops_store(struct kobject *kobj,
@@ -237,7 +251,10 @@ static ssize_t netoops_store(struct kobject *kobj,
 	if (!count)
 		return count;
 
-	if (!strcmp(attr->attr.name, "netoops_boot_id")) {
+	if (!strcmp(attr->attr.name, "netoops_user_blob")) {
+		count = min(count, NETOOPS_BLOB_BYTES);
+		memcpy(netoops_user_blob, buf, count);
+	} else if (!strcmp(attr->attr.name, "netoops_boot_id")) {
 		unsigned long tmp;
 		if (strict_strtoul(buf, 0, &tmp))
 			return -EINVAL;
@@ -250,10 +267,13 @@ static ssize_t netoops_store(struct kobject *kobj,
 	return count;
 }
 
+static struct kobj_attribute netoops_user_blob_attribute =
+	__ATTR(netoops_user_blob, 0644, netoops_show, netoops_store);
 static struct kobj_attribute netoops_boot_number_attribute =
 	__ATTR(netoops_boot_id, 0666, netoops_show, netoops_store);
 
 static struct attribute *attrs[] = {
+	&netoops_user_blob_attribute.attr,
 	&netoops_boot_number_attribute.attr,
 	NULL,
 };
