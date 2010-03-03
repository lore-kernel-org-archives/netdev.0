From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH V2 2/7] tcp: use limited socket backlog
Date: Wed,  3 Mar 2010 16:36:24 +0800
Message-ID: <1267605389-7369-2-git-send-email-yi.zhu@intel.com>
References: <1267605389-7369-1-git-send-email-yi.zhu@intel.com>
Cc: Zhu Yi <yi.zhu@intel.com>, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:60230 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751777Ab0CCIeq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Mar 2010 03:34:46 -0500
In-Reply-To: <1267605389-7369-1-git-send-email-yi.zhu@intel.com>
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

