From: Thomas Graf <tgraf@infradead.org>
Subject: [PATCH net-2.6] ipv6: Expose reachable and retrans timer values as
 msecs
Date: Wed, 17 Nov 2010 09:12:02 -0500
Message-ID: <20101117141202.GA17546@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from canuck.infradead.org ([134.117.69.58]:58439 "EHLO
	canuck.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932380Ab0KQOME (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Nov 2010 09:12:04 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Expose reachable and retrans timer values in msecs instead of jiffies.
Both timer values are already exposed as msecs in the neighbour table
netlink interface.

The creation timestamp format with increased precision is kept but
cleaned up.

Signed-off-by: Thomas Graf <tgraf@infradead.org>
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Index: net-2.6/net/ipv6/addrconf.c
===================================================================
--- net-2.6.orig/net/ipv6/addrconf.c
+++ net-2.6/net/ipv6/addrconf.c
@@ -98,7 +98,11 @@
 #endif
 
 #define	INFINITY_LIFE_TIME	0xFFFFFFFF
-#define TIME_DELTA(a, b) ((unsigned long)((long)(a) - (long)(b)))
+
+static inline u32 cstamp_delta(unsigned long cstamp)
+{
+	return (cstamp - INITIAL_JIFFIES) * 100UL / HZ;
+}
 
 #define ADDRCONF_TIMER_FUZZ_MINUS	(HZ > 50 ? HZ/50 : 1)
 #define ADDRCONF_TIMER_FUZZ		(HZ / 4)
@@ -3444,10 +3448,8 @@ static int put_cacheinfo(struct sk_buff 
 {
 	struct ifa_cacheinfo ci;
 
-	ci.cstamp = (u32)(TIME_DELTA(cstamp, INITIAL_JIFFIES) / HZ * 100
-			+ TIME_DELTA(cstamp, INITIAL_JIFFIES) % HZ * 100 / HZ);
-	ci.tstamp = (u32)(TIME_DELTA(tstamp, INITIAL_JIFFIES) / HZ * 100
-			+ TIME_DELTA(tstamp, INITIAL_JIFFIES) % HZ * 100 / HZ);
+	ci.cstamp = cstamp_delta(cstamp);
+	ci.tstamp = cstamp_delta(tstamp);
 	ci.ifa_prefered = preferred;
 	ci.ifa_valid = valid;
 
@@ -3905,10 +3907,9 @@ static int inet6_fill_ifla6_attrs(struct
 	NLA_PUT_U32(skb, IFLA_INET6_FLAGS, idev->if_flags);
 
 	ci.max_reasm_len = IPV6_MAXPLEN;
-	ci.tstamp = (__u32)(TIME_DELTA(idev->tstamp, INITIAL_JIFFIES) / HZ * 100
-		    + TIME_DELTA(idev->tstamp, INITIAL_JIFFIES) % HZ * 100 / HZ);
-	ci.reachable_time = idev->nd_parms->reachable_time;
-	ci.retrans_time = idev->nd_parms->retrans_time;
+	ci.tstamp = cstamp_delta(idev->tstamp);
+	ci.reachable_time = jiffies_to_msecs(idev->nd_parms->reachable_time);
+	ci.retrans_time = jiffies_to_msecs(idev->nd_parms->retrans_time);
 	NLA_PUT(skb, IFLA_INET6_CACHEINFO, sizeof(ci), &ci);
 
 	nla = nla_reserve(skb, IFLA_INET6_CONF, DEVCONF_MAX * sizeof(s32));
