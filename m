From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH] RAW6: Do not allow set IPV6_CHECKSUM for ICMPv6 socket
Date: Sun, 20 Apr 2008 17:18:17 +0800
Message-ID: <480B0A59.7000408@cn.fujitsu.com>
References: <480878CE.5040904@cn.fujitsu.com>	<20080418.040949.87112742.davem@davemloft.net>	<480AEE5C.4090402@cn.fujitsu.com> <20080420.003328.45324753.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:58135 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752688AbYDTJTy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Apr 2008 05:19:54 -0400
In-Reply-To: <20080420.003328.45324753.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller said the following on 2008-4-20 15:33:
> From: Wang Chen <wangchen@cn.fujitsu.com>
> Date: Sun, 20 Apr 2008 15:18:52 +0800
> 
>> Why not remove the RFC-breaking code from applications?
> 
> Because once applications exist and are deployed we cannot break them
> with careless kernel changes.  A user should not get a broken
> traceroute6 binary just because he upgrades his kernel, that's
> a bug.
> 
> The RFC is not a set of laws that must be followed under all
> circumstances.  In this case it is worse to break applications on
> people's systems than be compliant to some standard.
> 

Yes. I agree with you that the RFC is not a law and we don't want to
break applications by changing kernel.

So, how about the following approach which don't break iputils.

---
As RFC3542 mentions: An attempt to set IPV6_CHECKSUM for an ICMPv6 socket
will fail. But there are some legacy applications which set the option to
enable IPV6_CHECKSUM for ICMPv6 socket.
To forbid disabling checksum for ICMPv6 socket, add a check for that in
do_rawv6_setsockopt().

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 net/ipv6/raw.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 0a6fbc1..0be4eb3 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -994,6 +994,12 @@ static int do_rawv6_setsockopt(struct sock *sk, int level, int optname,
 
 	switch (optname) {
 		case IPV6_CHECKSUM:
+			/* RFC3542: An attempt to set IPV6_CHECKSUM for an
+			 * ICMPv6 socket will fail. But for legacy application
+			 * compliance, allow offset=2 option value.
+			 */
+			if (inet_sk(sk)->num == IPPROTO_ICMPV6 && val != 2)
+				return(-EINVAL);
 			/* You may get strange result with a positive odd offset;
 			   RFC2292bis agrees with me. */
 			if (val > 0 && (val&1))
-- 
1.5.4


