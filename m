From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH v5 0/6] XDP for virtio_net
Date: Wed, 07 Dec 2016 12:10:47 -0800
Message-ID: <20161207200139.28121.4811.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
        john.fastabend@gmail.com, brouer@redhat.com
To: daniel@iogearbox.net, mst@redhat.com, shm@cumulusnetworks.com,
        davem@davemloft.net, tgraf@suug.ch, alexei.starovoitov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35534 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932297AbcLGULH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 15:11:07 -0500
Received: by mail-pg0-f65.google.com with SMTP id p66so24435599pga.2
        for <netdev@vger.kernel.org>; Wed, 07 Dec 2016 12:11:07 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This implements virtio_net for the mergeable buffers and big_packet
modes. I tested this with vhost_net running on qemu and did not see
any issues. For testing num_buf > 1 I added a hack to vhost driver
to only but 100 bytes per buffer.

There are some restrictions for XDP to be enabled and work well
(see patch 3) for more details.

  1. LRO must be off
  2. MTU must be less than PAGE_SIZE
  3. queues must be available to dedicate to XDP
  4. num_bufs received in mergeable buffers must be 1
  5. big_packet mode must have all data on single page

To test this I used pktgen in the hypervisor and ran the XDP sample
programs xdp1 and xdp2 from ./samples/bpf in the host. The default
mode that is used with these patches with Linux guest and QEMU/Linux
hypervisor is the mergeable buffers mode. I tested this mode for 2+
days running xdp2 without issues. Additionally I did a series of
driver unload/load tests to check the allocate/release paths.

To test the big_packets path I applied the following simple patch against
the virtio driver forcing big_packets mode,

--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -2242,7 +2242,7 @@ static int virtnet_probe(struct virtio_device *vdev)
                vi->big_packets = true;
 
        if (virtio_has_feature(vdev, VIRTIO_NET_F_MRG_RXBUF))
-               vi->mergeable_rx_bufs = true;
+               vi->mergeable_rx_bufs = false;
 
        if (virtio_has_feature(vdev, VIRTIO_NET_F_MRG_RXBUF) ||
            virtio_has_feature(vdev, VIRTIO_F_VERSION_1))

I then repeated the tests with xdp1 and xdp2. After letting them run
for a few hours I called it good enough.

Testing the unexpected case where virtio receives a packet across
multiple buffers required patching the hypervisor vhost driver to
convince it to send these unexpected packets. Then I used ping with
the -s option to trigger the case with multiple buffers. This mode
is not expected to be used but as MST pointed out per spec it is
not strictly speaking illegal to generate multi-buffer packets so we
need someway to handle these. The following patch can be used to
generate multiple buffers,


--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -1777,7 +1777,8 @@ static int translate_desc(struct vhost_virtqueue
*vq, u64

                _iov = iov + ret;
                size = node->size - addr + node->start;
-               _iov->iov_len = min((u64)len - s, size);
+               printk("%s: build 100 length headers!\n", __func__);
+               _iov->iov_len = min((u64)len - s, (u64)100);//size);
                _iov->iov_base = (void __user *)(unsigned long)
                        (node->userspace_addr + addr - node->start);
                s += size;

Please review any comments/feedback welcome as always.

Thanks,
John

---

John Fastabend (6):
      net: virtio dynamically disable/enable LRO
      net: xdp: add invalid buffer warning
      virtio_net: Add XDP support
      virtio_net: add dedicated XDP transmit queues
      virtio_net: add XDP_TX support
      virtio_net: xdp, add slowpath case for non contiguous buffers


 drivers/net/virtio_net.c |  403 +++++++++++++++++++++++++++++++++++++++++++++-
 include/linux/filter.h   |    1 
 net/core/filter.c        |    6 +
 3 files changed, 402 insertions(+), 8 deletions(-)
