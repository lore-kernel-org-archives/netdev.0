From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [RFC] iproute2: display devconf info
Date: Thu, 22 Aug 2013 10:23:54 -0700
Message-ID: <20130822102354.31b0161d@samsung-9>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:51491 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753429Ab3HVRX7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 13:23:59 -0400
Received: by mail-pd0-f178.google.com with SMTP id w10so2141549pde.23
        for <netdev@vger.kernel.org>; Thu, 22 Aug 2013 10:23:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Would this be useful, it allows displaying devconf information with ip command.
Open to suggestions about format, and how to condense the display.

$ ip -d addr show dev wlan0

3: wlan0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
    link/ether xx:xx:xx:xx:xx:xx brd ff:ff:ff:ff:ff:ff
   ipv4 conf:
        forwarding:1
        accept redirects:1
        secure redirects:1
        send redirects:1
        shared media:1
        accept source route:1
   ipv6 conf:
        hoplimit:64
        mtu6:1500
        accept ra:2
        accept redirects:1
        autoconf:1
        dad transmits:1
        rtr solicits:3
        rtr solicit interval:4000
        rtr solicit delay:1000
        use tempaddr:2
        temp valid lft:604800
        temp prefered lft:86400
        regen max retry:3
        max desync factor:600
        max addresses:16
        accept ra defrtr:1
        accept ra pinfo:1
        accept ra rtr pref:1
        rtr probe interval:60000
        accept dad:1
    inet 192.168.1.189/24 brd 192.168.1.255 scope global wlan0
       valid_lft forever preferred_lft forever
    inet6 fe80::c685:8ff:feca:841f/64 scope link 
       valid_lft forever preferred_lft forever


---
 ip/ipaddress.c |  123 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 123 insertions(+)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 1c3e4da..f49e246 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -386,6 +386,126 @@ static void print_link_stats(FILE *fp, const struct rtnl_link_stats *s)
 	}
 }
 
+static const char *ipv4_devconf[] = {
+	"forwarding",
+	"mc forwarding",
+	"proxy arp",
+	"accept redirects",
+	"secure redirects",
+	"send redirects",
+	"shared media",
+	"rp filter",
+	"accept source route",
+	"bootp relay",
+	"log martians",
+	"tag",
+	"arpfilter",
+	"medium id",
+	"noxfrm",
+	"nopolicy",
+	"force igmp version",
+	"arp announce",
+	"arp ignore",
+	"promote secondaries",
+	"arp accept",
+	"arp notify",
+	"accept local",
+	"src vmark",
+	"proxy arp pvlan",
+	"route localnet",
+};
+
+static void print_inet_conf(FILE *fp, struct rtattr *ininfo)
+{
+	struct rtattr *rta, *tb[IFLA_INET_MAX+1];
+
+	parse_rtattr_nested(tb, IFLA_INET_MAX, ininfo);
+
+	if ((rta = tb[IFLA_INET_CONF])) {
+		const __u32 *conf = (__u32 *)RTA_DATA(rta);
+		unsigned i;
+
+		fprintf(fp, "\n   ipv4 conf:");
+		for (i = 0; i < rta->rta_len && i < ARRAY_SIZE(ipv4_devconf); i++) {
+			if (conf[i] != 0)
+				fprintf(fp, "\n        %s:%u",
+					ipv4_devconf[i], conf[i]);
+		}
+	}
+}
+
+static const char *ipv6_devconf[] = {
+	"forwarding",
+	"hoplimit",
+	"mtu6",
+	"accept ra",
+	"accept redirects",
+	"autoconf",
+	"dad transmits",
+	"rtr solicits",
+	"rtr solicit interval",
+	"rtr solicit delay",
+	"use tempaddr",
+	"temp valid lft",
+	"temp prefered lft",
+	"regen max retry",
+	"max desync factor",
+	"max addresses",
+	"force mld version",
+	"accept ra defrtr",
+	"accept ra pinfo",
+	"accept ra rtr pref",
+	"rtr probe interval",
+	"accept ra rt info max plen",
+	"proxy ndp",
+	"optimistic dad",
+	"accept source route",
+	"mc forwarding",
+	"disable ipv6",
+	"accept dad",
+	"force tllao",
+	"ndisc notify",
+};
+
+static void print_inet6_conf(FILE *fp, struct rtattr *in6info)
+{
+	struct rtattr *rta, *tb[IFLA_INET6_MAX+1];
+
+	parse_rtattr_nested(tb, IFLA_INET6_MAX, in6info);
+
+	if ((rta = tb[IFLA_INET6_CONF])) {
+		const __u32 *conf = (__u32 *)RTA_DATA(rta);
+		unsigned i;
+
+		fprintf(fp, "\n   ipv6 conf:");
+		for (i = 0; i < rta->rta_len && i < ARRAY_SIZE(ipv6_devconf); i++) {
+			if (conf[i] != 0)
+				fprintf(fp, "\n        %s:%u",
+					ipv6_devconf[i], conf[i]);
+		}
+	}
+}
+
+static void print_afinfo(FILE *fp, struct rtattr *afinfo)
+{
+	struct rtattr *tb[AF_MAX+1];
+
+	if (afinfo->rta_type != IFLA_AF_SPEC) {
+		fprintf(stderr, "BUG: rta type is %d\n", afinfo->rta_type);
+		return;
+	}
+
+	parse_rtattr_nested(tb, AF_MAX, afinfo);
+
+	if (tb[AF_INET] &&
+	    (!filter.family || filter.family == AF_INET))
+		print_inet_conf(fp, tb[AF_INET]);
+
+	if (tb[AF_INET6] &&
+	    (!filter.family || filter.family == AF_INET))
+		print_inet6_conf(fp, tb[AF_INET6]);
+}
+
 int print_linkinfo(const struct sockaddr_nl *who,
 		   struct nlmsghdr *n, void *arg)
 {
@@ -509,6 +629,9 @@ int print_linkinfo(const struct sockaddr_nl *who,
 			print_link_stats(fp, RTA_DATA(tb[IFLA_STATS]));
 	}
 
+	if (show_details && tb[IFLA_AF_SPEC])
+		print_afinfo(fp, tb[IFLA_AF_SPEC]);
+
 	if (do_link && tb[IFLA_VFINFO_LIST] && tb[IFLA_NUM_VF]) {
 		struct rtattr *i, *vflist = tb[IFLA_VFINFO_LIST];
 		int rem = RTA_PAYLOAD(vflist);
-- 
1.7.10.4
