From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [PATCH 03/15] RDS: fix rds_sock reference bug while doing bind
Date: Sat, 19 Sep 2015 19:04:40 -0400
Message-ID: <1442703892-26692-4-git-send-email-santosh.shilimkar@oracle.com>
References: <1442703892-26692-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	ssantosh@kernel.org,
	Santosh Shilimkar <santosh.shilimkar@oracle.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:47467 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751572AbbISXF0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Sep 2015 19:05:26 -0400
In-Reply-To: <1442703892-26692-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

One need to take rds socket reference while using it and release it
once done with it. rds_add_bind() code path does not do that so
lets fix it.

Signed-off-by: Santosh Shilimkar <ssantosh@kernel.org>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 net/rds/bind.c | 16 +++++++++++-----
 1 file changed, 11 insertions(+), 5 deletions(-)

diff --git a/net/rds/bind.c b/net/rds/bind.c
index 01989e2..166c605 100644
--- a/net/rds/bind.c
+++ b/net/rds/bind.c
@@ -61,8 +61,10 @@ static struct rds_sock *rds_bind_lookup(__be32 addr, __be16 port,
 		cmp = ((u64)be32_to_cpu(rs->rs_bound_addr) << 32) |
 		      be16_to_cpu(rs->rs_bound_port);
 
-		if (cmp == needle)
+		if (cmp == needle) {
+			rds_sock_addref(rs);
 			return rs;
+		}
 	}
 
 	if (insert) {
@@ -94,10 +96,10 @@ struct rds_sock *rds_find_bound(__be32 addr, __be16 port)
 	rs = rds_bind_lookup(addr, port, NULL);
 	read_unlock_irqrestore(&rds_bind_lock, flags);
 
-	if (rs && !sock_flag(rds_rs_to_sk(rs), SOCK_DEAD))
-		rds_sock_addref(rs);
-	else
+	if (rs && sock_flag(rds_rs_to_sk(rs), SOCK_DEAD)) {
+		rds_sock_put(rs);
 		rs = NULL;
+	}
 
 	rdsdebug("returning rs %p for %pI4:%u\n", rs, &addr,
 		ntohs(port));
@@ -123,14 +125,18 @@ static int rds_add_bound(struct rds_sock *rs, __be32 addr, __be16 *port)
 	write_lock_irqsave(&rds_bind_lock, flags);
 
 	do {
+		struct rds_sock *rrs;
 		if (rover == 0)
 			rover++;
-		if (!rds_bind_lookup(addr, cpu_to_be16(rover), rs)) {
+		rrs = rds_bind_lookup(addr, cpu_to_be16(rover), rs);
+		if (!rrs) {
 			*port = rs->rs_bound_port;
 			ret = 0;
 			rdsdebug("rs %p binding to %pI4:%d\n",
 			  rs, &addr, (int)ntohs(*port));
 			break;
+		} else {
+			rds_sock_put(rrs);
 		}
 	} while (rover++ != last);
 
-- 
1.9.1
