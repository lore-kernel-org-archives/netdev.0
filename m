From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [REVISED] [PATCH] ethtool v4: add autoneg advertise feature
Date: Tue, 05 Sep 2006 08:10:16 -0700
Message-ID: <20060905151016.8244.16888.stgit@jtkirshe-sled.jf.intel.com>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Cc: John Rociak <john.ronciak@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:33980 "EHLO
	orsmga102-1.jf.intel.com") by vger.kernel.org with ESMTP
	id S965082AbWIEPK0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Sep 2006 11:10:26 -0400
To: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


adds the ability to change the advertised speed and duplex for a network interface.  Previously, a network interface was only able to advertise all supported speed's and duplex's, or one individual speed and duplex.  The feature allows the user to choose which supported speed's and duplex's to advertise by using the hex value.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>

---

 ethtool.8 |   24 ++++++++++++++++++++++++
 ethtool.c |   12 +++++++++++-
 2 files changed, 35 insertions(+), 1 deletions(-)

diff --git a/ethtool.8 b/ethtool.8
index 888a7d8..679f6bc 100644
--- a/ethtool.8
+++ b/ethtool.8
@@ -176,6 +176,8 @@ ethtool \- Display or change ethernet ca
 .B2 duplex half full
 .B4 port tp aui bnc mii fibre
 .B2 autoneg on off
+.RB [ advertise
+.IR N ]
 .RB [ phyad
 .IR N ]
 .B2 xcvr internal external
@@ -327,6 +329,28 @@ Select device port.
 Specify if autonegotiation is enabled. In the usual case it is, but might
 cause some problems with some network devices, so you can turn it off.
 .TP
+.BI advertise \ N
+Set the speed and duplex advertised by autonegotiation.  The argument is
+a hexidecimal value using one or a combination of the following values:
+.RS
+.PD 0
+.TP 3
+.BR "0x01" "    10 Half"
+.TP 3
+.BR "0x02" "    10 Full"
+.TP 3
+.BR "0x04" "    100 Half"
+.TP 3
+.BR "0x08" "    100 Full"
+.TP 3
+.BR "0x10" "    1000 Half" "(not supported by IEEE standards)"
+.TP 3
+.BR "0x20" "    1000 Full"
+.TP 3
+.BR "0x3F" "    Auto"
+.PD
+.RE
+.TP
 .BI phyad \ N
 PHY address.
 .TP
diff --git a/ethtool.c b/ethtool.c
index 87e22ab..b7f189a 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -99,6 +99,7 @@ static struct option {
 		"		[ duplex half|full ]\n"
 		"		[ port tp|aui|bnc|mii|fibre ]\n"
 		"		[ autoneg on|off ]\n"
+		"		[ advertise %%x ]\n"
 		"		[ phyad %%d ]\n"
 		"		[ xcvr internal|external ]\n"
 		"		[ wol p|u|m|b|a|g|s|d... ]\n"
@@ -549,6 +550,15 @@ static void parse_cmdline(int argc, char
 					show_usage(1);
 				}
 				break;
+			} else if (!strcmp(argp[i], "advertise")) {
+				gset_changed = 1;
+				i += 1;
+				if (i >= argc)
+					show_usage(1);
+				advertising_wanted = strtol(argp[i], NULL, 16);
+				if (advertising_wanted < 0)
+					show_usage(1);
+				break;
 			} else if (!strcmp(argp[i], "phyad")) {
 				gset_changed = 1;
 				i += 1;
@@ -601,7 +611,7 @@ static void parse_cmdline(int argc, char
 		}
 	}
 
-	if (autoneg_wanted == AUTONEG_ENABLE){
+	if ((autoneg_wanted == AUTONEG_ENABLE) && (advertising_wanted < 0)) {
 		if (speed_wanted == SPEED_10 && duplex_wanted == DUPLEX_HALF)
 			advertising_wanted = ADVERTISED_10baseT_Half;
 		else if (speed_wanted == SPEED_10 &&
