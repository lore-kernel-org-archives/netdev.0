From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH 08/17] RxRPC: Don't call skb_add_data() if there's no data to copy
Date: Sat, 11 Apr 2015 22:18:19 +0100
Message-ID: <1428787108-13650-8-git-send-email-viro@ZenIV.linux.org.uk>
References: <20150411211742.GJ889@ZenIV.linux.org.uk>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:37872 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932479AbbDKVSa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Apr 2015 17:18:30 -0400
In-Reply-To: <20150411211742.GJ889@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Howells <dhowells@redhat.com>

Don't call skb_add_data() in rxrpc_send_data() if there's no data to copy and
also skip the calculations associated with it in such a case.

Signed-off-by: David Howells <dhowells@redhat.com>
---
 net/rxrpc/ar-output.c | 38 +++++++++++++++++++-------------------
 1 file changed, 19 insertions(+), 19 deletions(-)

diff --git a/net/rxrpc/ar-output.c b/net/rxrpc/ar-output.c
index 833a33b..f48dc1a 100644
--- a/net/rxrpc/ar-output.c
+++ b/net/rxrpc/ar-output.c
@@ -549,8 +549,6 @@ static int rxrpc_send_data(struct kiocb *iocb,
 	if (len > iov_iter_count(&msg->msg_iter))
 		len = iov_iter_count(&msg->msg_iter);
 	do {
-		int copy;
-
 		if (!skb) {
 			size_t size, chunk, max, space;
 
@@ -616,23 +614,25 @@ static int rxrpc_send_data(struct kiocb *iocb,
 		sp = rxrpc_skb(skb);
 
 		/* append next segment of data to the current buffer */
-		copy = skb_tailroom(skb);
-		ASSERTCMP(copy, >, 0);
-		if (copy > len)
-			copy = len;
-		if (copy > sp->remain)
-			copy = sp->remain;
-
-		_debug("add");
-		ret = skb_add_data(skb, &msg->msg_iter, copy);
-		_debug("added");
-		if (ret < 0)
-			goto efault;
-		sp->remain -= copy;
-		skb->mark += copy;
-		copied += copy;
-
-		len -= copy;
+		if (len > 0) {
+			int copy = skb_tailroom(skb);
+			ASSERTCMP(copy, >, 0);
+			if (copy > len)
+				copy = len;
+			if (copy > sp->remain)
+				copy = sp->remain;
+
+			_debug("add");
+			ret = skb_add_data(skb, &msg->msg_iter, copy);
+			_debug("added");
+			if (ret < 0)
+				goto efault;
+			sp->remain -= copy;
+			skb->mark += copy;
+			copied += copy;
+
+			len -= copy;
+		}
 
 		/* check for the far side aborting the call or a network error
 		 * occurring */
-- 
2.1.4
