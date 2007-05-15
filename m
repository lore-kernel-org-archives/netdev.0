From: Mark Glines <mark@glines.org>
Subject: [PATCH] use default 32768-61000 outgoing port range in all cases
Date: Tue, 15 May 2007 15:50:54 -0700
Message-ID: <20070515155054.394f4032@chirp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from squawk.glines.org ([72.36.206.66]:37922 "EHLO squawk.glines.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758223AbXEOWu7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 May 2007 18:50:59 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I noticed I had chopped off a whole comment, when I meant to only remove
part of it.  So I've fixed that.

This is a reissued use-high-ports-for-local-stuff.diff, with a comment
fix.  Does anyone have a problem with this patch in its current form?
Any chance of applying it?

This diff changes the default port range used for outgoing connections,
from "use 32768-61000 in most cases, but use N-4999 on small boxes
(where N is a multiple of 1024, depending on just *how* small the box
is)" to just "use 32768-61000 in all cases".

I don't believe there are any drawbacks to this change, and it keeps
outgoing connection ports farther away from the mess of IANA-registered
ports.

Thanks,

Signed-off-by: Mark Glines <mark@glines.org>

diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 43fb160..fbe7714 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -31,10 +31,8 @@ EXPORT_SYMBOL(inet_csk_timer_bug_msg);
 
 /*
  * This array holds the first and last local port number.
- * For high-usage systems, use sysctl to change this to
- * 32768-61000
  */
-int sysctl_local_port_range[2] = { 1024, 4999 };
+int sysctl_local_port_range[2] = { 32768, 61000 };
 
 int inet_csk_bind_conflict(const struct sock *sk,
 			   const struct inet_bind_bucket *tb)
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index bd4c295..33ef0e7 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2465,13 +2465,10 @@ void __init tcp_init(void)
 			order++)
 		;
 	if (order >= 4) {
-		sysctl_local_port_range[0] = 32768;
-		sysctl_local_port_range[1] = 61000;
 		tcp_death_row.sysctl_max_tw_buckets = 180000;
 		sysctl_tcp_max_orphans = 4096 << (order - 4);
 		sysctl_max_syn_backlog = 1024;
 	} else if (order < 3) {
-		sysctl_local_port_range[0] = 1024 * (3 - order);
 		tcp_death_row.sysctl_max_tw_buckets >>= (3 - order);
 		sysctl_tcp_max_orphans >>= (3 - order);
 		sysctl_max_syn_backlog = 128;
