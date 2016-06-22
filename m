From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH 0/3] basic device IOTLB support
Date: Wed, 22 Jun 2016 05:50:44 -0400
Message-ID: <1466589047-2271-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: vkaplans@redhat.com, wexu@redhat.com, peterx@redhat.com
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

Have a benchmark on this. Test was done with l2fwd in guest.For 2MB
page, no difference in 64B performance and I notice a 4%-5% drop for
1500B performance compare to UIO in guest. We can add some shortcut to
bypass the IOTLB for virtqueue accessing, but I think it's better to
do this on top.

Changes from RFC V3:
- rebase on latest
- minor tweak on commit log
- use VHOST_ACCESS_RO instead of VHOST_ACCESS_WO in vhost_copy_from_user()
- switch to use atomic userspace access helper in vhost_get/put_user()
- remove debug codes in vhost_iotlb_miss()
- use FIFO instead of FILO when doing TLB replacement
- fix unbalanced lock in vhost_process_iotlb_msg()

Changes from RFC V2:
- introduce memory accessors for vhost
- switch from ioctls to oridinary file read/write for iotlb miss and
  updating
- do not assume virtqueue were virtually mapped contiguously, all
  virtqueue access were done throug IOTLB
- verify memory access during IOTLB update and fail early
- introduce a module parameter for the size of IOTLB

Changes from RFC V1:
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
 drivers/vhost/vhost.c      | 799 +++++++++++++++++++++++++++++++++++++++------
 drivers/vhost/vhost.h      |  60 +++-
 include/uapi/linux/vhost.h |  28 ++
 4 files changed, 829 insertions(+), 121 deletions(-)

-- 
1.8.3.1
