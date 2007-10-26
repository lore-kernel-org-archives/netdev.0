From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: Files, sockets, and closing
Date: Fri, 26 Oct 2007 15:09:01 -0700
Message-ID: <20071026150901.3b7fa6a3@freepuppy.rosehill>
References: <20071026140319.5bcc8ac0@freepuppy.rosehill>
	<20071026214513.GG8181@ftp.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Al Viro <viro@ftp.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:56347 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751240AbXJZWKM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2007 18:10:12 -0400
In-Reply-To: <20071026214513.GG8181@ftp.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 26 Oct 2007 22:45:13 +0100
Al Viro <viro@ftp.linux.org.uk> wrote:

> On Fri, Oct 26, 2007 at 02:03:19PM -0700, Stephen Hemminger wrote:
> > Looking at this bug:
> > http://bugzilla.kernel.org/show_bug.cgi?id=9149
> > 
> > Exposes some rather deep issues in the filesystem/socket/inet/tcp
> > layering. It seems that sys_close() zaps the file table entry, but
> > since each thread has a separate reference, the actual tcp_close()
> > doesn't happen until the last thread calls close/exits.
> 
> No.  It's not about that at all.  Threads in his case _share_ descriptor
> table and the thing he's complaining about is that another thread has
> removed the descriptor from their (shared) descriptor table and he's
> not getting notified.  It's not about struct file (or socket) at all;
> it's all on descriptor level.
> 
> The reference to struct file is held by accept() itself, _not_ by descriptor
> table.  And he would have the same problem if the opened socket had been
> inherited from parent (and still opened by it) - it's really not about
> the damn thing getting shut down, etc.
> 
> What happens is that there is a mapping from descriptors to opened files,
> a reference to opened file is obtained by it once per syscall and that file
> remains open at least until the end of syscall.   Whether the descriptor
> you've passed remains refering to the same file is up to userland code.
> If you have another thread and that thread rips the descriptor out of your
> shared descriptor table, it's your responsibility to keep them sane and
> happy.
> 
> close() from another thread is not a way to abort blocked accept().  Never
> promised to be that.  Just as close() from another thread is not a way to
> abort blocked write() or read() or sendmsg() or...

The problem is the Linux interpretation conflicts with the expectation
of applications that run on other Unix systems.  Most likely, it is
one of those corner cases not covered by SUS or Posix specs otherwise
it would have come up earlier. The existing Linux behavior works fine
it just isn't expected (or well documented).

I'm fine with just closing the bug (which is what I did initially), but
where should this get documented?

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
