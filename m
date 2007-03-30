From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH][IPv6]: Fix incorrect length check in rawv6_sendmsg()
Date: Fri, 30 Mar 2007 09:13:16 +0900 (JST)
Message-ID: <20070330.091316.58970851.yoshfuji@linux-ipv6.org>
References: <1175203048.16183.14.camel@w-sridhar2.beaverton.ibm.com>
	<20070329.142644.70222545.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sri@us.ibm.com, netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:35403 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1945909AbXC3AMa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Mar 2007 20:12:30 -0400
In-Reply-To: <20070329.142644.70222545.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20070329.142644.70222545.davem@davemloft.net> (at Thu, 29 Mar 2007 14:26:44 -0700 (PDT)), David Miller <davem@davemloft.net> says:

> From: Sridhar Samudrala <sri@us.ibm.com>
> Date: Thu, 29 Mar 2007 14:17:28 -0700
> 
> > The check for length in rawv6_sendmsg() is incorrect.
> > As len is an unsigned int, (len < 0) will never be TRUE.
> > I think checking for IPV6_MAXPLEN(65535) is better.
> > 
> > Is it possible to send ipv6 jumbo packets using raw
> > sockets? If so, we can remove this check.
> 
> I don't see why such a limitation against jumbo would exist,
> does anyone else?
> 
> Thanks for catching this Sridhar.  A good compiler should simply
> fail to compile "if (x < 0)" when 'x' is an unsigned type, don't
> you think :-)

Dave, we use "int" for returning value,
so we should fix this anyway, IMHO;
we should not allow len > INT_MAX.

Don't you think so?

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 306d5d8..203e069 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -687,9 +687,9 @@ static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 	int err;
 
 	/* Rough check on arithmetic overflow,
-	   better check is made in ip6_build_xmit
+	   better check is made in ip6_append_data().
 	 */
-	if (len < 0)
+	if (len > INT_MAX)
 		return -EMSGSIZE;
 
 	/* Mirror BSD error message compatibility */
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 0ad4719..f590db5 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -615,7 +615,7 @@ do_udp_sendmsg:
 		return udp_sendmsg(iocb, sk, msg, len);
 
 	/* Rough check on arithmetic overflow,
-	   better check is made in ip6_build_xmit
+	   better check is made in ip6_append_data().
 	   */
 	if (len > INT_MAX - sizeof(struct udphdr))
 		return -EMSGSIZE;

--yoshfuji
