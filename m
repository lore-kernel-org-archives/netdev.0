From: Jason Wang <jasowang@redhat.com>
Subject: [net-next resend v4 0/7] Multiqueue support in tuntap
Date: Mon, 29 Oct 2012 14:15:44 +0800
Message-ID: <1351491351-11477-1-git-send-email-jasowang@redhat.com>
Cc: maxk@qualcomm.com, edumazet@google.com, krkumar2@in.ibm.com,
	ernesto.martin@viasat.com, haixiao@juniper.net,
	Jason Wang <jasowang@redhat.com>
To: mst@redhat.com, davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello All:

This is an update of multiqueue support in tuntap from V3. Please consider to
merge.

The main idea for this series is to let tun/tap device to be benefited from
multiqueue network cards and multi-core host. We used to have a single queue for
tuntap which could be a bottleneck in a multiqueue/core environment. So this
series let the device could be attched with multiple sockets and expose them
through fd to the userspace as multiqueues. The sereis were orignally designed
to serve as backend for multiqueue virtio-net in KVM, but the design is generic
for other application to be used.

Some quick overview of the design:

- Moving socket from tun_device to tun_file.
- Allowing multiple sockets to be attached to a tun/tap devices.
- Using RCU to synchronize the data path and system call.
- Two new ioctls were added for the usespace to attach and detach socket to the device.
- API compatibility were maintained without userspace notable changes, so legacy
  userspace that only use one queue won't need any changes.
- A flow(rxhash) to queue table were maintained by tuntap which choose the txq
  based on the last rxq where it comes.

Performance test:

Pktgen is used to generate the traffic and a simple program that only does the
receiving in userspace.

#q #thread  kpps     aggregate kpps
1q 1thread  818kpps  +0%
2q 2threads 1926kpps +135%
3q 3threads 2642kpps +223%
4q 4threads 3536kpps +332%

Changes from V3:
- Rebase to net-next
- A separate RCUiying patch to simply the reviewing
- Add a simple "tx follows rx" policy when choosing txq
- Various bug fixes

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

Reference:
- V3 https://lkml.org/lkml/2012/6/25/191
- V2 http://lwn.net/Articles/459270/
- V1 http://www.mail-archive.com/kvm@vger.kernel.org/msg59479.html

Jason Wang (7):
  tuntap: log the unsigned informaiton with %u
  tuntap: move socket to tun_file
  tuntap: RCUify dereferencing between tun_struct and tun_file
  tuntap: introduce multiqueue flags
  tuntap: multiqueue support
  tuntap: add ioctl to attach or detach a file form tuntap device
  tuntap: choose the txq based on rxq

 drivers/net/tun.c           |  845 ++++++++++++++++++++++++++++++++-----------
 include/uapi/linux/if_tun.h |    5 +
 2 files changed, 640 insertions(+), 210 deletions(-)
