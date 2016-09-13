From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 05/10] rxrpc: Add missing unlock in
 rxrpc_call_accept()
Date: Tue, 13 Sep 2016 23:21:30 +0100
Message-ID: <147380529065.23135.14835990321667645327.stgit@warthog.procyon.org.uk>
References: <147380525614.23135.7539695651371953351.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34282 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932669AbcIMWVc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 13 Sep 2016 18:21:32 -0400
In-Reply-To: <147380525614.23135.7539695651371953351.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a missing unlock in rxrpc_call_accept() in the path taken if there's no
call to wake up.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/call_accept.c |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/rxrpc/call_accept.c b/net/rxrpc/call_accept.c
index b8acec0d596e..06e328f6b0f0 100644
--- a/net/rxrpc/call_accept.c
+++ b/net/rxrpc/call_accept.c
@@ -425,9 +425,11 @@ struct rxrpc_call *rxrpc_accept_call(struct rxrpc_sock *rx,
 
 	write_lock(&rx->call_lock);
 
-	ret = -ENODATA;
-	if (list_empty(&rx->to_be_accepted))
-		goto out;
+	if (list_empty(&rx->to_be_accepted)) {
+		write_unlock(&rx->call_lock);
+		kleave(" = -ENODATA [empty]");
+		return ERR_PTR(-ENODATA);
+	}
 
 	/* check the user ID isn't already in use */
 	pp = &rx->calls.rb_node;
