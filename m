From: Vlad Zolotarov <vladz@cloudius-systems.com>
Subject: [PATCH iproute2] ip link set vf: Added "query_rss" command
Date: Sun, 22 Mar 2015 20:52:58 +0200
Message-ID: <1427050378-15004-1-git-send-email-vladz@cloudius-systems.com>
Cc: jeffrey.t.kirsher@intel.com,
	Vlad Zolotarov <vladz@cloudius-systems.com>
To: stephen@networkplumber.org, kuznet@ms2.inr.ac.ru,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:37903 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751870AbbCVSxD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 14:53:03 -0400
Received: by wibgn9 with SMTP id gn9so40726372wib.1
        for <netdev@vger.kernel.org>; Sun, 22 Mar 2015 11:53:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a new option to toggle the ability of querying the RSS configuration of a specific VF.

VF RSS information like RSS hash key may be considered sensitive on some devices where
this information is shared between VF and PF and thus its querying may be prohibited by default.

This new option allows a system administrator with privileges to modify a PF state
to control if the above VF querying is allowed or not.

For example:
 To enable RSS querying of VF[0] of ethX:
 >> ip link set dev ethX vf 0 query_rss on

Signed-off-by: Vlad Zolotarov <vladz@cloudius-systems.com>
---
 include/linux/if_link.h |  8 ++++++++
 ip/iplink.c             | 13 +++++++++++++
 2 files changed, 21 insertions(+)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 3450c3f..ca831e2 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -457,6 +457,9 @@ enum {
 	IFLA_VF_SPOOFCHK,	/* Spoof Checking on/off switch */
 	IFLA_VF_LINK_STATE,	/* link state enable/disable/auto switch */
 	IFLA_VF_RATE,		/* Min and Max TX Bandwidth Allocation */
+	IFLA_VF_RSS_QUERY_EN,	/* RSS Redirection Table and Hash Key query
+				 * on/off switch
+				 */
 	__IFLA_VF_MAX,
 };
 
@@ -489,6 +492,11 @@ struct ifla_vf_spoofchk {
 	__u32 setting;
 };
 
+struct ifla_vf_rss_query_en {
+	__u32 vf;
+	__u32 setting;
+};
+
 enum {
 	IFLA_VF_LINK_STATE_AUTO,	/* link state of the uplink */
 	IFLA_VF_LINK_STATE_ENABLE,	/* link always up */
diff --git a/ip/iplink.c b/ip/iplink.c
index 5893ee4..6498041 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -80,6 +80,7 @@ void iplink_usage(void)
 	fprintf(stderr, "				   [ rate TXRATE ] ] \n");
 
 	fprintf(stderr, "				   [ spoofchk { on | off} ] ] \n");
+	fprintf(stderr, "				   [ query_rss { on | off} ] ] \n");
 	fprintf(stderr, "				   [ state { auto | enable | disable} ] ]\n");
 	fprintf(stderr, "			  [ master DEVICE ]\n");
 	fprintf(stderr, "			  [ nomaster ]\n");
@@ -331,6 +332,18 @@ static int iplink_parse_vf(int vf, int *argcp, char ***argvp,
 			ivs.vf = vf;
 			addattr_l(&req->n, sizeof(*req), IFLA_VF_SPOOFCHK, &ivs, sizeof(ivs));
 
+		} else if (matches(*argv, "query_rss") == 0) {
+			struct ifla_vf_rss_query_en ivs;
+			NEXT_ARG();
+			if (matches(*argv, "on") == 0)
+				ivs.setting = 1;
+			else if (matches(*argv, "off") == 0)
+				ivs.setting = 0;
+			else
+				invarg("Invalid \"query_rss\" value\n", *argv);
+			ivs.vf = vf;
+			addattr_l(&req->n, sizeof(*req), IFLA_VF_RSS_QUERY_EN, &ivs, sizeof(ivs));
+
 		} else if (matches(*argv, "state") == 0) {
 			struct ifla_vf_link_state ivl;
 			NEXT_ARG();
-- 
2.1.0
