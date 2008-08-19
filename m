From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFC] ipv6: protocol for address routes
Date: Tue, 19 Aug 2008 08:54:41 -0700
Message-ID: <20080819085441.7b0184d1@speedy>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:41741 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752713AbYHSPym (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Aug 2008 11:54:42 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by mail.vyatta.com (Postfix) with ESMTP id 505454F4632
	for <netdev@vger.kernel.org>; Tue, 19 Aug 2008 08:54:42 -0700 (PDT)
Received: from mail.vyatta.com ([127.0.0.1])
	by localhost (mail.vyatta.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id HKGFKMs9DTh2 for <netdev@vger.kernel.org>;
	Tue, 19 Aug 2008 08:54:42 -0700 (PDT)
Received: from speedy (unknown [10.3.0.149])
	by mail.vyatta.com (Postfix) with ESMTP id 156AD4F4631
	for <netdev@vger.kernel.org>; Tue, 19 Aug 2008 08:54:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes a problem spotted with zebra, but not sure if it is necessary a kernel problem.
With IPV6 when an address is added to an interface, Zebra creates a duplicate RIB
entry, one as a connected route, and other as a kernel route.

When an address is added to an interface the RTN_NEWADDR message causes Zebra
to create a connected route. In IPV4 when an address is added to an interface a RTN_NEWROUTE
message is set to user space with the protocol RTPROT_KERNEL. Zebra ignores these messages,
because it already has the connected route.

The problem is that route created in IPV6 has route protocol == RTPROT_BOOT.
Was this a design decision or a bug? This fixes it. Same patch applies to both
net-2.6 and stable.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/ipv6/addrconf.c	2008-08-18 21:58:51.000000000 -0700
+++ b/net/ipv6/addrconf.c	2008-08-18 22:00:26.000000000 -0700
@@ -1688,6 +1688,7 @@ addrconf_prefix_route(struct in6_addr *p
 		.fc_dst_len = plen,
 		.fc_flags = RTF_UP | flags,
 		.fc_nlinfo.nl_net = dev_net(dev),
+		.fc_protocol = RTPROT_KERNEL,
 	};
 
 	ipv6_addr_copy(&cfg.fc_dst, pfx);
