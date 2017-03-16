From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: [net-next PATCH 0/5] Add busy poll support for epoll under certain
 circumstances
Date: Thu, 16 Mar 2017 11:32:31 -0700
Message-ID: <20170316183142.15806.38824.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: sridhar.samudrala@intel.com, edumazet@google.com,
        davem@davemloft.net
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch series is meant to add busy polling support to epoll when all of
the sockets on a given epoll are either local or are being sourced by the
same NAPI ID.

In order to support this the first two patches clean up a few issues we
found with the NAPI ID tracking and infrastructure.

In the third patch we introduce SO_INCOMING_NAPI_ID so that applications
have a means of trying to sort their incoming sockets to identify which
requests should be routed where in order to keep the epoll listener aligned
to a given Rx queue without having to rely on IRQ pinning.

Finally the last two patches refactor the existing busy poll infrastructure
to make it so that we can call it without necessarily needing a socket, and
enable the bits needed to support epoll when all of the sockets on the
epoll either share the same NAPI ID, or simply are reporting no NAPI ID.

---

Sridhar Samudrala (5):
      net: Do not record sender_cpu as napi_id in socket receive paths
      net: Call sk_mark_napi_id() in the ACK receive path
      net: Introduce SO_INCOMING_NAPI_ID
      net: Commonize busy polling code to focus on napi_id instead of socket
      epoll: Add busy poll support to epoll with socket fds.


 arch/alpha/include/uapi/asm/socket.h   |    2 +
 arch/avr32/include/uapi/asm/socket.h   |    2 +
 arch/frv/include/uapi/asm/socket.h     |    2 +
 arch/ia64/include/uapi/asm/socket.h    |    2 +
 arch/m32r/include/uapi/asm/socket.h    |    2 +
 arch/mips/include/uapi/asm/socket.h    |    2 +
 arch/mn10300/include/uapi/asm/socket.h |    2 +
 arch/parisc/include/uapi/asm/socket.h  |    2 +
 arch/powerpc/include/uapi/asm/socket.h |    2 +
 arch/s390/include/uapi/asm/socket.h    |    2 +
 arch/sparc/include/uapi/asm/socket.h   |    2 +
 arch/xtensa/include/uapi/asm/socket.h  |    2 +
 fs/eventpoll.c                         |  115 ++++++++++++++++++++++++++++++++
 include/net/busy_poll.h                |   14 +++-
 include/uapi/asm-generic/socket.h      |    2 +
 net/core/dev.c                         |   16 ++--
 net/core/sock.c                        |   22 ++++++
 net/ipv4/tcp_ipv4.c                    |    1 
 18 files changed, 183 insertions(+), 11 deletions(-)

--
