From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH 03/16] Bluetooth: fix possible info leak in bt_sock_recvmsg()
Date: Sun,  7 Apr 2013 13:51:49 +0200
Message-ID: <1365335522-29931-4-git-send-email-minipli@googlemail.com>
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
Received: from mail-bk0-f52.google.com ([209.85.214.52]:43011 "EHLO
	mail-bk0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933443Ab3DGLw1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Apr 2013 07:52:27 -0400
Received: by mail-bk0-f52.google.com with SMTP id it16so2618672bkc.25
        for <netdev@vger.kernel.org>; Sun, 07 Apr 2013 04:52:26 -0700 (PDT)
In-Reply-To: <1365335522-29931-1-git-send-email-minipli@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case the socket is already shutting down, bt_sock_recvmsg() returns
with 0 without updating msg_namelen leading to net/socket.c leaking the
local, uninitialized sockaddr_storage variable to userland -- 128 bytes
of kernel stack memory.

Fix this by moving the msg_namelen assignment in front of the shutdown
test.

Cc: Marcel Holtmann <marcel@holtmann.org>
Cc: Gustavo Padovan <gustavo@padovan.org>
Cc: Johan Hedberg <johan.hedberg@gmail.com>
Signed-off-by: Mathias Krause <minipli@googlemail.com>
---
 net/bluetooth/af_bluetooth.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/bluetooth/af_bluetooth.c b/net/bluetooth/af_bluetooth.c
index d3ee69b..0d1b08c 100644
--- a/net/bluetooth/af_bluetooth.c
+++ b/net/bluetooth/af_bluetooth.c
@@ -230,6 +230,8 @@ int bt_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
 	if (flags & (MSG_OOB))
 		return -EOPNOTSUPP;
 
+	msg->msg_namelen = 0;
+
 	skb = skb_recv_datagram(sk, flags, noblock, &err);
 	if (!skb) {
 		if (sk->sk_shutdown & RCV_SHUTDOWN)
@@ -237,8 +239,6 @@ int bt_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
 		return err;
 	}
 
-	msg->msg_namelen = 0;
-
 	copied = skb->len;
 	if (len < copied) {
 		msg->msg_flags |= MSG_TRUNC;
-- 
1.7.10.4
