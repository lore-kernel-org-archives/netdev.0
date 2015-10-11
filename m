From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next] RDS: Invoke ->laddr_check() in rds_bind() for
 explicitly bound transports.
Date: Sun, 11 Oct 2015 16:46:03 -0400
Message-ID: <20151011204603.GA14646@oracle.com>
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


The IP address passed to rds_bind() should be vetted by the
transport's ->laddr_check() for a previously bound transport.
This needs to be done to avoid cases where, for example,
the application has asked for an IB transport,
but the IP address passed to bind is only usable on
ethernet interfaces.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 net/rds/bind.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/net/rds/bind.c b/net/rds/bind.c
index bc6b93e..6192566 100644
--- a/net/rds/bind.c
+++ b/net/rds/bind.c
@@ -196,7 +196,14 @@ int rds_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 		goto out;
 
 	if (rs->rs_transport) { /* previously bound */
-		ret = 0;
+		trans = rs->rs_transport;
+		if (trans->laddr_check(sock_net(sock->sk),
+				       sin->sin_addr.s_addr) != 0) {
+			ret = -ENOPROTOOPT;
+			rds_remove_bound(rs);
+		} else {
+			ret = 0;
+		}
 		goto out;
 	}
 	trans = rds_trans_get_preferred(sock_net(sock->sk),
-- 
1.7.1
