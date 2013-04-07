From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH 15/16] VSOCK: vmci - fix possible info leak in vmci_transport_dgram_dequeue()
Date: Sun,  7 Apr 2013 13:52:01 +0200
Message-ID: <1365335522-29931-16-git-send-email-minipli@googlemail.com>
References: <1365335522-29931-1-git-send-email-minipli@googlemail.com>
Cc: netdev@vger.kernel.org,
	Allan Stephens <allan.stephens@windriver.com>,
	Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	Andy King <acking@vmware.com>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	Dmitry Torokhov <dtor@vmware.com>,
	George Zhang <georgezhang@vmware.com>,
	Gustavo Padovan <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	Jon Maloy <jon.maloy@ericsson.com>,
	Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
	Marcel Holtmann <marcel@holtmann.org>,
	Ralf Baechle <ralf@linux-mips.org>,
	Samuel Ortiz <sameo@linux.intel.com>,
	Samuel Ortiz <samuel@sortiz.org>,
	Sjur Braendeland <sjur.brandeland@stericsson.com>,
	Ursula Braun <ursula.braun@de.ibm.com>,
	Brad Spengler <spender@grsecurity.net>,
	Mathias Krause <minipli@googlemail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f51.google.com ([209.85.214.51]:60169 "EHLO
	mail-bk0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933521Ab3DGLwn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Apr 2013 07:52:43 -0400
Received: by mail-bk0-f51.google.com with SMTP id y8so2702487bkt.38
        for <netdev@vger.kernel.org>; Sun, 07 Apr 2013 04:52:41 -0700 (PDT)
In-Reply-To: <1365335522-29931-1-git-send-email-minipli@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case we received no data on the call to skb_recv_datagram(), i.e.
skb->data is NULL, vmci_transport_dgram_dequeue() will return with 0
without updating msg_namelen leading to net/socket.c leaking the local,
uninitialized sockaddr_storage variable to userland -- 128 bytes of
kernel stack memory.

Fix this by moving the already existing msg_namelen assignment a few
lines above.

Cc: Andy King <acking@vmware.com>
Cc: Dmitry Torokhov <dtor@vmware.com>
Cc: George Zhang <georgezhang@vmware.com>
Signed-off-by: Mathias Krause <minipli@googlemail.com>
---
 net/vmw_vsock/vmci_transport.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/vmw_vsock/vmci_transport.c b/net/vmw_vsock/vmci_transport.c
index a70ace8..a8e4e70 100644
--- a/net/vmw_vsock/vmci_transport.c
+++ b/net/vmw_vsock/vmci_transport.c
@@ -1727,6 +1727,8 @@ static int vmci_transport_dgram_dequeue(struct kiocb *kiocb,
 	if (flags & MSG_OOB || flags & MSG_ERRQUEUE)
 		return -EOPNOTSUPP;
 
+	msg->msg_namelen = 0;
+
 	/* Retrieve the head sk_buff from the socket's receive queue. */
 	err = 0;
 	skb = skb_recv_datagram(&vsk->sk, flags, noblock, &err);
@@ -1759,7 +1761,6 @@ static int vmci_transport_dgram_dequeue(struct kiocb *kiocb,
 	if (err)
 		goto out;
 
-	msg->msg_namelen = 0;
 	if (msg->msg_name) {
 		struct sockaddr_vm *vm_addr;
 
-- 
1.7.10.4
