From: Eyal Birger <eyal.birger@gmail.com>
Subject: [PATCH net-next v2 0/7] net: move skb->dropcount to skb->cb[]
Date: Thu, 26 Feb 2015 21:06:57 +0200
Message-ID: <1424977624-649-1-git-send-email-eyal.birger@gmail.com>
Cc: willemb@google.com, edumazet@google.com, shmulik.ladkani@gmail.com,
	linux-bluetooth@vger.kernel.org, marcel@holtmann.org,
	netdev@vger.kernel.org, Eyal Birger <eyal.birger@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f170.google.com ([74.125.82.170]:43498 "EHLO
	mail-we0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753828AbbBZTHV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 14:07:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 977750076d98 ("af_packet: add interframe drop cmsg (v6)")
unionized skb->mark and skb->dropcount in order to allow recording
of the socket drop count while maintaining struct sk_buff size.

skb->dropcount was introduced since there was no available room
in skb->cb[] in packet sockets. However, its introduction led to
the inability to export skb->mark to userspace.

It was considered to alias skb->priority instead of skb->mark.
However, that would lead to the inabilty to export skb->priority
to userspace if desired. Such change may also lead to hard-to-find
issues as skb->priority is assumed to be alias free, and, as noted
by Shmulik Ladkani, is not 'naturally orthogonal' with other skb
fields.

This patch series follows the suggestions made by Eric Dumazet moving
the dropcount metric to skb->cb[], eliminating this problem
at the expense of 4 bytes less in skb->cb[] for protocol families
using it.

The patch series include compactization of bluetooth and packet
use of skb->cb[] as well as the infrastructure for placing dropcount
in skb->cb[].

---
Changes in v2:
- Rebase
- Receive const struct sock * in sock_skb_set_dropcount()
  per Eric Dumazet's suggestion
- struct bt_skb_cb compactization code improvements following
  suggestions from Shmulik Landani and David Laight
- Fix incorrect asignment to skb->dev in packet_rcv()
---

Eyal Birger (7):
  net: bluetooth: compact struct bt_skb_cb by inlining struct
    hci_req_ctrl
  net: bluetooth: compact struct bt_skb_cb by converting boolean fields
    to bit fields
  net: rxrpc: change call to sock_recv_ts_and_drops() on rxrpc recvmsg
    to sock_recv_timestamp()
  net: packet: use skb->dev as storage for skb orig len instead of
    skb->cb[]
  net: use common macro for assering skb->cb[] available size in
    protocol families
  net: add common accessor for setting dropcount on packets
  net: move skb->dropcount to skb->cb[]

 include/linux/skbuff.h            |  2 --
 include/net/bluetooth/bluetooth.h | 14 +++++---------
 include/net/sock.h                | 23 +++++++++++++++++++++++
 net/bluetooth/af_bluetooth.c      |  3 +--
 net/bluetooth/hci_core.c          | 12 ++++++------
 net/bluetooth/hci_event.c         |  4 ++--
 net/bluetooth/hci_request.c       |  6 +++---
 net/bluetooth/hci_sock.c          |  2 +-
 net/can/bcm.c                     |  2 +-
 net/can/raw.c                     |  6 +++---
 net/core/sock.c                   |  2 +-
 net/ipv4/af_inet.c                |  2 +-
 net/ipv4/tcp.c                    |  3 +--
 net/ipv6/af_inet6.c               |  2 +-
 net/packet/af_packet.c            | 15 +++++++--------
 net/rxrpc/ar-recvmsg.c            |  2 +-
 net/sctp/protocol.c               |  3 +--
 net/socket.c                      |  4 ++--
 18 files changed, 60 insertions(+), 47 deletions(-)

-- 
2.1.4
