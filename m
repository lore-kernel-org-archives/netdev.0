From: Mike Waychison <mikew@google.com>
Subject: [PATCH v3 18/22] sys-rq: Add option to soft dump
Date: Tue, 14 Dec 2010 13:30:32 -0800
Message-ID: <20101214213032.17022.76191.stgit@mike.mtv.corp.google.com>
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

It is very useful to provide some means to force the kernel logs to make it out
via the kmsg_oops implementations on the console.  Add a new option 'Y' to
sysrq to allow dumping of logs to kmsg_dumper drivers.

Signed-off-by: Mike Waychison <mikew@google.com>
---
Changelog:
- v3
  - Added a note to Documentation/sysrq.txt about the command.

TODO: Figure out a better letter?  Can we reuse 'v'?
---
 Documentation/sysrq.txt |    4 ++++
 drivers/tty/sysrq.c     |   14 +++++++++++++-
 2 files changed, 17 insertions(+), 1 deletions(-)

diff --git a/Documentation/sysrq.txt b/Documentation/sysrq.txt
index 312e375..3c7ee87 100644
--- a/Documentation/sysrq.txt
+++ b/Documentation/sysrq.txt
@@ -118,6 +118,10 @@ On all -  write a character to /proc/sysrq-trigger.  e.g.:
 'x'	- Used by xmon interface on ppc/powerpc platforms.
 
 'y'	- Show global CPU Registers [SPARC-64 specific]
+'y'	- Trigger a 'soft' kmsg dump. Any kmsg_dump clients (mtdoops,
+          netoops, ramoops) will initiate a dump to their respective
+          backend.
+
 
 'z'	- Dump the ftrace buffer
 
diff --git a/drivers/tty/sysrq.c b/drivers/tty/sysrq.c
index c556ed9..f79f34a 100644
--- a/drivers/tty/sysrq.c
+++ b/drivers/tty/sysrq.c
@@ -41,6 +41,7 @@
 #include <linux/oom.h>
 #include <linux/slab.h>
 #include <linux/input.h>
+#include <linux/kmsg_dump.h>
 
 #include <asm/ptrace.h>
 #include <asm/irq_regs.h>
@@ -395,6 +396,17 @@ static struct sysrq_key_op sysrq_unrt_op = {
 	.enable_mask	= SYSRQ_ENABLE_RTNICE,
 };
 
+static void sysrq_handle_softdump(int key)
+{
+	kmsg_dump(KMSG_DUMP_SOFT, NULL);
+}
+static struct sysrq_key_op sysrq_softdump_op = {
+	.handler	= sysrq_handle_softdump,
+	.help_msg	= "soft-dump(Y)",
+	.action_msg	= "Trigger a soft dump",
+	.enable_mask	= SYSRQ_ENABLE_DUMP,
+};
+
 /* Key Operations table and lock */
 static DEFINE_SPINLOCK(sysrq_key_table_lock);
 
@@ -451,7 +463,7 @@ static struct sysrq_key_op *sysrq_key_table[36] = {
 	/* x: May be registered on ppc/powerpc for xmon */
 	NULL,				/* x */
 	/* y: May be registered on sparc64 for global register dump */
-	NULL,				/* y */
+	&sysrq_softdump_op,		/* y */
 	&sysrq_ftrace_dump_op,		/* z */
 };
 
