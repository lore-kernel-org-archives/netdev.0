From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 16517] New: rp_filter fails to filter with
 CONFIG_IP_ROUTE_MULTIPATH and more than one 0/0 nexthop dev
Date: Mon, 06 Sep 2010 22:35:07 -0700 (PDT)
Message-ID: <20100906.223507.149819455.davem@davemloft.net>
References: <bug-16517-10286@https.bugzilla.kernel.org/>
	<20100805134653.9e8985cc.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter@vger.kernel.org, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	for.poige+bugzilla.kernel.org@gmail.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40468
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751320Ab0IGFeu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Sep 2010 01:34:50 -0400
In-Reply-To: <20100805134653.9e8985cc.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Thu, 5 Aug 2010 13:46:53 -0700

>> I think the problem is net/ipv4/fib_frontend.c fib_validate_source()
>> 
>> ...
>> #ifdef CONFIG_IP_ROUTE_MULTIPATH
>>     if (FIB_RES_DEV(res) == dev || res.fi->fib_nhs > 1)
>> #else
>>     if (FIB_RES_DEV(res) == dev)
>> #endif
>> ...
>> 
>> I'm not sure, but this code is quite trivial and self-speaking. In case we have
>> several default routes, we'd better iterate over each of them and compare
>> resulting devices with the input one. So, fix is also trivial, specially for
>> network kernel developers. ;-)

Please test this patch:

ipv4: Fix reverse path filtering with multipath routing.

Actually iterate over the next-hops to make sure we have
a device match.  Otherwise RP filtering is always elided
when the route matched has multiple next-hops.

Reported-by: Igor M Podlesny <for.poige@gmail.com>
Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index a439689..7d02a9f 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -246,6 +246,7 @@ int fib_validate_source(__be32 src, __be32 dst, u8 tos, int oif,
 
 	struct fib_result res;
 	int no_addr, rpf, accept_local;
+	bool dev_match;
 	int ret;
 	struct net *net;
 
@@ -273,12 +274,22 @@ int fib_validate_source(__be32 src, __be32 dst, u8 tos, int oif,
 	}
 	*spec_dst = FIB_RES_PREFSRC(res);
 	fib_combine_itag(itag, &res);
+	dev_match = false;
+
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
-	if (FIB_RES_DEV(res) == dev || res.fi->fib_nhs > 1)
+	for (ret = 0; ret < res.fi->fib_nhs; ret++) {
+		struct fib_nh *nh = &res.fi->fib_nh[ret];
+
+		if (nh->nh_dev == dev) {
+			dev_match = true;
+			break;
+		}
+	}
 #else
 	if (FIB_RES_DEV(res) == dev)
+		dev_match = true;
 #endif
-	{
+	if (dev_match) {
 		ret = FIB_RES_NH(res).nh_scope >= RT_SCOPE_HOST;
 		fib_res_put(&res);
 		return ret;
