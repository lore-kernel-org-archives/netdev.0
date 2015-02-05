From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCHv2] rds: Make rds_message_copy_from_user() return 0 on success.
Date: Thu, 5 Feb 2015 17:41:43 -0500
Message-ID: <20150205224143.GD28883@oracle.com>
References: <20150205202050.GH5811@oracle.com>
 <20150205215845.GT29656@ZenIV.linux.org.uk>
 <20150205220734.GC28883@oracle.com>
 <20150205222301.GU29656@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rds-devel@oss.oracle.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, sowmini.varadhan@oracle.com,
	viro@zeniv.linux.org.uk
To: chien.yen@oracle.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150205222301.GU29656@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Commit 083735f4b01b ("rds: switch rds_message_copy_from_user() to iov_iter")
breaks rds_message_copy_from_user() semantics on success, and causes it
to return nbytes copied, when it should return 0.  This commit fixes that bug.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
changes from v1: incorporate Al.Viro comment. 

 net/rds/message.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/rds/message.c b/net/rds/message.c
index 5a21e6f..756c737 100644
--- a/net/rds/message.c
+++ b/net/rds/message.c
@@ -266,7 +266,7 @@ struct rds_message *rds_message_map_pages(unsigned long *page_addrs, unsigned in
 
 int rds_message_copy_from_user(struct rds_message *rm, struct iov_iter *from)
 {
-	unsigned long to_copy;
+	unsigned long to_copy, nbytes;
 	unsigned long sg_off;
 	struct scatterlist *sg;
 	int ret = 0;
@@ -293,9 +293,9 @@ int rds_message_copy_from_user(struct rds_message *rm, struct iov_iter *from)
 				sg->length - sg_off);
 
 		rds_stats_add(s_copy_from_user, to_copy);
-		ret = copy_page_from_iter(sg_page(sg), sg->offset + sg_off,
-					  to_copy, from);
-		if (ret != to_copy)
+		nbytes = copy_page_from_iter(sg_page(sg), sg->offset + sg_off,
+					     to_copy, from);
+		if (nbytes != to_copy)
 			return -EFAULT;
 
 		sg_off += to_copy;
-- 
1.7.1
