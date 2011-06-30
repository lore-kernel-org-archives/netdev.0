From: "Sebastian =?ISO-8859-1?Q?P=F6hn?=" <sebastian.belden@googlemail.com>
Subject: [PATCH] ethtool : NFC corrections again
Date: Thu, 30 Jun 2011 10:41:20 +0200
Message-ID: <1309423280.15040.2.camel@DENEC1DT0191>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sebastian =?ISO-8859-1?Q?P=F6hn?= <sebastian.poehn@belden.com>
To: Ben Hutchings <bhutchings@solarflare.com>,
	Linux Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:52964 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754539Ab1F3Il3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2011 04:41:29 -0400
Received: by gwaa18 with SMTP id a18so773246gwa.19
        for <netdev@vger.kernel.org>; Thu, 30 Jun 2011 01:41:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch:
# Adds an alias for ip4 called l4data pointing to spi (first 4 Layer 4
bytes)
# [TRIVIAL] Corrects the permutation of dst and src for ethernet
# Suggests to always set the ip_ver field of usr_ip to ETH_RX_NFC_IP4 at
least as long there is no opportunity to use others than IPv4 and there
is no frontend option to enter ip_ver.

Signed-off-by: Sebastian Poehn <sebastian.poehn@belden.com>
---

 ethtool.8.in |    5 +++++
 rxclass.c    |   11 ++++++++---
 2 files changed, 13 insertions(+), 3 deletions(-)

diff --git a/ethtool.8.in b/ethtool.8.in
index 7b1cdf5..0a64d75 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -296,6 +296,7 @@ ethtool \- query or control network driver and
hardware settings
 .BM src\-port
 .BM dst\-port
 .BM spi
+.BM l4data
 .BM vlan\-etype
 .BM vlan
 .BM user\-def
@@ -718,6 +719,10 @@ Specify the value of the security parameter index
field (applicable to
 AH/ESP packets)in the incoming packet to match along with an optional
 mask.  Valid for flow-types ip4, ah4, and esp4.
 .TP
+.BI l4data \ N \\fR\ [\\fPm \ N \\fR]\\fP
+Specify the value of the first 4 Bytes of Layer 4 in the incoming
packet to
+match along with an optional mask.  Valid for ip4 flow-type.
+.TP
 .BI vlan\-etype \ N \\fR\ [\\fPm \ N \\fR]\\fP
 Includes the VLAN tag Ethertype and an optional mask.
 .TP
diff --git a/rxclass.c b/rxclass.c
index ee486f7..b227901 100644
--- a/rxclass.c
+++ b/rxclass.c
@@ -622,6 +622,9 @@ static struct rule_opts rule_nfc_usr_ip4[] = {
 	{ "l4proto", OPT_U8, NFC_FLAG_PROTO,
 	  offsetof(struct ethtool_rx_flow_spec, h_u.usr_ip4_spec.proto),
 	  offsetof(struct ethtool_rx_flow_spec, m_u.usr_ip4_spec.proto) },
+	{ "l4data", OPT_BE32, NFC_FLAG_SPI,
+	  offsetof(struct ethtool_rx_flow_spec, h_u.usr_ip4_spec.l4_4_bytes),
+	  offsetof(struct ethtool_rx_flow_spec,
m_u.usr_ip4_spec.l4_4_bytes) },
 	{ "spi", OPT_BE32, NFC_FLAG_SPI,
 	  offsetof(struct ethtool_rx_flow_spec, h_u.usr_ip4_spec.l4_4_bytes),
 	  offsetof(struct ethtool_rx_flow_spec,
m_u.usr_ip4_spec.l4_4_bytes) },
@@ -648,11 +651,11 @@ static struct rule_opts rule_nfc_usr_ip4[] = {
 
 static struct rule_opts rule_nfc_ether[] = {
 	{ "src", OPT_MAC, NFC_FLAG_SADDR,
-	  offsetof(struct ethtool_rx_flow_spec, h_u.ether_spec.h_dest),
-	  offsetof(struct ethtool_rx_flow_spec, m_u.ether_spec.h_dest) },
-	{ "dst", OPT_MAC, NFC_FLAG_DADDR,
 	  offsetof(struct ethtool_rx_flow_spec, h_u.ether_spec.h_source),
 	  offsetof(struct ethtool_rx_flow_spec, m_u.ether_spec.h_source) },
+	{ "dst", OPT_MAC, NFC_FLAG_DADDR,
+	  offsetof(struct ethtool_rx_flow_spec, h_u.ether_spec.h_dest),
+	  offsetof(struct ethtool_rx_flow_spec, m_u.ether_spec.h_dest) },
 	{ "proto", OPT_BE16, NFC_FLAG_PROTO,
 	  offsetof(struct ethtool_rx_flow_spec, h_u.ether_spec.h_proto),
 	  offsetof(struct ethtool_rx_flow_spec, m_u.ether_spec.h_proto) },
@@ -1062,6 +1065,8 @@ int rxclass_parse_ruleopts(char **argp, int argc,
 		}
 	}
 
+	if (flow_type == IP_USER_FLOW)
+		fsp->h_u.usr_ip4_spec.ip_ver = ETH_RX_NFC_IP4;
 	if (flags & (NTUPLE_FLAG_VLAN | NTUPLE_FLAG_UDEF | NTUPLE_FLAG_VETH))
 		fsp->flow_type |= FLOW_EXT;
 



