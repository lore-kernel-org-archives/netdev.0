From: Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v3 01/17] hashtable: introduce a small and
	naive hashtable
Date: Sat, 25 Aug 2012 00:59:25 +0200
Message-ID: <5038074D.300@gmail.com>
References: <1345602432-27673-1-git-send-email-levinsasha928@gmail.com>
	<1345602432-27673-2-git-send-email-levinsasha928@gmail.com>
	<20120822180138.GA19212@google.com> <50357840.5020201@gmail.com>
	<20120823200456.GD14962@google.com> <5037DA47.9010306@gmail.com>
	<20120824195941.GC21325@google.com> <5037E00B.6090606@gmail.com>
	<20120824203332.GF21325@google.com> <5037E9D9.9000605@gmail.com>
	<20120824212348.GK21325@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, neilb-l3A5Bk7waGM@public.gmane.org, fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org, bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org,
	paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, aarcange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org,
	eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, venkat.x.venkatsubra-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org,
	ccaulfie-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org,
	ericvh-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org, rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org,
	mathieu.desnoyers-vg+e7yoeK/dWk0Htik3J/w@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ejt-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, lw-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, teigland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20120824212348.GK21325-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

>> Why do we need hash_head/hash_for_each_head()? I haven't stumbled on a place yet
>> that needed direct access to the bucket itself.
> 
> Because whole hash table walking is much less common and we can avoid
> another full set of iterators.

I don't agree. Out of 32 places which now use a hashtable iterator of some kind,
12 of them (38%) walk the entire table.

The thing is that usually data structures are indexable by more than one key, so
usually hashtables are fully walked in cold paths to look for different keys.

Take kernel/workqueue.c for example: There are 4 places which do a key lookup
(find_worker_executing_work()) and 3 places which fully walk the entire table
(for_each_busy_worker()).

>> This basically means 11 macros/functions that would let us have full
>> encapsulation and will make it very easy for future implementations to work with
>> this API instead of making up a new one. It's also not significantly (+~2-3)
>> more than the ones you listed.
> 
> I'm not sure whether full encapsulation is a good idea for trivial
> hashtable.  For higher level stuff, sure but at this level I think
> benefits coming from known obvious implementation can be larger.
> e.g. suppose the caller knows certain entries to be way colder than
> others and wants to put them at the end of the chain.

Thats the thing, the amount of things of things you can do with a given bucket
is very limited. You can't add entries to any point besides the head (without
walking the entire list).

Basically you can do only two things with a bucket:

 - Add something to it at a very specific place.
 - Walk it

So I don't understand whats the point in exposing the internal structure of the
hashtable if there's nothing significant that can be gained from it by the user.

> 
> So, I think implmenting the minimal set of helpers which reflect the
> underlying trivial implementation explicitly could actually be better
> even when discounting the reduced number of wrappers.
> 
> Thanks.
> 
