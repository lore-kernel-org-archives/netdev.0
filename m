From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: POHMELFS high performance network filesystem. Transactions, failover, performance.
Date: Wed, 14 May 2008 11:40:30 +0400
Message-ID: <20080514074028.GA28330@2ka.mipt.ru>
References: <20080513174523.GA1677@2ka.mipt.ru> <20080513233341.47edea7f.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:55130 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752902AbYENHlF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 May 2008 03:41:05 -0400
Content-Disposition: inline
In-Reply-To: <20080513233341.47edea7f.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew.

On Tue, May 13, 2008 at 11:33:41PM -0700, Andrew Morton (akpm@linux-foundation.org) wrote:
> If any thread takes more than one kmap() at a time, it is deadlockable.
> Because there is a finite pool of kmaps.  Everyone can end up holding
> one or more kmaps, then waiting for someone else to release one.

It never takes the whole LAST_PKMAP maps. So the same can be applied to
any user who kmaps at least one page - while user waits for free slot,
it can be reused by someone else and so on.

But it can be speed issue, on 32 bit machine with 8gb of ram essentially
all pages were highmem and required mapping, so this does slows things
down (probably a lot), so I will extend writeback path of the POHMELFS
not to kmap pages, but instead use ->sendpage(), which if needed will
map page one-by-one. Current approach when page is mapped and then
copied looks really beter since the only one sending function is used
which takes lock only single time.

> Duplicating page_waitqueue() is bad.  Exporting it is probably bad too.
> Better would be to help us work out why the core kernel infrastructure is
> unsuitable, then make it suitable.

When ->writepage() is used, it has to wait until page is written (remote
side sent acknowledge), so if multiple pages are being written
simultaneously we either have to allocate shared structure or use
per-page wait. Right now there are transactions (and they will be used
for all operations eventually), so this waiting can go away.
It is exactly the same logic which lock_page() uses.

Will lock_page_killable()/__lock_page_killable() be exported to modules?

-- 
	Evgeniy Polyakov
