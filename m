From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: POHMELFS high performance network filesystem. Transactions,
 failover, performance.
Date: Wed, 14 May 2008 01:01:01 -0700
Message-ID: <20080514010101.8ef541b3.akpm@linux-foundation.org>
References: <20080513174523.GA1677@2ka.mipt.ru>
	<20080513233341.47edea7f.akpm@linux-foundation.org>
	<20080514074028.GA28330@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:33282 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752231AbYENIOd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2008 04:14:33 -0400
In-Reply-To: <20080514074028.GA28330@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 14 May 2008 11:40:30 +0400 Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:

> Hi Andrew.
> 
> On Tue, May 13, 2008 at 11:33:41PM -0700, Andrew Morton (akpm@linux-foundation.org) wrote:
> > If any thread takes more than one kmap() at a time, it is deadlockable.
> > Because there is a finite pool of kmaps.  Everyone can end up holding
> > one or more kmaps, then waiting for someone else to release one.
> 
> It never takes the whole LAST_PKMAP maps. So the same can be applied to
> any user who kmaps at least one page - while user waits for free slot,
> it can be reused by someone else and so on.
> 
> But it can be speed issue, on 32 bit machine with 8gb of ram essentially
> all pages were highmem and required mapping, so this does slows things
> down (probably a lot), so I will extend writeback path of the POHMELFS
> not to kmap pages, but instead use ->sendpage(), which if needed will
> map page one-by-one. Current approach when page is mapped and then
> copied looks really beter since the only one sending function is used
> which takes lock only single time.

OK.

> > Duplicating page_waitqueue() is bad.  Exporting it is probably bad too.
> > Better would be to help us work out why the core kernel infrastructure is
> > unsuitable, then make it suitable.
> 
> When ->writepage() is used, it has to wait until page is written (remote
> side sent acknowledge), so if multiple pages are being written
> simultaneously we either have to allocate shared structure or use
> per-page wait.

That sounds exactly like wait_on_page_writeback()?

> Right now there are transactions (and they will be used
> for all operations eventually), so this waiting can go away.
> It is exactly the same logic which lock_page() uses.
>
> Will lock_page_killable()/__lock_page_killable() be exported to modules?

Maybe, if there's a need.  I see no particular problem with that.
