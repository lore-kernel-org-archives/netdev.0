From: Jeff Liu <jeff.liu@oracle.com>
Subject: [PATCH v2] RDS: fix rds-ping spinlock recursion
Date: Tue, 09 Oct 2012 12:57:27 +0800
Message-ID: <5073AEB7.9060309@oracle.com>
Reply-To: jeff.liu@oracle.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>,
	davem@davemloft.net, Dan Carpenter <dan.carpenter@oracle.com>,
	James Morris <james.l.morris@oracle.com>,
	netdev@vger.kernel.org
To: rds-devel@oss.oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:22788 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750952Ab2JIE6o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2012 00:58:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

This is the revised patch for fixing rds-ping spinlock recursion according to Venkat's suggestions.

RDS ping/pong over TCP feature has been broken for years(2.6.39 to 3.6.0) since we
have to set TCP cork and call kernel_sendmsg() between ping/pong which both need to
lock "struct sock *sk". However, this lock has already been hold before rds_tcp_data_ready()
callback is triggerred. As a result, we always facing spinlock resursion which would resulting
in system panic.

Given that RDS ping is only used to test the connectivity and not for serious performance measurements,
we can queue the pong transmit to rds_wq as a delayed response.

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
CC: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
CC: David S. Miller <davem@davemloft.net>
CC: James Morris <james.l.morris@oracle.com>
Signed-off-by: Jie Liu <jeff.liu@oracle.com>
---
 net/rds/send.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/rds/send.c b/net/rds/send.c
index 96531d4..88eace5 100644
--- a/net/rds/send.c
+++ b/net/rds/send.c
@@ -1122,7 +1122,7 @@ rds_send_pong(struct rds_connection *conn, __be16 dport)
 	rds_stats_inc(s_send_pong);
 
 	if (!test_bit(RDS_LL_SEND_FULL, &conn->c_flags))
-		rds_send_xmit(conn);
+		queue_delayed_work(rds_wq, &conn->c_send_w, 0);
 
 	rds_message_put(rm);
 	return 0;
-- 
1.7.9.5
