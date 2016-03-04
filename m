From: Guy Harris <guy@alum.mit.edu>
Subject: Re: [PATCH 0/3] UNIX sockets: POSIX conformance of errno's
Date: Thu, 3 Mar 2016 17:05:59 -0800
Message-ID: <918FFC95-9C82-4957-975F-4207DE7555D4@alum.mit.edu>
References: <1457004216-24988-1-git-send-email-ed@nuxi.nl>
Mime-Version: 1.0 (Mac OS X Mail 9.2 \(3112\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: Ed Schouten <ed@nuxi.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from c.mail.sonic.net ([64.142.111.80]:32899 "EHLO c.mail.sonic.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751831AbcCDBXP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 20:23:15 -0500
In-Reply-To: <1457004216-24988-1-git-send-email-ed@nuxi.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mar 3, 2016, at 3:23 AM, Ed Schouten <ed@nuxi.nl> wrote:

> While comparing the behavior of the Berkeley sockets API different
> operating systems, I noticed that in some places we return different
> errno's as what POSIX requires and how other systems work, but also what
> we document in our own man pages.
> 
> This is the first time I'm sending a patch to the Linux kernel, so if
> there's anything wrong with the way I submitted these patches,

Well, there doesn't actually seem to be any patches attached to the message, so that might be one thing that's wrong with it, unless it somehow got lost between you and me.  That's why, in my comments, I'm saying "if" in a number of places - I don't know what changes are being made.

> just let me know.
> 
> Thanks,
> Ed
> 
> Ed Schouten (3):
>  Make listen() on an unbound UNIX socket return EDESTADDRREQ.

The current version of the Single UNIX Specification says, on the page for listen():

	[EDESTADDRREQ]
		The socket is not bound to a local address, and the protocol does not support listening on an unbound socket.

The Linux man page for listen() doesn't say anything about listening on an unbound socket.  A quick look at the kernel code in Git seems to indicate that it returns EINVAL, so maybe a case could be made for changing it.

>  Let open() on a UNIX socket return EOPNOTSUPP.

The current version of the Single UNIX Specification appears to be silent, in the page for open(), on what happens if you hand open() a pathname for a UNIX-domain socket file, so, whilst Linux may incompatible with some other systems here, it's not incompatible with what POSIX requires.

In addition, I see nothing about UNIX-domain socket opens on the Linux open() man page:

	http://man7.org/linux/man-pages/man2/open.2.html

>  Return ENOTCONN when trying to recv() on an unconnected UNIX socket.

The current version of the Single UNIX Specification says, on the page for recv():

	[ENOTCONN]
		A receive is attempted on a connection-mode socket that is not connected.

A quick look at the current kernel code in Git indicates that it would return EINVAL instead, although it'd return ENOTCONN for sequenced-packet sockets, so maybe a case could be made for changing it.

So I see one case (open()) where there doesn't seem to be any case for the change, and two cases where a case could be made.

However, as Linux doesn't claim to be a UNIX(R), it's not as if violating the POSIX spec is *ipso facto* a problem - and "[Linux's] own man pages" appear to be silent on those issues. If, as David notes, there's the risk of breaking apps if the change is made, just as there's the risk of breaking apps ported from other platforms if the change *isn't* made.

I don't know of any data to indicate what would break in either case, so conservatism, i.e. not changing Linux's behavior, might be the right choice.  (From a pure abstract principle point of view, I'd vote for the change, but sometimes things work better if you ignore abstract principles.)
