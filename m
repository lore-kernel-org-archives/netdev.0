From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] sctp: sctp_epaddr_lookup_transport should be protected by rcu_read_lock
Date: Thu, 15 Dec 2016 23:00:55 +0800
Message-ID: <eb70a1f54c102c728a5572f1aa2842940fc3f5a5.1481814055.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Dmitry Vyukov <dvyukov@google.com>
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35794 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936494AbcLOPBE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Dec 2016 10:01:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit 7fda702f9315 ("sctp: use new rhlist interface on sctp transport
rhashtable"), sctp has changed to use rhlist_lookup to look up transport, but
rhlist_lookup doesn't call rcu_read_lock inside, unlike rhashtable_lookup_fast.

It is called in sctp_epaddr_lookup_transport and sctp_addrs_lookup_transport.
sctp_addrs_lookup_transport is always in the protection of rcu_read_lock(),
as __sctp_lookup_association is called in rx path or sctp_lookup_association
which are in the protection of rcu_read_lock() already.

But sctp_epaddr_lookup_transport is called by sctp_endpoint_lookup_assoc, it
doesn't call rcu_read_lock, which may cause "suspicious rcu_dereference_check
usage' in __rhashtable_lookup.

This patch is to fix it by adding rcu_read_lock in sctp_endpoint_lookup_assoc
before calling sctp_epaddr_lookup_transport.

Fixes: 7fda702f9315 ("sctp: use new rhlist interface on sctp transport rhashtable")
Reported-by: Dmitry Vyukov <dvyukov@google.com>
Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/sctp/endpointola.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/sctp/endpointola.c b/net/sctp/endpointola.c
index 1f03065..410ddc1 100644
--- a/net/sctp/endpointola.c
+++ b/net/sctp/endpointola.c
@@ -331,7 +331,9 @@ struct sctp_association *sctp_endpoint_lookup_assoc(
 	 * on this endpoint.
 	 */
 	if (!ep->base.bind_addr.port)
-		goto out;
+		return NULL;
+
+	rcu_read_lock();
 	t = sctp_epaddr_lookup_transport(ep, paddr);
 	if (!t)
 		goto out;
@@ -339,6 +341,7 @@ struct sctp_association *sctp_endpoint_lookup_assoc(
 	*transport = t;
 	asoc = t->asoc;
 out:
+	rcu_read_unlock();
 	return asoc;
 }
 
-- 
2.1.0
