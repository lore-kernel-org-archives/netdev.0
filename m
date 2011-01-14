From: Bill Sommerfeld <wsommerfeld@google.com>
Subject: [PATCH] Make INET_LHTABLE_SIZE a compile-time tunable
Date: Fri, 14 Jan 2011 13:48:08 -0800
Message-ID: <1295041688-16550-1-git-send-email-wsommerfeld@google.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Bill Sommerfeld <wsommerfeld@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:61471 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752917Ab1ANVs3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jan 2011 16:48:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

INET_LHTABLE_SIZE has been fixed at 32 for a long time.  It should be
tunable as larger systems may be running many more than 32 listeners.
Since the exising code depends on the hash table size
being a power of two, use a shift value as the tunable and
compute the hash table size from the shift value.

Signed-off-by: Bill Sommerfeld <wsommerfeld@google.com>
---
Background: We've observed that many of our machines are now running
with well in excess of 32 TCP listener sockets open.  As the number of
cpu cores per system increases we expect this to grow further.

In general hash tables should be sized to keep hash chains short, and
32 is not enough for this on some of our machines.

The help text was inspired by the help text for LOG_BUF_SHIFT in
init/Kconfig

 include/net/inet_hashtables.h |    2 +-
 net/ipv4/Kconfig              |   14 ++++++++++++++
 2 files changed, 15 insertions(+), 1 deletions(-)

diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index e9c2ed8..7253fce 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -113,7 +113,7 @@ struct inet_listen_hashbucket {
 };
 
 /* This is for listening sockets, thus all sockets which possess wildcards. */
-#define INET_LHTABLE_SIZE	32	/* Yes, really, this is all you need. */
+#define INET_LHTABLE_SIZE	(1U << (CONFIG_INET_LHTABLE_SHIFT))
 
 struct inet_hashinfo {
 	/* This is for sockets with full identity only.  Sockets here will
diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 9e95d7f..a92954e 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -440,6 +440,20 @@ config INET_TCP_DIAG
 	depends on INET_DIAG
 	def_tristate INET_DIAG
 
+config INET_LHTABLE_SHIFT
+	int "Number of TCP port listener table buckets (5 => 32, 8 => 256)"
+	default 5
+	range 0 12
+	help
+	  Select number of buckets in TCP listener hash as a power of 2
+	  32 is probably enough unless you run a lot of different servers
+	  Examples:
+		     4 => 16
+		     5 => 32 (default)
+		     6 => 64
+		     7 => 128
+		     8 => 256
+
 menuconfig TCP_CONG_ADVANCED
 	bool "TCP: advanced congestion control"
 	---help---
-- 
1.7.3.1

