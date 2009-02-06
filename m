From: David Howells <dhowells@redhat.com>
Subject: [PATCH] RxRPC: Fix a potential NULL dereference
Date: Fri, 06 Feb 2009 11:59:43 +0000
Message-ID: <20090206115943.6126.95330.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org
To: netdev@vger.kernel.org, error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:52424 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752553AbZBFMAw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Feb 2009 07:00:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix a potential NULL dereference bug during error handling in
rxrpc_kernel_begin_call(), whereby rxrpc_put_transport() may be handed a NULL
pointer.

This was found with a code checker (http://repo.or.cz/w/smatch.git/).

Reported-by: Dan Carpenter <error27@gmail.com>
Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/af_rxrpc.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)


diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index d7d2bed..eac5e7b 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -284,13 +284,13 @@ struct rxrpc_call *rxrpc_kernel_begin_call(struct socket *sock,
 		if (IS_ERR(trans)) {
 			call = ERR_CAST(trans);
 			trans = NULL;
-			goto out;
+			goto out_notrans;
 		}
 	} else {
 		trans = rx->trans;
 		if (!trans) {
 			call = ERR_PTR(-ENOTCONN);
-			goto out;
+			goto out_notrans;
 		}
 		atomic_inc(&trans->usage);
 	}
@@ -315,6 +315,7 @@ struct rxrpc_call *rxrpc_kernel_begin_call(struct socket *sock,
 	rxrpc_put_bundle(trans, bundle);
 out:
 	rxrpc_put_transport(trans);
+out_notrans:
 	release_sock(&rx->sk);
 	_leave(" = %p", call);
 	return call;

