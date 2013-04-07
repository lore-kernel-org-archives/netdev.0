From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH 05/16] Bluetooth: SCO - Fix missing msg_namelen update in sco_sock_recvmsg()
Date: Sun,  7 Apr 2013 13:51:51 +0200
Message-ID: <1365335522-29931-6-git-send-email-minipli@googlemail.com>
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
Received: from mail-bk0-f43.google.com ([209.85.214.43]:46754 "EHLO
	mail-bk0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933484Ab3DGLwa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Apr 2013 07:52:30 -0400
Received: by mail-bk0-f43.google.com with SMTP id jm2so2679676bkc.2
        for <netdev@vger.kernel.org>; Sun, 07 Apr 2013 04:52:28 -0700 (PDT)
In-Reply-To: <1365335522-29931-1-git-send-email-minipli@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the socket is in state BT_CONNECT2 and BT_SK_DEFER_SETUP is set in
the flags, sco_sock_recvmsg() returns early with 0 without updating the
possibly set msg_namelen member. This, in turn, leads to a 128 byte
kernel stack leak in net/socket.c.

Fix this by updating msg_namelen in this case. For all other cases it
will be handled in bt_sock_recvmsg().

Cc: Marcel Holtmann <marcel@holtmann.org>
Cc: Gustavo Padovan <gustavo@padovan.org>
Cc: Johan Hedberg <johan.hedberg@gmail.com>
Signed-off-by: Mathias Krause <minipli@googlemail.com>
---
 net/bluetooth/sco.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/bluetooth/sco.c b/net/bluetooth/sco.c
index fad0302..fb6192c 100644
--- a/net/bluetooth/sco.c
+++ b/net/bluetooth/sco.c
@@ -665,6 +665,7 @@ static int sco_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
 	    test_bit(BT_SK_DEFER_SETUP, &bt_sk(sk)->flags)) {
 		hci_conn_accept(pi->conn->hcon, 0);
 		sk->sk_state = BT_CONFIG;
+		msg->msg_namelen = 0;
 
 		release_sock(sk);
 		return 0;
-- 
1.7.10.4
