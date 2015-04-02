From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCHv2 3/6] rds: check for excessive looping in rds_send_xmit
Date: Thu,  2 Apr 2015 10:19:37 -0400
Message-ID: <5f877b89716358c7a08272275979b5e039ca1c29.1427983908.git.sowmini.varadhan@oracle.com>
References: <cover.1427983908.git.sowmini.varadhan@oracle.com>
Cc: chien.yen@oracle.com, davem@davemloft.net,
	rds-devel@oss.oracle.com, agrover@redhat.com, clm@fb.com,
	zab@zabbo.net, ajaykumar.hotchandani@oracle.com,
	sergei.shtylyov@cogentembedded.com,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1427983908.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1427983908.git.sowmini.varadhan@oracle.com>
References: <cover.1427983908.git.sowmini.varadhan@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Original patch by Andy Grover

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 net/rds/send.c |   13 +++++++++++++
 1 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/net/rds/send.c b/net/rds/send.c
index 44672be..b1741a2 100644
--- a/net/rds/send.c
+++ b/net/rds/send.c
@@ -140,6 +140,7 @@ int rds_send_xmit(struct rds_connection *conn)
 	struct scatterlist *sg;
 	int ret = 0;
 	LIST_HEAD(to_be_dropped);
+	int same_rm = 0;
 
 restart:
 
@@ -177,6 +178,18 @@ int rds_send_xmit(struct rds_connection *conn)
 
 		rm = conn->c_xmit_rm;
 
+		if (!rm) {
+			same_rm = 0;
+		} else {
+			same_rm++;
+			if (same_rm >= 4096) {
+				printk_ratelimited(KERN_ERR "RDS: Stuck rm\n");
+				cond_resched();
+				ret = -EAGAIN;
+				break;
+			}
+		}
+
 		/*
 		 * If between sending messages, we can send a pending congestion
 		 * map update.
-- 
1.7.1
