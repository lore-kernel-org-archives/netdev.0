From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next v3 0/3] Multiqueue support in virtio-net
Date: Sat,  8 Dec 2012 01:04:54 +0800
Message-ID: <1354899897-10423-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, kvm@vger.kernel.org, bhutchings@solarflare.com,
	jwhan@filewood.snu.ac.kr, shiyer@redhat.com
To: mst@redhat.com, rusty@rustcorp.com.au, davem@davemloft.net,
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

Hi all:

This series is an update version (hope the final version) of multiqueue
(VIRTIO_NET_F_MQ) support in virtio-net driver. All previous comments were
addressed, the work were based on Krishna Kumar's work to let virtio-net use
multiple rx/tx queues to do the packets reception and transmission. Performance
test show the aggregate latency were increased greately but may get some
regression in small packet transmission. Due to this, multiqueue were disabled
by default. If user want to benefit form the multiqueue, ethtool -L could be
used to enable the feature.

Please review and comments.

A protype implementation of qemu-kvm support could by found in
git://github.com/jasowang/qemu-kvm-mq.git. To start a guest with two queues, you
could specify the queues parameters to both tap and virtio-net like:

./qemu-kvm -netdev tap,queues=2,... -device virtio-net-pci,queues=2,...

then enable the multiqueue through ethtool by:

ethtool -L eth0 combined 2

Changes from V2:
Align the implementation to V6 virtio-spec
- Change the name of feature and name from _{RFS|rfs} to _{MQ|mq}

Changes from V1:
Addressing Michael's comments:
- fix typos in commit log
- don't move virtnet_open()
- don't set to NULL in virtnet_free_queues()
- style & comment fixes
- conditionally set the irq affinity hint based on online cpus and queue pairs
- move the virnet_del_vqs to patch 1
- change the meaningless kzalloc() to kmalloc()
- open code the err handling
- store the name of virtqueue in send/receive queue
- avoid type cast in virtnet_find_vqs()
- fix the mem leak and freeing issue of names in virtnet_find_vqs()
- check cvq during before setting the max_queue_pairs in virtnet_probe()
- check the cvq and VIRTIO_NET_F_RFS in virtnet_set_queues()
- set the curr_queue_pairs in virtnet_set_queue()
- use the err report by virtnet_set_queue() as the return value of
  ethtool_set_channels()

Changes from RFC v7:
Addressing Rusty's comments:
- align the implementation (location of cvq) to v5.
- fix the style issue.
- use a global refill instead of per-vq one.
- check the VIRTIO_NET_F_RFS before calling virtnet_set_queues()

Addresing Michael's comments
- rename the curr_queue_pairs in virtnet_probe() to max_queue_pairs
- validate the number of queue pairs supported by the device against
  VIRTIO_NET_CTRL_RFS_VQ_PAIRS_MIN and VIRTIO_NET_CTRL_RFS_VQ_PAIRS_MAX.
- don't crash when failing to change the number of virtqueues
- don't set the affinity hint when onle single queue is used or there's too much
  virtqueues
- add a TODO of handling cpu hotplug
- allow user to set the nubmer of queue pairs between 1 and max_queue_pairs

Changes from RFC v6:
- Align the implementation with the RFC spec update v5
- Addressing Rusty's comments:
  * split the patches
  * rename to max_queue_pairs and curr_queue_pairs
  * remove the useless status
  * fix the hibernation bug
- Addressing Ben's comments:
  * check other parameters in ethtool_set_queues

Changes from RFC v5:
- Align the implementation with the RFC spec update v4
- Switch the mode between single mode and multiqueue mode without reset
- Remove the 256 limitation of queues
- Use helpers to do the mapping between virtqueues and tx/rx queues
- Use commbined channels instead of separated rx/tx queus when do the queue
  number configuartion
- Other coding style comments from Michael

Changes from RFC v4:
- Add ability to negotiate the number of queues through control virtqueue
- Ethtool -{L|l} support and default the tx/rx queue number to 1
- Expose the API to set irq affinity instead of irq itself

Changes from RFC v3:
- Rebase to the net-next
- Let queue 2 to be the control virtqueue to obey the spec
- Prodives irq affinity
- Choose txq based on processor id

Reference:
- V6 virtio-spec: http://marc.info/?l=linux-netdev&m=135488976031512&w=2
- V2: https://lkml.org/lkml/2012/12/5/90
- V1: https://lkml.org/lkml/2012/11/27/177
- RFC V7: https://lkml.org/lkml/2012/11/27/177a
- RFC V6: https://lkml.org/lkml/2012/10/30/127
- RFC V5: http://lwn.net/Articles/505388/
- RFC V4: https://lkml.org/lkml/2012/6/25/120
- RFC V2: http://lwn.net/Articles/467283/

Perf Numbers:
- pktgen shows multqueue has much more ability to send/receive more packets
  comapred to single queue.
