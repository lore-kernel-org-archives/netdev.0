From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH linux-2.6 v2] IPv6: Create temporary address if none exists.
Date: Wed, 29 Sep 2010 10:43:16 -0400
Message-ID: <4CA35084.8010503@hp.com>
References: <20100927170430.GA7106@adams.ccsl.carleton.ca> <20100928.222510.71109554.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: gwurster@scs.carleton.ca, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	shemminger@vyatta.com, eric.dumazet@gmail.com,
	herbert@gondor.apana.org.au, ebiederm@xmission.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:29141 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752747Ab0I2On3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Sep 2010 10:43:29 -0400
In-Reply-To: <20100928.222510.71109554.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/29/2010 01:25 AM, David Miller wrote:
> From: Glenn Wurster <gwurster@scs.carleton.ca>
> Date: Mon, 27 Sep 2010 13:04:30 -0400
> 
>> If privacy extentions are enabled, but no current temporary address exists,
>> then create one when we get a router advertisement.
>>
>> Version 2, now with 100% fewer line wraps.  Thanks to David Miller for
>> pointing out the line wrapping issue.
>>
>> Signed-off-by: Glenn Wurster <gwurster@scs.carleton.ca>
> 
> The existing code is correct from what I can tell.
> 
> Variable "create" is true when "ifp == NULL" and "valid_lft != 0"
> 
> And RFC 3041 explicitly states in section 3.3:
> 
> 	When a new public address is created as described in [ADDRCONF]
> 	(because the prefix advertised does not match the prefix of any
> 	address already assigned to the interface, and Valid Lifetime
> 	in the option is not zero), also create a new temporary address.
> 
> Your patch is going to cause us to create a temporary address even
> when valid_lft is zero, which the RFC says we should not do.
> 
> That goes against what the RFC tells us to do, so I can only conclude
> that your patch is not correct.

I think this patch might actually be OK, I had to look at this more than
once to figure out the problem Glenn was trying to fix.  Maybe he can
confirm.

>From what I have found, this is fixing the case where we've changed
use_tempaddr to 1 on an interface that already has a "stable" IPv6
prefix.  In that case you'll never add a temporary address:

# ip -6 a s dev eth6
10: eth6: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qlen 1000
    inet6 2620:0:a09:e000:21f:29ff:fe59:faca/64 scope global dynamic 
       valid_lft 2591820sec preferred_lft 604620sec
    inet6 fe80::21f:29ff:fe59:faca/64 scope link 
       valid_lft forever preferred_lft forever

07:47:52.119051 IP6 fe80::205:9aff:fe3a:1871 > ip6-allnodes: ICMP6, router advertisement

# ip -6 a s dev eth6
10: eth6: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qlen 1000
    inet6 2620:0:a09:e000:21f:29ff:fe59:faca/64 scope global dynamic 
       valid_lft 2591996sec preferred_lft 604796sec
    inet6 fe80::21f:29ff:fe59:faca/64 scope link 
       valid_lft forever preferred_lft forever

No temp address :(

Since we're in the "if (ifp)" block, we can assume that at some point
in time we did get a valid advertisement to add this address, whether
is was right now or an hour ago doesn't matter.  Of course the RFCs
don't cover this case, they assume privacy settings were enabled at
boot time, if there's ever an update to 4941/3041 that should be
clarified.

Maybe the below (untested) patch is better?  Glenn, can you test this?

-Brian


---

If privacy extensions are enabled, but no current temporary address exists,
then create one when we get a router advertisement with a valid lifetime.

Signed-off-by: Brian Haley <brian.haley@hp.com>

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 8c88340..fb238d6 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1925,7 +1925,8 @@ ok:
 			update_lft = create = 1;
 			ifp->cstamp = jiffies;
 			addrconf_dad_start(ifp, RTF_ADDRCONF|RTF_PREFIX_RT);
-		}
+		} else if (list_empty(&in6_dev->tempaddr_list) && valid_lft)
+			create = 1;	/* use_tempaddr could have changed */
 
 		if (ifp) {
 			int flags;
