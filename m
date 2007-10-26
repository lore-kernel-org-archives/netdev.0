From: Roel Kluin <12o3l@tiscali.nl>
Subject: [PATCH 4] Unlock before BUG, but preserve normal operation
Date: Fri, 26 Oct 2007 20:00:32 +0200
Message-ID: <47222B40.1070009@tiscali.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out2.tiscali.nl ([195.241.79.177]:37599 "EHLO
	smtp-out2.tiscali.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757229AbXJZSAf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2007 14:00:35 -0400
Received: from [82.171.216.234] (helo=[192.168.1.2])
	by smtp-out2.tiscali.nl with esmtp (Tiscali http://www.tiscali.nl)
	id 1IlTU2-0002Vb-CO
	for <netdev@vger.kernel.org>; Fri, 26 Oct 2007 20:00:34 +0200
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I am a bit uncertain about this, so if you have comments on this, it is much
appreciated.

The rationale:
in the default case the BUG() kills the current process, but with the lock
still held this causes the system to hang; therefore the unlock before the
BUG(). 

When CONFIG_BUG is disabled - e.g. for embedded systems - the BUG(); will
not kill the process and there should not be a double unlock in that case.
--
    Unlock before BUG(), but preserve normal operation in the case that
    CONFIG_BUG is disabled.
    
    Signed-off-by: Roel Kluin <12o3l@tiscali.nl>
---
diff --git a/drivers/net/wireless/ipw2200.c b/drivers/net/wireless/ipw2200.c
index e3c8284..f337578 100644
--- a/drivers/net/wireless/ipw2200.c
+++ b/drivers/net/wireless/ipw2200.c
@@ -8722,7 +8722,9 @@ static int ipw_wx_get_freq(struct net_device *dev,
 			break;
 
 		default:
+			mutex_unlock(&priv->mutex);
 			BUG();
+			return -EINVAL;
 		}
 	} else
 		wrqu->freq.m = 0;
diff --git a/net/rxrpc/ar-ack.c b/net/rxrpc/ar-ack.c
index 657ee69..e551b0b 100644
--- a/net/rxrpc/ar-ack.c
+++ b/net/rxrpc/ar-ack.c
@@ -752,8 +752,11 @@ all_acked:
 		sp->call = call;
 		rxrpc_get_call(call);
 		spin_lock_bh(&call->lock);
-		if (rxrpc_queue_rcv_skb(call, skb, true, true) < 0)
+		if (rxrpc_queue_rcv_skb(call, skb, true, true) < 0) {
+			spin_unlock_bh(&call->lock);
 			BUG();
+			goto process_further;
+		}
 		spin_unlock_bh(&call->lock);
 		goto process_further;
 	}
diff --git a/net/rxrpc/ar-call.c b/net/rxrpc/ar-call.c
index 3c04b00..48804e1 100644
--- a/net/rxrpc/ar-call.c
+++ b/net/rxrpc/ar-call.c
@@ -426,9 +426,12 @@ void rxrpc_release_call(struct rxrpc_call *call)
 	       call->rx_first_oos);
 
 	spin_lock_bh(&call->lock);
-	if (test_and_set_bit(RXRPC_CALL_RELEASED, &call->flags))
+	if (test_and_set_bit(RXRPC_CALL_RELEASED, &call->flags)) {
+		spin_unlock_bh(&call->lock);
 		BUG();
-	spin_unlock_bh(&call->lock);
+	} else {
+		spin_unlock_bh(&call->lock);
+	}
 
 	/* dissociate from the socket
 	 * - the socket's ref on the call is passed to the death timer

