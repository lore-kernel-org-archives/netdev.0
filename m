From: Bas Bloemsaat <bloemsaa@xs4all.nl>
Subject: [2.4 PATCH] bugfix: ARP respond on all devices
Date: Sun, 27 Jul 2003 22:52:48 +0200 (CEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.53.0307272239570.2743@vialle.bloemsaat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: layes@loran.com, torvalds@osdl.org, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: marcelo@conectiva.com.br, netdev@oss.sgi.com, linux-net@vger.kernel.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Yesterday (20030726) I found out, that with two NICs on one ethernet
segment, ARPing for one IP address gave me two answers, one from each NIC
with the MAC address from each of them. They each have a seperate IP
address. First I thought the NICs where doing proxy arp on each other,
but it turned out that this wasn't the case. On closer examination it
turned out that any ARP request to a local IP resulted in a response,
even if the devices were on different subnets or ethernet segments.

I learned from the kernel sources that any NIC receiving an ARP request
for any local IP adress would respond to that request. Among others, that
has the following implications:
- when you have two NICs same ethernet segment, only one of them is used:
they both respond to any ARP request. As only the first response is ever
used (fasted router), only the NIC that responds first receives any
traffic. This NIC may or may not be bound to the destination IP. It may
not even be reachable because of iptables-rules. This also defeats a
common form of load balancing.
- when you have two NICs on seperate ethernet segments, for example on a
firewall, it is possible to probe one NIC for the IP address of the other.
This can be used to gain information about the inside network of the
firewall, which is a (minor) security risk. While this is not really
practical because every IP address has to be tried, often the inside is of
a limit range (10.x.x.x, 192.168.x.x), which makes it useful.

I think this is unwanted behaviour. This patch corrects the situation. It
makes every device only respond to ARP requests for IP addresses bound to
that device, not all local IP addresses. Proxy ARP still applies as
before.

The patch was made from 2.4.21. It patches 2.4.22-pre8 cleanly and tests
okay on both. Please apply.


diff -urN linux-2.4.21.orig/include/linux/inetdevice.h linux-2.4.21-okayclean/include/linux/inetdevice.h
--- linux-2.4.21.orig/include/linux/inetdevice.h	2002-08-03 02:39:45.000000000 +0200
+++ linux-2.4.21-okayclean/include/linux/inetdevice.h	2003-07-27 18:51:28.000000000 +0200
@@ -86,6 +86,7 @@
 extern u32		inet_select_addr(const struct net_device *dev, u32 dst, int scope);
 extern struct in_ifaddr *inet_ifa_byprefix(struct in_device *in_dev, u32 prefix, u32 mask);
 extern void		inet_forward_change(void);
+extern int 		inet_addr_local_dev(struct in_device *in_dev, u32 addr);

 static __inline__ int inet_ifa_match(u32 addr, struct in_ifaddr *ifa)
 {
diff -urN linux-2.4.21.orig/net/ipv4/arp.c linux-2.4.21-okayclean/net/ipv4/arp.c
--- linux-2.4.21.orig/net/ipv4/arp.c	2002-11-29 00:53:15.000000000 +0100
+++ linux-2.4.21-okayclean/net/ipv4/arp.c	2003-07-27 21:12:17.000000000 +0200
@@ -66,6 +66,7 @@
  *		Alexey Kuznetsov:	new arp state machine;
  *					now it is in net/core/neighbour.c.
  *		Krzysztof Halasa:	Added Frame Relay ARP support.
+ *		Bas Bloemsaat	:	(20030727) Fixed respond on all devices bug
  */

 #include <linux/types.h>
@@ -766,7 +767,9 @@
 		rt = (struct rtable*)skb->dst;
 		addr_type = rt->rt_type;

-		if (addr_type == RTN_LOCAL) {
+
+		/* check if arp is for this device */
+		if (inet_addr_local_dev(in_dev,tip)) {
 			n = neigh_event_ns(&arp_tbl, sha, &sip, dev);
 			if (n) {
 				int dont_send = 0;
@@ -778,6 +781,8 @@
 				neigh_release(n);
 			}
 			goto out;
+
+		/* check if we can and have to proxy it */
 		} else if (IN_DEV_FORWARD(in_dev)) {
 			if ((rt->rt_flags&RTCF_DNAT) ||
 			    (addr_type == RTN_UNICAST  && rt->u.dst.dev != dev &&
diff -urN linux-2.4.21.orig/net/ipv4/devinet.c linux-2.4.21-okayclean/net/ipv4/devinet.c
--- linux-2.4.21.orig/net/ipv4/devinet.c	2003-06-13 16:51:39.000000000 +0200
+++ linux-2.4.21-okayclean/net/ipv4/devinet.c	2003-07-27 18:50:19.000000000 +0200
@@ -199,6 +199,17 @@
 	return 0;
 }

+int
+inet_addr_local_dev(struct in_device *in_dev, u32 addr)
+{
+	for_ifa(in_dev) {
+		if (!(addr^ifa->ifa_address))
+			return -1;
+	} endfor_ifa(in_dev);
+
+	return 0;
+}
+
 static void
 inet_del_ifa(struct in_device *in_dev, struct in_ifaddr **ifap, int destroy)
 {
