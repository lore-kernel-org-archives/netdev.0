From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 5/5] ethtool: Use named flag support to update
 extended offload flags
Date: Fri, 25 Jun 2010 15:50:07 +0100
Message-ID: <1277477408.2094.10.camel@achroite.uk.solarflarecom.com>
References: <1277477027.2094.2.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:11829 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755183Ab0FYOuK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jun 2010 10:50:10 -0400
In-Reply-To: <1277477027.2094.2.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 ethtool.c |   70 ++++++++++--------------------------------------------------
 1 files changed, 12 insertions(+), 58 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index a70cd03..4073745 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -277,10 +277,9 @@ static int off_sg_wanted = -1;
 static int off_tso_wanted = -1;
 static int off_ufo_wanted = -1;
 static int off_gso_wanted = -1;
-static int off_lro_wanted = -1;
+static u32 off_flags_wanted = 0;
+static u32 off_flags_unwanted = 0;
 static int off_gro_wanted = -1;
-static int off_ntuple_wanted = -1;
-static int off_rxhash_wanted = -1;
 
 static struct ethtool_pauseparam epause;
 static int gpause_changed = 0;
@@ -419,10 +418,13 @@ static struct cmdline_info cmdline_offload[] = {
 	{ "tso", CMDL_BOOL, &off_tso_wanted, NULL },
 	{ "ufo", CMDL_BOOL, &off_ufo_wanted, NULL },
 	{ "gso", CMDL_BOOL, &off_gso_wanted, NULL },
-	{ "lro", CMDL_BOOL, &off_lro_wanted, NULL },
+	{ "lro", CMDL_FLAG, &off_flags_wanted, NULL,
+	  ETH_FLAG_LRO, &off_flags_unwanted },
 	{ "gro", CMDL_BOOL, &off_gro_wanted, NULL },
-	{ "ntuple", CMDL_BOOL, &off_ntuple_wanted, NULL },
-	{ "rxhash", CMDL_BOOL, &off_rxhash_wanted, NULL },
+	{ "ntuple", CMDL_FLAG, &off_flags_wanted, NULL,
+	  ETH_FLAG_NTUPLE, &off_flags_unwanted },
+	{ "rxhash", CMDL_FLAG, &off_flags_wanted, NULL,
+	  ETH_FLAG_RXHASH, &off_flags_unwanted },
 };
 
 static struct cmdline_info cmdline_pause[] = {
@@ -2191,7 +2193,7 @@ static int do_soffload(int fd, struct ifreq *ifr)
 			return 90;
 		}
 	}
-	if (off_lro_wanted >= 0) {
+	if (off_flags_wanted || off_flags_unwanted) {
 		changed = 1;
 		eval.cmd = ETHTOOL_GFLAGS;
 		eval.data = 0;
@@ -2203,14 +2205,12 @@ static int do_soffload(int fd, struct ifreq *ifr)
 		}
 
 		eval.cmd = ETHTOOL_SFLAGS;
-		if (off_lro_wanted == 1)
-			eval.data |= ETH_FLAG_LRO;
-		else
-			eval.data &= ~ETH_FLAG_LRO;
+		eval.data = ((eval.data & ~off_flags_unwanted) |
+			     off_flags_wanted);
 
 		err = ioctl(fd, SIOCETHTOOL, ifr);
 		if (err) {
-			perror("Cannot set large receive offload settings");
+			perror("Cannot set device flag settings");
 			return 92;
 		}
 	}
@@ -2225,52 +2225,6 @@ static int do_soffload(int fd, struct ifreq *ifr)
 			return 93;
 		}
 	}
-	if (off_ntuple_wanted >= 0) {
-		changed = 1;
-		eval.cmd = ETHTOOL_GFLAGS;
-		eval.data = 0;
-		ifr->ifr_data = (caddr_t)&eval;
-		err = ioctl(fd, SIOCETHTOOL, ifr);
-		if (err) {
-			perror("Cannot get device flag settings");
-			return 91;
-		}
-
-		eval.cmd = ETHTOOL_SFLAGS;
-		if (off_ntuple_wanted == 1)
-			eval.data |= ETH_FLAG_NTUPLE;
-		else
-			eval.data &= ~ETH_FLAG_NTUPLE;
-
-		err = ioctl(fd, SIOCETHTOOL, ifr);
-		if (err) {
-			perror("Cannot set n-tuple filter settings");
-			return 93;
-		}
-	}
-	if (off_rxhash_wanted >= 0) {
-		changed = 1;
-		eval.cmd = ETHTOOL_GFLAGS;
-		eval.data = 0;
-		ifr->ifr_data = (caddr_t)&eval;
-		err = ioctl(fd, SIOCETHTOOL, ifr);
-		if (err) {
-			perror("Cannot get device flag settings");
-			return 91;
-		}
-
-		eval.cmd = ETHTOOL_SFLAGS;
-		if (off_rxhash_wanted)
-			eval.data |= ETH_FLAG_RXHASH;
-		else
-			eval.data &= ~ETH_FLAG_RXHASH;
-
-		err = ioctl(fd, SIOCETHTOOL, ifr);
-		if (err) {
-			perror("Cannot set receive hash settings");
-			return 93;
-		}
-	}
 
 	if (!changed) {
 		fprintf(stdout, "no offload settings changed\n");
-- 
1.6.2.5

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

