From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [ethtool PATCH 1/6] Add support for ESP as a separate protocol from AH
Date: Thu, 21 Apr 2011 13:40:20 -0700
Message-ID: <20110421204020.23054.60822.stgit@gitlad.jf.intel.com>
References: <20110421202857.23054.63316.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:19694 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754271Ab1DUUkV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Apr 2011 16:40:21 -0400
In-Reply-To: <20110421202857.23054.63316.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change is mostly cosmetic.  NIU had supported AH and ESP seperately.
As such it is possible that a return value of ESP or AH may be returned
for a has request instead of the AH_ESP combined value.  To resolve that
the inputs are combined for AH and ESP into the AH_ESP value and return
values for AH and ESP will display the combined string info.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

 ethtool.8.in |    8 +++++---
 ethtool.c    |   21 ++++++++++++---------
 2 files changed, 17 insertions(+), 12 deletions(-)

diff --git a/ethtool.8.in b/ethtool.8.in
index 714486e..12a1d1d 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -52,7 +52,7 @@
 .\"
 .\"	\(*FL - flow type values
 .\"
-.ds FL \fBtcp4\fP|\fBudp4\fP|\fBah4\fP|\fBsctp4\fP|\fBtcp6\fP|\fBudp6\fP|\fBah6\fP|\fBsctp6\fP
+.ds FL \fBtcp4\fP|\fBudp4\fP|\fBah4\fP|\fBesp4\fP|\fBsctp4\fP|\fBtcp6\fP|\fBudp6\fP|\fBah6\fP|\fBesp6\fP|\fBsctp6\fP
 .\"
 .\"	\(*HO - hash options
 .\"
@@ -572,11 +572,13 @@ nokeep;
 lB	l.
 tcp4	TCP over IPv4
 udp4	UDP over IPv4
-ah4	IPSEC AH/ESP over IPv4
+ah4	IPSEC AH over IPv4
+esp4	IPSEC ESP over IPv4
 sctp4	SCTP over IPv4
 tcp6	TCP over IPv6
 udp6	UDP over IPv6
-ah6	IPSEC AH/ESP over IPv6
+ah6	IPSEC AH over IPv6
+esp6	IPSEC ESP over IPv6
 sctp6	SCTP over IPv6
 .TE
 .TP
diff --git a/ethtool.c b/ethtool.c
index 32df0ee..cfdac65 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -32,7 +32,6 @@
 #include <sys/ioctl.h>
 #include <sys/stat.h>
 #include <stdio.h>
-#include <string.h>
 #include <errno.h>
 #include <net/if.h>
 #include <sys/utsname.h>
@@ -233,15 +232,15 @@ static struct option {
     { "-S", "--statistics", MODE_GSTATS, "Show adapter statistics" },
     { "-n", "--show-nfc", MODE_GNFC, "Show Rx network flow classification "
 		"options",
-		"		[ rx-flow-hash tcp4|udp4|ah4|sctp4|"
-		"tcp6|udp6|ah6|sctp6 ]\n" },
+		"		[ rx-flow-hash tcp4|udp4|ah4|esp4|sctp4|"
+		"tcp6|udp6|ah6|esp6|sctp6 ]\n" },
     { "-f", "--flash", MODE_FLASHDEV, "FILENAME " "Flash firmware image "
     		"from the specified file to a region on the device",
 		"               [ REGION-NUMBER-TO-FLASH ]\n" },
     { "-N", "--config-nfc", MODE_SNFC, "Configure Rx network flow "
 		"classification options",
-		"		[ rx-flow-hash tcp4|udp4|ah4|sctp4|"
-		"tcp6|udp6|ah6|sctp6 m|v|t|s|d|f|n|r... ]\n" },
+		"		[ rx-flow-hash tcp4|udp4|ah4|esp4|sctp4|"
+		"tcp6|udp6|ah6|esp6|sctp6 m|v|t|s|d|f|n|r... ]\n" },
     { "-x", "--show-rxfh-indir", MODE_GRXFHINDIR, "Show Rx flow hash "
 		"indirection" },
     { "-X", "--set-rxfh-indir", MODE_SRXFHINDIR, "Set Rx flow hash indirection",
@@ -783,7 +782,7 @@ static int rxflow_str_to_type(const char *str)
 		flow_type = TCP_V4_FLOW;
 	else if (!strcmp(str, "udp4"))
 		flow_type = UDP_V4_FLOW;
-	else if (!strcmp(str, "ah4"))
+	else if (!strcmp(str, "ah4") || !strcmp(str, "esp4"))
 		flow_type = AH_ESP_V4_FLOW;
 	else if (!strcmp(str, "sctp4"))
 		flow_type = SCTP_V4_FLOW;
@@ -791,7 +790,7 @@ static int rxflow_str_to_type(const char *str)
 		flow_type = TCP_V6_FLOW;
 	else if (!strcmp(str, "udp6"))
 		flow_type = UDP_V6_FLOW;
-	else if (!strcmp(str, "ah6"))
+	else if (!strcmp(str, "ah6") || !strcmp(str, "esp6"))
 		flow_type = AH_ESP_V6_FLOW;
 	else if (!strcmp(str, "sctp6"))
 		flow_type = SCTP_V6_FLOW;
@@ -1941,7 +1940,9 @@ static int dump_rxfhash(int fhash, u64 val)
 		fprintf(stdout, "SCTP over IPV4 flows");
 		break;
 	case AH_ESP_V4_FLOW:
-		fprintf(stdout, "IPSEC AH over IPV4 flows");
+	case AH_V4_FLOW:
+	case ESP_V4_FLOW:
+		fprintf(stdout, "IPSEC AH/ESP over IPV4 flows");
 		break;
 	case TCP_V6_FLOW:
 		fprintf(stdout, "TCP over IPV6 flows");
@@ -1953,7 +1954,9 @@ static int dump_rxfhash(int fhash, u64 val)
 		fprintf(stdout, "SCTP over IPV6 flows");
 		break;
 	case AH_ESP_V6_FLOW:
-		fprintf(stdout, "IPSEC AH over IPV6 flows");
+	case AH_V6_FLOW:
+	case ESP_V6_FLOW:
+		fprintf(stdout, "IPSEC AH/ESP over IPV6 flows");
 		break;
 	default:
 		break;

