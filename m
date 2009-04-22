From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Subject: Re: [PATCH] LSM: Add security_socket_post_accept() and security_socket_post_recv_datagram().
Date: Wed, 22 Apr 2009 16:19:19 +0900
Message-ID: <200904220719.n3M7JJSo035412@www262.sakura.ne.jp>
References: <20090422061006.GB27688@bx9.net> <20090421.233403.83067664.davem@davemloft.net> <20090422064159.GA4221@bx9.net> <20090421.234618.181879214.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Cc: paul.moore@hp.com, linux-security-module@vger.kernel.org,
	netdev@vger.kernel.org, greg@blekko.com
To: davem@davemloft.net
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20090421.234618.181879214.davem@davemloft.net>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> If I dup a file descriptor for a listening socket, and accept() in the
> "wrong" task, the other task has no way to accept() that connection
> even if it's security settings allow it.  The connection is lost
> forever.
Why the connection gets lost? If two tasks' security settings are the same,
the process whichever reached sock->ops->accept() first will get the connetion.
If two tasks' security settings are not the same, I warned it on the patch
descripption.

> This new behavior from TOMOYO would make accept() return -EAGAIN in
> cases which are of no fault of the application.  It is definitely
> unexpected behavior.
TOMOYO will return -ECONNABORTED, which is also returned by failure of
newsock->ops->getname().

If there were some application which can't handle accept() returning
-ECONNABORTED error, we can simply disable this filtering (by giving such
application permission to accept connection from all addresses).
Applications should be able to handle accept() error other than -EAGAIN.
It is legal to return (for example) -ENOMEM, -EPERM. "man 2 accept" says:

ERRORS
       accept() shall fail if:

       EAGAIN or EWOULDBLOCK
              The socket is marked non-blocking and no connections are present to be accepted.

       EBADF  The descriptor is invalid.

       ECONNABORTED
              A connection has been aborted.

       EINTR  The system call was interrupted by a signal that was caught before a valid connection arrived.

       EINVAL Socket is not listening for connections, or addrlen is invalid (e.g., is negative).

       EMFILE The per-process limit of open file descriptors has been reached.

       ENFILE The system limit on the total number of open files has been reached.

       ENOTSOCK
              The descriptor references a file, not a socket.

       EOPNOTSUPP
              The referenced socket is not of type SOCK_STREAM.

       accept() may fail if:

       EFAULT The addr argument is not in a writable part of the user address space.

       ENOBUFS, ENOMEM
              Not  enough free memory.  This often means that the memory allocation is limited by the socket buffer limits, not by the system memory.

       EPROTO Protocol error.

       Linux accept() may fail if:

       EPERM  Firewall rules forbid connection.

       In addition, network errors for the new socket and as defined for the protocol may be returned. Various  Linux  kernels  can  return
       other errors such as ENOSR, ESOCKTNOSUPPORT, EPROTONOSUPPORT, ETIMEDOUT.  The value ERESTARTSYS may be seen during a trace.

Linux 2.6.7                       2004-06-17                         ACCEPT(2)
