From: Alexander Kochetkov <al.kochet@gmail.com>
Subject: [PATCH 1/2] net/smsc911x: Fix rare soft reset timeout issue due to PHY power-down mode
Date: Thu, 13 Nov 2014 05:26:19 +0400
Message-ID: <1415841980-14250-1-git-send-email-al.kochet@gmail.com>
Cc: steve.glendinning@shawell.net,
	Alexander Kochetkov <al.kochet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f44.google.com ([209.85.215.44]:57622 "EHLO
	mail-la0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753136AbaKMB0b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2014 20:26:31 -0500
Received: by mail-la0-f44.google.com with SMTP id hz20so2297965lab.3
        for <netdev@vger.kernel.org>; Wed, 12 Nov 2014 17:26:30 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch affect SMSC LAN generation 4 chips with integrated PHY (LAN9221).

It is possible that PHY could enter power-down mode (ENERGYON clear),
between ENERGYON bit check in smsc911x_phy_disable_energy_detect and SRST
bit set in smsc911x_soft_reset. This could happen, for example, if someone
disconnect ethernet cable between the checks. The PHY in a power-down mode
would prevent the MAC portion of chip to be software reseted.

Initially found by code review, confirmed later using test case.

This is low probability issue, and in order to reproduce it you have to
run the script:

while true; do
	ifconfig eth0 down
	ifconfig eth0 up || break
done

While the script is running you have to plug/unplug ethernet cable many
times (using gpio controlled ethernet switch, for example) until get:

[ 4516.477783] ADDRCONF(NETDEV_UP): eth0: link is not ready
[ 4516.512207] smsc911x smsc911x.0: eth0: SMSC911x/921x identified at 0xce006000, IRQ: 336
[ 4516.524658] ADDRCONF(NETDEV_UP): eth0: link is not ready
[ 4516.559082] smsc911x smsc911x.0: eth0: SMSC911x/921x identified at 0xce006000, IRQ: 336
[ 4516.571990] ADDRCONF(NETDEV_UP): eth0: link is not ready
ifconfig: SIOCSIFFLAGS: Input/output error

The patch was reviewed by Steve Glendinning and Microchip Team.

Signed-off-by: Alexander Kochetkov <al.kochet@gmail.com>
Acked-by: Steve Glendinning <steve.glendinning@shawell.net>
---
 drivers/net/ethernet/smsc/smsc911x.c |    8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index 8564f23..c657184 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -1356,12 +1356,8 @@ static int smsc911x_phy_disable_energy_detect(struct smsc911x_data *pdata)
 		return rc;
 	}
 
-	/*
-	 * If energy is detected the PHY is already awake so is not necessary
-	 * to disable the energy detect power-down mode.
-	 */
-	if ((rc & MII_LAN83C185_EDPWRDOWN) &&
-	    !(rc & MII_LAN83C185_ENERGYON)) {
+	/* Only disable if energy detect mode is already enabled */
+	if (rc & MII_LAN83C185_EDPWRDOWN) {
 		/* Disable energy detect mode for this SMSC Transceivers */
 		rc = phy_write(pdata->phy_dev, MII_LAN83C185_CTRL_STATUS,
 			       rc & (~MII_LAN83C185_EDPWRDOWN));
-- 
1.7.9.5
