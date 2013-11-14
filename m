From: Josh Hunt <johunt@akamai.com>
Subject: [PATCH] rds: fix local ping DoS
Date: Wed, 13 Nov 2013 17:15:43 -0800
Message-ID: <1384391743-9342-1-git-send-email-johunt@akamai.com>
Cc: linux-kernel@vger.kernel.org, jjolly@suse.com, fenlason@redhat.com,
	honli@redhat.com, Josh Hunt <johunt@akamai.com>
To: netdev@vger.kernel.org, venkat.x.venkatsubra@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The rds_ib_xmit function in net/rds/ib_send.c in the Reliable Datagram Sockets
(RDS) protocol implementation allows local users to cause a denial of service
(BUG_ON and kernel panic) by establishing an RDS connection with the source
IP address equal to the IPoIB interface's own IP address, as demonstrated by
rds-ping.

A local unprivileged user could use this flaw to crash the system.

CVE-2012-2372

Reported-by: Honggang Li <honli@redhat.com>
Signed-off-by: Josh Hunt <johunt@akamai.com>
---
 net/rds/ib_send.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/rds/ib_send.c b/net/rds/ib_send.c
index e590949..7920c85 100644
--- a/net/rds/ib_send.c
+++ b/net/rds/ib_send.c
@@ -544,7 +544,7 @@ int rds_ib_xmit(struct rds_connection *conn, struct rds_message *rm,
 	int flow_controlled = 0;
 	int nr_sig = 0;
 
-	BUG_ON(off % RDS_FRAG_SIZE);
+	BUG_ON(!conn->c_loopback && off % RDS_FRAG_SIZE);
 	BUG_ON(hdr_off != 0 && hdr_off != sizeof(struct rds_header));
 
 	/* Do not send cong updates to IB loopback */
-- 
1.7.0.4
