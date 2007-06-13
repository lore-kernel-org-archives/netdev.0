From: Patrick McHardy <kaber@trash.net>
Subject: [IPROUTE 01/02]: iplink: use netlink for link configuration
Date: Wed, 13 Jun 2007 19:02:33 +0200 (MEST)
Message-ID: <20070613170230.8318.41637.sendpatchset@localhost.localdomain>
References: <20070613170229.8318.75488.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: shemminger@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36213 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758679AbXFMRCf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2007 13:02:35 -0400
In-Reply-To: <20070613170229.8318.75488.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPROUTE]: iplink: use netlink for link configuration

Add support for using netlink for link configuration. Kernel-support is
probed, when not available it falls back to using ioctls.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 4feb48d12295eb41850c39996f3a8c1dd7909ed5
tree dbb34cf5a9b38adb0c2602a88b09823f922c8a2c
parent b16621cafd599499fdbaa79236266d72a53106bb
author Patrick McHardy <kaber@trash.net> Wed, 13 Jun 2007 14:10:57 +0200
committer Patrick McHardy <kaber@trash.net> Wed, 13 Jun 2007 14:10:57 +0200

 include/linux/if_link.h |   13 ++
 ip/Makefile             |    2 
 ip/ip.c                 |    5 +
 ip/ip_common.h          |   15 ++
 ip/ipaddress.c          |   39 ++++++
 ip/iplink.c             |  311 +++++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 382 insertions(+), 3 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 2920e8a..58a48d7 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -76,6 +76,8 @@ enum
 #define IFLA_WEIGHT IFLA_WEIGHT
 	IFLA_OPERSTATE,
 	IFLA_LINKMODE,
+	IFLA_LINKINFO,
+#define IFLA_LINKINFO IFLA_LINKINFO
 	__IFLA_MAX
 };
 
@@ -137,4 +139,15 @@ struct ifla_cacheinfo
 	__u32	retrans_time;
 };
 
+enum
+{
+	IFLA_INFO_UNSPEC,
+	IFLA_INFO_KIND,
+	IFLA_INFO_DATA,
+	IFLA_INFO_XSTATS,
+	__IFLA_INFO_MAX,
+};
+
+#define IFLA_INFO_MAX	(__IFLA_INFO_MAX - 1)
+
 #endif /* _LINUX_IF_LINK_H */
diff --git a/ip/Makefile b/ip/Makefile
index a749993..9a5bfe3 100644
--- a/ip/Makefile
+++ b/ip/Makefile
@@ -22,3 +22,5 @@ install: all
 clean:
 	rm -f $(ALLOBJ) $(TARGETS)
 
+LDLIBS	+= -ldl
+LDFLAGS	+= -Wl,-export-dynamic
diff --git a/ip/ip.c b/ip/ip.c
index c084292..4bdb83b 100644
--- a/ip/ip.c
+++ b/ip/ip.c
@@ -30,6 +30,7 @@
 
 int preferred_family = AF_UNSPEC;
 int show_stats = 0;
+int show_details = 0;
 int resolve_hosts = 0;
 int oneline = 0;
 int timestamp = 0;
@@ -47,7 +48,7 @@ static void usage(void)
 "       ip [ -force ] [-batch filename\n"
 "where  OBJECT := { link | addr | route | rule | neigh | ntable | tunnel |\n"
 "                   maddr | mroute | monitor | xfrm }\n"
-"       OPTIONS := { -V[ersion] | -s[tatistics] | -r[esolve] |\n"
+"       OPTIONS := { -V[ersion] | -s[tatistics] | -d[etails] | -r[esolve] |\n"
 "                    -f[amily] { inet | inet6 | ipx | dnet | link } |\n"
 "                    -o[neline] | -t[imestamp] }\n");
 	exit(-1);
