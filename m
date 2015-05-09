From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 0/6] Cleanup the kernel sockets.
Date: Fri, 08 May 2015 21:05:33 -0500
Message-ID: <87383633pu.fsf_-_@x220.int.ebiederm.org>
References: <1430988770-28907-1-git-send-email-ying.xue@windriver.com>
	<87wq0kcqlm.fsf@x220.int.ebiederm.org>
	<20150508140733.GA13325@gondor.apana.org.au>
	<87sib76kef.fsf@x220.int.ebiederm.org>
	<20150509011339.GA19116@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ying Xue <ying.xue@windriver.com>, netdev@vger.kernel.org,
	cwang@twopensource.com, xemul@openvz.org, eric.dumazet@gmail.com,
	maxk@qti.qualcomm.com, stephen@networkplumber.org, tgraf@suug.ch,
	nicolas.dichtel@6wind.com, tom@herbertland.com,
	jchapman@katalix.com, erik.hugne@ericsson.com,
	jon.maloy@ericsson.com, horms@verge.net.au,
	Herbert Xu <herbert@gondor.apana.org.au>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:37291 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751389AbbEICKI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2015 22:10:08 -0400
In-Reply-To: <20150509011339.GA19116@gondor.apana.org.au> (Herbert Xu's
	message of "Sat, 9 May 2015 09:13:39 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Right now the situtation for allocating kernel sockets is a mess.
- sock_create_kern does not take a namespace parameter.
- kernel sockets must not reference count a network namespace and keep
  it alive or else we will have a reference counting loop.
- The way we avoid the reference counting loop with sk_change_net
  and sk_release_kernel are major hacks.

This patchset addresses this mess by fixing sock_create_kern to do
everything necessary to create a kernel socket.  None of the current
users of kernel sockets need the network namespace reference counted.
Either kernel sockets are network namespace aware (and using the current
hacks) or kernel sockets are limited to the initial network namespace
in which case it does not matter.

This patchset starts by addressing tun which should be using normal
userspace sockets like macvtap.

Then sock_create_kern is fixed to take a network namespace.
Then the in kernel status of sockets are passed through to sk_alloc.
Then sk_alloc is fixed to not reference count the network namespace
     of kernel sockets.
Then the callers of sock_create_kern are fixed up to stop using hacks.
Then netlink which uses it's own flavor of sock_create_kern is fixed.

Finally the hacks that are sk_change_net and sk_release_kernel are removed.

When it is all done the code is easier to follow, easier to use, easier
to maintain and shorter by about 70 lines.

Reported-by: Ying Xue <ying.xue@windriver.com>

Eric W. Biederman (6):
      tun: Utilize the normal socket network namespace refcounting.
      net: Add a struct net parameter to sock_create_kern
      net: Pass kern from net_proto_family.create to sk_alloc
      net: Modify sk_alloc to not reference count the netns of kernel sockets.
      netlink: Create kernel netlink sockets in the proper network namespace
      net: kill sk_change_net and sk_release_kernel

 crypto/af_alg.c                    |  4 ++--
 drivers/block/drbd/drbd_receiver.c |  4 ++--
 drivers/isdn/mISDN/socket.c        | 12 ++++++------
 drivers/net/macvtap.c              |  2 +-
 drivers/net/ppp/pppoe.c            |  4 ++--
 drivers/net/ppp/pppox.c            |  2 +-
 drivers/net/ppp/pptp.c             |  4 ++--
 drivers/net/tun.c                  | 26 +++++---------------------
 fs/afs/rxrpc.c                     |  2 +-
 fs/dlm/lowcomms.c                  | 16 ++++++++--------
 include/linux/if_pppox.h           |  2 +-
 include/linux/net.h                |  3 +--
 include/net/af_vsock.h             |  2 +-
 include/net/inet_common.h          |  2 +-
 include/net/llc_conn.h             |  2 +-
 include/net/sock.h                 | 21 +++------------------
 net/appletalk/ddp.c                |  2 +-
 net/atm/common.c                   |  4 ++--
 net/atm/common.h                   |  2 +-
 net/atm/pvc.c                      |  2 +-
 net/atm/svc.c                      |  2 +-
 net/ax25/af_ax25.c                 |  4 ++--
 net/bluetooth/bnep/sock.c          |  2 +-
 net/bluetooth/cmtp/sock.c          |  2 +-
 net/bluetooth/hci_sock.c           |  2 +-
 net/bluetooth/hidp/sock.c          |  2 +-
 net/bluetooth/l2cap_sock.c         | 10 +++++-----
 net/bluetooth/rfcomm/core.c        |  2 +-
 net/bluetooth/rfcomm/sock.c        |  8 ++++----
 net/bluetooth/sco.c                |  8 ++++----
 net/caif/caif_socket.c             |  2 +-
 net/can/af_can.c                   |  2 +-
 net/ceph/messenger.c               |  4 ++--
 net/core/sock.c                    | 30 ++++++++----------------------
 net/decnet/af_decnet.c             |  8 ++++----
 net/ieee802154/socket.c            |  2 +-
 net/ipv4/af_inet.c                 |  6 ++----
 net/ipv4/udp_tunnel.c              |  8 +++-----
 net/ipv6/af_inet6.c                |  2 +-
 net/ipv6/ip6_udp_tunnel.c          |  6 ++----
 net/ipx/af_ipx.c                   |  2 +-
 net/irda/af_irda.c                 |  2 +-
 net/iucv/af_iucv.c                 | 10 +++++-----
 net/key/af_key.c                   |  2 +-
 net/l2tp/l2tp_core.c               | 15 ++++++---------
 net/l2tp/l2tp_ppp.c                |  4 ++--
 net/llc/af_llc.c                   |  2 +-
 net/llc/llc_conn.c                 |  6 +++---
 net/netfilter/ipvs/ip_vs_sync.c    | 30 +++++++++---------------------
 net/netlink/af_netlink.c           | 21 +++++++++------------
 net/netrom/af_netrom.c             |  4 ++--
 net/nfc/af_nfc.c                   |  2 +-
 net/nfc/llcp.h                     |  2 +-
 net/nfc/llcp_core.c                |  2 +-
 net/nfc/llcp_sock.c                |  8 ++++----
 net/nfc/nfc.h                      |  2 +-
 net/nfc/rawsock.c                  |  4 ++--
 net/packet/af_packet.c             |  2 +-
 net/phonet/af_phonet.c             |  2 +-
 net/phonet/pep.c                   |  2 +-
 net/rds/af_rds.c                   |  2 +-
 net/rose/af_rose.c                 |  4 ++--
 net/rxrpc/af_rxrpc.c               |  2 +-
 net/rxrpc/ar-local.c               |  4 ++--
 net/sctp/ipv6.c                    |  2 +-
 net/sctp/protocol.c                |  2 +-
 net/socket.c                       |  7 ++-----
 net/tipc/socket.c                  |  2 +-
 net/unix/af_unix.c                 |  8 ++++----
 net/vmw_vsock/af_vsock.c           |  7 ++++---
 net/vmw_vsock/vmci_transport.c     |  2 +-
 net/x25/af_x25.c                   |  8 ++++----
 72 files changed, 166 insertions(+), 238 deletions(-)
