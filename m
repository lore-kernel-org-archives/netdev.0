From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH V3 2/8] tcp: use limited socket backlog
Date: Fri,  5 Mar 2010 12:01:41 +0800
Message-ID: <1267761707-15605-2-git-send-email-yi.zhu@intel.com>
References: <1267761707-15605-1-git-send-email-yi.zhu@intel.com>
Cc: netdev@vger.kernel.org, Zhu Yi <yi.zhu@intel.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:27263 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752248Ab0CEEA2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Mar 2010 23:00:28 -0500
In-Reply-To: <1267761707-15605-1-git-send-email-yi.zhu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make tcp adapt to the limited socket backlog change.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: "Pekka Savola (ipv6)" <pekkas@netcore.fi>
Cc: Patrick McHardy <kaber@trash.net>
Signed-off-by: Zhu Yi <yi.zhu@intel.com>
---
 net/ipv4/tcp_ipv4.c |    6 ++++--
 net/ipv6/tcp_ipv6.c |    6 ++++--
 2 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index c3588b4..4baf194 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1682,8 +1682,10 @@ process:
 			if (!tcp_prequeue(sk, skb))
 				ret = tcp_v4_do_rcv(sk, skb);
 		}
-	} else
-		sk_add_backlog(sk, skb);
+	} else if (sk_add_backlog_limited(sk, skb)) {
+		bh_unlock_sock(sk);
+		goto discard_and_relse;
+	}
 	bh_unlock_sock(sk);
 
 	sock_put(sk);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 6963a6b..c4ea9d5 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1740,8 +1740,10 @@ process:
 			if (!tcp_prequeue(sk, skb))
 				ret = tcp_v6_do_rcv(sk, skb);
 		}
-	} else
-		sk_add_backlog(sk, skb);
+	} else if (sk_add_backlog_limited(sk, skb)) {
+		bh_unlock_sock(sk);
+		goto discard_and_relse;
+	}
 	bh_unlock_sock(sk);
 
 	sock_put(sk);
-- 
1.6.3.3