@@ -188,6 +189,8 @@ int main(int argc, char **argv)
 		} else if (matches(opt, "-stats") == 0 ||
 			   matches(opt, "-statistics") == 0) {
 			++show_stats;
+		} else if (matches(opt, "-details") == 0) {
+			++show_details;
 		} else if (matches(opt, "-resolve") == 0) {
 			++resolve_hosts;
 		} else if (matches(opt, "-oneline") == 0) {
diff --git a/ip/ip_common.h b/ip/ip_common.h
index 5bfd9b9..39f2507 100644
--- a/ip/ip_common.h
+++ b/ip/ip_common.h
@@ -45,6 +45,21 @@ static inline int rtm_get_table(struct rtmsg *r, struct rtattr **tb)
 
 extern struct rtnl_handle rth;
 
+struct link_util
+{
+	struct link_util	*next;
+	const char		*id;
+	int			maxattr;
+	int			(*parse_opt)(struct link_util *, int, char **,
+					     struct nlmsghdr *);
+	void			(*print_opt)(struct link_util *, FILE *,
+					     struct rtattr *[]);
+	void			(*print_xstats)(struct link_util *, FILE *,
+					     struct rtattr *);
+};
+
+struct link_util *get_link_kind(const char *kind);
+
 #ifndef	INFINITY_LIFE_TIME
 #define     INFINITY_LIFE_TIME      0xFFFFFFFFU
 #endif
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 98effa3..da6b270 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -134,6 +134,41 @@ void print_queuelen(char *name)
 		printf("qlen %d", ifr.ifr_qlen);
 }
 
+static void print_linktype(FILE *fp, struct rtattr *tb)
+{
+	struct rtattr *linkinfo[IFLA_INFO_MAX+1];
+	struct link_util *lu;
+	char *kind;
+
+	parse_rtattr_nested(linkinfo, IFLA_INFO_MAX, tb);
+
+	if (!linkinfo[IFLA_INFO_KIND])
+		return;
+	kind = RTA_DATA(linkinfo[IFLA_INFO_KIND]);
+
+	fprintf(fp, "%s", _SL_);
+	fprintf(fp, "    %s ", kind);
+
+	lu = get_link_kind(kind);
+	if (!lu || !lu->print_opt)
+		return;
+
+	if (1) {
+		struct rtattr *attr[lu->maxattr+1], **data = NULL;
+
+		if (linkinfo[IFLA_INFO_DATA]) {
+			parse_rtattr_nested(attr, lu->maxattr,
+					    linkinfo[IFLA_INFO_DATA]);
+			data = attr;
+		}
+		lu->print_opt(lu, fp, data);
+
+		if (linkinfo[IFLA_INFO_XSTATS] && show_stats &&
+		    lu->print_xstats)
+			lu->print_xstats(lu, fp, linkinfo[IFLA_INFO_XSTATS]);
+	}
+}
+
 int print_linkinfo(const struct sockaddr_nl *who,
 		   struct nlmsghdr *n, void *arg)
 {
@@ -221,6 +256,10 @@ int print_linkinfo(const struct sockaddr_nl *who,
 						      b1, sizeof(b1)));
 		}
 	}
+
+	if (do_link && tb[IFLA_LINKINFO] && show_details)
+		print_linktype(fp, tb[IFLA_LINKINFO]);
+
 	if (do_link && tb[IFLA_STATS] && show_stats) {
 		struct rtnl_link_stats slocal;
 		struct rtnl_link_stats *s = RTA_DATA(tb[IFLA_STATS]);
diff --git a/ip/iplink.c b/ip/iplink.c
index 8f82a08..4060845 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -15,6 +15,7 @@
 #include <unistd.h>
 #include <syslog.h>
 #include <fcntl.h>
+#include <dlfcn.h>
 #include <errno.h>
 #include <sys/socket.h>
 #include <linux/if.h>
@@ -31,6 +32,7 @@
 #include "utils.h"
 #include "ip_common.h"
 
+#define IPLINK_IOCTL_COMPAT	1
 
 static void usage(void) __attribute__((noreturn));
 
@@ -62,6 +64,290 @@ static int on_off(char *msg)
 	return -1;
 }
 
