From: Asias He <asias@redhat.com>
Subject: [PATCH 2/4] VSOCK: Return VMCI_ERROR_NO_MEM when fails to allocate skb
Date: Thu, 20 Jun 2013 17:20:31 +0800
Message-ID: <1371720033-19714-3-git-send-email-asias@redhat.com>
References: <1371720033-19714-1-git-send-email-asias@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Andy King <acking@vmware.com>,
	Dmitry Torokhov <dtor@vmware.com>,
	Reilly Grant <grantr@vmware.com>, Asias He <asias@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62458 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755535Ab3FTJU4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Jun 2013 05:20:56 -0400
In-Reply-To: <1371720033-19714-1-git-send-email-asias@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

vmci_transport_recv_dgram_cb always return VMCI_SUCESS even if we fail
to allocate skb, return VMCI_ERROR_NO_MEM instead.

Signed-off-by: Asias He <asias@redhat.com>
---
 net/vmw_vsock/vmci_transport.c | 15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

diff --git a/net/vmw_vsock/vmci_transport.c b/net/vmw_vsock/vmci_transport.c
index daff752..99b511d 100644
--- a/net/vmw_vsock/vmci_transport.c
+++ b/net/vmw_vsock/vmci_transport.c
@@ -625,13 +625,14 @@ static int vmci_transport_recv_dgram_cb(void *data, struct vmci_datagram *dg)
 
 	/* Attach the packet to the socket's receive queue as an sk_buff. */
 	skb = alloc_skb(size, GFP_ATOMIC);
-	if (skb) {
-		/* sk_receive_skb() will do a sock_put(), so hold here. */
-		sock_hold(sk);
-		skb_put(skb, size);
-		memcpy(skb->data, dg, size);
-		sk_receive_skb(sk, skb, 0);
-	}
+	if (!skb)
+		return VMCI_ERROR_NO_MEM;
+
+	/* sk_receive_skb() will do a sock_put(), so hold here. */
+	sock_hold(sk);
+	skb_put(skb, size);
+	memcpy(skb->data, dg, size);
+	sk_receive_skb(sk, skb, 0);
 
 	return VMCI_SUCCESS;
 }
-- 
1.8.1.4
