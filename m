From: Brian Haley <brian.haley@hp.com>
Subject: Re: linux kernel's IPV6_MULTICAST_HOPS default is 64; should be 1?
Date: Tue, 04 May 2010 10:40:58 -0400
Message-ID: <4BE031FA.6040006@hp.com>
References: <AANLkTimf-FWCsiLqYDGg4nl-relRMuNvDowfTKZbe9kx@mail.gmail.com>	<OF8BB88147.4F3756DA-ON88257719.002A895A-88257719.002AEB08@us.ibm.com> <20100504.005757.97355845.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, enh@google.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:1073 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932476Ab0EDOlJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 May 2010 10:41:09 -0400
In-Reply-To: <20100504.005757.97355845.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: David Stevens <dlstevens@us.ibm.com>
> Date: Tue, 4 May 2010 00:48:46 -0700
> 
>> It's set to -1 by default, but the common code for unicast and
>> multicast in getsockopt is falling through to use the dst_entry.
>>
>> I believe (though I haven't actually tried it recently) it actually
>> uses "1" for the default value for multicast;

No, on-the-wire it's actually 64.

> It doesn't, all of the uses in the ipv6 stack say something like:
> 
> 	if (multicast)
> 		hlimit = np->mcast_hops;
> 	else
> 		hlimit = np->hop_limit;
> 	if (hlimit < 0)
> 		hlimit = ip6_dst_hoplimit(dst);
> 
> Therefore, the change suggested by Elliot and which I committed is the
> way to get the correct behavior and fix this.

Not exactly.  It fixes the case where it's wrong by default, but
the corner case of setting it to -1 via setsockopt() says:

    x == -1:       use kernel default

But that will revert back to the kernel using 64 on the next transmit.
I can work on an update to this that makes a new mcast_hops per-interface
setting and makes ip6_dst_hoplimit() aware of it.  Or even easier, just
have setsockopt() trap the -1 and set np->mcast_hops to 1.  Built but
untested patch below.

-Brian

--


Specifying -1 for setsockopt(IPV6_MULTICAST_HOPS) should set the socket
value back to the system default value of IPV6_DEFAULT_MCASTHOPS (1).

Signed-off-by: Brian Haley <brian.haley@hp.com>

diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index bd43f01..fa6875b 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -486,7 +486,10 @@ done:
 			goto e_inval;
 		if (val > 255 || val < -1)
 			goto e_inval;
-		np->mcast_hops = val;
+		if (val == -1)
+			np->mcast_hops = IPV6_DEFAULT_MCASTHOPS;
+		else
+			np->mcast_hops = val;
 		retv = 0;
 		break;
 
