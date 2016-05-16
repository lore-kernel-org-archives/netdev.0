From: Andrew Vagin <avagin@virtuozzo.com>
Subject: Re: task_diag: add a new interface to get information about processes
Date: Mon, 16 May 2016 15:29:17 -0700
Message-ID: <20160516222916.GC25638@outlook.office365.com>
References: <20160504132245.1d04c131@xeon-e3>
 <CANaxB-w2RZ8WZ0ACP-3M9OJ0vgWRM0d74S2WAVwRRY=gXoR5Zg@mail.gmail.com>
 <20160504191436.7dfa3a55@xeon-e3>
 <CALCETrUEgb0MSJ+VP3BVk8LLKNqWb8Uc7nwxjs6OXbLbi7biPg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="koi8-r"
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	"David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	Andrey Vagin <avagin@openvz.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0109.outbound.protection.outlook.com ([157.56.112.109]:35450
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751587AbcEPWo5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 May 2016 18:44:57 -0400
Content-Disposition: inline
In-Reply-To: <CALCETrUEgb0MSJ+VP3BVk8LLKNqWb8Uc7nwxjs6OXbLbi7biPg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 04, 2016 at 08:39:51PM -0700, Andy Lutomirski wrote:
> 
> Linus, this is Yet Another Credential Fuckup, except that it hasn't
> happened yet, so it's okay.  The tl;dr is that Andrey wants to add an
> interface to ask a pidns some questions, and netlink looks natural,
> except that using netlink sockets to interrogate a pidns seems rather
> problematic.  I would also love to see a decent interface for
> interrogating user namespaces, and again, netlink would be great,
> except that it's a socket and makes no sense in this context.
> 
> Netlink had, and possibly still has, tons of serious security bugs
> involving code checking send() callers' creds.  I found and fixed a
> few a couple years ago.  To reiterate once again, send() CANNOT use
> caller creds safely.  (I feel like I say this once every few weeks.
> It's getting old.)
> 
> I realize that it's convenient to use a socket as a context to keep
> state between syscalls, but it has some annoying side effects:
> 
>  - It makes people want to rely on send()'s caller's creds.
> 
>  - It's miserable in combination with seccomp.
> 
>  - It doesn't play nicely with namespaces.
> 
>  - It makes me wonder why things like task_diag, which have nothing to
> do with networking, seem to get tangled up with networking.
> 
> 
> Would it be worth considering adding a parallel interface, using it
> for new things, and slowly migrating old use cases over?
> 
> int issue_kernel_command(int ns, int command, const struct iovec *iov,
> int iovcnt, int flags);
> 
> ns is an actual namespace fd or:
> 
> KERNEL_COMMAND_CURRENT_NETNS
> KERNEL_COMMAND_CURRENT_PIDNS
> etc, or a special one:
> KERNEL_COMMAND_GLOBAL.  KERNEL_COMMAND_GLOBAL can't be used in a
> non-root namespace.

An request can depend on a few namespaces. For example, we can request
credentials for a specified task. In this case we may want to specify
pid and user namespace.

> 
> KERNEL_COMMAND_GLOBAL works even for namespaced things, if the
> relevant current ns is the init namespace.  (This feature is optional,
> but it would allow gradually namespacing global things.)
> 
> command is an enumerated command.  Each command implies a namespace
> type, and, if you feed this thing the wrong namespace type, you get
> EINVAL.  The high bit of command indicates whether it's read-only
> command.
> 
> iov gives a command in the format expected, which, for the most part,
> would be a netlink message.
> 
> The return value is an fd that you can call read/readv on to read the
> response.  It's not a socket (or at least you can't do normal socket
> operations on it if it is a socket behind the scenes).  The
> implementation of read() promises *not* to look at caller creds.  The
> returned fd is unconditionally cloexec -- it's 2016 already.  Sheesh.
> 
> When you've read all the data, all you can do is close the fd.  You
> can't issue another command on the same fd.  You also can't call
> write() or send() on the fd unless someone has a good reason why you
> should be able to and why it's safe.  You can't issue another command
> on the same fd.
> 
> 
> I imagine that the implementation could re-use a bunch of netlink code
> under the hood.

I'm agree with this interface. For me it's interesting to know an
opinion from the other side. Stephen, could you share you comments
about these netlink issues and this new interface?

Thanks,
Andrew

> 
> 
> --Andy
