From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 19/21] tipc: Enhance sending of discovery object link request messages
Date: Tue, 10 May 2011 16:44:35 -0400
Message-ID: <1305060277-15600-20-git-send-email-paul.gortmaker@windriver.com>
References: <1305060277-15600-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Allan.Stephens@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:52461 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752716Ab1EJUpL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 16:45:11 -0400
In-Reply-To: <1305060277-15600-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

Augments TIPC's discovery object to send its initial neighbor discovery
request message as soon as the associated bearer is created, rather than
waiting for its first periodic timeout to occur, thereby speeding up the
discovery process. Also adds a check to suppress the initial request or
subsequent requests if the bearer is blocked at the time the request is
scheduled for transmission.

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/discover.c |   14 +++++++++++++-
 1 files changed, 13 insertions(+), 1 deletions(-)

diff --git a/net/tipc/discover.c b/net/tipc/discover.c
index 6acf32a..dba4767 100644
--- a/net/tipc/discover.c
+++ b/net/tipc/discover.c
@@ -241,6 +241,17 @@ void tipc_disc_update_link_req(struct link_req *req)
 }
 
 /**
+ * disc_send_msg - send link setup request message
+ * @req: ptr to link request structure
+ */
+
+static void disc_send_msg(struct link_req *req)
+{
+	if (!req->bearer->blocked)
+		tipc_bearer_send(req->bearer, req->buf, &req->dest);
+}
+
+/**
  * disc_timeout - send a periodic link setup request
  * @req: ptr to link request structure
  *
@@ -251,7 +262,7 @@ static void disc_timeout(struct link_req *req)
 {
 	spin_lock_bh(&req->bearer->lock);
 
-	req->bearer->media->send_msg(req->buf, req->bearer, &req->dest);
+	disc_send_msg(req);
 
 	if ((req->timer_intv == TIPC_LINK_REQ_SLOW) ||
 	    (req->timer_intv == TIPC_LINK_REQ_FAST)) {
@@ -300,6 +311,7 @@ int tipc_disc_create(struct tipc_bearer *b_ptr,
 	k_init_timer(&req->timer, (Handler)disc_timeout, (unsigned long)req);
 	k_start_timer(&req->timer, req->timer_intv);
 	b_ptr->link_req = req;
+	disc_send_msg(req);
 	return 0;
 }
 
-- 
1.7.4.4

