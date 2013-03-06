From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH] 8139too: send NETDEV_CHANGE manually when autoneg is disabled
Date: Wed,  6 Mar 2013 20:06:24 +0100
Message-ID: <1362596784-19443-1-git-send-email-vfalico@redhat.com>
Cc: wfp5p@virginia.edu, jasowang@redhat.com, junchangwang@gmail.com,
	greearb@candelatech.com, ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56097 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752910Ab3CFTF4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Mar 2013 14:05:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When setting autoneg off (with any additional parameters, like
speed/duplex), 8139too doesn't do an interface reset, and thus doesn't
notify anyone that its speed/duplex might have changed (bonding and bridge
will not see the speed changes, per example).

Verify if we've force_media and send notification manually, so that the
listeners have a chance to see the changes. It's quite ugly, however I
don't see anything better.

Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/ethernet/realtek/8139too.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/realtek/8139too.c b/drivers/net/ethernet/realtek/8139too.c
index 1276ac7..96ee18c 100644
--- a/drivers/net/ethernet/realtek/8139too.c
+++ b/drivers/net/ethernet/realtek/8139too.c
@@ -2393,6 +2393,11 @@ static int rtl8139_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	spin_lock_irq(&tp->lock);
 	rc = mii_ethtool_sset(&tp->mii, cmd);
 	spin_unlock_irq(&tp->lock);
+	/*
+	 * we don't restart on autoneg off, so notify manually
+	 */
+	if (tp->mii.force_media)
+		call_netdevice_notifiers(NETDEV_CHANGE, dev);
 	return rc;
 }
 
-- 
1.7.1
