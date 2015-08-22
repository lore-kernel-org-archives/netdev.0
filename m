From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [PATCH 13/14] RDS: return EMSGSIZE for oversize requests before processing/queueing
Date: Sat, 22 Aug 2015 15:45:34 -0700
Message-ID: <1440283535-4800-14-git-send-email-santosh.shilimkar@oracle.com>
References: <1440283535-4800-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	ssantosh@kernel.org, Mukesh Kacker <mukesh.kacker@oracle.com>,
	Santosh Shilimkar <santosh.shilimkar@oracle.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440283535-4800-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mukesh Kacker <mukesh.kacker@oracle.com>

rds_send_queue_rm() allows for the "current datagram" being queued
to exceed SO_SNDBUF thresholds by checking bytes queued without
counting in length of current datagram. (Since sk_sndbuf is set
to twice requested SO_SNDBUF value as a kernel heuristic this
is usually fine!)

If this "current datagram" squeezing past the threshold is itself
many times the size of the sk_sndbuf threshold itself then even
twice the SO_SNDBUF does not save us and it gets queued but
cannot be transmitted. Threads block and deadlock and device
becomes unusable. The check for this datagram not exceeding
SNDBUF thresholds (EMSGSIZE) is not done on this datagram as
that check is only done if queueing attempt fails.
(Datagrams that follow this datagram fail queueing attempts, go
through the check and eventually trip EMSGSIZE error but zero
length datagrams silently fail!)

This fix moves the check for datagrams exceeding SNDBUF limits
before any processing or queueing is attempted and returns EMSGSIZE
early in the rds_sndmsg() code. This change also ensures that all
datagrams get checked for exceeding SNDBUF/sk_sndbuf size limits
and the large datagrams that exceed those limits do not get to
rds_send_queue_rm() code for processing.

Signed-off-by: Mukesh Kacker <mukesh.kacker@oracle.com>
Signed-off-by: Santosh Shilimkar <ssantosh@kernel.org>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 net/rds/send.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/net/rds/send.c b/net/rds/send.c
index b0fe412..c2667bf 100644
--- a/net/rds/send.c
+++ b/net/rds/send.c
@@ -1015,6 +1015,11 @@ int rds_sendmsg(struct socket *sock, struct msghdr *msg, size_t payload_len)
 		goto out;
 	}
 
+	if (payload_len > rds_sk_sndbuf(rs)) {
+		ret = -EMSGSIZE;
+		goto out;
+	}
+
 	/* size of rm including all sgs */
 	ret = rds_rm_size(msg, payload_len);
 	if (ret < 0)
@@ -1086,11 +1091,7 @@ int rds_sendmsg(struct socket *sock, struct msghdr *msg, size_t payload_len)
 	while (!rds_send_queue_rm(rs, conn, rm, rs->rs_bound_port,
 				  dport, &queued)) {
 		rds_stats_inc(s_send_queue_full);
-		/* XXX make sure this is reasonable */
-		if (payload_len > rds_sk_sndbuf(rs)) {
-			ret = -EMSGSIZE;
-			goto out;
-		}
+
 		if (nonblock) {
 			ret = -EAGAIN;
 			goto out;
-- 
1.9.1
