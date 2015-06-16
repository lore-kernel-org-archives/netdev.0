From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 7/7] slub: initial bulk free implementation
Date: Tue, 16 Jun 2015 17:52:31 +0200
Message-ID: <20150616175231.427499ae@redhat.com>
References: <20150615155053.18824.617.stgit@devil>
	<20150615155256.18824.42651.stgit@devil>
	<20150616072806.GC13125@js1304-P5Q-DELUXE>
	<20150616102110.55208fdd@redhat.com>
	<20150616105732.2bc37714@redhat.com>
	<CAAmzW4OM-afGBZbWZzcH7O-mivNWvyeKpMVV4Os+i4Xb7GPgmg@mail.gmail.com>
	<alpine.DEB.2.11.1506161008350.3496@east.gentwo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Joonsoo Kim <js1304@gmail.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Linux Memory Management List <linux-mm@kvack.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux-Netdev <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.duyck@gmail.com>, brouer@redhat.com
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34899 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756070AbbFPPwi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Jun 2015 11:52:38 -0400
In-Reply-To: <alpine.DEB.2.11.1506161008350.3496@east.gentwo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 16 Jun 2015 10:10:25 -0500 (CDT)
Christoph Lameter <cl@linux.com> wrote:

> On Tue, 16 Jun 2015, Joonsoo Kim wrote:
> 
> > So, in your test, most of objects may come from one or two slabs and your
> > algorithm is well optimized for this case. But, is this workload normal case?
> 
> It is normal if the objects were bulk allocated because SLUB ensures that
> all objects are first allocated from one page before moving to another.

Yes, exactly.  Maybe SLAB is different? If so, then we can handle that
in the SLAB specific bulk implementation.


> > If most of objects comes from many different slabs, bulk free API does
> > enabling/disabling interrupt very much so I guess it work worse than
> > just calling __kmem_cache_free_bulk(). Could you test this case?
> 
> In case of SLAB this would be an issue since the queueing mechanism
> destroys spatial locality. This is much less an issue for SLUB.

I think Kim is worried about the cost of the enable/disable calls, when
the slowpath gets called.  But it is not a problem because the cost of
local_irq_{disable,enable} is very low (total cost 7 cycles).

It is very important that everybody realizes that the save+restore
variant is very expensive, this is key:

CPU: i7-4790K CPU @ 4.00GHz
 * local_irq_{disable,enable}:  7 cycles(tsc) - 1.821 ns
 * local_irq_{save,restore}  : 37 cycles(tsc) - 9.443 ns

Even if EVERY object need to call slowpath/__slab_free() it will be
faster than calling the fallback.  Because I've demonstrated the call
this_cpu_cmpxchg_double() costs 9 cycles.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

p.s. for comparison[1] a function call cost is 5-6 cycles, and a function
pointer call cost is 6-10 cycles, depending on CPU.

[1] https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/lib/time_bench_sample.c
