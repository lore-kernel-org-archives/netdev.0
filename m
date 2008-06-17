From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] udp: sk_drops handling
Date: Tue, 17 Jun 2008 23:31:33 +0200
Message-ID: <48582D35.40201@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Wang Chen <wangchen@cn.fujitsu.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2f.orange.fr ([80.12.242.152]:10704 "EHLO smtp2f.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756218AbYFQVbo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jun 2008 17:31:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commits 33c732c36169d7022ad7d6eb474b0c9be43a2dc1 ([IPV4]: Add raw drops
 counter) and a92aa318b4b369091fd80433c80e62838db8bc1c ([IPV4]: Add raw drops
 counter),
Wang Chen added raw drops counter for /proc/net/raw & /proc/net/raw6

This patch adds this capability to UDP sockets too (/proc/net/udp &
 /proc/net/udp6).

This means that 'RcvbufErrors' errors found in /proc/net/snmp can be also
be examined for each udp socket.

# grep Udp: /proc/net/snmp
Udp: InDatagrams NoPorts InErrors OutDatagrams RcvbufErrors SndbufErrors
Udp: 23971006 75 899420 16390693 146348 0

# cat /proc/net/udp
  sl  local_address rem_address   st tx_queue rx_queue tr tm->when retrnsmt  ---
 uid  timeout inode ref pointer drops
  75: 00000000:02CB 00000000:0000 07 00000000:00000000 00:00000000 00000000  ---
   0        0 2358 2 ffff81082a538c80 0
 111: 00000000:006F 00000000:0000 07 00000000:00000000 00:00000000 00000000  ---
   0        0 2286 2 ffff81042dd35c80 146348

In this example, only port 111 (0x006F) was flooded by messages that user program
could not read fast enough. 146348 messages were lost.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

diff --git a/include/net/sock.h b/include/net/sock.h
index 83f74b1..a7c3041 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -166,7 +166,7 @@ struct sock_common {
   *	@sk_err: last error
   *	@sk_err_soft: errors that don't cause failure but are the cause of a
   *		      persistent failure not just 'timed out'
-  *	@sk_drops: raw drops counter
+  *	@sk_drops: raw/udp drops counter
   *	@sk_ack_backlog: current listen backlog
   *	@sk_max_ack_backlog: listen backlog set in listen()
   *	@sk_priority: %SO_PRIORITY setting
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 7d44946..925fdf1 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -944,7 +944,7 @@ static int raw_seq_show(struct seq_file *seq, void *v)
 	if (v == SEQ_START_TOKEN)
 		seq_printf(seq, "  sl  local_address rem_address   st tx_queue "
 				"rx_queue tr tm->when retrnsmt   uid  timeout "
-				"inode  drops\n");
+				"inode ref pointer drops\n");
 	else
 		raw_sock_seq_show(seq, v, raw_seq_private(seq)->bucket);
 	return 0;
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 11eabf1..dd95e93 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1049,6 +1049,7 @@ int udp_queue_rcv_skb(struct sock * sk, struct sk_buff *skb)
 
 drop:
 	UDP_INC_STATS_BH(UDP_MIB_INERRORS, is_udplite);
+	atomic_inc(&sk->sk_drops);
 	kfree_skb(skb);
 	return -1;
 }
@@ -1629,12 +1630,13 @@ static void udp4_format_sock(struct sock *sp, struct seq_file *f,
 	__u16 srcp	  = ntohs(inet->sport);
 
 	seq_printf(f, "%4d: %08X:%04X %08X:%04X"
-		" %02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %p%n",
+		" %02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %p %d%n",
 		bucket, src, srcp, dest, destp, sp->sk_state,
 		atomic_read(&sp->sk_wmem_alloc),
 		atomic_read(&sp->sk_rmem_alloc),
 		0, 0L, 0, sock_i_uid(sp), 0, sock_i_ino(sp),
-		atomic_read(&sp->sk_refcnt), sp, len);
+		atomic_read(&sp->sk_refcnt), sp,
+		atomic_read(&sp->sk_drops), len);
 }
 
 int udp4_seq_show(struct seq_file *seq, void *v)
@@ -1643,7 +1645,7 @@ int udp4_seq_show(struct seq_file *seq, void *v)
 		seq_printf(seq, "%-127s\n",
 			   "  sl  local_address rem_address   st tx_queue "
 			   "rx_queue tr tm->when retrnsmt   uid  timeout "
-			   "inode");
+			   "inode ref pointer drops");
 	else {
 		struct udp_iter_state *state = seq->private;
 		int len;
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 456777d..34cfb3f 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -1251,7 +1251,7 @@ static int raw6_seq_show(struct seq_file *seq, void *v)
 			   "local_address                         "
 			   "remote_address                        "
 			   "st tx_queue rx_queue tr tm->when retrnsmt"
-			   "   uid  timeout inode  drops\n");
+			   "   uid  timeout inode ref pointer drops\n");
 	else
 		raw6_sock_seq_show(seq, v, raw_seq_private(seq)->bucket);
 	return 0;
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 432edaa..020e7f6 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -305,6 +305,7 @@ int udpv6_queue_rcv_skb(struct sock * sk, struct sk_buff *skb)
 	return 0;
 drop:
 	UDP6_INC_STATS_BH(UDP_MIB_INERRORS, is_udplite);
+	atomic_inc(&sk->sk_drops);
 	kfree_skb(skb);
 	return -1;
 }
@@ -955,7 +956,7 @@ static void udp6_sock_seq_show(struct seq_file *seq, struct sock *sp, int bucket
 	srcp  = ntohs(inet->sport);
 	seq_printf(seq,
 		   "%4d: %08X%08X%08X%08X:%04X %08X%08X%08X%08X:%04X "
-		   "%02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %p\n",
+		   "%02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %p %d\n",
 		   bucket,
 		   src->s6_addr32[0], src->s6_addr32[1],
 		   src->s6_addr32[2], src->s6_addr32[3], srcp,
@@ -967,7 +968,8 @@ static void udp6_sock_seq_show(struct seq_file *seq, struct sock *sp, int bucket
 		   0, 0L, 0,
 		   sock_i_uid(sp), 0,
 		   sock_i_ino(sp),
-		   atomic_read(&sp->sk_refcnt), sp);
+		   atomic_read(&sp->sk_refcnt), sp,
+		   atomic_read(&sp->sk_drops));
 }
 
 int udp6_seq_show(struct seq_file *seq, void *v)
@@ -978,7 +980,7 @@ int udp6_seq_show(struct seq_file *seq, void *v)
 			   "local_address                         "
 			   "remote_address                        "
 			   "st tx_queue rx_queue tr tm->when retrnsmt"
-			   "   uid  timeout inode\n");
+			   "   uid  timeout inode ref pointer drops\n");
 	else
 		udp6_sock_seq_show(seq, v, ((struct udp_iter_state *)seq->private)->bucket);
 	return 0;


