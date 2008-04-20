From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] RAW6: Do not allow set IPV6_CHECKSUM for ICMPv6 socket
Date: Sun, 20 Apr 2008 18:38:35 +0900 (JST)
Message-ID: <20080420.183835.02139171.yoshfuji@linux-ipv6.org>
References: <480AEE5C.4090402@cn.fujitsu.com>
	<20080420.003328.45324753.davem@davemloft.net>
	<480B0A59.7000408@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: wangchen@cn.fujitsu.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:33874 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753371AbYDTJgm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Apr 2008 05:36:42 -0400
In-Reply-To: <480B0A59.7000408@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <480B0A59.7000408@cn.fujitsu.com> (at Sun, 20 Apr 2008 17:18:17 +0800), Wang Chen <wangchen@cn.fujitsu.com> says:

> David Miller said the following on 2008-4-20 15:33:
> > From: Wang Chen <wangchen@cn.fujitsu.com>
> > Date: Sun, 20 Apr 2008 15:18:52 +0800
> > 
> >> Why not remove the RFC-breaking code from applications?
> > 
> > Because once applications exist and are deployed we cannot break them
> > with careless kernel changes.  A user should not get a broken
> > traceroute6 binary just because he upgrades his kernel, that's
> > a bug.
> > 
> > The RFC is not a set of laws that must be followed under all
> > circumstances.  In this case it is worse to break applications on
> > people's systems than be compliant to some standard.
> > 
> 
> Yes. I agree with you that the RFC is not a law and we don't want to
> break applications by changing kernel.
> 
> So, how about the following approach which don't break iputils.
> 
> ---
> As RFC3542 mentions: An attempt to set IPV6_CHECKSUM for an ICMPv6 socket
> will fail. But there are some legacy applications which set the option to
> enable IPV6_CHECKSUM for ICMPv6 socket.
> To forbid disabling checksum for ICMPv6 socket, add a check for that in
> do_rawv6_setsockopt().
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>

NAK.

I have another approach.

RFC3542 only tells about IPPROTO_IPV6-level IPV6_CHECKSUM option only
while ping6 and traceroute6 use IPPROTO_RAW-level IPV6_CHECKSUM
option.  Just disallow setting those on IPPROTO_IPV6 level.

----
>From 28024cad925091176166a3f4468ad622d18ef41c Mon Sep 17 00:00:00 2001
From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Sat, 19 Apr 2008 20:53:44 +0900
Subject: [PATCH] [IPV6] RAW: Disallow IPPROTO_IPV6-level IPV6_CHECKSUM socket option on ICMPv6 sockets.

RFC3542 tells that IPV6_CHECKSUM socket option in the IPPROTO_IPV6
level is not allowed on ICMPv6 sockets.
IPPROTO_RAW level IPV6_CHECKSUM socket option (a Linux extension)
is still allowed.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/raw.c |   18 ++++++++++++++++++
 1 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 0a6fbc1..9ad9aca 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -994,6 +994,19 @@ static int do_rawv6_setsockopt(struct sock *sk, int level, int optname,
 
 	switch (optname) {
 		case IPV6_CHECKSUM:
+			if (inet_sk(sk)->num == IPPROTO_ICMPV6 &&
+			    level == IPPROTO_IPV6) {
+				/*
+				 * RFC3542 tells that IPV6_CHECKSUM socket
+				 * option in the IPPROTO_IPV6 level is not
+				 * allowed on ICMPv6 sockets.
+				 * If you want to set it, use IPPROTO_RAW
+				 * level IPV6_CHECKSUM socket option
+				 * (Linux extension).
+				 */
+				return -EINVAL;
+			}
+
 			/* You may get strange result with a positive odd offset;
 			   RFC2292bis agrees with me. */
 			if (val > 0 && (val&1))
@@ -1069,6 +1082,11 @@ static int do_rawv6_getsockopt(struct sock *sk, int level, int optname,
 
 	switch (optname) {
 	case IPV6_CHECKSUM:
+		/*
+		 * We allow getsockopt() for IPPROTO_IPV6-level
+		 * IPV6_CHECKSUM socket option on ICMPv6 sockets
+		 * since RFC3542 is silent about it.
+		 */
 		if (rp->checksum == 0)
 			val = -1;
 		else
-- 
1.4.4.4

