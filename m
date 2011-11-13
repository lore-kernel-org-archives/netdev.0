From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch 6/8 2.6.32] tcp: use limited socket backlog
Date: Sun, 13 Nov 2011 23:19:11 +0300
Message-ID: <20111113201911.GG1362@elgon.mountain>
References: <20111113201336.GA1362@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Kroah-Hartman <greg@kroah.com>, Zhu Yi <yi.zhu@intel.com>,
	netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: stable@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:39570 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752764Ab1KMUTb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Nov 2011 15:19:31 -0500
Content-Disposition: inline
In-Reply-To: <20111113201336.GA1362@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This applied without changes to the original patch.

>From 6b03a53a5ab7ccf2d5d69f96cf1c739c4d2a8fb9 Mon Sep 17 00:00:00 2001
From: Zhu Yi <yi.zhu@intel.com>
Date: Thu, 4 Mar 2010 18:01:41 +0000
Subject: [PATCH] tcp: use limited socket backlog

Make tcp adapt to the limited socket backlog change.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: "Pekka Savola (ipv6)" <pekkas@netcore.fi>
Cc: Patrick McHardy <kaber@trash.net>
Signed-off-by: Zhu Yi <yi.zhu@intel.com>
Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
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
1.7.8.rc0.dirty
