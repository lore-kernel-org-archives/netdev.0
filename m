From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2 v3] ip link: Fix crash on older kernels when show VF dev
Date: Fri,  9 Jan 2015 21:24:31 +0200
Message-ID: <1420831471-27614-1-git-send-email-vadim4j@gmail.com>
Cc: william@gandi.net, Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:61146 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751064AbbAITe5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2015 14:34:57 -0500
Received: by mail-lb0-f179.google.com with SMTP id z11so9747917lbi.10
        for <netdev@vger.kernel.org>; Fri, 09 Jan 2015 11:34:55 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

The issue was caused that ifla_vf_rate does not exist on
older kernels and should be checked if it exists as nested attr.

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
Reported-by: William Dauchy <william@gandi.net>
Tested-by: William Dauchy <william@gandi.net>
---
 ip/ipaddress.c | 18 +++++++++++-------
 1 file changed, 11 insertions(+), 7 deletions(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 28dfe8c..830b166 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -259,11 +259,10 @@ static void print_vfinfo(FILE *fp, struct rtattr *vfinfo)
 {
 	struct ifla_vf_mac *vf_mac;
 	struct ifla_vf_vlan *vf_vlan;
-	struct ifla_vf_rate *vf_rate;
 	struct ifla_vf_tx_rate *vf_tx_rate;
 	struct ifla_vf_spoofchk *vf_spoofchk;
 	struct ifla_vf_link_state *vf_linkstate;
-	struct rtattr *vf[IFLA_VF_MAX+1];
+	struct rtattr *vf[IFLA_VF_MAX + 1] = {};
 	struct rtattr *tmp;
 	SPRINT_BUF(b1);
 
@@ -277,7 +276,6 @@ static void print_vfinfo(FILE *fp, struct rtattr *vfinfo)
 	vf_mac = RTA_DATA(vf[IFLA_VF_MAC]);
 	vf_vlan = RTA_DATA(vf[IFLA_VF_VLAN]);
 	vf_tx_rate = RTA_DATA(vf[IFLA_VF_TX_RATE]);
-	vf_rate = RTA_DATA(vf[IFLA_VF_RATE]);
 
 	/* Check if the spoof checking vf info type is supported by
 	 * this kernel.
@@ -313,10 +311,16 @@ static void print_vfinfo(FILE *fp, struct rtattr *vfinfo)
 		fprintf(fp, ", qos %d", vf_vlan->qos);
 	if (vf_tx_rate->rate)
 		fprintf(fp, ", tx rate %d (Mbps)", vf_tx_rate->rate);
-	if (vf_rate->max_tx_rate)
-		fprintf(fp, ", max_tx_rate %dMbps", vf_rate->max_tx_rate);
-	if (vf_rate->min_tx_rate)
-		fprintf(fp, ", min_tx_rate %dMbps", vf_rate->min_tx_rate);
+
+	if (vf[IFLA_VF_RATE]) {
+		struct ifla_vf_rate *vf_rate = RTA_DATA(vf[IFLA_VF_RATE]);
+
+		if (vf_rate->max_tx_rate)
+			fprintf(fp, ", max_tx_rate %dMbps", vf_rate->max_tx_rate);
+		if (vf_rate->min_tx_rate)
+			fprintf(fp, ", min_tx_rate %dMbps", vf_rate->min_tx_rate);
+	}
+
 	if (vf_spoofchk && vf_spoofchk->setting != -1) {
 		if (vf_spoofchk->setting)
 			fprintf(fp, ", spoof checking on");
-- 
2.1.3