+static void *BODY;		/* cached dlopen(NULL) handle */
+static struct link_util *linkutil_list;
+
+struct link_util *get_link_kind(const char *id)
+{
+	void *dlh;
+	char buf[256];
+	struct link_util *l;
+
+	for (l = linkutil_list; l; l = l->next)
+		if (strcmp(l->id, id) == 0)
+			return l;
+
+	snprintf(buf, sizeof(buf), "/usr/lib/ip/link_%s.so", id);
+	dlh = dlopen(buf, RTLD_LAZY);
+	if (dlh == NULL) {
+		/* look in current binary, only open once */
+		dlh = BODY;
+		if (dlh == NULL) {
+			dlh = BODY = dlopen(NULL, RTLD_LAZY);
+			if (dlh == NULL)
+				return NULL;
+		}
+	}
+
+	snprintf(buf, sizeof(buf), "%s_link_util", id);
+	l = dlsym(dlh, buf);
+	if (l == NULL)
+		return NULL;
+
+	l->next = linkutil_list;
+	linkutil_list = l;
+	return l;
+}
+
+#if IPLINK_IOCTL_COMPAT
+static int have_rtnl_newlink = -1;
+
+static int accept_msg(const struct sockaddr_nl *who,
+		      struct nlmsghdr *n, void *arg)
+{
+	struct nlmsgerr *err = (struct nlmsgerr *)NLMSG_DATA(n);
+
+	if (n->nlmsg_type == NLMSG_ERROR && err->error == -EOPNOTSUPP)
+		have_rtnl_newlink = 0;
+	else
+		have_rtnl_newlink = 1;
+	return -1;
+}
+
+static int iplink_have_newlink(void)
+{
+	struct {
+		struct nlmsghdr		n;
+		struct ifinfomsg	i;
+		char			buf[1024];
+	} req;
+
+	if (have_rtnl_newlink < 0) {
+		memset(&req, 0, sizeof(req));
+
+		req.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct ifinfomsg));
+		req.n.nlmsg_flags = NLM_F_REQUEST|NLM_F_ACK;
+		req.n.nlmsg_type = RTM_NEWLINK;
+		req.i.ifi_family = AF_UNSPEC;
+
+		rtnl_send(&rth, (char *)&req.n, req.n.nlmsg_len);
+		rtnl_listen(&rth, accept_msg, NULL);
+	}
+	return have_rtnl_newlink;
+}
+#else /* IPLINK_IOCTL_COMPAT */
+static int iplink_have_newlink(void)
+{
+	return 1;
+}
+#endif /* ! IPLINK_IOCTL_COMPAT */
+
+static int iplink_modify(int cmd, unsigned int flags, int argc, char **argv)
+{
+	int qlen = -1;
+	int mtu = -1;
+	int len;
+	char abuf[32];
+	char *dev = NULL;
+	char *name = NULL;
+	char *link = NULL;
+	char *type = NULL;
+	struct link_util *lu = NULL;
+	struct {
+		struct nlmsghdr		n;
+		struct ifinfomsg	i;
+		char			buf[1024];
+	} req;
+
+	memset(&req, 0, sizeof(req));
+
+	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct ifinfomsg));
+	req.n.nlmsg_flags = NLM_F_REQUEST|flags;
+	req.n.nlmsg_type = cmd;
+	req.i.ifi_family = preferred_family;
+
+	while (argc > 0) {
+		if (strcmp(*argv, "up") == 0) {
+			req.i.ifi_change |= IFF_UP;
+			req.i.ifi_flags |= IFF_UP;
+		} else if (strcmp(*argv, "down") == 0) {
+			req.i.ifi_change |= IFF_UP;
+			req.i.ifi_flags &= ~IFF_UP;
+		} else if (strcmp(*argv, "name") == 0) {
+			NEXT_ARG();
+			name = *argv;
+		} else if (matches(*argv, "link") == 0) {
+			NEXT_ARG();
+			link = *argv;
+		} else if (matches(*argv, "address") == 0) {
+			NEXT_ARG();
+			len = ll_addr_a2n(abuf, sizeof(abuf), *argv);
+			addattr_l(&req.n, sizeof(req), IFLA_ADDRESS, abuf, len);
+		} else if (matches(*argv, "broadcast") == 0 ||
+			   strcmp(*argv, "brd") == 0) {
+			NEXT_ARG();
+			len = ll_addr_a2n(abuf, sizeof(abuf), *argv);
+			addattr_l(&req.n, sizeof(req), IFLA_BROADCAST, abuf, len);
+		} else if (matches(*argv, "txqueuelen") == 0 ||
+			   strcmp(*argv, "qlen") == 0 ||
+			   matches(*argv, "txqlen") == 0) {
+			NEXT_ARG();
+			if (qlen != -1)
+				duparg("txqueuelen", *argv);
+			if (get_integer(&qlen,  *argv, 0))
+				invarg("Invalid \"txqueuelen\" value\n", *argv);
+			addattr_l(&req.n, sizeof(req), IFLA_TXQLEN, &qlen, 4);
+		} else if (strcmp(*argv, "mtu") == 0) {
+			NEXT_ARG();
+			if (mtu != -1)
+				duparg("mtu", *argv);
+			if (get_integer(&mtu, *argv, 0))
+				invarg("Invalid \"mtu\" value\n", *argv);
+			addattr_l(&req.n, sizeof(req), IFLA_MTU, &mtu, 4);
+		} else if (strcmp(*argv, "multicast") == 0) {
+			NEXT_ARG();
+			req.i.ifi_change |= IFF_MULTICAST;
+			if (strcmp(*argv, "on") == 0) {
+				req.i.ifi_flags |= IFF_MULTICAST;
+			} else if (strcmp(*argv, "off") == 0) {
+				req.i.ifi_flags &= ~IFF_MULTICAST;
+			} else
+				return on_off("multicast");
+		} else if (strcmp(*argv, "allmulticast") == 0) {
+			NEXT_ARG();
+			req.i.ifi_change |= IFF_ALLMULTI;
+			if (strcmp(*argv, "on") == 0) {
+				req.i.ifi_flags |= IFF_ALLMULTI;
+			} else if (strcmp(*argv, "off") == 0) {
+				req.i.ifi_flags &= ~IFF_ALLMULTI;
+			} else
+				return on_off("allmulticast");
+		} else if (strcmp(*argv, "promisc") == 0) {
+			NEXT_ARG();
+			req.i.ifi_change |= IFF_PROMISC;
+			if (strcmp(*argv, "on") == 0) {
+				req.i.ifi_flags |= IFF_PROMISC;
+			} else if (strcmp(*argv, "off") == 0) {
+				req.i.ifi_flags &= ~IFF_PROMISC;
+			} else
+				return on_off("promisc");
+		} else if (strcmp(*argv, "trailers") == 0) {
+			NEXT_ARG();
+			req.i.ifi_change |= IFF_NOTRAILERS;
+			if (strcmp(*argv, "off") == 0) {
+				req.i.ifi_flags |= IFF_NOTRAILERS;
+			} else if (strcmp(*argv, "on") == 0) {
+				req.i.ifi_flags &= ~IFF_NOTRAILERS;
+			} else
+				return on_off("trailers");
+		} else if (strcmp(*argv, "arp") == 0) {
+			NEXT_ARG();
+			req.i.ifi_change |= IFF_NOARP;
+			if (strcmp(*argv, "on") == 0) {
+				req.i.ifi_flags &= ~IFF_NOARP;
+			} else if (strcmp(*argv, "off") == 0) {
+				req.i.ifi_flags |= IFF_NOARP;
+			} else
+				return on_off("noarp");
+#ifdef IFF_DYNAMIC
+		} else if (matches(*argv, "dynamic") == 0) {
+			NEXT_ARG();
+			req.i.ifi_change |= IFF_DYNAMIC;
+			if (strcmp(*argv, "on") == 0) {
+				req.i.ifi_flags |= IFF_DYNAMIC;
+			} else if (strcmp(*argv, "off") == 0) {
+				req.i.ifi_flags &= ~IFF_DYNAMIC;
+			} else
+				return on_off("dynamic");
+#endif
+		} else if (matches(*argv, "type") == 0) {
+			NEXT_ARG();
+			type = *argv;
+			argc--; argv++;
+			break;
+		} else {
+                        if (strcmp(*argv, "dev") == 0) {
+				NEXT_ARG();
+			}
+			if (dev)
+				duparg2("dev", *argv);
+			dev = *argv;
+		}
+		argc--; argv++;
+	}
+
+	ll_init_map(&rth);
+
+	if (type) {
+		struct rtattr *linkinfo = NLMSG_TAIL(&req.n);
+		addattr_l(&req.n, sizeof(req), IFLA_LINKINFO, NULL, 0);
+		addattr_l(&req.n, sizeof(req), IFLA_INFO_KIND, type,
+			 strlen(type));
+
+		lu = get_link_kind(type);
+		if (lu && argc) {
+			struct rtattr * data = NLMSG_TAIL(&req.n);
+			addattr_l(&req.n, sizeof(req), IFLA_INFO_DATA, NULL, 0);
+
+			if (lu->parse_opt &&
+			    lu->parse_opt(lu, argc, argv, &req.n))
+				return -1;
+
+			data->rta_len = (void *)NLMSG_TAIL(&req.n) - (void *)data;
+		} else if (argc) {
+			if (matches(*argv, "help") == 0)
+				usage();
+			fprintf(stderr, "Garbage instead of arguments \"%s ...\". "
+					"Try \"ip link help\".\n", *argv);
+			return -1;
+		}
+		linkinfo->rta_len = (void *)NLMSG_TAIL(&req.n) - (void *)linkinfo;
+	}
+
+	if (!(flags & NLM_F_CREATE)) {
+		if (!dev) {
+			fprintf(stderr, "Not enough information: \"dev\" "
+					"argument is required.\n");
+			exit(-1);
+		}
+
+		req.i.ifi_index = ll_name_to_index(dev);
+		if (req.i.ifi_index == 0) {
+			fprintf(stderr, "Cannot find device \"%s\"\n", dev);
+			return -1;
+		}
+	} else {
+		/* Allow "ip link add dev" and "ip link add name" */
+		if (!name)
+			name = dev;
+
+		if (link) {
+			int ifindex;
+
+			ifindex = ll_name_to_index(link);
+			if (ifindex == 0) {
+				fprintf(stderr, "Cannot find device \"%s\"\n",
+					link);
+				return -1;
+			}
+			addattr_l(&req.n, sizeof(req), IFLA_LINK, &ifindex, 4);
+		}
+	}
+
+	if (name) {
+		len = strlen(name) + 1;
+		if (len > IFNAMSIZ)
+			invarg("\"name\" too long\n", *argv);
+		addattr_l(&req.n, sizeof(req), IFLA_IFNAME, name, len);
+	}
+
+	if (rtnl_talk(&rth, &req.n, 0, 0, NULL, NULL, NULL) < 0)
+		exit(2);
+
+	return 0;
+}
+
+#if IPLINK_IOCTL_COMPAT
 static int get_ctl_fd(void)
 {
 	int s_errno;
@@ -410,12 +696,33 @@ static int do_set(int argc, char **argv)
 		return do_chflags(dev, flags, mask);
 	return 0;
 }
