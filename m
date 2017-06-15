From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] sctp: return next obj by passing pos + 1 into sctp_transport_get_idx
Date: Thu, 15 Jun 2017 17:49:08 +0800
Message-ID: <a129be6693b882bac11ace44d659ceb1c1cc4f79.1497520148.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33995 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750802AbdFOJtR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 05:49:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In sctp_for_each_transport, pos is used to save how many objs it has
dumped. Now it gets the last obj by sctp_transport_get_idx, then gets
the next obj by sctp_transport_get_next.

The issue is that in the meanwhile if some objs in transport hashtable
are removed and the objs nums are less than pos, sctp_transport_get_idx
would return NULL and hti.walker.tbl is NULL as well. At this moment
it should stop hti, instead of continue getting the next obj. Or it
would cause a NULL pointer dereference in sctp_transport_get_next.

This patch is to pass pos + 1 into sctp_transport_get_idx to get the
next obj directly, even if pos > objs nums, it would return NULL and
stop hti.

Fixes: 626d16f50f39 ("sctp: export some apis or variables for sctp_diag and reuse some for proc")
Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/sctp/socket.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 30aa0a5..3a8318e 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -4666,9 +4666,8 @@ int sctp_for_each_transport(int (*cb)(struct sctp_transport *, void *),
 	if (err)
 		return err;
 
-	sctp_transport_get_idx(net, &hti, pos);
-	obj = sctp_transport_get_next(net, &hti);
-	for (; obj && !IS_ERR(obj); obj = sctp_transport_get_next(net, &hti)) {
+	obj = sctp_transport_get_idx(net, &hti, pos + 1);
+	for (; !IS_ERR_OR_NULL(obj); obj = sctp_transport_get_next(net, &hti)) {
 		struct sctp_transport *transport = obj;
 
 		if (!sctp_transport_hold(transport))
-- 
2.1.0
