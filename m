From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: [PATCH] IPV6: DAD has to be destined to solicited node mulitcast
 address
Date: Thu, 26 Jun 2003 04:01:50 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030626.040150.28947784.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

Check if DAD is destined for solicited node multicast address
as RFC2461 required.

Thanks in advance.

Index: linux-2.5/net/ipv6/ndisc.c
===================================================================
RCS file: /home/cvs/linux-2.5/net/ipv6/ndisc.c,v
retrieving revision 1.40
diff -u -r1.40 ndisc.c
--- linux-2.5/net/ipv6/ndisc.c	21 Jun 2003 16:21:01 -0000	1.40
+++ linux-2.5/net/ipv6/ndisc.c	25 Jun 2003 17:45:08 -0000
@@ -713,6 +713,7 @@
 	struct net_device *dev = skb->dev;
 	struct inet6_ifaddr *ifp;
 	struct neighbour *neigh;
+	int addr_type = ipv6_addr_type(saddr);
 
 	if (ipv6_addr_type(&msg->target)&IPV6_ADDR_MULTICAST) {
 		if (net_ratelimit())
@@ -720,6 +721,20 @@
 		return;
 	}
 
+	/*
+	 * RFC2461 7.1.1:
+	 * DAD has to be destined for solicited node multicast address.
+	 */
+	if (addr_type == IPV6_ADDR_ANY &&
+	    !(daddr->s6_addr32[0] == htonl(0xff020000) &&
+	      daddr->s6_addr32[1] == htonl(0x00000000) &&
+	      daddr->s6_addr32[2] == htonl(0x00000001) &&
+	      daddr->s6_addr [12] == 0xff )) {
+		if (net_ratelimit())
+			printk(KERN_DEBUG "ICMP6 NS: bad DAD packet (wrong destination\n");
+		return;
+	}
+
 	if (!ndisc_parse_options(msg->opt, ndoptlen, &ndopts)) {
 		if (net_ratelimit())
 			printk(KERN_WARNING "ICMP NS: invalid ND option, ignored.\n");
@@ -743,14 +758,7 @@
 	 *	NOTE! Linux kernel < 2.4.4 broke this rule.
 	 */
 		 	
-	/* XXX: RFC2461 7.1.1:
-	 *	If the IP source address is the unspecified address, the IP
-      	 *	destination address MUST be a solicited-node multicast address.
-	 */
-
 	if ((ifp = ipv6_get_ifaddr(&msg->target, dev)) != NULL) {
-		int addr_type = ipv6_addr_type(saddr);
-
 		if (ifp->flags & IFA_F_TENTATIVE) {
 			/* Address is tentative. If the source
 			   is unspecified address, it is someone
@@ -816,7 +824,6 @@
 		in6_ifa_put(ifp);
 	} else if (ipv6_chk_acast_addr(dev, &msg->target)) {
 		struct inet6_dev *idev = in6_dev_get(dev);
-		int addr_type = ipv6_addr_type(saddr);
 	
 		/* anycast */
 	

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
