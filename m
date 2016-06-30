From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next V3 0/6] switch to use tx skb array in tun
Date: Thu, 30 Jun 2016 11:52:53 +0800
Message-ID: <1467258779-3539-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, eric.dumazet@gmail.com, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: mst@redhat.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net
Return-path: <virtualization-bounces@lists.linux-foundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
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
 tools/virtio/ringtest/ptr_ring.c |   5 ++
 8 files changed, 243 insertions(+), 23 deletions(-)

-- 
2.7.4
