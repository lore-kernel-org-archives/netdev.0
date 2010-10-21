From: Roopa Prabhu <roprabhu@cisco.com>
Subject: [PATCH] iproute2: add VF_PORT support
Date: Thu, 21 Oct 2010 05:41:33 -0700
Message-ID: <20101021124133.32004.60468.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com, scofeldm@cisco.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:9311 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757810Ab0JUMle (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 08:41:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roprabhu@cisco.com>

Resubmitting Scott Feldmans original patch with a minor fix

Changes since last posted version:
- Fix port profile strlen which was off by 1

Add support for IFLA_VF_PORTS.  VF port netlink msg layout is

        [IFLA_NUM_VF]
        [IFLA_VF_PORTS]
                [IFLA_VF_PORT]
                        [IFLA_PORT_*], ...
                [IFLA_VF_PORT]
                        [IFLA_PORT_*], ...
                ...
        [IFLA_PORT_SELF]
                [IFLA_PORT_*], ...

The iproute2 cmd line for link set is now:

Usage: ip link add link DEV [ name ] NAME
                   [ txqueuelen PACKETS ]
                   [ address LLADDR ]
                   [ broadcast LLADDR ]
                   [ mtu MTU ]
                   type TYPE [ ARGS ]
       ip link delete DEV type TYPE [ ARGS ]

       ip link set DEVICE [ { up | down } ]
                          [ arp { on | off } ]
                          [ dynamic { on | off } ]
                          [ multicast { on | off } ]
                          [ allmulticast { on | off } ]
                          [ promisc { on | off } ]
                          [ trailers { on | off } ]
                          [ txqueuelen PACKETS ]
                          [ name NEWNAME ]
                          [ address LLADDR ]
                          [ broadcast LLADDR ]
                          [ mtu MTU ]
                          [ netns PID ]
                          [ alias NAME ]
                          [ port MODE { PROFILE | VSI } ]
                          [ vf NUM [ mac LLADDR ]
                                   [ vlan VLANID [ qos VLAN-QOS ] ]
                                   [ rate TXRATE ]
                                   [ port MODE { PROFILE | VSI } ] ]
       ip link show [ DEVICE ]

TYPE := { vlan | veth | vcan | dummy | ifb | macvlan | can }
MODE := { assoc | preassoc | preassocrr | disassoc }
PROFILE := profile PROFILE
           [ instance UUID ]
           [ host UUID ]
VSI := vsi mgr MGRID type VTID ver VER
       [ instance UUID ]

Signed-off-by: Scott Feldman <scofeldm@cisco.com>
Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
---
 ip/ipaddress.c |  115 +++++++++++++++++++++++++++++
 ip/iplink.c    |  225 +++++++++++++++++++++++++++++++++++++++++++++++---------
 2 files changed, 302 insertions(+), 38 deletions(-)


diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 19b3d6e..65be741 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -187,6 +187,107 @@ static void print_linktype(FILE *fp, struct rtattr *tb)
 	}
 }
 
