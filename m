From: Jason Wang <jasowang@redhat.com>
Subject: [RFC PATCH V2 0/2] basic device IOTLB support
Date: Fri, 25 Mar 2016 10:34:32 +0800
Message-ID: <1458873274-13961-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pbonzini@redhat.com, qemu-devel@nongnu.org, peterx@redhat.com
To: mst@redhat.com, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
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

This patch tries to implement an device IOTLB for vhost. This could be
used with for co-operation with userspace(qemu) implementation of
iommu for a secure DMA environment (DMAR) in guest.

The idea is simple. When vhost meets an IOTLB miss, it will request
the assistance of userspace to do the translation, this is done
through:

- Fill the translation request in a preset userspace address (This
  address is set through ioctl VHOST_SET_IOTLB_REQUEST_ENTRY).
- Notify userspace through eventfd (This eventfd was set through ioctl
  VHOST_SET_IOTLB_FD).

When userspace finishes the translation, it will update the vhost
IOTLB through VHOST_UPDATE_IOTLB ioctl. Userspace is also in charge of
snooping the IOTLB invalidation of IOMMU IOTLB and use
VHOST_UPDATE_IOTLB to invalidate the possible entry in vhost.

The codes were designed to be architecture independent. It should be
easily ported to any architecture.

Changes from V1:
- support any size/range of updating and invalidation through
  introducing the interval tree.
- convert from per device iotlb request to per virtqueue iotlb
  request, this solves the possible deadlock in V1.
- read/write permission check support.

Please review.

Thanks

Jason Wang (2):
  vhost: convert pre sorted vhost memory array to interval tree
  vhost: device IOTLB API

 drivers/vhost/net.c        |  14 +-
 drivers/vhost/vhost.c      | 427 +++++++++++++++++++++++++++++++++++----------
 drivers/vhost/vhost.h      |  42 ++++-
 fs/eventfd.c               |   3 +-
 include/uapi/linux/vhost.h |  35 ++++
 5 files changed, 419 insertions(+), 102 deletions(-)

-- 
2.5.0
