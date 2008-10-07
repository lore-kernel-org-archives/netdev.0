From: Patrick McHardy <kaber@trash.net>
Subject: [IPROUTE]: Fix up "ip link" help text
Date: Tue, 07 Oct 2008 17:17:10 +0200
Message-ID: <48EB7D76.7050004@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000707090407050602080305"
To: Linux Netdev List <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48946 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753375AbYJGPRR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2008 11:17:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000707090407050602080305
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

With this patch, "ip link add help" shows:

Usage: ip link add [ link DEV ] [ name ] NAME
                    [ txqueuelen PACKETS ]
                    [ address LLADDR ]
                    [ broadcast LLADDR ]
                    [ mtu MTU ]
                    type TYPE [ ARGS ]

        ip link set DEVICE [ { up | down } ]
                           [ arp { on | off } ]
                           [ dynamic { on | off } ]
                           [ multicast { on | off } ]
                           [ allmulticast { on | off } ]
                           [ promisc { on | off } ]
                           [ trailers { on | off } ]
                           [ txqueuelen PACKETS ]
                           [ name NEWNAME ]
                           [ address LLADDR ]
                           [ broadcast LLADDR ]
                           [ mtu MTU ]
                           [ netns PID ]
        ip link show [ DEVICE ]

TYPE := { vlan | veth | dummy | ifb | macvlan }

--------------000707090407050602080305
Content-Type: text/x-patch;
 name="03.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="03.diff"

commit 5e52e54c147b631e555294e6446d9c2d609207f2
Author: Patrick McHardy <kaber@trash.net>
Date:   Tue Oct 7 17:15:13 2008 +0200

    [IPROUTE]: Fix up "ip link" help text
    
    Show help for "ip link add" in case its supported by the kernel. Also fix up
    the "ip link set" help text:
    
    - the flags are not mutually exclusive as suggested by the current text,
      up/down states and on/off are mutually exclusive.
    
    - txqueuelen, name etc. have nothing to do with the flags and on/off states
      at all and are certainly not mutually exclusive, fix formatting and make
      it conform the other helptexts better.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/ip/iplink.c b/ip/iplink.c
index 6e9ac71..a99115a 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -37,23 +37,85 @@
 #define LIBDIR "/usr/lib/"
 #endif
 
+#if IPLINK_IOCTL_COMPAT
+static int have_rtnl_newlink = -1;
+
+static int accept_msg(const struct sockaddr_nl *who,
+		      struct nlmsghdr *n, void *arg)
+{
+	struct nlmsgerr *err = (struct nlmsgerr *)NLMSG_DATA(n);
+
+	if (n->nlmsg_type == NLMSG_ERROR &&
+	    (err->error == -EOPNOTSUPP || err->error == -EINVAL))
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
 static void usage(void) __attribute__((noreturn));
 
 void iplink_usage(void)
 {
-	fprintf(stderr, "Usage: ip link set DEVICE { up | down |\n");
-	fprintf(stderr, "	                     arp { on | off } |\n");
-	fprintf(stderr, "	                     dynamic { on | off } |\n");
-	fprintf(stderr, "	                     multicast { on | off } |\n");
-	fprintf(stderr, "	                     allmulticast { on | off } |\n");
-	fprintf(stderr, "	                     promisc { on | off } |\n");
-	fprintf(stderr, "	                     trailers { on | off } |\n");
-	fprintf(stderr, "	                     txqueuelen PACKETS |\n");
-	fprintf(stderr, "	                     name NEWNAME |\n");
-	fprintf(stderr, "	                     address LLADDR | broadcast LLADDR |\n");
-	fprintf(stderr, "	                     mtu MTU }\n");
-	fprintf(stderr, "	                     netns PID }\n");
+	if (iplink_have_newlink()) {
+		fprintf(stderr, "Usage: ip link add [ link DEV ] [ name ] NAME\n");
+		fprintf(stderr, "                   [ txqueuelen PACKETS ]\n");
+		fprintf(stderr, "                   [ address LLADDR ]\n");
+		fprintf(stderr, "                   [ broadcast LLADDR ]\n");
+		fprintf(stderr, "                   [ mtu MTU ]\n");
+		fprintf(stderr, "                   type TYPE [ ARGS ]\n");
+		fprintf(stderr, "\n");
+		fprintf(stderr, "       ip link set DEVICE [ { up | down } ]\n");
+	} else
+		fprintf(stderr, "Usage: ip link set DEVICE [ { up | down } ]\n");
+
+	fprintf(stderr, "	                  [ arp { on | off } ]\n");
+	fprintf(stderr, "	                  [ dynamic { on | off } ]\n");
+	fprintf(stderr, "	                  [ multicast { on | off } ]\n");
+	fprintf(stderr, "	                  [ allmulticast { on | off } ]\n");
+	fprintf(stderr, "	                  [ promisc { on | off } ]\n");
+	fprintf(stderr, "	                  [ trailers { on | off } ]\n");
+	fprintf(stderr, "	                  [ txqueuelen PACKETS ]\n");
+	fprintf(stderr, "	                  [ name NEWNAME ]\n");
+	fprintf(stderr, "	                  [ address LLADDR ]\n");
+	fprintf(stderr, "	                  [ broadcast LLADDR ]\n");
+	fprintf(stderr, "	                  [ mtu MTU ]\n");
+	fprintf(stderr, "	                  [ netns PID ]\n");
 	fprintf(stderr, "       ip link show [ DEVICE ]\n");
+
+	if (iplink_have_newlink()) {
+		fprintf(stderr, "\n");
+		fprintf(stderr, "TYPE := { vlan | veth | dummy | ifb | macvlan }\n");
+	}
+
 	exit(-1);
 }
 
@@ -103,50 +165,6 @@ struct link_util *get_link_kind(const char *id)
 	return l;
 }
 
-#if IPLINK_IOCTL_COMPAT
-static int have_rtnl_newlink = -1;
-
-static int accept_msg(const struct sockaddr_nl *who,
-		      struct nlmsghdr *n, void *arg)
-{
-	struct nlmsgerr *err = (struct nlmsgerr *)NLMSG_DATA(n);
-
-	if (n->nlmsg_type == NLMSG_ERROR &&
-	    (err->error == -EOPNOTSUPP || err->error == -EINVAL))
-		have_rtnl_newlink = 0;
-	else
-		have_rtnl_newlink = 1;
-	return -1;
-}
-
-static int iplink_have_newlink(void)
-{
-	struct {
-		struct nlmsghdr		n;
-		struct ifinfomsg	i;
-		char			buf[1024];
-	} req;
-
-	if (have_rtnl_newlink < 0) {
-		memset(&req, 0, sizeof(req));
-
-		req.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct ifinfomsg));
-		req.n.nlmsg_flags = NLM_F_REQUEST|NLM_F_ACK;
-		req.n.nlmsg_type = RTM_NEWLINK;
-		req.i.ifi_family = AF_UNSPEC;
-
-		rtnl_send(&rth, (char *)&req.n, req.n.nlmsg_len);
-		rtnl_listen(&rth, accept_msg, NULL);
-	}
-	return have_rtnl_newlink;
-}
-#else /* IPLINK_IOCTL_COMPAT */
-static int iplink_have_newlink(void)
-{
-	return 1;
-}
-#endif /* ! IPLINK_IOCTL_COMPAT */
-
 struct iplink_req {
 	struct nlmsghdr		n;
 	struct ifinfomsg	i;

--------------000707090407050602080305--
