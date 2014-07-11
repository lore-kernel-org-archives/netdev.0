From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch iproute2] iproute2: allow to ipv6 set address generation mode
Date: Fri, 11 Jul 2014 21:11:46 +0200
Message-ID: <1405105906-1538-1-git-send-email-jiri@resnulli.us>
References: <1405105818-1460-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	sfeldma@cumulusnetworks.com, arvid.brodin@alten.se,
	sucheta.chakraborty@qlogic.com, hannes@stressinduktion.org,
	stephen@networkplumber.org, dcbw@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f172.google.com ([74.125.82.172]:45830 "EHLO
	mail-we0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932366AbaGKTL4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jul 2014 15:11:56 -0400
Received: by mail-we0-f172.google.com with SMTP id u57so1567345wes.31
        for <netdev@vger.kernel.org>; Fri, 11 Jul 2014 12:11:53 -0700 (PDT)
In-Reply-To: <1405105818-1460-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/linux/if_link.h |  6 ++++++
 ip/iplink.c             | 22 ++++++++++++++++++++++
 2 files changed, 28 insertions(+)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index fadef0f..39cb62c 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -202,11 +202,17 @@ enum {
 	IFLA_INET6_CACHEINFO,	/* time values and max reasm size */
 	IFLA_INET6_ICMP6STATS,	/* statistics (icmpv6)		*/
 	IFLA_INET6_TOKEN,	/* device token			*/
+	IFLA_INET6_ADDR_GEN_MODE, /* implicit address generator mode */
 	__IFLA_INET6_MAX
 };
 
 #define IFLA_INET6_MAX	(__IFLA_INET6_MAX - 1)
 
+enum in6_addr_gen_mode {
+	IN6_ADDR_GEN_MODE_EUI64,
+	IN6_ADDR_GEN_MODE_NONE,
+};
+
 enum {
 	BRIDGE_MODE_UNSPEC,
 	BRIDGE_MODE_HAIRPIN,
diff --git a/ip/iplink.c b/ip/iplink.c
index 0d020ef..ecb05d6 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -81,6 +81,7 @@ void iplink_usage(void)
 	fprintf(stderr, "				   [ state { auto | enable | disable} ] ]\n");
 	fprintf(stderr, "			  [ master DEVICE ]\n");
 	fprintf(stderr, "			  [ nomaster ]\n");
+	fprintf(stderr, "			  [ addrgenmode { eui64 | none } ]\n");
 	fprintf(stderr, "       ip link show [ DEVICE | group GROUP ] [up]\n");
 
 	if (iplink_have_newlink()) {
@@ -161,6 +162,15 @@ static int get_link_mode(const char *mode)
 	return -1;
 }
 
+static int get_addr_gen_mode(const char *mode)
+{
+	if (strcasecmp(mode, "eui64") == 0)
+		return IN6_ADDR_GEN_MODE_EUI64;
+	if (strcasecmp(mode, "none") == 0)
+		return IN6_ADDR_GEN_MODE_NONE;
+	return -1;
+}
+
 #if IPLINK_IOCTL_COMPAT
 static int have_rtnl_newlink = -1;
 
@@ -557,6 +567,18 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 				invarg("Invalid \"numrxqueues\" value\n", *argv);
 			addattr_l(&req->n, sizeof(*req), IFLA_NUM_RX_QUEUES,
 				  &numrxqueues, 4);
+		} else if (matches(*argv, "addrgenmode") == 0) {
+			struct rtattr *afs, *afs6;
+			int mode;
+			NEXT_ARG();
+			mode = get_addr_gen_mode(*argv);
+			if (mode < 0)
+				invarg("Invalid address generation mode\n", *argv);
+			afs = addattr_nest(&req->n, sizeof(*req), IFLA_AF_SPEC);
+			afs6 = addattr_nest(&req->n, sizeof(*req), AF_INET6);
+			addattr8(&req->n, sizeof(*req), IFLA_INET6_ADDR_GEN_MODE, mode);
+			addattr_nest_end(&req->n, afs6);
+			addattr_nest_end(&req->n, afs);
 		} else {
 			if (strcmp(*argv, "dev") == 0) {
 				NEXT_ARG();
-- 
1.9.0
