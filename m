From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 7/8] iproute2: Add support for the RTA_NEWDST attribute.
Date: Sun, 15 Mar 2015 14:53:11 -0500
Message-ID: <877fuinil4.fsf_-_@x220.int.ebiederm.org>
References: <87bnjwspek.fsf@x220.int.ebiederm.org>
	<c3ad7d77783046d38e5b23b5e1fe0f71@BRMWP-EXMB11.corp.brocade.com>
	<20150315123337.2694183a@urahara>
	<87lhiyoxnw.fsf@x220.int.ebiederm.org>
	<87bnjuoxe8.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "netdev\@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:34947 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751962AbbCOT4z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 15:56:55 -0400
In-Reply-To: <87bnjuoxe8.fsf_-_@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Sun, 15 Mar 2015 14:47:59 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This attribute is like RTA_DST except it specifies the destination
address to place on a packet when it leaves the host.  For ip based
protocols this is destination NAT and not a common part of forwarding.
For protocols like MPLS label swapping is something that typically
happens on every hop.

There is likely to be a RTA_NEWSRC at some point so RTA_NEWDST
is printed as "as to"  and can be specified either as "as to"
or just "as"

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/linux/rtnetlink.h |  1 +
 ip/iproute.c              | 19 ++++++++++++++++++-
 man/man8/ip-route.8.in    |  5 +++++
 3 files changed, 24 insertions(+), 1 deletion(-)

diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 03e4c8df8e60..0d4100535bd7 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -304,6 +304,7 @@ enum rtattr_type_t {
 	RTA_MARK,
 	RTA_MFC_STATS,
 	RTA_VIA,
+	RTA_NEWDST,
 	__RTA_MAX
 };
 
diff --git a/ip/iproute.c b/ip/iproute.c
index c6ee411fdd56..2e691b8ef294 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -77,7 +77,7 @@ static void usage(void)
 	fprintf(stderr, "INFO_SPEC := NH OPTIONS FLAGS [ nexthop NH ]...\n");
 	fprintf(stderr, "NH := [ via [ FAMILY ] ADDRESS ] [ dev STRING ] [ weight NUMBER ] NHFLAGS\n");
 	fprintf(stderr, "FAMILY := [ inet | inet6 | ipx | dnet | bridge | link ]");
-	fprintf(stderr, "OPTIONS := FLAGS [ mtu NUMBER ] [ advmss NUMBER ]\n");
+	fprintf(stderr, "OPTIONS := FLAGS [ mtu NUMBER ] [ advmss NUMBER ] [ as [ to ] ADDRESS ]\n");
 	fprintf(stderr, "           [ rtt TIME ] [ rttvar TIME ] [ reordering NUMBER ]\n");
 	fprintf(stderr, "           [ window NUMBER] [ cwnd NUMBER ] [ initcwnd NUMBER ]\n");
 	fprintf(stderr, "           [ ssthresh NUMBER ] [ realms REALM ] [ src ADDRESS ]\n");
@@ -388,6 +388,13 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 	} else if (r->rtm_src_len) {
 		fprintf(fp, "from 0/%u ", r->rtm_src_len);
 	}
+	if (tb[RTA_NEWDST]) {
+		fprintf(fp, "as to %s ", format_host(r->rtm_family,
+						  RTA_PAYLOAD(tb[RTA_NEWDST]),
+						  RTA_DATA(tb[RTA_NEWDST]),
+						  abuf, sizeof(abuf))
+			);
+	}
 	if (r->rtm_tos && filter.tosmask != -1) {
 		SPRINT_BUF(b1);
 		fprintf(fp, "tos %s ", rtnl_dsfield_n2a(r->rtm_tos, b1, sizeof(b1)));
@@ -800,6 +807,16 @@ static int iproute_modify(int cmd, unsigned flags, int argc, char **argv)
 			if (req.r.rtm_family == AF_UNSPEC)
 				req.r.rtm_family = addr.family;
 			addattr_l(&req.n, sizeof(req), RTA_PREFSRC, &addr.data, addr.bytelen);
+		} else if (strcmp(*argv, "as") == 0) {
+			inet_prefix addr;
+			NEXT_ARG();
+			if (strcmp(*argv, "to") == 0) {
+				NEXT_ARG();
+			}
+			get_addr(&addr, *argv, req.r.rtm_family);
+			if (req.r.rtm_family == AF_UNSPEC)
+				req.r.rtm_family = addr.family;
+			addattr_l(&req.n, sizeof(req), RTA_NEWDST, &addr.data, addr.bytelen);
 		} else if (strcmp(*argv, "via") == 0) {
 			inet_prefix addr;
 			int family;
diff --git a/man/man8/ip-route.8.in b/man/man8/ip-route.8.in
index 906cfea0cd6b..5112344971c0 100644
--- a/man/man8/ip-route.8.in
+++ b/man/man8/ip-route.8.in
@@ -98,6 +98,11 @@ replace " } "
 .IR NUMBER " ] [ "
 .B  advmss
 .IR NUMBER " ] [ "
+.B  as
+[
+.B to
+]
+.IR ADDRESS " ]"
 .B  rtt
 .IR TIME " ] [ "
 .B  rttvar
-- 
2.2.1
