From: Thomas Graf <tgraf@suug.ch>
Subject: Re: iproute2 patch introducing mtu/txqlen/weight via rtnetlink
Date: Fri, 10 Sep 2004 18:55:08 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040910165508.GI20088@postel.suug.ch>
References: <20040909164834.GB18994@postel.suug.ch> <20040909103344.5a448b01.davem@davemloft.net> <20040909175411.GB19155@postel.suug.ch> <20040910.103341.28767986.yoshfuji@wide.ad.jp> <20040910092948.GB19930@postel.suug.ch> <20040910024030.28b7c66c@linux.site> <1094822205.1125.113.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>,
        "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@wide.ad.jp>,
        davem@davemloft.net, eric.lemoine@gmail.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1094822205.1125.113.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1094822205.1125.113.camel@jzny.localdomain> 2004-09-10 09:16
> 
> On Fri, 2004-09-10 at 05:40, Stephen Hemminger wrote:
> > Unless there is some compelling reason, I think that keeping the old ioctl
> > interface for a least a year until the kernel changes become more ubiquitous.
> 
> I think that iproute2 should first attempt to use netlink and on failure
> switch to ioctls.
> Maybe Thomas can create such a patch.

 - Uses rtnetlink whenver possible and falls back to ioctl if the
   rtnetlink call fails or one of the changes was not successful.
   Not 100% perfect yet but you'll get the point.

 - Fixes memory corruption issue. buffer for address and brd was too
   small (14) for bigger addresses, e.g. interfaces with ipv6 ll
   addresses. Introduced a ADDRBUFSIZ and a check in ll_init_map to
   avoid further problems.

 - Uses ifinfomsg.ifi_type instead of getting hw type from packet
   socket. I hope this is correct.

just a small hack...

diff -Nru iproute2-2.6.9-jamal.orig/include/linux/rtnetlink.h iproute2-2.6.9-jamal/include/linux/rtnetlink.h
--- iproute2-2.6.9-jamal.orig/include/linux/rtnetlink.h	2004-09-08 19:23:18.000000000 +0200
+++ iproute2-2.6.9-jamal/include/linux/rtnetlink.h	2004-09-10 17:51:28.000000000 +0200
@@ -561,6 +561,12 @@
 #define IFLA_WIRELESS IFLA_WIRELESS
 	IFLA_PROTINFO,		/* Protocol specific information for a link */
 #define IFLA_PROTINFO IFLA_PROTINFO
+	IFLA_TXQLEN,
+#define IFLA_TXQLEN IFLA_TXQLEN
+	IFLA_MAP,
+#define IFLA_MAP IFLA_MAP
+	IFLA_WEIGHT,
+#define IFLA_WEIGHT IFLA_WEIGHT
 	__IFLA_MAX
 };
 
diff -Nru iproute2-2.6.9-jamal.orig/include/ll_map.h iproute2-2.6.9-jamal/include/ll_map.h
--- iproute2-2.6.9-jamal.orig/include/ll_map.h	2004-09-08 19:23:18.000000000 +0200
+++ iproute2-2.6.9-jamal/include/ll_map.h	2004-09-10 18:37:45.000000000 +0200
@@ -1,12 +1,17 @@
 #ifndef __LL_MAP_H__
 #define __LL_MAP_H__ 1
 
+#define ADDRBUFSIZ 32
+
 extern int ll_remember_index(struct sockaddr_nl *who, struct nlmsghdr *n, void *arg);
 extern int ll_init_map(struct rtnl_handle *rth);
 extern int ll_name_to_index(char *name);
 extern const char *ll_index_to_name(int idx);
 extern const char *ll_idx_n2a(int idx, char *buf);
 extern int ll_index_to_type(int idx);
+extern int ll_index_to_alen(int idx);
+extern unsigned char *ll_index_to_addr(int idx);
+extern unsigned char *ll_index_to_brd(int idx);
 extern unsigned ll_index_to_flags(int idx);
 
 #endif /* __LL_MAP_H__ */
diff -Nru iproute2-2.6.9-jamal.orig/ip/ipaddress.c iproute2-2.6.9-jamal/ip/ipaddress.c
--- iproute2-2.6.9-jamal.orig/ip/ipaddress.c	2004-09-08 19:23:18.000000000 +0200
+++ iproute2-2.6.9-jamal/ip/ipaddress.c	2004-09-10 17:52:38.000000000 +0200
@@ -182,6 +182,10 @@
 		fprintf(fp, "mtu %u ", *(int*)RTA_DATA(tb[IFLA_MTU]));
 	if (tb[IFLA_QDISC])
 		fprintf(fp, "qdisc %s ", (char*)RTA_DATA(tb[IFLA_QDISC]));
