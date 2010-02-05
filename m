From: Li Zefan <lizf@cn.fujitsu.com>
Subject: [PATCH 13/13] net: atm: use seq_list_foo() helpers
Date: Fri, 05 Feb 2010 09:47:55 +0800
Message-ID: <4B6B78CB.1040908@cn.fujitsu.com>
References: <4B6B77FE.5000104@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:65139 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S932877Ab0BEBrj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Feb 2010 20:47:39 -0500
In-Reply-To: <4B6B77FE.5000104@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simplify seq_file code.

Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
---
 net/atm/proc.c      |    2 +-
 net/atm/resources.c |   18 ++----------------
 2 files changed, 3 insertions(+), 17 deletions(-)

diff --git a/net/atm/proc.c b/net/atm/proc.c
index ab8419a..c0c3a79 100644
--- a/net/atm/proc.c
+++ b/net/atm/proc.c
@@ -236,7 +236,7 @@ static int atm_dev_seq_show(struct seq_file *seq, void *v)
 		"Itf Type    ESI/\"MAC\"addr "
 		"AAL(TX,err,RX,err,drop) ...               [refcnt]\n";
 
-	if (v == SEQ_START_TOKEN)
+	if (v == &atm_devs)
 		seq_puts(seq, atm_dev_banner);
 	else {
 		struct atm_dev *dev = list_entry(v, struct atm_dev, dev_list);
diff --git a/net/atm/resources.c b/net/atm/resources.c
index f4091d6..bbd01b0 100644
--- a/net/atm/resources.c
+++ b/net/atm/resources.c
@@ -454,21 +454,10 @@ done:
 	return error;
 }
 
-static inline void *dev_get_idx(loff_t left)
-{
-	struct list_head *p;
-
-	list_for_each(p, &atm_devs) {
-		if (!--left)
-			break;
-	}
-	return (p != &atm_devs) ? p : NULL;
-}
-
 void *atm_dev_seq_start(struct seq_file *seq, loff_t *pos)
 {
 	mutex_lock(&atm_dev_mutex);
-	return *pos ? dev_get_idx(*pos) : SEQ_START_TOKEN;
+	return seq_list_start_head(&atm_devs, *pos);
 }
 
 void atm_dev_seq_stop(struct seq_file *seq, void *v)
@@ -478,8 +467,5 @@ void atm_dev_seq_stop(struct seq_file *seq, void *v)
 
 void *atm_dev_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
-	++*pos;
-	v = (v == SEQ_START_TOKEN)
-		? atm_devs.next : ((struct list_head *)v)->next;
-	return (v == &atm_devs) ? NULL : v;
+	return seq_list_next(v, &atm_devs, pos);
 }
-- 
1.6.3

