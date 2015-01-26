From: roopa@cumulusnetworks.com
Subject: [PATCH net-next v3 2/2] iproute2: bridge vlan show new option to print ranges
Date: Sun, 25 Jan 2015 18:26:25 -0800
Message-ID: <1422239185-14054-3-git-send-email-roopa@cumulusnetworks.com>
Cc: wkok@cumulusnetworks.com, sfeldma@gmail.com
To: netdev@vger.kernel.org, shemminger@vyatta.com, vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:32889 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752053AbbAZC0d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Jan 2015 21:26:33 -0500
Received: by mail-pd0-f181.google.com with SMTP id g10so9209511pdj.12
        for <netdev@vger.kernel.org>; Sun, 25 Jan 2015 18:26:33 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

Introduce new option -c[ompressvlans] to request
vlan ranges from kernel

(pls suggest better option names if this does not look ok)

$bridge vlan show
port	vlan ids
dummy0	 1 PVID Egress Untagged

dummy1	 1 PVID Egress Untagged
	 2
	 3
	 4
	 5
	 6
	 7
	 9
	 10
	 12

br0	 1 PVID Egress Untagged

$bridge help
Usage: bridge [ OPTIONS ] OBJECT { COMMAND | help }
where  OBJECT := { link | fdb | mdb | vlan | monitor }
       OPTIONS := { -V[ersion] | -s[tatistics] | -d[etails] |
                    -o[neline] | -t[imestamp] | -n[etns] name |
                    -c[ompressvlans] }
$bridge -c vlan show
port	vlan ids
dummy0	 1 PVID Egress Untagged

dummy1	 1 PVID Egress Untagged
	 2-7
	 9-10
	 12

br0	 1 PVID Egress Untagged

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 bridge/br_common.h        |    1 +
 bridge/bridge.c           |    6 +++++-
 bridge/vlan.c             |   11 +++++++++--
 include/linux/rtnetlink.h |    1 +
 4 files changed, 16 insertions(+), 3 deletions(-)

diff --git a/bridge/br_common.h b/bridge/br_common.h
index 12fce3e..169a162 100644
--- a/bridge/br_common.h
+++ b/bridge/br_common.h
@@ -16,4 +16,5 @@ extern int preferred_family;
 extern int show_stats;
 extern int show_details;
 extern int timestamp;
+extern int compress_vlans;
 extern struct rtnl_handle rth;
diff --git a/bridge/bridge.c b/bridge/bridge.c
index 5fcc552..88469ca 100644
--- a/bridge/bridge.c
+++ b/bridge/bridge.c
@@ -21,6 +21,7 @@ int resolve_hosts;
 int oneline = 0;
 int show_stats;
 int show_details;
+int compress_vlans;
 int timestamp;
 char * _SL_ = NULL;
 
@@ -32,7 +33,8 @@ static void usage(void)
 "Usage: bridge [ OPTIONS ] OBJECT { COMMAND | help }\n"
 "where  OBJECT := { link | fdb | mdb | vlan | monitor }\n"
 "       OPTIONS := { -V[ersion] | -s[tatistics] | -d[etails] |\n"
-"                    -o[neline] | -t[imestamp] | -n[etns] name }\n");
+"                    -o[neline] | -t[imestamp] | -n[etns] name |\n"
+"                    -c[ompressvlans] }\n");
 	exit(-1);
 }
 
@@ -117,6 +119,8 @@ main(int argc, char **argv)
 			NEXT_ARG();
 			if (netns_switch(argv[1]))
 				exit(-1);
+		} else if (matches(opt, "-compressvlans") == 0) {
+			++compress_vlans;
 		} else {
 			fprintf(stderr, "Option \"%s\" is unknown, try \"bridge help\".\n", opt);
 			exit(-1);
diff --git a/bridge/vlan.c b/bridge/vlan.c
index 88992e6..9f6c84e 100644
--- a/bridge/vlan.c
+++ b/bridge/vlan.c
@@ -182,7 +182,12 @@ static int print_vlan(const struct sockaddr_nl *who,
 				continue;
 
 			vinfo = RTA_DATA(i);
-			fprintf(fp, "\t %hu", vinfo->vid);
+			if (vinfo->flags & BRIDGE_VLAN_INFO_RANGE_END)
+				fprintf(fp, "-%hu", vinfo->vid);
+			else
+				fprintf(fp, "\t %hu", vinfo->vid);
+			if (vinfo->flags & BRIDGE_VLAN_INFO_RANGE_BEGIN)
+				continue;
 			if (vinfo->flags & BRIDGE_VLAN_INFO_PVID)
 				fprintf(fp, " PVID");
 			if (vinfo->flags & BRIDGE_VLAN_INFO_UNTAGGED)
@@ -218,7 +223,9 @@ static int vlan_show(int argc, char **argv)
 	}
 
 	if (rtnl_wilddump_req_filter(&rth, PF_BRIDGE, RTM_GETLINK,
-				     RTEXT_FILTER_BRVLAN) < 0) {
+				    (compress_vlans ?
+				    RTEXT_FILTER_BRVLAN_COMPRESSED :
+				    RTEXT_FILTER_BRVLAN)) < 0) {
 		perror("Cannont send dump request");
 		exit(1);
 	}
diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 9aa5c2f..19eadb1 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -632,6 +632,7 @@ struct tcamsg {
 /* New extended info filters for IFLA_EXT_MASK */
 #define RTEXT_FILTER_VF		(1 << 0)
 #define RTEXT_FILTER_BRVLAN	(1 << 1)
+#define RTEXT_FILTER_BRVLAN_COMPRESSED  (1 << 2)
 
 /* End of information exported to user level */
 
-- 
1.7.10.4
