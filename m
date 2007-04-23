From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH] [SCTP] Verify all destination ports in sctp_connectx.
Date: Mon, 23 Apr 2007 14:35:47 -0400
Message-ID: <462CFC83.9030802@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"lksctp-developers@lists.sourceforge.net"
	<lksctp-developers@lists.sourceforge.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:46812 "EHLO atlrel9.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161390AbXDWSgu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Apr 2007 14:36:50 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David

Please apply.  This was recently uncovered on the sctp-implementers
list as 'linux doing something stupid...'

Thanks
-vlad

[SCTP] Verify all destination ports in sctp_connectx.

We need to make sure that all destination ports are the same, since
the association really must not connect to multiple different ports
at once.  This was reported on the sctp-impl list.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/socket.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 536298c..6bfae12 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -966,6 +966,7 @@ static int __sctp_connect(struct sock* sk,
 	int walk_size = 0;
 	union sctp_addr *sa_addr;
 	void *addr_buf;
+	unsigned short port;
 
 	sp = sctp_sk(sk);
 	ep = sp->ep;
@@ -986,6 +987,7 @@ static int __sctp_connect(struct sock* sk,
 	while (walk_size < addrs_size) {
 		sa_addr = (union sctp_addr *)addr_buf;
 		af = sctp_get_af_specific(sa_addr->sa.sa_family);
+		port = ntohs(sa_addr->v4.sin_port);
 
 		/* If the address family is not supported or if this address
 		 * causes the address buffer to overflow return EINVAL.
@@ -999,6 +1001,12 @@ static int __sctp_connect(struct sock* sk,
 		if (err)
 			goto out_free;
 
+		/* Make sure the destination port is set to the same 
+		 * value in each address.
+		 */
+		if (asoc && asoc->peer.port && asoc->peer.port != port)
+			goto out_free;
+
 		memcpy(&to, sa_addr, af->sockaddr_len);
 
 		/* Check if there already is a matching association on the
-- 
1.5.0.3.438.gc49b2

