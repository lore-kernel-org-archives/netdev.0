From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 7058] New: CONFIG_IP_ROUTE_FWMARK breaks
 rp_filter checks
Date: Fri, 25 Aug 2006 13:54:59 -0700
Message-ID: <20060825135459.c383478a.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: gb@phonema.ea.univpm.it,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:44454 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932459AbWHYUzb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2006 16:55:31 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Fri, 25 Aug 2006 13:29:52 -0700
From: bugme-daemon@bugzilla.kernel.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 7058] New: CONFIG_IP_ROUTE_FWMARK breaks rp_filter checks


http://bugzilla.kernel.org/show_bug.cgi?id=7058

           Summary: CONFIG_IP_ROUTE_FWMARK breaks rp_filter checks
    Kernel Version: 2.6.17.8
            Status: NEW
          Severity: normal
             Owner: laforge@gnumonks.org
         Submitter: gb@phonema.ea.univpm.it


Most recent kernel where this bug did not occur: bug present since at least
early 2.4.x
Distribution: debian
Hardware Environment: i386
Software Environment: router/firewall
Problem Description:
Using a fwmark as a key for selecting among multiple routing tables (via "ip
rule" command) breaks the rp_filter functionality since the fwmark field is not
initialized in function fib_validate_source. Because of this there is no way to
assure that outgoing and incoming packets use the same routing table.

Steps to reproduce:
You should set up a network environment where there are at least two different
links from the machine A to a remote host B, and firewall rules on A to mark
specific packets to this destination and back (say those destined to a certain
port only and corresponding replies). Set a default route from A to B using link
1 and a different routing table for marked packets using link 2 (e.g. ip rule
add fwmark 2 table 2; ip route table 2 add ...). (This is the setup used for a
VPN I manage)
When an incoming packet from link 2 arrives in fib_validate_source, the fwmark
field will not be set despite the presence of appropriate rules in the firewall,
and thus the wrong table will be used for the check causing the packet to be
refused.

I have prepared a small patch to resolve this issue. I've tested it for quite
some time and it worked flawlessly and without side effects. I'm pasting it
here: it just adds an argument to fib_validate_source so that it can set the
fwmark field and passes the proper value already present in every caller.



--- a/include/net/ip_fib.h	2006-08-09 20:08:14.000000000 +0200
+++ b/include/net/ip_fib.h	2006-08-09 19:44:44.000000000 +0200
@@ -234,7 +234,7 @@
 extern int inet_rtm_newroute(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg);
 extern int inet_rtm_getroute(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg);
 extern int inet_dump_fib(struct sk_buff *skb, struct netlink_callback *cb);
-extern int fib_validate_source(u32 src, u32 dst, u8 tos, int oif,
+extern int fib_validate_source(u32 src, u32 dst, u8 tos, int oif, u32 fwmark,
 			       struct net_device *dev, u32 *spec_dst, u32 *itag);
 extern void fib_select_multipath(const struct flowi *flp, struct fib_result *res);
 
--- a/net/ipv4/fib_frontend.c	2006-08-07 06:18:54.000000000 +0200
+++ b/net/ipv4/fib_frontend.c	2006-08-09 19:43:45.000000000 +0200
@@ -160,14 +160,18 @@
    - check, that packet arrived from expected physical interface.
  */
 
-int fib_validate_source(u32 src, u32 dst, u8 tos, int oif,
+int fib_validate_source(u32 src, u32 dst, u8 tos, int oif, u32 fwmark,
 			struct net_device *dev, u32 *spec_dst, u32 *itag)
 {
 	struct in_device *in_dev;
 	struct flowi fl = { .nl_u = { .ip4_u =
 				      { .daddr = src,
 					.saddr = dst,
-					.tos = tos } },
+					.tos = tos,
+#ifdef CONFIG_IP_ROUTE_FWMARK
+					.fwmark = fwmark
+#endif
+				      } },
 			    .iif = oif };
 	struct fib_result res;
 	int no_addr, rpf;
--- a/net/ipv4/route.c	2006-08-09 20:08:47.000000000 +0200
+++ b/net/ipv4/route.c	2006-08-09 19:46:06.000000000 +0200
@@ -1606,6 +1606,11 @@
 			goto e_inval;
 		spec_dst = inet_select_addr(dev, 0, RT_SCOPE_LINK);
 	} else if (fib_validate_source(saddr, 0, tos, 0,
+#ifdef CONFIG_IP_ROUTE_FWMARK
+					skb->nfmark,
+#else
+					0, /* no fwmark dependant routing */
+#endif
 					dev, &spec_dst, &itag) < 0)
 		goto e_inval;
 
@@ -1720,6 +1725,11 @@
 
 
 	err = fib_validate_source(saddr, daddr, tos, FIB_RES_OIF(*res), 
+#ifdef CONFIG_IP_ROUTE_FWMARK
+				  skb->nfmark,
+#else
+				  0, /* no fwmark dependant routing */
+#endif
 				  in_dev->dev, &spec_dst, &itag);
 	if (err < 0) {
 		ip_handle_martian_source(in_dev->dev, in_dev, skb, daddr, 
@@ -1954,6 +1964,11 @@
 		int result;
 		result = fib_validate_source(saddr, daddr, tos,
 					     loopback_dev.ifindex,
+#ifdef CONFIG_IP_ROUTE_FWMARK
+					     skb->nfmark,
+#else
+					     0, /* no fwmark dependant routing */
+#endif
 					     dev, &spec_dst, &itag);
 		if (result < 0)
 			goto martian_source;
@@ -1987,8 +2002,13 @@
 	if (ZERONET(saddr))
 		spec_dst = inet_select_addr(dev, 0, RT_SCOPE_LINK);
 	else {
-		err = fib_validate_source(saddr, 0, tos, 0, dev, &spec_dst,
-					  &itag);
+		err = fib_validate_source(saddr, 0, tos, 0,
+#ifdef CONFIG_IP_ROUTE_FWMARK
+					  skb->nfmark,
+#else
+					  0, /* no fwmark dependant routing */
+#endif
+					  dev, &spec_dst, &itag);
 		if (err < 0)
 			goto martian_source;
 		if (err)

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
