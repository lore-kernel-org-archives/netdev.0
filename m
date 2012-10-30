From: Jason Wang <jasowang@redhat.com>
Subject: [rfc net-next v6 0/3] Multiqueue virtio-net
Date: Tue, 30 Oct 2012 18:03:20 +0800
Message-ID: <1351591403-23065-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org
To: mst@redhat.com, davem@davemloft.net,
	virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	rusty@rustcorp.com.au, krkumar2@in.ibm.com
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

This series is an update version of multiqueue virtio-net driver based on
Krishna Kumar's work to let virtio-net use multiple rx/tx queues to do the
packets reception and transmission. Please review and comments.

Changes from v5:
- Align the implementation with the RFC spec update v4
- Switch the mode between single mode and multiqueue mode without reset
- Remove the 256 limitation of queues
- Use helpers to do the mapping between virtqueues and tx/rx queues
- Use commbined channels instead of separated rx/tx queus when do the queue
number configuartion
- Other coding style comments from Michael

Reference:
- A protype implementation of qemu-kvm support could by found in
git://github.com/jasowang/qemu-kvm-mq.git
- V5 could be found at http://lwn.net/Articles/505388/
- V4 could be found at https://lkml.org/lkml/2012/6/25/120
- V2 could be found at http://lwn.net/Articles/467283/
- Michael virtio-spec: http://www.spinics.net/lists/netdev/msg209986.html

Perf Numbers:

- Pktgen test shows the receiving capability of the multiqueue virtio-net were
  dramatically improved.
- Netperf result shows latency were greately improved according to the test
result. The throughput were kept or improved when transfter with large
packets. But we get regression with small packet (<1500)
transmission/receiving. According to the satistics, TCP tends batch less when mq
is enabled which means much more but smaller pakcets were sent/received whcih
lead much higher cpu utilization and degradate the throughput. In the future,
either tuning of TCP or automatic switch bettwen mq and sq is needed.

Test environment:
- Intel(R) Xeon(R) CPU E5620 @ 2.40GHz, 8 cores 2 numa nodes
- Two directed connected 82599
- Host/Guest kenrel: net-next with the mq virtio-net patches and mq tuntap
patches

Pktgen test:
- Local host generate 64 byte UDP packet to guest.
- average of 20 runs

20 runs
#q #vcpu   kpps     +improvement
1q 1vcpu:  264kpps  +0%
2q 2vcpu:  451kpps  +70%
3q 3vcpu:  661kpps  +150%
4q 4vcpu:  941kpps  +250%

Netperf Local VM to VM test:
- VM1 and its vcpu/vhost thread in numa node 0
- VM2 and its vcpu/vhost thread in numa node 1
- a script is used to lauch the netperf with demo mode and do the postprocessing
  to measure the aggreagte result with the help of timestamp
- average of 3 runs

TCP_RR:
size/session/+lat%/+normalize%
    1/     1/    0%/    0%
    1/    10/  +52%/   +6%
    1/    20/  +27%/   +5%
   64/     1/    0%/    0%
   64/    10/  +45%/   +4%
   64/    20/  +28%/   +7%
  256/     1/   -1%/    0%
  256/    10/  +38%/   +2%
  256/    20/  +27%/   +6%
TCP_CRR:
size/session/+lat%/+normalize%
    1/     1/   -7%/  -12%
    1/    10/  +34%/   +3%
    1/    20/   +3%/   -8%
   64/     1/   -7%/   -3%
   64/    10/  +32%/   +1%
   64/    20/   +4%/   -7%
  256/     1/   -6%/  -18%
  256/    10/  +33%/    0%
  256/    20/   +4%/   -8%
