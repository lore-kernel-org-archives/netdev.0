From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 1/4] [SCTP] Verify all destination ports in sctp_connectx.
Date: Fri,  4 May 2007 16:22:52 -0400
Message-ID: <11783101751206-git-send-email-vladislav.yasevich@hp.com>
References: <1178310175881-git-send-email-vladislav.yasevich@hp.com>
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel7.hp.com ([156.153.255.213]:59046 "EHLO atlrel7.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031532AbXEDUW7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 May 2007 16:22:59 -0400
In-Reply-To: <1178310175881-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We need to make sure that all destination ports are the same, since
the association really must not connect to multiple different ports
at once.  This was reported on the sctp-impl list.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/socket.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 2fc0a92..81de560 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -972,6 +972,7 @@ static int __sctp_connect(struct sock* sk,
 	int walk_size = 0;
 	union sctp_addr *sa_addr;
 	void *addr_buf;
+	unsigned short port;
 
 	sp = sctp_sk(sk);
 	ep = sp->ep;
@@ -992,6 +993,7 @@ static int __sctp_connect(struct sock* sk,
 	while (walk_size < addrs_size) {
 		sa_addr = (union sctp_addr *)addr_buf;
 		af = sctp_get_af_specific(sa_addr->sa.sa_family);
+		port = ntohs(sa_addr->v4.sin_port);
 
 		/* If the address family is not supported or if this address
 		 * causes the address buffer to overflow return EINVAL.
@@ -1005,6 +1007,12 @@ static int __sctp_connect(struct sock* sk,
 		if (err)
 			goto out_free;
 
+		/* Make sure the destination port is correctly set 
+		 * in all addresses.
+		 */
+		if (asoc && asoc->peer.port && asoc->peer.port != port)
+			goto out_free;
+
 		memcpy(&to, sa_addr, af->sockaddr_len);
 
 		/* Check if there already is a matching association on the
-- 
1.5.0.3.438.gc49b2

