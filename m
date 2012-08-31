From: Bob Gilligan <gilligan@aristanetworks.com>
Subject: Re: [PATCH 1/2] ipv4: Improve the scaling of the ARP cache for multicast
 destinations.
Date: Fri, 31 Aug 2012 12:21:28 -0700
Message-ID: <50410EB8.3040603@aristanetworks.com>
References: <50400B68.3060302@aristanetworks.com> <20120830.210628.365120808137655227.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:36811 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754678Ab2HaTVb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2012 15:21:31 -0400
Received: by pbbrr13 with SMTP id rr13so5328714pbb.19
        for <netdev@vger.kernel.org>; Fri, 31 Aug 2012 12:21:31 -0700 (PDT)
In-Reply-To: <20120830.210628.365120808137655227.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/30/12 6:06 PM, David Miller wrote:
> From: Bob Gilligan <gilligan@aristanetworks.com>
> Date: Thu, 30 Aug 2012 17:55:04 -0700
> 
>> The mapping from multicast IPv4 address to MAC address can just as
>> easily be done at the time a packet is to be sent.  With this change,
>> we maintain one ARP cache entry for each interface that has at least
>> one multicast group member.  All routes to IPv4 multicast destinations
>> via a particular interface use the same ARP cache entry.  This entry
>> does not store the MAC address to use.  Instead, packets for multicast
>> destinations go to a new output function that maps the destination
>> IPv4 multicast address into the MAC address and forms the MAC header.
> 
> Doing an ARP MC mapping on every packet is much more expensive than
> doing a copy of the hard header cache.
> 
> I do not believe the memory consumption issue you use to justify this
> change is a real issue.
> 
> If you are talking to that many multicast groups actively, you do want
> that many neighbour cache entries.  This is not different from talking
> to nearly every IP address on a local /8 subnet.  You'll have a huge
> number of neighbour table entries in that case as well.
> 
> If your the actual steady state number of active groups being spoken
> to is smaller, you can tune the neighbour cache thresholds to collect
> old less used entries more quickly.
> 
> And this today is trivial, since routes no longer hold a reference
> to neighbour entries.  Therefore any neighbour entry whatsoever can
> be immediately reclaimed at any moment.

The scaling is N-squared: the number of neighbor cache entries
required for your multicast traffic is interfaces * groups.  100
interfaces and 100 groups could generate 10,000 entries. 1,000
interfaces and 1,000 groups could generate a million entries.

But the number of groups is hard to predict: it depends on the
applications in use and the multicast traffic they generate.  So, it
is hard to come up with a "budget" for multicast entries in the
neighbor cache for a multicast router.

If you pick a gc_thresh3 that is less than your working set, you'll
end up thrashing the neighbor cache.  And calls to neigh_forced_gc()
are expensive: It performs a linear search of the entire neighbor
cache.  Also, the calls to neigh_forced_gc() due to a large number of
multicast entries will negatively impact the unicast entries sharing the
neighbor cache: it will free any unreferenced but resolved unicast
entries. Any subsequent packets for those destinations will trigger a
re-ARP.  Unnecessary re-ARPing is generally undesirable in a router.

The user who wants to avoid these problems is left with the
alternative of setting gc_thresh3 to a very large number based on a
worst case estimate of the number of unicast plus multicast entries
required.

Seems just simpler and more efficient to keep the multicast entries
out of the neighbor cache entirely.

Bob.



> 
> I'm not fond of these patches, and adding yet more special cases to
> the neighbour layer, and therefore will not apply them.
> 
