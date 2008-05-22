From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Fwd: [Bug 447812] New: Netlink messages from "tc"  to sch_netem module are not interpreted correctly
Date: Thu, 22 May 2008 02:21:55 +0200
Message-ID: <20080522002155.GP20815@postel.suug.ch>
References: <20080521214523.GB22591@codemonkey.org.uk> <20080521151021.3d47a3d8@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dave Jones <davej@codemonkey.org.uk>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:49694 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S937648AbYEVAVe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 May 2008 20:21:34 -0400
Content-Disposition: inline
In-Reply-To: <20080521151021.3d47a3d8@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Stephen Hemminger <shemminger@vyatta.com> 2008-05-21 15:10
> /sbin/tc qdisc del dev eth1 root
> /sbin/tc qdisc del dev eth1 ingress
> /sbin/tc qdisc add dev eth1 root handle 1: prio bands 5 priomap 4 4 4 4 
> 4 4 4 4 4 4 4 4 4 4 4 4
> /sbin/tc qdisc add dev eth1 parent 1:1 handle 10: netem
> /sbin/tc qdisc add dev eth1 parent 10:1 handle 100: tbf rate 2147483647 
> burst 1600 latency 2000000 mpu 64
> /sbin/tc qdisc change dev eth1 parent 1:1 handle 10: netem delay 50ms 
> 5ms 10% corrupt 8%
> 
> It also generates the warning if the last line of the above is simply:
> 
> /sbin/tc qdisc change dev eth1 parent 1:1 handle 10: netem delay 50ms 
> 5ms 10%
> 
> But not if that last line is (i.e. with the correlation part dropped.)
> 
> /sbin/tc qdisc change dev eth1 parent 1:1 handle 10: netem delay 50ms 5ms
> 
> So, all in all, it seems to me that a bug has crept into the kernel 
> interpretation of the netem netlink messages.

Could you try this patch?

Index: net-2.6/include/net/netlink.h
===================================================================
--- net-2.6.orig/include/net/netlink.h	2008-05-22 02:12:48.000000000 +0200
+++ net-2.6/include/net/netlink.h	2008-05-22 02:15:25.000000000 +0200
@@ -772,12 +772,13 @@
 					    const struct nla_policy *policy,
 					    int len)
 {
-	if (nla_len(nla) < len)
+	int nested_len = nla_len(nla) - NLA_ALIGN(len);
+
+	if (nested_len < 0)
 		return -1;
-	if (nla_len(nla) >= NLA_ALIGN(len) + sizeof(struct nlattr))
-		return nla_parse_nested(tb, maxtype,
-					nla_data(nla) + NLA_ALIGN(len),
-					policy);
+	if (nested_len >= nla_attr_size(0))
+		return nla_parse(tb, maxtype, nla_data(nla) + NLA_ALIGN(len),
+				 nested_len, policy);
 	memset(tb, 0, sizeof(struct nlattr *) * (maxtype + 1));
 	return 0;
 }
