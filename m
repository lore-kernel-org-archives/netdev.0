From: Al Viro <viro@ftp.linux.org.uk>
Subject: Re: Files, sockets, and closing
Date: Fri, 26 Oct 2007 22:45:13 +0100
Message-ID: <20071026214513.GG8181@ftp.linux.org.uk>
References: <20071026140319.5bcc8ac0@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:49060 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754205AbXJZVpR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2007 17:45:17 -0400
Content-Disposition: inline
In-Reply-To: <20071026140319.5bcc8ac0@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 26, 2007 at 02:03:19PM -0700, Stephen Hemminger wrote:
> Looking at this bug:
> http://bugzilla.kernel.org/show_bug.cgi?id=9149
> 
> Exposes some rather deep issues in the filesystem/socket/inet/tcp
> layering. It seems that sys_close() zaps the file table entry, but
> since each thread has a separate reference, the actual tcp_close()
> doesn't happen until the last thread calls close/exits.

No.  It's not about that at all.  Threads in his case _share_ descriptor
table and the thing he's complaining about is that another thread has
removed the descriptor from their (shared) descriptor table and he's
not getting notified.  It's not about struct file (or socket) at all;
it's all on descriptor level.

The reference to struct file is held by accept() itself, _not_ by descriptor
table.  And he would have the same problem if the opened socket had been
inherited from parent (and still opened by it) - it's really not about
the damn thing getting shut down, etc.

What happens is that there is a mapping from descriptors to opened files,
a reference to opened file is obtained by it once per syscall and that file
remains open at least until the end of syscall.   Whether the descriptor
you've passed remains refering to the same file is up to userland code.
If you have another thread and that thread rips the descriptor out of your
shared descriptor table, it's your responsibility to keep them sane and
happy.

close() from another thread is not a way to abort blocked accept().  Never
promised to be that.  Just as close() from another thread is not a way to
abort blocked write() or read() or sendmsg() or...