+#ifdef IFLA_WEIGT
+	if (tb[IFLA_WEIGHT])
+		fprintf(fp, "weight %u ", *(uint32_t*)RTA_DATA(tb[IFLA_WEIGHT]));
+#endif
 #ifdef IFLA_MASTER
 	if (tb[IFLA_MASTER]) {
 		SPRINT_BUF(b1);
diff -Nru iproute2-2.6.9-jamal.orig/ip/iplink.c iproute2-2.6.9-jamal/ip/iplink.c
--- iproute2-2.6.9-jamal.orig/ip/iplink.c	2004-09-08 19:23:18.000000000 +0200
+++ iproute2-2.6.9-jamal/ip/iplink.c	2004-09-10 18:43:04.000000000 +0200
@@ -25,7 +25,7 @@
 #include <arpa/inet.h>
 #include <string.h>
 #include <sys/ioctl.h>
-#include <linux/sockios.h>
+#include <linux/rtnetlink.h>
 
 #include "rt_names.h"
 #include "utils.h"
@@ -46,6 +46,9 @@
 	fprintf(stderr, "	                     txqueuelen PACKETS |\n");
 	fprintf(stderr, "	                     name NEWNAME |\n");
 	fprintf(stderr, "	                     address LLADDR | broadcast LLADDR |\n");
+#ifdef IFLA_WEIGHT
+	fprintf(stderr, "                        weight WEIGHT |\n");
+#endif
 	fprintf(stderr, "	                     mtu MTU }\n");
 	fprintf(stderr, "       ip link show [ DEVICE ]\n");
 	exit(-1);
@@ -174,48 +177,6 @@
 	return 0; 
 }
 
