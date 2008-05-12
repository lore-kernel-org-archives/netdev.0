From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: IPV6 stateless address autoconfiguration
Date: Tue, 13 May 2008 00:46:20 +0900 (JST)
Message-ID: <20080513.004620.117676648.yoshfuji@linux-ipv6.org>
References: <BECE1C148A85274EB554378A3E0EDF4906388342@USA0300MS02.na.xerox.net>
	<20080512.051454.215453665.davem@davemloft.net>
	<20080512.235837.12477853.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	davem@davemloft.net
To: Joseph.Bonitch@xerox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:40056 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752348AbYELPqE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2008 11:46:04 -0400
In-Reply-To: <20080512.235837.12477853.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <20080512.235837.12477853.yoshfuji@linux-ipv6.org> (at Mon, 12 May 2008 23:58:37 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:

> In article <20080512.051454.215453665.davem@davemloft.net> (at Mon, 12 May 2008 05:14:54 -0700 (PDT)), David Miller <davem@davemloft.net> says:
> 
> > From: "Bonitch, Joseph" <Joseph.Bonitch@xerox.com>
> > Date: Mon, 12 May 2008 07:46:11 -0400
> > 
> > > I sent a note last week regarding an issue I found with IPV6 stateless
> > > address autoconfiguration.  I received no responses so I'm wondering if
> > > there is another list I should be sending this problem too.
> > 
> > We've all received it and saw your posting, it's just that everyone is
> > simply busy with other things.
> 
> Just FYI, I'm now looking into it.

Okay, this is my tentative patch.
Could you test this, please?

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

--- 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index e591e09..266a6bb 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1787,18 +1787,29 @@ void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len)
 		rt = rt6_lookup(dev_net(dev), &pinfo->prefix, NULL,
 				dev->ifindex, 1);
 
-		if (rt && ((rt->rt6i_flags & (RTF_GATEWAY | RTF_DEFAULT)) == 0)) {
-			if (rt->rt6i_flags&RTF_EXPIRES) {
-				if (valid_lft == 0) {
-					ip6_del_rt(rt);
-					rt = NULL;
-				} else {
-					rt->rt6i_expires = jiffies + rt_expires;
-				}
+		if (rt && (rt->rt6i_flags & (RTF_ADDRCONF | RTF_PREFIX_RT)) == (RTF_ADDRCONF | RTF_PREFIX_RT)) {
+			/* Autoconf prefix route */
+			if (valid_lft == 0) {
+				ip6_del_rt(rt);
+				rt = NULL;
+			} else if (~rt_expires) {
+				/* not infinity */
+				rt->rt6i_expires = jiffies + rt_expires;
+				rt->rt6i_flags |= RTF_EXPIRES;
+			} else {
+				rt->rt6i_flags &= ~RTF_EXPIRES;
+				rt->rt6i_expires = 0;
 			}
 		} else if (valid_lft) {
+			int flags = RTF_ADDRCONF | RTF_PREFIX_RT;
+			clock_t expires = 0;
+			if (~rt_expires) {
+				/* not infinity */
+				flags |= RTF_EXPIRES;
+				expires = jiffies_to_clock_t(rt_expires);
+			}
 			addrconf_prefix_route(&pinfo->prefix, pinfo->prefix_len,
-					      dev, jiffies_to_clock_t(rt_expires), RTF_ADDRCONF|RTF_EXPIRES|RTF_PREFIX_RT);
+					      dev, expires, flags);
 		}
 		if (rt)
 			dst_release(&rt->u.dst);


--yoshfuji
