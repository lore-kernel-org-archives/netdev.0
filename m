From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH 2/2] SOCK: add raw6 drops counter
Date: Wed, 14 Nov 2007 11:15:57 +0800
Message-ID: <473A686D.9020200@cn.fujitsu.com>
References: <47397514.2070002@cn.fujitsu.com> <473A6792.10405@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dada1@cosmosbay.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from [222.73.24.84] ([222.73.24.84]:62897 "EHLO song.cn.fujitsu.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754747AbXKNDSC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2007 22:18:02 -0500
In-Reply-To: <473A6792.10405@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add raw drops counter for IPv6 in /proc/net/raw6 .

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 raw.c |   15 ++++++++-------
 1 files changed, 8 insertions(+), 7 deletions(-)

diff -Nurp linux-2.6.24-rc2.org/net/ipv6/raw.c linux-2.6.24-rc2/net/ipv6/raw.c
--- linux-2.6.24-rc2.org/net/ipv6/raw.c	2007-11-09 16:38:05.000000000 +0800
+++ linux-2.6.24-rc2/net/ipv6/raw.c	2007-11-14 09:46:54.000000000 +0800
@@ -354,14 +354,14 @@ static inline int rawv6_rcv_skb(struct s
 {
 	if ((raw6_sk(sk)->checksum || sk->sk_filter) &&
 	    skb_checksum_complete(skb)) {
-		/* FIXME: increment a raw6 drops counter here */
+		atomic_inc(&sk->sk_drops);	
 		kfree_skb(skb);
 		return 0;
 	}
 
 	/* Charge it to the socket. */
 	if (sock_queue_rcv_skb(sk,skb)<0) {
-		/* FIXME: increment a raw6 drops counter here */
+		atomic_inc(&sk->sk_drops);
 		kfree_skb(skb);
 		return 0;
 	}
@@ -382,6 +382,7 @@ int rawv6_rcv(struct sock *sk, struct sk
 	struct raw6_sock *rp = raw6_sk(sk);
 
 	if (!xfrm6_policy_check(sk, XFRM_POLICY_IN, skb)) {
+		atomic_inc(&sk->sk_drops);
 		kfree_skb(skb);
 		return NET_RX_DROP;
 	}
@@ -405,7 +406,7 @@ int rawv6_rcv(struct sock *sk, struct sk
 
 	if (inet->hdrincl) {
 		if (skb_checksum_complete(skb)) {
-			/* FIXME: increment a raw6 drops counter here */
+			atomic_inc(&sk->sk_drops);
 			kfree_skb(skb);
 			return 0;
 		}
@@ -496,7 +497,7 @@ csum_copy_err:
 	   as some normal condition.
 	 */
 	err = (flags&MSG_DONTWAIT) ? -EAGAIN : -EHOSTUNREACH;
-	/* FIXME: increment a raw6 drops counter here */
+	atomic_inc(&sk->sk_drops);
 	goto out;
 }
 
@@ -1251,7 +1252,7 @@ static void raw6_sock_seq_show(struct se
 	srcp  = inet_sk(sp)->num;
 	seq_printf(seq,
 		   "%4d: %08X%08X%08X%08X:%04X %08X%08X%08X%08X:%04X "
-		   "%02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %p\n",
+		   "%02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %p %d\n",
 		   i,
 		   src->s6_addr32[0], src->s6_addr32[1],
 		   src->s6_addr32[2], src->s6_addr32[3], srcp,
@@ -1263,7 +1264,7 @@ static void raw6_sock_seq_show(struct se
 		   0, 0L, 0,
 		   sock_i_uid(sp), 0,
 		   sock_i_ino(sp),
-		   atomic_read(&sp->sk_refcnt), sp);
+		   atomic_read(&sp->sk_refcnt), sp, atomic_read(&sp->sk_drops));
 }
 
 static int raw6_seq_show(struct seq_file *seq, void *v)
@@ -1274,7 +1275,7 @@ static int raw6_seq_show(struct seq_file
 			   "local_address                         "
 			   "remote_address                        "
 			   "st tx_queue rx_queue tr tm->when retrnsmt"
-			   "   uid  timeout inode\n");
+			   "   uid  timeout inode  drops\n");
 	else
 		raw6_sock_seq_show(seq, v, raw6_seq_private(seq)->bucket);
 	return 0;

