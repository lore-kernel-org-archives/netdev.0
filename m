From: Yang Hongyang <yanghy@cn.fujitsu.com>
Subject: [PATCH 1/2] IPv6: Fix the return value of get destination options
 with NULL data pointer
Date: Wed, 28 May 2008 16:23:47 +0800
Message-ID: <483D1693.4080805@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@sunset.davemloft.net, netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:64747 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750831AbYE1IY4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 May 2008 04:24:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we pass NULL data buffer to getsockopt(), it will return 0,
and the option length is set to -EFAULT:
    getsockopt(sk, IPPROTO_IPV6, IPV6_DSTOPTS, NULL, &len);

This is because ipv6_getsockopt_sticky() will return -EFAULT or
-EINVAL if some error occur.

This patch fix this problem.

Signed-off-by: Yang Hongyang <yanghy@cn.fujitsu.com> 

---
 net/ipv6/ipv6_sockglue.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 56d55fe..aa7bedf 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -975,6 +975,9 @@ static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
 		len = ipv6_getsockopt_sticky(sk, np->opt,
 					     optname, optval, len);
 		release_sock(sk);
+		/* check if ipv6_getsockopt_sticky() returns err code */
+		if (len < 0)
+			return len;
 		return put_user(len, optlen);
 	}
 
-- 1.5.3.8 

