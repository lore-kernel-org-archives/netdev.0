From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH 3/3] net/rds Add getsockopt support for SO_RDS_TRANSPORT
Date: Fri, 29 May 2015 17:28:09 -0400
Message-ID: <97d3a190b13e112f9b3e28eb372b897c734897f4.1432927392.git.sowmini.varadhan@oracle.com>
References: <cover.1432927392.git.sowmini.varadhan@oracle.com>
Cc: chien.yen@oracle.com, davem@davemloft.net,
	rds-devel@oss.oracle.com, ajaykumar.hotchandani@oracle.com,
	igor.maximov@oracle.com,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1432927392.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1432927392.git.sowmini.varadhan@oracle.com>
References: <cover.1432927392.git.sowmini.varadhan@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The currently attached transport for a PF_RDS socket may be obtained
from user space by invoking getsockopt(2) using the SO_RDS_TRANSPORT
option at the SOL_RDS level. The integer optval returned will be one
of the RDS_TRANS_* constants defined in linux/rds.h.


Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 net/rds/af_rds.c |   14 ++++++++++++++
 1 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/net/rds/af_rds.c b/net/rds/af_rds.c
index 0487744..2ad9032 100644
--- a/net/rds/af_rds.c
+++ b/net/rds/af_rds.c
@@ -339,6 +339,7 @@ static int rds_getsockopt(struct socket *sock, int level, int optname,
 {
 	struct rds_sock *rs = rds_sk_to_rs(sock->sk);
 	int ret = -ENOPROTOOPT, len;
+	int trans;
 
 	if (level != SOL_RDS)
 		goto out;
@@ -364,6 +365,19 @@ static int rds_getsockopt(struct socket *sock, int level, int optname,
 		else
 			ret = 0;
 		break;
+	case SO_RDS_TRANSPORT:
+		if (len < sizeof(int)) {
+			ret = -EINVAL;
+			break;
+		}
+		trans = (rs->rs_transport ? rs->rs_transport->t_type :
+			 RDS_TRANS_NONE); /* unbound */
+		if (put_user(trans, (int __user *)optval) ||
+		    put_user(sizeof(int), optlen))
+			ret = -EFAULT;
+		else
+			ret = 0;
+		break;
 	default:
 		break;
 	}
-- 
1.7.1
