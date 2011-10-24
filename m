From: Andreas Hofmeister <andi@collax.com>
Subject: [PATCH] ipv6: Do not use routes from locally generated RAs
Date: Tue, 25 Oct 2011 01:09:36 +0200
Message-ID: <1319497776-23998-1-git-send-email-andi@collax.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.collax.com ([213.218.25.154]:54435 "EHLO mail.collax.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754513Ab1JXXJi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Oct 2011 19:09:38 -0400
Received: from localhost (mail.collax.com [127.0.0.1])
	by localhost (Postfix) with ESMTP id ADCB615F801F
	for <netdev@vger.kernel.org>; Tue, 25 Oct 2011 01:09:36 +0200 (CEST)
Received: from mail.collax.com ([127.0.0.1])
	by localhost (mail.collax.com [127.0.0.1]) (amavisd-new, port 10033)
	with ESMTP id vECmol15TCpk for <netdev@vger.kernel.org>;
	Tue, 25 Oct 2011 01:09:36 +0200 (CEST)
Received: from vmhost.coreworks.de (unknown [172.16.0.12])
	by mail.collax.com (Postfix) with ESMTP id 781FA15F801A
	for <netdev@vger.kernel.org>; Tue, 25 Oct 2011 01:09:36 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When hybrid mode is enabled (accept_ra == 2), the kernel also sees RAs
generated locally. This is useful since it allows the kernel to auto-configure
its own interface addresses.

However, if 'accept_ra_defrtr' and/or 'accept_ra_rtr_pref' are set and the
locally generated RAs announce the default route and/or other route information,
the kernel happily inserts bogus routes with its own address as gateway.

With this patch, adding routes from an RA will be skiped when the RAs source
address matches any local address, just as if 'accept_ra_defrtr' and
'accept_ra_rtr_pref' were set to 0.

Signed-off-by: Andreas Hofmeister <andi@collax.com>
---
 net/ipv6/ndisc.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 67501b6..00fa46e1 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1226,6 +1226,9 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 	if (!in6_dev->cnf.accept_ra_defrtr)
 		goto skip_defrtr;
 
+	if (ipv6_chk_addr(dev_net(in6_dev->dev), &ipv6_hdr(skb)->saddr, NULL, 0))
+		goto skip_defrtr;
+
 	lifetime = ntohs(ra_msg->icmph.icmp6_rt_lifetime);
 
 #ifdef CONFIG_IPV6_ROUTER_PREF
@@ -1350,6 +1353,9 @@ skip_linkparms:
 		goto out;
 
 #ifdef CONFIG_IPV6_ROUTE_INFO
+	if (ipv6_chk_addr(dev_net(in6_dev->dev), &ipv6_hdr(skb)->saddr, NULL, 0))
+		goto skip_routeinfo;
+
 	if (in6_dev->cnf.accept_ra_rtr_pref && ndopts.nd_opts_ri) {
 		struct nd_opt_hdr *p;
 		for (p = ndopts.nd_opts_ri;
@@ -1367,6 +1373,8 @@ skip_linkparms:
 				      &ipv6_hdr(skb)->saddr);
 		}
 	}
+
+skip_routeinfo:
 #endif
 
 #ifdef CONFIG_IPV6_NDISC_NODETYPE
-- 
1.7.6.1
