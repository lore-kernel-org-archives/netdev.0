From: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Subject: [PATCH] net/ipv4/ipmr.c fixes
Date: Thu, 08 Jul 2004 04:25:26 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <877jtfmxg9.fsf@devron.myhome.or.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


- pim_protocol warning fix

- ipmr_vif_open() and ipmr_mfc_open() allocates the memory, so it
  should use seq_release_private().

- ipmr_mfc_seq_xxx is using it->cache, in order to control whether
  unlock should be do or not, but it->cache was not initialized in
  ipmr_mfc_seq_start(). So it can point the previous state if user
  did seek(). This become to the cause of twice unlock.

Signed-off-by: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
---

 net/ipv4/ipmr.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff -puN net/ipv4/ipmr.c~ipmr-fixes net/ipv4/ipmr.c
--- linux-2.6.7/net/ipv4/ipmr.c~ipmr-fixes	2004-07-07 23:08:48.000000000 +0900
+++ linux-2.6.7-hirofumi/net/ipv4/ipmr.c	2004-07-07 23:10:49.000000000 +0900
@@ -109,7 +109,9 @@ static int ip_mr_forward(struct sk_buff 
 static int ipmr_cache_report(struct sk_buff *pkt, vifi_t vifi, int assert);
 static int ipmr_fill_mroute(struct sk_buff *skb, struct mfc_cache *c, struct rtmsg *rtm);
 
+#ifdef CONFIG_IP_PIMSM_V2
 static struct net_protocol pim_protocol;
+#endif
 
 static struct timer_list ipmr_expire_timer;
 
@@ -1702,7 +1704,7 @@ static struct file_operations ipmr_vif_f
 	.open    = ipmr_vif_open,
 	.read    = seq_read,
 	.llseek  = seq_lseek,
-	.release = seq_release,
+	.release = seq_release_private,
 };
 
 struct ipmr_mfc_iter {
@@ -1737,6 +1739,9 @@ static struct mfc_cache *ipmr_mfc_seq_id
 
 static void *ipmr_mfc_seq_start(struct seq_file *seq, loff_t *pos)
 {
+	struct ipmr_mfc_iter *it = seq->private;
+	it->cache = NULL;
+	it->ct = 0;
 	return *pos ? ipmr_mfc_seq_idx(seq->private, *pos - 1) 
 		: SEQ_START_TOKEN;
 }
@@ -1846,7 +1851,6 @@ static int ipmr_mfc_open(struct inode *i
 	if (rc)
 		goto out_kfree;
 
-	memset(s, 0, sizeof(*s));
 	seq = file->private_data;
 	seq->private = s;
 out:
@@ -1862,7 +1866,7 @@ static struct file_operations ipmr_mfc_f
 	.open    = ipmr_mfc_open,
 	.read    = seq_read,
 	.llseek  = seq_lseek,
-	.release = seq_release,
+	.release = seq_release_private,
 };
 #endif	
 
_

-- 
OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
