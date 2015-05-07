From: Ying Xue <ying.xue@windriver.com>
Subject: [RFC PATCH net-next 00/11] netns: don't switch namespace while creating kernel sockets
Date: Thu, 7 May 2015 16:52:39 +0800
Message-ID: <1430988770-28907-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <cwang@twopensource.com>, <herbert@gondor.apana.org.au>,
	<xemul@openvz.org>, <davem@davemloft.net>,
	<eric.dumazet@gmail.com>, <ebiederm@xmission.com>,
	<maxk@qti.qualcomm.com>, <stephen@networkplumber.org>,
	<tgraf@suug.ch>, <nicolas.dichtel@6wind.com>,
	<tom@herbertland.com>, <jchapman@katalix.com>,
	<erik.hugne@ericsson.com>, <jon.maloy@ericsson.com>,
	<horms@verge.net.au>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:35530 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751438AbbEGIxe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2015 04:53:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When commit 23fe18669e7f ("[NETNS]: Fix race between put_net() and
netlink_kernel_create().") attempted to fix the race between put_net()
and kernel socket's creation, it adopted a complex solution: create
netlink socket inside init_net namespace and then re-attach it to the
desired one right after the socket is created; similarly, when close
the socket, move back its namespace to init_net so that the socket can
be destroyed in the context which is same as the socket creation.

But the solution artificially makes the whole thing complex as its
design is not only weird, but also it causes a bad consequence that
when all kernel modules create kernel sockets, they have to follow
the model of namespace switch. More importantly, with the way kernel
sockets are created in init_net namespace, but they are released in
another new ones. This inconsistent namespace brings some modules many
inconvenience. For example, what tipc socket is inserted to rhashtable
happens in socket's creation, and different namespace has different
rhashtable for tipc socket. With the approach, a tipc kernel socket
will be inserted into the rhashtable of init_net. But as releasing
the socket happens in another one, it causes what the socket cannot
be found from the rhashtable of the new namespace.

Therefore, we propose a simpler solution to avoid the race: if we
find there is still pending a cleanup work in __put_net(), we don't
queue a new cleanup work to stop the cleanup process. The new proposal
not only successfully solves the race, but also it can help us to
avoid unnecessary namespace switches when creating kernel sockets.
Moreover, it can guarantee that both creation and release of kernel
sockets happen in the same namespace at all time.

In the series, we first resolve the race with patch #1, and then
prevent namespace switches from happening in all relevant kernel
modules one by one from patch #2 to patch #9. Until now, as all
dependencies on sk_change_net() are killed, we can delete the
interface completely in patch #10. Lastly, we simplify the code of
creating kernel sockets through changing the original behaviours
of sock_create_kern() and sk_release_kernel(). If a kernel socket
is created within a namespace which is different with init_net,
we must put the reference counter of the namespace once the socket
is successfully allocated in sk_alloc(), otherwise, the namespace
is probably unable to be shut down finally. Therefore, we decrease
namespace's reference counter once a kernel socket is created
successfully by sock_create_kern() within a namespace which is
different with init_net. Similarly, namespace's reference counter
must be increased back before the socket is destroyed in
sk_release_kernel().

Welcome to any comments.

Ying Xue (11):
  netns: Fix race between put_net() and netlink_kernel_create()
  netlink: avoid unnecessary namespace switch when create netlink
    kernel sockets
  tun: avoid unnecessary namespace switch druing kernel socket creation
  inet: avoid unnecessary namespace switch during kernel socket
    creation
  udp_tunnel: avoid to switch namespace for tunnel socket
  ip6_udp_tunnel: avoid to switch namespace for tunnel socket
  l2tp: avoid to switch namespace for l2tp tunnel socket
  ipvs: avoid to switch namespace for ipvs kernel socket
  tipc: fix net leak issue
  tipc: remove sk_change_net interface
  net: change behaviours of functions of creating and releasing kernel
    sockets

 drivers/block/drbd/drbd_receiver.c |    6 ++++--
 drivers/net/tun.c                  |   14 +++++++++-----
 fs/afs/rxrpc.c                     |    3 ++-
 fs/dlm/lowcomms.c                  |   16 ++++++++--------
 include/linux/net.h                |    3 ++-
 include/net/sock.h                 |   16 ----------------
 net/bluetooth/rfcomm/core.c        |    3 ++-
 net/ceph/messenger.c               |    4 ++--
 net/core/net_namespace.c           |   10 ++++++++--
 net/core/sock.c                    |    5 ++---
 net/ipv4/af_inet.c                 |    4 +---
 net/ipv4/udp_tunnel.c              |    4 +---
 net/ipv6/ip6_udp_tunnel.c          |    4 +---
 net/l2tp/l2tp_core.c               |   12 ++++--------
 net/netfilter/ipvs/ip_vs_sync.c    |   16 ++--------------
 net/netlink/af_netlink.c           |    7 ++++---
 net/rxrpc/ar-local.c               |    4 ++--
 net/socket.c                       |    9 +++++++--
 net/tipc/server.c                  |    5 +++++
 19 files changed, 66 insertions(+), 79 deletions(-)

-- 
1.7.9.5
