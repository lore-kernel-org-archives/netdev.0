From: Mike Waychison <mikew@google.com>
Subject: [PATCH v3 20/22] netoops: Add x86 specific bits to packet headers
Date: Tue, 14 Dec 2010 13:30:43 -0800
Message-ID: <20101214213043.17022.66195.stgit@mike.mtv.corp.google.com>
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

We need to be able to gather information about the CPUs that caused the
crash.  Rather than hope that the data is available in the dmesg
recieved, and is still parsable, send a binary representation in each
packet.  This allows us to quickly identify crashes even in cases where
we crash and burn as part of the netoops process (or if we timeout
asynchronously on a hardware watchdog).

This commit only handles x86, but it should be easy to add any
per-architecture specific information going forward in a compatible way.

Signed-off-by: Mike Waychison <mikew@google.com>
---
Changelog:
- v3
  - Added x86 vendor to the packet header.
  - Split out the arch specific data into its own data structure.  Only
    x86 is available at the moment.  This data will want to transition
    into per-arch code at some point.
---
 drivers/net/netoops.c |   26 +++++++++++++++++++++++---
 1 files changed, 23 insertions(+), 3 deletions(-)

diff --git a/drivers/net/netoops.c b/drivers/net/netoops.c
index 1940ea5..f7665ad 100644
--- a/drivers/net/netoops.c
+++ b/drivers/net/netoops.c
@@ -52,8 +52,25 @@ __setup("netoops=", option_setup);
 #if defined(__i386__) || defined(__x86_64__)
 #define NETOOPS_ARCH 2
 struct netoops_arch_data {
-
+	u8 x86_vendor;
+	u8 x86_family;
+	u8 x86_model;
+	u8 x86_stepping;
+	/* NOTE: regs is 60 or 168 bytes */
+	struct pt_regs regs;
 } __attribute__((packed));
+
+static void setup_packet_arch_data(struct netoops_arch_data *arch_data,
+				   struct pt_regs *regs) {
+	arch_data->x86_vendor   = current_cpu_data.x86_vendor;
+	arch_data->x86_family   = current_cpu_data.x86;
+	arch_data->x86_model    = current_cpu_data.x86_model;
+	arch_data->x86_stepping = current_cpu_data.x86_mask;
+	if (regs != NULL)
+		memcpy(&arch_data->regs, regs, sizeof(arch_data->regs));
+	else
+		memset(&arch_data->regs, 0, sizeof(arch_data->regs));
+}
 #else
 #error "unsupported architecture"
 #endif
@@ -86,7 +103,8 @@ struct netoops_msg {
 
 static struct netoops_msg msg;
 
-static void setup_packet_header(int packet_count, int soft_dump)
+static void setup_packet_header(int packet_count, struct pt_regs *regs,
+				int soft_dump)
 {
 	typeof(msg.header) *h = &msg.header;
 
@@ -101,6 +119,8 @@ static void setup_packet_header(int packet_count, int soft_dump)
 	strncpy(h->kernel_version, utsname()->release,
 		min(sizeof(msg.header.kernel_version),
 		    sizeof(utsname()->release)));
+
+	setup_packet_arch_data(&msg.arch_data, regs);
 }
 
 static int packet_count_from_length(unsigned long l)
@@ -185,7 +205,7 @@ static void netoops(struct kmsg_dumper *dumper, enum kmsg_dump_reason reason,
 
 	/* setup the non varying parts of the message */
 	memset(&msg, 0, sizeof(msg));
-	setup_packet_header(packet_count_1 + packet_count_2, soft_dump);
+	setup_packet_header(packet_count_1 + packet_count_2, regs, soft_dump);
 
 	/* Transmission loop */
 	for (i = 0; i < NETOOPS_RETRANSMIT_COUNT; i++) {
