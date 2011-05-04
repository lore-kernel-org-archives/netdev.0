From: Shirley Ma <mashirle@us.ibm.com>
Subject: [PATCH V4 0/8] macvtap/vhost TX zero-copy support
Date: Wed, 04 May 2011 00:48:22 -0700
Message-ID: <1304495302.20660.60.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, mst@redhat.com,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Avi Kivity <avi@redhat.com>, Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset add supports for TX zero-copy between guest and host
kernel through vhost. It significantly reduces CPU utilization on the
local host on which the guest is located (It reduced 30-50% CPU usage
for vhost thread for single stream test). The patchset is based on
previous submission and comments from the community regarding when/how
to handle guest kernel buffers to be released. This is the simplest
approach I can think of after comparing with several other solutions.

This patchset has integrated V3 review comments from the community:

1. Add more comments on how to use device ZEROCOPY flag;

2. Change device ZEROCOPY to available bit 31

3. Fix skb header linear allocation when virtio_net GSO is not enabled

This patchset includes:

1/8: Add a new sock zero-copy flag, SOCK_ZEROCOPY;

2/8: Add a new device flag, NETIF_F_ZEROCOPY for lower level device
support zero-copy;

3/8: Add a new struct skb_ubuf_info in skb_share_info for userspace
buffers release callback when lower device DMA has done for that skb,
which is the last reference count gone;

4/8: Add vhost zero-copy callback in vhost when skb last refcnt is gone;
add vhost_zerocopy_signal_used to notify guest to release TX skb
buffers.

5/8: Add macvtap zero-copy in lower device when sending packet is
greater than 256 bytes to make sure there is enough room for expanding
skb head.

6/8: Add Chelsio 10Gb NIC to zero-copy feature flag

7/8: Add Intel 10Gb NIC zero-copy feature flag

8/8: Add Emulex 10Gb NIC zero-copy feature flag

The patchset is built against most recent linux 2.6.39-rc5. It has
passed netperf/netserver multiple streams stress test on above NICs.

Single TCP_STREAM 120 secs test results over ixgbe 10Gb NIC results:

Message BW(Gb/s)qemu-kvm (NumCPU)vhost-net(NumCPU) PerfTop irq/s
4K      7408.57         92.1%           22.6%           1229
4K(Orig)4913.17         118.1%          84.1%           2086    
8K      9129.90         89.3%           23.3%           1141
8K(Orig)7094.55         115.9%          84.7%           2157
16K     9178.81         89.1%           23.3%           1139
16K(Orig)8927.1         118.7%          83.4%           2262
64K     9171.43         88.4%           24.9%           1253
64K(Orig)9085.85        115.9%          82.4%           2229

For message size less or equal than 2K, there is a known KVM guest TX
overrun issue. With this zero-copy patch, the issue becomes more severe,
guest io_exits has tripled than before, so the performance is not good.
Once the TX overrun problem has been addressed, I will retest the small
message size performance.

Thanks
Shirley
