From: Thomas Graf <tgraf@suug.ch>
Subject: Re: iproute2 patch introducing mtu/txqlen/weight via rtnetlink
Date: Thu, 9 Sep 2004 19:54:11 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040909175411.GB19155@postel.suug.ch>
References: <20040909164834.GB18994@postel.suug.ch> <20040909103344.5a448b01.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, shemminger@osdl.org, eric.lemoine@gmail.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040909103344.5a448b01.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* David S. Miller <20040909103344.5a448b01.davem@davemloft.net> 2004-09-09 10:33
> On Thu, 9 Sep 2004 18:48:34 +0200
> Thomas Graf <tgraf@suug.ch> wrote:
> 
> > - Convert mtu and txqlen to use rtnetlink instead of ioctl.
> > - Introduces weight.
> > - Updates local copy of rtnetlink.h.
> > 
> > Against iproute2-2.6.9-jamal, tested and working.
> > Will look into remaining ioctls later.
> 
> Please don't blindly update rtnetlink.h in iproute2 with
> the current kernel copy.  The "__KERNEL__" ifdef area
> is omitted on purpose, yet you added it back in.

Sorry, included old patch, this is a correct one:


diff -Nru iproute2-2.6.9-jamal.orig/include/linux/rtnetlink.h iproute2-2.6.9-jamal/include/linux/rtnetlink.h
--- iproute2-2.6.9-jamal.orig/include/linux/rtnetlink.h	2004-09-08 19:23:18.000000000 +0200
+++ iproute2-2.6.9-jamal/include/linux/rtnetlink.h	2004-09-09 19:46:26.000000000 +0200
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
 
diff -Nru iproute2-2.6.9-jamal.orig/ip/ipaddress.c iproute2-2.6.9-jamal/ip/ipaddress.c
--- iproute2-2.6.9-jamal.orig/ip/ipaddress.c	2004-09-08 19:23:18.000000000 +0200
+++ iproute2-2.6.9-jamal/ip/ipaddress.c	2004-09-08 19:57:30.000000000 +0200
@@ -182,6 +182,8 @@
 		fprintf(fp, "mtu %u ", *(int*)RTA_DATA(tb[IFLA_MTU]));
 	if (tb[IFLA_QDISC])
 		fprintf(fp, "qdisc %s ", (char*)RTA_DATA(tb[IFLA_QDISC]));
+	if (tb[IFLA_WEIGHT])
+		fprintf(fp, "weight %u ", *(uint32_t*)RTA_DATA(tb[IFLA_WEIGHT]));
 #ifdef IFLA_MASTER
 	if (tb[IFLA_MASTER]) {
 		SPRINT_BUF(b1);
diff -Nru iproute2-2.6.9-jamal.orig/ip/iplink.c iproute2-2.6.9-jamal/ip/iplink.c
--- iproute2-2.6.9-jamal.orig/ip/iplink.c	2004-09-08 19:23:18.000000000 +0200
+++ iproute2-2.6.9-jamal/ip/iplink.c	2004-09-09 19:50:51.000000000 +0200
@@ -21,6 +21,7 @@
 #include <linux/if_packet.h>
 #include <linux/if_ether.h>
 #include <linux/sockios.h>
+#include <linux/rtnetlink.h>
 #include <netinet/in.h>
 #include <arpa/inet.h>
 #include <string.h>
@@ -46,7 +47,8 @@
 	fprintf(stderr, "	                     txqueuelen PACKETS |\n");
 	fprintf(stderr, "	                     name NEWNAME |\n");
 	fprintf(stderr, "	                     address LLADDR | broadcast LLADDR |\n");
-	fprintf(stderr, "	                     mtu MTU }\n");
+	fprintf(stderr, "	                     mtu MTU |\n");
+	fprintf(stderr, "	                     weight WEIGHT }\n");
 	fprintf(stderr, "       ip link show [ DEVICE ]\n");
 	exit(-1);
 }
