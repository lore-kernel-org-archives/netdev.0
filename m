From: Pekka Enberg <penberg@cs.helsinki.fi>
Subject: Re: Mainline kernel OLTP performance update
Date: Fri, 23 Jan 2009 10:06:38 +0200
Message-ID: <1232697998.6094.17.camel@penberg-laptop>
References: <BC02C49EEB98354DBA7F5DD76F2A9E800317003CB0@azsmsx501.amr.corp.intel.com>
	 <200901161503.13730.nickpiggin@yahoo.com.au>
	 <20090115201210.ca1a9542.akpm@linux-foundation.org>
	 <200901161746.25205.nickpiggin@yahoo.com.au>
	 <20090116065546.GJ31013@parisc-linux.org>
	 <1232092430.11429.52.camel@ymzhang>  <87sknjeemn.fsf@basil.nowhere.org>
	 <1232428583.11429.83.camel@ymzhang>
	 <alpine.DEB.1.10.0901211852060.18367@qirst.com>
	 <1232613395.11429.122.camel@ymzhang>
	 <1232615707.14549.6.camel@penberg-laptop>
	 <1232616517.11429.129.camel@ymzhang>
	 <1232617672.14549.25.camel@penberg-laptop>
	 <1232679773.11429.155.camel@ymzhang>  <4979692B.3050703@cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Cc: Christoph Lameter <cl@linux-foundation.org>,
	Andi Kleen <andi@firstfloor.org>,
	Matthew Wilcox <matthew@wil.cx>,
	Nick Piggin <nickpiggin@yahoo.com.au>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, sfr@canb.auug.org.au,
	matthew.r.wilcox@intel.com, chinang.ma@intel.com,
	linux-kernel@vger.kernel.org, sharad.c.tripathi@intel.com,
	arjan@linux.intel.com, suresh.b.siddha@intel.com,
	harita.chilukuri@intel.com, douglas.w.styner@intel.com,
	peter.xihong.wang@intel.com, hubert.nueckel@intel.com,
	chris.mason@oracle.com, srostedt@redhat.com,
	linux-scsi@vger.kernel.org, andrew.vasquez@qlogic.com,
	anirban.chakraborty@qlogic.com, mingo@elte.hu
To: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:39632 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750798AbZAWIGl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2009 03:06:41 -0500
In-Reply-To: <4979692B.3050703@cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-01-23 at 08:52 +0200, Pekka Enberg wrote:
> > 1) If I start CPU_NUM clients and servers, SLUB's result is about 2% better than SLQB's;
> > 2) If I start 1 clinet and 1 server, and bind them to different physical cpu, SLQB's result
> > is about 10% better than SLUB's.
> > 
> > I don't know why there is still 10% difference with item 2). Maybe cachemiss causes it?
> 
> Maybe we can use the perfstat and/or kerneltop utilities of the new perf 
> counters patch to diagnose this:
> 
> http://lkml.org/lkml/2009/1/21/273
> 
> And do oprofile, of course. Thanks!

I assume binding the client and the server to different physical CPUs
also  means that the SKB is always allocated on CPU 1 and freed on CPU
2? If so, we will be taking the __slab_free() slow path all the time on
kfree() which will cause cache effects, no doubt.

But there's another potential performance hit we're taking because the
object size of the cache is so big. As allocations from CPU 1 keep
coming in, we need to allocate new pages and unfreeze the per-cpu page.
That in turn causes __slab_free() to be more eager to discard the slab
(see the PageSlubFrozen check there).

So before going for cache profiling, I'd really like to see an oprofile
report. I suspect we're still going to see much more page allocator
activity there than with SLAB or SLQB which is why we're still behaving
so badly here.

		Pekka

