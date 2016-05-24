From: Jason Wang <jasowang@redhat.com>
Subject: [RFC PATCH V3 0/3] basic device IOTLB support
Date: Tue, 24 May 2016 17:36:22 +0800
Message-ID: <1464082585-13049-1-git-send-email-jasowang@redhat.com>
Cc: wexu@redhat.com, peterx@redhat.com, vkaplans@redhat.com,
	Jason Wang <jasowang@redhat.com>
To: mst@redhat.com, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch tries to implement an device IOTLB for vhost. This could be
used with for co-operation with userspace IOMMU implementation (qemu)
for a secure DMA environment (DMAR) in guest.

The idea is simple. When vhost meets an IOTLB miss, it will request
the assistance of userspace to do the translation, this is done
through:

- when there's a IOTLB miss, it will notify userspace through
  vhost_net fd and then userspace read the fault address, size and
  access from vhost fd.
- userspace write the translation result back to vhost fd, vhost can
  then update its IOTLB.

The codes were optimized for fixed mapping users e.g dpdk in guest. It
will be slow if dynamic mappings were used in guest. We could do
optimizations on top.

The codes were designed to be architecture independent. It should be
easily ported to any architecture.

Stress tested with l2fwd/vfio in guest with 4K/2M/1G page size. On 1G
hugepage case, 100% TLB hit rate were noticed.

Changes from V2:
- introduce memory accessors for vhost
- switch from ioctls to oridinary file read/write for iotlb miss and
  updating
- do not assume virtqueue were virtually mapped contiguously, all
  virtqueue access were done throug IOTLB
- verify memory access during IOTLB update and fail early
- introduce a module parameter for the size of IOTLB

Changes from V1:
- support any size/range of updating and invalidation through
  introducing the interval tree.
- convert from per device iotlb request to per virtqueue iotlb
  request, this solves the possible deadlock in V1.
- read/write permission check support.

Please review.

Jason Wang (3):
  vhost: introduce vhost memory accessors
  vhost: convert pre sorted vhost memory array to interval tree
  vhost: device IOTLB API

 drivers/vhost/net.c        |  63 +++-
 drivers/vhost/vhost.c      | 760 ++++++++++++++++++++++++++++++++++++++-------
 drivers/vhost/vhost.h      |  60 +++-
 include/uapi/linux/vhost.h |  28 ++
 4 files changed, 790 insertions(+), 121 deletions(-)

-- 
2.7.4