@@ -130,50 +132,6 @@
 	return err;
 }
 
-static int set_qlen(char *dev, int qlen)
-{
-	struct ifreq ifr;
-	int s;
-
-	s = get_ctl_fd();
-	if (s < 0)
-		return -1;
-
-	memset(&ifr, 0, sizeof(ifr));
-	strcpy(ifr.ifr_name, dev); 
-	ifr.ifr_qlen = qlen; 
-	if (ioctl(s, SIOCSIFTXQLEN, &ifr) < 0) {
-		perror("SIOCSIFXQLEN");
-		close(s);
-		return -1;
-	}
-	close(s);
-
-	return 0; 
-}
-
-static int set_mtu(char *dev, int mtu)
-{
-	struct ifreq ifr;
-	int s;
-
-	s = get_ctl_fd();
-	if (s < 0)
-		return -1;
-
-	memset(&ifr, 0, sizeof(ifr));
-	strcpy(ifr.ifr_name, dev); 
-	ifr.ifr_mtu = mtu; 
-	if (ioctl(s, SIOCSIFMTU, &ifr) < 0) {
-		perror("SIOCSIFMTU");
-		close(s);
-		return -1;
-	}
-	close(s);
-
-	return 0; 
-}
-
 static int get_address(char *dev, int *htype)
 {
 	struct ifreq ifr;
@@ -249,19 +207,39 @@
 	return 0; 
 }
 
+struct link_request
+{
+	struct nlmsghdr     nl_msg;
+	struct ifinfomsg    ifi;
+	char buf[256];
+};
+
 
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
@@ -288,12 +266,14 @@
 				duparg("txqueuelen", *argv);
 			if (get_integer(&qlen,  *argv, 0))
 				invarg("Invalid \"txqueuelen\" value\n", *argv);
+			addattr_l(&req.nl_msg, sizeof(req), IFLA_TXQLEN, &qlen, sizeof(qlen));
 		} else if (strcmp(*argv, "mtu") == 0) {
 			NEXT_ARG();
 			if (mtu != -1)
 				duparg("mtu", *argv);
 			if (get_integer(&mtu, *argv, 0))
 				invarg("Invalid \"mtu\" value\n", *argv);
+			addattr_l(&req.nl_msg, sizeof(req), IFLA_MTU, &mtu, sizeof(mtu));
 		} else if (strcmp(*argv, "multicast") == 0) {
 			NEXT_ARG();
 			mask |= IFF_MULTICAST;
@@ -339,6 +319,13 @@
 				flags |= IFF_NOARP;
 			} else
 				return on_off("noarp");
+		} else if (matches(*argv, "weight") == 0) {
+			NEXT_ARG();
+			if (weight != -1)
+				duparg("weight", *argv);
+			if (get_integer(&weight,  *argv, 0))
+				invarg("Invalid \"weight\" value\n", *argv);
+			addattr_l(&req.nl_msg, sizeof(req), IFLA_WEIGHT, &weight, sizeof(weight));
 #ifdef IFF_DYNAMIC
 		} else if (matches(*argv, "dynamic") == 0) {
 			NEXT_ARG();
@@ -387,14 +374,6 @@
 			return -1;
 		dev = newname;
 	}
-	if (qlen != -1) { 
-		if (set_qlen(dev, qlen) < 0)
-			return -1; 
-	}
-	if (mtu != -1) { 
-		if (set_mtu(dev, mtu) < 0)
-			return -1; 
-	}
 	if (newaddr || newbrd) {
 		if (newbrd) {
 			if (set_address(&ifr1, 1) < 0)
@@ -407,6 +386,20 @@
 	}
 	if (mask)
 		return do_chflags(dev, flags, mask);
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
+	if (rtnl_talk(&rth, &req.nl_msg, 0, 0, NULL, NULL, NULL) < 0)
+		exit(2);
+
 	return 0;
 }
 
