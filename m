From: Jason Wang <jasowang@redhat.com>
Subject: [RFC V7 PATCH 0/7] enable tx interrupts for virtio-net
Date: Mon, 25 May 2015 01:23:57 -0400
Message-ID: <1432531444-50193-1-git-send-email-jasowang@redhat.com>
Cc: rusty@rustcorp.com.au, Jason Wang <jasowang@redhat.com>
To: mst@redhat.com, virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi:

This is a new version of trying to enable tx interrupts for
virtio-net.

We used to try to avoid tx interrupts and orphan packets before
transmission for virtio-net. This breaks socket accounting and can
lead serveral other side effects e.g:

- Several other functions which depends on socket accounting can not
  work correctly (e.g  TCP Small Queue)
- No tx completion which make BQL or packet generator can not work
  correctly.

This series tries to solve the issue by enabling tx interrupts. To
minize the performance impacts of this, several optimizations were
used:

- In guest side, try to use delayed callbacks as much as possible.
- In host side, try to use interrupt coalescing for reduce
  interrupts. About 10% - 15% performance were improved with this.

Perforamnce test shows:
- Few regression (10% - 15%) were noticed TCP_RR were noticed, this
  regresssion were not seen in previous version. Still not clear the
  reason.
- CPU utilization is increased in some cases.
- All other cases, tx interrupts can perform equal or better than
  orphaning especially for small packet tx

TODO:
- Try to fix the regressions of TCP_RR
- Determine a suitable coalescing paramters

Test Environmets:
- Two Intel Xeon E5620  @ 2.40GHz with back to back connected Intel 82599EB
- Both host and guest were 4.1-rc4
- Vhost zerocopy disabled
- idle=poll
- Netperf 2.6.0
- tx-frames=8 tx-usecs=64 (which was chosen to be the best performance
  during testing other combinations)
- Irqbalance were disabled by host, and smp affinity were set manually
- Using default ixgbe coalescing parameters

Test Result:

1 VCPU guest 1 Queue

Guest TX
size/session/+thu%/+normalize%
   64/     1/  +22%/  +23%
   64/     2/  +25%/  +26%
   64/     4/  +24%/  +24%
   64/     8/  +24%/  +25%
  256/     1/ +134%/ +141%
  256/     2/ +126%/ +132%
  256/     4/ +126%/ +134%
  256/     8/ +130%/ +135%
  512/     1/ +157%/ +170%
  512/     2/ +155%/ +169%
  512/     4/ +153%/ +168%
  512/     8/ +162%/ +176%
 1024/     1/  +84%/ +119%
 1024/     2/ +120%/ +146%
 1024/     4/ +105%/ +131%
 1024/     8/ +103%/ +134%
 2048/     1/  +20%/  +97%
 2048/     2/  +29%/  +76%
 2048/     4/    0%/  +11%
 2048/     8/    0%/   +3%
16384/     1/    0%/   -5%
16384/     2/    0%/  -10%
16384/     4/    0%/   -3%
16384/     8/    0%/    0%
65535/     1/    0%/  -10%
65535/     2/    0%/   -5%
65535/     4/    0%/   -3%
65535/     8/    0%/   -5%

TCP_RR
size/session/+thu%/+normalize%
    1/     1/    0%/   -9%
    1/    25/   -5%/   -5%
    1/    50/   -4%/   -3%
   64/     1/    0%/   -7%
   64/    25/   -5%/   -6%
   64/    50/   -5%/   -6%
  256/     1/    0%/   -6%
  256/    25/  -14%/  -14%
  256/    50/  -14%/  -14%

Guest RX
size/session/+thu%/+normalize%
   64/     1/    0%/   -1%
   64/     2/   +3%/   +3%
   64/     4/    0%/   -1%
   64/     8/    0%/    0%
  256/     1/   +5%/   +1%
  256/     2/   -9%/  -13%
  256/     4/    0%/   -2%
  256/     8/    0%/   -3%
  512/     1/   +1%/   -2%
  512/     2/   -3%/   -6%
  512/     4/    0%/   -3%
  512/     8/    0%/   -1%
 1024/     1/  +11%/  +16%
 1024/     2/    0%/   -3%
 1024/     4/    0%/   -2%
 1024/     8/    0%/   -1%
 2048/     1/    0%/   -3%
 2048/     2/    0%/   -1%
 2048/     4/    0%/   -1%
 2048/     8/    0%/   -2%
