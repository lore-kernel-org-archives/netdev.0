From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH iproute2 net-next v2 2/2] bridge: vlan: support for per vlan tunnel info
Date: Fri, 27 Oct 2017 22:13:50 -0700
Message-ID: <1509167630-9869-3-git-send-email-roopa@cumulusnetworks.com>
References: <1509167630-9869-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, nikolay@cumulusnetworks.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:46276 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751029AbdJ1FN6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 28 Oct 2017 01:13:58 -0400
Received: by mail-pg0-f65.google.com with SMTP id k7so6763331pga.3
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 22:13:58 -0700 (PDT)
In-Reply-To: <1509167630-9869-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch uses kernel bridge vlan attribute
IFLA_BRIDGE_VLAN_TUNNEL_INFO to set/delete/show per vlan tunnel info.

$bridge vlan add dev vxlan0 vid 2000 tunnel_info id 2000
$bridge vlan add dev vxlan0 vid 1000-1001 tunnel_info id 2000-2001

$bridge vlan tunnelshow
port    vlan ids        tunnel id
vxlan0   1000-1001       1000-1001
         2000            2000

$bridge  -j vlan tunnelshow
{
    "dummy0": [],
    "dummy1": [],
    "bridge": [],
    "vxlan0": [{
            "vlan": 1000,
            "vlanEnd": 1001,
            "tunid": 1000,
            "tunidEnd": 1001
        },{
            "vlan": 2000,
            "tunid": 2000
        }
    ]
}

This patch also fixes a json termination bug in print_vlan
when filter vlan is provided by the user.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 bridge/vlan.c     | 328 ++++++++++++++++++++++++++++++++++++++++++++++++------
 man/man8/bridge.8 |  14 ++-
 2 files changed, 307 insertions(+), 35 deletions(-)

diff --git a/bridge/vlan.c b/bridge/vlan.c
index 4ca91c1..0f78a9e 100644
--- a/bridge/vlan.c
+++ b/bridge/vlan.c
@@ -16,18 +16,114 @@
 
 static unsigned int filter_index, filter_vlan;
 static int last_ifidx = -1;
+static int show_vlan_tunnel_info = 0;
 
 json_writer_t *jw_global;
 
 static void usage(void)
 {
 	fprintf(stderr,
-		"Usage: bridge vlan { add | del } vid VLAN_ID dev DEV [ pvid ] [ untagged ]\n"
+		"Usage: bridge vlan { add | del } vid VLAN_ID dev DEV [ tunnel_info id TUNNEL_ID ]\n"
+		"                                                     [ pvid ] [ untagged ]\n"
 		"                                                     [ self ] [ master ]\n"
-		"       bridge vlan { show } [ dev DEV ] [ vid VLAN_ID ]\n");
+		"       bridge vlan { show } [ dev DEV ] [ vid VLAN_ID ]\n"
+		"       bridge vlan { tunnelshow } [ dev DEV ] [ vid VLAN_ID ]\n");
 	exit(-1);
 }
 
