From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] rds: prevent BUG_ON triggering on congestion map updates
Date: Wed,  2 Mar 2011 11:28:22 -0500
Message-ID: <1299083302-5168-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>, rds-devel@oss.oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:43897 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753827Ab1CBQ2o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 11:28:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Recently had this bug halt reported to me:

kernel BUG at net/rds/send.c:329!
Oops: Exception in kernel mode, sig: 5 [#1]
SMP NR_CPUS=1024 NUMA pSeries
Modules linked in: rds sunrpc ipv6 dm_mirror dm_region_hash dm_log ibmveth sg
ext4 jbd2 mbcache sd_mod crc_t10dif ibmvscsic scsi_transport_srp scsi_tgt
dm_mod [last unloaded: scsi_wait_scan]
NIP: d000000003ca68f4 LR: d000000003ca67fc CTR: d000000003ca8770
REGS: c000000175cab980 TRAP: 0700   Not tainted  (2.6.32-118.el6.ppc64)
MSR: 8000000000029032 <EE,ME,CE,IR,DR>  CR: 44000022  XER: 00000000
TASK = c00000017586ec90[1896] 'krdsd' THREAD: c000000175ca8000 CPU: 0
GPR00: 0000000000000150 c000000175cabc00 d000000003cb7340 0000000000002030
GPR04: ffffffffffffffff 0000000000000030 0000000000000000 0000000000000030
GPR08: 0000000000000001 0000000000000001 c0000001756b1e30 0000000000010000
GPR12: d000000003caac90 c000000000fa2500 c0000001742b2858 c0000001742b2a00
GPR16: c0000001742b2a08 c0000001742b2820 0000000000000001 0000000000000001
GPR20: 0000000000000040 c0000001742b2814 c000000175cabc70 0800000000000000
GPR24: 0000000000000004 0200000000000000 0000000000000000 c0000001742b2860
GPR28: 0000000000000000 c0000001756b1c80 d000000003cb68e8 c0000001742b27b8
NIP [d000000003ca68f4] .rds_send_xmit+0x4c4/0x8a0 [rds]
LR [d000000003ca67fc] .rds_send_xmit+0x3cc/0x8a0 [rds]
Call Trace:
[c000000175cabc00] [d000000003ca67fc] .rds_send_xmit+0x3cc/0x8a0 [rds]
(unreliable)
[c000000175cabd30] [d000000003ca7e64] .rds_send_worker+0x54/0x100 [rds]
[c000000175cabdb0] [c0000000000b475c] .worker_thread+0x1dc/0x3c0
[c000000175cabed0] [c0000000000baa9c] .kthread+0xbc/0xd0
[c000000175cabf90] [c000000000032114] .kernel_thread+0x54/0x70
Instruction dump:
4bfffd50 60000000 60000000 39080001 935f004c f91f0040 41820024 813d017c
7d094a78 7d290074 7929d182 394a0020 <0b090000> 40e2ff68 4bffffa4 39200000
Kernel panic - not syncing: Fatal exception
Call Trace:
[c000000175cab560] [c000000000012e04] .show_stack+0x74/0x1c0 (unreliable)
[c000000175cab610] [c0000000005a365c] .panic+0x80/0x1b4
[c000000175cab6a0] [c00000000002fbcc] .die+0x21c/0x2a0
[c000000175cab750] [c000000000030000] ._exception+0x110/0x220
[c000000175cab910] [c000000000004b9c] program_check_common+0x11c/0x180
--- Exception: 700 at .rds_send_xmit+0x4c4/0x8a0 [rds]
    LR = .rds_send_xmit+0x3cc/0x8a0 [rds]
[c000000175cabd30] [d000000003ca7e64] .rds_send_worker+0x54/0x100 [rds]
[c000000175cabdb0] [c0000000000b475c] .worker_thread+0x1dc/0x3c0
[c000000175cabed0] [c0000000000baa9c] .kthread+0xbc/0xd0
[c000000175cabf90] [c000000000032114] .kernel_thread+0x54/0x70
Rebooting in 180 seconds..

Tracked it down to a flaw in the xmit methods for the loop and ib transports.
Those two transports, when called with an rds message that has the
RDS_FLAG_CONG_BITMAP set, execute a rds_cong_map_updated call and return.  Since
the xmit method requires that the number of bytes sent be returned, and a
congestion map update doesn't really send any data, it just returns the sizeof
an rds_header plus the defined size of the congestion map.  This is problematic
because the caller of these methods (rds_send_xmit), validates that we didn't
send more data than was available in the passed rds_message.  If the return
value from ->xmit() is larger than the remaining data in the message, we bug
halt, which is exactly what we get above.  We could add a check to skip the bug
on check if the RDS_FLAG_CONG_BITMAP flag is set, but I think the check is
otherwise valid, so I've fixed it with this patch, which limits the return value
in the effected transports to not be more than the remainig space in the
rds_message.

Tested successfully by myself to solve the above bug halt.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
Reported-by: Petr Matousek <pmatouse@redhat.com>
CC: "David S. Miller" <davem@davemloft.net>
CC: rds-devel@oss.oracle.com
---
 net/rds/ib_send.c |    5 ++++-
 net/rds/loop.c    |   11 ++++++++---
 2 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/net/rds/ib_send.c b/net/rds/ib_send.c
index 71f373c..c47a511 100644
--- a/net/rds/ib_send.c
+++ b/net/rds/ib_send.c
@@ -551,7 +551,10 @@ int rds_ib_xmit(struct rds_connection *conn, struct rds_message *rm,
 	if (conn->c_loopback
 	    && rm->m_inc.i_hdr.h_flags & RDS_FLAG_CONG_BITMAP) {
 		rds_cong_map_updated(conn->c_fcong, ~(u64) 0);
-		return sizeof(struct rds_header) + RDS_CONG_MAP_BYTES;
+		scat = &rm->data.op_sg[sg];
+		ret = sizeof(struct rds_header) + RDS_CONG_MAP_BYTES;
+		ret = min_t(int, ret, scat->length - conn->c_xmit_data_off);
+		return ret;
 	}
 
 	/* FIXME we may overallocate here */
diff --git a/net/rds/loop.c b/net/rds/loop.c
index aeec1d4..bca6761 100644
--- a/net/rds/loop.c
+++ b/net/rds/loop.c
@@ -61,10 +61,15 @@ static int rds_loop_xmit(struct rds_connection *conn, struct rds_message *rm,
 			 unsigned int hdr_off, unsigned int sg,
 			 unsigned int off)
 {
+	struct scatterlist *sgp = &rm->data.op_sg[sg];
+	int ret = sizeof(struct rds_header) +
+			be32_to_cpu(rm->m_inc.i_hdr.h_len);
+
 	/* Do not send cong updates to loopback */
 	if (rm->m_inc.i_hdr.h_flags & RDS_FLAG_CONG_BITMAP) {
 		rds_cong_map_updated(conn->c_fcong, ~(u64) 0);
-		return sizeof(struct rds_header) + RDS_CONG_MAP_BYTES;
+		ret = min_t(int, ret, sgp->length - conn->c_xmit_data_off);
+		goto out;
 	}
 
 	BUG_ON(hdr_off || sg || off);
@@ -80,8 +85,8 @@ static int rds_loop_xmit(struct rds_connection *conn, struct rds_message *rm,
 			    NULL);
 
 	rds_inc_put(&rm->m_inc);
-
-	return sizeof(struct rds_header) + be32_to_cpu(rm->m_inc.i_hdr.h_len);
+out:
+	return ret;
 }
 
 /*
-- 
1.7.4

