From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [RFC PATCH net-2.6.26 (Plan A)] [TCP]: Lower stack usage in
 tcp4_seq_show().
Date: Tue, 15 Apr 2008 19:24:34 +0900 (JST)
Message-ID: <20080415.192434.05003640.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:33546 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754696AbYDOKWr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2008 06:22:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tcp4_seq_show() eats about 250 bytes.  By using buffer in seq_file
directly, it will be reduced under 100 bytes.

One drawback is slight change of the format - the format was fixed
size and now its size is variable.
However, size of the line was 128 bytes in 2.2, and 150 bytes in 2.6,
so the change may not matter, probably.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

--- 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 7766151..e3a6832 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2254,14 +2254,15 @@ void tcp_proc_unregister(struct net *net, struct tcp_seq_afinfo *afinfo)
 	proc_net_remove(net, afinfo->name);
 }
 
-static void get_openreq4(struct sock *sk, struct request_sock *req,
-			 char *tmpbuf, int i, int uid)
+static void get_openreq4(struct seq_file *seq, struct sock *sk,
+			 struct request_sock *req,
+			 int i, int uid)
 {
 	const struct inet_request_sock *ireq = inet_rsk(req);
 	int ttd = req->expires - jiffies;
 
-	sprintf(tmpbuf, "%4d: %08X:%04X %08X:%04X"
-		" %02X %08X:%08X %02X:%08lX %08X %5d %8d %u %d %p",
+	seq_printf(seq, "%4d: %08X:%04X %08X:%04X"
+		" %02X %08X:%08X %02X:%08lX %08X %5d %8d %u %d %p\n",
 		i,
 		ireq->loc_addr,
 		ntohs(inet_sk(sk)->sport),
@@ -2279,7 +2280,7 @@ static void get_openreq4(struct sock *sk, struct request_sock *req,
 		req);
 }
 
-static void get_tcp4_sock(struct sock *sk, char *tmpbuf, int i)
+static void get_tcp4_sock(struct seq_file *seq, struct sock *sk, int i)
 {
 	int timer_active;
 	unsigned long timer_expires;
@@ -2305,8 +2306,8 @@ static void get_tcp4_sock(struct sock *sk, char *tmpbuf, int i)
 		timer_expires = jiffies;
 	}
 
-	sprintf(tmpbuf, "%4d: %08X:%04X %08X:%04X %02X %08X:%08X %02X:%08lX "
-			"%08X %5d %8d %lu %d %p %u %u %u %u %d",
+	seq_printf(seq, "%4d: %08X:%04X %08X:%04X %02X %08X:%08X %02X:%08lX "
+			"%08X %5d %8d %lu %d %p %u %u %u %u %d\n",
 		i, src, srcp, dest, destp, sk->sk_state,
 		tp->write_seq - tp->snd_una,
 		sk->sk_state == TCP_LISTEN ? sk->sk_ack_backlog :
@@ -2325,8 +2326,8 @@ static void get_tcp4_sock(struct sock *sk, char *tmpbuf, int i)
 		tp->snd_ssthresh >= 0xFFFF ? -1 : tp->snd_ssthresh);
 }
 
-static void get_timewait4_sock(struct inet_timewait_sock *tw,
-			       char *tmpbuf, int i)
+static void get_timewait4_sock(struct seq_file *seq, struct inet_timewait_sock *tw,
+			       int i)
 {
 	__be32 dest, src;
 	__u16 destp, srcp;
@@ -2340,25 +2341,22 @@ static void get_timewait4_sock(struct inet_timewait_sock *tw,
 	destp = ntohs(tw->tw_dport);
 	srcp  = ntohs(tw->tw_sport);
 
-	sprintf(tmpbuf, "%4d: %08X:%04X %08X:%04X"
-		" %02X %08X:%08X %02X:%08lX %08X %5d %8d %d %d %p",
+	seq_printf(seq, "%4d: %08X:%04X %08X:%04X"
+		" %02X %08X:%08X %02X:%08lX %08X %5d %8d %d %d %p\n",
 		i, src, srcp, dest, destp, tw->tw_substate, 0, 0,
 		3, jiffies_to_clock_t(ttd), 0, 0, 0, 0,
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
-			   "  sl  local_address rem_address   st tx_queue "
-			   "rx_queue tr tm->when retrnsmt   uid  timeout "
-			   "inode");
+		seq_puts(seq,
+			 "  sl  local_address rem_address   st tx_queue "
+			 "rx_queue tr tm->when retrnsmt   uid  timeout "
+			 "inode\n");
 		goto out;
 	}
 	st = seq->private;
@@ -2366,16 +2364,15 @@ static int tcp4_seq_show(struct seq_file *seq, void *v)
 	switch (st->state) {
 	case TCP_SEQ_STATE_LISTENING:
 	case TCP_SEQ_STATE_ESTABLISHED:
-		get_tcp4_sock(v, tmpbuf, st->num);
+		get_tcp4_sock(seq, v, st->num);
 		break;
 	case TCP_SEQ_STATE_OPENREQ:
-		get_openreq4(st->syn_wait_sk, v, tmpbuf, st->num, st->uid);
+		get_openreq4(seq, st->syn_wait_sk, v, st->num, st->uid);
 		break;
 	case TCP_SEQ_STATE_TIME_WAIT:
-		get_timewait4_sock(v, tmpbuf, st->num);
+		get_timewait4_sock(seq, v, st->num);
 		break;
 	}
-	seq_printf(seq, "%-*s\n", TMPSZ - 1, tmpbuf);
 out:
 	return 0;
 }

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
