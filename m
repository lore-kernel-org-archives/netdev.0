From: Calin Velea <vcalinus@gemenii.ro>
Subject: Disable hashing by source IP in rt_hash_code
Date: Fri, 8 Sep 2006 05:23:05 +0300
Message-ID: <264699482.20060908052305@gemenii.ro>
Reply-To: Calin Velea <vcalinus@gemenii.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.gemenii.ro ([195.28.184.8]:2506 "EHLO newmail.gemenii.ro")
	by vger.kernel.org with ESMTP id S1751924AbWIHCXR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Sep 2006 22:23:17 -0400
Received: from geolap.gemenii.ro (geolap.gemenii.ro [195.28.185.67])
	by newmail.gemenii.ro (8.13.6/8.13.4) with ESMTP id k882Xivs021383
	for <netdev@vger.kernel.org>; Fri, 8 Sep 2006 05:33:44 +0300
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello netdev,

  I am using a Linux system as a border router in an ISP
environment (2x3GHz Xeon 2MB Cache, 4GB RAM, Intel Server
PCI-X 133MHz cards, E7520 chipset). Kernel is vanilla 2.6.17.10
rhash_entries and max_size are set to 2.500.000
Conntrack/netfilter are disabled. I don't use policy
routing, I only need routing by destination IP.

  Recently we've had severe DDoS attacks from outside our network (over 350 kpps)
with completely random source addresses and random
destinations within our prefix ranges.
When this happens, the route cache fills up instantly,
the receiving CPU is almost 100% busy with allocating/freeing
route cache entries and packet loss and delay jump through the roof.
  I think that if only the destination IP was used when
hashing the dst_entry, the cache size (for packets coming
into our network) would be limited only by the total
number of possible destinations (arount a /16 subnet).
This won't protect against random dst DoS from within our
network but this is less common and easily traceable.


  After a quick look through linux/net/ipv4/route.c
I thought of an easy (but possibly wrong) way to eliminate
the source address contribution to the hash result: zero the saddr
parameter when calling jhash_2words to hash a dst_entry.

static unsigned int rt_hash_code(u32 daddr, u32 saddr)
{
-        return (jhash_2words(daddr, saddr, rt_hash_rnd)
+        return (jhash_2words(daddr, 0, rt_hash_rnd)
                & rt_hash_mask);
}

My questions are:

1. What could the above change break in the routing code?
(policy routing is disabled)

2. Wouldn't a configure option to disable hashing dst_entries
by source IP be useful? I think it would eliminate a lot of
DoS attacks against the routing code, even for systems
which don't do routing.








-- 
Best regards,
 Calin                          mailto:vcalinus@gemenii.ro

