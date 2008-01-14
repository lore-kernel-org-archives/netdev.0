From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: [PATCH 9/9] fix sparse warnings
Date: Mon, 14 Jan 2008 12:07:04 +0100
Message-ID: <18315.16984.456053.250600@robur.slu.se>
References: <20080112064513.803976049@linux-foundation.org>
	<20080112064646.659443238@linux-foundation.org>
	<4788A17D.5070903@cosmosbay.com>
	<20080112130824.54cc1fc3@deepthought>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	David Miller <davem@davemloft.net>,
	Robert Olsson <robert.olsson@its.uu.se>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.slu.se ([130.238.96.70]:58809 "EHLO mx1.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756250AbYANLHm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jan 2008 06:07:42 -0500
In-Reply-To: <20080112130824.54cc1fc3@deepthought>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Thanks for hacking and improving and the trie... another idea that could
be also tested. If we look into routing table we see that most leafs 
only has one prefix

Main:
        Aver depth:     2.57
        Max depth:      7
        Leaves:         231173

ip route | wc -l 
241649

Thats 231173/241649 = 96% with the current Internet routing.

How about if would have a fastpath and store one entry direct in the 
leaf struct this to avoid loading the leaf_info list in most cases?

One could believe that both lookup and dump could improve.

Cheers.
					--ro



Stephen Hemminger writes:

 > Remember that the code should be optimized for lookup, not management
 > operations. We ran into this during testing (the test suite was looking
 > for number of routes), thats why I put in the size field.
 > 
 > The existing dump code is really slow:
 > 
 > 1) FIB_TRIE   Under KVM:
 >      load 164393 routes		12.436 sec
 >      ip route | wc -l		12.569 sec
 >      grep /proc/net/route	25.357 sec
 > 
 > 99% of the cpu time is spent in nextleaf() during these dump operations.
 > 
 > 2) FIB_HASH 	Under KVM:
 >      load 164393 routes		10.833 sec
 >      ip route | wc -l		1.981 sec
 >      grep /proc/net/route	0.204 sec
