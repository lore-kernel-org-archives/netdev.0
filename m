From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: [net-next PATCH v3 0/8] Add busy poll support for epoll
Date: Fri, 24 Mar 2017 10:07:47 -0700
Message-ID: <20170324164902.15226.48358.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: sridhar.samudrala@intel.com, edumazet@google.com,
        davem@davemloft.net, linux-api@vger.kernel.org
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch set adds support for using busy polling with epoll. The main
idea behind this is that we record the NAPI ID for the last event that is
moved onto the ready list for the epoll context and then when we no longer
have any events on the ready list we begin polling with that ID. If the
busy polling does not yield any events then we will reset the NAPI ID to 0
and wait until a new event is added to the ready list with a valid NAPI ID
before we will resume busy polling.

Most of the changes in this set authored by me are meant to be cleanup or
fixes for various things. For example, I am trying to make it so that we
don't perform hash look-ups for the NAPI instance when we are only working
with sender_cpu and the like.

At the heart of this set is the last 3 patches which enable epoll support
and add support for obtaining the NAPI ID of a given socket. With these it 
becomes possible for an application to make use of epoll and get optimal
busy poll utilization by stacking multiple sockets with the same NAPI ID on
the same epoll context.

v1: The first version of this series only allowed epoll to busy poll if all
    of the sockets with a NAPI ID shared the same NAPI ID. I feel we were
    too strict with this requirement, so I changed the behavior for v2.
v2: The second version was pretty much a full rewrite of the first set. The
    main changes consisted of pulling apart several patches to better
    address the need to clean up a few items and to make the code easier to
    review. In the set however I went a bit overboard and was trying to fix
    an issue that would only occur with 500+ years of uptime, and in the
    process limited the range for busy_poll/busy_read unnecessarily.
v3: Split off the code for limiting busy_poll and busy_read into a separate
    patch for net.
    Updated patch that changed busy loop time tracking so that it uses
    "local_clock() >> 10" as we originally did.
    Tweaked "Change return type.." patch by moving declaration of "work"
    inside the loop where is was accessed and always reset to 0.
    Added "Acked-by" for patches that received acks.

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
 fs/eventpoll.c                         |   93 +++++++++++++++++++++++++++++
 fs/select.c                            |   16 +++--
 include/net/busy_poll.h                |  102 +++++++++++++++++++-------------
 include/uapi/asm-generic/socket.h      |    2 +
 net/core/datagram.c                    |    8 ++-
 net/core/dev.c                         |   41 ++++++-------
 net/core/sock.c                        |   23 +++++++
 net/ipv4/tcp_ipv4.c                    |    2 -
 net/ipv4/tcp_minisocks.c               |    4 +
 net/ipv6/tcp_ipv6.c                    |    2 -
 net/sctp/socket.c                      |    9 ++-
 23 files changed, 244 insertions(+), 81 deletions(-)

--
