From: "Meng, Jilin" <Jilin.Meng@emc.com>
Subject: [PATCH] net: Fix tentative IPv6 address due to DAD looping back
Date: Thu, 11 Apr 2013 03:06:23 +0000
Message-ID: <027526AF93736D4380632CD4F3B42B8002FE9D@MX101CL02.corp.emc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Sun, Yinglin" <yinglin.sun@emc.com>,
	"Prithviraj, Lakshmanan" <lakshmanan.prithviraj@emc.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Meng, Jilin" <Jilin.Meng@emc.com>
To: "davem@davemloft.net" <davem@davemloft.net>,
	"kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
	"jmorris@namei.org" <jmorris@namei.org>,
	"yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>,
	"kaber@trash.net" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hop-nat-141.emc.com ([168.159.213.141]:26712 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932929Ab3DKDIZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Apr 2013 23:08:25 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

we should ignore the looped-back IPv6 DAD packet to avoid configuration failure.
This occurs when a bonding interface with roundrobin mode is being configured an IPv6 address while the switch side isn't configured bonding/channel yet.

Signed-off-by: Jilin Meng <jilin.meng@emc.com>
Signed-off-by: Yinglin Sun <yinglin.sun@emc.com>
Signed-off-by: Lakshmanan Prithviraj <lakshmanan.prithviraj@emc.com>
---
--- linux/net/ipv6/ndisc.c.orig	2013-03-12 17:16:18.000000000 +0800
+++ linux/net/ipv6/ndisc.c	2013-04-11 09:00:45.000000000 +0800
@@ -71,6 +71,7 @@
 
 #include <linux/netfilter.h>
 #include <linux/netfilter_ipv6.h>
+#include <linux/etherdevice.h>
 
 /* Set to 3 to get tracing... */
 #define ND_DEBUG 1
@@ -757,6 +758,19 @@ static void ndisc_recv_ns(struct sk_buff
 
 		if (ifp->flags & (IFA_F_TENTATIVE|IFA_F_OPTIMISTIC)) {
 			if (dad) {
+				if (dev->type == ARPHRD_ETHER) {
+					const unsigned char *sadr;
+					sadr = skb_mac_header(skb);
+					if (ether_addr_equal_64bits(sadr + 6, dev->dev_addr))
+					/*
+					 * looped-back to us. This occurs when
+					 * a bonding interface with roundrobin
+					 * mode is being configured while the
+					 * switch side isn't configured yet.
+					 */
+						goto out;
+				}
+
 				/*
 				 * We are colliding with another node
 				 * who is doing DAD
