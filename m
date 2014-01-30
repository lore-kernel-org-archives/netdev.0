From: Tom Gundersen <teg@jklm.no>
Subject: [PATCH] net: set default DEVTYPE for all ethernet based devices
Date: Thu, 30 Jan 2014 14:20:02 +0100
Message-ID: <1391088002-15650-1-git-send-email-teg@jklm.no>
Cc: linux-kernel@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	Avinash Kumar <avi.kp.137@gmail.com>,
	Mauro Carvalho Chehab <mchehab@redhat.com>,
	Simon Horman <horms@verge.net.au>, Tom Gundersen <teg@jklm.no>,
	Marcel Holtmann <marcel@holtmann.org>,
	Greg KH <gregkh@linuxfoundation.org>,
	Kay Sievers <kay@vrfy.org>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In systemd's networkd and udevd, we would like to give the administrator a
simple way to filter net devices by their DEVTYPE [0][1]. Other software
such as ConnMan and NetworkManager uses a similar filtering already.

Currently, plain ethernet devices have DEVTYPE=(null). This patch sets the
devtype to "ethernet" instead. This avoids the need for special-casing the
DEVTYPE=(null) case in userspace, and also avoids false positives, as there
are several other types of netdevs that also have DEVTYPE=(null).

Notice that this is done, as suggested by Marcel, in alloc_etherdev_mqs(),
and as best I can tell it will not give any false positives. I considered
doing it in ether_setup() instead as that seemed more intuitive, but that
would give a lot of false positives indeed.

[0]: <http://www.freedesktop.org/software/systemd/man/systemd-networkd.service.html#Type>
[1]: <http://www.freedesktop.org/software/systemd/man/udev.html#Type>

Signed-off-by: Tom Gundersen <teg@jklm.no>
Cc: Marcel Holtmann <marcel@holtmann.org>
Cc: Greg KH <gregkh@linuxfoundation.org>
Cc: Kay Sievers <kay@vrfy.org>
---
 net/ethernet/eth.c | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index 8f032ba..b76dc17 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -369,6 +369,10 @@ void ether_setup(struct net_device *dev)
 }
 EXPORT_SYMBOL(ether_setup);
 
+static const struct device_type eth_type = {
+	.name = "ethernet",
+};
+
 /**
  * alloc_etherdev_mqs - Allocates and sets up an Ethernet device
  * @sizeof_priv: Size of additional driver-private structure to be allocated
@@ -387,7 +391,13 @@ EXPORT_SYMBOL(ether_setup);
 struct net_device *alloc_etherdev_mqs(int sizeof_priv, unsigned int txqs,
 				      unsigned int rxqs)
 {
-	return alloc_netdev_mqs(sizeof_priv, "eth%d", ether_setup, txqs, rxqs);
+	struct net_device* dev;
+
+	dev = alloc_netdev_mqs(sizeof_priv, "eth%d", ether_setup, txqs, rxqs);
+	if (dev)
+		dev->dev.type = &eth_type;
+
+	return dev;
 }
 EXPORT_SYMBOL(alloc_etherdev_mqs);
 
-- 
1.8.5.3
