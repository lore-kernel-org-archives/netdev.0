From: Simon Horman <horms@verge.net.au>
Subject: [PATCH] rfc: ethtool: early-orphan control (user-space)
Date: Sat, 11 Dec 2010 13:13:58 +0900
Message-ID: <1292040838-10579-1-git-send-email-horms@verge.net.au>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Simon Horman <horms@verge.net.au>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:37032 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753676Ab0LKEOD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 23:14:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Early orphaning is an optimisation which avoids unnecessary cache misses by
orphaning an skb just before it is handed to a device for transmit thus
avoiding the case where the orphaning occurs on a different CPU.

In the case of bonded devices this has the unfortunate side-effect of
breaking down flow control allowing a socket to send UDP packets as fast as
the CPU will allow. This is particularly undesirable in virtualised
network environments.

This patch introduces ethtool control of early orphaning.
It remains on by default by it now may be disabled on a per-interface basis.

I have implemented this as a generic option using a generic flag.
I am unsure if any aspect of this approach is acceptable.

A patch for the kernel accompanies this patch.

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 ethtool-copy.h |    1 +
 ethtool.8      |    1 +
 ethtool.c      |   54 ++++++++++++++++++++++++++++++++++++++++++++++++++++--
 3 files changed, 54 insertions(+), 2 deletions(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index 75c3ae7..9ed758f 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -314,6 +314,7 @@ enum ethtool_flags {
 	ETH_FLAG_LRO		= (1 << 15),	/* LRO is enabled */
 	ETH_FLAG_NTUPLE		= (1 << 27),	/* N-tuple filters enabled */
 	ETH_FLAG_RXHASH		= (1 << 28),
+	ETH_FLAG_EARLY_ORPHAN	= (1 << 29),
 };
 
 /* The following structures are for supporting RX network flow
diff --git a/ethtool.8 b/ethtool.8
index 1760924..6384681 100644
--- a/ethtool.8
+++ b/ethtool.8
@@ -209,6 +209,7 @@ ethtool \- Display or change ethernet card settings
 .BI msglvl \ type
 .A1 on off
 .RB ...]
+.B2 early-orphan on off
 
 .B ethtool \-n
 .I ethX
diff --git a/ethtool.c b/ethtool.c
index 239912b..579b4e4 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -163,7 +163,8 @@ static struct option {
 		"		[ xcvr internal|external ]\n"
 		"		[ wol p|u|m|b|a|g|s|d... ]\n"
 		"		[ sopass %x:%x:%x:%x:%x:%x ]\n"
-		"		[ msglvl %d | msglvl type on|off ... ]\n" },
+		"		[ msglvl %d | msglvl type on|off ... ]\n"
+		"		[ early-orphan on|off ]\n" },
     { "-a", "--show-pause", MODE_GPAUSE, "Show pause options" },
     { "-A", "--pause", MODE_SPAUSE, "Set pause options",
       "		[ autoneg on|off ]\n"
@@ -411,6 +412,10 @@ static int msglvl_changed;
 static u32 msglvl_wanted = 0;
 static u32 msglvl_mask = 0;
 
+static u32 generic_flags_changed;
+static u32 generic_flags_wanted = 0;
+static u32 generic_flags_mask = 0;
+
 static enum {
 	ONLINE=0,
 	OFFLINE,
@@ -608,6 +613,11 @@ static struct cmdline_info cmdline_msglvl[] = {
 	  NETIF_MSG_WOL, &msglvl_mask },
 };
 
+static struct cmdline_info cmdline_generic_flags[] = {
+	{ "early-orphan", CMDL_FLAG, &generic_flags_wanted, NULL,
+	  ETH_FLAG_EARLY_ORPHAN, &generic_flags_mask },
+};
+
 static long long
 get_int_range(char *str, int base, long long min, long long max)
 {
@@ -1125,7 +1135,13 @@ static void parse_cmdline(int argc, char **argp)
 				}
 				break;
 			}
-			show_usage(1);
+			parse_generic_cmdline(
+					argc, argp, i,
+					&generic_flags_changed,
+					cmdline_generic_flags,
+					ARRAY_SIZE(cmdline_generic_flags));
+			i = argc;
+			break;
 		}
 	}
 
@@ -2498,6 +2514,18 @@ static int do_gset(int fd, struct ifreq *ifr)
 		perror("Cannot get link status");
 	}
 
+	edata.cmd = ETHTOOL_GFLAGS;
+	ifr->ifr_data = (caddr_t)&edata;
+	err = ioctl(fd, SIOCETHTOOL, ifr);
+	if (err) {
+		perror("Cannot get device flags");
+	} else {
+		int eo = (edata.data & ETH_FLAG_EARLY_ORPHAN) != 0;
+		fprintf(stdout, "	Early Orphan: %s\n",
+			eo ? "on" : "off");
+		allfail = 0;
+	}
+
 	if (allfail) {
 		fprintf(stdout, "No data available\n");
 		return 75;
@@ -2623,6 +2651,28 @@ static int do_sset(int fd, struct ifreq *ifr)
 		}
 	}
 
+	if (generic_flags_changed) {
+		printf("generic flags changed\n");
+		struct ethtool_value edata;
+
+		edata.cmd = ETHTOOL_GFLAGS;
+		edata.data = 0;
+		ifr->ifr_data = (caddr_t)&edata;
+		err = ioctl(fd, SIOCETHTOOL, ifr);
+		if (err) {
+			perror("Cannot get device flag settings");
+			return 91;
+		}
+
+		edata.cmd = ETHTOOL_SFLAGS;
+		edata.data = ((edata.data & ~generic_flags_mask) |
+			      generic_flags_wanted);
+
+		err = ioctl(fd, SIOCETHTOOL, ifr);
+		if (err)
+			perror("Cannot set device flag settings");
+	}
+
 	return 0;
 }
 
-- 
1.7.2.3

