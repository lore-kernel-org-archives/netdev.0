From: Paolo Abeni <pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next v5 0/3] udp: refactor memory accounting
Date: Thu, 20 Oct 2016 22:31:07 +0200
Message-ID: <cover.1476979679.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>,
        Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
        Alexander Duyck <aduyck-nYU0QVwCCFFWk0Htik3J/w@public.gmane.org>,
        Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
        Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org>,
        Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>,
        Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch series refactor the udp memory accounting, replacing the
generic implementation with a custom one, in order to remove the needs for
locking the socket on the enqueue and dequeue operations. The socket backlog
usage is dropped, as well.

The first patch factor out pieces of some queue and memory management
socket helpers, so that they can later be used by the udp memory accounting
functions.
The second patch adds the memory account helpers, without using them.
The third patch replacse the old rx memory accounting path for udp over ipv4 and
udp over ipv6. In kernel UDP users are updated, as well.

The memory accounting schema is described in detail in the individual patch
commit message.

The performance gain depends on the specific scenario; with few flows (and
little contention in the original code) the differences are in the noise range,
while with several flows contending the same socket, the measured speed-up
is relevant (e.g. even over 100% in case of extreme contention)

v4 -> v5:
 - use the receive queue spin lock to protect the memory accounting
 - several minor clean-up

v3 -> v4:
 - simplified the locking schema, always use a plain spinlock

v2 -> v3:
 - do not set the now unsed backlog_rcv callback

v1 -> v2:
 - changed slighly the memory accounting schema, we now perform lazy reclaim
 - fixed forward_alloc updating issue
 - fixed memory counter integer overflows

Paolo Abeni (3):
  net/socket: factor out helpers for memory and queue manipulation
  udp: implement memory accounting helpers
  udp: use it's own memory accounting schema

 include/net/sock.h    |   4 ++
 include/net/udp.h     |   4 ++
 net/core/datagram.c   |  36 +++++++-----
 net/core/sock.c       |  64 ++++++++++++++-------
 net/ipv4/udp.c        | 151 ++++++++++++++++++++++++++++++++++++++------------
 net/ipv6/udp.c        |  34 +++---------
 net/sunrpc/svcsock.c  |  20 +++++--
 net/sunrpc/xprtsock.c |   2 +-
 8 files changed, 216 insertions(+), 99 deletions(-)

-- 
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
