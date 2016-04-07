From: Shamir Rabinovitch <shamir.rabinovitch@oracle.com>
Subject: [PATCH v4 2/2] RDS: fix congestion map corruption for PAGE_SIZE > 4k
Date: Thu,  7 Apr 2016 07:57:36 -0400
Message-ID: <1460030256-16791-2-git-send-email-shamir.rabinovitch@oracle.com>
References: <1460030256-16791-1-git-send-email-shamir.rabinovitch@oracle.com>
Cc: davem@davemloft.net, shamir.rabinovitch@oracle.com,
	santosh.shilimkar@oracle.com
To: rds-devel@oss.oracle.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:28747 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755418AbcDGL6A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 07:58:00 -0400
In-Reply-To: <1460030256-16791-1-git-send-email-shamir.rabinovitch@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When PAGE_SIZE > 4k single page can contain 2 RDS fragments. If
'rds_ib_cong_recv' ignore the RDS fragment offset in to the page it
then read the data fragment as far congestion map update and lead to
corruption of the RDS connection far congestion map.

Signed-off-by: Shamir Rabinovitch <shamir.rabinovitch@oracle.com>
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
