From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [net-2.6.26 patch 4/6][NETNS][IPV6] tcp - make proc handle the network namespaces
Date: Thu, 13 Mar 2008 12:46:13 +0100
Message-ID: <20080313114932.259088949@mai.toulouse-stg.fr.ibm.com>
References: <20080313114609.176640638@mai.toulouse-stg.fr.ibm.com>
Cc: netdev@vger.kernel.org, benjamin.thery@bull.net, den@openvz.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.uk.ibm.com ([195.212.29.134]:33878 "EHLO
	mtagate1.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752459AbYCMLvn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Mar 2008 07:51:43 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate1.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m2DBpgK3187476
	for <netdev@vger.kernel.org>; Thu, 13 Mar 2008 11:51:42 GMT
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2DBpfHg2121938
	for <netdev@vger.kernel.org>; Thu, 13 Mar 2008 11:51:42 GMT
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2DBpcrZ001888
	for <netdev@vger.kernel.org>; Thu, 13 Mar 2008 11:51:41 GMT
Content-Disposition: inline; filename=tcp-proc-handle-namespace.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch, like udp proc, makes the proc functions to take care of
which namespace the socket belongs.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 include/net/tcp.h   |    1 +
 net/ipv4/tcp_ipv4.c |   44 +++++++++++++++++++++++++++++++++++---------
 2 files changed, 36 insertions(+), 9 deletions(-)

Index: net-2.6.26/include/net/tcp.h
===================================================================
--- net-2.6.26.orig/include/net/tcp.h
+++ net-2.6.26/include/net/tcp.h
@@ -1328,6 +1328,7 @@ struct tcp_seq_afinfo {
 };
 
 struct tcp_iter_state {
+	struct net              *net;
 	sa_family_t		family;
 	enum tcp_seq_states	state;
 	struct sock		*syn_wait_sk;
Index: net-2.6.26/net/ipv4/tcp_ipv4.c
===================================================================
--- net-2.6.26.orig/net/ipv4/tcp_ipv4.c
+++ net-2.6.26/net/ipv4/tcp_ipv4.c
@@ -1948,6 +1948,7 @@ static void *listening_get_next(struct s
 	struct hlist_node *node;
 	struct sock *sk = cur;
 	struct tcp_iter_state* st = seq->private;
+	struct net *net = st->net;
 
 	if (!sk) {
 		st->bucket = 0;
@@ -1964,7 +1965,8 @@ static void *listening_get_next(struct s
 		req = req->dl_next;
 		while (1) {
 			while (req) {
-				if (req->rsk_ops->family == st->family) {
+				if (req->rsk_ops->family == st->family &&
+				    req->sk->sk_net == net) {
 					cur = req;
 					goto out;
 				}
@@ -1988,7 +1990,7 @@ get_req:
 	}
 get_sk:
 	sk_for_each_from(sk, node) {
-		if (sk->sk_family == st->family) {
+		if (sk->sk_family == st->family && sk->sk_net == net) {
 			cur = sk;
 			goto out;
 		}
@@ -2027,6 +2029,7 @@ static void *listening_get_idx(struct se
 static void *established_get_first(struct seq_file *seq)
 {
 	struct tcp_iter_state* st = seq->private;
+	struct net *net = st->net;
 	void *rc = NULL;
 
 	for (st->bucket = 0; st->bucket < tcp_hashinfo.ehash_size; ++st->bucket) {
@@ -2037,7 +2040,8 @@ static void *established_get_first(struc
 
 		read_lock_bh(lock);
 		sk_for_each(sk, node, &tcp_hashinfo.ehash[st->bucket].chain) {
-			if (sk->sk_family != st->family) {
+			if (sk->sk_family != st->family ||
+			    sk->sk_net != net) {
 				continue;
 			}
 			rc = sk;
@@ -2046,7 +2050,8 @@ static void *established_get_first(struc
 		st->state = TCP_SEQ_STATE_TIME_WAIT;
 		inet_twsk_for_each(tw, node,
 				   &tcp_hashinfo.ehash[st->bucket].twchain) {
-			if (tw->tw_family != st->family) {
+			if (tw->tw_family != st->family &&
+			    tw->tw_net != net) {
 				continue;
 			}
 			rc = tw;
@@ -2065,6 +2070,7 @@ static void *established_get_next(struct
 	struct inet_timewait_sock *tw;
 	struct hlist_node *node;
 	struct tcp_iter_state* st = seq->private;
+	struct net *net = st->net;
 
 	++st->num;
 
@@ -2072,7 +2078,7 @@ static void *established_get_next(struct
 		tw = cur;
 		tw = tw_next(tw);
 get_tw:
-		while (tw && tw->tw_family != st->family) {
+		while (tw && tw->tw_family != st->family && tw->tw_net != net) {
 			tw = tw_next(tw);
 		}
 		if (tw) {
@@ -2093,7 +2099,7 @@ get_tw:
 		sk = sk_next(sk);
 
 	sk_for_each_from(sk, node) {
-		if (sk->sk_family == st->family)
+		if (sk->sk_family == st->family && sk->sk_net == net)
 			goto found;
 	}
 
@@ -2201,6 +2207,7 @@ static int tcp_seq_open(struct inode *in
 	struct tcp_seq_afinfo *afinfo = PDE(inode)->data;
 	struct seq_file *seq;
 	struct tcp_iter_state *s;
+	struct net *net;
 	int rc;
 
 	if (unlikely(afinfo == NULL))
@@ -2209,24 +2216,43 @@ static int tcp_seq_open(struct inode *in
 	s = kzalloc(sizeof(*s), GFP_KERNEL);
 	if (!s)
 		return -ENOMEM;
+
+	rc = -ENXIO;
+	net = get_proc_net(inode);
+	if (!net)
+		goto out_kfree;
+
 	s->family		= afinfo->family;
 	s->seq_ops.start	= tcp_seq_start;
 	s->seq_ops.next		= tcp_seq_next;
 	s->seq_ops.show		= afinfo->seq_show;
 	s->seq_ops.stop		= tcp_seq_stop;
+	s->net                  = net;
 
 	rc = seq_open(file, &s->seq_ops);
 	if (rc)
-		goto out_kfree;
-	seq	     = file->private_data;
+		goto out_put_net;
+	seq = file->private_data;
 	seq->private = s;
 out:
 	return rc;
+out_put_net:
+	put_net(net);
 out_kfree:
 	kfree(s);
 	goto out;
 }
 
+static int tcp_seq_release(struct inode *inode, struct file *file)
+{
+	struct seq_file *seq = file->private_data;
+	struct tcp_iter_state *s = seq->private;
+
+	put_net(s->net);
+	seq_release_private(inode, file);
+	return 0;
+}
+
 int tcp_proc_register(struct tcp_seq_afinfo *afinfo)
 {
 	int rc = 0;
@@ -2238,7 +2264,7 @@ int tcp_proc_register(struct tcp_seq_afi
 	afinfo->seq_fops->open		= tcp_seq_open;
 	afinfo->seq_fops->read		= seq_read;
 	afinfo->seq_fops->llseek	= seq_lseek;
-	afinfo->seq_fops->release	= seq_release_private;
+	afinfo->seq_fops->release	= tcp_seq_release;
 
 	p = proc_net_fops_create(&init_net, afinfo->name, S_IRUGO, afinfo->seq_fops);
 	if (p)

-- 
