From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next V4 0/6] switch to use tx skb array in tun
Date: Thu, 30 Jun 2016 14:45:30 +0800
Message-ID: <1467269136-8082-1-git-send-email-jasowang@redhat.com>
Cc: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
	eric.dumazet@gmail.com, brouer@redhat.com,
	Jason Wang <jasowang@redhat.com>
To: mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all:

This series tries to switch to use skb array in tun. This is used to
eliminate the spinlock contention between producer and consumer. The
conversion was straightforward: just introdce a tx skb array and use
it instead of sk_receive_queue.

A minor issue is to keep the tx_queue_len behaviour, since tun used to
use it for the length of sk_receive_queue. This is done through:

- add the ability to resize multiple rings at once to avoid handling
  partial resize failure for mutiple rings.
- add the support for zero length ring.
- introduce a notifier which was triggered when tx_queue_len was
  changed for a netdev.
- resize all queues during the tx_queue_len changing.

Tests shows about 15% improvement on guest rx pps:

Before: ~1300000pps
After : ~1500000pps

Changes from V3:
- fix kbuild warnings
- call NETDEV_CHANGE_TX_QUEUE_LEN on IFLA_TXQLEN

Changes from V2:
- add multiple rings resizing support for ptr_ring/skb_array
- add zero length ring support
- introdce a NETDEV_CHANGE_TX_QUEUE_LEN
- drop new flags

Changes from V1:
- switch to use skb array instead of a customized circular buffer
- add non-blocking support
- rename .peek to .peek_len
- drop lockless peeking since test show very minor improvement

Jason Wang (5):
  ptr_ring: support zero length ring
  skb_array: minor tweak
  skb_array: add wrappers for resizing
  net: introduce NETDEV_CHANGE_TX_QUEUE_LEN
  tun: switch to use skb array for tx

Michael S. Tsirkin (1):
  ptr_ring: support resizing multiple queues

 drivers/net/tun.c                | 138 ++++++++++++++++++++++++++++++++++++---
 drivers/vhost/net.c              |  16 ++++-
 include/linux/net.h              |   1 +
 include/linux/netdevice.h        |   1 +
 include/linux/ptr_ring.h         |  77 ++++++++++++++++++----
 include/linux/skb_array.h        |  13 +++-
 net/core/net-sysfs.c             |  15 ++++-
 net/core/rtnetlink.c             |  16 +++--
 tools/virtio/ringtest/ptr_ring.c |   5 ++
 9 files changed, 255 insertions(+), 27 deletions(-)

-- 
2.7.4
