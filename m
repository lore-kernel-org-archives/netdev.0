From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [patch][rfc] ddds: "dynamic dynamic data structure" algorithm,
	for adaptive dcache hash table sizing (resend)
Date: Tue, 7 Oct 2008 03:18:27 -0400
Message-ID: <20081007071827.GB5010@infradead.org>
References: <20081007064834.GA5959@wotan.suse.de> <20081007070225.GB5959@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux Memory Management List <linux-mm@kvack.org>,
	netdev@vger.kernel.org, Paul McKenney <paulmck@us.ibm.com>
To: Nick Piggin <npiggin@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:58856 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751488AbYJGHS3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2008 03:18:29 -0400
Content-Disposition: inline
In-Reply-To: <20081007070225.GB5959@wotan.suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 07, 2008 at 09:02:25AM +0200, Nick Piggin wrote:
> (resending with correct netdev address)
> 
> Hi,
> 
> I thought I should quickly bring this patch up to date and write it up
> properly, because IMO it is still useful. I earlier had tried to turn the
> algorithm into a library that could be plugged into with specific lookup
> functions and such, but that got really nasty and also difficult to retain
> a really light fastpath. I don't think it is too nasty to open-code it...
> 
> Describe the "Dynamic dynamic data structure" (DDDS) algorithm, and implement
> adaptive dcache hash table sizing using DDDS.
> 
> The dcache hash size is increased to the next power of 2 if the number
> of dentries exceeds the current size of the dcache hash table. It is decreased
> in size if it is currently more than 3 times the number of dentries.
> 
> This might be a dumb thing to do. It also currently performs the hash resizing
> check for each dentry insertion/deletion, and calls the resizing in-line from
> there: that's bad, because resizing takes several RCU grace periods. Rather it
> should kick off a thread to do the resizing, or even have a background worker
> thread checking the sizes periodically and resizing if required.
> 
> With this algorithm, I can fit a whole kernel source and git tree in my dcache
> hash table that is still 1/8th the size it would be before the patch.
> 
> I'm cc'ing netdev because Dave did express some interest in using this for
> some networking hashes, and network guys in general are pretty cluey when it
> comes to hashes and such ;)

Without even looking at the code I'd say geeting the dcache lookup data
structure as a hash is the main problem here.  Dcache lookup is
fundamentally a tree lookup, with some very nice domain splits
(superblocks or directories).  Mapping these back to a global hash is
a rather bad idea, not just for scalability purposes.

