From: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
Subject: [PATCH] rds: prevent BUG_ON triggered on congestion update to
 loopback
Date: Mon, 25 Nov 2013 09:47:34 +0300
Message-ID: <1385167442-6997-1-git-send-email-venkat.x.venkatsubra@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>,
	Honggang Li <honli@redhat.com>,
	Josh Hunt <joshhunt00@gmail.com>,
	Bang Nguyen <bang.nguyen@oracle.com>
To: rds-devel@oss.oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:34285 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750793Ab3KYGrs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Nov 2013 01:47:48 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>

After congestion update on a local connection, when rds_ib_xmit returns
less bytes than that are there in the message, rds_send_xmit calls
back rds_ib_xmit with an offset that causes BUG_ON(off & RDS_FRAG_SIZE)
to trigger.

Reported-by: Josh Hunt <joshhunt00@gmail.com>
Tested-by: Honggang Li <honli@redhat.com>
Acked-by: Bang Nguyen <bang.nguyen@oracle.com>
Signed-off-by: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
 net/rds/ib_send.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/rds/ib_send.c b/net/rds/ib_send.c
index e590949..37be6e2 100644
--- a/net/rds/ib_send.c
+++ b/net/rds/ib_send.c
@@ -552,9 +552,8 @@ int rds_ib_xmit(struct rds_connection *conn, struct rds_message *rm,
 	    && rm->m_inc.i_hdr.h_flags & RDS_FLAG_CONG_BITMAP) {
 		rds_cong_map_updated(conn->c_fcong, ~(u64) 0);
 		scat = &rm->data.op_sg[sg];
-		ret = sizeof(struct rds_header) + RDS_CONG_MAP_BYTES;
-		ret = min_t(int, ret, scat->length - conn->c_xmit_data_off);
-		return ret;
+		ret = max_t(int, RDS_CONG_MAP_BYTES, scat->length);
+		return sizeof(struct rds_header) + ret;
 	}
 
 	/* FIXME we may overallocate here */
-- 
1.7.6
