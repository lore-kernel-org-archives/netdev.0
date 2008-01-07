From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH] [IPv6]: IPV6_MULTICAST_IF setting is ignored on link-local
 connect()
Date: Mon, 07 Jan 2008 12:03:12 -0500
Message-ID: <47825B50.2060200@hp.com>
References: <OF27B7DA9C.52E5380F-ON882573B6.00650422-882573B6.0068581B@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000601010502020900000508"
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netdev-owner@vger.kernel.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:6483 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753217AbYAGRDP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2008 12:03:15 -0500
In-Reply-To: <OF27B7DA9C.52E5380F-ON882573B6.00650422-882573B6.0068581B@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000601010502020900000508
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

David Stevens wrote:
>         Yeah, that's what I get for typing in off-the-cuff code. What
> I was thinking was the fl.oif assignment instead was:
>         if (!sk->sk_bound_dev_if &&
>                 (addr_type & IPV6_ADDR_MULTICAST))
>                         sk->sk_bound_dev_if = np->mcast_oif;
> 
> Which it is not, but maybe it could be, since this is a connect().

How about the simple patch below?  I just removed the ENINVAL check from 
my original patch, but it accomplishes the same thing.

> That patch looks better, but I'm wondering if we could just remove the
> requirement that sin6_scope_id be set here if it's multicast, since it
> is doing the following later in the code:
> 
>         if (!fl.oif && (addr_type&IPV6_ADDR_MULTICAST))
>                 fl.oif = np->mcast_oif;
> 
> So, really, all we need to do is get through the LINKLOCAL section
> without error in the multicast case and we can remove the redundant
> multicast check there. I think that'd be simpler.

I don't think we can remove that check since it covers the non-multicast 
case.

-Brian

Signed-off-by: Brian Haley <brian.haley@hp.com>
---

--------------000601010502020900000508
Content-Type: text/x-patch;
 name="mcast_oif.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="mcast_oif.patch"

diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 2ed689a..5d4245a 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -123,11 +123,11 @@ ipv4_connected:
 				goto out;
 			}
 			sk->sk_bound_dev_if = usin->sin6_scope_id;
-			if (!sk->sk_bound_dev_if &&
-			    (addr_type & IPV6_ADDR_MULTICAST))
-				fl.oif = np->mcast_oif;
 		}
 
+		if (!sk->sk_bound_dev_if && (addr_type & IPV6_ADDR_MULTICAST))
+			sk->sk_bound_dev_if = np->mcast_oif;
+
 		/* Connect to link-local address requires an interface */
 		if (!sk->sk_bound_dev_if) {
 			err = -EINVAL;

--------------000601010502020900000508--