- netperf request-reponse test shows multiqueue improves a lot in aggregate
  latency.
- netperf stream test shows some regression especially for small packets since
  TCP batch less when latency is improved.

1 Pktgen test:

1.0 Test Environment:

One 2.0G AMD Opteron(tm) Processor 6168. Pktgen to stress the virtio-net in
guest to test Guest TX. Pktgen to stress tap in host to test Guest RX.

2.1 Guest TX: Unfortunately current pktgen does not support virtio-net well
since virtio-net may not free the skb during tx completion. So I test through a
patch (https://lkml.org/lkml/2012/11/26/31) that don't wait for this freeing
with a guest of 4 vcpu:

#q | kpps  | +improvement%
 1 | 589K  | 0%
 2 | 952K  | 62%
 3 | 1290K | 120%
 4 | 1578K | 168%

2.2 Guest RX: After commit 5d097109257c03a71845729f8db6b5770c4bbedc (tun: only
queue packets on device), pktgen start to report a unbelievable huge
kpps. (>2099kpps even for one queue). The problem if tun report NETDEV_TX_OK
even when it drops packet which confuse the pktgen. After change it to
NET_XMIT_DROP, the value makes more sense but not very stable even doing some
pining manually. Even this, multiqueue get a good speedup in the test. Will
continue to investigate.

2 Netperf test:

2.0 Test Environment:

Two Intel(R) Xeon(R) CPU E5620  @ 2.40GHz with two directed connected intel
82599EB 10 Gigabit Ethernet controller. A script to launch multiple parallelized
netperf sessions in demo mode, and a post-process script to compare the
timestamp and calculate the aggregate performance.

available: 2 nodes (0-1)
node 0 cpus: 0 1 2 3
node 0 size: 8175 MB
node 0 free: 7359 MB
node 1 cpus: 4 5 6 7
node 1 size: 8192 MB
node 1 free: 7731 MB
node distances
node   0   1
  0:  10  20
  1:  20  10

Host/Guest kernel: net-next with mq patches

2.1 2vcpu 2q vs 1q: ping guest vcpu and vhost thread in the same numa node

TCP_RR test:
size|session|+thu%|+normalize%
    1|     1|    0%|   -2%
    1|    20|  +23%|   +2%
    1|    50|   +9%|   -1%
    1|   100|   +2%|   -7%
   64|     1|    0%|   +1%
   64|    20|  +17%|   -1%
   64|    50|   +6%|   -4%
   64|   100|   +5%|   -5%
  256|     1|    0%|  +24%
  256|    20|  +52%|  +19%
  256|    50|  +46%|  +32%
  256|   100|  +44%|  +31%

- TCP_RR shows improvement of transaction rate. The reason why 1/64 byte does no
  show much gain is because the test could not fully utilized the two vhost
  threads: Each vhost thread cosume only about 50% of cpu.

TCP_CRR test:
size|session|+thu%|+normalize%
    1|     1|   -8%|  -13%
    1|    20|  +34%|   +1%
    1|    50|  +27%|    0%
    1|   100|  +29%|   +1%
   64|     1|   -9%|  -13%
   64|    20|  +31%|    0%
   64|    50|  +26%|   -1%
   64|   100|  +30%|   +1%
  256|     1|   -8%|  -11%
  256|    20|  +33%|   +1%
  256|    50|  +23%|   -3%
  256|   100|  +29%|   +1%

- TCP_CRR shows improvemnt of multiple sessions of TCP_CRR. Get regression of
  single session of TCP_CRR test, looks like the TCP_CRR will miss the flow
  director of both ixgbe and tun, which cause almost all physical queues has
  been used in host.

Guest TX:
size|session|+thu%|+normalize%
    1|     1|   -6%|    0%
    1|     2|   +3%|    0%
    1|     4|    0%|    0%
   64|     1|    0%|    0%
   64|     2|   -5%|   -8%
   64|     4|   -5%|   -7%
  256|     1|  +25%|   +7%
  256|     2|  -10%|  -34%
  256|     4|  -29%|  -31%
  512|     1|   -1%|  -63%
  512|     2|  -42%|  -43%
  512|     4|  -51%|  -60%
 1024|     1|   -5%|  -13%
 1024|     2|   +2%|  -39%
 1024|     4|    0%|  -27%
 4096|     1|  +73%|  +51%
 4096|     2|   +5%|   -9%
 4096|     4|   +3%|  -18%
16384|     1|  +48%|  +29%
16384|     2|  +73%|  +16%
16384|     4|  +21%|  -22%

- Parallel sending of small packets gets regression, statistics shows when
  multiqueue is enabled, TCP tends to send much more but smaller packets because
  the latency is improved, so TCP tends to batch less. More packets also means
  more exits/irqs which is bad for both throughput and cpu utilization.

Guest RX:
size|session|+thu%|+normalize%
    1|     1|    0%|  +26%
    1|     2|   -3%|  -51%
    1|     4|   -2%|  -44%
   64|     1|    0%|   -2%
   64|     2|    0%|  -29%
   64|     4|    0%|  -21%
  256|     1|    0%|   -2%
  256|     2|    0%|  -18%
  256|     4|  +11%|  -13%
  512|     1|   -1%|   -2%
  512|     2|   -9%|  -21%
  512|     4|   +7%|  -15%
 1024|     1|    0%|   -2%
 1024|     2|   +1%|  -11%
 1024|     4|   +5%|  -16%
 4096|     1|    0%|    0%
 4096|     2|    0%|  -10%
 4096|     4|  +10%|  -11%
16384|     1|    0%|   +1%
16384|     2|   +1%|  -15%
16384|     4|  +18%|   -7%

- RX performance is equal or better than single queue, but with a drop on per
  cpu throughput. Statistics shows more packets were sent and received by guest
  which result more exits/irqs.

2.2 4vcpu 4q vs 1q, pin vcpu in node 0, vhost thread in node 1

TCP_RR:
size|session|+thu%|+normalize%
    1|     1|   -1%|   +2%
    1|    20| +160%|   +5%
    1|    50| +169%|  +30%
    1|   100| +161%|  +30%
   64|     1|    0%|   +4%
   64|    20| +157%|  +11%
   64|    50| +112%|  +47%
   64|   100| +110%|  +48%
  256|     1|    0%|   +6%
  256|    20| +104%|   -3%
  256|    50| +131%|  +69%
  256|   100| +174%|  +96%

- Multiqueue shows much improvement in both transaction rate and cpu
  utilization.

TCP_CRR:
size|session|+thu%|+normalize%
    1|     1|  -30%|  -36%
    1|    20| +108%|   -4%
    1|    50| +132%|   +3%
    1|   100| +130%|   +9%
   64|     1|  -31%|  -36%
   64|    20| +111%|   -2%
   64|    50| +128%|   +2%
   64|   100| +136%|  +10%
  256|     1|  -30%|  -37%
  256|    20| +112%|   -1%
  256|    50| +136%|   +7%
  256|   100| +138%|  +11%

- Multiqueue shows much more improvement in aggregate transaction rate with
  equal or better cpu utilization.
- Like what we met in 2q test, single process of TCP_CRR get regression.

Guest TX:
size|session|+thu%|+normalize%
    1|     1|   -4%|    0%
    1|     2|  -15%|    0%
    1|     4|  -14%|    0%
   64|     1|   +1%|   -1%
   64|     2|  -10%|  -16%
   64|     4|  -19%|  -26%
  256|     1|   -3%|   -1%
  256|     2|  -34%|  -38%
  256|     4|  -27%|  -45%
  512|     1|   -7%|   -6%
  512|     2|  -42%|  -55%
  512|     4|   +1%|  -15%
 1024|     1|  +12%|  -25%
 1024|     2|    0%|  -23%
 1024|     4|   +2%|  -21%
 4096|     1|    0%|   -5%
 4096|     2|    0%|  -16%
 4096|     4|   -1%|  -31%
16384|     1|   -4%|   -3%
16384|     2|   +4%|  -17%
16384|     4|   +7%|  -28%

- Here we met the same issue as 2q: Statistics shows guest tends to send much
more but smaller packet in 4q since the latency is improved.

Guest RX:
size|session|+thu%|+normalize%
    1|     1|   +1%|    0%
    1|     2|   -2%|  -30%
    1|     4|   -2%|  -58%
   64|     1|    0%|   -1%
   64|     2|    0%|  -25%
   64|     4|   -1%|  -45%
  256|     1|    0%|    0%
  256|     2|   -2%|  -25%
  256|     4|  +61%|  -19%
  512|     1|   -1%|    0%
  512|     2|  +22%|  -11%
  512|     4|  +58%|  -22%
 1024|     1|   -3%|   -2%
 1024|     2|  +35%|   -6%
 1024|     4|  +53%|  -26%
 4096|     1|   -1%|    0%
 4096|     2|  +43%|   -3%
 4096|     4|  +66%|  -19%
16384|     1|    0%|    0%
16384|     2|  +45%|   -2%
16384|     4|  +79%|  -12%

- We get some performance improvement. The reason is becuase there's no much
  cpu in host node 0, so we must pin all vhost threads in node 1 to get stable
  result.
- Statistics shows much more packets were sent/received by guest which leads
  higher cpu utilization.

Jason Wang (3):
  virtio-net: separate fields of sending/receiving queue from
    virtnet_info
  virtio_net: multiqueue support
  virtio-net: support changing the number of queue pairs through
    ethtool

 drivers/net/virtio_net.c        |  726 +++++++++++++++++++++++++++++----------
 include/uapi/linux/virtio_net.h |   27 ++
 2 files changed, 567 insertions(+), 186 deletions(-)
