From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 07/10] batman-adv: Add function to calculate crc32c for the skb payload
Date: Mon, 19 Nov 2012 09:24:08 +0100
Message-ID: <1353313451-2930-8-git-send-email-ordex@autistici.org>
References: <1353313451-2930-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:64178 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753218Ab2KSIZY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 03:25:24 -0500
In-Reply-To: <1353313451-2930-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/Kconfig |  1 +
 net/batman-adv/main.c  | 34 ++++++++++++++++++++++++++++++++++
 net/batman-adv/main.h  |  1 +
 3 files changed, 36 insertions(+)

diff --git a/net/batman-adv/Kconfig b/net/batman-adv/Kconfig
index 250e0b5..8d8afb1 100644
--- a/net/batman-adv/Kconfig
+++ b/net/batman-adv/Kconfig
@@ -6,6 +6,7 @@ config BATMAN_ADV
 	tristate "B.A.T.M.A.N. Advanced Meshing Protocol"
 	depends on NET
 	select CRC16
+	select LIBCRC32C
         default n
 	help
           B.A.T.M.A.N. (better approach to mobile ad-hoc networking) is
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 70797de..253e240 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -17,6 +17,8 @@
  * 02110-1301, USA
  */
 
+#include <linux/crc32c.h>
+#include <linux/highmem.h>
 #include "main.h"
 #include "sysfs.h"
 #include "debugfs.h"
@@ -432,6 +434,38 @@ int batadv_compat_seq_print_text(struct seq_file *seq, void *offset)
 	return 0;
 }
 
+/**
+ * batadv_skb_crc32 - calculate CRC32 of the whole packet and skip bytes in
+ *  the header
+ * @skb: skb pointing to fragmented socket buffers
+ * @payload_ptr: Pointer to position inside the head buffer of the skb
+ *  marking the start of the data to be CRC'ed
+ *
+ * payload_ptr must always point to an address in the skb head buffer and not to
+ * a fragment.
+ */
+__be32 batadv_skb_crc32(struct sk_buff *skb, u8 *payload_ptr)
+{
+	u32 crc = 0;
+	unsigned int from;
+	unsigned int to = skb->len;
+	struct skb_seq_state st;
+	const u8 *data;
+	unsigned int len;
+	unsigned int consumed = 0;
+
+	from = (unsigned int)(payload_ptr - skb->data);
+
+	skb_prepare_seq_read(skb, from, to, &st);
+	while ((len = skb_seq_read(consumed, &data, &st)) != 0) {
+		crc = crc32c(crc, data, len);
+		consumed += len;
+	}
+	skb_abort_seq_read(&st);
+
+	return htonl(crc);
+}
+
 static int batadv_param_set_ra(const char *val, const struct kernel_param *kp)
 {
 	struct batadv_algo_ops *bat_algo_ops;
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 3243189..0213cb5 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -175,6 +175,7 @@ int batadv_algo_register(struct batadv_algo_ops *bat_algo_ops);
 int batadv_algo_select(struct batadv_priv *bat_priv, char *name);
 int batadv_algo_seq_print_text(struct seq_file *seq, void *offset);
 int batadv_compat_seq_print_text(struct seq_file *seq, void *offset);
+__be32 batadv_skb_crc32(struct sk_buff *skb, u8 *payload_ptr);
 
 /**
  * enum batadv_dbg_level - available log levels
-- 
1.8.0
