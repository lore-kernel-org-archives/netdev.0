From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [RFC PATCH] Fix double dereference (Re: IPv6 badness continues)
Date: Fri, 07 Jan 2005 11:18:06 +0900 (JST)
Message-ID: <20050107.111806.27181187.yoshfuji@linux-ipv6.org>
References: <41DA3A60.8050102@pobox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, herbert@gondor.apana.org.au
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com, davem@davemloft.net
In-Reply-To: <41DA3A60.8050102@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

In article <41DA3A60.8050102@pobox.com> (at Tue, 04 Jan 2005 01:40:32 -0500), Jeff Garzik <jgarzik@pobox.com> says:

> The first 'Badness in dst_release' message (of many) from 2.6.10-bk1, on 
> x86 SMP, is found below.
:
> Badness in dst_release at include/net/dst.h:149
>   [<f8c14a57>] ip6_dst_check+0x67/0x80 [ipv6]
>   [<f8c0b2d4>] ip6_dst_lookup+0x1b4/0x1d0 [ipv6]
>   [<f8c1e4b4>] udpv6_sendmsg+0x2b4/0x950 [ipv6]

Ok, now I doubt sk_dst_check() code path.

When ip6_dst_check() (or its variants) returns NULL, it will release 
refcnt while it leaves sk->dst_cache non-NULL.
Later, caller sets it to NULL by sk_dst_reset() (or its variants), and it 
decrements refcnt again.

I think we should NOT release refcnt in sk_dst_check() (or its variants)
even we return NULL because that reference was held for sk->dst_cache
and it is available yet. Instead, we should release refcnt when we 
really reset the dst in sk_dst_reset() (or its variants).
(Alternatively, we may always set sk->dst_cache to NULL and release 
refcnt when we're about to return NULL in sk_dst_check()
(or its variants).)

Am I miss something?

===== net/decnet/dn_route.c 1.29 vs edited =====
--- 1.29/net/decnet/dn_route.c	2004-11-10 09:44:25 +09:00
+++ edited/net/decnet/dn_route.c	2005-01-04 17:14:01 +09:00
@@ -253,7 +253,6 @@
  */
 static struct dst_entry *dn_dst_check(struct dst_entry *dst, __u32 cookie)
 {
-	dst_release(dst);
 	return NULL;
 }
 
===== net/ipv4/route.c 1.99 vs edited =====
--- 1.99/net/ipv4/route.c	2004-12-28 12:49:57 +09:00
+++ edited/net/ipv4/route.c	2005-01-04 17:13:49 +09:00
@@ -1321,7 +1321,6 @@
 
 static struct dst_entry *ipv4_dst_check(struct dst_entry *dst, u32 cookie)
 {
-	dst_release(dst);
 	return NULL;
 }
 
===== net/ipv6/route.c 1.102 vs edited =====
--- 1.102/net/ipv6/route.c	2004-11-30 12:24:46 +09:00
+++ edited/net/ipv6/route.c	2005-01-04 17:13:34 +09:00
@@ -578,8 +578,6 @@
 
 	if (rt && rt->rt6i_node && (rt->rt6i_node->fn_sernum == cookie))
 		return dst;
-
-	dst_release(dst);
 	return NULL;
 }
 
===== net/xfrm/xfrm_policy.c 1.61 vs edited =====
--- 1.61/net/xfrm/xfrm_policy.c	2004-12-28 11:33:32 +09:00
+++ edited/net/xfrm/xfrm_policy.c	2005-01-04 17:13:12 +09:00
@@ -1000,8 +1000,6 @@
 {
 	if (!stale_bundle(dst))
 		return dst;
-
-	dst_release(dst);
 	return NULL;
 }
 

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
