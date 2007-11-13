From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH] IPV4: add raw drops counter
Date: Tue, 13 Nov 2007 17:57:40 +0800
Message-ID: <47397514.2070002@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [222.73.24.84] ([222.73.24.84]:63182 "EHLO song.cn.fujitsu.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751250AbXKMJ7q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2007 04:59:46 -0500
Received: from tang.cn.fujitsu.com (tang.cn.fujitsu.com [10.167.250.3])
	by song.cn.fujitsu.com (Postfix) with ESMTP id 6D3F0170115
	for <netdev@vger.kernel.org>; Tue, 13 Nov 2007 17:59:43 +0800 (CST)
Received: from fnst.cn.fujitsu.com (localhost.localdomain [127.0.0.1])
	by tang.cn.fujitsu.com (8.13.1/8.13.1) with ESMTP id lAD9xg8E016942
	for <netdev@vger.kernel.org>; Tue, 13 Nov 2007 17:59:42 +0800
Received: from [127.0.0.1] (unknown [10.167.141.199])
	by fnst.cn.fujitsu.com (Postfix) with ESMTP id 62143D427B
	for <netdev@vger.kernel.org>; Tue, 13 Nov 2007 18:01:52 +0800 (CST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add raw drops counter for IPv4 in /proc/net/raw .

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 include/net/sock.h |    2 ++
 net/core/sock.c    |    1 +
 net/ipv4/raw.c     |   16 +++++++++-------
 3 files changed, 12 insertions(+), 7 deletions(-)

diff -Nurp linux-2.6.24-rc2.org/include/net/sock.h linux-2.6.24-rc2/include/net/sock.h
--- linux-2.6.24-rc2.org/include/net/sock.h	2007-11-09 16:37:08.000000000 +0800
+++ linux-2.6.24-rc2/include/net/sock.h	2007-11-13 15:19:20.000000000 +0800
@@ -156,6 +156,7 @@ struct sock_common {
   *	@sk_prot_creator: sk_prot of original sock creator (see ipv6_setsockopt, IPV6_ADDRFORM for instance)
   *	@sk_err: last error
   *	@sk_err_soft: errors that don't cause failure but are the cause of a persistent failure not just 'timed out'
+  *	@sk_drops: raw drops counter
   *	@sk_ack_backlog: current listen backlog
   *	@sk_max_ack_backlog: listen backlog set in listen()
   *	@sk_priority: %SO_PRIORITY setting
@@ -239,6 +240,7 @@ struct sock {
 	rwlock_t		sk_callback_lock;
 	int			sk_err,
 				sk_err_soft;
+	atomic_t		sk_drops;
 	unsigned short		sk_ack_backlog;
 	unsigned short		sk_max_ack_backlog;
 	__u32			sk_priority;
diff -Nurp linux-2.6.24-rc2.org/net/core/sock.c linux-2.6.24-rc2/net/core/sock.c
--- linux-2.6.24-rc2.org/net/core/sock.c	2007-11-09 16:37:40.000000000 +0800
+++ linux-2.6.24-rc2/net/core/sock.c	2007-11-13 15:20:53.000000000 +0800
@@ -1611,6 +1611,7 @@ void sock_init_data(struct socket *sock,
 	sk->sk_stamp = ktime_set(-1L, -1L);
 
 	atomic_set(&sk->sk_refcnt, 1);
+	atomic_set(&sk->sk_drops, 0);
 }
 
 void fastcall lock_sock_nested(struct sock *sk, int subclass)
diff -Nurp linux-2.6.24-rc2.org/net/ipv4/raw.c linux-2.6.24-rc2/net/ipv4/raw.c
--- linux-2.6.24-rc2.org/net/ipv4/raw.c	2007-11-09 16:37:56.000000000 +0800
+++ linux-2.6.24-rc2/net/ipv4/raw.c	2007-11-13 15:48:17.000000000 +0800
@@ -241,7 +241,7 @@ static int raw_rcv_skb(struct sock * sk,
 	/* Charge it to the socket. */
 
 	if (sock_queue_rcv_skb(sk, skb) < 0) {
-		/* FIXME: increment a raw drops counter here */
+		atomic_inc(&sk->sk_drops);	
 		kfree_skb(skb);
 		return NET_RX_DROP;
 	}
@@ -866,28 +866,30 @@ static __inline__ char *get_raw_sock(str
 	      srcp  = inet->num;
 
 	sprintf(tmpbuf, "%4d: %08X:%04X %08X:%04X"
-		" %02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %p",
+		" %02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %p %d",
 		i, src, srcp, dest, destp, sp->sk_state,
 		atomic_read(&sp->sk_wmem_alloc),
 		atomic_read(&sp->sk_rmem_alloc),
 		0, 0L, 0, sock_i_uid(sp), 0, sock_i_ino(sp),
-		atomic_read(&sp->sk_refcnt), sp);
+		atomic_read(&sp->sk_refcnt), sp, atomic_read(&sp->sk_drops));
 	return tmpbuf;
 }
 
+#define TMPSZ 128
+
 static int raw_seq_show(struct seq_file *seq, void *v)
 {
-	char tmpbuf[129];
+	char tmpbuf[TMPSZ+1];
 
 	if (v == SEQ_START_TOKEN)
-		seq_printf(seq, "%-127s\n",
+		seq_printf(seq, "%-*s\n", TMPSZ-1,
 			       "  sl  local_address rem_address   st tx_queue "
 			       "rx_queue tr tm->when retrnsmt   uid  timeout "
-			       "inode");
+			       "inode  drops");
 	else {
 		struct raw_iter_state *state = raw_seq_private(seq);
 
-		seq_printf(seq, "%-127s\n",
+		seq_printf(seq, "%-*s\n", TMPSZ-1,
 			   get_raw_sock(v, tmpbuf, state->bucket));
 	}
 	return 0;


