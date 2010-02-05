From: Li Zefan <lizf@cn.fujitsu.com>
Subject: [PATCH 09/13] net: af_key: use seq_hlist_foo() helpers
Date: Fri, 05 Feb 2010 09:46:55 +0800
Message-ID: <4B6B788F.7070500@cn.fujitsu.com>
References: <4B6B77FE.5000104@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4B6B77FE.5000104@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Simplify seq_file code.

Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
---
 net/key/af_key.c |   20 +++-----------------
 1 files changed, 3 insertions(+), 17 deletions(-)

diff --git a/net/key/af_key.c b/net/key/af_key.c
index 76fa6fe..cb006b6 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -3655,9 +3655,8 @@ static const struct net_proto_family pfkey_family_ops = {
 #ifdef CONFIG_PROC_FS
 static int pfkey_seq_show(struct seq_file *f, void *v)
 {
-	struct sock *s;
+	struct sock *s = sk_entry(v);
 
-	s = (struct sock *)v;
 	if (v == SEQ_START_TOKEN)
 		seq_printf(f ,"sk       RefCnt Rmem   Wmem   User   Inode\n");
 	else
@@ -3676,19 +3675,9 @@ static void *pfkey_seq_start(struct seq_file *f, loff_t *ppos)
 {
 	struct net *net = seq_file_net(f);
 	struct netns_pfkey *net_pfkey = net_generic(net, pfkey_net_id);
-	struct sock *s;
-	struct hlist_node *node;
-	loff_t pos = *ppos;
 
 	read_lock(&pfkey_table_lock);
-	if (pos == 0)
-		return SEQ_START_TOKEN;
-
-	sk_for_each(s, node, &net_pfkey->table)
-		if (pos-- == 1)
-			return s;
-
-	return NULL;
+	return seq_hlist_start_head(&net_pfkey->table, *ppos);
 }
 
 static void *pfkey_seq_next(struct seq_file *f, void *v, loff_t *ppos)
@@ -3696,10 +3685,7 @@ static void *pfkey_seq_next(struct seq_file *f, void *v, loff_t *ppos)
 	struct net *net = seq_file_net(f);
 	struct netns_pfkey *net_pfkey = net_generic(net, pfkey_net_id);
 
-	++*ppos;
-	return (v == SEQ_START_TOKEN) ?
-		sk_head(&net_pfkey->table) :
-			sk_next((struct sock *)v);
+	return seq_hlist_next(v, &net_pfkey->table, ppos);
 }
 
 static void pfkey_seq_stop(struct seq_file *f, void *v)
-- 
1.6.3
