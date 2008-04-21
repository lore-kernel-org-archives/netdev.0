From: Jason Uhlenkott <juhlenko@akamai.com>
Subject: [RFC 2/4] net core: let protocols implement SOCK_TIMESTAMP efficiently
Date: Sun, 20 Apr 2008 22:35:21 -0700
Message-ID: <20080421053521.GB31778@48M1231.sanmateo.corp.akamai.com>
References: <20080421053402.GB23476@48M1231.sanmateo.corp.akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay4.akamai.com ([72.246.198.135]:44132 "EHLO
	prod-mail-xrelay04.akamai.com" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751672AbYDUFpB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2008 01:45:01 -0400
Content-Disposition: inline
In-Reply-To: <20080421053402.GB23476@48M1231.sanmateo.corp.akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Classically, if anyone enabled the SOCK_TIMESTAMP flag on any socket
(via the SO_TIMESTAMP socket option or the SIOCGSTAMP ioctl), we'd
start recording timestamps for *every* packet coming into the system.
We did this because timestamps were recorded very early by the net
core, before the upper protocol layers had a chance to look up the
socket(s) associated with each incoming packet.

This gives protocols a way to announce (via a new flag,
PROTO_HAS_SOCK_TIMESTAMP) that they'll record packet timestamps
themselves, *after* the socket lookup has happened, so timestamps on
supported socket types can be enabled on a per-socket basis, instead
of globally in the net core.

For most protocols, supporting this is trivial:  it just requires a
call to sock_timestamp(sk, skb) somewhere in the rcv path, typically
immediately after the socket lookup.

Signed-off-by: Jason Uhlenkott <juhlenko@akamai.com>


---
 include/net/sock.h |   13 +++++++++++++
 net/core/sock.c    |   21 +++++++++++++++++++--
 2 files changed, 32 insertions(+), 2 deletions(-)

Index: linux/include/net/sock.h
===================================================================
--- linux.orig/include/net/sock.h	2008-04-20 21:03:54.000000000 -0700
+++ linux/include/net/sock.h	2008-04-20 21:04:03.000000000 -0700
@@ -475,6 +475,12 @@
 	skb->next = NULL;
 }
 
+static inline void sock_timestamp(struct sock *sk, struct sk_buff *skb)
+{
+	if (sock_flag(sk, SOCK_TIMESTAMP) && !skb->tstamp.tv64)
+		__net_timestamp(skb);
+}
+
 #define sk_wait_event(__sk, __timeo, __condition)			\
 	({	int __rc;						\
 		release_sock(__sk);					\
@@ -587,6 +593,8 @@
 	char			name[32];
 
 	struct list_head	node;
+
+	unsigned long		flags;
 #ifdef SOCK_REFCNT_DEBUG
 	atomic_t		socks;
 #endif
@@ -595,6 +603,11 @@
 extern int proto_register(struct proto *prot, int alloc_slab);
 extern void proto_unregister(struct proto *prot);
 
+enum proto_flags {
+	/* proto handles per-socket timestamp flag efficiently */
+	PROTO_HAS_SOCK_TIMESTAMP = 0,
+};
+
 #ifdef SOCK_REFCNT_DEBUG
 static inline void sk_refcnt_debug_inc(struct sock *sk)
 {
Index: linux/net/core/sock.c
===================================================================
--- linux.orig/net/core/sock.c	2008-04-20 21:03:54.000000000 -0700
+++ linux/net/core/sock.c	2008-04-20 21:04:03.000000000 -0700
@@ -287,11 +287,27 @@
 }
 EXPORT_SYMBOL(sock_get_timestampns);
 
+/*
+ * Does this type of socket implement SOCK_TIMESTAMP efficiently (by
+ * calling sock_timestamp() in the upper protocol layers, after we've
+ * looked up the skb's socket)?
+ */
+static inline int sock_supports_timestamps(struct sock *sk)
+{
+	return sk->sk_prot->flags & (1 << PROTO_HAS_SOCK_TIMESTAMP);
+}
+
 void sock_enable_timestamp(struct sock *sk)
 {
 	if (!sock_flag(sk, SOCK_TIMESTAMP)) {
 		sock_set_flag(sk, SOCK_TIMESTAMP);
-		net_enable_timestamp();
+		if (!sock_supports_timestamps(sk)) {
+			/*
+			 * Ugh, we can't enable timestamps for just
+			 * this socket.  We'll have to do it globally.
+			 */
+			net_enable_timestamp();
+		}
 	}
 }
 
@@ -299,7 +315,8 @@
 {
 	if (sock_flag(sk, SOCK_TIMESTAMP)) {
 		sock_reset_flag(sk, SOCK_TIMESTAMP);
-		net_disable_timestamp();
+		if (!sock_supports_timestamps(sk))
+			net_disable_timestamp();
 	}
 }
 
