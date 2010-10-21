From: kaber@trash.net
Subject: [PATCH 31/72] netfilter: add missing xt_log.h file
Date: Thu, 21 Oct 2010 17:19:18 +0200
Message-ID: <1287674399-31455-32-git-send-email-kaber@trash.net>
References: <1287674399-31455-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1287674399-31455-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

Forgot to add xt_log.h in commit a8defca0 (netfilter: ipt_LOG:
add bufferisation to call printk() once)

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/net/netfilter/xt_log.h |   54 ++++++++++++++++++++++++++++++++++++++++
 1 files changed, 54 insertions(+), 0 deletions(-)
 create mode 100644 include/net/netfilter/xt_log.h

diff --git a/include/net/netfilter/xt_log.h b/include/net/netfilter/xt_log.h
new file mode 100644
index 0000000..0dfb34a
--- /dev/null
+++ b/include/net/netfilter/xt_log.h
@@ -0,0 +1,54 @@
+#define S_SIZE (1024 - (sizeof(unsigned int) + 1))
+
+struct sbuff {
+	unsigned int	count;
+	char		buf[S_SIZE + 1];
+};
+static struct sbuff emergency, *emergency_ptr = &emergency;
+
+static int sb_add(struct sbuff *m, const char *f, ...)
+{
+	va_list args;
+	int len;
+
+	if (likely(m->count < S_SIZE)) {
+		va_start(args, f);
+		len = vsnprintf(m->buf + m->count, S_SIZE - m->count, f, args);
+		va_end(args);
+		if (likely(m->count + len < S_SIZE)) {
+			m->count += len;
+			return 0;
+		}
+	}
+	m->count = S_SIZE;
+	printk_once(KERN_ERR KBUILD_MODNAME " please increase S_SIZE\n");
+	return -1;
+}
+
+static struct sbuff *sb_open(void)
+{
+	struct sbuff *m = kmalloc(sizeof(*m), GFP_ATOMIC);
+
+	if (unlikely(!m)) {
+		local_bh_disable();
+		do {
+			m = xchg(&emergency_ptr, NULL);
+		} while (!m);
+	}
+	m->count = 0;
+	return m;
+}
+
+static void sb_close(struct sbuff *m)
+{
+	m->buf[m->count] = 0;
+	printk("%s\n", m->buf);
+
+	if (likely(m != &emergency))
+		kfree(m);
+	else {
+		xchg(&emergency_ptr, m);
+		local_bh_enable();
+	}
+}
+
-- 
1.7.1