16384/     1/    0%/   -2%
16384/     2/    0%/   -4%
16384/     4/    0%/   -3%
16384/     8/    0%/   -3%
65535/     1/    0%/   -2%
65535/     2/    0%/   -5%
65535/     4/    0%/   -1%
65535/     8/   +1%/    0%

4 VCPU guest 4 QUEUE
Guest TX
size/session/+thu%/+normalize%
   64/     1/  +42%/  +38%
   64/     2/  +33%/  +33%
   64/     4/  +16%/  +19%
   64/     8/  +19%/  +22%
  256/     1/ +139%/ +134%
  256/     2/  +43%/  +52%
  256/     4/   +1%/   +6%
  256/     8/    0%/   +4%
  512/     1/ +171%/ +175%
  512/     2/   -1%/  +26%
  512/     4/   +9%/   +8%
  512/     8/  +48%/  +31%
 1024/     1/ +162%/ +171%
 1024/     2/    0%/   +2%
 1024/     4/   +3%/    0%
 1024/     8/   +6%/   +2%
 2048/     1/  +60%/  +94%
 2048/     2/    0%/   +2%
 2048/     4/  +23%/  +11%
 2048/     8/   -1%/   -6%
16384/     1/    0%/  -12%
16384/     2/    0%/   -8%
16384/     4/    0%/   -9%
16384/     8/    0%/  -11%
65535/     1/    0%/  -15%
65535/     2/    0%/  -10%
65535/     4/    0%/   -6%
65535/     8/   +1%/  -10%

TCP_RR
size/session/+thu%/+normalize%
    1/     1/    0%/  -15%
    1/    25/  -14%/   -9%
    1/    50/   +3%/   +3%
   64/     1/   -3%/  -10%
   64/    25/  -13%/   -4%
   64/    50/   -7%/   -4%
  256/     1/   -1%/  -19%
  256/    25/  -15%/   -3%
  256/    50/  -16%/   -9%

Guest RX
size/session/+thu%/+normalize%
   64/     1/   +4%/  +21%
   64/     2/  +81%/ +140%
   64/     4/  +51%/ +196%
   64/     8/  -10%/  +33%
  256/     1/ +139%/ +216%
  256/     2/  +53%/ +114%
  256/     4/   -9%/   -5%
  256/     8/   -9%/  -14%
  512/     1/ +257%/ +413%
  512/     2/  +11%/  +32%
  512/     4/   -4%/   -6%
  512/     8/   -7%/  -10%
 1024/     1/  +98%/ +138%
 1024/     2/   -6%/   -9%
 1024/     4/   -3%/   -4%
 1024/     8/   -7%/  -10%
 2048/     1/  +32%/  +29%
 2048/     2/   -7%/  -14%
 2048/     4/   -3%/   -3%
 2048/     8/   -7%/   -3%
16384/     1/  -13%/  -19%
16384/     2/   -3%/   -9%
16384/     4/   -7%/   -9%
16384/     8/   -9%/  -10%
65535/     1/    0%/   -3%
65535/     2/   -2%/  -10%
65535/     4/   -6%/  -11%
65535/     8/   -9%/   -9%

4 VCPU Guest 4 Queue
Guest TX
size/session/+thu%/+normalize%
   64/     1/  +33%/  +31%
   64/     2/  +26%/  +29%
   64/     4/  +24%/  +29%
   64/     8/  +19%/  +24%
  256/     1/ +117%/ +128%
  256/     2/  +96%/ +109%
  256/     4/ +123%/ +198%
  256/     8/  +54%/ +111%
  512/     1/ +153%/ +171%
  512/     2/  +77%/ +135%
  512/     4/    0%/  +11%
  512/     8/    0%/   +2%
 1024/     1/ +133%/ +156%
 1024/     2/  +21%/  +78%
 1024/     4/    0%/   +3%
 1024/     8/    0%/   -7%
 2048/     1/  +41%/  +60%
 2048/     2/  +50%/ +153%
 2048/     4/    0%/  -10%
 2048/     8/   +2%/   -3%
16384/     1/    0%/   -7%
16384/     2/    0%/   -3%
16384/     4/   +1%/   -9%
16384/     8/   +4%/   -9%
65535/     1/    0%/   -7%
65535/     2/    0%/   -7%
65535/     4/   +5%/   -2%
65535/     8/    0%/   -5%