-static int get_address(char *dev, int *htype)
-{
-	struct ifreq ifr;
-	struct sockaddr_ll me;
-	int alen;
-	int s;
-
-	s = socket(PF_PACKET, SOCK_DGRAM, 0);
-	if (s < 0) { 
-		perror("socket(PF_PACKET)");
-		return -1;
-	}
-
-	memset(&ifr, 0, sizeof(ifr));
-	strcpy(ifr.ifr_name, dev);
-	if (ioctl(s, SIOCGIFINDEX, &ifr) < 0) {
-		perror("SIOCGIFINDEX");
-		close(s);
-		return -1;
-	}
-
-	memset(&me, 0, sizeof(me));
-	me.sll_family = AF_PACKET;
-	me.sll_ifindex = ifr.ifr_ifindex;
-	me.sll_protocol = htons(ETH_P_LOOP);
-	if (bind(s, (struct sockaddr*)&me, sizeof(me)) == -1) {
-		perror("bind");
-		close(s);
-		return -1;
-	}
-
-	alen = sizeof(me);
-	if (getsockname(s, (struct sockaddr*)&me, &alen) == -1) {
-		perror("getsockname");
-		close(s);
-		return -1;
-	}
-	close(s);
-	*htype = me.sll_hatype;
-	return me.sll_halen;
-}
-
 static int parse_address(char *dev, int hatype, int halen, char *lla, struct ifreq *ifr)
 {
 	int alen;
@@ -223,7 +184,7 @@
 	memset(ifr, 0, sizeof(*ifr));
 	strcpy(ifr->ifr_name, dev);
 	ifr->ifr_hwaddr.sa_family = hatype;
-	alen = ll_addr_a2n(ifr->ifr_hwaddr.sa_data, 14, lla);
+	alen = ll_addr_a2n(ifr->ifr_hwaddr.sa_data, ADDRBUFSIZ, lla);
 	if (alen < 0)
 		return -1;
 	if (alen != halen) {
@@ -249,19 +210,46 @@
 	return 0; 
 }
 
+struct link_request
+{
+	struct nlmsghdr     nl_msg;
+	struct ifinfomsg    ifi;
+	char buf[256];
+};
+
+#define USE_IOCTL_MTU 1
+#define USE_IOCTL_TXQLEN 2
+#define USE_IOCTL_FLAGS 4
+#define USE_IOCTL_NAME 8
+#define USE_IOCTL_ADDR 16
+#define USE_IOCTL_BRD 32
 
 static int do_set(int argc, char **argv)
 {
 	char *dev = NULL;
 	__u32 mask = 0;
 	__u32 flags = 0;
-	int qlen = -1;
-	int mtu = -1;
+	int32_t qlen = -1;
+	int32_t mtu = -1;
+	int32_t weight = -1;
 	char *newaddr = NULL;
 	char *newbrd = NULL;
 	struct ifreq ifr0, ifr1;
 	char *newname = NULL;
 	int htype, halen;
+	struct rtnl_handle rth;
+	int use_ioctl_mask = 0;
+	
+	struct link_request req = {
+		.nl_msg = {
+			.nlmsg_type = RTM_SETLINK,
+			.nlmsg_flags = NLM_F_REQUEST,
+			.nlmsg_len = NLMSG_LENGTH(sizeof(struct ifinfomsg)),
+		},
+		.ifi = {
+			.ifi_family = PF_PACKET,
+		},
+	};
 
 	while (argc > 0) {
 		if (strcmp(*argv, "up") == 0) {
@@ -288,12 +276,22 @@
 				duparg("txqueuelen", *argv);
 			if (get_integer(&qlen,  *argv, 0))
 				invarg("Invalid \"txqueuelen\" value\n", *argv);
+#ifdef IFLA_TXQLEN
+			addattr_l(&req.nl_msg, sizeof(req), IFLA_TXQLEN, &qlen, sizeof(qlen));
+#else
+			use_ioctl_mask |= USE_IOCTL_TXQLEN;
+#endif
 		} else if (strcmp(*argv, "mtu") == 0) {
 			NEXT_ARG();
 			if (mtu != -1)
 				duparg("mtu", *argv);
 			if (get_integer(&mtu, *argv, 0))
 				invarg("Invalid \"mtu\" value\n", *argv);
+#ifdef IFLA_MTU
+			addattr_l(&req.nl_msg, sizeof(req), IFLA_MTU, &mtu, sizeof(mtu));
+#else
+			use_ioctl_mask |= USE_IOCTL_MTU;
+#endif
 		} else if (strcmp(*argv, "multicast") == 0) {
 			NEXT_ARG();
 			mask |= IFF_MULTICAST;
@@ -339,6 +337,15 @@
 				flags |= IFF_NOARP;
 			} else
 				return on_off("noarp");
+#ifdef IFLA_WEIGHT
+		} else if (matches(*argv, "weight") == 0) {
+			NEXT_ARG();
+			if (weight != -1)
+				duparg("weight", *argv);
+			if (get_integer(&weight,  *argv, 0))
+				invarg("Invalid \"weight\" value\n", *argv);
+			addattr_l(&req.nl_msg, sizeof(req), IFLA_WEIGHT, &weight, sizeof(weight));
+#endif
 #ifdef IFF_DYNAMIC
 		} else if (matches(*argv, "dynamic") == 0) {
 			NEXT_ARG();
@@ -367,20 +374,85 @@
 		fprintf(stderr, "Not enough of information: \"dev\" argument is required.\n");
 		exit(-1);
 	}
+	
+	if (rtnl_open(&rth, 0) < 0)
+		exit(1);
+
+	ll_init_map(&rth);
+	
+	if ((req.ifi.ifi_index = ll_name_to_index(dev)) == 0) {
+		fprintf(stderr, "Cannot find device \"%s\"\n", dev);
+		return -1;
+	}
+	
+	if (mask) {
+		req.ifi.ifi_flags = ll_index_to_flags(req.ifi.ifi_index);
+		if ((req.ifi.ifi_flags ^ flags) & mask) {
+			req.ifi.ifi_flags &= ~mask;
+			req.ifi.ifi_flags |= mask & flags;
+		}
+	}
 
 	if (newaddr || newbrd) {
-		halen = get_address(dev, &htype);
+		halen = ll_index_to_alen(req.ifi.ifi_index);
+		htype = ll_index_to_type(req.ifi.ifi_index);
+
 		if (halen < 0)
 			return -1;
+
 		if (newaddr) {
 			if (parse_address(dev, htype, halen, newaddr, &ifr0) < 0)
 				return -1;
+
+			addattr_l(&req.nl_msg, sizeof(req), IFLA_ADDRESS, ifr0.ifr_hwaddr.sa_data, halen);
 		}
+
 		if (newbrd) {
 			if (parse_address(dev, htype, halen, newbrd, &ifr1) < 0)
 				return -1; 
+			addattr_l(&req.nl_msg, sizeof(req), IFLA_BROADCAST, ifr1.ifr_hwaddr.sa_data, halen);
 		}
 	}
+	
+	if (newname && strcmp(dev, newname)) {
+		char ifname[IFNAMSIZ] = {0};
+		
+		strncpy(ifname, newname, sizeof(ifname) - 1);
+		addattr_l(&req.nl_msg, sizeof(req), IFLA_IFNAME, ifname,
+			strlen(ifname) + 1);
+	}
+	
+	if (rtnl_talk(&rth, &req.nl_msg, 0, 0, NULL, NULL, NULL) == 0)
+	{
+		/* successful but check if everything is implemented */
+		ll_init_map(&rth);
+
+		if (mask)
+			if ((ll_index_to_flags(req.ifi.ifi_index) ^ flags) & mask)
+				use_ioctl_mask |= USE_IOCTL_FLAGS;
+
+		if (newaddr)
+			if (memcmp(ifr0.ifr_hwaddr.sa_data,
+				ll_index_to_addr(req.ifi.ifi_index),
+				ll_index_to_alen(req.ifi.ifi_index)))
+					use_ioctl_mask |= USE_IOCTL_ADDR;
+
+		if (newbrd)
+			if (memcmp(ifr1.ifr_hwaddr.sa_data,
+				ll_index_to_brd(req.ifi.ifi_index),
+				ll_index_to_alen(req.ifi.ifi_index)))
+					use_ioctl_mask |= USE_IOCTL_BRD;
+
+		if (newname && strcmp(dev, newname))
+			if (strcmp(newname, ll_index_to_name(req.ifi.ifi_index)))
+				use_ioctl_mask |= USE_IOCTL_NAME;
+
+		if (use_ioctl_mask == 0)
+			return 0;
+	}
+
+	printf("rtnetlink method failed, trying ioctl...\n");
+	/* rtnetlink method failed, try ioctl */
 
 	if (newname && strcmp(dev, newname)) {
 		if (do_changename(dev, newname) < 0)
@@ -407,6 +479,7 @@
 	}
 	if (mask)
 		return do_chflags(dev, flags, mask);
+
 	return 0;
 }
 
diff -Nru iproute2-2.6.9-jamal.orig/lib/ll_map.c iproute2-2.6.9-jamal/lib/ll_map.c
--- iproute2-2.6.9-jamal.orig/lib/ll_map.c	2004-09-08 19:23:18.000000000 +0200
+++ iproute2-2.6.9-jamal/lib/ll_map.c	2004-09-10 18:33:53.000000000 +0200
@@ -29,7 +29,8 @@
 	int		type;
 	int		alen;
 	unsigned	flags;
-	unsigned char	addr[8];
+	unsigned char	addr[ADDRBUFSIZ];
+	unsigned char   brd[ADDRBUFSIZ];
 	char		name[16];
 };
 
