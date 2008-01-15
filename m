From: "Templin, Fred L" <Fred.L.Templin@boeing.com>
Subject: [PATCH 02/03] ISATAP V2 (ndisc.c; route.c changes)
Date: Tue, 15 Jan 2008 11:59:06 -0800
Message-ID: <39C363776A4E8C4A94691D2BD9D1C9A1029EDDAD@XCH-NW-7V2.nw.nos.boeing.com>
References: <39C363776A4E8C4A94691D2BD9D1C9A1029EDC29@XCH-NW-7V2.nw.nos.boeing.com><39C363776A4E8C4A94691D2BD9D1C9A1029EDC45@XCH-NW-7V2.nw.nos.boeing.com><20071129102940.GC22537@gondor.apana.org.au> <20071129.195459.55971471.yoshfuji@linux-ipv6.org> <39C363776A4E8C4A94691D2BD9D1C9A1029EDDAC@XCH-NW-7V2.nw.nos.boeing.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Cc: =?ISO-2022-JP?B?WU9TSElGVUpJIEhpZGVha2kgLyAbJEI1SEYjMVFMQBsoQg==?=
	<yoshfuji@linux-ipv6.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from slb-smtpout-01.boeing.com ([130.76.64.48]:63049 "EHLO
	slb-smtpout-01.boeing.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751460AbYAOUci (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2008 15:32:38 -0500
Content-class: urn:content-classes:message
In-Reply-To: <39C363776A4E8C4A94691D2BD9D1C9A1029EDDAC@XCH-NW-7V2.nw.nos.boeing.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch updates the Linux the Intra-Site Automatic Tunnel Addressing
Protocol (ISATAP) implementation. It places the ISATAP potential router
list (PRL) in the kernel and adds three new private ioctls for PRL
management. The diffs are specific to the netdev net-2.6.25 development
tree taken by "git pull" on 1/14/08.

Signed-off-by: Fred L. Templin <fred.l.templin@boeing.com>

--- net-2.6.25/net/ipv6/ndisc.c.orig	2008-01-14 15:35:55.000000000 -0800
+++ net-2.6.25/net/ipv6/ndisc.c	2008-01-15 09:02:23.000000000 -0800
@@ -1090,6 +1090,12 @@ static void ndisc_router_discovery(struc
 		return;
 	}
 
+	if (skb->rtr_type == RTRTYPE_HOST) {
+		ND_PRINTK2(KERN_WARNING
+			   "ICMPv6 RA: from host or unauthorized router\n");
+		return;
+	}
+
 	/*
 	 *	set the RA_RECV flag in the interface
 	 */
@@ -1113,6 +1119,10 @@ static void ndisc_router_discovery(struc
 		return;
 	}
 
+	/* skip link-specific parameters from interior routers */
+	if (skb->rtr_type == RTRTYPE_INTERIOR)
+		goto skip_linkparms;
+
 	if (in6_dev->if_flags & IF_RS_SENT) {
 		/*
 		 *	flag that an RA was received after an RS was sent
@@ -1227,6 +1237,8 @@ skip_defrtr:
 		}
 	}
 
+skip_linkparms:
+
 	/*
 	 *	Process options.
 	 */
@@ -1266,6 +1278,10 @@ skip_defrtr:
 	}
 #endif
 
+	/* skip link-specific ndopts from interior routers */
+	if (skb->rtr_type == RTRTYPE_INTERIOR)
+		goto out;
+
 	if (in6_dev->cnf.accept_ra_pinfo && ndopts.nd_opts_pi) {
 		struct nd_opt_hdr *p;
 		for (p = ndopts.nd_opts_pi;
@@ -1329,6 +1345,14 @@ static void ndisc_redirect_rcv(struct sk
 	int optlen;
 	u8 *lladdr = NULL;
 
+	switch (skb->rtr_type) {
+	case RTRTYPE_HOST:
+	case RTRTYPE_INTERIOR:
+		ND_PRINTK2(KERN_WARNING
+			   "ICMPv6 Redirect: from host or unauthorized router\n");
+		return;
+	}
+
 	if (!(ipv6_addr_type(&ipv6_hdr(skb)->saddr) & IPV6_ADDR_LINKLOCAL)) {
 		ND_PRINTK2(KERN_WARNING
 			   "ICMPv6 Redirect: source address is not link-local.\n");
--- net-2.6.25/net/ipv6/route.c.orig	2008-01-14 15:39:40.000000000 -0800
+++ net-2.6.25/net/ipv6/route.c	2008-01-14 15:39:55.000000000 -0800
@@ -1655,8 +1655,6 @@ struct rt6_info *rt6_get_dflt_router(str
 	return rt;
 }
 
-EXPORT_SYMBOL(rt6_get_dflt_router);
-
 struct rt6_info *rt6_add_dflt_router(struct in6_addr *gwaddr,
 				     struct net_device *dev,
 				     unsigned int pref)
