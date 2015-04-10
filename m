From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH] RxRPC: Fix the conversion to iov_iter
Date: Fri, 10 Apr 2015 03:38:21 +0100
Message-ID: <20150410023821.GA889@ZenIV.linux.org.uk>
References: <20150410023652.GZ889@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:50871 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753043AbbDJCiW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 22:38:22 -0400
Content-Disposition: inline
In-Reply-To: <20150410023652.GZ889@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit:

    commit af2b040e470b470bfc881981db3c796072853eae
    Author: Al Viro <viro@zeniv.linux.org.uk>
    Date:   Thu Nov 27 21:44:24 2014 -0500
    Subject: rxrpc: switch rxrpc_send_data() to iov_iter primitives

incorrectly changes a do-while loop into a while loop in rxrpc_send_data().

Unfortunately, at least one pass through the loop is required - even if
there is no data - so that the packet the closes the send phase can be
sent if MSG_MORE is not set.

Author: David Howells <dhowells@redhat.com>
Signed-off-by: David Howells <dhowells@redhat.com>
---

diff --git a/net/rxrpc/ar-output.c b/net/rxrpc/ar-output.c
index 8331c95..833a33b 100644
--- a/net/rxrpc/ar-output.c
+++ b/net/rxrpc/ar-output.c
@@ -548,7 +548,7 @@ static int rxrpc_send_data(struct kiocb *iocb,
 	copied = 0;
 	if (len > iov_iter_count(&msg->msg_iter))
 		len = iov_iter_count(&msg->msg_iter);
-	while (len) {
+	do {
 		int copy;
 
 		if (!skb) {
@@ -689,7 +689,7 @@ static int rxrpc_send_data(struct kiocb *iocb,
 			rxrpc_queue_packet(call, skb, !iov_iter_count(&msg->msg_iter) && !more);
 			skb = NULL;
 		}
-	}
+	} while (len > 0);
 
 success:
 	ret = copied;
