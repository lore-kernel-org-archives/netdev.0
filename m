From: <rongqing.li@windriver.com>
Subject: [PATCH 4/5] Export the unix sock's security context to proc.
Date: Fri, 5 Aug 2011 16:58:05 +0800
Message-ID: <1312534686-4099-5-git-send-email-rongqing.li@windriver.com>
References: <1312534686-4099-1-git-send-email-rongqing.li@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>, <selinux@tycho.nsa.gov>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:34221 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756152Ab1HEI6P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Aug 2011 04:58:15 -0400
In-Reply-To: <1312534686-4099-1-git-send-email-rongqing.li@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roy.Li <rongqing.li@windriver.com>

Export the unix sock's security context to proc, since it maybe
different from the sock's owner process security context.

Signed-off-by: Roy.Li <rongqing.li@windriver.com>
---
 net/unix/af_unix.c |   15 +++++++++++++--
 1 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index ec68e1c..338fa0a 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -2239,12 +2239,15 @@ static void unix_seq_stop(struct seq_file *seq, void *v)
 	spin_unlock(&unix_table_lock);
 }
 
+#define OFFSET_PATH_START	40
 static int unix_seq_show(struct seq_file *seq, void *v)
 {
+	int seqlen, offset = OFFSET_PATH_START;
 
 	if (v == SEQ_START_TOKEN)
-		seq_puts(seq, "Num       RefCount Protocol Flags    Type St "
-			 "Inode Path\n");
+		seq_printf(seq, "Num       RefCount Protocol Flags    Type St "
+			 "Inode Path    %s",
+			 (selinux_is_enabled() ? "  scontext\n" : "\n"));
 	else {
 		struct sock *s = v;
 		struct unix_sock *u = unix_sk(s);
@@ -2275,7 +2278,15 @@ static int unix_seq_show(struct seq_file *seq, void *v)
 			}
 			for ( ; i < len; i++)
 				seq_putc(seq, u->addr->name->sun_path[i]);
+			if (offset > len)
+				offset -= (len + 1);
+			else
+				offset = 0;
 		}
+
+		seq_printf(seq, "%*c", offset, '\b');
+		sock_write_secctx(s, seq, &seqlen);
+
 		unix_state_unlock(s);
 		seq_putc(seq, '\n');
 	}
-- 
1.7.1

