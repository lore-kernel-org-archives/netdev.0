From: Liu Ping Fan <kernelfans@gmail.com>
Subject: [RFC:kvm] export host NUMA info to guest & make
	emulated device NUMA attr
Date: Thu, 17 May 2012 17:20:52 +0800
Message-ID: <1337246456-30909-1-git-send-email-kernelfans@gmail.com>
Cc: Krishna Kumar <krkumar2@in.ibm.com>, Shirley Ma <xma@us.ibm.com>,
	Tom Lendacky <toml@us.ibm.com>,
	"Michael S. Tsirkin" <mst@redhat.com>, qemu-devel@nongnu.org,
	Rusty Russell <rusty@rustcorp.com.au>,
	Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>,
	linux-kernel@vger.kernel.org, Ryan Harper <ryanh@us.ibm.com>,
	Avi Kivity <avi@redhat.com>, Anthony Liguori <anthony@codemonkey.ws>
To: kvm@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org>
List-Unsubscribe: <https://lists.nongnu.org/mailman/options/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=unsubscribe>
List-Archive: <http://lists.nongnu.org/archive/html/qemu-devel>
List-Post: <mailto:qemu-devel@nongnu.org>
List-Help: <mailto:qemu-devel-request@nongnu.org?subject=help>
List-Subscribe: <https://lists.nongnu.org/mailman/listinfo/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=subscribe>
Errors-To: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
Sender: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
List-Id: netdev.vger.kernel.org

Currently, the guest can not know the NUMA info of the vcpu, which will
result in performance drawback.

This is the discovered and experiment by
        Shirley Ma <xma@us.ibm.com>
        Krishna Kumar <krkumar2@in.ibm.com>
        Tom Lendacky <toml@us.ibm.com>
Refer to - http://www.mail-archive.com/kvm@vger.kernel.org/msg69868.html
we can see the big perfermance gap between NUMA aware and unaware.

Enlightened by their discovery, I think, we can do more work -- that is to
export NUMA info of host to guest.

So here comes the idea:
1. export host numa info through guest's sched domain to its scheduler
  Export vcpu's NUMA info to guest scheduler(I think mem NUMA problem
  has been handled by host).  So the guest's lb will consider the cost.
  I am still working on this, and my original idea is to export these info
  through "static struct sched_domain_topology_level *sched_domain_topology"
  to guest.

2. Do a better emulation of virt mach exported to guest.
  In real world, the devices are limited by kinds of reasons to own the NUMA
  property. But as to Qemu, the device is emulated by thread, which inherit
  the NUMA attr in nature.  We can implement the device as components of many
  logic units, each of the unit is backed by a thread in different host node.
  Currently, I want to start the work on vhost. But I think, maybe in
  future, the iothread in Qemu can also has such attr.


Forgive me, for the limited time, I can not have more better understand of
vhost/virtio_net drivers. These patches are just draft, _FAR_, _FAR_ from work.
I will do more detail work for them in future.

To easy the review, the following is the sum up of the 2nd point of the idea.
As for the 1st point of the idea, it is not reflected in the patches.

--spread/shrink the vhost_workers over the host nodes as demanded from Qemu.
  And we can consider each vhost_worker as an independent net logic device
  embeded in physical device "vhost_net".  At the meanwhile, we spread vcpu
  threads over the host node. 
  The vrings on guest are allocated PAGE_SIZE align separately, so they can 
  will only be mapped into different host node, so vhost_worker in the same
  node can access it with the least cost. So does the vq on guest.

--virtio_net driver will changes and talk with the logic device. And which
  logic device it will talk to is determined by on which vcpu it is scheduled.

--the binding of vcpus and vhost_worker is implemented by: 
  for call direction, vq-a in the node-A will have a dedicated irq-a. And 
  we set the irq-a's affinity to vcpus in node-A.
  for kick direction, kick register-b trigger different eventfd-b which wake up
  vhost_worker-b.


Please give some comments and suggestion.

Thanks and regards,
pingfan
