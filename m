From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH 3/8] tcp: use limited socket backlog
Date: Wed,  3 Mar 2010 14:35:06 +0800
Message-ID: <1267598111-12503-3-git-send-email-yi.zhu@intel.com>
References: <1267598111-12503-1-git-send-email-yi.zhu@intel.com>
 <1267598111-12503-2-git-send-email-yi.zhu@intel.com>
Cc: Zhu Yi <yi.zhu@intel.com>, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:65441 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754451Ab0CCGde (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Mar 2010 01:33:34 -0500
In-Reply-To: <1267598111-12503-2-git-send-email-yi.zhu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make tcp adapt to the limited socket backlog change.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: "Pekka Savola (ipv6)" <pekkas@netcore.fi>
Cc: Patrick McHardy <kaber@trash.net>
Signed-off-by: Zhu Yi <yi.zhu@intel.com>
---
 net/ipv4/tcp_ipv4.c      |    6 ++++--
 net/ipv4/tcp_minisocks.c |    2 +-
 net/ipv6/tcp_ipv6.c      |    6 ++++--
 3 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index c3588b4..1915f7d 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1682,8 +1682,10 @@ process:
 			if (!tcp_prequeue(sk, skb))
 				ret = tcp_v4_do_rcv(sk, skb);
 		}
-	} else
-		sk_add_backlog(sk, skb);
+	} else if (sk_add_backlog(sk, skb)) {
+		bh_unlock_sock(sk);
+		goto discard_and_relse;
+	}
 	bh_unlock_sock(sk);
 
 	sock_put(sk);
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index f206ee5..4199bc6 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -728,7 +728,7 @@ int tcp_child_process(struct sock *parent, struct sock *child,
 		 * in main socket hash table and lock on listening
 		 * socket does not protect us more.
 		 */
-		sk_add_backlog(child, skb);
+		__sk_add_backlog(child, skb);
 	}
 
 	bh_unlock_sock(child);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 6963a6b..2c378b1 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1740,8 +1740,10 @@ process:
 			if (!tcp_prequeue(sk, skb))
 				ret = tcp_v6_do_rcv(sk, skb);
 		}
-	} else
-		sk_add_backlog(sk, skb);
+	} else if (sk_add_backlog(sk, skb)) {
+		bh_unlock_sock(sk);
+		goto discard_and_relse;
+	}
 	bh_unlock_sock(sk);
 
 	sock_put(sk);
-- 
1.6.3.3

