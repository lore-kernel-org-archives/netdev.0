From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: task_diag: add a new interface to get information about processes
Date: Wed, 4 May 2016 20:39:51 -0700
Message-ID: <CALCETrUEgb0MSJ+VP3BVk8LLKNqWb8Uc7nwxjs6OXbLbi7biPg@mail.gmail.com>
References: <20160504132245.1d04c131@xeon-e3> <CANaxB-w2RZ8WZ0ACP-3M9OJ0vgWRM0d74S2WAVwRRY=gXoR5Zg@mail.gmail.com>
 <20160504191436.7dfa3a55@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	"David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	Andrey Vagin <avagin@openvz.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f41.google.com ([209.85.218.41]:36630 "EHLO
	mail-oi0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755313AbcEEDkM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 23:40:12 -0400
Received: by mail-oi0-f41.google.com with SMTP id x201so89437806oif.3
        for <netdev@vger.kernel.org>; Wed, 04 May 2016 20:40:11 -0700 (PDT)
In-Reply-To: <20160504191436.7dfa3a55@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On May 4, 2016 7:14 PM, "Stephen Hemminger" <stephen@networkplumber.org=
> wrote:
>
> On Wed, 4 May 2016 15:34:21 -0700
> Andrey Vagin <avagin@openvz.org> wrote:
>
> > Hi Stephen,
> >
> > On Wed, May 4, 2016 at 1:22 PM, Stephen Hemminger
> > <stephen@networkplumber.org> wrote:
> > > I understand how reading /proc or /sys can be a bottleneck, but t=
his
> > > proposed method using a system call is the wrong way to do this.
> > >
> > > Why not use netlink like other systems do which allows a message
> > > based response which allows for future changes (no fixed datastru=
ctures),
> > > and is message based.
> > >
> > > Generic netlink has already been used by several other subsystems=
=2E
> >
> > I used netlink in two first versions of task_diag, but then Andy
> > convinced me that netlink interfaces are not ideal for this case. I
> > added him into C=D1=81.
> >
> > Here is a thread with our discussion about using netlink for
> > task_diag: https://lkml.org/lkml/2015/12/15/520
> > Can I ask you to read it and give your comments? It would be nice t=
o
> > find a way how to use netlink sockets instead of creating a new
> > interface.
> >
> > Thanks,
> > Andrew
>
> LKML is too busy, no one reads it anymore :-)
> Since this is netlink related you need to discuss it on netdev.
>
> The objection seems to be time or creation versus time of use and per=
missions.
> Netlink internally is not really message based all responses are gene=
rated
> in the context of the send().  You need credentials to create
> the socket, but the actual response will occur in the context of the =
calling
> process. I don't see how that is substantially different than a syste=
m call.
>
>

Linus, this is Yet Another Credential Fuckup, except that it hasn't
happened yet, so it's okay.  The tl;dr is that Andrey wants to add an
interface to ask a pidns some questions, and netlink looks natural,
except that using netlink sockets to interrogate a pidns seems rather
problematic.  I would also love to see a decent interface for
interrogating user namespaces, and again, netlink would be great,
except that it's a socket and makes no sense in this context.

Netlink had, and possibly still has, tons of serious security bugs
involving code checking send() callers' creds.  I found and fixed a
few a couple years ago.  To reiterate once again, send() CANNOT use
caller creds safely.  (I feel like I say this once every few weeks.
It's getting old.)

I realize that it's convenient to use a socket as a context to keep
state between syscalls, but it has some annoying side effects:

 - It makes people want to rely on send()'s caller's creds.

 - It's miserable in combination with seccomp.

 - It doesn't play nicely with namespaces.

 - It makes me wonder why things like task_diag, which have nothing to
do with networking, seem to get tangled up with networking.


Would it be worth considering adding a parallel interface, using it
for new things, and slowly migrating old use cases over?

int issue_kernel_command(int ns, int command, const struct iovec *iov,
int iovcnt, int flags);

ns is an actual namespace fd or:

KERNEL_COMMAND_CURRENT_NETNS
KERNEL_COMMAND_CURRENT_PIDNS
etc, or a special one:
KERNEL_COMMAND_GLOBAL.  KERNEL_COMMAND_GLOBAL can't be used in a
non-root namespace.

KERNEL_COMMAND_GLOBAL works even for namespaced things, if the
relevant current ns is the init namespace.  (This feature is optional,
but it would allow gradually namespacing global things.)

command is an enumerated command.  Each command implies a namespace
type, and, if you feed this thing the wrong namespace type, you get
EINVAL.  The high bit of command indicates whether it's read-only
command.

iov gives a command in the format expected, which, for the most part,
would be a netlink message.

The return value is an fd that you can call read/readv on to read the
response.  It's not a socket (or at least you can't do normal socket
operations on it if it is a socket behind the scenes).  The
implementation of read() promises *not* to look at caller creds.  The
returned fd is unconditionally cloexec -- it's 2016 already.  Sheesh.

When you've read all the data, all you can do is close the fd.  You
can't issue another command on the same fd.  You also can't call
write() or send() on the fd unless someone has a good reason why you
should be able to and why it's safe.  You can't issue another command
on the same fd.


I imagine that the implementation could re-use a bunch of netlink code
under the hood.


--Andy
