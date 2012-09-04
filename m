From: Mathieu Desnoyers <mathieu.desnoyers-vg+e7yoeK/dWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v3 01/17] hashtable: introduce a small and naive
	hashtable
Date: Tue, 4 Sep 2012 12:32:20 -0400
Message-ID: <20120904163220.GA31698@Krystal>
References: <20120824212348.GK21325@google.com> <5038074D.300@gmail.com> <20120824230740.GN21325@google.com> <20120825042419.GA27240@Krystal> <503C95E4.3010000@gmail.com> <20120828101148.GA21683@Krystal> <503CAB1E.5010408@gmail.com> <20120828115638.GC23818@Krystal> <20120828230050.GA3337@Krystal> <1346772948.27919.9.camel@gandalf.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org,
	paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org,
	ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, aarcange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ericvh-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org,
	eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, neilb-l3A5Bk7waGM@public.gmane.org, ccaulfie-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	teigland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org,
	bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org, fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org,
	venkat.x.venkatsubra-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, ejt-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org, lw-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org
To: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1346772948.27919.9.camel-f9ZlEuEWxVcJvu8Pb33WZ0EMvNT87kid@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

* Steven Rostedt (rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org) wrote:
> On Tue, 2012-08-28 at 19:00 -0400, Mathieu Desnoyers wrote:
> 
> > Looking again at:
> > 
> > +#define hash_for_each_size(name, bits, bkt, node, obj, member)                 \
> > +       for (bkt = 0; bkt < HASH_SIZE(bits); bkt++)                             \
> > +               hlist_for_each_entry(obj, node, &name[bkt], member)
> > 
> > you will notice that a "break" or "continue" in the inner loop will not
> > affect the outer loop, which is certainly not what the programmer would
> > expect!
> > 
> > I advise strongly against creating such error-prone construct.
> > 
> 
> A few existing loop macros do this. But they require a do { } while ()
> approach, and all have a comment.
> 
> It's used by do_each_thread() in sched.h 

Yes. It's worth noting that it is a do_each_thread() /
while_each_thread() pair.


> and ftrace does this as well.
> Look at kernel/trace/ftrace.c at do_for_each_ftrace_rec().

Same here.

> 
> Yes it breaks 'break' but it does not break 'continue' as it would just
> go to the next item that would have been found (like a normal for
> would).

Good point.

So would changing hash_for_each_size() to a

do_each_hash_size()/while_each_hash_size() make it clearer that this
contains a double-loop ? (along with an appropriate comment about
break).

Thanks,

Mathieu

> 
> -- Steve
> 
> 

-- 
Mathieu Desnoyers
Operating System Efficiency R&D Consultant
EfficiOS Inc.
http://www.efficios.com
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
