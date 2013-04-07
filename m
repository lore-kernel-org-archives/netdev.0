From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH 08/16] iucv: Fix missing msg_namelen update in iucv_sock_recvmsg()
Date: Sun,  7 Apr 2013 13:51:54 +0200
Message-ID: <1365335522-29931-9-git-send-email-minipli@googlemail.com>
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
Received: from mail-bk0-f41.google.com ([209.85.214.41]:56409 "EHLO
	mail-bk0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933500Ab3DGLwe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Apr 2013 07:52:34 -0400
Received: by mail-bk0-f41.google.com with SMTP id i18so2680875bkv.28
        for <netdev@vger.kernel.org>; Sun, 07 Apr 2013 04:52:32 -0700 (PDT)
In-Reply-To: <1365335522-29931-1-git-send-email-minipli@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current code does not fill the msg_name member in case it is set.
It also does not set the msg_namelen member to 0 and therefore makes
net/socket.c leak the local, uninitialized sockaddr_storage variable
to userland -- 128 bytes of kernel stack memory.

Fix that by simply setting msg_namelen to 0 as obviously nobody cared
about iucv_sock_recvmsg() not filling the msg_name in case it was set.

Cc: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Mathias Krause <minipli@googlemail.com>
---
Remark: I failed to test that one as I've no access to a S390 system.

 net/iucv/af_iucv.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/iucv/af_iucv.c b/net/iucv/af_iucv.c
index a7d11ffe..bf69358 100644
--- a/net/iucv/af_iucv.c
+++ b/net/iucv/af_iucv.c
@@ -1328,6 +1328,8 @@ static int iucv_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
 	struct sk_buff *skb, *rskb, *cskb;
 	int err = 0;
 
+	msg->msg_namelen = 0;
+
 	if ((sk->sk_state == IUCV_DISCONN) &&
 	    skb_queue_empty(&iucv->backlog_skb_q) &&
 	    skb_queue_empty(&sk->sk_receive_queue) &&
-- 
1.7.10.4
