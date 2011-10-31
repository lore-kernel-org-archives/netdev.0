From: Matthijs Kooijman <matthijs@stdin.nl>
Subject: [PATCH] vlan: Don't propagate flag changes on down interfaces.
Date: Mon, 31 Oct 2011 15:53:13 +0100
Message-ID: <1320072793-16490-1-git-send-email-matthijs@stdin.nl>
References: <20111031134411.GG14392@login.drsnuggles.stderr.nl>
Cc: Matthijs Kooijman <matthijs@stdin.nl>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 84-245-11-97.dsl.cambrium.nl ([84.245.11.97]:60878 "EHLO
	grubby.stderr.nl" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933175Ab1JaP3H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2011 11:29:07 -0400
In-Reply-To: <20111031134411.GG14392@login.drsnuggles.stderr.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When (de)configuring a vlan interface, the IFF_ALLMULTI ans IFF_PROMISC
flags are cleared or set on the underlying interface. So, if these flags
are changed on a vlan interface that is not up, the flags underlying
interface might be set or cleared twice.

Only propagating flag changes when a device is up makes sure this does
not happen. It also makes sure that an underlying device is not set to
promiscuous or allmulti mode for a vlan device that is down.

Signed-off-by: Matthijs Kooijman <matthijs@stdin.nl>
---
 net/8021q/vlan_dev.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 9d40a07..0e72689 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -470,10 +470,12 @@ static void vlan_dev_change_rx_flags(struct net_device *dev, int change)
 {
 	struct net_device *real_dev = vlan_dev_info(dev)->real_dev;
 
-	if (change & IFF_ALLMULTI)
-		dev_set_allmulti(real_dev, dev->flags & IFF_ALLMULTI ? 1 : -1);
-	if (change & IFF_PROMISC)
-		dev_set_promiscuity(real_dev, dev->flags & IFF_PROMISC ? 1 : -1);
+	if (dev->flags & IFF_UP) {
+		if (change & IFF_ALLMULTI)
+			dev_set_allmulti(real_dev, dev->flags & IFF_ALLMULTI ? 1 : -1);
+		if (change & IFF_PROMISC)
+			dev_set_promiscuity(real_dev, dev->flags & IFF_PROMISC ? 1 : -1);
+	}
 }
 
 static void vlan_dev_set_rx_mode(struct net_device *vlan_dev)
-- 
1.7.7
