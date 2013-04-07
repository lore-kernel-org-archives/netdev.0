From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH 04/16] Bluetooth: RFCOMM - Fix missing msg_namelen update in rfcomm_sock_recvmsg()
Date: Sun,  7 Apr 2013 13:51:50 +0200
Message-ID: <1365335522-29931-5-git-send-email-minipli@googlemail.com>
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
Received: from mail-bk0-f49.google.com ([209.85.214.49]:34389 "EHLO
	mail-bk0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933435Ab3DGLw2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Apr 2013 07:52:28 -0400
Received: by mail-bk0-f49.google.com with SMTP id w12so2715278bku.36
        for <netdev@vger.kernel.org>; Sun, 07 Apr 2013 04:52:27 -0700 (PDT)
In-Reply-To: <1365335522-29931-1-git-send-email-minipli@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If RFCOMM_DEFER_SETUP is set in the flags, rfcomm_sock_recvmsg() returns
early with 0 without updating the possibly set msg_namelen member. This,
in turn, leads to a 128 byte kernel stack leak in net/socket.c.

Fix this by updating msg_namelen in this case. For all other cases it
will be handled in bt_sock_stream_recvmsg().

Cc: Marcel Holtmann <marcel@holtmann.org>
Cc: Gustavo Padovan <gustavo@padovan.org>
Cc: Johan Hedberg <johan.hedberg@gmail.com>
Signed-off-by: Mathias Krause <minipli@googlemail.com>
---
 net/bluetooth/rfcomm/sock.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/bluetooth/rfcomm/sock.c b/net/bluetooth/rfcomm/sock.c
index c23bae8..7c9224b 100644
--- a/net/bluetooth/rfcomm/sock.c
+++ b/net/bluetooth/rfcomm/sock.c
@@ -608,6 +608,7 @@ static int rfcomm_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
 
 	if (test_and_clear_bit(RFCOMM_DEFER_SETUP, &d->flags)) {
 		rfcomm_dlc_accept(d);
+		msg->msg_namelen = 0;
 		return 0;
 	}
 
-- 
1.7.10.4
