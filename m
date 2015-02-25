From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 00/29] Phase 2 of fib_trie updates
Date: Tue, 24 Feb 2015 22:53:00 -0500 (EST)
Message-ID: <20150224.225300.107506639649235664.davem@davemloft.net>
References: <20150224202837.26106.87623.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: alexander.h.duyck@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53867 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751226AbbBYDxF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2015 22:53:05 -0500
In-Reply-To: <20150224202837.26106.87623.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@redhat.com>
Date: Tue, 24 Feb 2015 12:47:55 -0800

> This patch series implements the second phase of the fib_trie changes.  I
> presented on these and the previous changes at Netdev01 and netconf.  The
> slides for the Netdev01 presentation can be found at
> https://www.netdev01.org/docs/duyck-fib-trie.pdf.
> 
> I'm currently debating if I should just submit the entire patch-set as-is
> or if I should hold off on submitting the last 10 patches as they currently
> have a potential performance impact in the case of a large number of
> entries placed in the local table.  Specifically I have seen that removing
> an interface in the case of 8K local subnets being configured on it
> resulted in the time for a dummy interface being removed increasing from
> about .6 seconds to 2.4 seconds.  I am not sure how common of a use-case
> something like this would be.  I have not seen the same issue if I assign
> 8K routes to the interface as I believe the fib_table_flush aggregates them
> all in to one resize action.
> 
> The entire series reduces the total look-up time by another 20-35% versus
> what is currently in the 4.0-rc1 kernel.  So for example a set of routing
> look-ups which took 140ns in the 4.0-rc1 kernel will now only take about
> 105ns after these patches.

I did a quick once-over for these changes and conceptually they look
fine.

Why are sequences of removals so much more costly now?  Is it because
of the maintainence of the information in the parent when rebalancing?

In any event, I'll say two things:

1) You should submit these changes in smaller batches anyways.
   It's easier to review and get small sets of transformations
   tested as a unit.

2) For the device removal case, we can batch the inet addr removal
   based route delete operations, and thus mitigate the rebalancing
   costs.
