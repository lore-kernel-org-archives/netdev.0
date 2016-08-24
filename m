From: Andrei Vagin <avagin@gmail.com>
Subject: Continue a discussion about the netlink interface
Date: Wed, 24 Aug 2016 15:16:00 -0700
Message-ID: <20160824221559.GB12687@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org, linux-api@vger.kernel.org,
        Kirill Kolyshkin <kir@openvz.org>,
        Steven Rostedt <rostedt@goodmis.org>
To: Andy Lutomirski <luto@amacapital.net>,
        Stephen Hemminger <stephen@networkplumber.org>,
        David Ahern <dsahern@gmail.com>, Arnd Bergmann <arnd@arndb.de>,
        Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33449 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756595AbcHXWQD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 18:16:03 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I want to return to a discussion about the netlink interface and how to
use it out of the network subsystem.

I'm developing a new interface to get information about processes
(task_diag). task_diag is like socket_diag but for processes. [0]

In the first two versions [1] [2], I used the netlink interface to
communicate with kernel. There was a discussion [4], that the netlink
interface is not suitable for this task and it has a few known issues
about security, so probably it should not be used for task_diag.

Then, in a third version [3], I used a proc transaction file
instead of the netlink interface. But it was not accepted too, because
we already have the netlink interface[5] and it's a bad idea to add one
more similar less-generic interface.

Then Andy Lutomirski suggested to rework netlink [6], but nobody
answered on his suggestion.

Can we continue this discussion and find a final solution?

Maybe we need to schedule a face-to-face meeting on one of conferences?
It may be Linux Plumbers, for example.

Here is Andy's idea how the netlink interface can be reworked:

On Wed, May 04, 2016 at 08:39:51PM -0700, Andy Lutomirski wrote:
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
>
> KERNEL_COMMAND_GLOBAL works even for namespaced things, if the
> relevant current ns is the init namespace.  (This feature is optional,
> but it would allow gradually namespacing global things.)
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

[6] https://www.mail-archive.com/netdev@vger.kernel.org/msg109212.html
[5] https://lkml.org/lkml/2016/5/4/785
[4] https://lkml.org/lkml/2015/7/6/708
[3] https://lwn.net/Articles/683371/
[2] https://lkml.org/lkml/2015/7/6/142
[1] https://lwn.net/Articles/633622/
[0] https://criu.org/Task-diag

Thanks,
Andrei
