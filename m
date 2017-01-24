From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] sctp: sctp_addr_id2transport should verify the addr before looking up assoc
Date: Tue, 24 Jan 2017 14:01:53 +0800
Message-ID: <2ba9d3e0b3aa05baa3791811c92248126d233c67.1485237713.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35363 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750703AbdAXGCB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 01:02:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sctp_addr_id2transport is a function for sockopt to look up assoc by
address. As the address is from userspace, it can be a v4-mapped v6
address. But in sctp protocol stack, it always handles a v4-mapped
v6 address as a v4 address. So it's necessary to convert it to a v4
address before looking up assoc by address.

This patch is to fix it by calling sctp_verify_addr in which it can do
this conversion before calling sctp_endpoint_lookup_assoc, just like
what sctp_sendmsg and __sctp_connect do for the address from users.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/sctp/socket.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 318c678..37eeab7 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -235,8 +235,12 @@ static struct sctp_transport *sctp_addr_id2transport(struct sock *sk,
 					      sctp_assoc_t id)
 {
 	struct sctp_association *addr_asoc = NULL, *id_asoc = NULL;
-	struct sctp_transport *transport;
+	struct sctp_af *af = sctp_get_af_specific(addr->ss_family);
 	union sctp_addr *laddr = (union sctp_addr *)addr;
+	struct sctp_transport *transport;
+
+	if (sctp_verify_addr(sk, laddr, af->sockaddr_len))
+		return NULL;
 
 	addr_asoc = sctp_endpoint_lookup_assoc(sctp_sk(sk)->ep,
 					       laddr,
-- 
2.1.0
