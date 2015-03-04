From: Madhu Challa <challa@noironetworks.com>
Subject: [PATCH iproute2 net-next 2/2] Enable configuring multicast group join / leave at IP level.
Date: Wed,  4 Mar 2015 10:30:10 -0800
Message-ID: <1425493810-2537-3-git-send-email-challa@noironetworks.com>
References: <1425493810-2537-1-git-send-email-challa@noironetworks.com>
Cc: Madhu Challa <challa@noironetworks.com>
To: stephen@networkplumber.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:43837 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758514AbbCDSrZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 13:47:25 -0500
Received: by pablj1 with SMTP id lj1so26464171pab.10
        for <netdev@vger.kernel.org>; Wed, 04 Mar 2015 10:47:24 -0800 (PST)
In-Reply-To: <1425493810-2537-1-git-send-email-challa@noironetworks.com>
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
mechanisms that need to receive multicast traffic.

example:
ip address add 224.1.1.10/24 dev eth5 autojoin
ip address del 224.1.1.10/24 dev eth5
---
 ip/ipaddress.c | 26 +++++++++++++++++++++++++-
 1 file changed, 25 insertions(+), 1 deletion(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 99a6ab5..e582da0 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -85,7 +85,7 @@ static void usage(void)
 	fprintf(stderr, "           [-]tentative | [-]deprecated | [-]dadfailed | temporary |\n");
 	fprintf(stderr, "           CONFFLAG-LIST ]\n");
 	fprintf(stderr, "CONFFLAG-LIST := [ CONFFLAG-LIST ] CONFFLAG\n");
-	fprintf(stderr, "CONFFLAG  := [ home | nodad | mngtmpaddr | noprefixroute ]\n");
+	fprintf(stderr, "CONFFLAG  := [ home | nodad | mngtmpaddr | noprefixroute | autojoin ]\n");
 	fprintf(stderr, "LIFETIME := [ valid_lft LFT ] [ preferred_lft LFT ]\n");
 	fprintf(stderr, "LFT := forever | SECONDS\n");
 
@@ -915,6 +915,10 @@ int print_addrinfo(const struct sockaddr_nl *who, struct nlmsghdr *n,
 		ifa_flags &= ~IFA_F_NOPREFIXROUTE;
 		fprintf(fp, "noprefixroute ");
 	}
+	if (ifa_flags & IFA_F_MCAUTOJOIN) {
+		ifa_flags &= ~IFA_F_MCAUTOJOIN;
+		fprintf(fp, "autojoin ");
+	}
 	if (!(ifa_flags & IFA_F_PERMANENT)) {
 		fprintf(fp, "dynamic ");
 	} else
@@ -1354,6 +1358,9 @@ static int ipaddr_list_flush_or_save(int argc, char **argv, int action)
 		} else if (strcmp(*argv, "noprefixroute") == 0) {
 			filter.flags |= IFA_F_NOPREFIXROUTE;
 			filter.flagmask |= IFA_F_NOPREFIXROUTE;
+		} else if (strcmp(*argv, "autojoin") == 0) {
+			filter.flags |= IFA_F_MCAUTOJOIN;
+			filter.flagmask |= IFA_F_MCAUTOJOIN;
 		} else if (strcmp(*argv, "dadfailed") == 0) {
 			filter.flags |= IFA_F_DADFAILED;
 			filter.flagmask |= IFA_F_DADFAILED;
@@ -1558,6 +1565,16 @@ static int default_scope(inet_prefix *lcl)
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
@@ -1665,6 +1682,8 @@ static int ipaddr_modify(int cmd, int flags, int argc, char **argv)
 			ifa_flags |= IFA_F_MANAGETEMPADDR;
 		} else if (strcmp(*argv, "noprefixroute") == 0) {
 			ifa_flags |= IFA_F_NOPREFIXROUTE;
+		} else if (strcmp(*argv, "autojoin") == 0) {
+			ifa_flags |= IFA_F_MCAUTOJOIN;
 		} else {
 			if (strcmp(*argv, "local") == 0) {
 				NEXT_ARG();
@@ -1755,6 +1774,11 @@ static int ipaddr_modify(int cmd, int flags, int argc, char **argv)
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
