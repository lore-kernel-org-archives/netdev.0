From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: [RFC v3 6/6] tun: add initialization root block support
Date: Mon,  3 Mar 2014 14:47:05 -0800
Message-ID: <1393886825-24323-7-git-send-email-mcgrof@do-not-panic.com>
References: <1393886825-24323-1-git-send-email-mcgrof@do-not-panic.com>
Cc: linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	xen-devel@lists.xenproject.org, mcgrof@suse.com,
	Stephen Hemminger <stephen@networkplumber.org>,
	bridge@lists.linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1393886825-24323-1-git-send-email-mcgrof@do-not-panic.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Luis R. Rodriguez" <mcgrof@suse.com>

The networking bridge module allows us to specify a
root block preference on net_devices but this feature
is a bridge port primitive. The bridge module assumes
that once a device is added as a slave to the brige
that it can be considered for the the root port.
Furthermore ndo_add_slave() only lets us pass on the
net_device, but drivers that want to root block
since the beginning need specify their root block
preference prior to register_netdevice(). This means
the tun driver must expose a knob to userspace to
enable toggling this feature prior to adding the
device to a bridge to prevent any undesired link
bouncing issues on the bridge.

This should be useful for TAP interfaces which are used
for virtualization.

Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: bridge@lists.linux-foundation.org
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: xen-devel@lists.xenproject.org
Cc: kvm@vger.kernel.org
Signed-off-by: Luis R. Rodriguez <mcgrof@suse.com>
---
 drivers/net/tun.c           | 6 +++++-
 include/uapi/linux/if_tun.h | 1 +
 2 files changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 8fe9cb7..e763fad 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1693,6 +1693,9 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 		if (err < 0)
 			goto err_free_flow;
 
+		if (ifr->ifr_flags & IFF_ROOT_BLOCK)
+			dev->priv_flags |= IFF_BRIDGE_ROOT_BLOCK;
+
 		err = register_netdevice(tun->dev);
 		if (err < 0)
 			goto err_detach;
@@ -1898,7 +1901,8 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 		 * This is needed because we never checked for invalid flags on
 		 * TUNSETIFF. */
 		return put_user(IFF_TUN | IFF_TAP | IFF_NO_PI | IFF_ONE_QUEUE |
-				IFF_VNET_HDR | IFF_MULTI_QUEUE,
+				IFF_VNET_HDR | IFF_MULTI_QUEUE |
+				IFF_ROOT_BLOCK,
 				(unsigned int __user*)argp);
 	} else if (cmd == TUNSETQUEUE)
 		return tun_set_queue(file, &ifr);
diff --git a/include/uapi/linux/if_tun.h b/include/uapi/linux/if_tun.h
index e9502dd..f814a85 100644
--- a/include/uapi/linux/if_tun.h
+++ b/include/uapi/linux/if_tun.h
@@ -73,6 +73,7 @@
 /* read-only flag */
 #define IFF_PERSIST	0x0800
 #define IFF_NOFILTER	0x1000
+#define IFF_ROOT_BLOCK	0x2000
 
 /* Socket options */
 #define TUN_TX_TIMESTAMP 1
-- 
1.9.0

