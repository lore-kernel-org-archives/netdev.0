From: Petko Manolov <petkan@nucleusys.com>
Subject: Re: [PATCH 2/3] drivers: net: usb: pegasus: read/write_mii_word
 optimised
Date: Fri, 26 Apr 2013 11:41:36 +0300 (EEST)
Message-ID: <alpine.DEB.2.02.1304261137150.12284@fry.nucleusys.com>
References: <alpine.DEB.2.02.1304260944240.3746@fry.nucleusys.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.02.1304260944240.3746@fry.nucleusys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Petko Manolov <petkan@nucleusys.com>

Duplicated code in routines reading and writing MII registers is now 
packed in __mii_op().

Signed-off-by: Petko Manolov <petkan@nucleusys.com>
---
Diff made against latest net-next, not my git repository;

 drivers/net/usb/pegasus.c |   85 +++++++++++++++--------------------
 1 file changed, 35 insertions(+), 50 deletions(-)

diff --git a/drivers/net/usb/pegasus.c b/drivers/net/usb/pegasus.c
index ff7b84d..352b4dc 100644
--- a/drivers/net/usb/pegasus.c
+++ b/drivers/net/usb/pegasus.c
@@ -323,36 +323,50 @@ static int update_eth_regs_async(pegasus_t *pegasus)
 	return ret;
 }
 
-/* Returns 0 on success, error on failure */
-static int read_mii_word(pegasus_t *pegasus, __u8 phy, __u8 indx, __u16 *regd)
+static int __mii_op(pegasus_t *p, __u8 phy, __u8 indx, __u16 *regd, __u8 cmd)
 {
 	int i;
 	__u8 data[4] = { phy, 0, 0, indx };
 	__le16 regdi;
-	int ret;
+	int ret = -ETIMEDOUT;
 
-	set_register(pegasus, PhyCtrl, 0);
-	set_registers(pegasus, PhyAddr, sizeof(data), data);
-	set_register(pegasus, PhyCtrl, (indx | PHY_READ));
+	if (cmd & PHY_WRITE) {
+		__le16 *t = (__le16 *) & data[1];
+		*t = cpu_to_le16(*regd);
+	}
+	set_register(p, PhyCtrl, 0);
+	set_registers(p, PhyAddr, sizeof(data), data);
+	set_register(p, PhyCtrl, (indx | cmd));
 	for (i = 0; i < REG_TIMEOUT; i++) {
-		ret = get_registers(pegasus, PhyCtrl, 1, data);
-		if (ret == -ESHUTDOWN)
+		ret = get_registers(p, PhyCtrl, 1, data);
+		if (ret < 0)
 			goto fail;
 		if (data[0] & PHY_DONE)
 			break;
 	}
-
 	if (i >= REG_TIMEOUT)
 		goto fail;
-
-	ret = get_registers(pegasus, PhyData, 2, &regdi);
-	*regd = le16_to_cpu(regdi);
+	if (cmd & PHY_READ) {
+		ret = get_registers(p, PhyData, 2, &regdi);
+		*regd = le16_to_cpu(regdi);
+		return ret;
+	}
+	return 0;
+fail:
+	netif_dbg(p, drv, p->net, "%s failed\n", __func__);
 	return ret;
+}
 
-fail:
-	netif_warn(pegasus, drv, pegasus->net, "%s failed\n", __func__);
+/* Returns non-negative int on success, error on failure */
+static int read_mii_word(pegasus_t *pegasus, __u8 phy, __u8 indx, __u16 *regd)
+{
+	return __mii_op(pegasus, phy, indx, regd, PHY_READ);
+}
 
-	return ret;
+/* Returns zero on success, error on failure */
+static int write_mii_word(pegasus_t *pegasus, __u8 phy, __u8 indx, __u16 *regd)
+{
+	return __mii_op(pegasus, phy, indx, regd, PHY_WRITE);
 }
 
 static int mdio_read(struct net_device *dev, int phy_id, int loc)
