From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 01/21] Report pause frame autonegotiation result
Date: Tue, 1 Nov 2011 23:13:38 +0000
Message-ID: <1320189218.2758.31.camel@bwh-desktop>
References: <1320186901.2758.30.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-net-drivers@solarflare.com>,
	Matt Carlson <mcarlson@broadcom.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:37718 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752553Ab1KAXNn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2011 19:13:43 -0400
In-Reply-To: <1320186901.2758.30.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If pause frame autonegotiation is enabled and the driver reports the
link partner's advertising flags, report the result of autonegotiation.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 ethtool.c |   46 ++++++++++++++++++++++++++++++++++++++++------
 1 files changed, 40 insertions(+), 6 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index a4e8b58..ad2d583 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -1745,7 +1745,7 @@ static int dump_test(struct ethtool_drvinfo *info, struct ethtool_test *test,
 	return rc;
 }
 
-static int dump_pause(void)
+static int dump_pause(u32 advertising, u32 lp_advertising)
 {
 	fprintf(stdout,
 		"Autonegotiate:	%s\n"
@@ -1755,6 +1755,30 @@ static int dump_pause(void)
 		epause.rx_pause ? "on" : "off",
 		epause.tx_pause ? "on" : "off");
 
+	if (lp_advertising) {
+		int an_rx = 0, an_tx = 0;
+
+		/* Work out negotiated pause frame usage per
+		 * IEEE 802.3-2005 table 28B-3.
+		 */
+		if (advertising & lp_advertising & ADVERTISED_Pause) {
+			an_tx = 1;
+			an_rx = 1;
+		} else if (advertising & lp_advertising &
+			   ADVERTISED_Asym_Pause) {
+			if (advertising & ADVERTISED_Pause)
+				an_rx = 1;
+			else if (lp_advertising & ADVERTISED_Pause)
+				an_tx = 1;
+		}
+
+		fprintf(stdout,
+			"RX negotiated:	%s\n"
+			"TX negotiated:	%s\n",
+			an_rx ? "on" : "off",
+			an_tx ? "on" : "off");
+	}
+
 	fprintf(stdout, "\n");
 	return 0;
 }
@@ -2051,6 +2075,7 @@ static int do_gdrv(int fd, struct ifreq *ifr)
 
 static int do_gpause(int fd, struct ifreq *ifr)
 {
+	struct ethtool_cmd ecmd;
 	int err;
 
 	fprintf(stdout, "Pause parameters for %s:\n", devname);
@@ -2058,15 +2083,24 @@ static int do_gpause(int fd, struct ifreq *ifr)
 	epause.cmd = ETHTOOL_GPAUSEPARAM;
 	ifr->ifr_data = (caddr_t)&epause;
 	err = send_ioctl(fd, ifr);
-	if (err == 0) {
-		err = dump_pause();
-		if (err)
-			return err;
-	} else {
+	if (err) {
 		perror("Cannot get device pause settings");
 		return 76;
 	}
 
+	if (epause.autoneg) {
+		ecmd.cmd = ETHTOOL_GSET;
+		ifr->ifr_data = (caddr_t)&ecmd;
+		err = send_ioctl(fd, ifr);
+		if (err) {
+			perror("Cannot get device settings");
+			return 1;
+		}
+		dump_pause(ecmd.advertising, ecmd.lp_advertising);
+	} else {
+		dump_pause(0, 0);
+	}
+
 	return 0;
 }
 
-- 
1.7.4.4



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
