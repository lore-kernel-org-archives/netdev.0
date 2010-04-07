From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH v3 0/4] xfrm: add x86 CONFIG_COMPAT support
Date: Wed, 7 Apr 2010 15:35:28 +0200
Message-ID: <20100407133528.GD22518@Chamillionaire.breakpoint.cc>
References: <1270506431-25578-1-git-send-email-fw@strlen.de>
 <20100407.030850.04450543.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fw@strlen.de, netdev@vger.kernel.org, johannes@sipsolutions.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:37845 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757718Ab0DGNfa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Apr 2010 09:35:30 -0400
Content-Disposition: inline
In-Reply-To: <20100407.030850.04450543.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
> From: Florian Westphal <fw@strlen.de>
> Date: Tue,  6 Apr 2010 00:27:07 +0200

[..]

> > I sent a patch that solved this by adding a sys_compat_write syscall
> > and a ->compat_aio_write() to struct file_operations to the
> > vfs mailing list, but that patch was ignored by the vfs people,
> > and the x86 folks did not exactly like the idea either.
> >
> > So this leaves three alternatives:
> > 1 - drop the whole idea and keep the current status.
> > 2 - Add new structure definitions (with new numbering) that would work
> >     everywhere, keep the old ones for backwards compatibility (This
> >     was suggested by Arnd Bergmann).
> > 3 - apply this patch set and tell userspace to move the sendmsg() when
> >     they want to work with xfrm on x86_64 with 32 bit userland.
>
> So do we know of any xfrm netlink apps that do not use sendmsg()?
>
> I doubt there are any, and if that's true for the most part, then
> option #3 seems the best.

Open- and strongswan do (in pluto/kernel_netlink.c), strongswan also uses
sendto() in charon (their ikev2 daemon); sendto does not work at the
moment either.

That being said, this is only in a single spot.
The openswan people indicated they'd accept a patch that converts the
write to a sendmsg call.

openikev2 also uses write on a netlink socket (looks rather similar
to the one in open/strongswan).

AFAICS, all the receive functions use recvfrom (which sets CMSG_COMPAT).

I did not find other ike software that uses xfrm.

> If we find a non-trivial number of apps using plain write() then
> we might have to consider championing your vfs patch to the
> lkml and vfs folks again.

There is probably no "nontrivial" number, simply because there are not
that many user apps out there to begin with.

But whats really bothering me is the number of sys_compat_* functions
needed to make all possibilities work;. e.g. to make (unmodified)
strongwan work, sys_compat_write and sys_compat_sendto are needed.

What about applications that use any of the other countless
write functions?  Right now these do not set CMSG_COMPAT either.

And lets not get started with the abdunance of read() like functions...

[ I do not know about any such applications, but still ...]

> I'll help if this is needed.

Thank you.

Personally I hope that we can move the affected userspace tools to
sendmsg() and avoid introducing new compat syscalls, simply because
there is no telling what kind of mess we'd be walking into :-)
