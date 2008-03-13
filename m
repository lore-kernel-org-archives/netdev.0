From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [net-2.6.26 patch 2/6][NETNS][IPV6] udp - make proc handle the network namespace
Date: Thu, 13 Mar 2008 12:46:11 +0100
Message-ID: <20080313114912.912457044@mai.toulouse-stg.fr.ibm.com>
References: <20080313114609.176640638@mai.toulouse-stg.fr.ibm.com>
Cc: netdev@vger.kernel.org, benjamin.thery@bull.net, den@openvz.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.uk.ibm.com ([195.212.29.134]:33853 "EHLO
	mtagate1.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752216AbYCMLvS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Mar 2008 07:51:18 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate1.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m2DBpG29043222
	for <netdev@vger.kernel.org>; Thu, 13 Mar 2008 11:51:17 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2DBpGrN2023520
	for <netdev@vger.kernel.org>; Thu, 13 Mar 2008 11:51:16 GMT
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2DBpF47014780
	for <netdev@vger.kernel.org>; Thu, 13 Mar 2008 11:51:16 GMT
Content-Disposition: inline; filename=udp-proc-handle-namespace.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes the common udp proc functions to take care
of which socket they should show taking into account the namespace
it belongs.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 include/net/udp.h |    1 +
 net/ipv4/udp.c    |   32 ++++++++++++++++++++++++++++----
 2 files changed, 29 insertions(+), 4 deletions(-)

Index: net-2.6.26/net/ipv4/udp.c
===================================================================
--- net-2.6.26.orig/net/ipv4/udp.c
+++ net-2.6.26/net/ipv4/udp.c
@@ -1512,10 +1512,13 @@ static struct sock *udp_get_first(struct
 {
 	struct sock *sk;
 	struct udp_iter_state *state = seq->private;
+	struct net *net = state->net;
 
 	for (state->bucket = 0; state->bucket < UDP_HTABLE_SIZE; ++state->bucket) {
 		struct hlist_node *node;
 		sk_for_each(sk, node, state->hashtable + state->bucket) {
+			if (sk->sk_net != net)
+				continue;
 			if (sk->sk_family == state->family)
 				goto found;
 		}
@@ -1528,12 +1531,13 @@ found:
 static struct sock *udp_get_next(struct seq_file *seq, struct sock *sk)
 {
 	struct udp_iter_state *state = seq->private;
+	struct net *net = state->net;
 
 	do {
 		sk = sk_next(sk);
 try_again:
 		;
-	} while (sk && sk->sk_family != state->family);
+	} while (sk && sk->sk_net != net && sk->sk_family != state->family);
 
 	if (!sk && ++state->bucket < UDP_HTABLE_SIZE) {
 		sk = sk_head(state->hashtable + state->bucket);
@@ -1582,31 +1586,51 @@ static int udp_seq_open(struct inode *in
 {
 	struct udp_seq_afinfo *afinfo = PDE(inode)->data;
 	struct seq_file *seq;
+	struct net *net;
 	int rc = -ENOMEM;
 	struct udp_iter_state *s = kzalloc(sizeof(*s), GFP_KERNEL);
 
 	if (!s)
 		goto out;
+
+	rc = -ENXIO;
+	net = get_proc_net(inode);
+	if (!net)
+		goto out_kfree;
+
 	s->family		= afinfo->family;
 	s->hashtable		= afinfo->hashtable;
 	s->seq_ops.start	= udp_seq_start;
 	s->seq_ops.next		= udp_seq_next;
 	s->seq_ops.show		= afinfo->seq_show;
 	s->seq_ops.stop		= udp_seq_stop;
+	s->net                  = net;
 
 	rc = seq_open(file, &s->seq_ops);
 	if (rc)
-		goto out_kfree;
+		goto out_put_net;
 
-	seq	     = file->private_data;
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
 
+static int udp_seq_release(struct inode *inode, struct file *file)
+{
+	struct seq_file *seq = file->private_data;
+	struct udp_iter_state *s = seq->private;
+
+	put_net(s->net);
+	seq_release_private(inode, file);
+	return 0;
+}
+
 /* ------------------------------------------------------------------------ */
 int udp_proc_register(struct udp_seq_afinfo *afinfo)
 {
@@ -1619,7 +1643,7 @@ int udp_proc_register(struct udp_seq_afi
 	afinfo->seq_fops->open		= udp_seq_open;
 	afinfo->seq_fops->read		= seq_read;
 	afinfo->seq_fops->llseek	= seq_lseek;
-	afinfo->seq_fops->release	= seq_release_private;
+	afinfo->seq_fops->release	= udp_seq_release;
 
 	p = proc_net_fops_create(&init_net, afinfo->name, S_IRUGO, afinfo->seq_fops);
 	if (p)
Index: net-2.6.26/include/net/udp.h
===================================================================
--- net-2.6.26.orig/include/net/udp.h
+++ net-2.6.26/include/net/udp.h
@@ -192,6 +192,7 @@ struct udp_seq_afinfo {
 };
 
 struct udp_iter_state {
+	struct net              *net;
 	sa_family_t		family;
 	struct hlist_head	*hashtable;
 	int			bucket;

-- 
