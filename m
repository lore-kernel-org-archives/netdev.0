From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net 1/1] af_iucv: fix AF_IUCV sendmsg() errno
Date: Mon, 30 Mar 2015 15:40:42 +0200
Message-ID: <1427722842-49894-2-git-send-email-ubraun@linux.vnet.ibm.com>
References: <1427722842-49894-1-git-send-email-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	ursula.braun@de.ibm.com, ubraun@linux.vnet.ibm.com,
	Eugene Crosser <Eugene.Crosser@ru.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp16.uk.ibm.com ([195.75.94.112]:41462 "EHLO
	e06smtp16.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752904AbbC3NsV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2015 09:48:21 -0400
Received: from /spool/local
	by e06smtp16.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Mon, 30 Mar 2015 14:48:19 +0100
In-Reply-To: <1427722842-49894-1-git-send-email-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugene Crosser <Eugene.Crosser@ru.ibm.com>

When sending over AF_IUCV socket, errno was incorrectly set to
ENOMEM even when other values where appropriate, notably EAGAIN.
With this patch, error indicator returned by sock_alloc_send_skb()
is passed to the caller, rather than being overwritten with ENOMEM.

Signed-off-by: Eugene Crosser <Eugene.Crosser@ru.ibm.com>
Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
---
 net/iucv/af_iucv.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/iucv/af_iucv.c b/net/iucv/af_iucv.c
index 2e9953b..53d9311 100644
--- a/net/iucv/af_iucv.c
+++ b/net/iucv/af_iucv.c
@@ -1114,10 +1114,8 @@ static int iucv_sock_sendmsg(struct kiocb *iocb, struct socket *sock,
 			noblock, &err);
 	else
 		skb = sock_alloc_send_skb(sk, len, noblock, &err);
-	if (!skb) {
-		err = -ENOMEM;
+	if (!skb)
 		goto out;
-	}
 	if (iucv->transport == AF_IUCV_TRANS_HIPER)
 		skb_reserve(skb, sizeof(struct af_iucv_trans_hdr) + ETH_HLEN);
 	if (memcpy_from_msg(skb_put(skb, len), msg, len)) {
-- 
2.1.4
