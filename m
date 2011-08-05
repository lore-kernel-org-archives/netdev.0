From: <rongqing.li@windriver.com>
Subject: [PATCH 5/5] Export the tcp sock's security context to proc.
Date: Fri, 5 Aug 2011 16:58:06 +0800
Message-ID: <1312534686-4099-6-git-send-email-rongqing.li@windriver.com>
References: <1312534686-4099-1-git-send-email-rongqing.li@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>, <selinux@tycho.nsa.gov>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:34227 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756158Ab1HEI6Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Aug 2011 04:58:16 -0400
In-Reply-To: <1312534686-4099-1-git-send-email-rongqing.li@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roy.Li <rongqing.li@windriver.com>

Export the tcp sock's security context to proc, since it maybe
different from the sock's owner process security context.

Signed-off-by: Roy.Li <rongqing.li@windriver.com>
---
 net/ipv4/tcp_ipv4.c |   15 +++++++++++----
 1 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 955b8e6..98a85d6 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2478,13 +2478,16 @@ static void get_timewait4_sock(struct inet_timewait_sock *tw,
 static int tcp4_seq_show(struct seq_file *seq, void *v)
 {
 	struct tcp_iter_state *st;
-	int len;
+	int len, sclen;
+	struct sock *s = NULL;
 
 	if (v == SEQ_START_TOKEN) {
-		seq_printf(seq, "%-*s\n", TMPSZ - 1,
+		seq_printf(seq,
 			   "  sl  local_address rem_address   st tx_queue "
 			   "rx_queue tr tm->when retrnsmt   uid  timeout "
-			   "inode");
+			   "inode %n", &len);
+		seq_printf(seq, "%-*s\n", TMPSZ - len - 1,
+			   (selinux_is_enabled() ? "  scontext" : ""));
 		goto out;
 	}
 	st = seq->private;
@@ -2493,15 +2496,19 @@ static int tcp4_seq_show(struct seq_file *seq, void *v)
 	case TCP_SEQ_STATE_LISTENING:
 	case TCP_SEQ_STATE_ESTABLISHED:
 		get_tcp4_sock(v, seq, st->num, &len);
+		s = v;
 		break;
 	case TCP_SEQ_STATE_OPENREQ:
 		get_openreq4(st->syn_wait_sk, v, seq, st->num, st->uid, &len);
+		s = st->syn_wait_sk;
 		break;
 	case TCP_SEQ_STATE_TIME_WAIT:
 		get_timewait4_sock(v, seq, st->num, &len);
 		break;
 	}
-	seq_printf(seq, "%*s\n", TMPSZ - 1 - len, "");
+
+	sock_write_secctx(s, seq, &sclen);
+	seq_printf(seq, "%*s\n", TMPSZ + sclen - 1 - len, "");
 out:
 	return 0;
 }
-- 
1.7.1

