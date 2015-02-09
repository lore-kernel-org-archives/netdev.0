From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH RFC v5 net-next 0/6] enable tx interrupts for virtio-net
Date: Mon,  9 Feb 2015 03:39:19 -0500
Message-ID: <1423471165-34243-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pagupta@redhat.com
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, mst@redhat.com
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

Hi:

This is a new version of trying to enable tx interrupts for
virtio-net.

We used to try to avoid tx interrupts and orphan packets before
transmission for virtio-net. This breaks socket accounting and can
lead serveral other side effects e.g:

- Several other functions which depends on socket accounting can not
  work  correctly (e.g  TCP Small Queue)
- No tx completion which make BQL or packet generator can not work
  correctly.

This series tries to solve the issue by enabling tx interrupts. To
minize the performance impacts of this, several optimizations were
used:

- In guest side, try to use delayed callbacks as much as possible.
- In host side, try to use interrupt coalescing for reduce tx
  interrupts. About 10% - 15% performance were improved with this.

Perforamnce test shows:
- Very few regression (less than 5%) were noticed TCP_RR on 1 vcpu 1
  queue guest.
- CPU utilization is increased in some cases.
- All other cases, tx interrupts can perform equal or better than
  orphaning (much more obvious when testing small packet transmission
  as a byproduct since socket accounting works for TCP packet).

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

Test result:

Environment:
Host: net-next.git
Guest: net-next.git
Qemu: qemu.git
CPU: Two Intel(R) Xeon(R) CPU E5620  @ 2.40GHz
Card: Two Intel Corporation 82599ES 10-Gigabit SFI/SFP+ Network
Connection (rev 01) connected back to back
Coalescing in host: rx-usecs: 1
Coalescing in guest:
- none if no tx interrupt
- tx-frames 8 tx-usecs 64
Zerocopy disabled for vhost_net

1 VCPU 1 queue:

Guest TX:
sessions/sizes/+-throughput%/+-cpu%/+-per_cpu_throughput%/
1/64/+41.2/-2.6/+45.1/
2/64/+40.8/-2.7/+44.7/
4/64/+38.5/-2.8/+42.5/
8/64/+36.1/-2.1/+38.9/
1/256/+158.5/-5.0/+172.3/
2/256/+155.3/-4.7/+167.9/
4/256/+156.4/-5.3/+170.6/
8/256/+155.4/-4.9/+168.6/
1/512/+276.5/-3.0/+288.3/
2/512/+280.1/-3.3/+293.1/
4/512/+276.1/-2.7/+286.7/
8/512/+267.1/-3.2/+279.1/
1/1024/+344.0/-6.9/+376.9/
2/1024/+362.3/-2.2/+372.8/
4/1024/+370.4/-1.1/+375.8/
8/1024/+374.0/+0.6/+371.1/
1/4096/+15.1/-30.4/+65.5/
2/4096/+6.3/-32.9/+58.4/
4/4096/+6.9/-32.4/+58.3/
8/4096/+6.7/-26.4/+45.0/
1/16384/-0.6/-4.6/+4.2/
2/16384/+0.0/-5.0/+5.4/
4/16384/+0.0/-2.5/+2.6/
8/16384/-0.0/-13.8/+13.2/
1/65535/-0.5/-0.5/0.0/
2/65535/-0.0/+4.0/-3.9/
4/65535/-0.0/+9.4/-8.6/
8/65535/+0.1/+8.6/-7.8/

TCP_RR:
sessions/sizes/+-throughput%/+-cpu%/+-per_cpu_throughput%/
1/1/-2.4/+16.3/-16.6/
50/1/-3.4/-0.2/-3.2/
1/64/+3.3/+0.7/+2.7/
50/64/-3.6/+0.2/-3.8/
1/256/-0.4/+16.6/-14.7/
50/256/-6.1/+0.2/-6.2/

