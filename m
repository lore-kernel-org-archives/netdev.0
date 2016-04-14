From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv3 net-next 6/6] sctp: fix some rhashtable functions using in sctp proc/diag
Date: Thu, 14 Apr 2016 15:35:35 +0800
Message-ID: <2c0384caa029f06c843ae3b6142c9551e1ad6d68.1460618169.git.lucien.xin@gmail.com>
References: <cover.1460618169.git.lucien.xin@gmail.com>
 <cd6bf9c2696f125a74491e1f82b77a30bb1005dd.1460618169.git.lucien.xin@gmail.com>
 <d3fc80db41935f6b22d9fffc5854de63fb842899.1460618169.git.lucien.xin@gmail.com>
 <c771f8320e007cd5d1801a820f0cca8f7ed7235c.1460618169.git.lucien.xin@gmail.com>
 <c48759e983ae5f9cefdd1805025abb7f57299886.1460618169.git.lucien.xin@gmail.com>
 <68aad242e3999a51e2c742bc3672ffb9bd5fc292.1460618169.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net,
	davem@davemloft.net, eric.dumazet@gmail.com
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:35134 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752827AbcDNHgH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 03:36:07 -0400
In-Reply-To: <68aad242e3999a51e2c742bc3672ffb9bd5fc292.1460618169.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1460618169.git.lucien.xin@gmail.com>
References: <cover.1460618169.git.lucien.xin@gmail.com>
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
index 6226c0b..b27a849 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -4299,8 +4299,12 @@ int sctp_transport_walk_start(struct rhashtable_iter *iter)
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
@@ -4389,11 +4393,12 @@ EXPORT_SYMBOL_GPL(sctp_transport_lookup_process);
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
@@ -4407,8 +4412,8 @@ int sctp_for_each_transport(int (*cb)(struct sctp_transport *, void *),
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
