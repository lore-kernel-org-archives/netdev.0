From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 3/3] Check user supplied interface name lengths
Date: Tue, 26 Sep 2017 18:35:48 +0200
Message-ID: <20170926163548.24347-4-phil@nwl.cc>
References: <20170926163548.24347-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:58112 "EHLO orbyte.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S967740AbdIZQgL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 26 Sep 2017 12:36:11 -0400
In-Reply-To: <20170926163548.24347-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The original problem was that something like:

| strncpy(ifr.ifr_name, *argv, IFNAMSIZ);

might leave ifr.ifr_name unterminated if length of *argv exceeds
IFNAMSIZ. In order to fix this, I thought about replacing all those
cases with (equivalent) calls to snprintf() or even introducing
strlcpy(). But as Ulrich Drepper correctly pointed out when rejecting
the latter from being added to glibc, truncating a string without
notifying the user is not to be considered good practice. So let's
excercise what he suggested and reject empty or overlong interface names
right from the start - this way calls to strncpy() like shown above
become safe and the user has a chance to reconsider what he was trying
to do.

Note that this doesn't add calls to check_ifname() to all places where
user supplied interface name is parsed. In many cases, the interface
must exist already and is therefore looked up using ll_name_to_index(),
so if_nametoindex() will perform the necessary checks already.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
Changes since v1:
- added missing check to tc/f_flower.c
- Drop some useless checks from ip/ip{6,}tunnel.c (ll_name_to_index()
  will detect illegal interface names for us).
- Renamed assert_valid_dev_name() to the shorter check_ifname().
- iplink: Check 'name' and 'dev' parameters right where they are parsed.
- ipl2tp: Drop needless check for p->ifname[0].
---
 include/utils.h |  1 +
 ip/ip6tunnel.c  |  3 ++-
 ip/ipl2tp.c     |  3 ++-
 ip/iplink.c     | 27 ++++++++-------------------
 ip/ipmaddr.c    |  1 +
 ip/iprule.c     |  4 ++++
 ip/iptunnel.c   |  5 ++++-
 ip/iptuntap.c   |  4 +++-
 lib/utils.c     | 10 ++++++++++
 misc/arpd.c     |  1 +
 tc/f_flower.c   |  1 +
 11 files changed, 37 insertions(+), 23 deletions(-)

diff --git a/include/utils.h b/include/utils.h
index c9ed230b96044..12f0735e8aa0d 100644
--- a/include/utils.h
+++ b/include/utils.h
@@ -133,6 +133,7 @@ void missarg(const char *) __attribute__((noreturn));
 void invarg(const char *, const char *) __attribute__((noreturn));
 void duparg(const char *, const char *) __attribute__((noreturn));
 void duparg2(const char *, const char *) __attribute__((noreturn));
+void check_ifname(const char *, const char *);
 int matches(const char *arg, const char *pattern);
 int inet_addr_match(const inet_prefix *a, const inet_prefix *b, int bits);
 
diff --git a/ip/ip6tunnel.c b/ip/ip6tunnel.c
index c12d700e74189..2c10b9c3fa7b5 100644
--- a/ip/ip6tunnel.c
+++ b/ip/ip6tunnel.c
@@ -273,7 +273,8 @@ static int parse_args(int argc, char **argv, int cmd, struct ip6_tnl_parm2 *p)
 				usage();
 			if (p->name[0])
 				duparg2("name", *argv);
-			strncpy(p->name, *argv, IFNAMSIZ - 1);
+			check_ifname("name", *argv);
+			strncpy(p->name, *argv, IFNAMSIZ);
 			if (cmd == SIOCCHGTUNNEL && count == 0) {
 				struct ip6_tnl_parm2 old_p = {};
 
diff --git a/ip/ipl2tp.c b/ip/ipl2tp.c
index 88664c909e11f..06f1bd064c914 100644
--- a/ip/ipl2tp.c
+++ b/ip/ipl2tp.c
@@ -182,7 +182,7 @@ static int create_session(struct l2tp_parm *p)
 	if (p->peer_cookie_len)
 		addattr_l(&req.n, 1024, L2TP_ATTR_PEER_COOKIE,
 			  p->peer_cookie,  p->peer_cookie_len);
-	if (p->ifname && p->ifname[0])
+	if (p->ifname)
 		addattrstrz(&req.n, 1024, L2TP_ATTR_IFNAME, p->ifname);
 
 	if (rtnl_talk(&genl_rth, &req.n, NULL, 0) < 0)
@@ -545,6 +545,7 @@ static int parse_args(int argc, char **argv, int cmd, struct l2tp_parm *p)
 			}
 		} else if (strcmp(*argv, "name") == 0) {
 			NEXT_ARG();
+			check_ifname("name", *argv);
 			p->ifname = *argv;
 		} else if (strcmp(*argv, "remote") == 0) {
 			NEXT_ARG();
diff --git a/ip/iplink.c b/ip/iplink.c
index ff5b56c038d28..f000a7992c92e 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -573,6 +573,7 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 			req->i.ifi_flags &= ~IFF_UP;
 		} else if (strcmp(*argv, "name") == 0) {
 			NEXT_ARG();
+			check_ifname("name", *argv);
 			*name = *argv;
 		} else if (strcmp(*argv, "index") == 0) {
 			NEXT_ARG();
@@ -848,6 +849,7 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 				NEXT_ARG();
 			if (*dev)
 				duparg2("dev", *argv);
+			check_ifname("dev", *argv);
 			*dev = *argv;
 			dev_index = ll_name_to_index(*dev);
 		}
