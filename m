From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH] IPv6: Fix the return value of ipv6_getsockopt
Date: Thu, 13 Dec 2007 14:44:00 +0900
Message-ID: <4760C6A0.4000300@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail7.fujitsu.co.jp ([192.51.44.37]:52452 "EHLO
	fgwmail7.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750770AbXLMFoL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2007 00:44:11 -0500
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id lBD5i9OB025824
	for <netdev@vger.kernel.org> (envelope-from yjwei@cn.fujitsu.com);
	Thu, 13 Dec 2007 14:44:09 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 49E362AC037
	for <netdev@vger.kernel.org>; Thu, 13 Dec 2007 14:44:09 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2200E12C0B8
	for <netdev@vger.kernel.org>; Thu, 13 Dec 2007 14:44:09 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4 [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0DA40161C00A
	for <netdev@vger.kernel.org>; Thu, 13 Dec 2007 14:44:09 +0900 (JST)
Received: from vs01.gw.fujitsu.co.jp (vs01.gw.fujitsu.co.jp [133.161.11.21])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A34A7161C00B
	for <netdev@vger.kernel.org>; Thu, 13 Dec 2007 14:44:08 +0900 (JST)
Received: from root00.fujitsu.com (root00.fujitsu.com [133.161.11.10])
	by vs01.gw.fujitsu.co.jp (8.13.7/8.13.7) with ESMTP id lBD5i8IV023397
	for <netdev@vger.kernel.org>; Thu, 13 Dec 2007 14:44:08 +0900
Received: from root00.fujitsu.com (root00 [127.0.0.1])
	by root00.fujitsu.com (Postfix) with ESMTP id 6E9EF133794
	for <netdev@vger.kernel.org>; Thu, 13 Dec 2007 14:44:08 +0900 (JST)
Received: from [10.33.110.120] (dhcp110-120.sky.yk.fujitsu.co.jp [10.33.110.120])
	by root00.fujitsu.com (Postfix) with ESMTP id 21C0013377B
	for <netdev@vger.kernel.org>; Thu, 13 Dec 2007 14:44:08 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If CONFIG_NETFILTER if not selected when compile the kernel source code, 
ipv6_getsockopt will returen an EINVAL error if optname is not supported by
the kernel. But if CONFIG_NETFILTER is selected, ENOPROTOOPT error will 
be return.
This patch fix to always return ENOPROTOOPT error if optname argument of 
ipv6_getsockopt is not supported by the kernel.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>

--- a/net/ipv6/ipv6_sockglue.c	2007-12-11 04:33:00.000000000 -0500
+++ b/net/ipv6/ipv6_sockglue.c	2007-12-11 06:40:18.000000000 -0500
@@ -1046,7 +1046,7 @@ static int do_ipv6_getsockopt(struct soc
 		break;
 
 	default:
-		return -EINVAL;
+		return -ENOPROTOOPT;
 	}
 	len = min_t(unsigned int, sizeof(int), len);
 	if(put_user(len, optlen))
@@ -1069,9 +1069,8 @@ int ipv6_getsockopt(struct sock *sk, int
 
 	err = do_ipv6_getsockopt(sk, level, optname, optval, optlen);
 #ifdef CONFIG_NETFILTER
-	/* we need to exclude all possible EINVALs except default case */
-	if (err == -EINVAL && optname != IPV6_ADDRFORM &&
-			optname != MCAST_MSFILTER) {
+	/* we need to exclude all possible ENOPROTOOPTs except default case */
+	if (err == -ENOPROTOOPT && optname != IPV6_2292PKTOPTIONS) {
 		int len;
 
 		if (get_user(len, optlen))
@@ -1108,9 +1107,8 @@ int compat_ipv6_getsockopt(struct sock *
 
 	err = do_ipv6_getsockopt(sk, level, optname, optval, optlen);
 #ifdef CONFIG_NETFILTER
-	/* we need to exclude all possible EINVALs except default case */
-	if (err == -EINVAL && optname != IPV6_ADDRFORM &&
-			optname != MCAST_MSFILTER) {
+	/* we need to exclude all possible ENOPROTOOPTs except default case */
+	if (err == -ENOPROTOOPT && optname != IPV6_2292PKTOPTIONS) {
 		int len;
 
 		if (get_user(len, optlen))



