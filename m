From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] sctp: check af before verify address in sctp_addr_id2transport
Date: Tue,  7 Feb 2017 20:56:08 +0800
Message-ID: <d4c232a9f69f9eae6537f74078dc0d2a0574e8eb.1486472168.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34581 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753285AbdBGM4P (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 07:56:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 6f29a1306131 ("sctp: sctp_addr_id2transport should verify the
addr before looking up assoc") invoked sctp_verify_addr to verify the
addr.

But it didn't check af variable beforehand, once users pass an address
with family = 0 through sockopt, sctp_get_af_specific will return NULL
and NULL pointer dereference will be caused by af->sockaddr_len.

This patch is to fix it by returning NULL if af variable is NULL.

Fixes: 6f29a1306131 ("sctp: sctp_addr_id2transport should verify the addr before looking up assoc")
Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/sctp/socket.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 37eeab7..f354375 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -239,7 +239,7 @@ static struct sctp_transport *sctp_addr_id2transport(struct sock *sk,
 	union sctp_addr *laddr = (union sctp_addr *)addr;
 	struct sctp_transport *transport;
 
-	if (sctp_verify_addr(sk, laddr, af->sockaddr_len))
+	if (!af || sctp_verify_addr(sk, laddr, af->sockaddr_len))
 		return NULL;
 
 	addr_asoc = sctp_endpoint_lookup_assoc(sctp_sk(sk)->ep,
-- 
2.1.0