Guest RX:
sessions/sizes/+-throughput%/+-cpu%/+-per_cpu_throughput%/
1/64/+17.3/+4.9/+10.0/
2/64/+13.8/+1.1/+12.3/
4/64/+3.8/+1.0/+2.7/
8/64/+1.4/+2.1/-0.7
1/256/+24.5/-1.3/+19.1/
2/256/-3.9/+3.8/-7.5/
4/256/-1.3/+1.5/-2.8/
8/256/+1.5/+1.7/-0.2/
1/512/+2.9/+12.7/-8.6/
2/512/-0.0/+3.5/-3.4/
4/512/-1.4/+2.6/-4.0/
8/512/-1.3/+3.1/-4.2/
1/1024/-0.2/+6.0/-5.9/
2/1024/+0.0/+3.1/-3.1/
4/1024/+0.1/+0.9/-0.7/
8/1024/-1.1/-4.1/+3.2/
1/4096/-0.6/+4.0/-4.4/
2/4096/-0.0/+3.6/-3.4/
4/4096/+0.7/+3.8/-3.1/
8/4096/-0.5/+2.4/-2.9/
1/16384/-1.1/+4.9/-5.7/
2/16384/-0.0/+2.4/-2.4/
4/16384/-0.1/+4.7/-4.6/
8/16384/+1.3/-2.0/+3.2/
1/65535/+1.9/+6.0/-3.8/
2/65535/+0.0/+3.3/-3.2/
4/65535/+0.1/+5.1/-4.7/
8/65535/-0.7/+8.0/-8.5/

4 VCPU 1 queue:

Guest TX:
sessions/sizes/+-throughput%/+-cpu%/+-per_cpu_throughput%/
1/64/+45.9/+2.7/+41.9/
2/64/+28.8/+0.2/+28.4/
4/64/+11.2/-0.6/+11.9/
8/64/+10.0/-0.5/+10.6/
1/256/+162.4/+1.0/+160.1/
2/256/+99.7/-0.2/+99.9/
4/256/+10.2/-11.3/+24.2/
8/256/-0.0/-13.8/+16.0/
1/512/+232.4/-0.2/+232.8/
2/512/+105.9/-9.9/+128.5/
4/512/+6.7/-18.8/+31.4/
8/512/+0.0/-21.0/+26.6/
1/1024/+285.1/-2.9/+296.9/
2/1024/+99.3/-22.4/+156.8/
4/1024/+3.7/-24.0/+36.4/
8/1024/+0.1/-23.9/+31.6/
1/4096/+35.9/-17.4/+64.6/
2/4096/+11.4/-27.4/+53.4/
4/4096/+0.1/-36.0/+56.3/
8/4096/+0.0/-34.9/+53.7/
1/16384/-1.8/-9.5/+8.5/
2/16384/+0.0/-2.3/+2.4/
4/16384/+0.0/-3.0/+3.1/
8/16384/+0.1/-0.3/+0.4/
1/65535/-1.1/+3.1/-4.0/
2/65535/+0.0/+5.4/-5.1/
4/65535/+0.0/+7.2/-6.7/
8/65535/-0.0/+7.1/-6.7/

TCP_RR:
sessions/sizes/+-throughput%/+-cpu%/+-per_cpu_throughput%/
1/1/-0.5/+11.7/-11.0/
50/1/-1.9/+2.2/-4.1/
1/64/-0.9/+15.5/-14.3/
50/64/-3.3/+1.3/-4.5/
1/256/+0.6/+5.7/-5.5/
50/256/-1.6/+2.3/-3.8/

Guest RX:
sessions/sizes/+-throughput%/+-cpu%/+-per_cpu_throughput%/
1/64/+12.2/+10.7/+1.3/
2/64/-3.0/+1.9/-4.9/
4/64/+0.9/+0.6/+0.2/
8/64/-2.8/+11.9/-13.6/
1/256/+3.6/-1.8/+10.7/
2/256/+1.9/-0.8/+2.8/
4/256/+0.1/+2.1/-1.9/
8/256/+1.1/+4.3/-2.1/
1/512/+1.5/+1.8/-0.9/
2/512/-0.1/+5.5/-5.3/
4/512/+0.5/+12.9/-11.7/
8/512/+5.5/+10.2/-4.0/
1/1024/+2.6/+6.8/-4.0/
2/1024/-0.0/+3.3/-3.3/
4/1024/+0.1/+5.1/-4.7/
8/1024/+3.6/-2.9/+6.5/
1/4096/+1.0/+7.0/-5.7/
2/4096/-0.0/+1.7/-1.5/
4/4096/+0.1/+3.6/-3.4/
8/4096/-1.0/+2.6/-4.0/
1/16384/+0.6/+3.3/-2.7/
2/16384/+0.0/-2.9/+3.3/
4/16384/+1.5/+1.3/+0.7/
8/16384/+0.5/+8.5/-6.9/
1/65535/+0.5/+2.4/-2.0/
2/65535/+0.0/-1.2/+1.5/
4/65535/+0.1/-4.5/+4.9/
8/65535/+1.4/+7.1/-5.7/

4 VCPU 4 queues:

