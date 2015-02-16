From: Madhu Challa <challa@noironetworks.com>
Subject: [PATCH]     iproute2: Extend ip address command to enable multicast group join/leave on IP level.
Date: Mon, 16 Feb 2015 14:23:35 -0800
Message-ID: <1424125415-4616-1-git-send-email-challa@noironetworks.com>
Cc: Madhu Challa <challa@noironetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:39292 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751722AbbBPWjJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Feb 2015 17:39:09 -0500
Received: by pdjy10 with SMTP id y10so39200094pdj.6
        for <netdev@vger.kernel.org>; Mon, 16 Feb 2015 14:39:08 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

    Joining multicast group on ethernet level via "ip maddr" command would
    not work if we have an Ethernet switch that does igmp snooping since
    the switch would not replicate multicast packets on ports that did not
    have IGMP reports for the multicast addresses.

    Linux vxlan interfaces created via "ip link add vxlan" have the group option
    that enables then to do the required join.

    By extending ip address command with option "autojoin" we can get similar
    functionality for openvswitch vxlan interfaces as well as other tunneling
    mechanisms that need to receive multicast traffic. The kernel code is
    structured similar to how the vxlan driver does a group join / leave.

    example:
    ip address add 224.1.1.10/24 dev eth5 autojoin
    ip address del 224.1.1.10/24 dev eth5

Signed-off-by: Madhu Challa <challa@noironetworks.com>
---
 include/linux/if_addr.h |  1 +
 ip/ipaddress.c          | 26 +++++++++++++++++++++++++-
 2 files changed, 26 insertions(+), 1 deletion(-)

diff --git a/include/linux/if_addr.h b/include/linux/if_addr.h
index cc375e4..2033adc 100644
--- a/include/linux/if_addr.h
+++ b/include/linux/if_addr.h
@@ -50,6 +50,7 @@ enum {
 #define IFA_F_PERMANENT		0x80
 #define IFA_F_MANAGETEMPADDR	0x100
 #define IFA_F_NOPREFIXROUTE	0x200
+#define IFA_F_MCAUTOJOIN	0x400
 
 struct ifa_cacheinfo {
 	__u32	ifa_prefered;
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 3730424..4f7a81d 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -84,7 +84,7 @@ static void usage(void)
 	fprintf(stderr, "           [-]tentative | [-]deprecated | [-]dadfailed | temporary |\n");
 	fprintf(stderr, "           CONFFLAG-LIST ]\n");
 	fprintf(stderr, "CONFFLAG-LIST := [ CONFFLAG-LIST ] CONFFLAG\n");
-	fprintf(stderr, "CONFFLAG  := [ home | nodad | mngtmpaddr | noprefixroute ]\n");
+	fprintf(stderr, "CONFFLAG  := [ home | nodad | mngtmpaddr | noprefixroute | autojoin ]\n");
 	fprintf(stderr, "LIFETIME := [ valid_lft LFT ] [ preferred_lft LFT ]\n");
 	fprintf(stderr, "LFT := forever | SECONDS\n");
 
@@ -901,6 +901,10 @@ int print_addrinfo(const struct sockaddr_nl *who, struct nlmsghdr *n,
 		ifa_flags &= ~IFA_F_NOPREFIXROUTE;
 		fprintf(fp, "noprefixroute ");
 	}
+	if (ifa_flags & IFA_F_MCAUTOJOIN) {
+		ifa_flags &= ~IFA_F_MCAUTOJOIN;
+		fprintf(fp, "autojoin");
+	}
 	if (!(ifa_flags & IFA_F_PERMANENT)) {
 		fprintf(fp, "dynamic ");
 	} else
@@ -1340,6 +1344,9 @@ static int ipaddr_list_flush_or_save(int argc, char **argv, int action)
 		} else if (strcmp(*argv, "noprefixroute") == 0) {
 			filter.flags |= IFA_F_NOPREFIXROUTE;
 			filter.flagmask |= IFA_F_NOPREFIXROUTE;
+		} else if (strcmp(*argv, "autojoin") == 0) {
+			filter.flags |= IFA_F_MCAUTOJOIN;
+			filter.flagmask |= IFA_F_MCAUTOJOIN;
 		} else if (strcmp(*argv, "dadfailed") == 0) {
 			filter.flags |= IFA_F_DADFAILED;
 			filter.flagmask |= IFA_F_DADFAILED;
@@ -1544,6 +1551,16 @@ static int default_scope(inet_prefix *lcl)
 	return 0;
 }
 
+static bool ipaddr_is_multicast(inet_prefix *a)
+{
+	if (a->family == AF_INET)
+		return IN_MULTICAST(ntohl(a->data[0]));
+	else if (a->family == AF_INET6)
+		return IN6_IS_ADDR_MULTICAST(a->data);
+	else
+		return false;
+}
+
 static int ipaddr_modify(int cmd, int flags, int argc, char **argv)
 {
 	struct {
@@ -1651,6 +1668,8 @@ static int ipaddr_modify(int cmd, int flags, int argc, char **argv)
 			ifa_flags |= IFA_F_MANAGETEMPADDR;
 		} else if (strcmp(*argv, "noprefixroute") == 0) {
 			ifa_flags |= IFA_F_NOPREFIXROUTE;
+		} else if (strcmp(*argv, "autojoin") == 0) {
+			ifa_flags |= IFA_F_MCAUTOJOIN;
 		} else {
 			if (strcmp(*argv, "local") == 0) {
 				NEXT_ARG();
@@ -1741,6 +1760,11 @@ static int ipaddr_modify(int cmd, int flags, int argc, char **argv)
 			  sizeof(cinfo));
 	}
 
+	if ((ifa_flags & IFA_F_MCAUTOJOIN) && !ipaddr_is_multicast(&lcl)) {
+		fprintf(stderr, "autojoin needs multicast address\n");
+		return -1;
+	}
+
 	if (rtnl_talk(&rth, &req.n, 0, 0, NULL) < 0)
 		return -2;
 
-- 
1.9.1
