From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH RFC net-next] Cancel any pending connection attempts before taking down connection
Date: Mon, 27 Feb 2017 17:44:00 -0800
Message-ID: <1488246240-159171-1-git-send-email-sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1050.oracle.com ([141.146.126.70]:27614 "EHLO
        aserp1050.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751486AbdCAABc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Feb 2017 19:01:32 -0500
Received: from aserp1040.oracle.com (aserp1040.oracle.com [141.146.126.69])
        by aserp1050.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id v1SL5kRR023482
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
        for <netdev@vger.kernel.org>; Tue, 28 Feb 2017 21:05:47 GMT
To: sowmini.varadhan@oracle.com, dvyukov@google.com,
        netdev@vger.kernel.org
To: sowmini.varadhan@oracle.com
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a test patch being supplied for a trial run on syzkaller.

Explicitly cancel the workq before releasing resources that
will allow netns deletion, so that the connect request does
not trip up on a use-after free of the netns afterward.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Reported-by: Dmitry Vyukov <dvyukov@google.com>
---
 net/rds/tcp.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/rds/tcp.c b/net/rds/tcp.c
index 57bb523..2568eb1 100644
--- a/net/rds/tcp.c
+++ b/net/rds/tcp.c
@@ -509,6 +509,8 @@ static void rds_tcp_conn_paths_destroy(struct rds_connection *conn)
 
 	for (i = 0; i < RDS_MPATH_WORKERS; i++) {
 		cp = &conn->c_path[i];
+		if (cancel_delayed_work_sync(&cp->cp_conn_w))
+			pr_info("cancelled on path %d\n", i);
 		tc = cp->cp_transport_data;
 		if (!tc->t_sock)
 			continue;
-- 
1.7.1
