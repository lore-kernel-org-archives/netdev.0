From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] sctp: only drop the reference on the datamsg after sending a msg
Date: Sat,  5 Dec 2015 15:19:27 +0800
Message-ID: <b2b92ed429c3f617f5a22df8b232cf58ab7a0fb5.1449299967.git.lucien.xin@gmail.com>
Cc: marcelo.leitner@gmail.com, vyasevic@redhat.com, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:34090 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751902AbbLEHTb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Dec 2015 02:19:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the chunks are enqueued successfully but sctp_cmd_interpreter()
return err to sctp_sendmsg() (mainly because of no mem), the chunks will
get re-queued, but we are dropping the reference and freeing them.

The fix is to just drop the reference on the datamsg just as it had
succeeded, as:
 - if the chunks weren't queued, this is enough to get them freed.
 - if they were queued, they will get freed when they finally get out or
 discarded.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 net/sctp/socket.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 03c8256..d8460be 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -1966,15 +1966,13 @@ static int sctp_sendmsg(struct sock *sk, struct msghdr *msg, size_t msg_len)
 	 * breaks.
 	 */
 	err = sctp_primitive_SEND(net, asoc, datamsg);
+	sctp_datamsg_put(datamsg);
 	/* Did the lower layer accept the chunk? */
-	if (err) {
-		sctp_datamsg_free(datamsg);
+	if (err)
 		goto out_free;
-	}
 
 	pr_debug("%s: we sent primitively\n", __func__);
 
-	sctp_datamsg_put(datamsg);
 	err = msg_len;
 
 	if (unlikely(wait_connect)) {
-- 
2.1.0
