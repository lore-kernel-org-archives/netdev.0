From: Gerhard Stenzel <gstenzel@linux.vnet.ibm.com>
Subject: Re: [PATCH net] vxlan: fix incorrect initializer in union vxlan_addr
Date: Tue, 19 Aug 2014 22:36:43 +0200
Message-ID: <53F3B55B.6070505@linux.vnet.ibm.com>
References: <53EDCC19.70702@linux.vnet.ibm.com> <53EDCCFE.5090301@linux.vnet.ibm.com> <20140818.101143.2274310300741627370.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp16.uk.ibm.com ([195.75.94.112]:32807 "EHLO
	e06smtp16.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750916AbaHSUgs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2014 16:36:48 -0400
Received: from /spool/local
	by e06smtp16.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <gstenzel@linux.vnet.ibm.com>;
	Tue, 19 Aug 2014 21:36:47 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (d06relay13.portsmouth.uk.ibm.com [9.149.109.198])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 28C6E17D8045
	for <netdev@vger.kernel.org>; Tue, 19 Aug 2014 21:38:36 +0100 (BST)
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id s7JKaiLd35651608
	for <netdev@vger.kernel.org>; Tue, 19 Aug 2014 20:36:44 GMT
Received: from d06av04.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s7JKahfI004628
	for <netdev@vger.kernel.org>; Tue, 19 Aug 2014 14:36:44 -0600
In-Reply-To: <20140818.101143.2274310300741627370.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Trying again ... 

On 08/18/2014 07:11 PM, David Miller wrote:
...
> 
> Your patch was corrupted by your email client, also please do not
> indent your signoff.
> 
> THanks.
> 


The first initializer in the following

        union vxlan_addr ipa = {
            .sin.sin_addr.s_addr = tip,
            .sa.sa_family = AF_INET,
        };

is optimised away by the compiler, due to the second initializer,
therefore initialising .sin.sin_addr.s_addr always to 0.
This results in netlink messages indicating a L3 miss never contain the
missed IP address. This was observed with GCC 4.8 and 4.9. I do not know about previous versions.
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
@@ -1327,7 +1327,7 @@ static int arp_reduce(struct net_device *dev, struct sk_buff *skb)
 	} else if (vxlan->flags & VXLAN_F_L3MISS) {
 		union vxlan_addr ipa = {
 			.sin.sin_addr.s_addr = tip,
-			.sa.sa_family = AF_INET,
+			.sin.sin_family = AF_INET,
 		};
 
 		vxlan_ip_miss(dev, &ipa);
@@ -1488,7 +1488,7 @@ static int neigh_reduce(struct net_device *dev, struct sk_buff *skb)
 	} else if (vxlan->flags & VXLAN_F_L3MISS) {
 		union vxlan_addr ipa = {
 			.sin6.sin6_addr = msg->target,
-			.sa.sa_family = AF_INET6,
+			.sin6.sin6_family = AF_INET6,
 		};
 
 		vxlan_ip_miss(dev, &ipa);
@@ -1521,7 +1521,7 @@ static bool route_shortcircuit(struct net_device *dev, struct sk_buff *skb)
 		if (!n && (vxlan->flags & VXLAN_F_L3MISS)) {
 			union vxlan_addr ipa = {
 				.sin.sin_addr.s_addr = pip->daddr,
-				.sa.sa_family = AF_INET,
+				.sin.sin_family = AF_INET,
 			};
 
 			vxlan_ip_miss(dev, &ipa);
@@ -1542,7 +1542,7 @@ static bool route_shortcircuit(struct net_device *dev, struct sk_buff *skb)
 		if (!n && (vxlan->flags & VXLAN_F_L3MISS)) {
 			union vxlan_addr ipa = {
 				.sin6.sin6_addr = pip6->daddr,
-				.sa.sa_family = AF_INET6,
+				.sin6.sin6_family = AF_INET6,
 			};
 
 			vxlan_ip_miss(dev, &ipa);