@@ -364,40 +378,11 @@ static int mdio_read(struct net_device *dev, int phy_id, int loc)
 	return (int)res;
 }
 
-static int write_mii_word(pegasus_t *pegasus, __u8 phy, __u8 indx, __u16 regd)
-{
-	int i;
-	__u8 data[4] = { phy, 0, 0, indx };
-	int ret;
-
-	data[1] = (u8) regd;
-	data[2] = (u8) (regd >> 8);
-	set_register(pegasus, PhyCtrl, 0);
-	set_registers(pegasus, PhyAddr, sizeof(data), data);
-	set_register(pegasus, PhyCtrl, (indx | PHY_WRITE));
-	for (i = 0; i < REG_TIMEOUT; i++) {
-		ret = get_registers(pegasus, PhyCtrl, 1, data);
-		if (ret == -ESHUTDOWN)
-			goto fail;
-		if (data[0] & PHY_DONE)
-			break;
-	}
-
-	if (i >= REG_TIMEOUT)
-		goto fail;
-
-	return ret;
-
-fail:
-	netif_warn(pegasus, drv, pegasus->net, "%s failed\n", __func__);
-	return -ETIMEDOUT;
-}
-
 static void mdio_write(struct net_device *dev, int phy_id, int loc, int val)
 {
 	pegasus_t *pegasus = netdev_priv(dev);
 
-	write_mii_word(pegasus, phy_id, loc, val);
+	write_mii_word(pegasus, phy_id, loc, (__u16 *)&val);
 }
 
 static int read_eprom_word(pegasus_t *pegasus, __u8 index, __u16 *retdata)
@@ -434,7 +419,6 @@ fail:
 static inline void enable_eprom_write(pegasus_t *pegasus)
 {
 	__u8 tmp;
-	int ret;
 
 	get_registers(pegasus, EthCtrl2, 1, &tmp);
 	set_register(pegasus, EthCtrl2, tmp | EPROM_WR_ENABLE);
@@ -443,7 +427,6 @@ static inline void enable_eprom_write(pegasus_t *pegasus)
 static inline void disable_eprom_write(pegasus_t *pegasus)
 {
 	__u8 tmp;
-	int ret;
 
 	get_registers(pegasus, EthCtrl2, 1, &tmp);
 	set_register(pegasus, EpromCtrl, 0);
@@ -537,7 +520,8 @@ static inline int reset_mac(pegasus_t *pegasus)
 	if (usb_dev_id[pegasus->dev_index].vendor == VENDOR_ELCON) {
 		__u16 auxmode;
 		read_mii_word(pegasus, 3, 0x1b, &auxmode);
-		write_mii_word(pegasus, 3, 0x1b, auxmode | 4);
+		auxmode |= 4;
+		write_mii_word(pegasus, 3, 0x1b, &auxmode);
 	}
 
 	return 0;
@@ -569,7 +553,8 @@ static int enable_net_traffic(struct net_device *dev, struct usb_device *usb)
 	    usb_dev_id[pegasus->dev_index].vendor == VENDOR_DLINK) {
 		u16 auxmode;
 		read_mii_word(pegasus, 0, 0x1b, &auxmode);
-		write_mii_word(pegasus, 0, 0x1b, auxmode | 4);
+		auxmode |= 4;
+		write_mii_word(pegasus, 0, 0x1b, &auxmode);
 	}
 
 	return ret;
@@ -1144,7 +1129,7 @@ static int pegasus_ioctl(struct net_device *net, struct ifreq *rq, int cmd)
 	case SIOCDEVPRIVATE + 2:
 		if (!capable(CAP_NET_ADMIN))
 			return -EPERM;
-		write_mii_word(pegasus, pegasus->phy, data[1] & 0x1f, data[2]);
+		write_mii_word(pegasus, pegasus->phy, data[1] & 0x1f, &data[2]);
 		res = 0;
 		break;
 	default:
