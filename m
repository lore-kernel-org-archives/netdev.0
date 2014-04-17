From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH 2/2] net: Implement SO_PASSCGROUP to enable passing cgroup path
Date: Thu, 17 Apr 2014 12:19:34 -0700
Message-ID: <CALCETrW4nyeWC6Vq16fABJZ5ZWOFPukBuc09tU5vBypYdtrpfQ@mail.gmail.com>
References: <1397751853.2628.50.camel@willson.li.ssimo.org>
 <CALCETrWNWvumFg9Qba0GEOjYop4WYe530tCPtakrhnoCrHqhUQ@mail.gmail.com>
 <1397753323.2628.60.camel@willson.li.ssimo.org> <CALCETrXj6kD3E+vsaWmkrSbaQYTu=c-Hsw640jh4O+FbojYk2g@mail.gmail.com>
 <20140417171256.GB25334@redhat.com> <CALCETrVq4HRpfWOAbZAQbyjuraQd=OxnW=WjSoe5JgBzRStiKg@mail.gmail.com>
 <1397756025.2628.64.camel@willson.li.ssimo.org> <CALCETrVBJFgKwRKBE2jAG6kiGgkJ+MyQiw2nyz5yj0h68kCk9A@mail.gmail.com>
 <1397759013.2628.86.camel@willson.li.ssimo.org> <20140417185023.GA32527@redhat.com>
 <20140417185742.GB32527@redhat.com> <CALCETrXJPJeGBdauQS_WR5FNaZXR=05NjNKuC6r0xFORt+eaJQ@mail.gmail.com>
 <1397762143.2628.118.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Vivek Goyal <vgoyal@redhat.com>,
	Daniel J Walsh <dwalsh@redhat.com>,
	David Miller <davem@davemloft.net>, Tejun Heo <tj@kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	lpoetter@redhat.com, cgroups@vger.kernel.org, kay@redhat.com,
	Network Development <netdev@vger.kernel.org>
To: Simo Sorce <ssorce@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1397762143.2628.118.camel@willson.li.ssimo.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 17, 2014 at 12:15 PM, Simo Sorce <ssorce@redhat.com> wrote:
> On Thu, 2014-04-17 at 12:06 -0700, Andy Lutomirski wrote:
>> On Thu, Apr 17, 2014 at 11:57 AM, Vivek Goyal <vgoyal@redhat.com> wrote:
>> > On Thu, Apr 17, 2014 at 02:50:23PM -0400, Vivek Goyal wrote:
>> >> On Thu, Apr 17, 2014 at 02:23:33PM -0400, Simo Sorce wrote:
>> >> > On Thu, 2014-04-17 at 10:35 -0700, Andy Lutomirski wrote:
>> >> > > On Thu, Apr 17, 2014 at 10:33 AM, Simo Sorce <ssorce@redhat.com> wrote:
>> >> > > > On Thu, 2014-04-17 at 10:26 -0700, Andy Lutomirski wrote:
>> >> > > >>
>> >> > > >> Not really.  write(2) can't send SCM_CGROUP.  Callers of sendmsg(2)
>> >> > > >> who supply SCM_CGROUP are explicitly indicating that they want their
>> >> > > >> cgroup associated with that message.  Callers of write(2) and send(2)
>> >> > > >> are simply indicating that they have some bytes that they want to
>> >> > > >> shove into whatever's at the other end of the fd.
>> >> > > >
>> >> > > > But there is no attack vector that passes by tricking setuid binaries to
>> >> > > > write to pre-opened file descriptors on sendmsg(), and for the other
>> >> > > > cases (connected socket) journald can always cross check with
>> >> > > > SO_PEERCGROUP, so why do we care again ?
>> >> > >
>> >> > > Because the proposed code does not do what I described, at least as
>> >> > > far I as I can tell.
>> >> >
>> >> > Ok let me backtrack, apparently if you explicitly use connect() on a
>> >> > datagram socket then you *can* write() (thanks to Vivek for checking
>> >> > this).
>> >> >
>> >> > So you can trick something to write() to it but you can't do
>> >> > SO_PEERCGROUP on the other side, because it is not really a connected
>> >> > socket, the connection is only faked on the sender side by constructing
>> >> > sendmsg() messages with the original address passed into connect().
>> >> >
>> >> > So given this unfortunate circumstance, requiring the client to
>> >> > explicitly pass cgroup data on unix datagram sockets may be an
>> >> > acceptable request IMO.
>> >> >
>> >> > Perhaps this could be done with a sendmsg() header flag or simplified
>> >> > ancillary data even, rather than forcing the sender process to retrieve
>> >> > and construct the whole information which is already available in
>> >> > kernel.
>> >>
>> >> So what would be the protocol here? When should somebody send an
>> >> SCM_CGROUP message using sendmsg()?
>> >
>> > I don't know how it will even be used for systemd logging case. systemd
>> > provides various ways to connect stdout of services. So say a service's
>> > stdout is connected to a connected datagram socket and all printf()
>> > messages to stdout are being logged by receiver in journal. Now how
>> > would sender know that it is supposed to send SCM_CGROUP? One needs
>> > to modify printf() now?
>>
>> Does connecting stdout to a datagram socket really work well?  The
>> systemd function connect_logger_as looks like it's using stream
>> sockets, one per service, connected to /run/systemd/journal/stdout.
>> There's some rather strange logic in journald to authenticate the
>> thing that connects (using SO_PEERCRED!), but I don't see why this
>> code would even want to use SCM_CGROUP.
>>
>> IOW, write(2) issues notwithstanding, I'm still wondering what the use
>> case for this whole thing is.
>
> I "think" the use case is to aggregate all the logs that belong to a
> specific service by using a cgroup name, then, as long as children do
> not close stdout/stderr anything they emit would be captured and
> properly filed with the rest of the logs from the other process of the
> same control group, which has been made to mean "the service".

Would it be worth asking the people who actually intend to use this
thing to comment, then?  As far as I can tell, journald already does
this by using one socket per service.

>
> I also "think" using datagram sockets may be an attempt to reduce the
> number of sockets that need to be kept open and polled on the receiving
> side.

I think this can be done today with recvfrom.  At service creation
time, systemd creates a new datagram socket, connects it, calls
getsockname, and records that somewhere.

The downside is that there is no notification that your peer is gone.
There's also no notification that a cgroup is gone, so that part makes
little difference.

--Andy
