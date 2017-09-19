From: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: RFC: Audit Kernel Container IDs
Date: Tue, 19 Sep 2017 00:15:05 -0400
Message-ID: <20170919041505.GQ3405@madcap2.tricolour.ca>
References: <20170913171328.GP3405@madcap2.tricolour.ca>
 <87d16tb2y5.fsf@xmission.com>
 <20170914180704.GU3405@madcap2.tricolour.ca>
 <87wp4v76f4.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
        Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Audit <linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Linux FS Devel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Aristeu Rozanski <arozansk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Eric Paris <eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org>, jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        Paul Moore <pmoore-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>,
        Steve Grubb <sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, trondmy-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org,
        Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87wp4v76f4.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 2017-09-18 21:45, Eric W. Biederman wrote:
> Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:
> 
> > On 2017-09-14 12:33, Eric W. Biederman wrote:
> >> Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:
> >> 
> >> > The trigger is a pseudo filesystem (proc, since PID tree already exists)
> >> > write of a u64 representing the container ID to a file representing a
> >> > process that will become the first process in a new container.
> >> > This might place restrictions on mount namespaces required to define a
> >> > container, or at least careful checking of namespaces in the kernel to
> >> > verify permissions of the orchestrator so it can't change its own
> >> > container ID.
> >> 
> >> Why a u64?
> >
> > u32 will roll too quickly.  UUID is large enough that it adds
> > significantly to audit record bandwidth.  I'd prefer u64, but can look
> > at the difference of accommodating a UUID...
> 
> I was imagining a string might be better.  As for the purposes of audit
> it is just a byte string you regurgitate.

Yes, so looking at u128 vs dhowells' proposal, it would be 16 bytes vs
24 bytes, which really isn't that much difference...

What length of string length were you envisioning?

> >> Why a proc filesystem write and not a magic audit message?
> >
> > A magic audit message requires CAP_AUDIT_WRITE, which we'd like to use
> > sparingly.  Given that orchestrators will already require it to send
> > the mandatory AUDIT_VIRT_*, this doesn't seem like an unreasonable burden.
> >
> > I was originally leaning towards an audit message trigger or a syscall.
> >
> >> I don't like the fact that the proc filesystem entry is likely going to
> >> be readable and abusable by non-audit contexts?
> >
> > This proposal wasn't going to start with that link being readable, but
> > its filesystem structure and link names would be, perhaps giving away
> > too much already.
> >
> > I think we will need to find a way for the orchestrator or one of its
> > authorized agents to read this information while blocking reads from
> > unauthorized agents, otherwise this would be of very limited use.
> 
> Something that is set only for future audit messages seems reasonable.
> Once you start reading this from something other than audit messages I
> get neverous, that people will use this beyond audit for things it is
> not intended for.

Understandably.  At the same time, if we implement something that is
more broadly useful and solves a number of other challenges others are
facing, how can we make it available while limiting the potential for
abuse?

> >> Why the ability to change the containerid?  What is the use case you are
> >> thinking of there?
> >
> > This was covered in the end of the conversation with Paul Moore (that
> > maybe you got tired reading?)
> 
> I have not had time to review everything.  As I was busy preparing for my
> wedding and am now in the middle of my honeymoon.

I'm very sorry, my bad!  You had given me a heads up about this and I
appologise for causing a stir during your special time.

> > I'd originally proposed having it write
> > once, but Paul figured there was no good reason to restrict it and leave
> > that decision up to the orchestrator.  The use case would be adding
> > other processes to a container, but it could be argued all additional
> > processes should be spawned by the first process in a container.
> 
> I see two cases here:
> a) Nested containers
> b) Inject processes via something like nsenter into a container.
> 
> In case a) you have to figure out what to do with nested containers
> and that does seem to be a legitimate case for a double write.  Arguably
> with the restriction that you must specify a more nested label.

Is this technically a double write if it is an inheritance?  That should
be solvable with a flag.

> In case b) which you seem to be referring to it would be a process
> created by the container manager outside the container that has no
> container label.  At which point there is not a need for a double write.

Looking at the potential for nesting, if the orchestrator is already in
a container, then it would already have a label, but if we refer to the
flag solution above, then it is still the first write.

> So my recommendation is to not support double writes until you support
> nested containers.

I think this is a reasonable restriction.

Thanks for your time.  Sorry to disturb your holiday.

> Eric

- RGB

--
Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sr. S/W Engineer, Kernel Security, Base Operating Systems
Remote, Ottawa, Red Hat Canada
IRC: rgb, SunRaycer
Voice: +1.647.777.2635, Internal: (81) 32635
