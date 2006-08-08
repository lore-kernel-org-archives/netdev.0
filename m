From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] limit rt cache size
Date: Mon, 07 Aug 2006 23:18:34 -0700 (PDT)
Message-ID: <20060807.231834.48498773.davem@davemloft.net>
References: <20060807164842.GA3412@ms2.inr.ac.ru>
	<20060807.204214.68039839.davem@davemloft.net>
	<200608080711.06788.ak@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, dev@sw.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:46784
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751232AbWHHGSc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 02:18:32 -0400
To: ak@suse.de
In-Reply-To: <200608080711.06788.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <ak@suse.de>
Date: Tue, 8 Aug 2006 07:11:06 +0200

> The hash sizing code needs far more tweaks. iirc it can still
> allocate several GB hash tables on large memory systems (i've seen
> that once in the boot log of a 2TB system).  Even on smaller systems
> it is usually too much.

There is already a limit parameter to alloc_large_system_hash(), the
fact that the routing cache passes in zero (which causes the limit to
be 1/16 of all system memory) is just a bug. :-)

In passing this immediately this suggests a fix to alloc_large_system_hash,
in that when limit is given as 0, it should follow the same rules for
HASH_HIGHME which are applied to the "scale" arg.  It currently goes:

	if (max == 0) {
		max = ((unsigned long long)nr_all_pages << PAGE_SHIFT) >> 4;
		do_div(max, bucketsize);
	}

Whereas it should probably go:

	if (max == 0) {
		max = (flags & HASH_HIGHMEM) ? nr_all_pages : nr_kernel_pages;
		max = (max << PAGE_SHIFT) >> 4;
		do_div(max, bucketsize);
	}

or something like that.

