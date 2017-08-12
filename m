From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 50/51] Check user supplied interface name lengths
Date: Sat, 12 Aug 2017 14:05:09 +0200
Message-ID: <20170812120510.28750-51-phil@nwl.cc>
References: <20170812120510.28750-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:35097 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752018AbdHLMJJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 12 Aug 2017 08:09:09 -0400
In-Reply-To: <20170812120510.28750-1-phil@nwl.cc>
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

Note that this doesn't add calls to assert_valid_dev_name() to all
places where user supplied interface name is parsed. In many cases, the
interface must exist already and is therefore being looked up using
ll_name_to_index(), so if_nametoindex() will perform the necessary
checks already.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 include/utils.h |  1 +
 ip/ip6tunnel.c  |  6 ++++--
 ip/ipl2tp.c     |  1 +
 ip/iplink.c     | 27 ++++++++-------------------
 ip/ipmaddr.c    |  1 +
 ip/iprule.c     |  4 ++++
 ip/iptunnel.c   | 12 ++++++++----
 ip/iptuntap.c   |  4 +++-
 lib/utils.c     |  8 ++++++++
 misc/arpd.c     |  1 +
 10 files changed, 39 insertions(+), 26 deletions(-)

diff --git a/include/utils.h b/include/utils.h
index 6080b962fb411..103def33c92f3 100644
--- a/include/utils.h
+++ b/include/utils.h
@@ -132,6 +132,7 @@ void missarg(const char *) __attribute__((noreturn));
 void invarg(const char *, const char *) __attribute__((noreturn));
 void duparg(const char *, const char *) __attribute__((noreturn));
 void duparg2(const char *, const char *) __attribute__((noreturn));
+void assert_valid_dev_name(const char *, const char *);
 int matches(const char *arg, const char *pattern);
 int inet_addr_match(const inet_prefix *a, const inet_prefix *b, int bits);
 
diff --git a/ip/ip6tunnel.c b/ip/ip6tunnel.c
index b4a7def144226..b3ccfcf87be8f 100644
--- a/ip/ip6tunnel.c
+++ b/ip/ip6tunnel.c
@@ -180,7 +180,8 @@ static int parse_args(int argc, char **argv, int cmd, struct ip6_tnl_parm2 *p)
 			memcpy(&p->laddr, &laddr.data, sizeof(p->laddr));
 		} else if (strcmp(*argv, "dev") == 0) {
 			NEXT_ARG();
-			strncpy(medium, *argv, IFNAMSIZ - 1);
+			assert_valid_dev_name("dev", *argv);
+			strncpy(medium, *argv, IFNAMSIZ);
 		} else if (strcmp(*argv, "encaplimit") == 0) {
 			NEXT_ARG();
 			if (strcmp(*argv, "none") == 0) {
@@ -273,7 +274,8 @@ static int parse_args(int argc, char **argv, int cmd, struct ip6_tnl_parm2 *p)
 				usage();
 			if (p->name[0])
 				duparg2("name", *argv);
-			strncpy(p->name, *argv, IFNAMSIZ - 1);
+			assert_valid_dev_name("name", *argv);
+			strncpy(p->name, *argv, IFNAMSIZ);
 			if (cmd == SIOCCHGTUNNEL && count == 0) {
 				struct ip6_tnl_parm2 old_p = {};
 
diff --git a/ip/ipl2tp.c b/ip/ipl2tp.c
index 88664c909e11f..cdf9f4d8425d4 100644
--- a/ip/ipl2tp.c
+++ b/ip/ipl2tp.c
@@ -545,6 +545,7 @@ static int parse_args(int argc, char **argv, int cmd, struct l2tp_parm *p)
 			}
 		} else if (strcmp(*argv, "name") == 0) {
 			NEXT_ARG();
+			assert_valid_dev_name("name", *argv);
 			p->ifname = *argv;
 		} else if (strcmp(*argv, "remote") == 0) {
 			NEXT_ARG();
diff --git a/ip/iplink.c b/ip/iplink.c
index 5aff2fde38dae..8f76f0467fc9c 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -869,7 +869,6 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 
 static int iplink_modify(int cmd, unsigned int flags, int argc, char **argv)
 {
-	int len;
 	char *dev = NULL;
 	char *name = NULL;
 	char *link = NULL;
@@ -959,13 +958,9 @@ static int iplink_modify(int cmd, unsigned int flags, int argc, char **argv)
 	}
 
 	if (name) {
-		len = strlen(name) + 1;
-		if (len == 1)
-			invarg("\"\" is not a valid device identifier\n",
-			       "name");
-		if (len > IFNAMSIZ)
-			invarg("\"name\" too long\n", name);
-		addattr_l(&req.n, sizeof(req), IFLA_IFNAME, name, len);
+		assert_valid_dev_name("name", name);
+		addattr_l(&req.n, sizeof(req),
+			  IFLA_IFNAME, name, strlen(name) + 1);
 	}
 
 	if (type) {
@@ -1015,7 +1010,6 @@ static int iplink_modify(int cmd, unsigned int flags, int argc, char **argv)
 
 int iplink_get(unsigned int flags, char *name, __u32 filt_mask)
 {
-	int len;
 	struct iplink_req req = {
 		.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct ifinfomsg)),
 		.n.nlmsg_flags = NLM_F_REQUEST | flags,
@@ -1028,13 +1022,9 @@ int iplink_get(unsigned int flags, char *name, __u32 filt_mask)
 	} answer;
 
 	if (name) {
-		len = strlen(name) + 1;
-		if (len == 1)
-			invarg("\"\" is not a valid device identifier\n",
-				   "name");
-		if (len > IFNAMSIZ)
-			invarg("\"name\" too long\n", name);
-		addattr_l(&req.n, sizeof(req), IFLA_IFNAME, name, len);
+		assert_valid_dev_name("name", name);
+		addattr_l(&req.n, sizeof(req),
+			  IFLA_IFNAME, name, strlen(name) + 1);
 	}
 	addattr32(&req.n, sizeof(req), IFLA_EXT_MASK, filt_mask);
 
@@ -1357,6 +1347,7 @@ static int do_set(int argc, char **argv)
 			"Not enough of information: \"dev\" argument is required.\n");
 		exit(-1);
 	}
