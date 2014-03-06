From: <erik.hugne@ericsson.com>
Subject: [PATCH net-next v3 3/6] tipc: avoid to unnecessary process switch under non-block mode
Date: Thu, 6 Mar 2014 14:40:18 +0100
Message-ID: <1394113221-30100-4-git-send-email-erik.hugne@ericsson.com>
References: <1394113221-30100-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ying.xue@windriver.com>, <paul.gortmaker@windriver.com>,
	<richard.alpe@ericsson.com>
To: <netdev@vger.kernel.org>, <tipc-discussion@lists.sourceforge.net>,
	<jon.maloy@ericsson.com>, <maloy@donjonn.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw2.ericsson.se ([193.180.251.37]:64011 "EHLO
	mailgw2.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751531AbaCFNju (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 08:39:50 -0500
In-Reply-To: <1394113221-30100-1-git-send-email-erik.hugne@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>

When messages are received via tipc socket under non-block mode,
schedule_timeout() is called in tipc_wait_for_rcvmsg(), that is,
the process of receiving messages will be scheduled once although
timeout value passed to schedule_timeout() is 0. The same issue
exists in accept()/wait_for_accept(). To avoid this unnecessary
process switch, we only call schedule_timeout() if the timeout
value is non-zero.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/socket.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 336e18d..4428292 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -999,7 +999,7 @@ static int tipc_wait_for_rcvmsg(struct socket *sock, long timeo)
 
 	for (;;) {
 		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
-		if (skb_queue_empty(&sk->sk_receive_queue)) {
+		if (timeo && skb_queue_empty(&sk->sk_receive_queue)) {
 			if (sock->state == SS_DISCONNECTING) {
 				err = -ENOTCONN;
 				break;
@@ -1625,7 +1625,7 @@ static int tipc_wait_for_accept(struct socket *sock, long timeo)
 	for (;;) {
 		prepare_to_wait_exclusive(sk_sleep(sk), &wait,
 					  TASK_INTERRUPTIBLE);
-		if (skb_queue_empty(&sk->sk_receive_queue)) {
+		if (timeo && skb_queue_empty(&sk->sk_receive_queue)) {
 			release_sock(sk);
 			timeo = schedule_timeout(timeo);
 			lock_sock(sk);
-- 
1.8.3.2
