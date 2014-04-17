From: Simo Sorce <ssorce-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/2] net: Implement SO_PASSCGROUP to enable passing
 cgroup path
Date: Thu, 17 Apr 2014 15:10:17 -0400
Message-ID: <1397761817.2628.113.camel@willson.li.ssimo.org>
References: <CALCETrUrj2LtAoXp600BD2ANgE2UUEbTYQrK8hHqDR=qpeFPcg@mail.gmail.com>
	 <1397751853.2628.50.camel@willson.li.ssimo.org>
	 <CALCETrWNWvumFg9Qba0GEOjYop4WYe530tCPtakrhnoCrHqhUQ@mail.gmail.com>
	 <1397753323.2628.60.camel@willson.li.ssimo.org>
	 <CALCETrXj6kD3E+vsaWmkrSbaQYTu=c-Hsw640jh4O+FbojYk2g@mail.gmail.com>
	 <20140417171256.GB25334@redhat.com>
	 <CALCETrVq4HRpfWOAbZAQbyjuraQd=OxnW=WjSoe5JgBzRStiKg@mail.gmail.com>
	 <1397756025.2628.64.camel@willson.li.ssimo.org>
	 <CALCETrVBJFgKwRKBE2jAG6kiGgkJ+MyQiw2nyz5yj0h68kCk9A@mail.gmail.com>
	 <1397759013.2628.86.camel@willson.li.ssimo.org>
	 <20140417185023.GA32527@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Daniel J Walsh <dwalsh-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	lpoetter-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kay-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140417185023.GA32527-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2014-04-17 at 14:50 -0400, Vivek Goyal wrote:
> On Thu, Apr 17, 2014 at 02:23:33PM -0400, Simo Sorce wrote:
> > On Thu, 2014-04-17 at 10:35 -0700, Andy Lutomirski wrote:
> > > On Thu, Apr 17, 2014 at 10:33 AM, Simo Sorce <ssorce-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> > > > On Thu, 2014-04-17 at 10:26 -0700, Andy Lutomirski wrote:
> > > >>
> > > >> Not really.  write(2) can't send SCM_CGROUP.  Callers of sendmsg(2)
> > > >> who supply SCM_CGROUP are explicitly indicating that they want their
> > > >> cgroup associated with that message.  Callers of write(2) and send(2)
> > > >> are simply indicating that they have some bytes that they want to
> > > >> shove into whatever's at the other end of the fd.
> > > >
> > > > But there is no attack vector that passes by tricking setuid binaries to
> > > > write to pre-opened file descriptors on sendmsg(), and for the other
> > > > cases (connected socket) journald can always cross check with
> > > > SO_PEERCGROUP, so why do we care again ?
> > > 
> > > Because the proposed code does not do what I described, at least as
> > > far I as I can tell.
> > 
> > Ok let me backtrack, apparently if you explicitly use connect() on a
> > datagram socket then you *can* write() (thanks to Vivek for checking
> > this).
> > 
> > So you can trick something to write() to it but you can't do
> > SO_PEERCGROUP on the other side, because it is not really a connected
> > socket, the connection is only faked on the sender side by constructing
> > sendmsg() messages with the original address passed into connect().
> > 
> > So given this unfortunate circumstance, requiring the client to
> > explicitly pass cgroup data on unix datagram sockets may be an
> > acceptable request IMO.
> > 
> > Perhaps this could be done with a sendmsg() header flag or simplified
> > ancillary data even, rather than forcing the sender process to retrieve
> > and construct the whole information which is already available in
> > kernel.
> 
> So what would be the protocol here? When should somebody send an
> SCM_CGROUP message using sendmsg()?

Andy's point is that the sender application should explicitly decide to
send SCM_CGROUP data to the receiver, and if it doesn't do that then the
receiver will get no cgroup information at all even if it used
SO_PASSCGROUP to ask for it.

I am still not convinced that we should not allow to send the
information regardless, I think we should simply make it very clear that
there are ways this information may be used improperly so it shouldn't
be the unique factor in deciding anything.

After all, the receiving application can use SCM_CREDENTIALS to get the
pid and then try to check for the cgroup information in /proc, which is
terribly racy and expensive compared to unconditional SO_PASSCGROUP

For the log case, even faking cgroup information shouldn't be enough to
fool the logger, because it crosschecks information and takes in account
things like uids and pids.

Another option would be to allow unconditional SO_PASSCGROUP only if the
socket was opened (on the sender side) by a process with some explicit
privilege to do so ?  But I am not sure this really changes anything if
journald wants to use this mechanism on stderr.
And we are still talking about a hypothetical attack were a setuid
binary can be tricked to change its cgroup to another one chosen by the
attacker, and cause the same process to emit messages on stdout/stederr
in a format that does not give away something funny is going on, and
also counting on the fact that the logger will completely ignore that
the pid is different etc...

At this point I think journald people need to give a little bit more
details on how they plan to use SO_PASSCGROUP.

For my use cases I care only about streams and SO_PEERCGROUP that does
not have any of the (perceived) issues of SO_PASSCGROUP.

Simo.
