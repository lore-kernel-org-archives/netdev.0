From: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
Subject: [PATCH] rds: prevent BUG_ON triggered on congestion update to loopback
Date: Mon,  2 Dec 2013 15:41:39 -0800
Message-ID: <1386027699-30513-1-git-send-email-venkat.x.venkatsubra@oracle.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org, rds-devel@oss.oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:28623 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752847Ab3LBXln (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Dec 2013 18:41:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After congestion update on a local connection, when rds_ib_xmit returns
less bytes than that are there in the message, rds_send_xmit calls
back rds_ib_xmit with an offset that causes BUG_ON(off & RDS_FRAG_SIZE)
to trigger.

For a 4Kb PAGE_SIZE rds_ib_xmit returns min(8240,4096)=4096 when actually
the message contains 8240 bytes. rds_send_xmit thinks there is more to send
and calls rds_ib_xmit again with a data offset "off" of 4096-48(rds header)
=4048 bytes thus hitting the BUG_ON(off & RDS_FRAG_SIZE) [RDS_FRAG_SIZE=4k].

The commit 6094628bfd94323fc1cea05ec2c6affd98c18f7f
"rds: prevent BUG_ON triggering on congestion map updates" introduced
this regression. That change was addressing the triggering of a different
BUG_ON in rds_send_xmit() on PowerPC architecture with 64Kbytes PAGE_SIZE:
 	BUG_ON(ret != 0 &&
    		 conn->c_xmit_sg == rm->data.op_nents);
This was the sequence it was going through:
(rds_ib_xmit)
/* Do not send cong updates to IB loopback */
if (conn->c_loopback
   && rm->m_inc.i_hdr.h_flags & RDS_FLAG_CONG_BITMAP) {
  	rds_cong_map_updated(conn->c_fcong, ~(u64) 0);
    	return sizeof(struct rds_header) + RDS_CONG_MAP_BYTES;
}
rds_ib_xmit returns 8240
rds_send_xmit:
  c_xmit_data_off = 0 + 8240 - 48 (rds header accounted only the first time)
   		 = 8192
  c_xmit_data_off < 65536 (sg->length), so calls rds_ib_xmit again
rds_ib_xmit returns 8240
rds_send_xmit:
  c_xmit_data_off = 8192 + 8240 = 16432, calls rds_ib_xmit again
  and so on (c_xmit_data_off 24672,32912,41152,49392,57632)
rds_ib_xmit returns 8240
On this iteration this sequence causes the BUG_ON in rds_send_xmit:
    while (ret) {
    	tmp = min_t(int, ret, sg->length - conn->c_xmit_data_off);
    	[tmp = 65536 - 57632 = 7904]
    	conn->c_xmit_data_off += tmp;
    	[c_xmit_data_off = 57632 + 7904 = 65536]
    	ret -= tmp;
    	[ret = 8240 - 7904 = 336]
    	if (conn->c_xmit_data_off == sg->length) {
    		conn->c_xmit_data_off = 0;
    		sg++;
    		conn->c_xmit_sg++;
    		BUG_ON(ret != 0 &&
    			conn->c_xmit_sg == rm->data.op_nents);
    		[c_xmit_sg = 1, rm->data.op_nents = 1]

What the current fix does:
Since the congestion update over loopback is not actually transmitted
as a message, all that rds_ib_xmit needs to do is let the caller think
the full message has been transmitted and not return partial bytes.
It will return 8240 (RDS_CONG_MAP_BYTES+48) when PAGE_SIZE is 4Kb.
And 64Kb+48 when page size is 64Kb.

Reported-by: Josh Hunt <joshhunt00@gmail.com>
Tested-by: Honggang Li <honli@redhat.com>
Acked-by: Bang Nguyen <bang.nguyen@oracle.com>
Signed-off-by: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
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
