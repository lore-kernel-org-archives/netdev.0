From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH 06/16] caif: Fix missing msg_namelen update in caif_seqpkt_recvmsg()
Date: Sun,  7 Apr 2013 13:51:52 +0200
Message-ID: <1365335522-29931-7-git-send-email-minipli@googlemail.com>
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
Received: from mail-bk0-f54.google.com ([209.85.214.54]:45156 "EHLO
	mail-bk0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933435Ab3DGLwb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Apr 2013 07:52:31 -0400
Received: by mail-bk0-f54.google.com with SMTP id q16so2666070bkw.41
        for <netdev@vger.kernel.org>; Sun, 07 Apr 2013 04:52:30 -0700 (PDT)
In-Reply-To: <1365335522-29931-1-git-send-email-minipli@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current code does not fill the msg_name member in case it is set.
It also does not set the msg_namelen member to 0 and therefore makes
net/socket.c leak the local, uninitialized sockaddr_storage variable
to userland -- 128 bytes of kernel stack memory.

Fix that by simply setting msg_namelen to 0 as obviously nobody cared
about caif_seqpkt_recvmsg() not filling the msg_name in case it was
set.

Cc: Sjur Braendeland <sjur.brandeland@stericsson.com>
Signed-off-by: Mathias Krause <minipli@googlemail.com>
---
 net/caif/caif_socket.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/caif/caif_socket.c b/net/caif/caif_socket.c
index 095259f..ff2ff3c 100644
--- a/net/caif/caif_socket.c
+++ b/net/caif/caif_socket.c
@@ -286,6 +286,8 @@ static int caif_seqpkt_recvmsg(struct kiocb *iocb, struct socket *sock,
 	if (m->msg_flags&MSG_OOB)
 		goto read_error;
 
+	m->msg_namelen = 0;
+
 	skb = skb_recv_datagram(sk, flags, 0 , &ret);
 	if (!skb)
 		goto read_error;
-- 
1.7.10.4
