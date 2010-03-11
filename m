From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH 01/13] RDS: Do not BUG() on error returned from ib_post_send
Date: Thu, 11 Mar 2010 15:49:55 -0800
Message-ID: <1268351407-7394-2-git-send-email-andy.grover@oracle.com>
References: <1268351407-7394-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:56757 "EHLO
	rcsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754464Ab0CKXu6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 18:50:58 -0500
Received: from acsinet15.oracle.com (acsinet15.oracle.com [141.146.126.227])
	by rcsinet12.oracle.com (Switch-3.4.2/Switch-3.4.2) with ESMTP id o2BNouUQ001372
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 11 Mar 2010 23:50:58 GMT
In-Reply-To: <1268351407-7394-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

BUGging on a runtime error code should be avoided. This
patch also eliminates all other BUG()s that have no real
reason to exist.

Signed-off-by: Andy Grover <andy.grover@oracle.com>
---
 net/rds/ib_recv.c        |    4 ++--
 net/rds/ib_send.c        |    7 +++----
 net/rds/iw_recv.c        |    4 ++--
 net/rds/iw_send.c        |    3 +--
 net/rds/rdma_transport.c |    3 +--
 5 files changed, 9 insertions(+), 12 deletions(-)

diff --git a/net/rds/ib_recv.c b/net/rds/ib_recv.c
index 04dc0d3..c338881 100644
--- a/net/rds/ib_recv.c
+++ b/net/rds/ib_recv.c
@@ -468,8 +468,8 @@ static void rds_ib_send_ack(struct rds_ib_connection *ic, unsigned int adv_credi
 		set_bit(IB_ACK_REQUESTED, &ic->i_ack_flags);
 
 		rds_ib_stats_inc(s_ib_ack_send_failure);
-		/* Need to finesse this later. */
-		BUG();
+
+		rds_ib_conn_error(ic->conn, "sending ack failed\n");
 	} else
 		rds_ib_stats_inc(s_ib_ack_sent);
 }
diff --git a/net/rds/ib_send.c b/net/rds/ib_send.c
index a10fab6..f380c3f 100644
--- a/net/rds/ib_send.c
+++ b/net/rds/ib_send.c
@@ -574,8 +574,7 @@ int rds_ib_xmit(struct rds_connection *conn, struct rds_message *rm,
 		rds_ib_send_grab_credits(ic, 0, &posted, 1, RDS_MAX_ADV_CREDIT - adv_credits);
 		adv_credits += posted;
 		BUG_ON(adv_credits > 255);
-	} else if (ic->i_rm != rm)
-		BUG();
+	}
 
 	send = &ic->i_sends[pos];
 	first = send;
@@ -714,8 +713,8 @@ add_header:
 			ic->i_rm = prev->s_rm;
 			prev->s_rm = NULL;
 		}
-		/* Finesse this later */
-		BUG();
+
+		rds_ib_conn_error(ic->conn, "ib_post_send failed\n");
 		goto out;
 	}
 
diff --git a/net/rds/iw_recv.c b/net/rds/iw_recv.c
index 54af7d6..337e4e5 100644
--- a/net/rds/iw_recv.c
+++ b/net/rds/iw_recv.c
@@ -468,8 +468,8 @@ static void rds_iw_send_ack(struct rds_iw_connection *ic, unsigned int adv_credi
 		set_bit(IB_ACK_REQUESTED, &ic->i_ack_flags);
 
 		rds_iw_stats_inc(s_iw_ack_send_failure);
-		/* Need to finesse this later. */
-		BUG();
+
+		rds_iw_conn_error(ic->conn, "sending ack failed\n");
 	} else
 		rds_iw_stats_inc(s_iw_ack_sent);
 }
diff --git a/net/rds/iw_send.c b/net/rds/iw_send.c
index 1379e9d..52182ff 100644
--- a/net/rds/iw_send.c
+++ b/net/rds/iw_send.c
@@ -616,8 +616,7 @@ int rds_iw_xmit(struct rds_connection *conn, struct rds_message *rm,
 		rds_iw_send_grab_credits(ic, 0, &posted, 1, RDS_MAX_ADV_CREDIT - adv_credits);
 		adv_credits += posted;
 		BUG_ON(adv_credits > 255);
-	} else if (ic->i_rm != rm)
-		BUG();
+	}
 
 	send = &ic->i_sends[pos];
 	first = send;
diff --git a/net/rds/rdma_transport.c b/net/rds/rdma_transport.c
index 9ece910..31f9c72 100644
--- a/net/rds/rdma_transport.c
+++ b/net/rds/rdma_transport.c
@@ -109,8 +109,7 @@ int rds_rdma_cm_event_handler(struct rdma_cm_id *cm_id,
 
 	default:
 		/* things like device disconnect? */
-		printk(KERN_ERR "unknown event %u\n", event->event);
-		BUG();
+		printk(KERN_ERR "RDS: unknown event %u!\n", event->event);
 		break;
 	}
 
-- 
1.6.3.3

