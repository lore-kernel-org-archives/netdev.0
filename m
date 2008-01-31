From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 2/3] [RAW]: Cleanup IPv4 raw_seq_show.
Date: Thu, 31 Jan 2008 14:34:53 +0300
Message-ID: <1201779294-21987-2-git-send-email-den@openvz.org>
References: <47A1B1E4.2010804@sw.ru>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	devel@openvz.org, xemul@openvz.org, bunk@kernel.org,
	"Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:59413 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757659AbYAaLev (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jan 2008 06:34:51 -0500
In-Reply-To: <47A1B1E4.2010804@sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no need to use 128 bytes on the stack at all. Clean the code in
the IPv6 style.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/ipv4/raw.c |   24 +++++++-----------------
 1 files changed, 7 insertions(+), 17 deletions(-)

diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 507cbfe..830f19e 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -927,7 +927,7 @@ void raw_seq_stop(struct seq_file *seq, void *v)
 }
 EXPORT_SYMBOL_GPL(raw_seq_stop);
 
-static __inline__ char *get_raw_sock(struct sock *sp, char *tmpbuf, int i)
+static void raw_sock_seq_show(struct seq_file *seq, struct sock *sp, int i)
 {
 	struct inet_sock *inet = inet_sk(sp);
 	__be32 dest = inet->daddr,
@@ -935,33 +935,23 @@ static __inline__ char *get_raw_sock(struct sock *sp, char *tmpbuf, int i)
 	__u16 destp = 0,
 	      srcp  = inet->num;
 
-	sprintf(tmpbuf, "%4d: %08X:%04X %08X:%04X"
+	seq_printf(seq, "%4d: %08X:%04X %08X:%04X"
 		" %02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %p %d",
 		i, src, srcp, dest, destp, sp->sk_state,
 		atomic_read(&sp->sk_wmem_alloc),
 		atomic_read(&sp->sk_rmem_alloc),
 		0, 0L, 0, sock_i_uid(sp), 0, sock_i_ino(sp),
 		atomic_read(&sp->sk_refcnt), sp, atomic_read(&sp->sk_drops));
-	return tmpbuf;
 }
 
-#define TMPSZ 128
-
 static int raw_seq_show(struct seq_file *seq, void *v)
 {
-	char tmpbuf[TMPSZ+1];
-
 	if (v == SEQ_START_TOKEN)
-		seq_printf(seq, "%-*s\n", TMPSZ-1,
-			       "  sl  local_address rem_address   st tx_queue "
-			       "rx_queue tr tm->when retrnsmt   uid  timeout "
-			       "inode  drops");
-	else {
-		struct raw_iter_state *state = raw_seq_private(seq);
-
-		seq_printf(seq, "%-*s\n", TMPSZ-1,
-			   get_raw_sock(v, tmpbuf, state->bucket));
-	}
+		seq_printf(seq, "  sl  local_address rem_address   st tx_queue "
+				"rx_queue tr tm->when retrnsmt   uid  timeout "
+				"inode  drops\n");
+	else
+		raw_sock_seq_show(seq, v, raw_seq_private(seq)->bucket);
 	return 0;
 }
 
-- 
1.5.3.rc5

