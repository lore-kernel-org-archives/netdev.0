From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: [PATCH 2/2] socket: add minimum listen queue length sysctl
Date: Fri, 25 Mar 2011 19:31:39 +0100
Message-ID: <1301077899-16482-2-git-send-email-hagen@jauu.net>
References: <1301077899-16482-1-git-send-email-hagen@jauu.net>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:37364 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754840Ab1CYScO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Mar 2011 14:32:14 -0400
In-Reply-To: <1301077899-16482-1-git-send-email-hagen@jauu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the case that a server programmer misjudge network characteristic the
backlog parameter for listen(2) may not adequate to utilize hosts
capabilities and lead to unrequired SYN retransmission - thus a
underestimated backlog value can form an artificial limitation.

A listen queue length of 8 is often a way to small, but several
server authors does not about know this limitation (from Erics server
setup):

ss -a | head
State      Recv-Q Send-Q      Local Address:Port          Peer
Address:Port
LISTEN     0      8                       *:imaps                    *:*
LISTEN     0      8                       *:pop3s                    *:*
LISTEN     0      50                      *:mysql                    *:*
LISTEN     0      8                       *:pop3                     *:*
LISTEN     0      8                       *:imap2                    *:*
LISTEN     0      511                     *:www                      *:*

Until now it was not possible for the system (network) administrator to
increase this value. A bug report must be filled, the backlog increased,
a new version released or even worse: if using closed source software
you cannot make anything.

sysctl_min_syn_backlog provides the ability to increase the minimum
queue length.

Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/request_sock.h |    1 +
 net/core/request_sock.c    |    6 +++++-
 net/ipv4/af_inet.c         |    2 +-
 net/ipv4/sysctl_net_ipv4.c |    7 +++++++
 4 files changed, 14 insertions(+), 2 deletions(-)

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
index 182236b..0e968b6 100644
--- a/net/core/request_sock.c
+++ b/net/core/request_sock.c
@@ -35,6 +35,9 @@
 int sysctl_max_syn_backlog = 256;
 EXPORT_SYMBOL(sysctl_max_syn_backlog);
 
+int sysctl_min_syn_backlog = 0;
+EXPORT_SYMBOL(sysctl_min_syn_backlog);
+
 int reqsk_queue_alloc(struct request_sock_queue *queue,
 		      unsigned int nr_table_entries)
 {
@@ -42,7 +45,8 @@ int reqsk_queue_alloc(struct request_sock_queue *queue,
 	struct listen_sock *lopt;
 
 	nr_table_entries = min_t(u32, nr_table_entries, sysctl_max_syn_backlog);
-	nr_table_entries = max_t(u32, nr_table_entries, 8);
+	nr_table_entries = max_t(u32, nr_table_entries,
+			max_t(u32, 8, sysctl_min_syn_backlog));
 	nr_table_entries = roundup_pow_of_two(nr_table_entries + 1);
 	lopt_size += nr_table_entries * sizeof(struct request_sock *);
 	if (lopt_size > PAGE_SIZE)
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 807d83c..c580d7c 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -213,7 +213,7 @@ int inet_listen(struct socket *sock, int backlog)
 		if (err)
 			goto out;
 	}
-	sk->sk_max_ack_backlog = backlog;
+	sk->sk_max_ack_backlog = max_t(u32, backlog, sysctl_min_syn_backlog);
 	err = 0;
 
 out:
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
1.7.2.3