@@ -74,6 +75,10 @@
 	if (tb[IFLA_ADDRESS]) {
 		int alen;
 		im->alen = alen = RTA_PAYLOAD(tb[IFLA_ADDRESS]);
+		if (alen > ADDRBUFSIZ) {
+			fprintf(stderr, "Increase ADDRBUFSIZ\n");
+			return -1;
+		}
 		if (alen > sizeof(im->addr))
 			alen = sizeof(im->addr);
 		memcpy(im->addr, RTA_DATA(tb[IFLA_ADDRESS]), alen);
@@ -81,6 +86,17 @@
 		im->alen = 0;
 		memset(im->addr, 0, sizeof(im->addr));
 	}
+	if (tb[IFLA_BROADCAST]) {
+		int alen = RTA_PAYLOAD(tb[IFLA_BROADCAST]);
+		if (alen > ADDRBUFSIZ) {
+			fprintf(stderr, "Increase ADDRBUFSIZ\n");
+			return -1;
+		}
+		if (alen != im->alen)
+			return -1;
+		memcpy(im->brd, RTA_DATA(tb[IFLA_BROADCAST]), alen);
+	} else
+		memset(im->brd, 0, sizeof(im->brd));
 	strcpy(im->name, RTA_DATA(tb[IFLA_IFNAME]));
 	return 0;
 }
@@ -118,6 +134,42 @@
 	return -1;
 }
 
+int ll_index_to_alen(int idx)
+{
+	struct idxmap *im;
+	
+	if (idx == 0)
+		return -1;
+	for (im = idxmap[idx&0xF]; im; im = im->next)
+		if (im->index == idx)
+			return im->alen;
+	return -1;
+}
+
+unsigned char * ll_index_to_addr(int idx)
+{
+	struct idxmap *im;
+	
+	if (idx == 0)
+		return NULL;
+	for (im = idxmap[idx&0xF]; im; im = im->next)
+		if (im->index == idx)
+			return im->addr;
+	return NULL;
+}
+
+unsigned char * ll_index_to_brd(int idx)
+{
+	struct idxmap *im;
+	
+	if (idx == 0)
+		return NULL;
+	for (im = idxmap[idx&0xF]; im; im = im->next)
+		if (im->index == idx)
+			return im->brd;
+	return NULL;
+}
+
 unsigned ll_index_to_flags(int idx)
 {
 	struct idxmap *im;
