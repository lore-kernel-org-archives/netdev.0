From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH] [TCP]: Replace struct net on tcp_iter_state with seq_net_private.
Date: Tue,  8 Apr 2008 17:29:47 +0400
Message-ID: <1207661392-13570-1-git-send-email-den@openvz.org>
References: <1207661318.7171.22.camel@iris.sw.ru>
Cc: netdev@vger.kernel.org, "Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:38171 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751990AbYDHN3c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Apr 2008 09:29:32 -0400
In-Reply-To: <1207661318.7171.22.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 include/net/tcp.h   |    2 +-
 net/ipv4/tcp_ipv4.c |   11 +++++------
 2 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 723b368..f9d6b89 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1329,7 +1329,7 @@ struct tcp_seq_afinfo {
 };
 
 struct tcp_iter_state {
-	struct net              *net;
+	struct seq_net_private	p;
 	sa_family_t		family;
 	enum tcp_seq_states	state;
 	struct sock		*syn_wait_sk;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index df89a56..fc1b505 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1955,7 +1955,7 @@ static void *listening_get_next(struct seq_file *seq, void *cur)
 	struct hlist_node *node;
 	struct sock *sk = cur;
 	struct tcp_iter_state* st = seq->private;
-	struct net *net = st->net;
+	struct net *net = seq_file_net(seq);
 
 	if (!sk) {
 		st->bucket = 0;
@@ -2036,7 +2036,7 @@ static void *listening_get_idx(struct seq_file *seq, loff_t *pos)
 static void *established_get_first(struct seq_file *seq)
 {
 	struct tcp_iter_state* st = seq->private;
-	struct net *net = st->net;
+	struct net *net = seq_file_net(seq);
 	void *rc = NULL;
 
 	for (st->bucket = 0; st->bucket < tcp_hashinfo.ehash_size; ++st->bucket) {
@@ -2077,7 +2077,7 @@ static void *established_get_next(struct seq_file *seq, void *cur)
 	struct inet_timewait_sock *tw;
 	struct hlist_node *node;
 	struct tcp_iter_state* st = seq->private;
-	struct net *net = st->net;
+	struct net *net = seq_file_net(seq);
 
 	++st->num;
 
@@ -2234,7 +2234,7 @@ static int tcp_seq_open(struct inode *inode, struct file *file)
 	s->seq_ops.next		= tcp_seq_next;
 	s->seq_ops.show		= afinfo->seq_show;
 	s->seq_ops.stop		= tcp_seq_stop;
-	s->net                  = net;
+	s->p.net                = net;
 
 	rc = seq_open(file, &s->seq_ops);
 	if (rc)
@@ -2253,9 +2253,8 @@ out_kfree:
 static int tcp_seq_release(struct inode *inode, struct file *file)
 {
 	struct seq_file *seq = file->private_data;
-	struct tcp_iter_state *s = seq->private;
 
-	put_net(s->net);
+	put_net(seq_file_net(seq));
 	seq_release_private(inode, file);
 	return 0;
 }
-- 
1.5.3.rc5

