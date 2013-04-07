From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH 12/16] NFC: llcp: fix info leaks via msg_name in llcp_sock_recvmsg()
Date: Sun,  7 Apr 2013 13:51:58 +0200
Message-ID: <1365335522-29931-13-git-send-email-minipli@googlemail.com>
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
Received: from mail-bk0-f52.google.com ([209.85.214.52]:59843 "EHLO
	mail-bk0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933504Ab3DGLwj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Apr 2013 07:52:39 -0400
Received: by mail-bk0-f52.google.com with SMTP id it16so2652488bkc.39
        for <netdev@vger.kernel.org>; Sun, 07 Apr 2013 04:52:38 -0700 (PDT)
In-Reply-To: <1365335522-29931-1-git-send-email-minipli@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The code in llcp_sock_recvmsg() does not initialize all the members of
struct sockaddr_nfc_llcp when filling the sockaddr info. Nor does it
initialize the padding bytes of the structure inserted by the compiler
for alignment.

Also, if the socket is in state LLCP_CLOSED or is shutting down during
receive the msg_namelen member is not updated to 0 while otherwise
returning with 0, i.e. "success". The msg_namelen update is also
missing for stream and seqpacket sockets which don't fill the sockaddr
info.

Both issues lead to the fact that the code will leak uninitialized
kernel stack bytes in net/socket.c.

Fix the first issue by initializing the memory used for sockaddr info
with memset(0). Fix the second one by setting msg_namelen to 0 early.
It will be updated later if we're going to fill the msg_name member.

Cc: Lauro Ramos Venancio <lauro.venancio@openbossa.org>
Cc: Aloisio Almeida Jr <aloisio.almeida@openbossa.org>
Cc: Samuel Ortiz <sameo@linux.intel.com>
Signed-off-by: Mathias Krause <minipli@googlemail.com>
---
 net/nfc/llcp/sock.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/nfc/llcp/sock.c b/net/nfc/llcp/sock.c
index 5c7cdf3..4741adc 100644
--- a/net/nfc/llcp/sock.c
+++ b/net/nfc/llcp/sock.c
@@ -646,6 +646,8 @@ static int llcp_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
 
 	pr_debug("%p %zu\n", sk, len);
 
+	msg->msg_namelen = 0;
+
 	lock_sock(sk);
 
 	if (sk->sk_state == LLCP_CLOSED &&
@@ -691,6 +693,7 @@ static int llcp_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
 
 		pr_debug("Datagram socket %d %d\n", ui_cb->dsap, ui_cb->ssap);
 
+		memset(sockaddr, 0, sizeof(*sockaddr));
 		sockaddr->sa_family = AF_NFC;
 		sockaddr->nfc_protocol = NFC_PROTO_NFC_DEP;
 		sockaddr->dsap = ui_cb->dsap;
-- 
1.7.10.4
