From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 9/9] RDS: Do not send a pong to an incoming ping with 0 src port
Date: Thu, 30 Jun 2016 16:11:18 -0700
Message-ID: <f8cb6eac2c4ebc6c3e9d214fa46e72f8bf848ce8.1467322344.git.sowmini.varadhan@oracle.com>
References: <cover.1467322344.git.sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, rds-devel@oss.oracle.com,
	sowmini.varadhan@oracle.com, santosh.shilimkar@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1050.oracle.com ([141.146.126.70]:44450 "EHLO
	aserp1050.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752124AbcF3XMQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 19:12:16 -0400
Received: from aserp1040.oracle.com (aserp1040.oracle.com [141.146.126.69])
	by aserp1050.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id u5UNCAvH007298
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 30 Jun 2016 23:12:11 GMT
In-Reply-To: <cover.1467322344.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1467322344.git.sowmini.varadhan@oracle.com>
References: <cover.1467322344.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RDS ping messages are sent with a non-zero src port to a zero
dst port, so that the rds pong messages can be sent back to the
originators src port. However if a confused/malicious sender
sends a ping with a 0 src port, we'd have an infinite ping-pong
loop. To avoid this, the receiver should ignore ping messages
with a 0 src port.

Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 net/rds/recv.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/rds/recv.c b/net/rds/recv.c
index b58f505..fed53a6 100644
--- a/net/rds/recv.c
+++ b/net/rds/recv.c
@@ -226,6 +226,10 @@ void rds_recv_incoming(struct rds_connection *conn, __be32 saddr, __be32 daddr,
 	cp->cp_next_rx_seq = be64_to_cpu(inc->i_hdr.h_sequence) + 1;
 
 	if (rds_sysctl_ping_enable && inc->i_hdr.h_dport == 0) {
+		if (inc->i_hdr.h_sport == 0) {
+			rdsdebug("ignore ping with 0 sport from 0x%x\n", saddr);
+			goto out;
+		}
 		rds_stats_inc(s_recv_ping);
 		rds_send_pong(cp, inc->i_hdr.h_sport);
 		goto out;
-- 
1.7.1
