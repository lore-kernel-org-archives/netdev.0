From: Shamir Rabinovitch <shamir.rabinovitch@oracle.com>
Subject: [PATCH v3 2/2] RDS: fix congestion map corruption for PAGE_SIZE > 8k
Date: Sun,  3 Apr 2016 08:24:04 -0400
Message-ID: <1459686244-14939-2-git-send-email-shamir.rabinovitch@oracle.com>
References: <1459686244-14939-1-git-send-email-shamir.rabinovitch@oracle.com>
Cc: davem@davemloft.net, shamir.rabinovitch@oracle.com
To: rds-devel@oss.oracle.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:38790 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753607AbcDCMYU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Apr 2016 08:24:20 -0400
In-Reply-To: <1459686244-14939-1-git-send-email-shamir.rabinovitch@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sparc64 page size is 8k. So single page contain 2 RDS fragments. If
'rds_ib_cong_recv' ignore the RDS fragment offset in to the page it then
read the data fragment as far congestion map update and lead to
corruption of the RDS connection far congestion map.

This patch require the below patch for Sparc64 platforms:
001f8f8 RDS: fix "Kernel unaligned access" on sparc64

Signed-off-by: Shamir Rabinovitch <shamir.rabinovitch@oracle.com>

Reviewed-by: Wengang Wang <wen.gang.wang@oracle.com>
Reviewed-by: Ajaykumar Hotchandani <ajaykumar.hotchandani@oracle.com>
Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Tested-by: Anand Bibhuti <anand.bibhuti@oracle.com>
---
 net/rds/ib_recv.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

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
-- 
1.7.1