@@ -870,7 +872,6 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 
 static int iplink_modify(int cmd, unsigned int flags, int argc, char **argv)
 {
-	int len;
 	char *dev = NULL;
 	char *name = NULL;
 	char *link = NULL;
@@ -960,13 +961,8 @@ static int iplink_modify(int cmd, unsigned int flags, int argc, char **argv)
 	}
 
 	if (name) {
-		len = strlen(name) + 1;
-		if (len == 1)
-			invarg("\"\" is not a valid device identifier\n",
-			       "name");
-		if (len > IFNAMSIZ)
-			invarg("\"name\" too long\n", name);
-		addattr_l(&req.n, sizeof(req), IFLA_IFNAME, name, len);
+		addattr_l(&req.n, sizeof(req),
+			  IFLA_IFNAME, name, strlen(name) + 1);
 	}
 
 	if (type) {
@@ -1016,7 +1012,6 @@ static int iplink_modify(int cmd, unsigned int flags, int argc, char **argv)
 
 int iplink_get(unsigned int flags, char *name, __u32 filt_mask)
 {
-	int len;
 	struct iplink_req req = {
 		.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct ifinfomsg)),
 		.n.nlmsg_flags = NLM_F_REQUEST | flags,
@@ -1029,13 +1024,8 @@ int iplink_get(unsigned int flags, char *name, __u32 filt_mask)
 	} answer;
 
 	if (name) {
-		len = strlen(name) + 1;
-		if (len == 1)
-			invarg("\"\" is not a valid device identifier\n",
-				   "name");
-		if (len > IFNAMSIZ)
-			invarg("\"name\" too long\n", name);
-		addattr_l(&req.n, sizeof(req), IFLA_IFNAME, name, len);
+		addattr_l(&req.n, sizeof(req),
+			  IFLA_IFNAME, name, strlen(name) + 1);
 	}
 	addattr32(&req.n, sizeof(req), IFLA_EXT_MASK, filt_mask);
 
@@ -1265,6 +1255,7 @@ static int do_set(int argc, char **argv)
 			flags &= ~IFF_UP;
 		} else if (strcmp(*argv, "name") == 0) {
 			NEXT_ARG();
+			check_ifname("name", newname);
 			newname = *argv;
 		} else if (matches(*argv, "address") == 0) {
 			NEXT_ARG();
@@ -1355,6 +1346,7 @@ static int do_set(int argc, char **argv)
 
 			if (dev)
 				duparg2("dev", *argv);
+			check_ifname("dev", dev);
 			dev = *argv;
 		}
 		argc--; argv++;
