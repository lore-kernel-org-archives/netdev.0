From: Marius Tomaschewski <mt@suse.de>
Subject: [PATCH] ipv6: send NEWLINK on RA managed/otherconf changes
Date: Mon, 31 Aug 2015 15:59:22 +0200
Message-ID: <20150831135922.GA24179@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Marius Tomaschewski <mt@suse.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:54048 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752714AbbHaN73 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Aug 2015 09:59:29 -0400
Received: from relay2.suse.de (charybdis-ext.suse.de [195.135.220.254])
	by mx2.suse.de (Postfix) with ESMTP id 1FD48ABC6
	for <netdev@vger.kernel.org>; Mon, 31 Aug 2015 13:59:28 +0000 (UTC)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The kernel is applying the RA managed/otherconf flags silently and
forgets to send ifinfo notify to inform about their change when the
router provides a zero reachable_time and retrans_timer as dnsmasq
and many routers send it, which just means unspecified by this router
and the host should continue using whatever value it is already using.
Userspace may monitor the ifinfo notifications to activate dhcpv6.

Signed-off-by: Marius Tomaschewski <mt@suse.de>

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index c53331c..99ea9dd 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1074,6 +1074,7 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 	struct ndisc_options ndopts;
 	int optlen;
 	unsigned int pref = 0;
+	__u32 old_if_flags;
 
 	__u8 *opt = (__u8 *)(ra_msg + 1);
 
@@ -1144,6 +1145,7 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 	 * Remember the managed/otherconf flags from most recently
 	 * received RA message (RFC 2462) -- yoshfuji
 	 */
+	old_if_flags = in6_dev->if_flags;
 	in6_dev->if_flags = (in6_dev->if_flags & ~(IF_RA_MANAGED |
 				IF_RA_OTHERCONF)) |
 				(ra_msg->icmph.icmp6_addrconf_managed ?
@@ -1151,6 +1153,9 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 				(ra_msg->icmph.icmp6_addrconf_other ?
 					IF_RA_OTHERCONF : 0);
 
+	if (old_if_flags != in6_dev->if_flags)
+		inet6_ifinfo_notify(RTM_NEWLINK, in6_dev);
+
 	if (!in6_dev->cnf.accept_ra_defrtr) {
 		ND_PRINTK(2, info,
 			  "RA: %s, defrtr is false for dev: %s\n",
-- 
2.1.4