+static int parse_tunnel_info(int *argcp, char ***argvp, __u32 *tun_id_start,
+			     __u32 *tun_id_end)
+{
+	char **argv = *argvp;
+	int argc = *argcp;
+	char *t;
+
+	NEXT_ARG();
+	if (!matches(*argv, "id")) {
+		NEXT_ARG();
+		t = strchr(*argv, '-');
+		if (t) {
+			*t = '\0';
+			if (get_u32(tun_id_start, *argv, 0) ||
+				    *tun_id_start >= 1u << 24)
+				invarg("invalid tun id", *argv);
+			if (get_u32(tun_id_end, t + 1, 0) ||
+				    *tun_id_end >= 1u << 24)
+				invarg("invalid tun id", *argv);
+
+		} else {
+			if (get_u32(tun_id_start, *argv, 0) ||
+				    *tun_id_start >= 1u << 24)
+				invarg("invalid tun id", *argv);
+		}
+	} else {
+		invarg("tunnel id expected", *argv);
+	}
+
+	*argcp = argc;
+	*argvp = argv;
+
+	return 0;
+}
+
+static int add_tunnel_info(struct nlmsghdr *n, int reqsize,
+			   __u16 vid, __u32 tun_id, __u16 flags)
+{
+	struct rtattr *tinfo;
+
+	tinfo = addattr_nest(n, reqsize, IFLA_BRIDGE_VLAN_TUNNEL_INFO);
+	addattr32(n, reqsize, IFLA_BRIDGE_VLAN_TUNNEL_ID, tun_id);
+	addattr32(n, reqsize, IFLA_BRIDGE_VLAN_TUNNEL_VID, vid);
+	addattr32(n, reqsize, IFLA_BRIDGE_VLAN_TUNNEL_FLAGS, flags);
+
+	addattr_nest_end(n, tinfo);
+
+	return 0;
+}
+
+static int add_tunnel_info_range(struct nlmsghdr *n, int reqsize,
+				 __u16 vid_start, int16_t vid_end,
+				 __u32 tun_id_start, __u32 tun_id_end)
+{
+	if (vid_end != -1 && (vid_end - vid_start) > 0) {
+		add_tunnel_info(n, reqsize, vid_start, tun_id_start,
+				BRIDGE_VLAN_INFO_RANGE_BEGIN);
+
+		add_tunnel_info(n, reqsize, vid_end, tun_id_end,
+				BRIDGE_VLAN_INFO_RANGE_END);
+	} else {
+		add_tunnel_info(n, reqsize, vid_start, tun_id_start, 0);
+	}
+
+	return 0;
+}
+
+static int add_vlan_info_range(struct nlmsghdr *n, int reqsize, __u16 vid_start,
+			       int16_t vid_end, __u16 flags)
+{
+	struct bridge_vlan_info vinfo = {};
+
+	vinfo.flags = flags;
+	vinfo.vid = vid_start;
+	if (vid_end != -1) {
+		/* send vlan range start */
+		addattr_l(n, reqsize, IFLA_BRIDGE_VLAN_INFO, &vinfo,
+			  sizeof(vinfo));
+		vinfo.flags &= ~BRIDGE_VLAN_INFO_RANGE_BEGIN;
+
+		/* Now send the vlan range end */
+		vinfo.flags |= BRIDGE_VLAN_INFO_RANGE_END;
+		vinfo.vid = vid_end;
+		addattr_l(n, reqsize, IFLA_BRIDGE_VLAN_INFO, &vinfo,
+			  sizeof(vinfo));
+	} else {
+		addattr_l(n, reqsize, IFLA_BRIDGE_VLAN_INFO, &vinfo,
+			  sizeof(vinfo));
+	}
+
+	return 0;
+}
+
 static int vlan_modify(int cmd, int argc, char **argv)
 {
 	struct {
@@ -45,7 +141,10 @@ static int vlan_modify(int cmd, int argc, char **argv)
 	short vid_end = -1;
 	struct rtattr *afspec;
 	struct bridge_vlan_info vinfo = {};
+	bool tunnel_info_set = false;
 	unsigned short flags = 0;
+	__u32 tun_id_start = 0;
+	__u32 tun_id_end = 0;
 
 	while (argc > 0) {
 		if (strcmp(*argv, "dev") == 0) {
@@ -73,6 +172,12 @@ static int vlan_modify(int cmd, int argc, char **argv)
 			vinfo.flags |= BRIDGE_VLAN_INFO_PVID;
 		} else if (strcmp(*argv, "untagged") == 0) {
 			vinfo.flags |= BRIDGE_VLAN_INFO_UNTAGGED;
+		} else if (strcmp(*argv, "tunnel_info") == 0) {
+				if (parse_tunnel_info(&argc, &argv,
+						      &tun_id_start,
+						      &tun_id_end))
+					return -1;
+				tunnel_info_set = true;
 		} else {
 			if (matches(*argv, "help") == 0)
 				NEXT_ARG();
@@ -114,22 +219,12 @@ static int vlan_modify(int cmd, int argc, char **argv)
 	if (flags)
 		addattr16(&req.n, sizeof(req), IFLA_BRIDGE_FLAGS, flags);
 
-	vinfo.vid = vid;
-	if (vid_end != -1) {
-		/* send vlan range start */
-		addattr_l(&req.n, sizeof(req), IFLA_BRIDGE_VLAN_INFO, &vinfo,
-			  sizeof(vinfo));
-		vinfo.flags &= ~BRIDGE_VLAN_INFO_RANGE_BEGIN;
-
-		/* Now send the vlan range end */
-		vinfo.flags |= BRIDGE_VLAN_INFO_RANGE_END;
-		vinfo.vid = vid_end;
-		addattr_l(&req.n, sizeof(req), IFLA_BRIDGE_VLAN_INFO, &vinfo,
-			  sizeof(vinfo));
-	} else {
-		addattr_l(&req.n, sizeof(req), IFLA_BRIDGE_VLAN_INFO, &vinfo,
-			  sizeof(vinfo));
-	}
+	if (tunnel_info_set)
+		add_tunnel_info_range(&req.n, sizeof(req), vid, vid_end,
+				      tun_id_start, tun_id_end);
+	else
+		add_vlan_info_range(&req.n, sizeof(req), vid, vid_end,
+				    vinfo.flags);
 
 	addattr_nest_end(&req.n, afspec);
 
@@ -146,14 +241,14 @@ static int vlan_modify(int cmd, int argc, char **argv)
  *             which are less than filter_vlan)
  * return  1 - print the entry and continue
  */
-static int filter_vlan_check(struct bridge_vlan_info *vinfo)
+static int filter_vlan_check(__u16 vid, __u16 flags)
 {
 	/* if we're filtering we should stop on the first greater entry */
-	if (filter_vlan && vinfo->vid > filter_vlan &&
-	    !(vinfo->flags & BRIDGE_VLAN_INFO_RANGE_END))
+	if (filter_vlan && vid > filter_vlan &&
+	    !(flags & BRIDGE_VLAN_INFO_RANGE_END))
 		return -1;
-	if ((vinfo->flags & BRIDGE_VLAN_INFO_RANGE_BEGIN) ||
-	    vinfo->vid < filter_vlan)
+	if ((flags & BRIDGE_VLAN_INFO_RANGE_BEGIN) ||
+	    vid < filter_vlan)
 		return 0;
 
 	return 1;
@@ -181,6 +276,150 @@ static void start_json_vlan_flags_array(bool *vlan_flags)
 	*vlan_flags = true;
 }
 
+static void print_vlan_tunnel_info(FILE *fp, struct rtattr *tb, int ifindex)
+{
+	bool jsonw_end_parray = false;
+	struct rtattr *i, *list = tb;
+	int rem = RTA_PAYLOAD(list);
+	__u16 last_vid_start = 0;
+	__u32 last_tunid_start = 0;
+
+	if (!filter_vlan) {
+		print_vlan_port(fp, ifindex);
+		jsonw_end_parray = 1;
+	}
+
+	for (i = RTA_DATA(list); RTA_OK(i, rem); i = RTA_NEXT(i, rem)) {
+		struct rtattr *ttb[IFLA_BRIDGE_VLAN_TUNNEL_MAX+1];
+		__u32 tunnel_id = 0;
+		__u16 tunnel_vid = 0;
+		__u16 tunnel_flags = 0;
+		int vcheck_ret;
+
+		if (i->rta_type != IFLA_BRIDGE_VLAN_TUNNEL_INFO)
+			continue;
+
+		parse_rtattr(ttb, IFLA_BRIDGE_VLAN_TUNNEL_MAX,
+			     RTA_DATA(i), RTA_PAYLOAD(i));
+
+		if (ttb[IFLA_BRIDGE_VLAN_TUNNEL_VID])
+			tunnel_vid =
+				rta_getattr_u32(ttb[IFLA_BRIDGE_VLAN_TUNNEL_VID]);
+		else
+			continue;
+
+		if (ttb[IFLA_BRIDGE_VLAN_TUNNEL_ID])
+			tunnel_id =
+				rta_getattr_u32(ttb[IFLA_BRIDGE_VLAN_TUNNEL_ID]);
+
+		if (ttb[IFLA_BRIDGE_VLAN_TUNNEL_FLAGS])
+			tunnel_flags =
+				rta_getattr_u32(ttb[IFLA_BRIDGE_VLAN_TUNNEL_FLAGS]);
+
+		if (!(tunnel_flags & BRIDGE_VLAN_INFO_RANGE_END)) {
+			last_vid_start = tunnel_vid;
+			last_tunid_start = tunnel_id;
+		}
+		vcheck_ret = filter_vlan_check(tunnel_vid, tunnel_flags);
+		if (vcheck_ret == -1)
+			break;
+		else if (vcheck_ret == 0)
+			continue;
+
+		if (tunnel_flags & BRIDGE_VLAN_INFO_RANGE_BEGIN)
+			continue;
+
+		if (filter_vlan) {
+			print_vlan_port(fp, ifindex);
+			jsonw_end_parray = 1;
+		}
+
+		if (jw_global) {
+			jsonw_start_object(jw_global);
+			jsonw_uint_field(jw_global, "vlan",
+					 last_vid_start);
+		} else {
+			fprintf(fp, "\t %hu", last_vid_start);
+		}
+		if (last_vid_start != tunnel_vid) {
+			if (jw_global)
+				jsonw_uint_field(jw_global, "vlanEnd",
+						 tunnel_vid);
+			else
+				fprintf(fp, "-%hu", tunnel_vid);
+		}
+
+		if (jw_global) {
+			jsonw_uint_field(jw_global, "tunid",
+					 last_tunid_start);
+		} else {
+			fprintf(fp, "\t %hu", last_tunid_start);
+		}
+		if (last_vid_start != tunnel_vid) {
+			if (jw_global)
+				jsonw_uint_field(jw_global, "tunidEnd",
+						 tunnel_id);
+			else
+				fprintf(fp, "-%hu", tunnel_id);
+		}
+
+		if (jw_global)
+			jsonw_end_object(jw_global);
+		else
+			fprintf(fp, "\n");
+	}
+
+	if (jsonw_end_parray) {
+		if (jw_global)
+			jsonw_end_array(jw_global);
+		else
+			fprintf(fp, "\n");
+	}
+}
+
+static int print_vlan_tunnel(const struct sockaddr_nl *who,
+			     struct nlmsghdr *n,
+			     void *arg)
+{
+	struct ifinfomsg *ifm = NLMSG_DATA(n);
+	struct rtattr *tb[IFLA_MAX+1];
+	int len = n->nlmsg_len;
+	FILE *fp = arg;
+
+	if (n->nlmsg_type != RTM_NEWLINK) {
+		fprintf(stderr, "Not RTM_NEWLINK: %08x %08x %08x\n",
+			n->nlmsg_len, n->nlmsg_type, n->nlmsg_flags);
+		return 0;
+	}
+
+	len -= NLMSG_LENGTH(sizeof(*ifm));
+	if (len < 0) {
+		fprintf(stderr, "BUG: wrong nlmsg len %d\n", len);
+		return -1;
+	}
+
+	if (ifm->ifi_family != AF_BRIDGE)
+		return 0;
+
+	if (filter_index && filter_index != ifm->ifi_index)
+		return 0;
+
+	parse_rtattr(tb, IFLA_MAX, IFLA_RTA(ifm), len);
+
+	/* if AF_SPEC isn't there, vlan table is not preset for this port */
+	if (!tb[IFLA_AF_SPEC]) {
+		if (!filter_vlan && !jw_global)
+			fprintf(fp, "%s\tNone\n",
+				ll_index_to_name(ifm->ifi_index));
+		return 0;
+	}
+
+	print_vlan_tunnel_info(fp, tb[IFLA_AF_SPEC], ifm->ifi_index);
+
+	fflush(fp);
+	return 0;
+}
+
 static int print_vlan(const struct sockaddr_nl *who,
 		      struct nlmsghdr *n,
 		      void *arg)
@@ -219,13 +458,7 @@ static int print_vlan(const struct sockaddr_nl *who,
 	}
 
 	print_vlan_info(fp, tb[IFLA_AF_SPEC], ifm->ifi_index);
-	if (!filter_vlan) {
-		if (jw_global)
-			jsonw_end_array(jw_global);
-		else
-			fprintf(fp, "\n");
 
-	}
 	fflush(fp);
 	return 0;
 }
@@ -315,6 +548,7 @@ static int print_vlan_stats(const struct sockaddr_nl *who,
 static int vlan_show(int argc, char **argv)
 {
 	char *filter_dev = NULL;
+	int ret = 0;
 
 	while (argc > 0) {
 		if (strcmp(*argv, "dev") == 0) {
@@ -356,10 +590,19 @@ static int vlan_show(int argc, char **argv)
 			}
 			jsonw_start_object(jw_global);
 		} else {
-			printf("port\tvlan ids\n");
+			if (show_vlan_tunnel_info)
+				printf("port\tvlan ids\ttunnel id\n");
+			else
+				printf("port\tvlan ids\n");
 		}
 
-		if (rtnl_dump_filter(&rth, print_vlan, stdout) < 0) {
+		if (show_vlan_tunnel_info)
+			ret = rtnl_dump_filter(&rth, print_vlan_tunnel,
+					       stdout);
+		else
+			ret = rtnl_dump_filter(&rth, print_vlan, stdout);
+
+		if (ret < 0) {
 			fprintf(stderr, "Dump ternminated\n");
 			exit(1);
 		}
@@ -408,9 +651,12 @@ void print_vlan_info(FILE *fp, struct rtattr *tb, int ifindex)
 	int rem = RTA_PAYLOAD(list);
 	__u16 last_vid_start = 0;
 	bool vlan_flags = false;
+	bool jsonw_end_parray = false;
 
-	if (!filter_vlan)
+	if (!filter_vlan) {
 		print_vlan_port(fp, ifindex);
+		jsonw_end_parray = true;
+	}
 
 	for (i = RTA_DATA(list); RTA_OK(i, rem); i = RTA_NEXT(i, rem)) {
 		struct bridge_vlan_info *vinfo;
@@ -423,14 +669,16 @@ void print_vlan_info(FILE *fp, struct rtattr *tb, int ifindex)
 
 		if (!(vinfo->flags & BRIDGE_VLAN_INFO_RANGE_END))
 			last_vid_start = vinfo->vid;
-		vcheck_ret = filter_vlan_check(vinfo);
+		vcheck_ret = filter_vlan_check(vinfo->vid, vinfo->flags);
 		if (vcheck_ret == -1)
 			break;
 		else if (vcheck_ret == 0)
 			continue;
 
-		if (filter_vlan)
+		if (filter_vlan) {
 			print_vlan_port(fp, ifindex);
+			jsonw_end_parray = true;
+		}
 		if (jw_global) {
 			jsonw_start_object(jw_global);
 			jsonw_uint_field(jw_global, "vlan",
@@ -474,6 +722,14 @@ void print_vlan_info(FILE *fp, struct rtattr *tb, int ifindex)
 		else
 			fprintf(fp, "\n");
 	}
+
+	if (jsonw_end_parray) {
+		if (jw_global)
+			jsonw_end_array(jw_global);
+		else
+			fprintf(fp, "\n");
+
+	}
 }
 
 int do_vlan(int argc, char **argv)
@@ -489,6 +745,10 @@ int do_vlan(int argc, char **argv)
 		    matches(*argv, "lst") == 0 ||
 		    matches(*argv, "list") == 0)
 			return vlan_show(argc-1, argv+1);
+		if (matches(*argv, "tunnelshow") == 0) {
+			show_vlan_tunnel_info = 1;
+			return vlan_show(argc-1, argv+1);
+		}
 		if (matches(*argv, "help") == 0)
 			usage();
 	} else {
diff --git a/man/man8/bridge.8 b/man/man8/bridge.8
index d3c5b1e..d6baa81 100644
--- a/man/man8/bridge.8
+++ b/man/man8/bridge.8
@@ -105,11 +105,13 @@ bridge \- show / manipulate bridge addresses and devices
 .IR DEV
 .B vid
 .IR VID " [ "
+.BR tunnel_info
+.IR TUNNEL_ID " ] [ "
 .BR pvid " ] [ " untagged " ] [ "
 .BR self " ] [ " master " ] "
 
 .ti -8
-.BR "bridge vlan" " [ " show " ] [ "
+.BR "bridge vlan" " [ " show " | " tunnelshow " ] [ "
 .B dev
 .IR DEV " ]"
 
@@ -562,6 +564,12 @@ the interface with which this vlan is associated.
 the VLAN ID that identifies the vlan.
 
 .TP
+.BI tunnel_info " TUNNEL_ID"
+the TUNNEL ID that maps to this vlan. The tunnel id is set in dst_metadata for
+every packet that belongs to this vlan (applicable to bridge ports with vlan_tunnel
+flag set).
+
+.TP
 .BI pvid
 the vlan specified is to be considered a PVID at ingress.
 Any untagged frames will be assigned to this VLAN.
@@ -598,6 +606,10 @@ With the
 .B -statistics
 option, the command displays per-vlan traffic statistics.
 
+.SS bridge vlan tunnelshow - list vlan tunnel mapping.
+
+This command displays the current vlan tunnel info mapping.
+
 .SH bridge monitor - state monitoring
 
 The
-- 
2.1.4
