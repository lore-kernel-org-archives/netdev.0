From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [MM PATCH V4.1 5/6] slub: support for bulk free with SLUB
 freelists
Date: Mon, 5 Oct 2015 14:20:45 -0700
Message-ID: <20151005212045.GG26924@tassilo.jf.intel.com>
References: <560ABE86.9050508@gmail.com>
 <20150930114255.13505.2618.stgit@canyon>
 <20151001151015.c59a1360c7720a257f655578@linux-foundation.org>
 <20151002114118.75aae2f9@redhat.com>
 <20151002154039.69f82bdc@redhat.com>
 <20151002145044.781c911ea98e3ea74ae5cf3b@linux-foundation.org>
 <20151005212639.35932b6c@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	Christoph Lameter <cl@linux.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Pekka Enberg <penberg@kernel.org>, netdev@vger.kernel.org,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	David Rientjes <rientjes@google.com>,
	Hannes Frederic Sowa <hannes@redhat.com>,
	Arnaldo Carvalho de Melo <acme@redhat.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:23569 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751639AbbJEVUq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Oct 2015 17:20:46 -0400
Content-Disposition: inline
In-Reply-To: <20151005212639.35932b6c@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> My only problem left, is I want a perf measurement that pinpoint these
> kind of spots.  The difference in L1-icache-load-misses were significant
> (1,278,276 vs 2,719,158).  I tried to somehow perf record this with
> different perf events without being able to pinpoint the location (even
> though I know the spot now).  Even tried Andi's ocperf.py... maybe he
> will know what event I should try?

Run pmu-tools toplev.py -l3 with --show-sample. It tells you what the
bottle neck is and what to sample for if there is a suitable event and
even prints the command line.

https://github.com/andikleen/pmu-tools/wiki/toplev-manual#sampling-with-toplev

However frontend issues are difficult to sample, as they happen very far
away from instruction retirement where the sampling happens. So you may
have large skid and the sampling points may be far away. Skylake has new
special FRONTEND_* PEBS events for this, but before it was often difficult. 

BTW if your main goal is icache; I wrote a gcc patch to help the kernel
by enabling function splitting: Apply the patch in
https://gcc.gnu.org/bugzilla/show_bug.cgi?id=66890 to gcc 5,
make sure 9bebe9e5b0f (now in mainline) is applied and build with
-freorder-blocks-and-partition. That will split all functions into
statically predicted hot and cold parts and generally relieves
icache pressure. Any testing of this on your workload welcome.

-Andi
