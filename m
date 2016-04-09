From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv2 net-next 6/6] sctp: fix some rhashtable functions using in sctp proc/diag
Date: Sat,  9 Apr 2016 12:53:14 +0800
Message-ID: <f7b9070052adc4ba1474d9554c3f533cd69abab0.1460177331.git.lucien.xin@gmail.com>
References: <cover.1460177331.git.lucien.xin@gmail.com>
 <c507274a984bd1b0a7e7a59d1e825352536efd25.1460177331.git.lucien.xin@gmail.com>
 <a3703f4379eeb3a385d3cc000dd621f77540608e.1460177331.git.lucien.xin@gmail.com>
 <5408d667c2a83b8917a501b92810c82f9a66f584.1460177331.git.lucien.xin@gmail.com>
 <ac19f4966c7df6399c2a3bfa0f7f9589b9ff536f.1460177331.git.lucien.xin@gmail.com>
 <f8e308aea76c74f37d1235ef384f38a4d27a1808.1460177331.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net,
	davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34216 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751967AbcDIExp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Apr 2016 00:53:45 -0400
In-Reply-To: <f8e308aea76c74f37d1235ef384f38a4d27a1808.1460177331.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1460177331.git.lucien.xin@gmail.com>
References: <cover.1460177331.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When rhashtable_walk_init return err, no release function should be
called, and when rhashtable_walk_start return err, we should only invoke
rhashtable_walk_exit to release the source.

But now when sctp_transport_walk_start return err, we just call
rhashtable_walk_stop/exit, and never care about if rhashtable_walk_init
or start return err, which is so bad.

We will fix it by calling rhashtable_walk_exit if rhashtable_walk_start
return err in sctp_transport_walk_start, and if sctp_transport_walk_start
return err, we do not need to call sctp_transport_walk_stop any more.

For sctp proc, we will use 'iter->start_fail' to decide if we will call
rhashtable_walk_stop/exit.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/sctp/proc.c   |  7 ++++++-
 net/sctp/socket.c | 15 ++++++++++-----
 2 files changed, 16 insertions(+), 6 deletions(-)

diff --git a/net/sctp/proc.c b/net/sctp/proc.c
index 9fe1393..4cb5aed 100644
--- a/net/sctp/proc.c
+++ b/net/sctp/proc.c
@@ -280,6 +280,7 @@ void sctp_eps_proc_exit(struct net *net)
 struct sctp_ht_iter {
 	struct seq_net_private p;
 	struct rhashtable_iter hti;
+	int start_fail;
 };
 
 static void *sctp_transport_seq_start(struct seq_file *seq, loff_t *pos)
@@ -287,8 +288,10 @@ static void *sctp_transport_seq_start(struct seq_file *seq, loff_t *pos)
 	struct sctp_ht_iter *iter = seq->private;
 	int err = sctp_transport_walk_start(&iter->hti);
 
-	if (err)
+	if (err) {
+		iter->start_fail = 1;
 		return ERR_PTR(err);
+	}
 
 	return sctp_transport_get_idx(seq_file_net(seq), &iter->hti, *pos);
 }
@@ -297,6 +300,8 @@ static void sctp_transport_seq_stop(struct seq_file *seq, void *v)
 {
 	struct sctp_ht_iter *iter = seq->private;
 
+	if (iter->start_fail)
+		return;
 	sctp_transport_walk_stop(&iter->hti);
 }
 
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index b0bf6c7..473a40c 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -4298,8 +4298,12 @@ int sctp_transport_walk_start(struct rhashtable_iter *iter)
 		return err;
 
 	err = rhashtable_walk_start(iter);
+	if (err && err != -EAGAIN) {
+		rhashtable_walk_exit(iter);
+		return err;
+	}
 
-	return err == -EAGAIN ? 0 : err;
+	return 0;
 }
 
 void sctp_transport_walk_stop(struct rhashtable_iter *iter)
@@ -4388,11 +4392,12 @@ EXPORT_SYMBOL_GPL(sctp_transport_lookup_process);
 int sctp_for_each_transport(int (*cb)(struct sctp_transport *, void *),
 			    struct net *net, int pos, void *p) {
 	struct rhashtable_iter hti;
-	int err = 0;
 	void *obj;
+	int err;
 
-	if (sctp_transport_walk_start(&hti))
-		goto out;
+	err = sctp_transport_walk_start(&hti);
+	if (err)
+		return err;
 
 	sctp_transport_get_idx(net, &hti, pos);
 	obj = sctp_transport_get_next(net, &hti);
@@ -4406,8 +4411,8 @@ int sctp_for_each_transport(int (*cb)(struct sctp_transport *, void *),
 		if (err)
 			break;
 	}
-out:
 	sctp_transport_walk_stop(&hti);
+
 	return err;
 }
 EXPORT_SYMBOL_GPL(sctp_for_each_transport);
-- 
2.1.0
