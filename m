From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 5/7] sctp: reuse the some transport traversal functions in proc
Date: Tue,  5 Apr 2016 12:06:30 +0800
Message-ID: <cdc77cc7b894aab62dad372f0018c571e33cf16e.1459829123.git.lucien.xin@gmail.com>
References: <cover.1459829123.git.lucien.xin@gmail.com>
 <c507274a984bd1b0a7e7a59d1e825352536efd25.1459829123.git.lucien.xin@gmail.com>
 <c99aafbc687328f783c0777e10df3e207004db10.1459829123.git.lucien.xin@gmail.com>
 <d16e3f12f689f28d8c3b62c7c2a15916177bd7c0.1459829123.git.lucien.xin@gmail.com>
 <123695bf6a49412e15b79049d088903a36538c53.1459829123.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net,
	davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35661 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753700AbcDEEHI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 00:07:08 -0400
In-Reply-To: <123695bf6a49412e15b79049d088903a36538c53.1459829123.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1459829123.git.lucien.xin@gmail.com>
References: <cover.1459829123.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are some transport traversal functions for sctp_diag, we can also
use it for sctp_proc. cause they have the similar situation to traversal
transport.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/sctp/proc.c | 80 +++++++++++++--------------------------------------------
 1 file changed, 18 insertions(+), 62 deletions(-)

diff --git a/net/sctp/proc.c b/net/sctp/proc.c
index 5cfac8d..dd8492f 100644
--- a/net/sctp/proc.c
+++ b/net/sctp/proc.c
@@ -282,80 +282,31 @@ struct sctp_ht_iter {
 	struct rhashtable_iter hti;
 };
 
-static struct sctp_transport *sctp_transport_get_next(struct seq_file *seq)
-{
-	struct sctp_ht_iter *iter = seq->private;
-	struct sctp_transport *t;
-
-	t = rhashtable_walk_next(&iter->hti);
-	for (; t; t = rhashtable_walk_next(&iter->hti)) {
-		if (IS_ERR(t)) {
-			if (PTR_ERR(t) == -EAGAIN)
-				continue;
-			break;
-		}
-
-		if (net_eq(sock_net(t->asoc->base.sk), seq_file_net(seq)) &&
-		    t->asoc->peer.primary_path == t)
-			break;
-	}
-
-	return t;
-}
-
-static struct sctp_transport *sctp_transport_get_idx(struct seq_file *seq,
-						     loff_t pos)
-{
-	void *obj = SEQ_START_TOKEN;
-
-	while (pos && (obj = sctp_transport_get_next(seq)) && !IS_ERR(obj))
-		pos--;
-
-	return obj;
-}
-
-static int sctp_transport_walk_start(struct seq_file *seq)
-{
-	struct sctp_ht_iter *iter = seq->private;
-	int err;
-
-	err = rhashtable_walk_init(&sctp_transport_hashtable, &iter->hti);
-	if (err)
-		return err;
-
-	err = rhashtable_walk_start(&iter->hti);
-
-	return err == -EAGAIN ? 0 : err;
-}
-
-static void sctp_transport_walk_stop(struct seq_file *seq)
-{
-	struct sctp_ht_iter *iter = seq->private;
-
-	rhashtable_walk_stop(&iter->hti);
-	rhashtable_walk_exit(&iter->hti);
-}
-
 static void *sctp_assocs_seq_start(struct seq_file *seq, loff_t *pos)
 {
-	int err = sctp_transport_walk_start(seq);
+	struct sctp_ht_iter *iter = seq->private;
+	int err = sctp_transport_walk_start(&iter->hti);
 
 	if (err)
 		return ERR_PTR(err);
 
-	return sctp_transport_get_idx(seq, *pos);
+	return sctp_transport_get_idx(seq_file_net(seq), &iter->hti, *pos);
 }
 
 static void sctp_assocs_seq_stop(struct seq_file *seq, void *v)
 {
-	sctp_transport_walk_stop(seq);
+	struct sctp_ht_iter *iter = seq->private;
+
+	sctp_transport_walk_stop(&iter->hti);
 }
 
 static void *sctp_assocs_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
+	struct sctp_ht_iter *iter = seq->private;
+
 	++*pos;
 
-	return sctp_transport_get_next(seq);
+	return sctp_transport_get_next(seq_file_net(seq), &iter->hti);
 }
 
 /* Display sctp associations (/proc/net/sctp/assocs). */
@@ -457,24 +408,29 @@ void sctp_assocs_proc_exit(struct net *net)
 
 static void *sctp_remaddr_seq_start(struct seq_file *seq, loff_t *pos)
 {
-	int err = sctp_transport_walk_start(seq);
+	struct sctp_ht_iter *iter = seq->private;
+	int err = sctp_transport_walk_start(&iter->hti);
 
 	if (err)
 		return ERR_PTR(err);
 
-	return sctp_transport_get_idx(seq, *pos);
+	return sctp_transport_get_idx(seq_file_net(seq), &iter->hti, *pos);
 }
 
 static void *sctp_remaddr_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
+	struct sctp_ht_iter *iter = seq->private;
+
 	++*pos;
 
-	return sctp_transport_get_next(seq);
+	return sctp_transport_get_next(seq_file_net(seq), &iter->hti);
 }
 
 static void sctp_remaddr_seq_stop(struct seq_file *seq, void *v)
 {
-	sctp_transport_walk_stop(seq);
+	struct sctp_ht_iter *iter = seq->private;
+
+	sctp_transport_walk_stop(&iter->hti);
 }
 
 static int sctp_remaddr_seq_show(struct seq_file *seq, void *v)
-- 
2.1.0
