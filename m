From: sjur.brandeland@stericsson.com
Subject: [PATCH net-2.6 4/6] caif: Bugfix - Poll can't return POLLHUP while
 connecting.
Date: Fri, 21 May 2010 14:16:10 +0200
Message-ID: <1274444172-31969-4-git-send-email-sjur.brandeland@stericsson.com>
References: <1274444172-31969-1-git-send-email-sjur.brandeland@stericsson.com>
 <1274444172-31969-2-git-send-email-sjur.brandeland@stericsson.com>
 <1274444172-31969-3-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: 7BIT
Cc: sjurbr@gmail.com, linus.walleij@stericsson.com,
	marcel@holtmann.org,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from thalia-smout.broadpark.no ([80.202.8.21]:44152 "EHLO
	thalia-smout.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753899Ab0EUMQr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 May 2010 08:16:47 -0400
Received: from ignis-smin.broadpark.no ([unknown] [80.202.8.11])
 by thalia-smout.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-12.01 64bit (built Oct 15 2009))
 with ESMTP id <0L2R003TERFAK140@thalia-smout.broadpark.no> for
 netdev@vger.kernel.org; Fri, 21 May 2010 14:16:22 +0200 (CEST)
Received: from localhost.localdomain ([unknown] [84.49.77.207])
 by ignis-smin.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-12.01 64bit (built Oct 15 2009))
 with ESMTP id <0L2R006WURF8S590@ignis-smin.broadpark.no> for
 netdev@vger.kernel.org; Fri, 21 May 2010 14:16:22 +0200 (CEST)
In-reply-to: <1274444172-31969-3-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sjur Braendeland <sjur.brandeland@stericsson.com>

Discovered bug when testing async connect.
While connecting poll should not return POLLHUP,
but POLLOUT when connected. 
Also fixed the sysfs flow-control-counters.

Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>
---
 net/caif/caif_socket.c |   21 ++++++---------------
 1 files changed, 6 insertions(+), 15 deletions(-)

diff --git a/net/caif/caif_socket.c b/net/caif/caif_socket.c
index 77e9956..732897d 100644
--- a/net/caif/caif_socket.c
+++ b/net/caif/caif_socket.c
@@ -138,7 +138,7 @@ void caif_flow_ctrl(struct sock *sk, int mode)
 {
 	struct caifsock *cf_sk;
 	cf_sk = container_of(sk, struct caifsock, sk);
-	if (cf_sk->layer.dn)
+	if (cf_sk->layer.dn && cf_sk->layer.dn->modemcmd)
 		cf_sk->layer.dn->modemcmd(cf_sk->layer.dn, mode);
 }
 
@@ -162,9 +162,8 @@ int caif_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 			atomic_read(&cf_sk->sk.sk_rmem_alloc),
 			sk_rcvbuf_lowwater(cf_sk));
 		set_rx_flow_off(cf_sk);
-		if (cf_sk->layer.dn)
-			cf_sk->layer.dn->modemcmd(cf_sk->layer.dn,
-						CAIF_MODEMCMD_FLOW_OFF_REQ);
+		dbfs_atomic_inc(&cnt.num_rx_flow_off);
+		caif_flow_ctrl(sk, CAIF_MODEMCMD_FLOW_OFF_REQ);
 	}
 
 	err = sk_filter(sk, skb);
@@ -175,9 +174,8 @@ int caif_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 		trace_printk("CAIF: %s():"
 			" sending flow OFF due to rmem_schedule\n",
 			__func__);
-		if (cf_sk->layer.dn)
-			cf_sk->layer.dn->modemcmd(cf_sk->layer.dn,
-						CAIF_MODEMCMD_FLOW_OFF_REQ);
+		dbfs_atomic_inc(&cnt.num_rx_flow_off);
+		caif_flow_ctrl(sk, CAIF_MODEMCMD_FLOW_OFF_REQ);
 	}
 	skb->dev = NULL;
 	skb_set_owner_r(skb, sk);
@@ -285,16 +283,13 @@ static void caif_check_flow_release(struct sock *sk)
 {
 	struct caifsock *cf_sk = container_of(sk, struct caifsock, sk);
 
-	if (cf_sk->layer.dn == NULL || cf_sk->layer.dn->modemcmd == NULL)
-		return;
 	if (rx_flow_is_on(cf_sk))
 		return;
 
 	if (atomic_read(&sk->sk_rmem_alloc) <= sk_rcvbuf_lowwater(cf_sk)) {
 			dbfs_atomic_inc(&cnt.num_rx_flow_on);
 			set_rx_flow_on(cf_sk);
-			cf_sk->layer.dn->modemcmd(cf_sk->layer.dn,
-						CAIF_MODEMCMD_FLOW_ON_REQ);
+			caif_flow_ctrl(sk, CAIF_MODEMCMD_FLOW_ON_REQ);
 	}
 }
 /*
@@ -1018,10 +1013,6 @@ static unsigned int caif_poll(struct file *file,
 		(sk->sk_shutdown & RCV_SHUTDOWN))
 		mask |= POLLIN | POLLRDNORM;
 
-	/* Connection-based need to check for termination and startup */
-	if (sk->sk_state == CAIF_DISCONNECTED)
-		mask |= POLLHUP;
-
 	/*
 	 * we set writable also when the other side has shut down the
 	 * connection. This prevents stuck sockets.
-- 
1.6.3.3

