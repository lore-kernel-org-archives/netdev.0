From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: Re: [PATCH 1/2] ipv4: fix do_ip_setsockopt optlen check for IP_MULTICAST_IF
Date: Thu, 17 Sep 2009 17:15:22 +0800
Message-ID: <4AB1FE2A.1060906@cn.fujitsu.com>
References: <1253164784-15789-1-git-send-email-dfeng@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kaber@trash.net, yoshfuji@linux-ipv6.org,
	jmorris@namei.org, pekkas@netcore.fi, kuznet@ms2.inr.ac.ru,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Xiaotian Feng <dfeng@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:63341 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752870AbZIQJLB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Sep 2009 05:11:01 -0400
In-Reply-To: <1253164784-15789-1-git-send-email-dfeng@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Xiaotian Feng wrote, at 09/17/2009 01:19 PM:
> Due to man page of setsockopt, if optlen is not valid, kernel should return
> -EINVAL. But a simple testcase as following, errno is 0, which means setsockopt
> is successful.
> 
>         addr.s_addr = inet_addr("192.1.2.3");
>         setsockopt(s, IPPROTO_IP, IP_MULTICAST_IF, &addr, 1);
> 	printf("errno is %d\n", errno);
> 
> This patch fixes the optlen check part, with the patch, we got errno EINVAL.
> 

I also think it's a bug, the freebsd also does the optlen check. 
But the style should be coincident with other option: firstly check the
availability of optlen, then copy option value from user and deal with it.   

How about this one:

diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index fc7993e..5a06935 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -611,6 +611,9 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 		 *	Check the arguments are allowable
 		 */
 
+		if (optlen < sizeof(struct in_addr))
+			goto e_inval;
+
 		err = -EFAULT;
 		if (optlen >= sizeof(struct ip_mreqn)) {
 			if (copy_from_user(&mreq, optval, sizeof(mreq)))



Best Regards
-----
Shan Wei

