From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [RFC PATCH net-2.6.26 (Plan B)] [TCP]: Lower stack usage in
 tcp4_seq_show().
Date: Tue, 15 Apr 2008 19:33:55 +0900 (JST)
Message-ID: <20080415.193355.36907928.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:33550 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753932AbYDOKcF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2008 06:32:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tcp4_seq_show() eats about 250 bytes.  By using buffer in seq_file
directly, it will be reduced around 100 bytes.

One drawback is higher usage of slab for IPv6 but the format
will not change with this patch.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

---
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 2c14edf..2c6d9ba 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1333,12 +1333,15 @@ struct tcp_seq_afinfo {
 	struct seq_operations	seq_ops;
 };
 
+#define TCP_SEQFILE_BLOCKSIZE	150
+
 struct tcp_iter_state {
 	struct seq_net_private	p;
 	sa_family_t		family;
 	enum tcp_seq_states	state;
 	struct sock		*syn_wait_sk;
 	int			bucket, sbucket, num, uid;
+	char			buf[TCP_SEQFILE_BLOCKSIZE + 1];	/* for IPv4 */
 };
 
 extern int tcp_proc_register(struct net *net, struct tcp_seq_afinfo *afinfo);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 7766151..8f1cabf 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2347,15 +2347,12 @@ static void get_timewait4_sock(struct inet_timewait_sock *tw,
 		atomic_read(&tw->tw_refcnt), tw);
 }
 
-#define TMPSZ 150
-
 static int tcp4_seq_show(struct seq_file *seq, void *v)
 {
 	struct tcp_iter_state* st;
-	char tmpbuf[TMPSZ + 1];
 
 	if (v == SEQ_START_TOKEN) {
-		seq_printf(seq, "%-*s\n", TMPSZ - 1,
+		seq_printf(seq, "%-*s\n", TCP_SEQFILE_BLOCKSIZE - 1,
 			   "  sl  local_address rem_address   st tx_queue "
 			   "rx_queue tr tm->when retrnsmt   uid  timeout "
 			   "inode");
@@ -2366,16 +2363,16 @@ static int tcp4_seq_show(struct seq_file *seq, void *v)
 	switch (st->state) {
 	case TCP_SEQ_STATE_LISTENING:
 	case TCP_SEQ_STATE_ESTABLISHED:
-		get_tcp4_sock(v, tmpbuf, st->num);
+		get_tcp4_sock(v, st->buf, st->num);
 		break;
 	case TCP_SEQ_STATE_OPENREQ:
-		get_openreq4(st->syn_wait_sk, v, tmpbuf, st->num, st->uid);
+		get_openreq4(st->syn_wait_sk, v, st->buf, st->num, st->uid);
 		break;
 	case TCP_SEQ_STATE_TIME_WAIT:
-		get_timewait4_sock(v, tmpbuf, st->num);
+		get_timewait4_sock(v, st->buf, st->num);
 		break;
 	}
-	seq_printf(seq, "%-*s\n", TMPSZ - 1, tmpbuf);
+	seq_printf(seq, "%-*s\n", TCP_SEQFILE_BLOCKSIZE - 1, st->buf);
 out:
 	return 0;
 }
