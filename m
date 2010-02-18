From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH net-next-2.6] vhost: Restart tx poll when socket send queue
 is full
Date: Thu, 18 Feb 2010 12:59:11 -0800
Message-ID: <1266526751.15681.71.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: "Michael S. Tsirkin" <mst@redhat.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:42133 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750999Ab0BRU7X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Feb 2010 15:59:23 -0500
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e8.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o1IKq0tL008295
	for <netdev@vger.kernel.org>; Thu, 18 Feb 2010 15:52:00 -0500
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o1IKxMUT107724
	for <netdev@vger.kernel.org>; Thu, 18 Feb 2010 15:59:22 -0500
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o1IKxCcd026964
	for <netdev@vger.kernel.org>; Thu, 18 Feb 2010 13:59:13 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When running guest to remote host TCP stream test using vhost-net
via tap/macvtap, i am seeing network transmit hangs. This happens
when handle_tx() returns because of the socket send queue full 
condition.
This patch fixes this by restarting tx poll when hitting this
condition.

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 91a324c..82d4bbe 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -113,12 +113,16 @@ static void handle_tx(struct vhost_net *net)
 	if (!sock)
 		return;
 
-	wmem = atomic_read(&sock->sk->sk_wmem_alloc);
-	if (wmem >= sock->sk->sk_sndbuf)
-		return;
-
 	use_mm(net->dev.mm);
 	mutex_lock(&vq->mutex);
+
+	wmem = atomic_read(&sock->sk->sk_wmem_alloc);
+	if (wmem >= sock->sk->sk_sndbuf) {
+		tx_poll_start(net, sock);
+		set_bit(SOCK_ASYNC_NOSPACE, &sock->flags);
+		goto unlock;
+	}
+
 	vhost_disable_notify(vq);
 
 	if (wmem < sock->sk->sk_sndbuf * 2)
@@ -178,6 +182,7 @@ static void handle_tx(struct vhost_net *net)
 		}
 	}
 
+unlock:
 	mutex_unlock(&vq->mutex);
 	unuse_mm(net->dev.mm);
 }


