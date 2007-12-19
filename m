From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH] [IPv6]: IPV6_MULTICAST_IF setting is ignored on link-local
 connect()
Date: Wed, 19 Dec 2007 10:35:46 -0500
Message-ID: <47693A52.5020301@hp.com>
References: <OF7B1ADDCA.711DCE7B-ON882573B5.00820D67-882573B5.0083AEF8@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010205040607090904030004"
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netdev-owner@vger.kernel.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:22715 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759016AbXLSPoU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2007 10:44:20 -0500
In-Reply-To: <OF7B1ADDCA.711DCE7B-ON882573B5.00820D67-882573B5.0083AEF8@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010205040607090904030004
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit

Hi David,

David Stevens wrote:
> OK, I see what you're trying to fix now.
> 
> I think the scope_id checks are not quite right-- they
> should be something like this:
> 
> if (addr_type&IPV6_ADDR_LINKLOCAL) {
>         if (addr_len >= sizeof(struct sockaddr_in6)) {
>                 if (sk->sk_bound_dev_if && usin->sin6_scope_id &&
>                     sk->sk_bound_dev_if != usin->sin6_scope_id) {
>                         err = -EINVAL;
>                         goto out;
>                 }
>                 if (usin->sin6_scope_id)
>                         sk->sk_bound_dev_if = usin->sin6_scope_id;
>                 if (!sk->sk_bound_dev_if &&
>                      (addr_type & IPV6_ADDR_MULTICAST))
>                         fl.oif = np->mcast_oif;

This assignment will not get us past the next check...

>         /* connect to the link-local addres requires an interface */
>         if (!sk->sk_bound_dev_if) {
>                 err = -EINVAL;
>                 goto out;
>         }

... and even if it did, fl.oif is over-written by sk_bound_dev_if just a 
few lines down.

>         If I did an SO_BINDTODEVICE and specified sin6_scope_id,
> then they better agree.
>         If I specified sin6_scope_id without SO_BINDTODEVICE, set
> the device to that.
>         If I get this far without a device and it's multicast, use 
> mcast_oif
>         If I get all through that and don't have a device, EINVAL.

You also need to check if mcast_oif matches sk_bind_dev_if here - it's 
actually done in the setsockopt() code already when we set it, 
duplicating it here isn't that big a deal.

How about the following patch?  It does not set sk_bound_dev_if to 
mcast_oif, but does allow the connect() to succeed.

-Brian


Signed-off-by: Brian Haley <brian.haley@hp.com>
---

--------------010205040607090904030004
Content-Type: text/x-patch;
 name="mcast_oif.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="mcast_oif.patch"

diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 2ed689a..3226970 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -114,6 +114,8 @@ ipv4_connected:
 		goto out;
 	}
 
+	fl.oif = sk->sk_bound_dev_if;
+
 	if (addr_type&IPV6_ADDR_LINKLOCAL) {
 		if (addr_len >= sizeof(struct sockaddr_in6) &&
 		    usin->sin6_scope_id) {
@@ -122,14 +124,14 @@ ipv4_connected:
 				err = -EINVAL;
 				goto out;
 			}
-			sk->sk_bound_dev_if = usin->sin6_scope_id;
-			if (!sk->sk_bound_dev_if &&
-			    (addr_type & IPV6_ADDR_MULTICAST))
-				fl.oif = np->mcast_oif;
+			fl.oif = sk->sk_bound_dev_if = usin->sin6_scope_id;
 		}
 
+		if (!fl.oif && (addr_type & IPV6_ADDR_MULTICAST))
+			fl.oif = np->mcast_oif;
+
 		/* Connect to link-local address requires an interface */
-		if (!sk->sk_bound_dev_if) {
+		if (!fl.oif) {
 			err = -EINVAL;
 			goto out;
 		}
@@ -148,7 +150,6 @@ ipv4_connected:
 	fl.proto = sk->sk_protocol;
 	ipv6_addr_copy(&fl.fl6_dst, &np->daddr);
 	ipv6_addr_copy(&fl.fl6_src, &np->saddr);
-	fl.oif = sk->sk_bound_dev_if;
 	fl.fl_ip_dport = inet->dport;
 	fl.fl_ip_sport = inet->sport;
 

--------------010205040607090904030004--
