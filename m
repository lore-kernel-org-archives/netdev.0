From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next] sock: don't enable netstamp for af_unix sockets
Date: Mon, 26 Oct 2015 13:51:37 +0100
Message-ID: <1445863897-22646-1-git-send-email-hannes@stressinduktion.org>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:49770 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753935AbbJZMvq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2015 08:51:46 -0400
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 76A1120383
	for <netdev@vger.kernel.org>; Mon, 26 Oct 2015 08:51:45 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netstamp_needed is toggled for all socket families if they request
timestamping. But some protocols don't need the lower-layer timestamping
code at all. This patch starts disabling it for af-unix.

E.g. systemd enables timestamping during boot-up on the journald af-unix
sockets, thus causing the system to globally enable timestamping in the
lower networking stack. Still, it is very probable that timestamping
gets activated, by e.g. dhclient or various NTP implementations.

Reported-by: Jesper Dangaard Brouer <brouer@redhat.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/core/sock.c | 20 +++++++++++++++++---
 1 file changed, 17 insertions(+), 3 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index dcc7d62..0ef30aa 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -422,13 +422,25 @@ static void sock_warn_obsolete_bsdism(const char *name)
 	}
 }
 
+static bool sock_needs_netstamp(const struct sock *sk)
+{
+	switch (sk->sk_family) {
+	case AF_UNSPEC:
+	case AF_UNIX:
+		return false;
+	default:
+		return true;
+	}
+}
+
 #define SK_FLAGS_TIMESTAMP ((1UL << SOCK_TIMESTAMP) | (1UL << SOCK_TIMESTAMPING_RX_SOFTWARE))
 
 static void sock_disable_timestamp(struct sock *sk, unsigned long flags)
 {
 	if (sk->sk_flags & flags) {
 		sk->sk_flags &= ~flags;
-		if (!(sk->sk_flags & SK_FLAGS_TIMESTAMP))
+		if (sock_needs_netstamp(sk) &&
+		    !(sk->sk_flags & SK_FLAGS_TIMESTAMP))
 			net_disable_timestamp();
 	}
 }
@@ -1582,7 +1594,8 @@ struct sock *sk_clone_lock(const struct sock *sk, const gfp_t priority)
 		if (newsk->sk_prot->sockets_allocated)
 			sk_sockets_allocated_inc(newsk);
 
-		if (newsk->sk_flags & SK_FLAGS_TIMESTAMP)
+		if (sock_needs_netstamp(sk) &&
+		    newsk->sk_flags & SK_FLAGS_TIMESTAMP)
 			net_enable_timestamp();
 	}
 out:
@@ -2510,7 +2523,8 @@ void sock_enable_timestamp(struct sock *sk, int flag)
 		 * time stamping, but time stamping might have been on
 		 * already because of the other one
 		 */
-		if (!(previous_flags & SK_FLAGS_TIMESTAMP))
+		if (sock_needs_netstamp(sk) &&
+		    !(previous_flags & SK_FLAGS_TIMESTAMP))
 			net_enable_timestamp();
 	}
 }
-- 
2.5.0
