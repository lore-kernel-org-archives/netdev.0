From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: [RFC v3 0/6] networking: address root block upon initialization
Date: Mon,  3 Mar 2014 14:46:59 -0800
Message-ID: <1393886825-24323-1-git-send-email-mcgrof@do-not-panic.com>
Cc: linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	xen-devel@lists.xenproject.org, mcgrof@suse.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Luis R. Rodriguez" <mcgrof@suse.com>

This is my third series on addressing removing the xen-netback hack of
using a high MAC address for a root block preference after feedback and
testing of the bridge feature Stephen mentioned. We want to remove that
hack as its possible to end up with IPv6 conflicts upon SLAAC and DAD.

As per Stephen we want to use the root_block preference but this is a
networking bridge port primitive, not a net_device feature. Since
ndo_add_slave() only lets us pass a net_device *and* since the bridge code
assumes outright that a slave devices can become a root port we have
to use a private flag on the net_device if a driver wants to enable
root block since initialization. If we don't address this preference
early the device may end up as the designated port and can run into
undesired link topology preferences.

As I tested using the root block preference I noticed that if a net_device
slave under the bridge gets the designated root port prior to setting in
userspace the root_block feature enabling the feature won't kick the
bridge to remove that net_device from the designated port. I addressed
that issue and also upkeeping the initial random MAC address given to
the bridge as if othwerwise we'd end up with a zero MAC address bridge
if we root block all ports. I have only done local tests I'd appreciate a
bit more wide test coverage and review.

I suspect the TAP devices used for virtualization can also benefit from this
flag so likewise since TAP devices can be tuned in userspace by design
we must enable an option to pass to userspace to let the tun driver set
the root block private flag prior to device registration. I'd be interested
to hear if folks usng kvm in a bridged topology have run into this issue
and if this addresses that issue there as well, I think it will.

If someone wants to test this in qemu the patch below can be used, but
note that this simply force-enables root block if the kernel has that
feature. Since I've heard claims that some topologies exist where
the virtualized backend device could be used as the designated port
on the bridge it may be desirable to enable qemu users to specify their
preference. If we however prove that we don't need this at all ever for
backends we likley want this enabled always.

These patches apply onto today's net-next.

diff --git a/net/tap-linux.c b/net/tap-linux.c
index 812bf2d..34be39d 100644
--- a/net/tap-linux.c
+++ b/net/tap-linux.c
@@ -61,6 +61,10 @@ int tap_open(char *ifname, int ifname_size, int *vnet_hdr,
         ifr.ifr_flags |= IFF_ONE_QUEUE;
     }
 
+    if (features & IFF_ROOT_BLOCK) {
+        ifr.ifr_flags |= IFF_ROOT_BLOCK;
+    }
+
     if (*vnet_hdr) {
         if (features & IFF_VNET_HDR) {
             *vnet_hdr = 1;
diff --git a/net/tap-linux.h b/net/tap-linux.h
index 1cf35d4..d59e477 100644
--- a/net/tap-linux.h
+++ b/net/tap-linux.h
@@ -42,6 +42,8 @@
 #define IFF_ATTACH_QUEUE 0x0200
 #define IFF_DETACH_QUEUE 0x0400
 
+#define IFF_ROOT_BLOCK   0x2000
+
 /* Features for GSO (TUNSETOFFLOAD). */
 #define TUN_F_CSUM	0x01	/* You can hand me unchecksummed packets. */
 #define TUN_F_TSO4	0x02	/* I can handle TSO for IPv4 packets */

Luis R. Rodriguez (6):
  bridge: preserve random init MAC address
  bridge: trigger a bridge calculation upon port changes
  bridge: fix bridge root block on designated port
  bridge: enable root block during device registration
  xen-netback: use a random MAC address and force bridge root block
  tun: add initialization root block support

 drivers/net/tun.c                   |  6 ++-
 drivers/net/xen-netback/interface.c | 14 +++----
 include/linux/netdevice.h           |  7 ++++
 include/uapi/linux/if_tun.h         |  1 +
 net/bridge/br_device.c              |  1 +
 net/bridge/br_if.c                  |  2 +
 net/bridge/br_netlink.c             | 24 ++++++++++++
 net/bridge/br_private.h             |  2 +
 net/bridge/br_stp.c                 | 73 ++++++++++++++++++++++++++++++++++---
 net/bridge/br_stp_if.c              |  6 ++-
 10 files changed, 119 insertions(+), 17 deletions(-)

-- 
1.9.0
