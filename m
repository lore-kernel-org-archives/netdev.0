From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] NAT and requests to unrouted targets
Date: Thu, 15 Mar 2007 09:51:17 +0100
Message-ID: <45F90905.4000408@trash.net>
References: <000001c766d8$66f1cc00$1a04010a@V505CP>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Netfilter Development Mailinglist
	<netfilter-devel@lists.netfilter.org>
To: Martin Schiller <mschiller@tdt.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:57821 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752142AbXCOIv2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Mar 2007 04:51:28 -0400
In-Reply-To: <000001c766d8$66f1cc00$1a04010a@V505CP>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Martin Schiller wrote:
> This patch changes the behaivor of the iptables nat module to the style
> before release 2.6.16 so it is possible again to use the "ping -I <iface>
> <target>" command to send icmp requests to a target for which no route
> exists.

Please attach patches inline and send netfilter related patches to
netfilter-devel@lists.netfilter.org.

Quoted for reference:

diff -uNpr linux-2.6.19.org/net/ipv4/netfilter/ip_nat_standalone.c
linux-2.6.19/net/ipv4/netfilter/ip_nat_standalone.c
--- linux-2.6.19.org/net/ipv4/netfilter/ip_nat_standalone.c
2006-11-29 22:57:37.000000000 +0100
+++ linux-2.6.19/net/ipv4/netfilter/ip_nat_standalone.c 2007-03-15
08:25:11.000000000 +0100
@@ -191,11 +191,13 @@ ip_nat_in(unsigned int hooknum,
           int (*okfn)(struct sk_buff *))
 {
        unsigned int ret;
+       __be32 saddr = (*pskb)->nh.iph->saddr;
        __be32 daddr = (*pskb)->nh.iph->daddr;

        ret = ip_nat_fn(hooknum, pskb, in, out, okfn);
        if (ret != NF_DROP && ret != NF_STOLEN
-           && daddr != (*pskb)->nh.iph->daddr) {
+           && ((*pskb)->nh.iph->saddr != saddr
+               || (*pskb)->nh.iph->daddr != daddr)) {
                dst_release((*pskb)->dst);
                (*pskb)->dst = NULL;
        }

I don't see how this would change anything, the PRE_ROUTING hook
doesn't change the source address, so the comparison is unnecessary,
additionally the dst_release is only needed for loopback because
packets received from a real interface don't have a route attached
at this time.

