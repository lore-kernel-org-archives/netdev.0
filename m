From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH 2/6] RDS: only use passive connections when addresses match
Date: Thu,  2 Apr 2015 09:50:45 -0400
Message-ID: <25b5d99baee278ade82d725bb80d0a382b2bf654.1427936719.git.sowmini.varadhan@oracle.com>
References: <cover.1427936719.git.sowmini.varadhan@oracle.com>
Cc: chien.yen@oracle.com, davem@davemloft.net,
	rds-devel@oss.oracle.com, agrover@redhat.com, clm@fb.com,
	zab@zabbo.net, ajaykumar.hotchandani@oracle.com,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:44937 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753144AbbDBNvE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 09:51:04 -0400
In-Reply-To: <cover.1427936719.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1427936719.git.sowmini.varadhan@oracle.com>
References: <cover.1427936719.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Passive connections were added for the case where one loopback IB
connection between identical addresses needs another connection to store
the second QP.  Unfortunately, they were also created in the case where
the addesses differ and we already have both QPs.

This lead to a message reordering bug.

- two different IB interfaces and addresses on a machine: A B
- traffic is sent from A to B
- connection from A-B is created, connect request sent
- listening accepts connect request, B-A is created
- traffic flows, next_rx is incremented
- unacked messages exist on the retrans list
- connection A-B is shut down, new connect request sent
- listen sees existing loopback B-A, creates new passive B-A
- retrans messages are sent and delivered because of 0 next_rx

The problem is that the second connection request saw the previously
existing parent connection.  Instead of using it, and using the existing
next_rx_seq state for the traffic between those IPs, it mistakenly
thought that it had to create a passive connection.

We fix this by only using passive connections in the special case where
laddr and faddr match.  In this case we'll only ever have one parent
sending connection requests and one passive connection created as the
listening path sees the existing parent connection which initiated the
request.

Original patch by Zach Brown

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Reviewed-by: Ajaykumar Hotchandani <ajaykumar.hotchandani@oracle.com>
---
 net/rds/connection.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/rds/connection.c b/net/rds/connection.c
index 378c3a6..7952a5b 100644
--- a/net/rds/connection.c
+++ b/net/rds/connection.c
@@ -130,7 +130,7 @@ static struct rds_connection *__rds_conn_create(__be32 laddr, __be32 faddr,
 	rcu_read_lock();
 	conn = rds_conn_lookup(head, laddr, faddr, trans);
 	if (conn && conn->c_loopback && conn->c_trans != &rds_loop_transport &&
-	    !is_outgoing) {
+	    laddr == faddr && !is_outgoing) {
 		/* This is a looped back IB connection, and we're
 		 * called by the code handling the incoming connect.
 		 * We need a second connection object into which we
-- 
1.7.1
