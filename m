From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH V7 0/4 net-next] macvtap/vhost TX zero-copy support
Date: Tue, 14 Jun 2011 16:30:07 +0300
Message-ID: <20110614133006.GA13258@redhat.com>
References: <1306610077.5180.78.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Avi Kivity <avi@redhat.com>, Arnd Bergmann <arnd@arndb.de>,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14137 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751083Ab1FNNaH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2011 09:30:07 -0400
Content-Disposition: inline
In-Reply-To: <1306610077.5180.78.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 28, 2011 at 12:14:37PM -0700, Shirley Ma wrote:
> This patchset add supports for TX zero-copy between guest and host
> kernel through vhost. It significantly reduces CPU utilization on the
> local host on which the guest is located (It reduced about 50% CPU us=
age
> for single stream test on the host, while 4K message size BW has
> increased about 50%). The patchset is based on previous submission an=
d
> comments from the community regarding when/how to handle guest kernel
> buffers to be released. This is the simplest approach I can think of
> after comparing with several other solutions.
>=20
> This patchset has integrated V3 review comments from community:=20
>=20
> 1. Add more comments on how to use device ZEROCOPY flag;
> 2. Change device ZEROCOPY to available bit 31
> 3. Fix skb header linear allocation when virtio_net GSO is not enable=
d
>=20
> It has integrated V4 review comments from MST and Sridhar:
> 1. In vhost, using socket poll wake up for outstanding DMAs
> 2. Add detailed comments for vhost_zerocopy_signal_used call
> 3. Add sleep in vhost shutting down instead of busy-wait for outstand=
ing
>    DMAs.
> 4. Copy small packets, don't do zero-copy callback in mavtap, mark it=
's
>    DMA done in vhost
> 5. change zerocopy to bool in macvtap.
>=20
> It has integrated V5 review comments from MST and=20
> Micha=C5=82 Miros=C5=82aw <mirqus@gmail.com>
> 1. Prevent userspace apps from holding skb userspace buffers by copyi=
ng
> userspace buffers to kernel in skb_clone, skb_copy, pskb_copy,
> pskb_expand_head.
> 2. It is also used HIGHDMA, SG feature bits to enable ZEROCOPY to rem=
ove
> the dependency of a new feature bit, we can add it later when new
> feature bit is available.
>=20
> It has integrated V6 review comments from Eric Dumazet.
> 1. Moving ubuf_info object from skb to caller, just use one pointer i=
n
> skb_share_info to point ubuf_info object.
>=20
> 2. Change the zero-copy size from 256 bytes to PAGE_SIZE (4K) because=
 of
> the small message size performance issue.
>=20
> 3. During vhost shutting down, release outstanding userspace buffers =
w/o
> waiting for lower device DMAs done if any. Do we really care about th=
e
> possible wrong data being sent on the wire during shutting down?

Yes, we do. IMHO the right approach is to wait
for DMAs to be done - just use a sleep/wake up construct,
not a timed sleep.

> This patchset includes:
> 1/4: Add a new sock zero-copy flag, SOCK_ZEROCOPY;
>=20
> 2/4: Add a new struct skb_ubuf_info in skb_share_info for userspace
> buffers release callback when lower device DMA has done for that skb,
> which is the last reference count gone; Or whenever skb_clone, skb_co=
py,
> pskb_copy, pskb_expand_head get call from tcpdump, filtering, these
> userspace buffers will be copied into kernel ... we don't want usersp=
ace
> apps to hold userspace buffers too long.
>=20
> 3/4: Add vhost zero-copy callback in vhost when skb last refcnt is go=
ne;
> add vhost_zerocopy_signal_used to notify guest to release TX skb
> buffers.
>=20
> 4/4: Add macvtap zero-copy in lower device when sending packet is
> greater than PAGE_SIZE.
>=20
> The patchset is built against linux-2.6.39. It has passed
> netperf/netserver multiple streams stress test, tcpdump
> suspended test, dynamically SG change test.
>=20
> Single TCP_STREAM 120 secs test results 2.6.39-rc3 over ixgbe 10Gb NI=
C
> results:
>=20
> Message BW(Gb/s)qemu-kvm (NumCPU)vhost-net(NumCPU) PerfTop irq/s
> 4K      7408.57         92.1%           22.6%           1229
> 4K(Orig)4913.17         118.1%          84.1%           2086   =20
> 8K      9129.90         89.3%           23.3%           1141
> 8K(Orig)7094.55         115.9%          84.7%           2157
> 16K     9178.81         89.1%           23.3%           1139
> 16K(Orig)8927.1         118.7%          83.4%           2262
> 64K     9171.43         88.4%           24.9%           1253
> 64K(Orig)9085.85        115.9%          82.4%           2229
>=20
> For message size less or equal than 2K, there is a known KVM guest TX
> overrun issue. With this zero-copy patch, the issue becomes more seve=
re,
> guest io_exits has tripled than before, so the performance is not goo=
d.
> Once the TX overrun problem has been addressed, I will retest the sma=
ll
> message size performance.
>=20
>  drivers/net/macvtap.c  |  131
> ++++++++++++++++++++++++++++++++++++++++++++----
>  drivers/vhost/net.c    |   45 ++++++++++++++++-
>  drivers/vhost/vhost.c  |   51 +++++++++++++++++++
>  drivers/vhost/vhost.h  |   15 ++++++
>  include/linux/skbuff.h |   25 +++++++++
>  include/net/sock.h     |    1 +
>  net/core/skbuff.c      |   83 ++++++++++++++++++++++++++++++-
>  7 files changed, 338 insertions(+), 13 deletions(-)
>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe kvm" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
