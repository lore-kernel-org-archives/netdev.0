From: Brian Haley <brian.haley@hp.com>
Subject: [PATCH] IPv6: preferred lifetime of address not getting updated
Date: Thu, 02 Jul 2009 13:10:52 -0400
Message-ID: <4A4CEA1C.3070606@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jens Rosenboom <jens.rosenboom@freenet.ag>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:26829 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751428AbZGBRKv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2009 13:10:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There's a bug in addrconf_prefix_rcv() where it won't update the
preferred lifetime of an IPv6 address if the current valid lifetime
of the address is less than 2 hours (the minimum value in the RA).

For example, If I send a router advertisement with a prefix that
has valid lifetime = preferred lifetime = 2 hours we'll build
this address:

3: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qlen 1000
    inet6 2001:1890:1109:a20:217:8ff:fe7d:4718/64 scope global dynamic 
       valid_lft 7175sec preferred_lft 7175sec

If I then send the same prefix with valid lifetime = preferred
lifetime = 0 it will be ignored since the minimum valid lifetime
is 2 hours:

3: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qlen 1000
    inet6 2001:1890:1109:a20:217:8ff:fe7d:4718/64 scope global dynamic 
       valid_lft 7161sec preferred_lft 7161sec

But according to RFC 4862 we should always reset the preferred lifetime
even if the valid lifetime is invalid, which would cause the address
to immediately get deprecated.  So with this patch we'd see this:

5: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qlen 1000
    inet6 2001:1890:1109:a20:21f:29ff:fe5a:ef04/64 scope global deprecated dynamic 
       valid_lft 7163sec preferred_lft 0sec

The comment winds-up being 5x the size of the code to fix the problem.

This patch is against net-2.6.

-----

Update the preferred lifetime of IPv6 addresses derived from a prefix
info option in a router advertisement even if the valid lifetime in
the option is invalid, as specified in RFC 4862 Section 5.5.3e.  Fixes
an issue where an address will not immediately become deprecated.
Reported by Jens Rosenboom.

Signed-off-by: Brian Haley <brian.haley@hp.com>
---

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 3883b40..43b3c9f 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1916,8 +1916,32 @@ ok:
 					update_lft = 1;
 				else if (stored_lft <= MIN_VALID_LIFETIME) {
 					/* valid_lft <= stored_lft is always true */
-					/* XXX: IPsec */
-					update_lft = 0;
+					/*
+					 * RFC 4862 Section 5.5.3e:
+					 * "Note that the preferred lifetime of
+					 *  the corresponding address is always
+					 *  reset to the Preferred Lifetime in
+					 *  the received Prefix Information
+					 *  option, regardless of whether the
+					 *  valid lifetime is also reset or
+					 *  ignored."
+					 *
+					 *  So if the preferred lifetime in
+					 *  this advertisement is different
+					 *  than what we have stored, but the
+					 *  valid lifetime is invalid, just
+					 *  reset prefered_lft.
+					 *
+					 *  We must set the valid lifetime
+					 *  to the stored lifetime since we'll
+					 *  be updating the timestamp below,
+					 *  else we'll set it back to the
+					 *  minumum.
+					 */
+					if (prefered_lft != ifp->prefered_lft) {
+						valid_lft = stored_lft;
+						update_lft = 1;
+					}
 				} else {
 					valid_lft = MIN_VALID_LIFETIME;
 					if (valid_lft < prefered_lft)
@@ -3085,7 +3109,7 @@ restart:
 				spin_unlock(&ifp->lock);
 				continue;
 			} else if (age >= ifp->prefered_lft) {
-				/* jiffies - ifp->tsamp > age >= ifp->prefered_lft */
+				/* jiffies - ifp->tstamp > age >= ifp->prefered_lft */
 				int deprecate = 0;
 
 				if (!(ifp->flags&IFA_F_DEPRECATED)) {
