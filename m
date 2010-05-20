From: sjur.brandeland@stericsson.com
Subject: [PATCH net-next-2.6 7/8] caif: Bugfix - Poll can't return POLLHUP
 while connecting.
Date: Thu, 20 May 2010 09:44:07 +0200
Message-ID: <1274341448-14924-8-git-send-email-sjur.brandeland@stericsson.com>
References: <1274341448-14924-1-git-send-email-sjur.brandeland@stericsson.com>
 <1274341448-14924-2-git-send-email-sjur.brandeland@stericsson.com>
 <1274341448-14924-3-git-send-email-sjur.brandeland@stericsson.com>
 <1274341448-14924-4-git-send-email-sjur.brandeland@stericsson.com>
 <1274341448-14924-5-git-send-email-sjur.brandeland@stericsson.com>
 <1274341448-14924-6-git-send-email-sjur.brandeland@stericsson.com>
 <1274341448-14924-7-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: 7BIT
Cc: marcel@holtmann.org, daniel.martensson@stericsson.com,
	linus.walleji@stericsson.com, sjurbren@gmail.com,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from thalia-smout.broadpark.no ([80.202.8.21]:51603 "EHLO
	thalia-smout.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754234Ab0ETHot (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 May 2010 03:44:49 -0400
Received: from ignis-smin.broadpark.no ([unknown] [80.202.8.11])
 by thalia-smout.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-12.01 64bit (built Oct 15 2009))
 with ESMTP id <0L2P00CEKK656ZD0@thalia-smout.broadpark.no> for
 netdev@vger.kernel.org; Thu, 20 May 2010 09:44:29 +0200 (CEST)
Received: from localhost.localdomain ([unknown] [84.49.77.207])
 by ignis-smin.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-12.01 64bit (built Oct 15 2009))
 with ESMTP id <0L2P008F5K603V20@ignis-smin.broadpark.no> for
 netdev@vger.kernel.org; Thu, 20 May 2010 09:44:29 +0200 (CEST)
In-reply-to: <1274341448-14924-7-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sjur Braendeland <sjur.brandeland@stericsson.com>

While connecting poll should not return POLLHUP,
but POLLOUT when connected.
Also fixed the sysfs for flow control that was not counting correctly.

Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>
---
 net/caif/caif_socket.c |   22 ++++++----------------
 1 files changed, 6 insertions(+), 16 deletions(-)

diff --git a/net/caif/caif_socket.c b/net/caif/caif_socket.c
index 2c2f7d7..4bf2ed6 100644
--- a/net/caif/caif_socket.c
+++ b/net/caif/caif_socket.c
@@ -139,7 +139,7 @@ void caif_flow_ctrl(struct sock *sk, int mode)
 {
 	struct caifsock *cf_sk;
 	cf_sk = container_of(sk, struct caifsock, sk);
-	if (cf_sk->layer.dn)
+	if (cf_sk->layer.dn && cf_sk->layer.dn->modemcmd)
 		cf_sk->layer.dn->modemcmd(cf_sk->layer.dn, mode);
 }
 
@@ -163,9 +163,8 @@ int caif_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
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
@@ -176,9 +175,8 @@ int caif_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
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
@@ -286,17 +284,13 @@ static void caif_check_flow_release(struct sock *sk)
 {
 	struct caifsock *cf_sk = container_of(sk, struct caifsock, sk);
 
-	if (cf_sk->layer.dn == NULL || cf_sk->layer.dn->modemcmd == NULL)
-		return;
-
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
 
@@ -1019,10 +1013,6 @@ static unsigned int caif_poll(struct file *file,
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

