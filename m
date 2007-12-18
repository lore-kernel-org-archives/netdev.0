From: Brian Haley <brian.haley@hp.com>
Subject: [PATCH] [IPv6]: IPV6_MULTICAST_IF setting is ignored on link-local
 connect()
Date: Tue, 18 Dec 2007 15:57:54 -0500
Message-ID: <47683452.8080102@hp.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080304000401070209080604"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0007.atlanta.hp.com ([15.192.0.44]:8811 "EHLO
	g5t0007.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752634AbXLRU54 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2007 15:57:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080304000401070209080604
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Trying to connect() to an IPv6 link-local multicast address by
specifying the outgoing multicast interface doesn't work, you have to
bind to a device first with an SO_BINDTODEVICE setsockopt() call.  This
patch allows the IPV6_MULTICAST_IF setting to also control which
interface should be used for the connection, as specified in RFC 3493.

Signed-off-by: Brian Haley <brian.haley@hp.com>
---


--------------080304000401070209080604
Content-Type: text/x-patch;
 name="mcast_oif.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="mcast_oif.patch"

diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 2ed689a..0b1e7eb 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -123,9 +123,15 @@ ipv4_connected:
 				goto out;
 			}
 			sk->sk_bound_dev_if = usin->sin6_scope_id;
-			if (!sk->sk_bound_dev_if &&
-			    (addr_type & IPV6_ADDR_MULTICAST))
-				fl.oif = np->mcast_oif;
+		}
+
+		if ((addr_type & IPV6_ADDR_MULTICAST) && np->mcast_oif) {
+			if (sk->sk_bound_dev_if &&
+			    sk->sk_bound_dev_if != np->mcast_oif) {
+				err = -EINVAL;
+				goto out;
+			}
+			sk->sk_bound_dev_if = np->mcast_oif;
 		}
 
 		/* Connect to link-local address requires an interface */


--------------080304000401070209080604--
