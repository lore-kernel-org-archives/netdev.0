From: Al Viro <viro@ftp.linux.org.uk>
Subject: Re: Files, sockets, and closing
Date: Fri, 26 Oct 2007 23:46:22 +0100
Message-ID: <20071026224622.GH8181@ftp.linux.org.uk>
References: <20071026140319.5bcc8ac0@freepuppy.rosehill> <20071026214513.GG8181@ftp.linux.org.uk> <20071026150901.3b7fa6a3@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:43589 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751798AbXJZWq0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2007 18:46:26 -0400
Content-Disposition: inline
In-Reply-To: <20071026150901.3b7fa6a3@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 26, 2007 at 03:09:01PM -0700, Stephen Hemminger wrote:

> > close() from another thread is not a way to abort blocked accept().  Never
> > promised to be that.  Just as close() from another thread is not a way to
> > abort blocked write() or read() or sendmsg() or...
> 
> The problem is the Linux interpretation conflicts with the expectation
> of applications that run on other Unix systems.  Most likely, it is
> one of those corner cases not covered by SUS or Posix specs otherwise
> it would have come up earlier. The existing Linux behavior works fine
> it just isn't expected (or well documented).
> 
> I'm fine with just closing the bug (which is what I did initially), but
> where should this get documented?

close(2), perhaps?  "System call on opened file holds a reference to
opened file regardless of what happens to descriptor originally passed
to it" or something to the same effect...

That's what really happens - you get the same effect as if there had been
an additional temporary opened descriptor for that sucker.  And really,
multithreaded application that has one thread rip descriptors from under
another should be damn careful on _any_ system.  Anything that goes
"I've got -EBADF, guess another thread had removed that descriptor,
got to recover" is insane - in effect, it calls accept() blindly and
hopes that race will play out nicely, without hitting
	* thread A calls accept(3)
	* thread B calls close()
	* thread B calls e.g. dup() for unrelated reason and gets the same
descriptor reused
	* thread A finally gets from libc to accept(2), sees no EBADF and
proceeds with accept() on completely unrelated socket, with no indication of
the problem (or returns giving you a bogus errno, depending on what the
hell that descriptor happens to be).

IOW, if you rely on -EBADF to deal with such (userland) races, you are
extremely likely to be screwed.  On Linux, on FreeBSD, on Solaris, whatever.
In very controlled circumstances you might get away with that, but it's
almost certainly a Very Bad Idea(tm).

The bottom line: if descriptor table is a shared resource in your
multithreaded program, treat it as such.  Kernel will survive having
descriptors closed in the middle of syscall just fine; your userland
code is a different story.
