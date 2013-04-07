From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH 11/16] netrom: fix info leak via msg_name in nr_recvmsg()
Date: Sun,  7 Apr 2013 13:51:57 +0200
Message-ID: <1365335522-29931-12-git-send-email-minipli@googlemail.com>
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
Received: from mail-bk0-f43.google.com ([209.85.214.43]:40810 "EHLO
	mail-bk0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933373Ab3DGLwh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Apr 2013 07:52:37 -0400
Received: by mail-bk0-f43.google.com with SMTP id jm2so2647058bkc.16
        for <netdev@vger.kernel.org>; Sun, 07 Apr 2013 04:52:36 -0700 (PDT)
In-Reply-To: <1365335522-29931-1-git-send-email-minipli@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case msg_name is set the sockaddr info gets filled out, as
requested, but the code fails to initialize the padding bytes of
struct sockaddr_ax25 inserted by the compiler for alignment. Also
the sax25_ndigis member does not get assigned, leaking four more
bytes.

Both issues lead to the fact that the code will leak uninitialized
kernel stack bytes in net/socket.c.

Fix both issues by initializing the memory with memset(0).

Cc: Ralf Baechle <ralf@linux-mips.org>
Signed-off-by: Mathias Krause <minipli@googlemail.com>
---
 net/netrom/af_netrom.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
index d1fa1d9..7fcb307 100644
--- a/net/netrom/af_netrom.c
+++ b/net/netrom/af_netrom.c
@@ -1173,6 +1173,7 @@ static int nr_recvmsg(struct kiocb *iocb, struct socket *sock,
 	}
 
 	if (sax != NULL) {
+		memset(sax, 0, sizeof(sax));
 		sax->sax25_family = AF_NETROM;
 		skb_copy_from_linear_data_offset(skb, 7, sax->sax25_call.ax25_call,
 			      AX25_ADDR_LEN);
-- 
1.7.10.4
