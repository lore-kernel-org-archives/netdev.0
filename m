From: Jason Wang <jasowang@redhat.com>
Subject: [net-next RFC V3 0/6] Multiqueue support in tun/tap
Date: Mon, 25 Jun 2012 19:59:17 +0800
Message-ID: <1340625563-9300-1-git-send-email-jasowang@redhat.com>
References: <20120625060830.6765.27584.stgit@amd-6168-8-1.englab.nay.redhat.com>
Cc: shemminger@vyatta.com, edumazet@google.com,
	Jason Wang <jasowang@redhat.com>
To: mst@redhat.com, akong@redhat.com, habanero@linux.vnet.ibm.com,
	tahm@linux.vnet.ibm.com, haixiao@juniper.net,
	jwhan@filewood.snu.ac.kr, ernesto.martin@viasat.com,
	mashirle@us.ibm.com, davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, krkumar2@in.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120625060830.6765.27584.stgit@amd-6168-8-1.englab.nay.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello All:

This is an update of multiqueue support in tun/tap from V2. Please consider to
merge.

The main idea for this series is to let tun/tap device to benefit from
multiqueue network cards and multi-cores host by letting it to be able to
transmit and receive packets from mmultiple sockets/queues. This series allows
multiple sockets to be attached and detached to the tun/tap devices. Userspace
could utilize this parallism to achiveve higher throughput.

Some quick overview of the design:

- Moving socket from tun_device to tun_file.
- Allowing multiple sockets to be attached to a tun/tap devices.
- Using RCU to synchronize the data path and system call.
- A simple hash based queue selecting algorithm is used to choose the tx queue.
- Two new ioctls were added for the usespace to attach and detach socket to the device.
- ABI compatibility were maintained, userspace that only use one queue won't
 need any changes.

Performance test:

This series were originally designed to serve as the backend of the multiqueue
virito-net in kvm guest. But the design is generic enough to let it to be reused
by any other type of userspace.

Since I would post a series of multiqueue virtio-net as RFC, so I would post the
performance result in that thread. To summarize the performance, the multiqueue
improves the transaction in the TCP_RR test but have some regression in small
packets transmission in TCP_STREAM test.

Martin test the multiqueue tap for their userspace, and he see an improvement in
terms of packets per second.

References:
- V2 of multiqueue tun/tap, http://lwn.net/Articles/459270/
- V1 of multiqueue tun/tap, http://www.mail-archive.com/kvm@vger.kernel.org/msg59479.html

Changes from V2:

- Rebase to the latest net-next
- Fix netdev leak when tun_attach fails
- Fix return value of TUNSETOWNER
- Purge the receive queue in socket destructor
- Enable multiqueue tun (V1 and V2 only allows mq to be eanbled for tap
- Add per-queue u64 statistics
- Fix wrong BUG_ON() check in tun_detach()
- Check numqueues instead of tfile[0] in tun_set_iff() to let tunctl -d works
  correctly
- Set numqueues to MAX_TAP_QUEUES during tun_detach_all() to prevent the
  attaching.

Changes from V1:

- Simplify the sockets array management by not leaving NULL in the slot.
- Optimization on the tx queue selecting.
- Fix the bug in tun_deatch_all()

Jason Wang (6):
  tuntap: move socket to tun_file
  tuntap: categorize ioctl
  tuntap: introduce multiqueue flags
  tuntap: multiqueue support
  tuntap: per queue 64 bit stats
  tuntap: add ioctls to attach or detach a file form tuntap device

 drivers/net/tun.c      |  797 ++++++++++++++++++++++++++++++------------------
 include/linux/if_tun.h |    5 +
 2 files changed, 503 insertions(+), 299 deletions(-)