TCP_RR
size/session/+thu%/+normalize%
    1/     1/    0%/   -6%
    1/    25/  -17%/  -15%
    1/    50/  -24%/  -21%
   64/     1/   -1%/   -1%
   64/    25/  -14%/  -12%
   64/    50/  -23%/  -21%
  256/     1/    0%/  -12%
  256/    25/   -4%/   -8%
  256/    50/   -7%/   -8%

Guest RX
size/session/+thu%/+normalize%
   64/     1/   +3%/   -4%
   64/     2/  +32%/  +41%
   64/     4/   +5%/   -3%
   64/     8/   +7%/    0%
  256/     1/    0%/  -10%
  256/     2/  -15%/  -26%
  256/     4/    0%/   -5%
  256/     8/   -1%/  -11%
  512/     1/   +4%/   -7%
  512/     2/   -6%/    0%
  512/     4/    0%/   -8%
  512/     8/    0%/   -8%
 1024/     1/  +71%/   -2%
 1024/     2/   -4%/    0%
 1024/     4/    0%/  -11%
 1024/     8/    0%/   -9%
 2048/     1/   -1%/   +9%
 2048/     2/   -2%/   -2%
 2048/     4/    0%/   -6%
 2048/     8/    0%/  -10%
16384/     1/    0%/   -3%
16384/     2/    0%/  -14%
16384/     4/    0%/  -10%
16384/     8/   -2%/  -13%
65535/     1/    0%/   -4%
65535/     2/   +1%/  -16%
65535/     4/   +1%/   -8%
65535/     8/   +4%/   -6%

Changes from RFCv5:
- rebase the HEAD
- Move net specific codes to virtio/vhost generic codes
- Drop the wrong virtqueue_enable_cb_delayed() optimization from the
  series
- Limit the enabling of tx interrupt only for host with interrupt
  coalescing. This can reduce the performance impact for older host.
- Avoid expensive dividing in vhost code.
- Try to avoid the overhead of timer callback by using mutex_trylock()
  and inject the irq directly from the timer callback.

Changes from RFCv4:
- fix the virtqueue_enable_cb_delayed() return value when only 1
  buffer is pending.
- try to disable callbacks by publish event index in
  virtqueue_disable_cb(). Tests shows about 2% - 3% improvement on
  multiple sessions of TCP_RR.
- Revert some of Micahel's tweaks from RFC v1 (see patch 3 for
  details).
- use netif_wake_subqueue() instead of netif_start_subqueue() in
  free_old_xmit_skbs(), since it may be called in tx napi.
- in start_xmit(), try to enable the callback only when current skb is
  the last in the list or tx has already been stopped. This avoid the
  callbacks enabling in heavy load.
- return ns instead of us in vhost_net_check_coalesce_and_signal()
- measure the time interval of real interrupts instead of calls to
  vhost_signal()
- drop bql from the series since it does not affact performance from
  the test result.
Changes from RFC V3:
- Don't free tx packets in ndo_start_xmit()
- Add interrupt coalescing support for virtio-net
Changes from RFC v2:
- clean up code, address issues raised by Jason
Changes from RFC v1:
- address comments by Jason Wang, use delayed cb everywhere
- rebased Jason's patch on top of mine and include it (with some
  tweaks)

Jason Wang (7):
  virito-cpi: add coalescing parameters setting
  virtio_ring: try to disable event index callbacks in
    virtqueue_disable_cb()
  virtio-net: optimize free_old_xmit_skbs stats
  virtio-net: add basic interrupt coalescing support
  virtio_net: enable tx interrupt
  vhost: interrupt coalescing support
  vhost_net: add interrupt coalescing support

 drivers/net/virtio_net.c           | 266 +++++++++++++++++++++++++++++++------
 drivers/vhost/net.c                |   8 ++
 drivers/vhost/vhost.c              |  88 +++++++++++-
 drivers/vhost/vhost.h              |  20 +++
 drivers/virtio/virtio_pci_modern.c |  15 +++
 drivers/virtio/virtio_ring.c       |   3 +
 include/linux/virtio_config.h      |   8 ++
 include/uapi/linux/vhost.h         |  13 +-
 include/uapi/linux/virtio_pci.h    |   4 +
 include/uapi/linux/virtio_ring.h   |   1 +
 10 files changed, 382 insertions(+), 44 deletions(-)

-- 
1.8.3.1
