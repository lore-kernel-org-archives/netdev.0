From: Vivek Goyal <vgoyal@redhat.com>
Subject: [PATCH 0/2] net: Implement SO_PEERCGROUP to get cgroup of peer
Date: Wed, 12 Mar 2014 14:45:40 -0400
Message-ID: <1394649942-5854-1-git-send-email-vgoyal@redhat.com>
Cc: ssorce@redhat.com, jkaluza@redhat.com, lpoetter@redhat.com,
	kay@redhat.com, Vivek Goyal <vgoyal@redhat.com>
To: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org,
	netdev@vger.kernel.org, davem@davemloft.net, tj@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some applications like sssd want to know the cgroup of connected peer over
unix stream socket. They want to use this information to map the the
container client belongs to and then decide what kind of policies apply
on the container.

Well why not use SO_PEERCRED, extract pid from it and lookup in
/proc/pid/cgroup to figure out cgroup of client. Problem there is that it
is racy. By the time we look up in /proc, it might happen that client
exited (possibly after handing over socket fd to a child), and client pid
can possibly be assigned to another process. That's the reason people are
looking for more reliable mechanism.

There are others like journald who want similar information over unix
datagram sockets. A patchset to provide that functionality was posted 
here.

https://lkml.org/lkml/2014/1/13/43

But this was rejected because of overhead it will cause for rest of the
cases.

https://lkml.org/lkml/2014/1/15/480

This patch series implements SO_PEERCGROUP, which gives more connection
based and gives the cgroup of client at the time of opening the connection.
So overhead is involved only during connection setup and there should not
be any overhead after that.

So it does not solve all the use cases out there but can solve the needs
of sssd. Hence I am posting this patch.

Please consider it for inclusion.

Thanks
Vivek

Vivek Goyal (2):
  cgroup: Provide empty definition of task_cgroup_path()
  net: Implement SO_PEERCGROUP

 arch/alpha/include/uapi/asm/socket.h   |  1 +
 arch/avr32/include/uapi/asm/socket.h   |  1 +
 arch/cris/include/uapi/asm/socket.h    |  2 ++
 arch/frv/include/uapi/asm/socket.h     |  1 +
 arch/ia64/include/uapi/asm/socket.h    |  2 ++
 arch/m32r/include/uapi/asm/socket.h    |  1 +
 arch/mips/include/uapi/asm/socket.h    |  1 +
 arch/mn10300/include/uapi/asm/socket.h |  1 +
 arch/parisc/include/uapi/asm/socket.h  |  1 +
 arch/powerpc/include/uapi/asm/socket.h |  1 +
 arch/s390/include/uapi/asm/socket.h    |  1 +
 arch/sparc/include/uapi/asm/socket.h   |  2 ++
 arch/xtensa/include/uapi/asm/socket.h  |  1 +
 include/linux/cgroup.h                 |  2 ++
 include/net/sock.h                     |  1 +
 include/uapi/asm-generic/socket.h      |  2 ++
 net/core/sock.c                        | 19 ++++++++++++++
 net/unix/af_unix.c                     | 48 ++++++++++++++++++++++++++++++++++
 18 files changed, 88 insertions(+)

-- 
1.8.5.3
