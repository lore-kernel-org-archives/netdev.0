From: Andy Gospodarek <andy@greyhouse.net>
Subject: [net-2.6 PATCH] bonding: fix broken multicast with round-robin mode
Date: Thu, 25 Mar 2010 17:40:33 -0400
Message-ID: <20100325214033.GA28741@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lhh@redhat.com, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49233 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751426Ab0CYVkm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Mar 2010 17:40:42 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Round-robin (mode 0) does nothing to ensure that any multicast traffic
originally destined for the host will continue to arrive at the host when
the link that sent the IGMP join or membership report goes down.  One of
the benefits of absolute round-robin transmit.

Keeping track of subscribed multicast groups for each slave did not seem
like a good use of resources, so I decided to simply send on the
curr_active slave of the bond (typically the first enslaved device that
is up).  This makes failover management simple as IGMP membership
reports only need to be sent when the curr_active_slave changes.  I
tested this patch and it appears to work as expected.

Originally reported by Lon Hohberger <lhh@redhat.com>.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
CC: Lon Hohberger <lhh@redhat.com>
CC: Jay Vosburgh <fubar@us.ibm.com>

---
 drivers/net/bonding/bond_main.c |   34 ++++++++++++++++++++++++++--------
 1 files changed, 26 insertions(+), 8 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 430c022..0b38455 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1235,6 +1235,11 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
 			write_lock_bh(&bond->curr_slave_lock);
 		}
 	}
+
+	/* resend IGMP joins since all were sent on curr_active_slave */
+	if (bond->params.mode == BOND_MODE_ROUNDROBIN) {
+		bond_resend_igmp_join_requests(bond);
+	}
 }
 
 /**
@@ -4138,22 +4143,35 @@ static int bond_xmit_roundrobin(struct sk_buff *skb, struct net_device *bond_dev
 	struct bonding *bond = netdev_priv(bond_dev);
 	struct slave *slave, *start_at;
 	int i, slave_no, res = 1;
+	struct iphdr *iph = ip_hdr(skb);
 
 	read_lock(&bond->lock);
 
 	if (!BOND_IS_OK(bond))
 		goto out;
-
 	/*
-	 * Concurrent TX may collide on rr_tx_counter; we accept that
-	 * as being rare enough not to justify using an atomic op here
+	 * Start with the curr_active_slave that joined the bond as the
+	 * default for sending IGMP traffic.  For failover purposes one
+	 * needs to maintain some consistency for the interface that will
+	 * send the join/membership reports.  The curr_active_slave found
+	 * will send all of this type of traffic.
 	 */
-	slave_no = bond->rr_tx_counter++ % bond->slave_cnt;
+	if ((skb->protocol == htons(ETH_P_IP)) &&
+	    (iph->protocol == htons(IPPROTO_IGMP))) {
+		slave = bond->curr_active_slave;
+	} else {
+		/*
+		 * Concurrent TX may collide on rr_tx_counter; we accept
+		 * that as being rare enough not to justify using an
+		 * atomic op here.
+		 */
+		slave_no = bond->rr_tx_counter++ % bond->slave_cnt;
 
-	bond_for_each_slave(bond, slave, i) {
-		slave_no--;
-		if (slave_no < 0)
-			break;
+		bond_for_each_slave(bond, slave, i) {
+			slave_no--;
+			if (slave_no < 0)
+				break;
+		}
 	}
 
 	start_at = slave;
