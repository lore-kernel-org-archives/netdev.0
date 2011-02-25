From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [ethtool PATCH 1/4] Add support for ESP as a separate protocol from AH
Date: Fri, 25 Feb 2011 15:48:45 -0800
Message-ID: <20110225234845.8409.67383.stgit@gitlad.jf.intel.com>
References: <20110225233902.8409.74474.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:58509 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756212Ab1BYXsq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Feb 2011 18:48:46 -0500
In-Reply-To: <20110225233902.8409.74474.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change is meant to split out ESP from AH.  Currently they are present
as both a combined value, and two separate values.  In order to try and
support eventually splitting the two out into separate values this change
makes it so that ESP can be called out separately in ethtool.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

 ethtool.8.in |    2 +-
 ethtool.c    |   21 ++++++++++++++++-----
 2 files changed, 17 insertions(+), 6 deletions(-)

diff --git a/ethtool.8.in b/ethtool.8.in
index 133825b..7dec259 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -50,7 +50,7 @@
 .\"
 .\"	\(*FL - flow type values
 .\"
-.ds FL \fBtcp4\fP|\fBudp4\fP|\fBah4\fP|\fBsctp4\fP|\fBtcp6\fP|\fBudp6\fP|\fBah6\fP|\fBsctp6\fP
+.ds FL \fBtcp4\fP|\fBudp4\fP|\fBah4\fP|\fBesp4\fP|\fBsctp4\fP|\fBtcp6\fP|\fBudp6\fP|\fBah6\fP|\fBesp6\fP|\fBsctp6\fP
 .\"
 .\"	\(*HO - hash options
 .\"
diff --git a/ethtool.c b/ethtool.c
index 1afdfe4..14740d5 100644
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
@@ -232,15 +231,15 @@ static struct option {
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
@@ -778,6 +777,8 @@ static int rxflow_str_to_type(const char *str)
 		flow_type = UDP_V4_FLOW;
 	else if (!strcmp(str, "ah4"))
 		flow_type = AH_ESP_V4_FLOW;
+	else if (!strcmp(str, "esp4"))
+		flow_type = ESP_V4_FLOW;
 	else if (!strcmp(str, "sctp4"))
 		flow_type = SCTP_V4_FLOW;
 	else if (!strcmp(str, "tcp6"))
@@ -786,6 +787,8 @@ static int rxflow_str_to_type(const char *str)
 		flow_type = UDP_V6_FLOW;
 	else if (!strcmp(str, "ah6"))
 		flow_type = AH_ESP_V6_FLOW;
+	else if (!strcmp(str, "esp6"))
+		flow_type = ESP_V6_FLOW;
 	else if (!strcmp(str, "sctp6"))
 		flow_type = SCTP_V6_FLOW;
 	else if (!strcmp(str, "ether"))
@@ -1918,8 +1921,12 @@ static int dump_rxfhash(int fhash, u64 val)
 		fprintf(stdout, "SCTP over IPV4 flows");
 		break;
 	case AH_ESP_V4_FLOW:
+	case AH_V4_FLOW:
 		fprintf(stdout, "IPSEC AH over IPV4 flows");
 		break;
+	case ESP_V4_FLOW:
+		fprintf(stdout, "IPSEC ESP over IPV4 flows");
+		break;
 	case TCP_V6_FLOW:
 		fprintf(stdout, "TCP over IPV6 flows");
 		break;
@@ -1930,8 +1937,12 @@ static int dump_rxfhash(int fhash, u64 val)
 		fprintf(stdout, "SCTP over IPV6 flows");
 		break;
 	case AH_ESP_V6_FLOW:
+	case AH_V6_FLOW:
 		fprintf(stdout, "IPSEC AH over IPV6 flows");
 		break;
+	case ESP_V6_FLOW:
+		fprintf(stdout, "IPSEC ESP over IPV6 flows");
+		break;
 	default:
 		break;
 	}

