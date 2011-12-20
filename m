From: frank.blaschka@de.ibm.com
Subject: [patch 02/10] [PATCH] af_iucv: accelerate close for HS transport
Date: Tue, 20 Dec 2011 09:56:28 +0100
Message-ID: <20111220085735.688872331@de.ibm.com>
References: <20111220085626.924756639@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp13.uk.ibm.com ([195.75.94.109]:35208 "EHLO
	e06smtp13.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752136Ab1LTI5k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2011 03:57:40 -0500
Received: from /spool/local
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Tue, 20 Dec 2011 08:57:39 -0000
Content-Disposition: inline; filename=601-af_iucv-fast-close-hs.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

Closing an af_iucv socket may wait for confirmation of outstanding
send requests. This patch adds confirmation code for the new
HiperSockets transport.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 net/iucv/af_iucv.c |    7 +++++++
 1 file changed, 7 insertions(+)

--- a/net/iucv/af_iucv.c
+++ b/net/iucv/af_iucv.c
@@ -2293,6 +2293,13 @@ static void afiucv_hs_callback_txnotify(
 	}
 	spin_unlock_irqrestore(&list->lock, flags);
 
+	if (sk->sk_state == IUCV_CLOSING) {
+		if (skb_queue_empty(&iucv_sk(sk)->send_skb_q)) {
+			sk->sk_state = IUCV_CLOSED;
+			sk->sk_state_change(sk);
+		}
+	}
+
 out_unlock:
 	bh_unlock_sock(sk);
 }
