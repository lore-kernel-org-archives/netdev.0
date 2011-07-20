From: Shirley Ma <mashirle@us.ibm.com>
Subject: [PATCH V2]  vhost: fix check for # of outstanding buffers
Date: Wed, 20 Jul 2011 10:23:12 -0700
Message-ID: <1311182592.8573.45.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jasowang@redhat.com
To: mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:40220 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751437Ab1GTRXS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2011 13:23:18 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p6KH0tuf028455
	for <netdev@vger.kernel.org>; Wed, 20 Jul 2011 13:00:55 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p6KHNFIH094576
	for <netdev@vger.kernel.org>; Wed, 20 Jul 2011 13:23:16 -0400
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p6KHNEIw027071
	for <netdev@vger.kernel.org>; Wed, 20 Jul 2011 11:23:14 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the check for number of outstanding buffers returns incorrect
results due to vq->pend_idx wrap around;

Signed-off-by: Shirley Ma <xma@us.ibm.com>
---

 drivers/vhost/net.c |   12 +++++++++---
 1 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 70ac604..946a71e 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -182,15 +182,21 @@ static void handle_tx(struct vhost_net *net)
 			break;
 		/* Nothing new?  Wait for eventfd to tell us they refilled. */
 		if (head == vq->num) {
+			int num_pends;
+
 			wmem = atomic_read(&sock->sk->sk_wmem_alloc);
 			if (wmem >= sock->sk->sk_sndbuf * 3 / 4) {
 				tx_poll_start(net, sock);
 				set_bit(SOCK_ASYNC_NOSPACE, &sock->flags);
 				break;
 			}
-			/* If more outstanding DMAs, queue the work */
-			if (unlikely(vq->upend_idx - vq->done_idx >
-				     VHOST_MAX_PEND)) {
+			/* If more outstanding DMAs, queue the work
+			 * handle upend_idx wrap around
+			 */
+			num_pends = (vq->upend_idx >= vq->done_idx) ?
+				    (vq->upend_idx - vq->done_idx) :
+				    (vq->upend_idx + UIO_MAXIOV - vq->done_idx);
+			if (unlikely(num_pends > VHOST_MAX_PEND)) {
 				tx_poll_start(net, sock);
 				set_bit(SOCK_ASYNC_NOSPACE, &sock->flags);
 				break;


