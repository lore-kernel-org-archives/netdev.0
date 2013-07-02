From: Simon Derr <simon.derr@bull.net>
Subject: [PATCH 05/10] 9P/RDMA: Protect against duplicate replies
Date: Tue,  2 Jul 2013 15:11:19 +0200
Message-ID: <1372770684-25573-6-git-send-email-simon.derr@bull.net>
References: <1372770684-25573-1-git-send-email-simon.derr@bull.net>
Cc: simon.derr@bull.net, ericvh@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:40943 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751708Ab3GBNlp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 09:41:45 -0400
In-Reply-To: <1372770684-25573-1-git-send-email-simon.derr@bull.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A well-behaved server would not send twice the reply to a request.
But if it ever happens...
This additional check prevents the kernel from leaking memory
and possibly more nasty consequences in that unlikely event.

Signed-off-by: Simon Derr <simon.derr@bull.net>
---
 net/9p/trans_rdma.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/net/9p/trans_rdma.c b/net/9p/trans_rdma.c
index b8b66d3..274a9c1 100644
--- a/net/9p/trans_rdma.c
+++ b/net/9p/trans_rdma.c
@@ -294,6 +294,13 @@ handle_recv(struct p9_client *client, struct p9_trans_rdma *rdma,
 	if (!req)
 		goto err_out;
 
+	/* Check that we have not yet received a reply for this request.
+	 */
+	if (unlikely(req->rc)) {
+		pr_err("Duplicate reply for request %d", tag);
+		goto err_out;
+	}
+
 	req->rc = c->rc;
 	req->status = REQ_STATUS_RCVD;
 	p9_client_cb(client, req);
-- 
1.7.2.2
