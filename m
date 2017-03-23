From: Alexander Duyck <alexander.duyck-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [net-next PATCH v2 0/8] Add busy poll support for epoll
Date: Thu, 23 Mar 2017 14:36:29 -0700
Message-ID: <20170323211820.12615.88907.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: sridhar.samudrala-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
        davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is my second pass at trying to add support for busy polling when using
epoll. It is pretty much a full rewrite as I have made serious changes to
most of the patches.

In the v1 series I had submitted we only allowed epoll to make use of busy
poll when all NAPI IDs were the same. I gave this some more thought and
after making several other changes based on feedback from Eric Dumazet I
decided to try changing the main concept a bit and instead we will now
attempt to busy poll on the NAPI ID of the last socket added to the ready
list. By doing it this way we are able to take advantage of the changes
Eric has already made so that we get woken up by the softirq, we then pull
packets via busy poll, and will return to the softirq until we are woken up
and a new socket has been added to the ready list.

Most of the changes in this set authored by me are meant to be cleanup or
fixes for various things. For example, I am trying to make it so that we
don't perform hash look-ups for the NAPI instance when we are only working
with sender_cpu and the like.

The most complicated change of the set is probably the clean-ups for the
timeout. I realized that the timeout could potentially get into a state
where it would never timeout if the local_clock() was approaching a
rollover and the added busy poll usecs interval would be enough to roll it
over.  Because we were shifting the value you would never be able to get
time_after to actually trigger.

At the heart of this set is the last 3 patches which enable epoll support
and add support for obtaining the NAPI ID of a given socket.  With these
It becomes possible for an application to make use of epoll and get optimal
busy poll utilization by stacking multiple sockets with the same NAPI ID on
the same epoll context.

---

Alexander Duyck (5):
      net: Busy polling should ignore sender CPUs
      tcp: Record Rx hash and NAPI ID in tcp_child_process
      net: Only define skb_mark_napi_id in one spot instead of two
      net: Change return type of sk_busy_loop from bool to void
      net: Track start of busy loop instead of when it should end

Sridhar Samudrala (3):
      net: Commonize busy polling code to focus on napi_id instead of socket
      epoll: Add busy poll support to epoll with socket fds.
      net: Introduce SO_INCOMING_NAPI_ID


 arch/alpha/include/uapi/asm/socket.h   |    2 +
 arch/avr32/include/uapi/asm/socket.h   |    2 +
 arch/frv/include/uapi/asm/socket.h     |    2 +
 arch/ia64/include/uapi/asm/socket.h    |    2 +
 arch/m32r/include/uapi/asm/socket.h    |    2 +
 arch/mips/include/uapi/asm/socket.h    |    1 
 arch/mn10300/include/uapi/asm/socket.h |    2 +
 arch/parisc/include/uapi/asm/socket.h  |    2 +
 arch/powerpc/include/uapi/asm/socket.h |    2 +
 arch/s390/include/uapi/asm/socket.h    |    2 +
 arch/sparc/include/uapi/asm/socket.h   |    2 +
 arch/xtensa/include/uapi/asm/socket.h  |    2 +
 fs/eventpoll.c                         |   93 +++++++++++++++++++++++++++
 fs/select.c                            |   16 ++---
 include/net/busy_poll.h                |  112 ++++++++++++++++++++------------
 include/uapi/asm-generic/socket.h      |    2 +
 net/core/datagram.c                    |    8 ++
 net/core/dev.c                         |   42 ++++++------
 net/core/sock.c                        |   23 +++++++
 net/core/sysctl_net_core.c             |   11 +++
 net/ipv4/tcp_ipv4.c                    |    2 -
 net/ipv4/tcp_minisocks.c               |    4 +
 net/ipv6/tcp_ipv6.c                    |    2 -
 net/sctp/socket.c                      |    9 ++-
 24 files changed, 264 insertions(+), 83 deletions(-)

--
