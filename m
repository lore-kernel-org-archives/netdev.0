From: Mahesh Bandewar <mahesh@bandewar.net>
Subject: [PATCH] ip/ipvlan: enhance ability to add mode flags to existing modes
Date: Mon, 30 Oct 2017 13:57:51 -0700
Message-ID: <20171030205751.8280-1-mahesh@bandewar.net>
Cc: Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>,
        Changgong Li <chonggangli@google.com>,
        Mahesh Bandewar <mahesh@bandewar.net>,
        Mahesh Bandewar <maheshb@google.com>
To: Netdev <netdev@vger.kernel.org>,
        Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:54936 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932821AbdJ3U55 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 16:57:57 -0400
Received: by mail-io0-f195.google.com with SMTP id e89so30275347ioi.11
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2017 13:57:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>

IPvlan supported bridge-only functionality prior to commits
a190d04db937 ('ipvlan: introduce 'private' attribute for all
existing modes.') and fe89aa6b250c ('ipvlan: implement VEPA mode').
These two commits allow to configure the VEPA and private modes now.
This patch adds those options in ip command.

e.g.
  bash:~# ip link add link eth0 name ipvl0 type ipvlan mode l2 private
  -or-
  bash:~# ip link add link eth0 type ipvl0 type ipvlan mode l2 vepa

Also the output will reflect the mode and the mode-flag accordingly.
e.g.
  bash:~# ip -details link show ipvl0
  4: ipvl0@eth0: <BROADCAST,MULTICAST> mtu 1500 qdisc ...
     link/ether 00:1a:11:44:a5:3e brd ff:ff:ff:ff:ff:ff promiscuity 0
     ipvlan  mode l2 private addrgenmode eui64 numtxqueues 1 ...

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 include/uapi/linux/if_link.h |  4 ++++
 ip/iplink_ipvlan.c           | 35 ++++++++++++++++++++++++++++++++++-
 2 files changed, 38 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index dafe0a6e0421..35bc598566e0 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -463,6 +463,7 @@ enum macsec_validation_type {
 enum {
 	IFLA_IPVLAN_UNSPEC,
 	IFLA_IPVLAN_MODE,
+	IFLA_IPVLAN_FLAGS,
 	__IFLA_IPVLAN_MAX
 };
 
@@ -475,6 +476,9 @@ enum ipvlan_mode {
 	IPVLAN_MODE_MAX
 };
 
+#define IPVLAN_F_PRIVATE	0x01
+#define IPVLAN_F_VEPA		0x02
+
 /* VXLAN section */
 enum {
 	IFLA_VXLAN_UNSPEC,
diff --git a/ip/iplink_ipvlan.c b/ip/iplink_ipvlan.c
index 9f48309ee030..8889808508fe 100644
--- a/ip/iplink_ipvlan.c
+++ b/ip/iplink_ipvlan.c
@@ -20,12 +20,21 @@
 
 static void ipvlan_explain(FILE *f)
 {
-	fprintf(f, "Usage: ... ipvlan [ mode { l2 | l3  | l3s } ]\n");
+	fprintf(f,
+		"Usage: ... ipvlan [ mode MODE ] [ FLAGS ]\n"
+		"\n"
+		"MODE: l3 | l3s | l2\n"
+		"FLAGS: bridge | private | vepa\n"
+		"(first values are the defaults if nothing is specified).\n"
+		);
 }
 
 static int ipvlan_parse_opt(struct link_util *lu, int argc, char **argv,
 			    struct nlmsghdr *n)
 {
+	__u16 flags = 0;
+	bool mflag_given = false;
+
 	while (argc > 0) {
 		if (matches(*argv, "mode") == 0) {
 			__u16 mode = 0;
@@ -43,6 +52,14 @@ static int ipvlan_parse_opt(struct link_util *lu, int argc, char **argv,
 				return -1;
 			}
 			addattr16(n, 1024, IFLA_IPVLAN_MODE, mode);
+		} else if (matches(*argv, "private") == 0 && !mflag_given) {
+			flags |= IPVLAN_F_PRIVATE;
+			mflag_given = true;
+		} else if (matches(*argv, "vepa") == 0 && !mflag_given) {
+			flags |= IPVLAN_F_VEPA;
+			mflag_given = true;
+		} else if (matches(*argv, "bridge") == 0 && !mflag_given) {
+			mflag_given = true;
 		} else if (matches(*argv, "help") == 0) {
 			ipvlan_explain(stderr);
 			return -1;
@@ -55,6 +72,7 @@ static int ipvlan_parse_opt(struct link_util *lu, int argc, char **argv,
 		argc--;
 		argv++;
 	}
+	addattr16(n, 1024, IFLA_IPVLAN_FLAGS, flags);
 
 	return 0;
 }
@@ -75,6 +93,21 @@ static void ipvlan_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 			print_string(PRINT_ANY, "mode", " mode %s ", mode_str);
 		}
 	}
+	if (tb[IFLA_IPVLAN_FLAGS]) {
+		if (RTA_PAYLOAD(tb[IFLA_IPVLAN_FLAGS]) == sizeof(__u16)) {
+			__u16 flags = rta_getattr_u16(tb[IFLA_IPVLAN_FLAGS]);
+
+			if (flags & IPVLAN_F_PRIVATE)
+				print_bool(PRINT_ANY, "private", "private ",
+					   true);
+			else if (flags & IPVLAN_F_VEPA)
+				print_bool(PRINT_ANY, "vepa", "vepa ",
+					   true);
+			else
+				print_bool(PRINT_ANY, "bridge", "bridge ",
+					   true);
+		}
+	}
 }
 
 static void ipvlan_print_help(struct link_util *lu, int argc, char **argv,
-- 
2.15.0.rc2.357.g7e34df9404-goog
