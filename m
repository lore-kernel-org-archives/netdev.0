From: Shirley Ma <mashirle@us.ibm.com>
Subject: [PATCH V7 0/4 net-next] macvtap/vhost TX zero-copy support
Date: Sat, 28 May 2011 12:14:37 -0700
Message-ID: <1306610077.5180.78.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, mst@redhat.com,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Avi Kivity <avi@redhat.com>, Arnd Bergmann <arnd@arndb.de>
Return-path: <kvm-owner@vger.kernel.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset add supports for TX zero-copy between guest and host
kernel through vhost. It significantly reduces CPU utilization on the
local host on which the guest is located (It reduced about 50% CPU usag=
e
for single stream test on the host, while 4K message size BW has
increased about 50%). The patchset is based on previous submission and
comments from the community regarding when/how to handle guest kernel
buffers to be released. This is the simplest approach I can think of
after comparing with several other solutions.

This patchset has integrated V3 review comments from community:=20

1. Add more comments on how to use device ZEROCOPY flag;
2. Change device ZEROCOPY to available bit 31
3. Fix skb header linear allocation when virtio_net GSO is not enabled

It has integrated V4 review comments from MST and Sridhar:
1. In vhost, using socket poll wake up for outstanding DMAs
2. Add detailed comments for vhost_zerocopy_signal_used call
3. Add sleep in vhost shutting down instead of busy-wait for outstandin=
g
   DMAs.
4. Copy small packets, don't do zero-copy callback in mavtap, mark it's
   DMA done in vhost
5. change zerocopy to bool in macvtap.

It has integrated V5 review comments from MST and=20
Micha=C5=82 Miros=C5=82aw <mirqus@gmail.com>
1. Prevent userspace apps from holding skb userspace buffers by copying
userspace buffers to kernel in skb_clone, skb_copy, pskb_copy,
pskb_expand_head.
2. It is also used HIGHDMA, SG feature bits to enable ZEROCOPY to remov=
e
the dependency of a new feature bit, we can add it later when new
feature bit is available.

It has integrated V6 review comments from Eric Dumazet.
1. Moving ubuf_info object from skb to caller, just use one pointer in
skb_share_info to point ubuf_info object.

2. Change the zero-copy size from 256 bytes to PAGE_SIZE (4K) because o=
f
the small message size performance issue.

3. During vhost shutting down, release outstanding userspace buffers w/=
o
waiting for lower device DMAs done if any. Do we really care about the
possible wrong data being sent on the wire during shutting down?

This patchset includes:
1/4: Add a new sock zero-copy flag, SOCK_ZEROCOPY;

2/4: Add a new struct skb_ubuf_info in skb_share_info for userspace
buffers release callback when lower device DMA has done for that skb,
which is the last reference count gone; Or whenever skb_clone, skb_copy=
,
pskb_copy, pskb_expand_head get call from tcpdump, filtering, these
userspace buffers will be copied into kernel ... we don't want userspac=
e
apps to hold userspace buffers too long.

3/4: Add vhost zero-copy callback in vhost when skb last refcnt is gone=
;
add vhost_zerocopy_signal_used to notify guest to release TX skb
buffers.

4/4: Add macvtap zero-copy in lower device when sending packet is
greater than PAGE_SIZE.

The patchset is built against linux-2.6.39. It has passed
netperf/netserver multiple streams stress test, tcpdump
suspended test, dynamically SG change test.

Single TCP_STREAM 120 secs test results 2.6.39-rc3 over ixgbe 10Gb NIC
results:

Message BW(Gb/s)qemu-kvm (NumCPU)vhost-net(NumCPU) PerfTop irq/s
4K      7408.57         92.1%           22.6%           1229
4K(Orig)4913.17         118.1%          84.1%           2086   =20
8K      9129.90         89.3%           23.3%           1141
8K(Orig)7094.55         115.9%          84.7%           2157
16K     9178.81         89.1%           23.3%           1139
16K(Orig)8927.1         118.7%          83.4%           2262
64K     9171.43         88.4%           24.9%           1253
64K(Orig)9085.85        115.9%          82.4%           2229

=46or message size less or equal than 2K, there is a known KVM guest TX
overrun issue. With this zero-copy patch, the issue becomes more severe=
,
guest io_exits has tripled than before, so the performance is not good.
Once the TX overrun problem has been addressed, I will retest the small
message size performance.

 drivers/net/macvtap.c  |  131
++++++++++++++++++++++++++++++++++++++++++++----
 drivers/vhost/net.c    |   45 ++++++++++++++++-
 drivers/vhost/vhost.c  |   51 +++++++++++++++++++
 drivers/vhost/vhost.h  |   15 ++++++
 include/linux/skbuff.h |   25 +++++++++
 include/net/sock.h     |    1 +
 net/core/skbuff.c      |   83 ++++++++++++++++++++++++++++++-
 7 files changed, 338 insertions(+), 13 deletions(-)


