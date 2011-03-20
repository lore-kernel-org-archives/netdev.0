From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: [PATCH 2/2] socket: add minimum listen queue length sysctl
Date: Mon, 21 Mar 2011 00:04:42 +0100
Message-ID: <1300662282-24741-2-git-send-email-hagen@jauu.net>
References: <20110320121414.GC3038@nuttenaction>
 <1300662282-24741-1-git-send-email-hagen@jauu.net>
Cc: Hagen Paul Pfeifer <hagen@jauu.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:39232 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751632Ab1CTXFB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Mar 2011 19:05:01 -0400
In-Reply-To: <1300662282-24741-1-git-send-email-hagen@jauu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the case that a server programmer misjudge network characteristic the
backlog parameter for listen(2) may not adequate to utilize hosts
capabilities and lead to unrequired SYN retransmission - a small backlog
value can form an artificial limitation. From Erics server setup, a
listen queue length of 8 is often a way to small):

ss -a | head
State      Recv-Q Send-Q      Local Address:Port          Peer
Address:Port
LISTEN     0      8                       *:imaps                    *:*
LISTEN     0      8                       *:pop3s                    *:*
LISTEN     0      50                      *:mysql                    *:*
LISTEN     0      8                       *:pop3                     *:*
LISTEN     0      8                       *:imap2                    *:*
LISTEN     0      511                     *:www                      *:*

Until now it is not possible for the system (network) administrator to
increase this value. A bug report must be filled, the backlog increased,
a new version released or even worse: if using closed source software
you cannot make anything.

sysctl_min_syn_backlog provides the ability to increase the minimum
queue length. The default is 8.

Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>

---
I will spin a second documentation patch if Davem accept this patch.
---
 include/net/request_sock.h |    1 +
 net/core/request_sock.c    |    5 ++++-
 net/ipv4/sysctl_net_ipv4.c |    7 +++++++
 3 files changed, 12 insertions(+), 1 deletions(-)

diff --git a/include/net/request_sock.h b/include/net/request_sock.h
index 99e6e19..3e8865f 100644
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -89,6 +89,7 @@ static inline void reqsk_free(struct request_sock *req)
 }
 
 extern int sysctl_max_syn_backlog;
+extern int sysctl_min_syn_backlog;
 
 /** struct listen_sock - listen state
  *
diff --git a/net/core/request_sock.c b/net/core/request_sock.c
index 182236b..e937e9c 100644
--- a/net/core/request_sock.c
+++ b/net/core/request_sock.c
@@ -35,6 +35,9 @@
 int sysctl_max_syn_backlog = 256;
 EXPORT_SYMBOL(sysctl_max_syn_backlog);
 
+int sysctl_min_syn_backlog = 8;
+EXPORT_SYMBOL(sysctl_min_syn_backlog);
+
 int reqsk_queue_alloc(struct request_sock_queue *queue,
 		      unsigned int nr_table_entries)
 {
@@ -42,7 +45,7 @@ int reqsk_queue_alloc(struct request_sock_queue *queue,
 	struct listen_sock *lopt;
 
 	nr_table_entries = min_t(u32, nr_table_entries, sysctl_max_syn_backlog);
-	nr_table_entries = max_t(u32, nr_table_entries, 8);
+	nr_table_entries = max_t(u32, nr_table_entries, sysctl_min_syn_backlog);
 	nr_table_entries = roundup_pow_of_two(nr_table_entries + 1);
 	lopt_size += nr_table_entries * sizeof(struct request_sock *);
 	if (lopt_size > PAGE_SIZE)
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 1a45665..cc03c62 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -298,6 +298,13 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
+		.procname	= "tcp_min_syn_backlog",
+		.data		= &sysctl_min_syn_backlog,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
+	{
 		.procname	= "ip_local_port_range",
 		.data		= &sysctl_local_ports.range,
 		.maxlen		= sizeof(sysctl_local_ports.range),
-- 
1.7.4.1.57.g0466.dirty

