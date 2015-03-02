From: Vlastimil Babka <vbabka-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [patch v2 1/3] mm: remove GFP_THISNODE
Date: Mon, 02 Mar 2015 14:46:41 +0100
Message-ID: <54F469C1.9090601@suse.cz>
References: <alpine.DEB.2.10.1502251621010.10303@chino.kir.corp.google.com> <alpine.DEB.2.10.1502271415510.7225@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>,
	Pekka Enberg <penberg-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Joonsoo Kim <iamjoonsoo.kim-Hm3cg6mZ9cc@public.gmane.org>,
	Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>,
	Mel Gorman <mgorman-l3A5Bk7waGM@public.gmane.org>,
	Pravin Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>,
	Jarno Rajahalme <jrajahalme-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>,
	Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	Greg Thelen <gthelen-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
To: David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.DEB.2.10.1502271415510.7225-X6Q0R45D7oAcqpCFd4KODRPsWskHk0ljAL8bYrjMMd8@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 02/27/2015 11:16 PM, David Rientjes wrote:
> NOTE: this is not about __GFP_THISNODE, this is only about GFP_THISNODE.
>
> GFP_THISNODE is a secret combination of gfp bits that have different
> behavior than expected.  It is a combination of __GFP_THISNODE,
> __GFP_NORETRY, and __GFP_NOWARN and is special-cased in the page allocator
> slowpath to fail without trying reclaim even though it may be used in
> combination with __GFP_WAIT.
>
> An example of the problem this creates: commit e97ca8e5b864 ("mm: fix
> GFP_THISNODE callers and clarify") fixed up many users of GFP_THISNODE
> that really just wanted __GFP_THISNODE.  The problem doesn't end there,
> however, because even it was a no-op for alloc_misplaced_dst_page(),
> which also sets __GFP_NORETRY and __GFP_NOWARN, and
> migrate_misplaced_transhuge_page(), where __GFP_NORETRY and __GFP_NOWAIT
> is set in GFP_TRANSHUGE.  Converting GFP_THISNODE to __GFP_THISNODE is
> a no-op in these cases since the page allocator special-cases
> __GFP_THISNODE && __GFP_NORETRY && __GFP_NOWARN.
>
> It's time to just remove GFP_THISNODE entirely.  We leave __GFP_THISNODE
> to restrict an allocation to a local node, but remove GFP_THISNODE and
> its obscurity.  Instead, we require that a caller clear __GFP_WAIT if it
> wants to avoid reclaim.
>
> This allows the aforementioned functions to actually reclaim as they
> should.  It also enables any future callers that want to do
> __GFP_THISNODE but also __GFP_NORETRY && __GFP_NOWARN to reclaim.  The
> rule is simple: if you don't want to reclaim, then don't set __GFP_WAIT.
>
> Aside: ovs_flow_stats_update() really wants to avoid reclaim as well, so
> it is unchanged.
>
> Signed-off-by: David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

Acked-by: Vlastimil Babka <vbabka-AlSwsSmVLrQ@public.gmane.org>

So you've convinced me that this is a non-functional change for slab and 
a prerequisity for patch 2/3 which is the main point of this series for 
4.0. That said, the new 'goto nopage' condition is still triggered by a 
combination of flag states, and the less we have those, the better for 
us IMHO.

Looking at commit 952f3b51be which introduced this particular check 
using GFP_THISNODE, it seemed like it was a workaround to avoid 
triggering reclaim, without needing a new gfp flag. Nowadays, we have 
such flag called __GFP_NO_KSWAPD and as I explained in my reply to v1 
(where I missed the new condition), passing the flag would already 
prevent wake_all_kswapds() and treating the allocation as atomic in 
gfp_to_alloc_flags(). So the whole difference would be another 
get_page_from_freelist() attempt (possibly less constrained than the 
fast path one) and then bail out on !wait.

So it would be IMHO better for longer-term maintainability to have the 
relevant __GFP_THISNODE callers pass also __GFP_NO_KSWAPD to denote 
these opportunistic allocation attempts, instead of having this subtle 
semantic difference attached to __GFP_THISNODE && !__GFP_WAIT. It would 
be probably too risky for 4.0. On the other hand, I don't think even 
this series is really urgent. It's true that patch 2/3 fixes two 
commits, including a 4.0 one, but those commits are already not 
regressions without the fix. But maybe current -rcX is low enough to 
proceed with this series and catch any regressions in time, allowing the 
larger cleanups later.
