From: linux@horizon.com
Subject: The mess that is SIGPIPE
Date: 19 Aug 2007 08:00:02 -0400
Message-ID: <20070819120002.17027.qmail@science.horizon.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from science.horizon.com ([192.35.100.1]:15874 "HELO
	science.horizon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751196AbXHSMGo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Aug 2007 08:06:44 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I noticed that FreeBSD has a useful SOL_SOCKET option, SO_NOSIGPIPE, which
is a "sticky" version of MSG_NOSIGNAL.  Particularly useful for libraries,
it disables SIGPIPE on a particular socket without disabling it globally.

Anyway, this led me to look at the implementation of SIGPIPE and
MSG_NOSIGNAL and...  it's a bit of a mess.  Some places honor
MSG_NOSIGNAL, but there are a lot of code paths that don't appear to.

So I started thinking about a cleanup...

Currently, SIGPIPE is sent from dozens of places that return EPIPE.
What if they could all be deleted and just a few system calls: write(),
writev(), send(), sendto() and sendmsg() (oh, yes, and sendfile())
could check for EPIPE from the VFS calls they make and generate SIGPIPE
appropriately?

The only thing is figuring out where in the call chain to put it.

sys_send()
-> sys_sendto()
   -> sock_sendmsg()
      -> __sock_sendmsg()
         -> sock->ops->sendmsg

sys_write()
-> vfs_write()
   -> do_sync_write
      -> filp->f_op->aio_write
         -> sock_aio_write()
            -> do_sock_write()
               -> __sock_(sendmsg()

sys_writev()
-> vfs_writev()
   -> do_readv_writev()
      -> do_loop_readv_writev()
         -> file->f_op->write
            -> ????
               -> sock_aio_write()
                  -> do_sock_write()
                     -> __sock_(sendmsg()

kernel_sendmsg() also calls sock_sendmsg(), and it would save a bunch
of fiddling with MSG_NOSIGNAL if kernel_sendmsg() never generated signals.

That implies that the check should be at the sys_sendto() layer or higher.


Anyway, looking into implementing this, I found a zillion places where
the logic looked a little unclear, such as OCFS2 code.  I'm not convinced
that a bug there can't generate SIGPIPE unexpectedly.


Anyway, before I tackle this rewrite, I'd like to ask if someone knows
what the code is *supposed* to be doing, and can confirm that SIGPIPE
should be generated if and only if the write is done by a user-level
system call that can return EPIPE.  So all the buried network file
systems should never generate it.  Is that right?

Thanks for the insights.
