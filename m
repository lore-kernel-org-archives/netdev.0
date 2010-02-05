From: Li Zefan <lizf@cn.fujitsu.com>
Subject: [PATCH 11/13] net: irda: use seq_list_foo() helpers
Date: Fri, 05 Feb 2010 09:47:25 +0800
Message-ID: <4B6B78AD.1030809@cn.fujitsu.com>
References: <4B6B77FE.5000104@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:60089 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S932739Ab0BEBrK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Feb 2010 20:47:10 -0500
In-Reply-To: <4B6B77FE.5000104@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simplify seq_file code.

Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
---
 net/irda/irlan/irlan_common.c |   26 ++++----------------------
 1 files changed, 4 insertions(+), 22 deletions(-)

diff --git a/net/irda/irlan/irlan_common.c b/net/irda/irlan/irlan_common.c
index 315ead3..2141593 100644
--- a/net/irda/irlan/irlan_common.c
+++ b/net/irda/irlan/irlan_common.c
@@ -1128,19 +1128,8 @@ int irlan_extract_param(__u8 *buf, char *name, char *value, __u16 *len)
  */
 static void *irlan_seq_start(struct seq_file *seq, loff_t *pos)
 {
-	int i = 1;
-	struct irlan_cb *self;
-
 	rcu_read_lock();
-	if (*pos == 0)
-		return SEQ_START_TOKEN;
-
-	list_for_each_entry(self, &irlans, dev_list) {
-		if (*pos == i)
-			return self;
-		++i;
-	}
-	return NULL;
+	return seq_list_start_head(&irlans, *pos);
 }
 
 /* Return entry after v, and increment pos */
@@ -1148,14 +1137,7 @@ static void *irlan_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
 	struct list_head *nxt;
 
-	++*pos;
-	if (v == SEQ_START_TOKEN)
-		nxt = irlans.next;
-	else
-		nxt = ((struct irlan_cb *)v)->dev_list.next;
-
-	return (nxt == &irlans) ? NULL
-		: list_entry(nxt, struct irlan_cb, dev_list);
+	return seq_list_next(v, &irlans, pos);
 }
 
 /* End of reading /proc file */
@@ -1170,10 +1152,10 @@ static void irlan_seq_stop(struct seq_file *seq, void *v)
  */
 static int irlan_seq_show(struct seq_file *seq, void *v)
 {
-	if (v == SEQ_START_TOKEN)
+	if (v == &irlans)
 		seq_puts(seq, "IrLAN instances:\n");
 	else {
-		struct irlan_cb *self = v;
+		struct irlan_cb *self = list_entry(v, struct irlan_cb, list);
 
 		IRDA_ASSERT(self != NULL, return -1;);
 		IRDA_ASSERT(self->magic == IRLAN_MAGIC, return -1;);
-- 
1.6.3

