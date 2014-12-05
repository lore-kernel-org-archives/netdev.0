From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: the next chunk of iov_iter-net stuff for review
Date: Fri, 5 Dec 2014 05:56:23 +0000
Message-ID: <20141205055623.GQ29748@ZenIV.linux.org.uk>
References: <1416924151-28698-1-git-send-email-viro@ZenIV.linux.org.uk>
 <20141125.142820.78809050565547546.davem@davemloft.net>
 <20141125205911.GA29748@ZenIV.linux.org.uk>
 <20141126.122727.1791815907895724977.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:51293 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750860AbaLEF40 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2014 00:56:26 -0500
Content-Disposition: inline
In-Reply-To: <20141126.122727.1791815907895724977.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	OK, here's the tentative next batch (covers most of the ->recvmsg()
side of conversion).  That's on top of merge of net-next#master with
vfs#iov_iter (the latter had been posted earlier today, Cc'd to netdev among
other places).  This series corresponds to vfs#for-davem.  Review and comments
would be very welcome...

Shortlog:
Al Viro (12):
      raw.c: stick msghdr into raw_frag_vec
      ipv6 equivalent of "ipv4: Avoid reading user iov twice after raw_probe_proto_opt"
      ip_generic_getfrag, udplite_getfrag: switch to passing msghdr
      switch tcp_sock->ucopy from iovec (ucopy.iov) to msghdr (ucopy.msg)
      switch l2cap ->memcpy_fromiovec() to msghdr
      vmci: propagate msghdr all way down to __qp_memcpy_from_queue()
      put iov_iter into msghdr
      first fruits - kill l2cap ->memcpy_fromiovec()
      switch memcpy_to_msg() and skb_copy{,_and_csum}_datagram_msg() to primitives
      ppp_read(): switch to skb_copy_datagram_iter()
      skb_copy_datagram_iovec() can die
      bury memcpy_toiovec()
Diffstat:
 crypto/algif_hash.c                      |   4 +-
 crypto/algif_skcipher.c                  |   4 +-
 drivers/misc/vmw_vmci/vmci_queue_pair.c  |  17 ++--
 drivers/net/macvtap.c                    |   8 +-
 drivers/net/ppp/ppp_generic.c            |   4 +-
 drivers/net/tun.c                        |   8 +-
 drivers/target/iscsi/iscsi_target_util.c |  12 ++-
 drivers/vhost/net.c                      |   8 +-
 fs/afs/rxrpc.c                           |  14 ++--
 include/linux/skbuff.h                   |  22 ++---
 include/linux/socket.h                   |   3 +-
 include/linux/tcp.h                      |   2 +-
 include/linux/uio.h                      |   1 -
 include/linux/vmw_vmci_api.h             |   5 +-
 include/net/bluetooth/l2cap.h            |  29 -------
 include/net/udplite.h                    |   4 +-
 lib/iovec.c                              |  25 ------
 net/atm/common.c                         |   5 +-
 net/bluetooth/6lowpan.c                  |   7 +-
 net/bluetooth/a2mp.c                     |   4 +-
 net/bluetooth/l2cap_core.c               |   7 +-
 net/bluetooth/l2cap_sock.c               |   8 --
 net/bluetooth/smp.c                      |   5 +-
 net/caif/caif_socket.c                   |   2 +-
 net/compat.c                             |  10 ++-
 net/core/datagram.c                      | 138 +++++--------------------------
 net/ipv4/ip_output.c                     |   8 +-
 net/ipv4/ping.c                          |   3 +-
 net/ipv4/raw.c                           |  11 +--
 net/ipv4/tcp.c                           |   8 +-
 net/ipv4/tcp_input.c                     |   7 +-
 net/ipv4/tcp_output.c                    |   2 +-
 net/ipv4/udp.c                           |   4 +-
 net/ipv6/ping.c                          |   3 +-
 net/ipv6/raw.c                           | 115 +++++++++++++-------------
 net/ipv6/udp.c                           |   2 +-
 net/l2tp/l2tp_ip6.c                      |   2 +-
 net/netlink/af_netlink.c                 |   2 +-
 net/packet/af_packet.c                   |   7 +-
 net/rds/recv.c                           |   7 +-
 net/rds/send.c                           |   4 +-
 net/rxrpc/ar-output.c                    |   8 +-
 net/sctp/socket.c                        |   5 +-
 net/socket.c                             |  27 +++---
 net/tipc/msg.c                           |   4 +-
 net/tipc/socket.c                        |   4 +-
 net/unix/af_unix.c                       |  10 +--
 net/vmw_vsock/vmci_transport.c           |   7 +-
 48 files changed, 204 insertions(+), 402 deletions(-)