@@ -1383,9 +1375,6 @@ static int do_set(int argc, char **argv)
 	}
 
 	if (newname && strcmp(dev, newname)) {
-		if (strlen(newname) == 0)
-			invarg("\"\" is not a valid device identifier\n",
-			       "name");
 		if (do_changename(dev, newname) < 0)
 			return -1;
 		dev = newname;
diff --git a/ip/ipmaddr.c b/ip/ipmaddr.c
index 85a69e779563d..282a06153c79a 100644
--- a/ip/ipmaddr.c
+++ b/ip/ipmaddr.c
@@ -284,6 +284,7 @@ static int multiaddr_modify(int cmd, int argc, char **argv)
 			NEXT_ARG();
 			if (ifr.ifr_name[0])
 				duparg("dev", *argv);
+			check_ifname("dev", *argv);
 			strncpy(ifr.ifr_name, *argv, IFNAMSIZ);
 		} else {
 			if (matches(*argv, "address") == 0) {
diff --git a/ip/iprule.c b/ip/iprule.c
index 8313138db815f..33cfd87195212 100644
--- a/ip/iprule.c
+++ b/ip/iprule.c
@@ -472,10 +472,12 @@ static int iprule_list_flush_or_save(int argc, char **argv, int action)
 		} else if (strcmp(*argv, "dev") == 0 ||
 			   strcmp(*argv, "iif") == 0) {
 			NEXT_ARG();
+			check_ifname("iif", *argv);
 			strncpy(filter.iif, *argv, IFNAMSIZ);
 			filter.iifmask = 1;
 		} else if (strcmp(*argv, "oif") == 0) {
 			NEXT_ARG();
+			check_ifname("oif", *argv);
 			strncpy(filter.oif, *argv, IFNAMSIZ);
 			filter.oifmask = 1;
 		} else if (strcmp(*argv, "l3mdev") == 0) {
@@ -695,10 +697,12 @@ static int iprule_modify(int cmd, int argc, char **argv)
 		} else if (strcmp(*argv, "dev") == 0 ||
 			   strcmp(*argv, "iif") == 0) {
 			NEXT_ARG();
+			check_ifname("dev/iif", *argv);
 			addattr_l(&req.n, sizeof(req), FRA_IFNAME,
 				  *argv, strlen(*argv)+1);
 		} else if (strcmp(*argv, "oif") == 0) {
 			NEXT_ARG();
+			check_ifname("oif", *argv);
 			addattr_l(&req.n, sizeof(req), FRA_OIFNAME,
 				  *argv, strlen(*argv)+1);
 		} else if (strcmp(*argv, "l3mdev") == 0) {
diff --git a/ip/iptunnel.c b/ip/iptunnel.c
index 0acfd0793d3cd..851a80aad73a9 100644
--- a/ip/iptunnel.c
+++ b/ip/iptunnel.c
@@ -178,7 +178,8 @@ static int parse_args(int argc, char **argv, int cmd, struct ip_tunnel_parm *p)
 
 			if (p->name[0])
 				duparg2("name", *argv);
-			strncpy(p->name, *argv, IFNAMSIZ - 1);
+			check_ifname("name", *argv);
+			strncpy(p->name, *argv, IFNAMSIZ);
 			if (cmd == SIOCCHGTUNNEL && count == 0) {
 				struct ip_tunnel_parm old_p = {};
 
@@ -487,6 +488,7 @@ static int do_prl(int argc, char **argv)
 			count++;
 		} else if (strcmp(*argv, "dev") == 0) {
 			NEXT_ARG();
+			check_ifname("dev", *argv);
 			medium = *argv;
 		} else {
 			fprintf(stderr,
@@ -534,6 +536,7 @@ static int do_6rd(int argc, char **argv)
 			cmd = SIOCDEL6RD;
 		} else if (strcmp(*argv, "dev") == 0) {
 			NEXT_ARG();
+			check_ifname("dev", *argv);
 			medium = *argv;
 		} else {
 			fprintf(stderr,
diff --git a/ip/iptuntap.c b/ip/iptuntap.c
index 451f7f0eac6bb..4400dc2fa2a88 100644
--- a/ip/iptuntap.c
+++ b/ip/iptuntap.c
@@ -176,7 +176,8 @@ static int parse_args(int argc, char **argv,
 			ifr->ifr_flags |= IFF_MULTI_QUEUE;
 		} else if (matches(*argv, "dev") == 0) {
 			NEXT_ARG();
-			strncpy(ifr->ifr_name, *argv, IFNAMSIZ-1);
+			check_ifname("dev", *argv);
+			strncpy(ifr->ifr_name, *argv, IFNAMSIZ);
 		} else {
 			if (matches(*argv, "name") == 0) {
 				NEXT_ARG();
@@ -184,6 +185,7 @@ static int parse_args(int argc, char **argv,
 				usage();
 			if (ifr->ifr_name[0])
 				duparg2("name", *argv);
+			check_ifname("name", *argv);
 			strncpy(ifr->ifr_name, *argv, IFNAMSIZ);
 		}
 		count++;
diff --git a/lib/utils.c b/lib/utils.c
index bbd3cbc46a0e5..c4a02b8f9f52a 100644
--- a/lib/utils.c
+++ b/lib/utils.c
@@ -699,6 +699,16 @@ void duparg2(const char *key, const char *arg)
 	exit(-1);
 }
 
+void check_ifname(const char *arg, const char *name)
+{
+	size_t len = strlen(name);
+
+	if (!len)
+		invarg("Empty interface name not allowed.", arg);
+	if (len >= IFNAMSIZ)
+		invarg("Interface name is too long.", name);
+}
+
 int matches(const char *cmd, const char *pattern)
 {
 	int len = strlen(cmd);
diff --git a/misc/arpd.c b/misc/arpd.c
index bfab44544ee1d..d42df9e58a9f1 100644
--- a/misc/arpd.c
+++ b/misc/arpd.c
@@ -664,6 +664,7 @@ int main(int argc, char **argv)
 		struct ifreq ifr = {};
 
 		for (i = 0; i < ifnum; i++) {
+			check_ifname(ifnames[i], ifnames[i]);
 			strncpy(ifr.ifr_name, ifnames[i], IFNAMSIZ);
 			if (ioctl(udp_sock, SIOCGIFINDEX, &ifr)) {
 				perror("ioctl(SIOCGIFINDEX)");
diff --git a/tc/f_flower.c b/tc/f_flower.c
index 99e62a382dec6..ff45ea7af086e 100644
--- a/tc/f_flower.c
+++ b/tc/f_flower.c
@@ -630,6 +630,7 @@ static int flower_parse_opt(struct filter_util *qu, char *handle,
 			flags |= TCA_CLS_FLAGS_SKIP_SW;
 		} else if (matches(*argv, "indev") == 0) {
 			NEXT_ARG();
+			check_ifname("indev", *argv);
 			addattrstrz(n, MAX_MSG, TCA_FLOWER_INDEV, *argv);
 		} else if (matches(*argv, "vlan_id") == 0) {
 			__u16 vid;
-- 
2.13.1