Guest TX:
sessions/sizes/+-throughput%/+-cpu%/+-per_cpu_throughput%/
1/64/+43.6/-7.9/+56.5/
2/64/+41.7/-3.8/+47.3/
4/64/+43.7/-3.7/+49.3/
8/64/+40.2/-3.5/+45.3/
1/256/+155.9/-2.9/+164.2/
2/256/+160.6/-3.2/+169.1/
4/256/+77.5/-23.2/+131.4/
8/256/+82.5/-21.1/+132.4/
1/512/+214.7/-0.7/+217.9/
2/512/+125.2/-10.1/+151.8/
4/512/+30.4/-37.0/+107.6/
8/512/+0.8/-17.1/+22.9/
1/1024/+250.0/+3.1/+239.5/
2/1024/+83.6/-19.7/+129.0/
4/1024/+18.0/-39.4/+95.2/
8/1024/+1.9/-20.5/+30.3/
1/4096/+26.6/-10.9/+42.1/
2/4096/+0.9/-2.3/+3.9/
4/4096/+0.9/-12.6/+16.8/
8/4096/-0.4/-29.4/+42.1/
1/16384/+12.0/-3.1/+15.9/
2/16384/-2.8/-2.1/+0.5/
4/16384/-1.6/-15.3/+18.2/
8/16384/+0.5/-17.9/+34.5/
1/65535/+12.2/-2.9/+15.8/
2/65535/-4.3/+4.7/-8.6/
4/65535/+1.1/-9.8/+15.9/
8/65535/-1.3/-21.8/+34.1/

TCP_RR:
sessions/sizes/+-throughput%/+-cpu%/+-per_cpu_throughput%/
1/1/+5.4/-0.4/+6.6/
50/1/+6.9/+2.8/+3.9/
1/64/+7.8/+8.4/-1.5/
50/64/+11.1/+0.8/+10.4/
1/256/+3.9/-2.9/+10.3/
50/256/+17.4/+2.7/+14.1/

Guest RX:
sessions/sizes/+-throughput%/+-cpu%/+-per_cpu_throughput%/
1/64/+3.9/+3.8/+9.8/
2/64/-11.0/+11.2/-20.4/
4/64/-5.2/+14.4/-16.6/
8/64/-8.2/+17.2/-21.6/
1/256/+37.3/-32.0/+47.7/
2/256/+16.2/-9.7/+27.7/
4/256/+0.7/+1.5/-0.9/
8/256/+2.1/+8.6/-5.8/
1/512/+2.7/-2.2/+5.5/
2/512/+1.5/+9.4/-7.4/
4/512/-0.0/+10.7/-9.6/
8/512/+4.0/+11.6/-7.0/
1/1024/-3.1/-5.7/+3.2/
2/1024/+0.0/+5.5/-4.9/
4/1024/-0.2/+7.0/-6.9/
8/1024/-1.5/+1.3/-2.6/
1/4096/-1.0/-10.5/+10.6/
2/4096/+0.0/-0.3/+1.0/
4/4096/+0.1/+15.1/-13.0/
8/4096/-1.3/+15.5/-14.6/
1/16384/-0.5/-11.6/+12.5/
2/16384/+0.0/+6.1/-5.9/
4/16384/-1.7/+24.2/-20.5/
8/16384/-2.2/+2.8/-2.6/
1/65535/-0.9/-12.4/+13.0/
2/65535/+0.1/+4.7/-4.3/
4/65535/0.0/+10.6/-9.5/
8/65535/-1.8/+9.4/-10.1/

I've also done test on mlx4, almos the same trends. So not post here.

Thanks

Jason Wang (6):
  virtio_ring: fix virtqueue_enable_cb() when only 1 buffers were
    pending
  virtio_ring: try to disable event index callbacks in
    virtqueue_disable_cb()
  virtio_net: enable tx interrupt
  virtio-net: add basic interrupt coalescing support
  vhost: let vhost_signal() returns whether signalled
  vhost_net: interrupt coalescing support

 drivers/net/virtio_net.c        | 203 +++++++++++++++++++++++++++++++---------
 drivers/vhost/net.c             | 199 +++++++++++++++++++++++++++++++++++++--
 drivers/vhost/vhost.c           |   7 +-
 drivers/vhost/vhost.h           |   2 +-
 drivers/virtio/virtio_ring.c    |   7 +-
 include/uapi/linux/vhost.h      |  12 +++
 include/uapi/linux/virtio_net.h |  12 +++
 7 files changed, 383 insertions(+), 59 deletions(-)

-- 
1.8.3.1
