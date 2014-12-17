From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH net 2/2] geneve: Fix races between socket add and release.
Date: Tue, 16 Dec 2014 18:25:32 -0800
Message-ID: <1418783132-99230-2-git-send-email-jesse@nicira.com>
References: <1418783132-99230-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog131.obsmtp.com ([74.125.149.247]:50983 "HELO
	na3sys009aog131.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751066AbaLQCcD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2014 21:32:03 -0500
Received: by mail-pa0-f54.google.com with SMTP id fb1so15426820pad.27
        for <netdev@vger.kernel.org>; Tue, 16 Dec 2014 18:32:02 -0800 (PST)
In-Reply-To: <1418783132-99230-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, searching for a socket to add a reference to is not
synchronized with deletion of sockets. This can result in use
after free if there is another operation that is removing a
socket at the same time. Solving this requires both holding the
appropriate lock and checking the refcount to ensure that it
has not already hit zero.

Inspired by a related (but not exactly the same) issue in the
VXLAN driver.

Fixes: 0b5e8b8e ("net: Add Geneve tunneling protocol driver")
CC: Andy Zhou <azhou@nicira.com>
Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 net/ipv4/geneve.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/geneve.c b/net/ipv4/geneve.c
index 5a47188..95e47c9 100644
--- a/net/ipv4/geneve.c
+++ b/net/ipv4/geneve.c
@@ -296,6 +296,7 @@ struct geneve_sock *geneve_sock_add(struct net *net, __be16 port,
 				    geneve_rcv_t *rcv, void *data,
 				    bool no_share, bool ipv6)
 {
+	struct geneve_net *gn = net_generic(net, geneve_net_id);
 	struct geneve_sock *gs;
 
 	gs = geneve_socket_create(net, port, rcv, data, ipv6);
@@ -305,15 +306,15 @@ struct geneve_sock *geneve_sock_add(struct net *net, __be16 port,
 	if (no_share)	/* Return error if sharing is not allowed. */
 		return ERR_PTR(-EINVAL);
 
+	spin_lock(&gn->sock_lock);
 	gs = geneve_find_sock(net, port);
-	if (gs) {
-		if (gs->rcv == rcv)
-			atomic_inc(&gs->refcnt);
-		else
+	if (gs && ((gs->rcv != rcv) ||
+		   !atomic_add_unless(&gs->refcnt, 1, 0)))
 			gs = ERR_PTR(-EBUSY);
-	} else {
+	spin_unlock(&gn->sock_lock);
+
+	if (!gs)
 		gs = ERR_PTR(-EINVAL);
-	}
 
 	return gs;
 }
-- 
1.9.1
