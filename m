From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [IPV6] ADDRCONF: Defer dad for global address until dad for
 linklocal is completed.
Date: Thu, 22 May 2008 01:58:07 +0900 (JST)
Message-ID: <20080522.015807.02348209.yoshfuji@linux-ipv6.org>
References: <48324792.5070309@miraclelinux.com>
	<20080520.173353.128167700.yoshfuji@linux-ipv6.org>
	<4832C3CC.5070609@miraclelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tabe@miraclelinux.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:43905 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756560AbYEUQ5o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2008 12:57:44 -0400
In-Reply-To: <4832C3CC.5070609@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <4832C3CC.5070609@miraclelinux.com> (at Tue, 20 May 2008 21:27:56 +0900), Toyo Abe <tabe@miraclelinux.com> says:

> I was also thinking so. And I tried it at first.
> But then, many other test scenarios in TAHI test suite went to FAIL. It
> was because
> the tester node send RA with prefix option to the host right after it
> receives DAD NS
> from the host, which is obviously in autoconfiguration process for
> linklocal address.

If so, we should complain about the spec / tests.

> Since current addrconf code actually accepts RA including prefix option 
> while DAD for
> linklocal address is processing, changes of the behaviour looks like a 
> degradation for me.
> Hence, I chose to accept RA at that moment and defer sending DAD NS for 
> global addresses.

Well I don't think so.
We should choose simpler way - avoid introducing new "unique" state so far.

If you really think is worth accepting RA during DAD for link-local
address, we should cancel all of on-going DADs for global address(es)
if the RA for link-local address has failed, intead of deferring DAD
for global address(es).

---
[RFC PATCH] [IPV6] ADDRCONF: Do not generate "global" address unless valid link-local address is available.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index e591e09..df99c5e 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1813,8 +1813,14 @@ void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len)
 
 		if (pinfo->prefix_len == 64) {
 			memcpy(&addr, &pinfo->prefix, 8);
-			if (ipv6_generate_eui64(addr.s6_addr + 8, dev) &&
-			    ipv6_inherit_eui64(addr.s6_addr + 8, in6_dev)) {
+			if (ipv6_inherit_eui64(addr.s6_addr + 8, in6_dev)) {
+				/*
+				 * If a valid link-local address is not found,
+				 * let's ignore autonomous flag.
+				 */
+				if (net_ratelimit())
+					printk(KERN_DEBUG "IPv6 addrconf: valid link-local address not found on %s\n",
+					       in6_dev->dev->name);
 				in6_dev_put(in6_dev);
 				return;
 			}

--yoshfuji
