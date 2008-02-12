From: David Miller <davem@davemloft.net>
Subject: [PATCH]: Remove IP_TOS privilege checks
Date: Mon, 11 Feb 2008 18:03:15 -0800 (PST)
Message-ID: <20080211.180315.71005060.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36666
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756823AbYBLCCn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2008 21:02:43 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 81FD0C8C1F2
	for <netdev@vger.kernel.org>; Mon, 11 Feb 2008 18:03:15 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I've committing the following upstream, for the reasons outlined in
the commit message.

These DSCP value meanings are advisory and the kernel is not the
entity to enforce what values mean.  This change makes us behave
consistently with BSD and with our own IPV6 implementation, yet
without breaking existing setups.

[IPV4]: Remove IP_TOS setting privilege checks.

Various RFCs have all sorts of things to say about the CS field of the
DSCP value.  In particular they try to make the distinction between
values that should be used by "user applications" and things like
routing daemons.

This seems to have influenced the CAP_NET_ADMIN check which exists for
IP_TOS socket option settings, but in fact it has an off-by-one error
so it wasn't allowing CS5 which is meant for "user applications" as
well.

Further adding to the inconsistency and brokenness here, IPV6 does not
validate the DSCP values specified for the IPV6_TCLASS socket option.

The real actual uses of these TOS values are system specific in the
final analysis, and these RFC recommendations are just that, "a
recommendation".  In fact the standards very purposefully use
"SHOULD" and "SHOULD NOT" when describing how these values can be
used.

In the final analysis the only clean way to provide consistency here
is to remove the CAP_NET_ADMIN check.  The alternatives just don't
work out:

1) If we add the CAP_NET_ADMIN check to ipv6, this can break existing
   setups.

2) If we just fix the off-by-one error in the class comparison in
   IPV4, certain DSCP values can be used in IPV6 but not IPV4 by
   default.  So people will just ask for a sysctl asking to
   override that.

I checked several other freely available kernel trees and they
do not make any privilege checks in this area like we do.  For
the BSD stacks, this goes back all the way to Stevens Volume 2
and beyond.

Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 754b0a5..de0572c 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -514,11 +514,6 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 			val &= ~3;
 			val |= inet->tos & 3;
 		}
-		if (IPTOS_PREC(val) >= IPTOS_PREC_CRITIC_ECP &&
-		    !capable(CAP_NET_ADMIN)) {
-			err = -EPERM;
-			break;
-		}
 		if (inet->tos != val) {
 			inet->tos = val;
 			sk->sk_priority = rt_tos2priority(val);