+static void print_port(FILE *fp, struct rtattr *port[])
+{
+	struct ifla_port_vsi *vsi;
+#define uuid_fmt "%02X%02X%02X%02X-%02X%02X-%02X%02X-" \
+	"%02X%02X-%02X%02X%02X%02X%02X%02X"
+	unsigned char *uuid;
+	__u8 request;
+	__u16 response;
+
+	if (port[IFLA_PORT_VF])
+		fprintf(fp, "\n    vf %d port",
+			*(__u32 *)RTA_DATA(port[IFLA_PORT_VF]));
+	else
+		fprintf(fp, "\n    port");
+
+	if (port[IFLA_PORT_REQUEST]) {
+		request = *(__u8 *)RTA_DATA(port[IFLA_PORT_REQUEST]);
+		fprintf(fp, " %s",
+			request == PORT_REQUEST_PREASSOCIATE ? "preassoc" :
+			request == PORT_REQUEST_PREASSOCIATE_RR ? "preassocrr" :
+			request == PORT_REQUEST_ASSOCIATE ? "assoc" :
+			request == PORT_REQUEST_DISASSOCIATE ? "disassoc" :
+			"unknown request");
+	}
+
+	if (port[IFLA_PORT_PROFILE])
+		fprintf(fp, " profile \"%s\"",
+			(char *)RTA_DATA(port[IFLA_PORT_PROFILE]));
+
+	if (port[IFLA_PORT_VSI_TYPE]) {
+		vsi = RTA_DATA(port[IFLA_PORT_VSI_TYPE]);
+		fprintf(fp, " vsi mgr %d type 0x%02x%02x%02x ver %d",
+			vsi->vsi_mgr_id, vsi->vsi_type_id[0],
+			vsi->vsi_type_id[1], vsi->vsi_type_id[2],
+			vsi->vsi_type_version);
+	}
+
+	if (port[IFLA_PORT_RESPONSE]) {
+		response = *(__u16 *)RTA_DATA(port[IFLA_PORT_RESPONSE]);
+		fprintf(fp, " status: %s",
+			response == PORT_VDP_RESPONSE_SUCCESS ?
+				"SUCCESS" :
+			response == PORT_VDP_RESPONSE_INVALID_FORMAT ?
+				"INVALID FORMAT" :
+			response == PORT_VDP_RESPONSE_INSUFFICIENT_RESOURCES ?
+				"INSUFFICIENT RESOURCES" :
+			response == PORT_VDP_RESPONSE_UNUSED_VTID ?
+				"UNUSED VTID" :
+			response == PORT_VDP_RESPONSE_VTID_VIOLATION ?
+				"VTID VIOLATION" :
+			response == PORT_VDP_RESPONSE_VTID_VERSION_VIOALTION ?
+				"VTID VERSION VIOLATION" :
+			response == PORT_VDP_RESPONSE_OUT_OF_SYNC ?
+				"OUT-OF-SYNC" :
+			response == PORT_PROFILE_RESPONSE_SUCCESS ?
+				"SUCCESS" :
+			response == PORT_PROFILE_RESPONSE_INPROGRESS ?
+				"IN-PROGRESS" :
+			response == PORT_PROFILE_RESPONSE_INVALID ?
+				"INVALID" :
+			response == PORT_PROFILE_RESPONSE_BADSTATE ?
+				"BAD STATE" :
+			response == PORT_PROFILE_RESPONSE_INSUFFICIENT_RESOURCES ?
+				"INSUFFICIENT RESOURCES" :
+			response == PORT_PROFILE_RESPONSE_ERROR ?
+				"ERROR" :
+			"UNKNOWN RESPONSE");
+	}
+
+	if (port[IFLA_PORT_INSTANCE_UUID]) {
+		uuid = RTA_DATA(port[IFLA_PORT_INSTANCE_UUID]);
+		fprintf(fp, "\n        instance "uuid_fmt,
+			uuid[0],  uuid[1],  uuid[2],  uuid[3],
+			uuid[4],  uuid[5],  uuid[6],  uuid[7],
+			uuid[8],  uuid[9],  uuid[10], uuid[11],
+			uuid[12], uuid[13], uuid[14], uuid[15]);
+	}
+
+	if (port[IFLA_PORT_HOST_UUID]) {
+		uuid = RTA_DATA(port[IFLA_PORT_HOST_UUID]);
+		fprintf(fp, "\n            host "uuid_fmt,
+			uuid[0],  uuid[1],  uuid[2],  uuid[3],
+			uuid[4],  uuid[5],  uuid[6],  uuid[7],
+			uuid[8],  uuid[9],  uuid[10], uuid[11],
+			uuid[12], uuid[13], uuid[14], uuid[15]);
+	}
+}
+
+static void print_vfport(FILE *fp, struct rtattr *vfport)
+{
+	struct rtattr *port[IFLA_PORT_MAX+1];
+
+	if (vfport->rta_type != IFLA_VF_PORT) {
+		fprintf(stderr, "BUG: rta type is %d\n", vfport->rta_type);
+		return;
+	}
+
+	parse_rtattr_nested(port, IFLA_PORT_MAX, vfport);
+	print_port(fp, port);
+}
+
 static void print_vfinfo(FILE *fp, struct rtattr *vfinfo)
 {
 	struct ifla_vf_mac *vf_mac;
@@ -421,6 +522,20 @@ int print_linkinfo(const struct sockaddr_nl *who,
 			print_vfinfo(fp, i);
 	}
 
+	if (do_link && tb[IFLA_PORT_SELF]) {
+		struct rtattr *port[IFLA_PORT_MAX+1];
+		parse_rtattr_nested(port, IFLA_PORT_MAX, tb[IFLA_PORT_SELF]);
+		print_port(fp, port);
+	}
+
+	if (do_link && tb[IFLA_VF_PORTS] && tb[IFLA_NUM_VF]) {
+		struct rtattr *i, *vfports = tb[IFLA_VF_PORTS];
+		int rem = RTA_PAYLOAD(vfports);
+		for (i = RTA_DATA(vfports); RTA_OK(i, rem);
+			i = RTA_NEXT(i, rem))
+			print_vfport(fp, i);
+	}
+
 	fprintf(fp, "\n");
 	fflush(fp);
 	return 0;
diff --git a/ip/iplink.c b/ip/iplink.c
index cb2c4f5..0a29ae5 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -68,14 +68,22 @@ void iplink_usage(void)
 	fprintf(stderr, "	                  [ mtu MTU ]\n");
 	fprintf(stderr, "	                  [ netns PID ]\n");
 	fprintf(stderr, "			  [ alias NAME ]\n");
+	fprintf(stderr, "			  [ port MODE { PROFILE | VSI } ]\n");
 	fprintf(stderr, "	                  [ vf NUM [ mac LLADDR ]\n");
 	fprintf(stderr, "				   [ vlan VLANID [ qos VLAN-QOS ] ]\n");
-	fprintf(stderr, "				   [ rate TXRATE ] ] \n");
+	fprintf(stderr, "				   [ rate TXRATE ]\n");
+	fprintf(stderr, "				   [ port MODE { PROFILE | VSI } ] ]\n");
 	fprintf(stderr, "       ip link show [ DEVICE ]\n");
 
 	if (iplink_have_newlink()) {
 		fprintf(stderr, "\n");
 		fprintf(stderr, "TYPE := { vlan | veth | vcan | dummy | ifb | macvlan | can }\n");
+		fprintf(stderr, "MODE := { assoc | preassoc | preassocrr | disassoc }\n");
+		fprintf(stderr, "PROFILE := profile PROFILE\n");
+		fprintf(stderr, "           [ instance UUID ]\n");
+		fprintf(stderr, "           [ host UUID ]\n");
+		fprintf(stderr, "VSI := vsi mgr MGRID type VTID ver VER\n");
+		fprintf(stderr, "       [ instance UUID ]\n");
 	}
 	exit(-1);
 }
