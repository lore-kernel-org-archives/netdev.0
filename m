From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next] RDS-TCP: Reset tcp callbacks if re-using an
 outgoing socket in rds_tcp_accept_one()
Date: Sun, 11 Oct 2015 16:49:44 -0400
Message-ID: <20151011204944.GB14646@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, rds-devel@oss.oracle.com,
	ajaykumar.hotchandani@oracle.com, igor.maximov@oracle.com,
	santosh.shilimkar@oracle.com
To: sowmini.varadhan@oracle.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Consider the following "duelling syn" sequence between two peers A and B:
        	A		B
        	SYN1     -->
        	    	<--	SYN2
        	SYN2ACK  -->

Note that the SYN/ACK has already been sent out by TCP before
rds_tcp_accept_one() gets invoked as part of callbacks.

If the inet_addr(A) is numerically less than inet_addr(B),
the arbitration scheme in rds_tcp_accept_one() will prefer the
TCP connection triggered by SYN1, and will send a CLOSE for the
SYN2 (just after the SYN2ACK was sent).

Since B also follows the same arbitration scheme, it will send the SYN-ACK
for SYN1 that will set up a healthy ESTABLISHED connection on both sides.
B will also get a  CLOSE for SYN2, which should result in the cleanup
of the TCP state machine for SYN2, but it should not trigger any
stale RDS-TCP callbacks (such as ->writespace, ->state_change etc),
that would disrupt the progress of the SYN2 based RDS-TCP  connection.

Thus the arbitration scheme in rds_tcp_accept_one() should restore
rds_tcp callbacks for the winner before setting them up for the
new accept socket, and also make sure that conn->c_outgoing
is set to 0 so that we do not trigger any reconnect attempts on the
passive side of the tcp socket in the future, in conformance with
commit c82ac7e69efe ("net/rds: RDS-TCP: only initiate reconnect attempt
on outgoing TCP socket.")

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 net/rds/tcp_listen.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/rds/tcp_listen.c b/net/rds/tcp_listen.c
index 1d90240..0936a4a 100644
--- a/net/rds/tcp_listen.c
+++ b/net/rds/tcp_listen.c
@@ -125,6 +125,9 @@ int rds_tcp_accept_one(struct socket *sock)
 		new_sock = NULL;
 		ret = 0;
 		goto out;
+	} else if (rs_tcp->t_sock) {
+		rds_tcp_restore_callbacks(rs_tcp->t_sock, rs_tcp);
+		conn->c_outgoing = 0;
 	}
 
 	rds_conn_transition(conn, RDS_CONN_DOWN, RDS_CONN_CONNECTING);
-- 
1.7.1
