From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net 1/3] sctp: hold transport instead of assoc in sctp_diag
Date: Fri, 28 Oct 2016 18:10:52 +0800
Message-ID: <a58ed3a60643e38876a12ed9193e60f7b38cba4d.1477649076.git.lucien.xin@gmail.com>
References: <cover.1477649076.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:32958 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758738AbcJ1KLH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2016 06:11:07 -0400
In-Reply-To: <cover.1477649076.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1477649076.git.lucien.xin@gmail.com>
References: <cover.1477649076.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In sctp_transport_lookup_process(), Commit 1cceda784980 ("sctp: fix
the issue sctp_diag uses lock_sock in rcu_read_lock") moved cb() out
of rcu lock, but it put transport and hold assoc instead, and ignore
that cb() still uses transport. It may cause a use-after-free issue.

This patch is to hold transport instead of assoc there.

Fixes: 1cceda784980 ("sctp: fix the issue sctp_diag uses lock_sock in rcu_read_lock")
Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/sctp/socket.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 9fbb6fe..71b75f9 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -4480,12 +4480,9 @@ int sctp_transport_lookup_process(int (*cb)(struct sctp_transport *, void *),
 	if (!transport || !sctp_transport_hold(transport))
 		goto out;
 
-	sctp_association_hold(transport->asoc);
-	sctp_transport_put(transport);
-
 	rcu_read_unlock();
 	err = cb(transport, p);
-	sctp_association_put(transport->asoc);
+	sctp_transport_put(transport);
 
 out:
 	return err;
-- 
2.1.0
