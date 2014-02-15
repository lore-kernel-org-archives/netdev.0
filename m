From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: [RFC v2 0/4] net: bridge / ip optimizations for virtual net backends
Date: Fri, 14 Feb 2014 18:59:36 -0800
Message-ID: <1392433180-16052-1-git-send-email-mcgrof@do-not-panic.com>
Cc: xen-devel@lists.xenproject.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, "Luis R. Rodriguez" <mcgrof@suse.com>
To: netdev@vger.kernel.org
Return-path: <kvm-owner@vger.kernel.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Luis R. Rodriguez" <mcgrof@suse.com>

This v2 series changes the approach from my original virtualization
multicast patch series [0] by abandoning completely the multicast
issues and instead generalizing an approach for virtualization
backends. There are two things in common with virtualization
backends:

  0) they should not become the root bridge
  1) they don't need ipv4 / ipv6 interfaces

Both qemu's usage of TAP interfaces and xen-netback's driver
avoid getting their interfaces added to the root bridge by
using a high MAC address. Lets just generalize the solution
by making this a flag.

The skipping of IPv4 / IPv6 interfaces is an optimization
I observed possible while studying the xen-netback in a
shared physical bridge environment. I haven't been able
to test the NAT environment so I appreciate it if someone
can test these patches for that case if I don't get to it
eventually.

The same flags can be embraced by TAP interfaces when needed,
I tested this as a temporary patch as follows:

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 44c4db8..19b967e 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -940,6 +940,7 @@ static void tun_net_init(struct net_device *dev)
 		ether_setup(dev);
 		dev->priv_flags &= ~IFF_TX_SKB_SHARING;
 		dev->priv_flags |= IFF_LIVE_ADDR_CHANGE;
+		dev->priv_flags |= IFF_BRIDGE_NON_ROOT | IFF_SKIP_IP;
 
 		eth_hw_addr_random(dev);
 

a proper followup would be to specify the flags during open() or any
way prior, just to register_netdevice(). Before that is done we'd
need to evaluate all qemu use cases of the TAP interfaces both
for the xen HVM case (which tests fine for me) and for KVM's
use cases on both shared physical and in the NAT case. That is,
test the above patch and this series for all KVM / xen use cases.

[0] http://marc.info/?l=linux-netdev&m=139207142110536&w=2

Luis R. Rodriguez (4):
  bridge: enable interfaces to opt out from becoming the root bridge
  net: enables interface option to skip IP
  xen-netback: use a random MAC address
  xen-netback: skip IPv4 and IPv6 interfaces

 drivers/net/xen-netback/interface.c | 14 +++++---------
 include/uapi/linux/if.h             |  2 ++
 net/bridge/br_if.c                  |  2 ++
 net/bridge/br_private.h             |  1 +
 net/bridge/br_stp_if.c              |  2 ++
 net/ipv4/devinet.c                  |  3 +++
 net/ipv6/addrconf.c                 |  6 ++++++
 7 files changed, 21 insertions(+), 9 deletions(-)

-- 
1.8.5.2