+#endif /* IPLINK_IOCTL_COMPAT */
 
 int do_iplink(int argc, char **argv)
 {
 	if (argc > 0) {
-		if (matches(*argv, "set") == 0)
-			return do_set(argc-1, argv+1);
+		if (iplink_have_newlink()) {
+			if (matches(*argv, "add") == 0)
+				return iplink_modify(RTM_NEWLINK,
+						     NLM_F_CREATE|NLM_F_EXCL,
+						     argc-1, argv+1);
+			if (matches(*argv, "set") == 0 ||
+			    matches(*argv, "change") == 0)
+				return iplink_modify(RTM_NEWLINK, 0,
+						     argc-1, argv+1);
+			if (matches(*argv, "replace") == 0)
+				return iplink_modify(RTM_NEWLINK,
+						     NLM_F_CREATE|NLM_F_REPLACE,
+						     argc-1, argv+1);
+			if (matches(*argv, "delete") == 0)
+				return iplink_modify(RTM_DELLINK, 0,
+						     argc-1, argv+1);
+		} else {
+#if IPLINK_IOCTL_COMPAT
+			if (matches(*argv, "set") == 0)
+				return do_set(argc-1, argv+1);
+#endif
+		}
 		if (matches(*argv, "show") == 0 ||
 		    matches(*argv, "lst") == 0 ||
 		    matches(*argv, "list") == 0)
