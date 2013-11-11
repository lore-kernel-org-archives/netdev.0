From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch iproute2 RFC 1/2] add support for extended ifa_flags
Date: Mon, 11 Nov 2013 15:50:41 +0100
Message-ID: <1384181442-23247-1-git-send-email-jiri@resnulli.us>
References: <1384181359-23199-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, thaller@redhat.com,
	stephen@networkplumber.org, hannes@stressinduktion.org,
	vyasevich@gmail.com, dcbw@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f41.google.com ([74.125.83.41]:33746 "EHLO
	mail-ee0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753312Ab3KKOuq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 09:50:46 -0500
Received: by mail-ee0-f41.google.com with SMTP id e53so2517756eek.0
        for <netdev@vger.kernel.org>; Mon, 11 Nov 2013 06:50:45 -0800 (PST)
In-Reply-To: <1384181359-23199-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/linux/if_addr.h |  1 +
 ip/ipaddress.c          | 44 ++++++++++++++++++++++++++++++--------------
 2 files changed, 31 insertions(+), 14 deletions(-)

diff --git a/include/linux/if_addr.h b/include/linux/if_addr.h
index 58b39f4..cced59f 100644
--- a/include/linux/if_addr.h
+++ b/include/linux/if_addr.h
@@ -28,6 +28,7 @@ enum {
 	IFA_ANYCAST,
 	IFA_CACHEINFO,
 	IFA_MULTICAST,
+	IFA_FLAGS,
 	__IFA_MAX,
 };
 
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 1c3e4da..59dbd71 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -541,6 +541,13 @@ static int set_lifetime(unsigned int *lifetime, char *argv)
 	return 0;
 }
 
