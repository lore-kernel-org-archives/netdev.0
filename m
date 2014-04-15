From: Vivek Goyal <vgoyal@redhat.com>
Subject: [PATCH 0/2] net: Implement SO_PEERCGROUP and SO_PASSCGROUP socket options
Date: Tue, 15 Apr 2014 17:15:44 -0400
Message-ID: <1397596546-10153-1-git-send-email-vgoyal@redhat.com>
Cc: tj@kernel.org, ssorce@redhat.com, lpoetter@redhat.com,
	kay@redhat.com, luto@amacapital.net, dwalsh@redhat.com,
	Vivek Goyal <vgoyal@redhat.com>
To: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org,
	netdev@vger.kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

This is another version of patchset to add support passing cgroup information
of client over unix socket API.

This patchset adds a new socket option SO_PEERCGROUP to receive cgroup
information of client which opened the connection. This only works with
unix stream sockets.

It also adds another option SO_PASSCGROUP which allows server to receive
the cgroup information of the message sender. This option enables receiving
a new type of control message SCM_CGROUP which contains cgroup information.
This option works both with unix stream as well as datagram sockets.

User space applications want to know the cgroup of the client and they
seem to have different use cases of how to make use of cgroup information.
One such use case is that systemd logs cgroup information of client in
journal. 

Currently, one uses SO_PEERCRED or SO_PASSCRED option and gets the pid of
client and looks up cgroup from /proc/pid/cgroup. But this has two problems.

- Looking up /proc/pid/cgroup is racy. It is possible that by the time we
  looked it up, client exited and pid got reused and we are looking at cgroup
  information of an entirely different process.

- Even if pid did not get reused, there might not be /proc/pid/cgroup file
  if client exited. So server got a message but now there is no way to find
  cgroup of client how had sent the message.

Passing cgroup information using SO_PEERCROUP and SO_PASSCGROUP options
should solve above two problems/races.

Your feedback is welcome.

Thanks
Vivek


Vivek Goyal (2):
  net: Implement SO_PEERCGROUP
  net: Implement SO_PASSCGROUP to enable passing cgroup path

 arch/alpha/include/uapi/asm/socket.h   |   2 +
 arch/avr32/include/uapi/asm/socket.h   |   2 +
 arch/cris/include/uapi/asm/socket.h    |   3 +
 arch/frv/include/uapi/asm/socket.h     |   2 +
 arch/ia64/include/uapi/asm/socket.h    |   3 +
 arch/m32r/include/uapi/asm/socket.h    |   2 +
 arch/mips/include/uapi/asm/socket.h    |   2 +
 arch/mn10300/include/uapi/asm/socket.h |   2 +
 arch/parisc/include/uapi/asm/socket.h  |   2 +
 arch/powerpc/include/uapi/asm/socket.h |   2 +
 arch/s390/include/uapi/asm/socket.h    |   2 +
 arch/sparc/include/uapi/asm/socket.h   |   3 +
 arch/xtensa/include/uapi/asm/socket.h  |   2 +
 include/linux/net.h                    |   1 +
 include/linux/socket.h                 |   1 +
 include/net/af_unix.h                  |   1 +
 include/net/scm.h                      |  26 ++++-
 include/net/sock.h                     |   2 +
 include/uapi/asm-generic/socket.h      |   3 +
 net/core/sock.c                        |  26 +++++
 net/unix/af_unix.c                     | 188 ++++++++++++++++++++++++++++++++-
 21 files changed, 271 insertions(+), 6 deletions(-)

-- 
1.9.0
