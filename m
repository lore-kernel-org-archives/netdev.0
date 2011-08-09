From: <rongqing.li@windriver.com>
Subject: [PATCH 6/6] Export the tcp sock's security context to proc.
Date: Tue, 9 Aug 2011 15:28:30 +0800
Message-ID: <1312874910-31010-7-git-send-email-rongqing.li@windriver.com>
References: <1312874910-31010-1-git-send-email-rongqing.li@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>, <selinux@tycho.nsa.gov>,
	<linux-security-module@vger.kernel.org>, <sds@tycho.nsa.gov>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:43758 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752438Ab1HIH2o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2011 03:28:44 -0400
In-Reply-To: <1312874910-31010-1-git-send-email-rongqing.li@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roy.Li <rongqing.li@windriver.com>

Export the tcp sock's security context to proc, since it maybe
different from the sock's owner process security context.

Signed-off-by: Roy.Li <rongqing.li@windriver.com>
---
 net/ipv4/tcp_ipv4.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 955b8e6..ddac912 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2479,12 +2479,13 @@ static int tcp4_seq_show(struct seq_file *seq, void *v)
 {
 	struct tcp_iter_state *st;
 	int len;
+	struct sock *s = NULL;
 
 	if (v == SEQ_START_TOKEN) {
 		seq_printf(seq, "%-*s\n", TMPSZ - 1,
 			   "  sl  local_address rem_address   st tx_queue "
 			   "rx_queue tr tm->when retrnsmt   uid  timeout "
-			   "inode");
+			   "inode seclabel");
 		goto out;
 	}
 	st = seq->private;
@@ -2493,15 +2494,20 @@ static int tcp4_seq_show(struct seq_file *seq, void *v)
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
+	len += sock_write_secctx(s, seq);
+	len = TMPSZ - 1 - len;
+	seq_printf(seq, "%*s\n", len > 0 ? len : 0, "");
 out:
 	return 0;
 }
-- 
1.7.1