+static unsigned int get_ifa_flags(struct ifaddrmsg *ifa,
+				  struct rtattr *ifa_flags_attr)
+{
+	return ifa_flags_attr ? rta_getattr_u32(ifa_flags_attr) :
+				ifa->ifa_flags;
+}
+
 int print_addrinfo(const struct sockaddr_nl *who, struct nlmsghdr *n,
 		   void *arg)
 {
@@ -567,6 +574,8 @@ int print_addrinfo(const struct sockaddr_nl *who, struct nlmsghdr *n,
 
 	parse_rtattr(rta_tb, IFA_MAX, IFA_RTA(ifa), n->nlmsg_len - NLMSG_LENGTH(sizeof(*ifa)));
 
+	ifa_flags = get_ifa_flags(ifa, rta_tb[IFA_FLAGS]);
+
 	if (!rta_tb[IFA_LOCAL])
 		rta_tb[IFA_LOCAL] = rta_tb[IFA_ADDRESS];
 	if (!rta_tb[IFA_ADDRESS])
@@ -576,7 +585,7 @@ int print_addrinfo(const struct sockaddr_nl *who, struct nlmsghdr *n,
 		return 0;
 	if ((filter.scope^ifa->ifa_scope)&filter.scopemask)
 		return 0;
-	if ((filter.flags^ifa->ifa_flags)&filter.flagmask)
+	if ((filter.flags ^ ifa_flags) & filter.flagmask)
 		return 0;
 	if (filter.label) {
 		SPRINT_BUF(b1);
@@ -670,36 +679,35 @@ int print_addrinfo(const struct sockaddr_nl *who, struct nlmsghdr *n,
 				    abuf, sizeof(abuf)));
 	}
 	fprintf(fp, "scope %s ", rtnl_rtscope_n2a(ifa->ifa_scope, b1, sizeof(b1)));
-	ifa_flags = ifa->ifa_flags;
-	if (ifa->ifa_flags&IFA_F_SECONDARY) {
+	if (ifa_flags & IFA_F_SECONDARY) {
 		ifa_flags &= ~IFA_F_SECONDARY;
 		if (ifa->ifa_family == AF_INET6)
 			fprintf(fp, "temporary ");
 		else
 			fprintf(fp, "secondary ");
 	}
-	if (ifa->ifa_flags&IFA_F_TENTATIVE) {
+	if (ifa_flags & IFA_F_TENTATIVE) {
 		ifa_flags &= ~IFA_F_TENTATIVE;
 		fprintf(fp, "tentative ");
 	}
-	if (ifa->ifa_flags&IFA_F_DEPRECATED) {
+	if (ifa_flags & IFA_F_DEPRECATED) {
 		ifa_flags &= ~IFA_F_DEPRECATED;
 		deprecated = 1;
 		fprintf(fp, "deprecated ");
 	}
-	if (ifa->ifa_flags&IFA_F_HOMEADDRESS) {
+	if (ifa_flags & IFA_F_HOMEADDRESS) {
 		ifa_flags &= ~IFA_F_HOMEADDRESS;
 		fprintf(fp, "home ");
 	}
-	if (ifa->ifa_flags&IFA_F_NODAD) {
+	if (ifa_flags & IFA_F_NODAD) {
 		ifa_flags &= ~IFA_F_NODAD;
 		fprintf(fp, "nodad ");
 	}
-	if (!(ifa->ifa_flags&IFA_F_PERMANENT)) {
+	if (!(ifa_flags & IFA_F_PERMANENT)) {
 		fprintf(fp, "dynamic ");
 	} else
 		ifa_flags &= ~IFA_F_PERMANENT;
-	if (ifa->ifa_flags&IFA_F_DADFAILED) {
+	if (ifa_flags & IFA_F_DADFAILED) {
 		ifa_flags &= ~IFA_F_DADFAILED;
 		fprintf(fp, "dadfailed ");
 	}
@@ -926,6 +934,8 @@ static void ipaddr_filter(struct nlmsg_chain *linfo, struct nlmsg_chain *ainfo)
 		for (a = ainfo->head; a; a = a->next) {
 			struct nlmsghdr *n = &a->h;
 			struct ifaddrmsg *ifa = NLMSG_DATA(n);
+			struct rtattr *tb[IFA_MAX + 1];
+			unsigned int ifa_flags;
 
 			if (ifa->ifa_index != ifi->ifi_index)
 				continue;
@@ -934,11 +944,13 @@ static void ipaddr_filter(struct nlmsg_chain *linfo, struct nlmsg_chain *ainfo)
 				continue;
 			if ((filter.scope^ifa->ifa_scope)&filter.scopemask)
 				continue;
-			if ((filter.flags^ifa->ifa_flags)&filter.flagmask)
+
+			parse_rtattr(tb, IFA_MAX, IFA_RTA(ifa), IFA_PAYLOAD(n));
+			ifa_flags = get_ifa_flags(ifa, tb[IFA_FLAGS]);
+
+			if ((filter.flags ^ ifa_flags) & filter.flagmask)
 				continue;
 			if (filter.pfx.family || filter.label) {
-				struct rtattr *tb[IFA_MAX+1];
-				parse_rtattr(tb, IFA_MAX, IFA_RTA(ifa), IFA_PAYLOAD(n));
 				if (!tb[IFA_LOCAL])
 					tb[IFA_LOCAL] = tb[IFA_ADDRESS];
 
@@ -1252,6 +1264,7 @@ static int ipaddr_modify(int cmd, int flags, int argc, char **argv)
 	__u32 preferred_lft = INFINITY_LIFE_TIME;
 	__u32 valid_lft = INFINITY_LIFE_TIME;
 	struct ifa_cacheinfo cinfo;
+	unsigned int ifa_flags = 0;
 
 	memset(&req, 0, sizeof(req));
 
@@ -1329,9 +1342,9 @@ static int ipaddr_modify(int cmd, int flags, int argc, char **argv)
 			if (set_lifetime(&preferred_lft, *argv))
 				invarg("preferred_lft value", *argv);
 		} else if (strcmp(*argv, "home") == 0) {
-			req.ifa.ifa_flags |= IFA_F_HOMEADDRESS;
+			ifa_flags |= IFA_F_HOMEADDRESS;
 		} else if (strcmp(*argv, "nodad") == 0) {
-			req.ifa.ifa_flags |= IFA_F_NODAD;
+			ifa_flags |= IFA_F_NODAD;
 		} else {
 			if (strcmp(*argv, "local") == 0) {
 				NEXT_ARG();
@@ -1349,6 +1362,9 @@ static int ipaddr_modify(int cmd, int flags, int argc, char **argv)
 		}
 		argc--; argv++;
 	}
+	req.ifa.ifa_flags = ifa_flags & 0xff;
+	addattr32(&req.n, sizeof(req), IFA_FLAGS, ifa_flags);
+
 	if (d == NULL) {
 		fprintf(stderr, "Not enough information: \"dev\" argument is required.\n");
 		return -1;
-- 
1.8.3.1
