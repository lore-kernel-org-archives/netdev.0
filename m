From: Li Zefan <lizf@cn.fujitsu.com>
Subject: [PATCH 05/13] net: packet: use seq_hlist_foo() helpers
Date: Fri, 05 Feb 2010 09:45:56 +0800
Message-ID: <4B6B7854.3080803@cn.fujitsu.com>
References: <4B6B77FE.5000104@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:59720 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1757452Ab0BEBpl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Feb 2010 20:45:41 -0500
In-Reply-To: <4B6B77FE.5000104@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simplify seq_file code.

Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
---
 net/packet/af_packet.c |   20 +++-----------------
 1 files changed, 3 insertions(+), 17 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 0f6bf59..256de26 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2374,33 +2374,19 @@ static struct notifier_block packet_netdev_notifier = {
 };
 
 #ifdef CONFIG_PROC_FS
-static inline struct sock *packet_seq_idx(struct net *net, loff_t off)
-{
-	struct sock *s;
-	struct hlist_node *node;
-
-	sk_for_each(s, node, &net->packet.sklist) {
-		if (!off--)
-			return s;
-	}
-	return NULL;
-}
 
 static void *packet_seq_start(struct seq_file *seq, loff_t *pos)
 	__acquires(seq_file_net(seq)->packet.sklist_lock)
 {
 	struct net *net = seq_file_net(seq);
 	read_lock(&net->packet.sklist_lock);
-	return *pos ? packet_seq_idx(net, *pos - 1) : SEQ_START_TOKEN;
+	return seq_hlist_start_head(&net->packet.sklist, *pos);
 }
 
 static void *packet_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
 	struct net *net = seq_file_net(seq);
-	++*pos;
-	return  (v == SEQ_START_TOKEN)
-		? sk_head(&net->packet.sklist)
-		: sk_next((struct sock *)v) ;
+	return seq_hlist_next(v, &net->packet.sklist, pos);
 }
 
 static void packet_seq_stop(struct seq_file *seq, void *v)
@@ -2415,7 +2401,7 @@ static int packet_seq_show(struct seq_file *seq, void *v)
 	if (v == SEQ_START_TOKEN)
 		seq_puts(seq, "sk       RefCnt Type Proto  Iface R Rmem   User   Inode\n");
 	else {
-		struct sock *s = v;
+		struct sock *s = sk_entry(v);
 		const struct packet_sock *po = pkt_sk(s);
 
 		seq_printf(seq,
-- 
1.6.3

