From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH 2/3] net/rds: Add setsockopt support for SO_RDS_TRANSPORT
Date: Fri, 29 May 2015 17:28:08 -0400
Message-ID: <ceeb05168eaca18e9d09e41fba927c0559496f86.1432927392.git.sowmini.varadhan@oracle.com>
References: <cover.1432927392.git.sowmini.varadhan@oracle.com>
Cc: chien.yen@oracle.com, davem@davemloft.net,
	rds-devel@oss.oracle.com, ajaykumar.hotchandani@oracle.com,
	igor.maximov@oracle.com,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:35538 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756904AbbE2V2q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2015 17:28:46 -0400
In-Reply-To: <cover.1432927392.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1432927392.git.sowmini.varadhan@oracle.com>
References: <cover.1432927392.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

An application may deterministically attach the underlying transport for
a PF_RDS socket by invoking setsockopt(2) with the SO_RDS_TRANSPORT
option at the SOL_RDS level. The integer argument to setsockopt must be
one of the RDS_TRANS_* transport types, e.g., RDS_TRANS_TCP. The option
must be specified before invoking bind(2) on the socket, and may only
be used once on the socket. An attempt to set the option on a bound
socket, or to invoke the option after a successful SO_RDS_TRANSPORT
attachment, will return EOPNOTSUPP.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 net/rds/af_rds.c    |   27 +++++++++++++++++++++++++++
 net/rds/bind.c      |    4 ++++
 net/rds/rds.h       |    1 +
 net/rds/transport.c |   21 +++++++++++++++++++++
 4 files changed, 53 insertions(+), 0 deletions(-)

diff --git a/net/rds/af_rds.c b/net/rds/af_rds.c
index 3d83641..0487744 100644
--- a/net/rds/af_rds.c
+++ b/net/rds/af_rds.c
@@ -270,6 +270,28 @@ static int rds_cong_monitor(struct rds_sock *rs, char __user *optval,
 	return ret;
 }
 
+static int rds_set_transport(struct rds_sock *rs, char __user *optval,
+			     int optlen)
+{
+	int t_type;
+
+	if (rs->rs_transport)
+		return -EOPNOTSUPP; /* previously attached to transport */
+
+	if (optlen != sizeof(int))
+		return -EINVAL;
+
+	if (copy_from_user(&t_type, (int __user *)optval, sizeof(t_type)))
+		return -EFAULT;
+
+	if (t_type < 0 || t_type >= RDS_TRANS_COUNT)
+		return -EINVAL;
+
+	rs->rs_transport = rds_trans_get(t_type);
+
+	return rs->rs_transport ? 0 : -ENOPROTOOPT;
+}
+
 static int rds_setsockopt(struct socket *sock, int level, int optname,
 			  char __user *optval, unsigned int optlen)
 {
@@ -300,6 +322,11 @@ static int rds_setsockopt(struct socket *sock, int level, int optname,
 	case RDS_CONG_MONITOR:
 		ret = rds_cong_monitor(rs, optval, optlen);
 		break;
+	case SO_RDS_TRANSPORT:
+		lock_sock(sock->sk);
+		ret = rds_set_transport(rs, optval, optlen);
+		release_sock(sock->sk);
+		break;
 	default:
 		ret = -ENOPROTOOPT;
 	}
diff --git a/net/rds/bind.c b/net/rds/bind.c
index a2e6562..4ebd29c 100644
--- a/net/rds/bind.c
+++ b/net/rds/bind.c
@@ -181,6 +181,10 @@ int rds_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 	if (ret)
 		goto out;
 
+	if (rs->rs_transport) { /* previously bound */
+		ret = 0;
+		goto out;
+	}
 	trans = rds_trans_get_preferred(sin->sin_addr.s_addr);
 	if (!trans) {
 		ret = -EADDRNOTAVAIL;
diff --git a/net/rds/rds.h b/net/rds/rds.h
index 76db508..a33fb4a 100644
--- a/net/rds/rds.h
+++ b/net/rds/rds.h
@@ -798,6 +798,7 @@ struct rds_transport *rds_trans_get_preferred(__be32 addr);
 void rds_trans_put(struct rds_transport *trans);
 unsigned int rds_trans_stats_info_copy(struct rds_info_iterator *iter,
 				       unsigned int avail);
+struct rds_transport *rds_trans_get(int t_type);
 int rds_trans_init(void);
 void rds_trans_exit(void);
 
diff --git a/net/rds/transport.c b/net/rds/transport.c
index 7f2ac4f..8b4a6cd 100644
--- a/net/rds/transport.c
+++ b/net/rds/transport.c
@@ -101,6 +101,27 @@ struct rds_transport *rds_trans_get_preferred(__be32 addr)
 	return ret;
 }
 
+struct rds_transport *rds_trans_get(int t_type)
+{
+	struct rds_transport *ret = NULL;
+	struct rds_transport *trans;
+	unsigned int i;
+
+	down_read(&rds_trans_sem);
+	for (i = 0; i < RDS_TRANS_COUNT; i++) {
+		trans = transports[i];
+
+		if (trans && trans->t_type == t_type &&
+		    (!trans->t_owner || try_module_get(trans->t_owner))) {
+			ret = trans;
+			break;
+		}
+	}
+	up_read(&rds_trans_sem);
+
+	return ret;
+}
+
 /*
  * This returns the number of stats entries in the snapshot and only
  * copies them using the iter if there is enough space for them.  The
-- 
1.7.1
