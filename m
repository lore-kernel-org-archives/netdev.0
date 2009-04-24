From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH] bonding: use ethtool for link checking first
Date: Fri, 24 Apr 2009 13:58:23 +0200
Message-ID: <20090424115823.GD16703@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fubar@us.ibm.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:44118 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753204AbZDXL60 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Apr 2009 07:58:26 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch only changes the order of interfaces to use for checking slave link
status in bond_check_dev_link() to priorize ethtool interface. Should safe some
troubles as ethtool seems to be more supported.

Jirka

Signed-off-by: Jiri Pirko <jpirko@redhat.com>

 drivers/net/bonding/bond_main.c |   26 ++++++++++++--------------
 1 files changed, 12 insertions(+), 14 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 63369b6..e4166ee 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -695,6 +695,18 @@ static int bond_check_dev_link(struct bonding *bond, struct net_device *slave_de
 	if (bond->params.use_carrier)
 		return netif_carrier_ok(slave_dev) ? BMSR_LSTATUS : 0;
 
+	/* Try to get link status using Ethtool first. */
+	if (slave_dev->ethtool_ops) {
+		if (slave_dev->ethtool_ops->get_link) {
+			u32 link;
+
+			link = slave_dev->ethtool_ops->get_link(slave_dev);
+
+			return link ? BMSR_LSTATUS : 0;
+		}
+	}
+
+	/* Ethtool can't be used, fallback to MII ioclts. */
 	ioctl = slave_ops->ndo_do_ioctl;
 	if (ioctl) {
 		/* TODO: set pointer to correct ioctl on a per team member */
@@ -721,20 +733,6 @@ static int bond_check_dev_link(struct bonding *bond, struct net_device *slave_de
 	}
 
 	/*
-	 * Some drivers cache ETHTOOL_GLINK for a period of time so we only
-	 * attempt to get link status from it if the above MII ioctls fail.
-	 */
-	if (slave_dev->ethtool_ops) {
-		if (slave_dev->ethtool_ops->get_link) {
-			u32 link;
-
-			link = slave_dev->ethtool_ops->get_link(slave_dev);
-
-			return link ? BMSR_LSTATUS : 0;
-		}
-	}
-
-	/*
 	 * If reporting, report that either there's no dev->do_ioctl,
 	 * or both SIOCGMIIREG and get_link failed (meaning that we
 	 * cannot report link status).  If not reporting, pretend
