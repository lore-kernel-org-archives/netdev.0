From: Robin Holt <holt@sgi.com>
Subject: Re: [RFC] Limit the size of the IPV4 route hash.
Date: Fri, 10 Dec 2004 15:00:06 -0600
Message-ID: <20041210210006.GB23222@lnx-holt.americas.sgi.com>
References: <20041210190025.GA21116@lnx-holt.americas.sgi.com> <20041210114829.034e02eb.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Robin Holt <holt@sgi.com>, yoshfuji@linux-ipv6.org, akpm@osdl.org,
	hirofumi@parknet.co.jp, torvalds@osdl.org, dipankar@ibm.com,
	laforge@gnumonks.org, bunk@stusta.de, herbert@apana.org.au,
	paulmck@ibm.com, netdev@oss.sgi.com, linux-kernel@vger.kernel.org,
	gnb@sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261158AbULJVBF@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041210114829.034e02eb.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> 
> I can definitely say that just forcing it to use 1 page is wrong.
> Even ignoring your tests, your test was on a system that has 16K
> PAGE_SIZE.  Other systems use 4K and 8K (and other) PAGE_SIZE
> values.  This is why we make our calculations relative to PAGE_SHIFT.

I picked 1 page because it was not some magic small number that I would
need to justify.  I also hoped that it would incite someone to respond.

> 
> Also, 1 page even in your case is (assuming you are on a 64-bit platform,
> you didn't mention) going to give us 1024 hash chains.  A reasonably
> busy web server will easily be talking to more than 1K unique hosts at
> a given point in time.  This is especially true as slow long distance
> connections bunch up.

But 1k hosts is not the limit with a 16k page.  There are 1k buckets,
but each is a list.  A reasonably well designed hash will scale to greater
than one item per bucket.  Additionally, for the small percentage of web
servers with enough network traffic that they will be affected by the
depth of the entries, they can set rhash_entries for their specific needs.

> 
> Alexey Kuznetsov needed to use more than one page on his lowly
> i386 router in Russia, and this was circa 7 or 8 years ago.

And now he, for his special case, could set rhash_entries to increase
the size.

I realize I have a special case which highlighted the problem.  My case
shows that not putting an upper limit or at least a drastically aggressive
non-linear growth cap does cause issues.  For the really large system,
we were seeing a size of 512MB for the hash which was limited because
that was the largest amount of memory available on a single node.  I can
not ever imagine this being a reasonable limit.  Not with 512 cpus and
1024 network adapters could I envision that this level of hashing would
actually be advantageous given all the other lock contention that will
be seen.

Can we agree that a linear calculation based on num_physpages is probably
not the best algorithm.  If so, should we make it a linear to a limit or
a logarithmically decreasing size to a limit?  How do we determine that
limit point?
