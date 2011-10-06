From: Yinglin Sun <Yinglin.Sun@emc.com>
Subject: [PATCH] IPv6: DAD from bonding iface is treated as dup address from others
Date: Wed,  5 Oct 2011 20:59:10 -0700
Message-ID: <1317873550-1677-1-git-send-email-Yinglin.Sun@emc.com>
Cc: netdev@vger.kernel.org, Yinglin Sun <Yinglin.Sun@emc.com>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kabe
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:37742 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755887Ab1JFD7c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Oct 2011 23:59:32 -0400
Received: by pzk1 with SMTP id 1so5842972pzk.1
        for <netdev@vger.kernel.org>; Wed, 05 Oct 2011 20:59:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Steps to reproduce this issue:
1. create bond0 over eth0 and eth1, set the mode to balance-xor
2. add an IPv6 address to bond0
3. DAD packet is sent out from one slave and then is looped back from
the other slave. Therefore, it is treated as a duplicate address and
stays tentative afterwards:
   kern.info:
       Oct  5 11:50:18 testvm1 kernel: [  129.224353] bond0: IPv6 duplicate address 1234::1 detected!

Signed-off-by: Yinglin Sun <Yinglin.Sun@emc.com>
---
 net/ipv6/ndisc.c |   15 +++++++++++++--
 1 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 9da6e02..c82f4c7 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -809,9 +809,10 @@ static void ndisc_recv_ns(struct sk_buff *skb)
 
 		if (ifp->flags & (IFA_F_TENTATIVE|IFA_F_OPTIMISTIC)) {
 			if (dad) {
+				const unsigned char *sadr;
+				sadr = skb_mac_header(skb);
+
 				if (dev->type == ARPHRD_IEEE802_TR) {
-					const unsigned char *sadr;
-					sadr = skb_mac_header(skb);
 					if (((sadr[8] ^ dev->dev_addr[0]) & 0x7f) == 0 &&
 					    sadr[9] == dev->dev_addr[1] &&
 					    sadr[10] == dev->dev_addr[2] &&
@@ -821,6 +822,16 @@ static void ndisc_recv_ns(struct sk_buff *skb)
 						/* looped-back to us */
 						goto out;
 					}
+				} else if (dev->type == ARPHRD_ETHER) {
+					if (sadr[6] == dev->dev_addr[0] &&
+					    sadr[7] == dev->dev_addr[1] &&
+					    sadr[8] == dev->dev_addr[2] &&
+					    sadr[9] == dev->dev_addr[3] &&
+					    sadr[10] == dev->dev_addr[4] &&
+					    sadr[11] == dev->dev_addr[5]) {
+						/* looped-back to us */
+						goto out;
+					}
 				}
 
 				/*
-- 
1.7.4.1