+	assert_valid_dev_name("dev", dev);
 
 	if (newaddr || newbrd) {
 		halen = get_address(dev, &htype);
@@ -1375,9 +1366,7 @@ static int do_set(int argc, char **argv)
 	}
 
 	if (newname && strcmp(dev, newname)) {
-		if (strlen(newname) == 0)
-			invarg("\"\" is not a valid device identifier\n",
-			       "name");
+		assert_valid_dev_name("name", newname);
 		if (do_changename(dev, newname) < 0)
 			return -1;
 		dev = newname;
diff --git a/ip/ipmaddr.c b/ip/ipmaddr.c
index 85a69e779563d..753e32d5807c0 100644
--- a/ip/ipmaddr.c
+++ b/ip/ipmaddr.c
@@ -284,6 +284,7 @@ static int multiaddr_modify(int cmd, int argc, char **argv)
 			NEXT_ARG();
 			if (ifr.ifr_name[0])
 				duparg("dev", *argv);
+			assert_valid_dev_name("dev", *argv);
 			strncpy(ifr.ifr_name, *argv, IFNAMSIZ);
 		} else {
 			if (matches(*argv, "address") == 0) {
diff --git a/ip/iprule.c b/ip/iprule.c
index 8313138db815f..0184e922053ae 100644
--- a/ip/iprule.c
+++ b/ip/iprule.c
@@ -472,10 +472,12 @@ static int iprule_list_flush_or_save(int argc, char **argv, int action)
 		} else if (strcmp(*argv, "dev") == 0 ||
 			   strcmp(*argv, "iif") == 0) {
 			NEXT_ARG();
+			assert_valid_dev_name("iif", *argv);
 			strncpy(filter.iif, *argv, IFNAMSIZ);
 			filter.iifmask = 1;
 		} else if (strcmp(*argv, "oif") == 0) {
 			NEXT_ARG();
+			assert_valid_dev_name("oif", *argv);
 			strncpy(filter.oif, *argv, IFNAMSIZ);
 			filter.oifmask = 1;
 		} else if (strcmp(*argv, "l3mdev") == 0) {
@@ -695,10 +697,12 @@ static int iprule_modify(int cmd, int argc, char **argv)
 		} else if (strcmp(*argv, "dev") == 0 ||
 			   strcmp(*argv, "iif") == 0) {
 			NEXT_ARG();
+			assert_valid_dev_name("iif", *argv);
 			addattr_l(&req.n, sizeof(req), FRA_IFNAME,
 				  *argv, strlen(*argv)+1);
 		} else if (strcmp(*argv, "oif") == 0) {
 			NEXT_ARG();
+			assert_valid_dev_name("oif", *argv);
 			addattr_l(&req.n, sizeof(req), FRA_OIFNAME,
 				  *argv, strlen(*argv)+1);
 		} else if (strcmp(*argv, "l3mdev") == 0) {
diff --git a/ip/iptunnel.c b/ip/iptunnel.c
index 105d0f5576f1a..b9dd19c6f83c5 100644
--- a/ip/iptunnel.c
+++ b/ip/iptunnel.c
@@ -139,7 +139,8 @@ static int parse_args(int argc, char **argv, int cmd, struct ip_tunnel_parm *p)
 				p->iph.saddr = htonl(INADDR_ANY);
 		} else if (strcmp(*argv, "dev") == 0) {
 			NEXT_ARG();
-			strncpy(medium, *argv, IFNAMSIZ - 1);
+			assert_valid_dev_name("dev", *argv);
+			strncpy(medium, *argv, IFNAMSIZ);
 		} else if (strcmp(*argv, "ttl") == 0 ||
 			   strcmp(*argv, "hoplimit") == 0 ||
 			   strcmp(*argv, "hlim") == 0) {
@@ -178,7 +179,8 @@ static int parse_args(int argc, char **argv, int cmd, struct ip_tunnel_parm *p)
 
 			if (p->name[0])
 				duparg2("name", *argv);
-			strncpy(p->name, *argv, IFNAMSIZ - 1);
+			assert_valid_dev_name("name", *argv);
+			strncpy(p->name, *argv, IFNAMSIZ);
 			if (cmd == SIOCCHGTUNNEL && count == 0) {
 				struct ip_tunnel_parm old_p = {};
 
@@ -488,7 +490,8 @@ static int do_prl(int argc, char **argv)
 			count++;
 		} else if (strcmp(*argv, "dev") == 0) {
 			NEXT_ARG();
-			strncpy(medium, *argv, IFNAMSIZ-1);
+			assert_valid_dev_name("dev", *argv);
+			strncpy(medium, *argv, IFNAMSIZ);
 			devname++;
 		} else {
 			fprintf(stderr,
@@ -537,7 +540,8 @@ static int do_6rd(int argc, char **argv)
 			cmd = SIOCDEL6RD;
 		} else if (strcmp(*argv, "dev") == 0) {
 			NEXT_ARG();
-			strncpy(medium, *argv, IFNAMSIZ-1);
+			assert_valid_dev_name("dev", *argv);
+			strncpy(medium, *argv, IFNAMSIZ);
 			devname++;
 		} else {
 			fprintf(stderr,
diff --git a/ip/iptuntap.c b/ip/iptuntap.c
index 451f7f0eac6bb..062f3d6ed036e 100644
--- a/ip/iptuntap.c
+++ b/ip/iptuntap.c
@@ -176,7 +176,8 @@ static int parse_args(int argc, char **argv,
 			ifr->ifr_flags |= IFF_MULTI_QUEUE;
 		} else if (matches(*argv, "dev") == 0) {
 			NEXT_ARG();
-			strncpy(ifr->ifr_name, *argv, IFNAMSIZ-1);
+			assert_valid_dev_name("dev", *argv);
+			strncpy(ifr->ifr_name, *argv, IFNAMSIZ);
 		} else {
 			if (matches(*argv, "name") == 0) {
 				NEXT_ARG();
@@ -184,6 +185,7 @@ static int parse_args(int argc, char **argv,
 				usage();
 			if (ifr->ifr_name[0])
 				duparg2("name", *argv);
+			assert_valid_dev_name("name", *argv);
 			strncpy(ifr->ifr_name, *argv, IFNAMSIZ);
 		}
 		count++;
diff --git a/lib/utils.c b/lib/utils.c
index 9143ed2284870..002063075fd61 100644
--- a/lib/utils.c
+++ b/lib/utils.c
@@ -699,6 +699,14 @@ void duparg2(const char *key, const char *arg)
 	exit(-1);
 }
 
+void assert_valid_dev_name(const char *arg, const char *name)
+{
+	size_t len = strlen(name);
+
+	if (len < 1 || len >= IFNAMSIZ)
+		invarg("empty or overlong interface name.", len ? name : arg);
+}
+
 int matches(const char *cmd, const char *pattern)
 {
 	int len = strlen(cmd);
diff --git a/misc/arpd.c b/misc/arpd.c
index bfab44544ee1d..4b834868e0ec7 100644
--- a/misc/arpd.c
+++ b/misc/arpd.c
@@ -664,6 +664,7 @@ int main(int argc, char **argv)
 		struct ifreq ifr = {};
 
 		for (i = 0; i < ifnum; i++) {
+			assert_valid_dev_name(ifnames[i], ifnames[i]);
 			strncpy(ifr.ifr_name, ifnames[i], IFNAMSIZ);
 			if (ioctl(udp_sock, SIOCGIFINDEX, &ifr)) {
 				perror("ioctl(SIOCGIFINDEX)");
-- 
2.13.1
