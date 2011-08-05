From: <rongqing.li@windriver.com>
Subject: [PATCH 2/5] Export the raw sock's security context to proc.
Date: Fri, 5 Aug 2011 16:58:03 +0800
Message-ID: <1312534686-4099-3-git-send-email-rongqing.li@windriver.com>
References: <1312534686-4099-1-git-send-email-rongqing.li@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>, <selinux@tycho.nsa.gov>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:34198 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756112Ab1HEI6M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Aug 2011 04:58:12 -0400
In-Reply-To: <1312534686-4099-1-git-send-email-rongqing.li@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roy.Li <rongqing.li@windriver.com>

The element sk_security of struct sock represents the socket
security context ID, which is inheriting from the process when
creates this socket on most of the time.

but when SELinux type_transition rule is applied to socket, or
application sets /proc/xxx/attr/createsock, the socket security
context would be different from the creating process. on this
condition, the "netstat -Z" will return wrong value, since
"netstat -Z" only returns the process security context as socket
process security.

Export the raw sock's security context to proc, so that "netstat -Z"
could be fixed by reading procfs.

Signed-off-by: Roy.Li <rongqing.li@windriver.com>
---
 net/ipv4/raw.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 1457acb..645d373 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -972,6 +972,7 @@ EXPORT_SYMBOL_GPL(raw_seq_stop);
 
 static void raw_sock_seq_show(struct seq_file *seq, struct sock *sp, int i)
 {
+	int sclen;
 	struct inet_sock *inet = inet_sk(sp);
 	__be32 dest = inet->inet_daddr,
 	       src = inet->inet_rcv_saddr;
@@ -979,12 +980,15 @@ static void raw_sock_seq_show(struct seq_file *seq, struct sock *sp, int i)
 	      srcp  = inet->inet_num;
 
 	seq_printf(seq, "%4d: %08X:%04X %08X:%04X"
-		" %02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %pK %d\n",
+		" %02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %pK %d",
 		i, src, srcp, dest, destp, sp->sk_state,
 		sk_wmem_alloc_get(sp),
 		sk_rmem_alloc_get(sp),
 		0, 0L, 0, sock_i_uid(sp), 0, sock_i_ino(sp),
 		atomic_read(&sp->sk_refcnt), sp, atomic_read(&sp->sk_drops));
+
+	sock_write_secctx(sp, seq, &sclen);
+	seq_putc(seq, '\n');
 }
 
 static int raw_seq_show(struct seq_file *seq, void *v)
@@ -992,7 +996,8 @@ static int raw_seq_show(struct seq_file *seq, void *v)
 	if (v == SEQ_START_TOKEN)
 		seq_printf(seq, "  sl  local_address rem_address   st tx_queue "
 				"rx_queue tr tm->when retrnsmt   uid  timeout "
-				"inode ref pointer drops\n");
+				"inode ref pointer drops %s",
+				(selinux_is_enabled() ? "  scontext\n" : "\n"));
 	else
 		raw_sock_seq_show(seq, v, raw_seq_private(seq)->bucket);
 	return 0;
-- 
1.7.1

