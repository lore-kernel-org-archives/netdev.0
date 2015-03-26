From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: [RFC iproute2 2/2] iproute2: allow user to set IPv6 nexthop for IPv4 route
Date: Thu, 26 Mar 2015 17:05:28 -0400
Message-ID: <1427403928-1342-3-git-send-email-gospo@cumulusnetworks.com>
References: <1427403928-1342-1-git-send-email-gospo@cumulusnetworks.com>
Cc: Andy Gospodarek <gospo@cumulusnetworks.com>
To: netdev@vger.kernel.org, Bjornar Ness <bjornar.ness@gmail.com>,
	Sowmini Varadhan <sowmini05@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f41.google.com ([209.85.213.41]:33371 "EHLO
	mail-yh0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752298AbbCZVGc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 17:06:32 -0400
Received: by yhpt93 with SMTP id t93so32230201yhp.0
        for <netdev@vger.kernel.org>; Thu, 26 Mar 2015 14:06:32 -0700 (PDT)
In-Reply-To: <1427403928-1342-1-git-send-email-gospo@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This will allow a user to run a command like this:

$ ip route add 20.0.0.0/24 via 2100::2 dev p7p1

so that an IPv6 network can be used as a carrier for IPv4 traffic.  This
is extremely useful in many datecenter environments especially where
autoconfiguration of IPv6 helps minimize the need to configure
invdividual addresses on each interface.

This feature does not encompass all that is needed to support RFC-5549,
but this demonstrates the netlink infrastructure needed to correctly
enable the kernel infrastructure.  For more informtion the full RFC is
here: http://www.ietf.org/rfc/rfc5549.txt.

Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
---
 include/linux/rtnetlink.h |  4 ++++
 ip/iproute.c              | 18 +++++++++++++++---
 lib/utils.c               |  4 +++-
 3 files changed, 22 insertions(+), 4 deletions(-)

diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 3eb7810..fff7095 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -303,6 +303,10 @@ enum rtattr_type_t {
 	RTA_TABLE,
 	RTA_MARK,
 	RTA_MFC_STATS,
+	RTA_VIA,
+	RTA_NEWDST,
+	RTA_PREF,
+	RTA_GATEWAY6,
 	__RTA_MAX
 };
 
diff --git a/ip/iproute.c b/ip/iproute.c
index 024d401..ed66cb8 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -384,6 +384,15 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 				    RTA_DATA(tb[RTA_GATEWAY]),
 				    abuf, sizeof(abuf)));
 	}
+
+	if (tb[RTA_GATEWAY6] && filter.rvia.bitlen != host_len) {
+		fprintf(fp, "via %s ",
+			format_host(AF_INET6,
+				    RTA_PAYLOAD(tb[RTA_GATEWAY6]),
+				    RTA_DATA(tb[RTA_GATEWAY6]),
+				    abuf, sizeof(abuf)));
+	}
+
 	if (tb[RTA_OIF] && filter.oifmask != -1)
 		fprintf(fp, "dev %s ", ll_index_to_name(*(int*)RTA_DATA(tb[RTA_OIF])));
 
@@ -647,7 +656,7 @@ static int parse_one_nh(struct rtmsg *r, struct rtattr *rta,
 			inet_prefix addr;
 			NEXT_ARG();
 			get_addr(&addr, *argv, r->rtm_family);
-			if (r->rtm_family == AF_UNSPEC)
+			if (addr.family == AF_UNSPEC)
 				r->rtm_family = addr.family;
 			rta_addattr_l(rta, 4096, RTA_GATEWAY, &addr.data, addr.bytelen);
 			rtnh->rtnh_len += sizeof(struct rtattr) + addr.bytelen;
@@ -761,9 +770,12 @@ static int iproute_modify(int cmd, unsigned flags, int argc, char **argv)
 			gw_ok = 1;
 			NEXT_ARG();
 			get_addr(&addr, *argv, req.r.rtm_family);
-			if (req.r.rtm_family == AF_UNSPEC)
+			if (addr.family == AF_UNSPEC)
 				req.r.rtm_family = addr.family;
-			addattr_l(&req.n, sizeof(req), RTA_GATEWAY, &addr.data, addr.bytelen);
+			if (addr.family == AF_INET)
+				addattr_l(&req.n, sizeof(req), RTA_GATEWAY, &addr.data, addr.bytelen);
+			else if (addr.family == AF_INET6)
+				addattr_l(&req.n, sizeof(req), RTA_GATEWAY6, &addr.data, addr.bytelen);
 		} else if (strcmp(*argv, "from") == 0) {
 			inet_prefix addr;
 			NEXT_ARG();
diff --git a/lib/utils.c b/lib/utils.c
index 0d08a86..feadbbf 100644
--- a/lib/utils.c
+++ b/lib/utils.c
@@ -399,7 +399,7 @@ int get_addr_1(inet_prefix *addr, const char *name, int family)
 
 	if (strchr(name, ':')) {
 		addr->family = AF_INET6;
-		if (family != AF_UNSPEC && family != AF_INET6)
+		if (family != AF_UNSPEC && family != AF_INET6 && family != AF_INET)
 			return -1;
 		if (inet_pton(AF_INET6, name, addr->data) <= 0)
 			return -1;
@@ -712,6 +712,8 @@ static const char *resolve_address(const void *addr, int len, int af)
 const char *format_host(int af, int len, const void *addr,
 			char *buf, int buflen)
 {
+	if (af == AF_INET && len == 16)
+		af = AF_INET6;
 #ifdef RESOLVE_HOSTNAMES
 	if (resolve_hosts) {
 		const char *n;
-- 
1.9.3
