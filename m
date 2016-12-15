From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] sctp: sctp_transport_lookup_process should rcu_read_unlock when transport is null
Date: Thu, 15 Dec 2016 23:05:52 +0800
Message-ID: <3d4f0205d5b5c64d372dffb37602f48e4a173612.1481814352.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35955 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932518AbcLOPGB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Dec 2016 10:06:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prior to this patch, sctp_transport_lookup_process didn't rcu_read_unlock
when it failed to find a transport by sctp_addrs_lookup_transport.

This patch is to fix it by moving up rcu_read_unlock right before checking
transport and also to remove the out path.

Fixes: 1cceda784980 ("sctp: fix the issue sctp_diag uses lock_sock in rcu_read_lock")
Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/sctp/socket.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index d5f4b4a..318c678 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -4472,18 +4472,17 @@ int sctp_transport_lookup_process(int (*cb)(struct sctp_transport *, void *),
 				  const union sctp_addr *paddr, void *p)
 {
 	struct sctp_transport *transport;
-	int err = -ENOENT;
+	int err;
 
 	rcu_read_lock();
 	transport = sctp_addrs_lookup_transport(net, laddr, paddr);
+	rcu_read_unlock();
 	if (!transport)
-		goto out;
+		return -ENOENT;
 
-	rcu_read_unlock();
 	err = cb(transport, p);
 	sctp_transport_put(transport);
 
-out:
 	return err;
 }
 EXPORT_SYMBOL_GPL(sctp_transport_lookup_process);
-- 
2.1.0