STREAM:
size/session/+thu%/+normalize%
    1/     1/   -3%/    0%
    1/     2/   -1%/    0%
    1/     4/   -2%/    0%
   64/     1/    0%/   +1%
   64/     2/   -6%/   -6%
   64/     4/   -8%/  -14%
  256/     1/    0%/    0%
  256/     2/  -48%/  -52%
  256/     4/  -50%/  -55%
  512/     1/   +4%/   +5%
  512/     2/  -29%/  -33%
  512/     4/  -37%/  -49%
 1024/     1/   +6%/   +7%
 1024/     2/  -46%/  -51%
 1024/     4/  -15%/  -17%
 4096/     1/   +1%/   +1%
 4096/     2/  +16%/   -2%
 4096/     4/  +31%/  -10%
16384/     1/    0%/    0%
16384/     2/  +16%/   +9%
16384/     4/  +17%/   -9%

Netperf test between external host and guest over 10gb(ixgbe):
- VM thread and vhost threads were pinned int the node 0
- a script is used to lauch the netperf with demo mode and do the postprocessing
  to measure the aggreagte result with the help of timestamp
- average of 3 runs

TCP_RR:
size/session/+lat%/+normalize%
    1/     1/    0%/   +6%
    1/    10/  +41%/   +2%
    1/    20/  +10%/   -3%
   64/     1/    0%/  -10%
   64/    10/  +39%/   +1%
   64/    20/  +22%/   +2%
  256/     1/    0%/   +2%
  256/    10/  +26%/  -17%
  256/    20/  +24%/  +10%
TCP_CRR:
size/session/+lat%/+normalize%
    1/     1/   -3%/   -3%
    1/    10/  +34%/   -3%
    1/    20/    0%/  -15%
   64/     1/   -3%/   -3%
   64/    10/  +34%/   -3%
   64/    20/   -1%/  -16%
  256/     1/   -1%/   -3%
  256/    10/  +38%/   -2%
  256/    20/   -2%/  -17%
TCP_STREAM:(guest receiving)
size/session/+thu%/+normalize%
    1/     1/   +1%/  +14%
    1/     2/    0%/   +4%
    1/     4/   -2%/  -24%
   64/     1/   -6%/   +1%
   64/     2/   +1%/   +1%
   64/     4/   -1%/  -11%
  256/     1/   +3%/   +4%
  256/     2/    0%/   -1%
  256/     4/    0%/  -15%
  512/     1/   +4%/    0%
  512/     2/  -10%/  -12%
  512/     4/    0%/  -11%
 1024/     1/   -5%/    0%
 1024/     2/  -11%/  -16%
 1024/     4/   +3%/  -11%
 4096/     1/  +27%/   +6%
 4096/     2/    0%/  -12%
 4096/     4/    0%/  -20%
16384/     1/    0%/   -2%
16384/     2/    0%/   -9%
16384/     4/  +10%/   -2%
TCP_MAERTS:(guest sending)
    1/     1/   -1%/    0%
    1/     2/    0%/    0%
    1/     4/   -5%/    0%
   64/     1/    0%/    0%
   64/     2/   -7%/   -8%
   64/     4/   -7%/   -8%
  256/     1/    0%/    0%
  256/     2/  -28%/  -28%
  256/     4/  -28%/  -29%
  512/     1/    0%/    0%
  512/     2/  -15%/  -13%
  512/     4/  -53%/  -59%
 1024/     1/   +4%/  +13%
 1024/     2/   -7%/  -18%
 1024/     4/   +1%/  -18%
 4096/     1/   +2%/    0%
 4096/     2/   +3%/  -19%
 4096/     4/   -1%/  -19%
16384/     1/   -3%/   -1%
16384/     2/    0%/  -12%
16384/     4/    0%/  -10%

Jason Wang (2):
  virtio_net: multiqueue support
  virtio-net: change the number of queues through ethtool

Krishna Kumar (1):
  virtio_net: Introduce VIRTIO_NET_F_MULTIQUEUE

 drivers/net/virtio_net.c        |  790 ++++++++++++++++++++++++++++-----------
 include/uapi/linux/virtio_net.h |   19 +
 2 files changed, 594 insertions(+), 215 deletions(-)
