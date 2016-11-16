From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 1/3] RDS: TCP: set RDS_FLAG_RETRANSMITTED in cp_retrans list
Date: Wed, 16 Nov 2016 13:29:48 -0800
Message-ID: <0e4770a7eae7c49264ce9238dddc542da8e2388a.1478876910.git.sowmini.varadhan@oracle.com>
References: <cover.1478876910.git.sowmini.varadhan@oracle.com>
Cc: santosh.shilimkar@oracle.com, sowmini.varadhan@oracle.com,
        davem@davemloft.net, rds-devel@oss.oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:25959 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933687AbcKPVaB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 16:30:01 -0500
In-Reply-To: <cover.1478876910.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1478876910.git.sowmini.varadhan@oracle.com>
References: <cover.1478876910.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As noted in rds_recv_incoming() sequence numbers on data packets
can decreas for the failover case, and the Rx path is equipped
to recover from this, if the RDS_FLAG_RETRANSMITTED is set
on the rds header of an incoming message with a suspect sequence
number.

The RDS_FLAG_RETRANSMITTED is predicated on the RDS_FLAG_RETRANSMITTED
flag in the rds_message, so make sure the flag is set on messages
queued for retransmission.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 net/rds/tcp_send.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/rds/tcp_send.c b/net/rds/tcp_send.c
index 89d09b4..dcf4742 100644
--- a/net/rds/tcp_send.c
+++ b/net/rds/tcp_send.c
@@ -100,6 +100,9 @@ int rds_tcp_xmit(struct rds_connection *conn, struct rds_message *rm,
 		set_bit(RDS_MSG_HAS_ACK_SEQ, &rm->m_flags);
 		tc->t_last_expected_una = rm->m_ack_seq + 1;
 
+		if (test_bit(RDS_MSG_RETRANSMITTED, &rm->m_flags))
+			rm->m_inc.i_hdr.h_flags |= RDS_FLAG_RETRANSMITTED;
+
 		rdsdebug("rm %p tcp nxt %u ack_seq %llu\n",
 			 rm, rds_tcp_snd_nxt(tc),
 			 (unsigned long long)rm->m_ack_seq);
-- 
1.7.1
