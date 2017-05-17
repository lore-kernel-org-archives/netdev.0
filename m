From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next V5 0/9] vhost_net rx batch dequeuing
Date: Wed, 17 May 2017 12:14:36 +0800
Message-ID: <1494994485-12994-1-git-send-email-jasowang@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
To: mst@redhat.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series tries to implement rx batching for vhost-net. This is done
by batching the dequeuing from skb_array which was exported by
underlayer socket and pass the sbk back through msg_control to finish
userspace copying. This is also the requirement for more batching
implemention on rx path.

Tests shows at most 7.56% improvment bon rx pps on top of batch
zeroing and no obvious changes for TCP_STREAM/TCP_RR result.

Please review.

Thanks

Changes from V4:
- drop batch zeroing patch
- renew the performance numbers
- move skb pointer array out of vhost_net structure

Changes from V3:
- add batch zeroing patch to fix the build warnings

Changes from V2:
- rebase to net-next HEAD
- use unconsume helpers to put skb back on releasing
- introduce and use vhost_net internal buffer helpers
- renew performance numbers on top of batch zeroing

Changes from V1:
- switch to use for() in __ptr_ring_consume_batched()
- rename peek_head_len_batched() to fetch_skbs()
- use skb_array_consume_batched() instead of
  skb_array_consume_batched_bh() since no consumer run in bh
- drop the lockless peeking patch since skb_array could be resized, so
  it's not safe to call lockless one

Jason Wang (8):
  skb_array: introduce skb_array_unconsume
  ptr_ring: introduce batch dequeuing
  skb_array: introduce batch dequeuing
  tun: export skb_array
  tap: export skb_array
  tun: support receiving skb through msg_control
  tap: support receiving skb from msg_control
  vhost_net: try batch dequing from skb array

Michael S. Tsirkin (1):
  ptr_ring: add ptr_ring_unconsume

 drivers/net/tap.c         |  25 +++++++--
 drivers/net/tun.c         |  31 ++++++++---
 drivers/vhost/net.c       | 128 +++++++++++++++++++++++++++++++++++++++++++---
 include/linux/if_tap.h    |   5 ++
 include/linux/if_tun.h    |   5 ++
 include/linux/ptr_ring.h  | 120 +++++++++++++++++++++++++++++++++++++++++++
 include/linux/skb_array.h |  31 +++++++++++
 7 files changed, 327 insertions(+), 18 deletions(-)

-- 
2.7.4
