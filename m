From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH 10/16] llc: Fix missing msg_namelen update in llc_ui_recvmsg()
Date: Sun,  7 Apr 2013 13:51:56 +0200
Message-ID: <1365335522-29931-11-git-send-email-minipli@googlemail.com>
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
Received: from mail-bk0-f43.google.com ([209.85.214.43]:36575 "EHLO
	mail-bk0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933488Ab3DGLwg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Apr 2013 07:52:36 -0400
Received: by mail-bk0-f43.google.com with SMTP id jm2so2679693bkc.2
        for <netdev@vger.kernel.org>; Sun, 07 Apr 2013 04:52:35 -0700 (PDT)
In-Reply-To: <1365335522-29931-1-git-send-email-minipli@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For stream sockets the code misses to update the msg_namelen member
to 0 and therefore makes net/socket.c leak the local, uninitialized
sockaddr_storage variable to userland -- 128 bytes of kernel stack
memory. The msg_namelen update is also missing for datagram sockets
in case the socket is shutting down during receive.

Fix both issues by setting msg_namelen to 0 early. It will be
updated later if we're going to fill the msg_name member.

Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Signed-off-by: Mathias Krause <minipli@googlemail.com>
---
 net/llc/af_llc.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/llc/af_llc.c b/net/llc/af_llc.c
index 8870988..48aaa89 100644
--- a/net/llc/af_llc.c
+++ b/net/llc/af_llc.c
@@ -720,6 +720,8 @@ static int llc_ui_recvmsg(struct kiocb *iocb, struct socket *sock,
 	int target;	/* Read at least this many bytes */
 	long timeo;
 
+	msg->msg_namelen = 0;
+
 	lock_sock(sk);
 	copied = -ENOTCONN;
 	if (unlikely(sk->sk_type == SOCK_STREAM && sk->sk_state == TCP_LISTEN))
-- 
1.7.10.4
