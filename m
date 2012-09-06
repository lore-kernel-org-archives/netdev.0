From: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
Subject: Re: [PATCH v3 01/17] hashtable: introduce a small and naive
 hashtable
Date: Thu, 06 Sep 2012 12:00:06 -0400
Message-ID: <1346947206.1680.36.camel@gandalf.local.home>
References: <503C95E4.3010000@gmail.com> <20120828101148.GA21683@Krystal>
	 <503CAB1E.5010408@gmail.com> <20120828115638.GC23818@Krystal>
	 <20120828230050.GA3337@Krystal>
	 <1346772948.27919.9.camel@gandalf.local.home> <50462C99.5000007@redhat.com>
	 <50462EE8.1090903@redhat.com> <20120904170138.GB31934@Krystal>
	 <5048AAF6.5090101@gmail.com> <20120906145545.GA17332@leaf>
	 <5048C615.4070204@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Josh Triplett <josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org>,
	Mathieu Desnoyers <mathieu.desnoyers-vg+e7yoeK/dWk0Htik3J/w@public.gmane.org>,
	Pedro Alves <palves-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org,
	paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org,
	ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, aarcange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ericvh-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org,
	agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, neilb-l3A5Bk7waGM@public.gmane.org,
	ccaulfie-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, teigland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org, bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org,
	fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org,
	venkat.x.venkatsubra-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, ejt-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org, lw-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org
To: Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5048C615.4070204-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-09-06 at 17:49 +0200, Sasha Levin wrote:
>  
> > Looks reasonable.  However, it would break (or rather, not break) on
> > code like this:
> > 
> > 	hash_for_each_entry(...) {
> > 		if (...) {
> > 			foo(node);
> > 			node = NULL;

ug, I didn't even notice this. Ignore my last email :-p

/me needs to wake-up a bit more.

> > 			break;
> > 		}
> > 	}
> > 
> > Hiding the double loop still seems error-prone.
> 
> I think that that code doesn't make sense. The users of hlist_for_each_* aren't
> supposed to be changing the loop cursor.

I totally agree. Modifying the 'node' pointer is just asking for issues.
Yes that is error prone, but not due to the double loop. It's due to the
modifying of the node pointer that is used internally by the loop
counter. Don't do that :-)


> 
> We have three options here:
> 
>  1. Stuff everything into a single for(). While not too difficult, it will make
> the readability of the code difficult as it will force us to abandon using
> hlist_for_each_* macros.
> 
>  2. Over-complicate everything, and check for 'node == NULL && obj &&
> obj->member.next == NULL' instead. That one will fail only if the user has
> specifically set the object as the last object in the list and the node as NULL.
> 
>  3. Use 2 loops which might not work properly if the user does something odd,
> with a big fat warning above them.
> 
> 
> To sum it up, I'd rather go with 3 and let anyone who does things he shouldn't
> be doing break.

I agree, the double loop itself is not error prone. If you are modifying
'node' you had better know what the hell you are doing.

Actually, it may be something that is legitimate. That is, if you want
to skip to the next bucket, just set node to NULL and do the break (as
Josh had done). This would break if the macro loop changed later on, but
hey, like I said, it's error prone ;-) If you really want to do that,
then hand coding the double loop would be a better bet. IOW, don't use
the macro loop.

-- Steve


--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
