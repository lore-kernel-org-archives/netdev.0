From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH] LSM: Add security_socket_post_accept() and security_socket_post_recv_datagram().
Date: Thu, 23 Apr 2009 23:00:09 +0900
Message-ID: <200904232300.IIB39542.SHJFLOtFVQFOMO@I-love.SAKURA.ne.jp>
References: <200904220502.n3M52GQj001957@www262.sakura.ne.jp>
	<20090421.220735.118831531.davem@davemloft.net>
	<200904220538.n3M5c4QI010548@www262.sakura.ne.jp>
	<20090421.225202.218457438.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: paul.moore@hp.com, linux-security-module@vger.kernel.org,
	netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20090421.225202.218457438.davem@davemloft.net>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> FWIW I do not agree with TOMOYO conceptually.
That will be my fault. I haven't explained you the background of this proposal.
Would you please be patient and read below explanation?

Thanks.
----------
TOMOYO is a security module which focuses on behavior of a system. A process is
created to achieve something. TOMOYO lets each process declare behaviors and
resources needed to achieve its purpose (like an immigration officer) and
permits only declared behaviors and resources (like an operation watchdog).

TOMOYO has an unprecedented concept called "process invocation history" (in
short, PIH). TOMOYO utilizes the PIH for categorizing the purpose of a process.
The PIH is stored into current->cred->security and is defined as concatenation
of program's pathnames ever executed. For example, /sbin/init invoked from the
kernel is defined as "<kernel> /sbin/init", /etc/rc.d/rc.sysinit invoked from
/sbin/init invoked from the kernel is defined as
"<kernel> /sbin/init /etc/rc.d/rc.sysinit". (There are some exceptions, but I
omit explanation because exceptions have no linkage with this proposal.)

**TOMOYO's policy is PIH-driven.** For example,

  <kernel> /sbin/init
  allow_read /etc/inittab

means that any process with PIH "<kernel> /sbin/init" is allowed to open a file
named /etc/inittab for reading.

  <kernel> /usr/sbin/sshd
  allow_create /var/run/sshd.pid

means that any process with PIH "<kernel> /usr/sbin/sshd" is allowed to create
a file named /var/run/sshd.pid .

  <kernel> /usr/sbin/sshd /bin/bash /usr/bin/curl
  allow_network TCP connect 192.168.1.1 80
  allow_network UDP connect 192.168.1.2 53

means that any process with PIH
"<kernel> /usr/sbin/sshd /bin/bash /usr/bin/curl" is allowed to send TCP
connect() requests to 192.168.1.1 port 80 and is allowed to send UDP datagrams
to 192.168.1.2 port 53.

TOMOYO wants to allow writing policy for incoming connections/datagrams in the
same manner. For example,

  <kernel> /usr/sbin/sshd
  allow_network TCP accept 10.0.0.0-10.255.255.255 1024-65535

means that any process with PIH "<kernel> /usr/sbin/sshd" is allowed to pick up
TCP connections from 10.0.0.0/8 port 1024-65535.

To be able to write in the same manner, TOMOYO needs to know the PIH of a
process who is about to pick up the incoming connection/datagram.
The PIH (i.e. current->cred->security) is different from the security context
of a socket which is going to enqueue the incoming connection/datagram
(i.e. "struct sock"->sk_security). And LSM has no hooks which allow TOMOYO to
use current->cred->security for incoming connections/datagrams.

There could be some programs which get confused by accept()/recvmsg() returning
an error when poll() said "connections are ready" or "datagrams are ready".
If we find such programs, we can tell TOMOYO to disable filtering for such
programs.
