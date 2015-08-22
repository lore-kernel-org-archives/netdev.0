From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [PATCH 07/14] RDS: add a sock_destruct callback debug aid
Date: Sat, 22 Aug 2015 15:45:28 -0700
Message-ID: <1440283535-4800-8-git-send-email-santosh.shilimkar@oracle.com>
References: <1440283535-4800-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	ssantosh@kernel.org,
	Santosh Shilimkar <santosh.shilimkar@oracle.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440283535-4800-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This helps to detect the accidental processes/apps trying to destroy
the RDS socket which they are sharing with other processes/apps.

Reviewed-by: Ajaykumar Hotchandani <ajaykumar.hotchandani@oracle.com>
Signed-off-by: Santosh Shilimkar <ssantosh@kernel.org>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 net/rds/af_rds.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/net/rds/af_rds.c b/net/rds/af_rds.c
index 896834c..a2f28a6 100644
--- a/net/rds/af_rds.c
+++ b/net/rds/af_rds.c
@@ -438,6 +438,14 @@ static const struct proto_ops rds_proto_ops = {
 	.sendpage =	sock_no_sendpage,
 };
 
+static void rds_sock_destruct(struct sock *sk)
+{
+	struct rds_sock *rs = rds_sk_to_rs(sk);
+
+	WARN_ON((&rs->rs_item != rs->rs_item.next ||
+		 &rs->rs_item != rs->rs_item.prev));
+}
+
 static int __rds_create(struct socket *sock, struct sock *sk, int protocol)
 {
 	struct rds_sock *rs;
@@ -445,6 +453,7 @@ static int __rds_create(struct socket *sock, struct sock *sk, int protocol)
 	sock_init_data(sock, sk);
 	sock->ops		= &rds_proto_ops;
 	sk->sk_protocol		= protocol;
+	sk->sk_destruct		= rds_sock_destruct;
 
 	rs = rds_sk_to_rs(sk);
 	spin_lock_init(&rs->rs_lock);
-- 
1.9.1
