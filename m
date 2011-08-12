From: Jason Wang <jasowang@redhat.com>
Subject: [net-next RFC PATCH 0/7] multiqueue support for tun/tap
Date: Fri, 12 Aug 2011 09:54:39 +0800
Message-ID: <20110812015221.31613.95001.stgit@intel-e5620-16-2.englab.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, rusty@rustcorp.com.au, qemu-devel@nongnu.org,
	kvm@vger.kernel.org, mirq-linux@rere.qmqm.pl
To: mst@redhat.com, netdev@vger.kernel.org, jasowang@redhat.com,
	linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, davem@davemloft.net
Return-path: <qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org>
List-Unsubscribe: <https://lists.nongnu.org/mailman/options/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=unsubscribe>
List-Archive: </archive/html/qemu-devel>
List-Post: <mailto:qemu-devel@nongnu.org>
List-Help: <mailto:qemu-devel-request@nongnu.org?subject=help>
List-Subscribe: <https://lists.nongnu.org/mailman/listinfo/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=subscribe>
Errors-To: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
Sender: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
List-Id: netdev.vger.kernel.org

As multi-queue nics were commonly used for high-end servers,
current single queue based tap can not satisfy the
requirement of scaling guest network performance as the
numbers of vcpus increase. So the following series
implements multiple queue support in tun/tap.

In order to take advantages of this, a multi-queue capable
driver and qemu were also needed. I just rebase the latest
version of Krishna's multi-queue virtio-net driver into this
series to simplify the test. And for multiqueue supported
qemu, you can refer the patches I post in
http://www.spinics.net/lists/kvm/msg52808.html. Vhost is
also a must to achieve high performance and its code could
be used for multi-queue without modification. Alternatively,
this series can be also used for Krishna's M:N
implementation of multiqueue but I didn't test it.

The idea is simple: each socket were abstracted as a queue
for tun/tap, and userspace may open as many files as
required and then attach them to the devices. In order to
keep the ABI compatibility, device creation were still
finished in TUNSETIFF, and two new ioctls TUNATTACHQUEUE and
TUNDETACHQUEUE were added for user to manipulate the numbers
of queues for the tun/tap.

I've done some basic performance testing of multi queue
tap. For tun, I just test it through vpnc.

Notes:
- Test shows improvement when receving packets from
local/external host to guest, and send big packet from guest
to local/external host.
- Current multiqueue based virtio-net/tap introduce a
regression of send small packet (512 byte) from guest to
local/external host. I suspect it's the issue of queue
selection in both guest driver and tap. Would continue to
investigate.
- I would post the perforamnce numbers as a reply of this
mail.

TODO:
- solve the issue of packet transmission of small packets.
- addressing the comments of virtio-net driver
- performance tunning

Please review and comment it, Thanks.

---

Jason Wang (5):
      tuntap: move socket/sock related structures to tun_file
      tuntap: categorize ioctl
      tuntap: introduce multiqueue related flags
      tuntap: multiqueue support
      tuntap: add ioctls to attach or detach a file form tap device

Krishna Kumar (2):
      Change virtqueue structure
      virtio-net changes


 drivers/net/tun.c           |  738 ++++++++++++++++++++++++++-----------------
 drivers/net/virtio_net.c    |  578 ++++++++++++++++++++++++----------
 drivers/virtio/virtio_pci.c |   10 -
 include/linux/if_tun.h      |    5 
 include/linux/virtio.h      |    1 
 include/linux/virtio_net.h  |    3 
 6 files changed, 867 insertions(+), 468 deletions(-)

-- 
Jason Wang
