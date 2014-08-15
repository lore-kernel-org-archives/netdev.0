From: Gerhard Stenzel <gstenzel@linux.vnet.ibm.com>
Subject: [PATCH net] vxlan: fix incorrect initializer in union vxlan_addr
Date: Fri, 15 Aug 2014 11:03:58 +0200
Message-ID: <53EDCCFE.5090301@linux.vnet.ibm.com>
References: <53EDCC19.70702@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp14.uk.ibm.com ([195.75.94.110]:57615 "EHLO
	e06smtp14.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751162AbaHOJEC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Aug 2014 05:04:02 -0400
Received: from /spool/local
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <gstenzel@linux.vnet.ibm.com>;
	Fri, 15 Aug 2014 10:04:00 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id CB0AD2190045
	for <netdev@vger.kernel.org>; Fri, 15 Aug 2014 10:03:41 +0100 (BST)
Received: from d06av09.portsmouth.uk.ibm.com (d06av09.portsmouth.uk.ibm.com [9.149.37.250])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id s7F93wuS35913976
	for <netdev@vger.kernel.org>; Fri, 15 Aug 2014 09:03:58 GMT
Received: from d06av09.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av09.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s7F93wC7018413
	for <netdev@vger.kernel.org>; Fri, 15 Aug 2014 03:03:58 -0600
Received: from oc4745424800.ibm.com (dyn-9-152-214-79.boeblingen.de.ibm.com [9.152.214.79])
	by d06av09.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVin) with ESMTP id s7F93wH1018409
	for <netdev@vger.kernel.org>; Fri, 15 Aug 2014 03:03:58 -0600
In-Reply-To: <53EDCC19.70702@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The first initializer in the following

		union vxlan_addr ipa = {
			.sin.sin_addr.s_addr = tip,
			.sa.sa_family = AF_INET,
		};

is optimised away by the compiler, due to the second initializer,
therefore initialising .sin.sin_addr.s_addr always to 0.
This results in netlink messages indicating a L3 miss never contain the
missed IP address. This was observed with GCC 4.8 and 4.9. I do not know 
about previous versions.
The problem affects user space programs relying on an IP address being
sent as part of a netlink message indicating a L3 miss.

Changing
			.sa.sa_family = AF_INET,
to
			.sin.sin_family = AF_INET,
fixes the problem.

     Signed-off-by: Gerhard Stenzel <gerhard.stenzel@de.ibm.com>

---

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 1fb7b37..beb377b 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1327,7 +1327,7 @@ static int arp_reduce(struct net_device *dev,
struct sk_buff *skb)
  	} else if (vxlan->flags & VXLAN_F_L3MISS) {
  		union vxlan_addr ipa = {
  			.sin.sin_addr.s_addr = tip,
-			.sa.sa_family = AF_INET,
+			.sin.sin_family = AF_INET,
  		};

  		vxlan_ip_miss(dev, &ipa);
@@ -1488,7 +1488,7 @@ static int neigh_reduce(struct net_device *dev,
struct sk_buff *skb)
  	} else if (vxlan->flags & VXLAN_F_L3MISS) {
  		union vxlan_addr ipa = {
  			.sin6.sin6_addr = msg->target,
-			.sa.sa_family = AF_INET6,
+			.sin6.sin6_family = AF_INET6,
  		};

  		vxlan_ip_miss(dev, &ipa);
@@ -1521,7 +1521,7 @@ static bool route_shortcircuit(struct net_device
*dev, struct sk_buff *skb)
  		if (!n && (vxlan->flags & VXLAN_F_L3MISS)) {
  			union vxlan_addr ipa = {
  				.sin.sin_addr.s_addr = pip->daddr,
-				.sa.sa_family = AF_INET,
+				.sin.sin_family = AF_INET,
  			};

  			vxlan_ip_miss(dev, &ipa);
@@ -1542,7 +1542,7 @@ static bool route_shortcircuit(struct net_device
*dev, struct sk_buff *skb)
  		if (!n && (vxlan->flags & VXLAN_F_L3MISS)) {
  			union vxlan_addr ipa = {
  				.sin6.sin6_addr = pip6->daddr,
-				.sa.sa_family = AF_INET6,
+				.sin6.sin6_family = AF_INET6,
  			};

  			vxlan_ip_miss(dev, &ipa);
