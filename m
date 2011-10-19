From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH RFC 0/2] Add extended pause query capability
Date: Wed, 19 Oct 2011 21:05:15 +0100
Message-ID: <1319054716.2829.55.camel@bwh-desktop>
References: <1318625642-9668-1-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:30262 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753376Ab1JSUFT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2011 16:05:19 -0400
In-Reply-To: <1318625642-9668-1-git-send-email-mcarlson@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-10-14 at 13:54 -0700, Matt Carlson wrote:
> The current implementation of get_pauseparam allows userspace to query the
> flow control configuration, but not the flow control status.  This patchset
> defines a new ethtool_pauseparamext structure and adds a new
> get_pauseparamext ethtool callback to support it.  The new facilities allow
> the driver to report both config and status in the same query.
> 
> Please note that Ben Hutchings' suggestion to deduce the flow control settings
> through the 'advertising' and 'lp_advertising' from ETHTOOL_GSET was considered,
> but rejected because there was no way to know if the flow control
> advertisements reported were valid.

If a driver sets the lp_advertising field and if AN has been successful
then that field must be non-zero.  If a driver does not set the field
then it must be zero (since the ethtool core initialises the structure
to zero).

If you're saying that some drivers may set lp_advertising but not
include the Pause/Asym_Pause flags, those drivers should be fixed.
However, so far as I can see, lp_advertising is only set by mdio, mii
and sfc - and in all those places I did cover pause advertising flags.

The following patch for ethtool should DTRT without any kernel changes;
can you test it?

One oddity of pause AN is that we cannot really advertise that we want
RX-only.  If the settings are autoneg on, rx on, tx off then AN may
result in bidirectional usage.  I'm not sure whether 'TX negotiated'
should then be reported as 'on' (strictly correct) or 'off' (actual
usage - hopefully).

Ben.

---
From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 19 Oct 2011 20:52:12 +0100
Subject: [PATCH ethtool] ethtool: Report pause frame autonegotiation result

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
