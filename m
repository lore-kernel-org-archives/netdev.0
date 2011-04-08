From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [ethtool PATCH 2/2] Add support for ESP as a separate protocol from AH
Date: Fri, 08 Apr 2011 15:12:39 -0700
Message-ID: <20110408221239.26893.36898.stgit@gitlad.jf.intel.com>
References: <20110408221135.26893.50092.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jeffrey.t.kirsher@intel.com, bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:46341 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757800Ab1DHWMn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Apr 2011 18:12:43 -0400
In-Reply-To: <20110408221135.26893.50092.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change is meant to split out ESP from AH.  Currently they are present
as both a combined value, and two separate values.  In order to try and
support eventually splitting the two out into separate values this change
makes it so that ESP can be called out separately in ethtool.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

 ethtool.8.in |    8 +++++---
 ethtool.c    |   21 ++++++++++++++++-----
 2 files changed, 21 insertions(+), 8 deletions(-)

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
index 32df0ee..1ebf562 100644
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
@@ -785,6 +784,8 @@ static int rxflow_str_to_type(const char *str)
 		flow_type = UDP_V4_FLOW;
 	else if (!strcmp(str, "ah4"))
 		flow_type = AH_ESP_V4_FLOW;
+	else if (!strcmp(str, "esp4"))
+		flow_type = ESP_V4_FLOW;
 	else if (!strcmp(str, "sctp4"))
 		flow_type = SCTP_V4_FLOW;
 	else if (!strcmp(str, "tcp6"))
@@ -793,6 +794,8 @@ static int rxflow_str_to_type(const char *str)
 		flow_type = UDP_V6_FLOW;
 	else if (!strcmp(str, "ah6"))
 		flow_type = AH_ESP_V6_FLOW;
+	else if (!strcmp(str, "esp6"))
+		flow_type = ESP_V6_FLOW;
 	else if (!strcmp(str, "sctp6"))
 		flow_type = SCTP_V6_FLOW;
 	else if (!strcmp(str, "ether"))
@@ -1941,8 +1944,12 @@ static int dump_rxfhash(int fhash, u64 val)
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
@@ -1953,8 +1960,12 @@ static int dump_rxfhash(int fhash, u64 val)
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

