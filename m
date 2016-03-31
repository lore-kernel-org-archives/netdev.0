From: shamir rabinovitch <shamir.rabinovitch@oracle.com>
Subject: [PATCH v2] rds: rds-stress show all zeros after few minutes
Date: Thu, 31 Mar 2016 02:29:22 -0400
Message-ID: <1459405762-29778-1-git-send-email-shamir.rabinovitch@oracle.com>
Cc: davem@davemloft.net, shamir.rabinovitch@oracle.com
To: rds-devel@oss.oracle.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:36753 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753530AbcCaOdO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2016 10:33:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Issue can be seen on platforms that use 8K and above page size
while rds fragment size is 4K. On those platforms single page is
shared between 2 or more rds fragments. Each fragment has its own
offset and rds congestion map code need to take this offset to account.
Not taking this offset to account lead to reading the data fragment
as congestion map fragment and hang of the rds transmit due to far
congestion map corruption.

Signed-off-by: shamir rabinovitch <shamir.rabinovitch@oracle.com>

Reviewed-by: Wengang Wang <wen.gang.wang@oracle.com>
Reviewed-by: Ajaykumar Hotchandani <ajaykumar.hotchandani@oracle.com>
Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Tested-by: Anand Bibhuti <anand.bibhuti@oracle.com>
---
 net/rds/ib_recv.c |    2 +-
 net/rds/iw_recv.c |    2 +-
 net/rds/page.c    |    5 +++--
 3 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/rds/ib_recv.c b/net/rds/ib_recv.c
index 977fb86..abc8cc8 100644
--- a/net/rds/ib_recv.c
+++ b/net/rds/ib_recv.c
@@ -796,7 +796,7 @@ static void rds_ib_cong_recv(struct rds_connection *conn,
 
 		addr = kmap_atomic(sg_page(&frag->f_sg));
 
-		src = addr + frag_off;
+		src = addr + frag->f_sg.offset + frag_off;
 		dst = (void *)map->m_page_addrs[map_page] + map_off;
 		for (k = 0; k < to_copy; k += 8) {
 			/* Record ports that became uncongested, ie
diff --git a/net/rds/iw_recv.c b/net/rds/iw_recv.c
index a66d179..62a1738 100644
--- a/net/rds/iw_recv.c
+++ b/net/rds/iw_recv.c
@@ -585,7 +585,7 @@ static void rds_iw_cong_recv(struct rds_connection *conn,
 
 		addr = kmap_atomic(frag->f_page);
 
-		src = addr + frag_off;
+		src = addr +  frag->f_offset + frag_off;
 		dst = (void *)map->m_page_addrs[map_page] + map_off;
 		for (k = 0; k < to_copy; k += 8) {
 			/* Record ports that became uncongested, ie
diff --git a/net/rds/page.c b/net/rds/page.c
index 5a14e6d..715cbaa 100644
--- a/net/rds/page.c
+++ b/net/rds/page.c
@@ -135,8 +135,9 @@ int rds_page_remainder_alloc(struct scatterlist *scat, unsigned long bytes,
 			if (rem->r_offset != 0)
 				rds_stats_inc(s_page_remainder_hit);
 
-			rem->r_offset += bytes;
-			if (rem->r_offset == PAGE_SIZE) {
+			/* some hw (e.g. sparc) require aligned memory */
+			rem->r_offset += ALIGN(bytes, 8);
+			if (rem->r_offset >= PAGE_SIZE) {
 				__free_page(rem->r_page);
 				rem->r_page = NULL;
 			}
-- 
1.7.1
