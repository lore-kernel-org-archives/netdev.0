From: y@vger.kernel.org
Subject: [RFC v4 10/11] snet: introduce snet_stats
Date: Thu,  5 May 2011 15:59:20 +0200
Message-ID: <23139.2700378366$1304604591@news.gmane.org>
References: <1304603961-2517-1-git-send-email-y>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, jamal <hadi@cyberus.ca>,
	Patrick McHardy <kaber@trash.net>,
	Grzegorz Nosek <root@localdomain.pl>,
	Samir Bellabes <sam@synack.fr>
To: linux-security-module@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1304603961-2517-1-git-send-email-y>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Samir Bellabes <sam@synack.fr>

this patch adds a /proc/snet/snet_stats entry to show statistics about
snet. this patch adds also the functions to manage the statistics.

 Signed-off-by: Samir Bellabes <sam@synack.fr>
---
 security/snet/snet_stats.c |   65 ++++++++++++++++++++++++++++++++++++++++++++
 security/snet/snet_stats.h |   57 ++++++++++++++++++++++++++++++++++++++
 2 files changed, 122 insertions(+), 0 deletions(-)
 create mode 100644 security/snet/snet_stats.c
 create mode 100644 security/snet/snet_stats.h

diff --git a/security/snet/snet_stats.c b/security/snet/snet_stats.c
new file mode 100644
index 0000000..b946dda
--- /dev/null
+++ b/security/snet/snet_stats.c
@@ -0,0 +1,65 @@
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/proc_fs.h>
+#include <linux/seq_file.h>
+#include <net/net_namespace.h>
+#include "snet_stats.h"
+#include "snet_utils.h"
+
+extern struct net init_net;
+
+#define SNET_STATS_PROC_DIR	"snet"
+#define SNET_STATS_PROC_INFO	"snet_stats"
+
+static struct proc_dir_entry *snet_stats_dir;
+static struct proc_dir_entry *snet_stats_pde;
+struct snet_statistics snet_stats;
+
+static int snet_stats_show(struct seq_file *m, void *v)
+{
+	unsigned int sys = 0;
+	seq_printf(m, "snet statistics\n");
+
+	for (sys = SNET_SOCKET_CREATE; sys < SNET_NR_SOCKET_TYPES; sys++) {
+		unsigned int v = 0;
+		seq_printf(m, "%s {", snet_syscall_name(sys));
+
+		seq_printf(m, " Exec: %u ", SNET_STATS_GET(SNET_STATS_EXEC, sys));
+		seq_printf(m, " Unreg: %u ", SNET_STATS_GET(SNET_STATS_UNREG, sys));
+		for (v = SNET_VERDICT_GRANT; v < SNET_NR_VERDICT_TYPES; v++) {
+			seq_printf(m, " %s: %u ", snet_verdict_name(v),
+				   SNET_STATS_GET(v, sys));
+		}
+		seq_printf(m, " Reg Error: %u ", SNET_STATS_GET(SNET_STATS_REG_ERROR, sys));
+		seq_printf(m, "}\n");
+	}
+	return 0;
+}
+
+static int snet_stats_proc_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, snet_stats_show, NULL);
+}
+
+static const struct file_operations snet_stats_proc_fops = {
+	.owner		= THIS_MODULE,
+	.open		= snet_stats_proc_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= single_release,
+};
+
+void snet_stats_init(void)
+{
+	snet_stats_dir = proc_mkdir(SNET_STATS_PROC_DIR, init_net.proc_net);
+	if (snet_stats_dir == NULL) {
+		printk(KERN_ERR "snet: can't create /proc/%s\n",
+		       SNET_STATS_PROC_DIR);
+		goto out;
+	}
+
+	snet_stats_pde = proc_create(SNET_STATS_PROC_INFO, 0644, snet_stats_dir,
+				     &snet_stats_proc_fops);
+out:
+	return;
+}
diff --git a/security/snet/snet_stats.h b/security/snet/snet_stats.h
new file mode 100644
index 0000000..05ab06d
--- /dev/null
+++ b/security/snet/snet_stats.h
@@ -0,0 +1,57 @@
+#ifndef _SNET_STATS_H
+#define _SNET_STATS_H
+
+#include <linux/snet.h>
+
+enum {
+	SNET_STATS_REG_GRANT = 0,
+	SNET_STATS_REG_DENY,
+	SNET_STATS_REG_PENDING,
+	SNET_STATS_REG_NONE,
+	SNET_STATS_REG_INVALID,
+	SNET_STATS_REG_ERROR,
+	SNET_STATS_UNREG,
+	SNET_STATS_EXEC,
+	__SNET_STATS_MAX
+};
+
+#define SNET_STATS_MAX __SNET_STATS_MAX
+
+struct snet_statistics {
+	atomic_t	mibs[SNET_NR_SOCKET_TYPES+1][SNET_STATS_MAX];
+};
+
+extern struct snet_statistics snet_stats;
+#define SNET_STATS_INC(field, syscall)	(atomic_inc(&snet_stats.mibs[syscall][field]))
+#define SNET_STATS_DEC(field, syscall)	(atomic_dec(&snet_stats.mibs[syscall][field]))
+#define SNET_STATS_GET(field, syscall)	(atomic_read(&snet_stats.mibs[syscall][field]))
+
+void snet_stats_init(void);
+
+static inline void snet_stats_inc_reg(const enum snet_verdict verdict,
+				      const enum snet_syscall syscall)
+{
+	switch (verdict) {
+	case SNET_VERDICT_GRANT:
+		SNET_STATS_INC(SNET_STATS_REG_GRANT, syscall);
+		break;
+	case SNET_VERDICT_DENY:
+		SNET_STATS_INC(SNET_STATS_REG_DENY, syscall);
+		break;
+	case SNET_VERDICT_PENDING:
+		SNET_STATS_INC(SNET_STATS_REG_PENDING, syscall);
+		break;
+	case SNET_VERDICT_NONE:
+		SNET_STATS_INC(SNET_STATS_REG_NONE, syscall);
+		break;
+	case SNET_VERDICT_INVALID:
+		SNET_STATS_INC(SNET_STATS_REG_INVALID, syscall);
+		break;
+	default:
+		SNET_STATS_INC(SNET_STATS_REG_ERROR, syscall);
+		break;
+	}
+	return;
+};
+
+#endif
-- 
1.7.4.1

