From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 5/5] Documentation: RDS: Document Multipath RDS (mprds)
Date: Thu, 14 Jul 2016 03:51:05 -0700
Message-ID: <cde6613efcc78ba1a94811ec661defba5ee05464.1468488884.git.sowmini.varadhan@oracle.com>
References: <cover.1468488884.git.sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, rds-devel@oss.oracle.com,
	sowmini.varadhan@oracle.com, santosh.shilimkar@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:42538 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751122AbcGNKv1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2016 06:51:27 -0400
In-Reply-To: <cover.1468488884.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1468488884.git.sowmini.varadhan@oracle.com>
References: <cover.1468488884.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Document the design of mprds, covering a brief description
of the motivation, data-structures and modifications to the
RDS control plane.

Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 Documentation/networking/rds.txt |   55 ++++++++++++++++++++++++++++++++++++++
 1 files changed, 55 insertions(+), 0 deletions(-)

diff --git a/Documentation/networking/rds.txt b/Documentation/networking/rds.txt
index 1366e11..0235ae6 100644
--- a/Documentation/networking/rds.txt
+++ b/Documentation/networking/rds.txt
@@ -365,4 +365,59 @@ The recv path
     handle CMSGs
     return to application
 
+Multipath RDS (mprds)
+=====================
+  Mprds is multipathed-RDS, primarily intended for RDS-over-TCP
+  (though the concept can be extended to other transports). The classical
+  implementation of RDS-over-TCP is implemented by demultiplexing multiple
+  PF_RDS sockets between any 2 endpoints (where endpoint == [IP address,
+  port]) over a single TCP socket between the 2 IP addresses involved. This
+  has the limitation that it ends up funneling multiple RDS flows over a
+  single TCP flow, thus it is
+  (a) upper-bounded to the single-flow bandwidth,
+  (b) suffers from head-of-line blocking for all the RDS sockets.
+
+  Better throughput (for a fixed small packet size, MTU) can be achieved
+  by having multiple TCP/IP flows per rds/tcp connection, i.e., multipathed
+  RDS (mprds).  Each such TCP/IP flow constitutes a path for the rds/tcp
+  connection. RDS sockets will be attached to a path based on some hash
+  (e.g., of local address and RDS port number) and packets for that RDS
+  socket will be sent over the attached path using TCP to segment/reassemble
+  RDS datagrams on that path.
+
+  Multipathed RDS is implemented by splitting the struct rds_connection into
+  a common (to all paths) part, and a per-path struct rds_conn_path. All
+  I/O workqs and reconnect threads are driven from the rds_conn_path.
+  Transports such as TCP that are multipath capable may then set up a
+  TPC socket per rds_conn_path, and this is managed by the transport via
+  the transport privatee cp_transport_data pointer.
+
+  Transports announce themselves as multipath capable by setting the
+  t_mp_capable bit during registration with the rds core module. When the
+  transport is multipath-capable, rds_sendmsg() hashes outgoing traffic
+  across multiple paths. The outgoing hash is computed based on the
+  local address and port that the PF_RDS socket is bound to.
+
+  Additionally, even if the transport is MP capable, we may be
+  peering with some node that does not support mprds, or supports
+  a different number of paths. As a result, the peering nodes need
+  to agree on the number of paths to be used for the connection.
+  This is done by sending out a control packet exchange before the
+  first data packet. The control packet exchange must have completed
+  prior to outgoing hash completion in rds_sendmsg() when the transport
+  is mutlipath capable.
+
+  The control packet is an RDS ping packet (i.e., packet to rds dest
+  port 0) with the ping packet having a rds extension header option  of
+  type RDS_EXTHDR_NPATHS, length 2 bytes, and the value is the
+  number of paths supported by the sender. The "probe" ping packet will
+  get sent from some reserved port, RDS_FLAG_PROBE_PORT (in <linux/rds.h>)
+  The receiver of a ping from RDS_FLAG_PROBE_PORT will thus immediately
+  be able to compute the min(sender_paths, rcvr_paths). The pong
+  sent in response to a probe-ping should contain the rcvr's npaths
+  when the rcvr is mprds-capable.
+
+  If the rcvr is not mprds-capable, the exthdr in the ping will be
+  ignored.  In this case the pong will not have any exthdrs, so the sender
+  of the probe-ping can default to single-path mprds.
 
-- 
1.7.1