@@ -176,55 +184,168 @@ struct iplink_req {
 	char			buf[1024];
 };
 
-int iplink_parse_vf(int vf, int *argcp, char ***argvp,
-			   struct iplink_req *req)
+void iplink_parse_port(int vf, int *argcp, char ***argvp,
+		       struct iplink_req *req)
+{
+	int argc = *argcp;
+	char **argv = *argvp;
+	struct rtattr *nest, *nest_inner = NULL;
+	struct ifla_port_vsi port_vsi;
+	char *port_profile = NULL;
+	char *instance_uuid = NULL;
+	char *host_uuid = NULL;
+	unsigned char uuid[16];
+	char *uuid_fmt = "%02X%02X%02X%02X-%02X%02X-%02X%02X-"
+		"%02X%02X-%02X%02X%02X%02X%02X%02X";
+	int parsed;
+	int manager_id = -1;
+	int type_id = -1;
+	int type_id_version = -1;
+	int request = -1;
+	int vsi = 0;
+
+	if (NEXT_ARG_OK()) {
+		NEXT_ARG();
+		if (matches(*argv, "assoc") == 0)
+			request = PORT_REQUEST_ASSOCIATE;
+		else if (matches(*argv, "preassoc") == 0)
+			request = PORT_REQUEST_PREASSOCIATE;
+		else if (matches(*argv, "preassocrr") == 0)
+			request = PORT_REQUEST_PREASSOCIATE_RR;
+		else if (matches(*argv, "disassoc") == 0)
+			request = PORT_REQUEST_DISASSOCIATE;
+	}
+
+	while (NEXT_ARG_OK()) {
+		NEXT_ARG();
+		if (matches(*argv, "vsi") == 0) {
+			vsi = 1;
+		} else if (matches(*argv, "mgr") == 0) {
+			NEXT_ARG();
+			if (get_integer(&manager_id, *argv, 0))
+				invarg("Invalid \"mgr\" value\n", *argv);
+		} else if (matches(*argv, "type") == 0) {
+			NEXT_ARG();
+			if (get_integer(&type_id, *argv, 0))
+				invarg("Invalid \"type\" value\n", *argv);
+		} else if (matches(*argv, "ver") == 0) {
+			NEXT_ARG();
+			if (get_integer(&type_id_version, *argv, 0))
+				invarg("Invalid \"ver\" value\n", *argv);
+		} else if (matches(*argv, "profile") == 0) {
+			NEXT_ARG();
+			port_profile = *argv;
+		} else if (matches(*argv, "instance") == 0) {
+			NEXT_ARG();
+			instance_uuid = *argv;
+		} else if (matches(*argv, "host") == 0) {
+			NEXT_ARG();
+			host_uuid = *argv;
+		} else {
+			/* rewind arg */
+			PREV_ARG();
+			break;
+		}
+	}
+
+	if (argc == *argcp)
+		incomplete_command();
+
+	if (vf == PORT_SELF_VF) {
+		nest = addattr_nest(&req->n, sizeof(*req), IFLA_PORT_SELF);
+	} else {
+		nest = addattr_nest(&req->n, sizeof(*req), IFLA_VF_PORTS);
+		nest_inner = addattr_nest(&req->n, sizeof(*req), IFLA_VF_PORT);
+		addattr_l(&req->n, sizeof(*req), IFLA_PORT_VF,
+			(uint32_t *)&vf, sizeof(uint32_t));
+	}
+
+	if (port_profile)
+		addattr_l(&req->n, sizeof(*req), IFLA_PORT_PROFILE,
+			port_profile, strlen(port_profile) + 1);
+
+	if (instance_uuid) {
+		parsed = sscanf(instance_uuid, uuid_fmt,
+			&uuid[0],  &uuid[1],  &uuid[2],  &uuid[3],
+			&uuid[4],  &uuid[5],  &uuid[6],  &uuid[7],
+			&uuid[8],  &uuid[9],  &uuid[10], &uuid[11],
+			&uuid[12], &uuid[13], &uuid[14], &uuid[15]);
+		if (parsed != sizeof(uuid))
+			invarg("Invalid \"uuid\" value\n", instance_uuid);
+		addattr_l(&req->n, sizeof(*req), IFLA_PORT_INSTANCE_UUID,
+			uuid, sizeof(uuid));
+	}
+
+	if (host_uuid) {
+		parsed = sscanf(host_uuid, uuid_fmt,
+			&uuid[0],  &uuid[1],  &uuid[2],  &uuid[3],
+			&uuid[4],  &uuid[5],  &uuid[6],  &uuid[7],
+			&uuid[8],  &uuid[9],  &uuid[10], &uuid[11],
+			&uuid[12], &uuid[13], &uuid[14], &uuid[15]);
+		if (parsed != sizeof(uuid))
+			invarg("Invalid \"uuid\" value\n", host_uuid);
+		addattr_l(&req->n, sizeof(*req), IFLA_PORT_HOST_UUID,
+			uuid, sizeof(uuid));
+	}
+
+	if (vsi) {
+		port_vsi.vsi_mgr_id = manager_id;
+		memcpy(&port_vsi.vsi_type_id, &type_id,
+			sizeof(port_vsi.vsi_type_id));
+		port_vsi.vsi_type_version = type_id_version;
+		addattr_l(&req->n, sizeof(*req), IFLA_PORT_VSI_TYPE,
+			&port_vsi, sizeof(port_vsi));
+	}
+
+	addattr_l(&req->n, sizeof(*req), IFLA_PORT_REQUEST,
+		&request, 1);
+
+	if (nest_inner)
+		addattr_nest_end(&req->n, nest_inner);
+	addattr_nest_end(&req->n, nest);
+
+	*argcp = argc;
+	*argvp = argv;
+}
+
+void iplink_parse_vf(int vf, int *argcp, char ***argvp,
+		     struct iplink_req *req)
 {
 	int len, argc = *argcp;
 	char **argv = *argvp;
+	struct rtattr *vflist;
 	struct rtattr *vfinfo;
-
-	vfinfo = addattr_nest(&req->n, sizeof(*req), IFLA_VF_INFO);
+	char *mac = NULL;
+	char *vlan = NULL;
+	char *qos = NULL;
+	char *rate = NULL;
+	struct ifla_vf_mac ivm = { .vf = vf, };
+	struct ifla_vf_vlan ivv = { .vf = vf, .qos = 0, };
+	struct ifla_vf_tx_rate ivt = { .vf = vf, };
 
 	while (NEXT_ARG_OK()) {
 		NEXT_ARG();
-		if (matches(*argv, "mac") == 0) {
-			struct ifla_vf_mac ivm;
+		if (matches(*argv, "port") == 0) {
+			iplink_parse_port(vf, &argc, &argv, req);
+		} else if (matches(*argv, "mac") == 0) {
 			NEXT_ARG();
-			ivm.vf = vf;
-			len = ll_addr_a2n((char *)ivm.mac, 32, *argv);
-			if (len < 0)
-				return -1;
-			addattr_l(&req->n, sizeof(*req), IFLA_VF_MAC, &ivm, sizeof(ivm));
+			mac = *argv;
 		} else if (matches(*argv, "vlan") == 0) {
-			struct ifla_vf_vlan ivv;
 			NEXT_ARG();
-			if (get_unsigned(&ivv.vlan, *argv, 0)) {
-				invarg("Invalid \"vlan\" value\n", *argv);
-			}
-			ivv.vf = vf;
-			ivv.qos = 0;
+			vlan = *argv;
 			if (NEXT_ARG_OK()) {
 				NEXT_ARG();
 				if (matches(*argv, "qos") == 0) {
 					NEXT_ARG();
-					if (get_unsigned(&ivv.qos, *argv, 0)) {
-						invarg("Invalid \"qos\" value\n", *argv);
-					}
+					qos = *argv;
 				} else {
 					/* rewind arg */
 					PREV_ARG();
 				}
 			}
-			addattr_l(&req->n, sizeof(*req), IFLA_VF_VLAN, &ivv, sizeof(ivv));
 		} else if (matches(*argv, "rate") == 0) {
-			struct ifla_vf_tx_rate ivt;
 			NEXT_ARG();
-			if (get_unsigned(&ivt.rate, *argv, 0)) {
-				invarg("Invalid \"rate\" value\n", *argv);
-			}
-			ivt.vf = vf;
-			addattr_l(&req->n, sizeof(*req), IFLA_VF_TX_RATE, &ivt, sizeof(ivt));
-		
+			rate = *argv;
 		} else {
 			/* rewind arg */
 			PREV_ARG();
@@ -235,11 +356,43 @@ int iplink_parse_vf(int vf, int *argcp, char ***argvp,
 	if (argc == *argcp)
 		incomplete_command();
 
-	addattr_nest_end(&req->n, vfinfo);
+	if (mac || vlan || rate) {
+
+		vflist = addattr_nest(&req->n, sizeof(*req), IFLA_VFINFO_LIST);
+		vfinfo = addattr_nest(&req->n, sizeof(*req), IFLA_VF_INFO);
+
+		if (mac) {
+			len = ll_addr_a2n((char *)ivm.mac, 32, mac);
+			if (len < 0)
+				invarg("Invalid \"mac\" value\n", mac);
+			addattr_l(&req->n, sizeof(*req), IFLA_VF_MAC,
+				&ivm, sizeof(ivm));
+		}
+
+		if (vlan) {
+			if (get_unsigned(&ivv.vlan, vlan, 0))
+				invarg("Invalid \"vlan\" value\n", vlan);
+			if (qos) {
+				if (get_unsigned(&ivv.qos, qos, 0))
+					invarg("Invalid \"qos\" value\n", qos);
+			}
+			addattr_l(&req->n, sizeof(*req), IFLA_VF_VLAN,
+				&ivv, sizeof(ivv));
+		}
+
+		if (rate) {
+			if (get_unsigned(&ivt.rate, rate, 0))
+				invarg("Invalid \"rate\" value\n", rate);
+			addattr_l(&req->n, sizeof(*req), IFLA_VF_TX_RATE,
+				&ivt, sizeof(ivt));
+		}
+
+		addattr_nest_end(&req->n, vfinfo);
+		addattr_nest_end(&req->n, vflist);
+	}
 
 	*argcp = argc;
 	*argvp = argv;
-	return 0;
 }
 
 
@@ -349,18 +502,14 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 				req->i.ifi_flags |= IFF_NOARP;
 			} else
 				return on_off("noarp");
+		} else if (strcmp(*argv, "port") == 0) {
+			iplink_parse_port(vf, &argc, &argv, req);
 		} else if (strcmp(*argv, "vf") == 0) {
-			struct rtattr *vflist;
 			NEXT_ARG();
 			if (get_integer(&vf,  *argv, 0)) {
 				invarg("Invalid \"vf\" value\n", *argv);
 			}
-			vflist = addattr_nest(&req->n, sizeof(*req),
-					      IFLA_VFINFO_LIST);
-			len = iplink_parse_vf(vf, &argc, &argv, req);
-			if (len < 0)
-				return -1;
-			addattr_nest_end(&req->n, vflist);
+			iplink_parse_vf(vf, &argc, &argv, req);
 #ifdef IFF_DYNAMIC
 		} else if (matches(*argv, "dynamic") == 0) {
 			NEXT_ARG();

