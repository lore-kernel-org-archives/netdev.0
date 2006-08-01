From: Balazs Scheidler <bazsi@balabit.hu>
Subject: [patch] RFC: matching interface groups
Date: Tue, 01 Aug 2006 19:10:09 +0200
Message-ID: <1154452209.6395.77.camel@bzorp.balabit>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@lists.netfilter.org, shemminger@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from balabit.hu ([82.141.167.23]:20882 "EHLO balabit.hu")
	by vger.kernel.org with ESMTP id S1751734AbWHARiw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2006 13:38:52 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I would like to easily match a set of dynamically created interfaces
from my packet filter rules. The attached patch forms the basis of my
implementation and I would like to know whether something like this is
mergeable to mainline.

The use-case is as follows:

* I have two different subsystems creating interfaces dynamically (for
example pptpd and serial pppd lines, each creating dynamic pppX
interfaces),
* I would like to assign a different set of iptables rules for these
clients,
* I would like to react to a new interface being added to a specific set
in a userspace application,

The reasons I see this needs new kernel functionality:

* iptables supports wildcard interface matching (for example "iptables
-i ppp+"), but as the names of the interfaces used by PPTPD and PPPD
cannot be distinguished this way, this is not enough,
* Reloading the iptables ruleset everytime a new interface comes up is
not really feasible, as it abrupts packet processing, and validating the
ruleset in the kernel can take significant amount of time,
* the kernel change is very simple, adapting userspace to this change is
also very simple, and in userspace various software packages can easily
interoperate with each-other once this is merged.

The implementation:

Each interface can belong to a single "group" at a time, an interface
comes up without being a member in any of the groups.

Userspace can assign interfaces to groups after being created, this
would typically be performed in /etc/ppp/ip-up.d (and similar) scripts.

In spirit "interface group" is somewhat similar to the "routing
protocol" field for routing entries, which contains information on which
routing daemon was responsible for adding the given route entry.

Things to be done if you like this approach:

* interface group match in iptables,
* support for naming interface groups in userspace, a'la routing
protocols,
* emitting a netlink notification when the group of an interface
changes,
* possibly converting the "ip link" command to use NETLINK messages,
instead of using ioctl()

What do you think?

kernel patch:
-------------

* add a numeric ID to each interface in the system, denoting its
"interface group",


index df0cdd4..19a103a 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -736,6 +736,8 @@ enum
 #define IFLA_WEIGHT IFLA_WEIGHT
        IFLA_OPERSTATE,
        IFLA_LINKMODE,
+#define IFLA_IFGROUP IFLA_IFGROUP
+       IFLA_IFGROUP,
        __IFLA_MAX
 };

diff --git a/include/linux/sockios.h b/include/linux/sockios.h
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 3fcfa9c..26849af 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -279,6 +279,11 @@ static int rtnetlink_fill_ifinfo(struct
                u32 iflink = dev->iflink;
                RTA_PUT(skb, IFLA_LINK, sizeof(iflink), &iflink);
        }
+
+       if (dev->ifgroup) {
+               u32 ifgroup = dev->ifgroup;
+               RTA_PUT(skb, IFLA_IFGROUP, sizeof(ifgroup), &ifgroup);
+       }

        if (dev->qdisc_sleeping)
                RTA_PUT(skb, IFLA_QDISC,
@@ -459,6 +464,12 @@ static int do_setlink(struct sk_buff *sk
                dev->link_mode = *((u8 *) RTA_DATA(ida[IFLA_LINKMODE - 1]));
                write_unlock_bh(&dev_base_lock);
        }
+
+       if (ida[IFLA_IFGROUP - 1]) {
+               if (ida[IFLA_IFGROUP - 1]->rta_len != RTA_LENGTH(sizeof(u32)))
+                       goto out;
+               dev->ifgroup = *((u32 *) RTA_DATA(ida[IFLA_IFGROUP - 1]));
+       }

        if (ifm->ifi_index >= 0 && ida[IFLA_IFNAME - 1]) {
                char ifname[IFNAMSIZ];


ip route patch:
---------------

* added a "group" option to ip link set to make it possible to set this
id, and a way to print this option


diff --git a/ip/iplink.c b/ip/iplink.c
index ffc9f06..e694475 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -26,6 +26,7 @@
 #include <string.h>
 #include <sys/ioctl.h>
 #include <linux/sockios.h>
+#include <linux/rtnetlink.h>

 #include "rt_names.h"
 #include "utils.h"
@@ -44,6 +45,7 @@ void iplink_usage(void)
        fprintf(stderr, "                            promisc { on | off } |\n");
        fprintf(stderr, "                            trailers { on | off } |\n");
        fprintf(stderr, "                            txqueuelen PACKETS |\n");
+       fprintf(stderr, "                            group GROUP |\n");
        fprintf(stderr, "                            name NEWNAME |\n");
        fprintf(stderr, "                            address LLADDR | broadcast LLADDR |\n");
        fprintf(stderr, "                            mtu MTU }\n");
@@ -174,6 +176,28 @@ static int set_mtu(const char *dev, int
        return 0;
 }

+static int set_group(const char *dev, int ifgroup)
+{
+       struct {
+               struct nlmsghdr         n;
+               struct ifinfomsg        ifi;
+               char                    buf[256];
+       } req;
+
+       memset(&req, 0, sizeof(req));
+       req.n.nlmsg_len = NLMSG_LENGTH(sizeof(req.ifi));
+       req.n.nlmsg_flags = NLM_F_REQUEST;
+       req.n.nlmsg_type = RTM_SETLINK;
+
+       req.ifi.ifi_index = -1;
+
+       addattr_l(&req.n, sizeof(req), IFLA_IFNAME, dev, strlen(dev)+1);
+       addattr_l(&req.n, sizeof(req), IFLA_IFGROUP, &ifgroup, sizeof(ifgroup));
+       if (rtnl_talk(&rth, &req.n, 0, 0, NULL, NULL, NULL) < 0)
+               return -1;
+       return 0;
+}
+
 static int get_address(const char *dev, int *htype)
 {
        struct ifreq ifr;
@@ -257,6 +281,7 @@ static int do_set(int argc, char **argv)
        __u32 mask = 0;
        __u32 flags = 0;
        int qlen = -1;
+       int group = 0;
        int mtu = -1;
        char *newaddr = NULL;
        char *newbrd = NULL;
@@ -289,6 +314,12 @@ static int do_set(int argc, char **argv)
                                duparg("txqueuelen", *argv);
                        if (get_integer(&qlen,  *argv, 0))
                                invarg("Invalid \"txqueuelen\" value\n", *argv);
+               } else if (matches(*argv, "group") == 0) {
+                       NEXT_ARG();
+                       if (group != 0)
+                               duparg("group", *argv);
+                       if (get_integer(&group, *argv, 0) || group == 0)
+                               invarg("Invalid \"group\" value\n", *argv);
                } else if (strcmp(*argv, "mtu") == 0) {
                        NEXT_ARG();
                        if (mtu != -1)
@@ -406,6 +437,10 @@ static int do_set(int argc, char **argv)
                                return -1;
                }
        }
+       if (group) {
+               if (set_group(dev, group) < 0)
+                       return -1;
+       }
        if (mask)
                return do_chflags(dev, flags, mask);
        return 0;


-- 
Bazsi

