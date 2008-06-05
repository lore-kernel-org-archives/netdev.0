From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] ipv6 addrconf: Fix memory leak when deleting addresses
Date: Thu, 05 Jun 2008 11:26:46 +0900 (JST)
Message-ID: <20080605.112646.51075203.yoshfuji@linux-ipv6.org>
References: <20080604234934.GI20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:58128 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753176AbYFEC0I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2008 22:26:08 -0400
In-Reply-To: <20080604234934.GI20815@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <20080604234934.GI20815@postel.suug.ch> (at Thu, 5 Jun 2008 01:49:34 +0200), Thomas Graf <tgraf@suug.ch> says:

> ip6_del_rt() may fail in which case the dst/route is not released.

If prefix is ::/64 and ...

The only case ip6_del_rt() does not call dst_release() is when rt is
ip6_null_entry.  In that case we should skip whole the logic in the
caller, anyway.

Note: it might be better to release refcnt when ip6_del_rt() returns.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

-- 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 3a83557..d8ce0d7 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -772,7 +772,7 @@ static void ipv6_del_addr(struct inet6_ifaddr *ifp)
 		ipv6_addr_prefix(&prefix, &ifp->addr, ifp->prefix_len);
 		rt = rt6_lookup(net, &prefix, NULL, ifp->idev->dev->ifindex, 1);
 
-		if (rt && ((rt->rt6i_flags & (RTF_GATEWAY | RTF_DEFAULT)) == 0)) {
+		if (rt && ((rt->rt6i_flags & (RTF_REJECT | RTF_GATEWAY | RTF_DEFAULT)) == 0)) {
 			if (onlink == 0) {
 				ip6_del_rt(rt);
 				rt = NULL;
@@ -1789,7 +1789,7 @@ void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len)
 		rt = rt6_lookup(dev_net(dev), &pinfo->prefix, NULL,
 				dev->ifindex, 1);
 
-		if (rt && ((rt->rt6i_flags & (RTF_GATEWAY | RTF_DEFAULT)) == 0)) {
+		if (rt && ((rt->rt6i_flags & (RTF_REJECT | RTF_GATEWAY | RTF_DEFAULT)) == 0)) {
 			/* Autoconf prefix route */
 			if (valid_lft == 0) {
 				ip6_del_rt(rt);

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
