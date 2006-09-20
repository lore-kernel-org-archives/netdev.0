From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [GIT PATCH] IPV6: Updates for net-2.6.19
Date: Wed, 20 Sep 2006 12:46:33 +0900 (JST)
Message-ID: <20060920.124633.93310316.yoshfuji@linux-ipv6.org>
References: <20060919.000826.80802464.yoshfuji@linux-ipv6.org>
	<45101A35.6060908@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:14086 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S1750895AbWITDoX
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Sep 2006 23:44:23 -0400
To: nicolas.dichtel@6wind.com, davem@davemloft.net
In-Reply-To: <45101A35.6060908@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <45101A35.6060908@6wind.com> (at Tue, 19 Sep 2006 18:26:29 +0200), Nicolas DICHTEL <nicolas.dichtel@6wind.com> says:

> > +	if (pneigh)
> > +		is_router = pneigh->flags & NTF_ROUTER;
> >   
> In function ndisc_send_na(), is_router must be 1 or 0, doesn't it ? Because,
> icmph.icmp6_router is define as: "__u32           router:1,".
> 
> So, patch will be:
> 
> -		is_router = pneigh->flags & NTF_ROUTER;
> +		is_router = !!(pneigh->flags & NTF_ROUTER);
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> 
> 
> What do you think ?

Oh, good catch.

In addition, we are sending NA with wrong IsRouter if forwarding is
set to even non-zero value.  We need to fix both.

Here's the patch on top of my git tree for IPv6 updates.

----
[IPV6] NDISC: Fix is_router flag setting.

We did not send appropriate IsRouter flag in proxy NAs, or in non-proxy NAs
if the forwarding setting is even non-zero value.  To fix both cases,
let's ensure to give 1/0 value to ndisc_send_na().

Also, existing users of ndisc_send_na() give 0/1 to override,
we can omit redundant operation in that function.

Bug in proxy NAs was spotted by Nicolas Dichtel <nicolas.dichtel@6wind.com>.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/ndisc.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 76517a5..0304b5f 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -496,7 +496,7 @@ static void ndisc_send_na(struct net_dev
         msg->icmph.icmp6_unused = 0;
         msg->icmph.icmp6_router    = router;
         msg->icmph.icmp6_solicited = solicited;
-        msg->icmph.icmp6_override  = !!override;
+        msg->icmph.icmp6_override  = override;
 
         /* Set the target address. */
 	ipv6_addr_copy(&msg->target, solicited_addr);
@@ -847,10 +847,7 @@ static void ndisc_recv_ns(struct sk_buff
 			goto out;
 	}
 
-	if (pneigh)
-		is_router = pneigh->flags & NTF_ROUTER;
-	else
-		is_router = idev->cnf.forwarding;
+	is_router = !!(pneigh ? pneigh->flags & NTF_ROUTER : idev->cnf.forwarding);
 
 	if (dad) {
 		struct in6_addr maddr;
-- 
1.4.0


-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
