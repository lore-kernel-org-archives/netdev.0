From: "Sebastian =?ISO-8859-1?Q?P=F6hn?=" <sebastian.belden@googlemail.com>
Subject: [PATCH] ethtool: NFC corrections
Date: Tue, 14 Jun 2011 16:58:16 +0200
Message-ID: <1308063496.13297.8.camel@DENEC1DT0191>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Sebastian =?ISO-8859-1?Q?P=F6hn?= <sebastian.poehn@belden.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:53640 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751574Ab1FNPUd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2011 11:20:33 -0400
Received: by wya21 with SMTP id 21so3972083wya.19
        for <netdev@vger.kernel.org>; Tue, 14 Jun 2011 08:20:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch:
# Adds an alias for ip4 called l4data pointing to spi (first 4 Layer 4 bytes)
# [TRIVIAL] Corrects the permutation of dst and src for ethernet
# Suggests to always set the ip_ver field of usr_ip to ETH_RX_NFC_IP4 at least as
  long there is no opportunity to uses others than IPv4 and there is no frontend
  option to enter ip_ver.

Signed-off-by: Sebastian Poehn <sebastian.poehn@belden.com>
---

 ethtool.8.in |    5 +++++
 rxclass.c    |   11 ++++++++---
 2 files changed, 13 insertions(+), 3 deletions(-)

diff --git a/ethtool.8.in b/ethtool.8.in
index 7b1cdf5..0a64d75 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -296,6 +296,7 @@ ethtool \- query or control network driver and hardware settings
 .BM src\-port
 .BM dst\-port
 .BM spi
+.BM l4data
 .BM vlan\-etype
 .BM vlan
 .BM user\-def
@@ -718,6 +719,10 @@ Specify the value of the security parameter index field (applicable to
 AH/ESP packets)in the incoming packet to match along with an optional
 mask.  Valid for flow-types ip4, ah4, and esp4.
 .TP
+.BI l4data \ N \\fR\ [\\fPm \ N \\fR]\\fP
+Specify the value of the first 4 Bytes of Layer 4 in the incoming packet to
+match along with an optional mask.  Valid for ip4 flow-type.
+.TP
 .BI vlan\-etype \ N \\fR\ [\\fPm \ N \\fR]\\fP
 Includes the VLAN tag Ethertype and an optional mask.
 .TP
diff --git a/rxclass.c b/rxclass.c
index ee486f7..45c0c17 100644
--- a/rxclass.c
+++ b/rxclass.c
@@ -622,6 +622,9 @@ static struct rule_opts rule_nfc_usr_ip4[] = {
 	{ "l4proto", OPT_U8, NFC_FLAG_PROTO,
 	  offsetof(struct ethtool_rx_flow_spec, h_u.usr_ip4_spec.proto),
 	  offsetof(struct ethtool_rx_flow_spec, m_u.usr_ip4_spec.proto) },
+	{ "l4data", OPT_BE32, NFC_FLAG_SPI,
+	  offsetof(struct ethtool_rx_flow_spec, h_u.usr_ip4_spec.l4_4_bytes),
+	  offsetof(struct ethtool_rx_flow_spec, m_u.usr_ip4_spec.l4_4_bytes) },
 	{ "spi", OPT_BE32, NFC_FLAG_SPI,
 	  offsetof(struct ethtool_rx_flow_spec, h_u.usr_ip4_spec.l4_4_bytes),
 	  offsetof(struct ethtool_rx_flow_spec, m_u.usr_ip4_spec.l4_4_bytes) },
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
@@ -1064,6 +1067,8 @@ int rxclass_parse_ruleopts(char **argp, int argc,
 
 	if (flags & (NTUPLE_FLAG_VLAN | NTUPLE_FLAG_UDEF | NTUPLE_FLAG_VETH))
 		fsp->flow_type |= FLOW_EXT;
+	if (flow_type == IP_USER_FLOW)
+		fsp->h_u.usr_ip4_spec.ip_ver = ETH_RX_NFC_IP4;
 
 	return 0;
 


