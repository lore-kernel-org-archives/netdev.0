From: Zefir Kurtisi <zefir.kurtisi@neratec.com>
Subject: Re: [PATCH] net: add regs attribute to phy device for user diagnose
Date: Wed, 18 Jan 2017 13:37:06 +0100
Message-ID: <9ace94d7-0a3b-ff5f-63e1-53496e1e6b1b@neratec.com>
References: <20170115172150.GC5643@lunn.ch> <1484571579.3374.4.camel@163.com>
 <cf3e3125-582f-8b91-9c23-05dbdd2c6d24@gmail.com>
 <20170116.165401.1642553705400599921.davem@davemloft.net>
 <8729016553E3654398EA69218DA29EEF15A58E63@cnshjmbx04>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------24EC91287AB545E3493DCAAB"
Cc: "cugyly@163.com" <cugyly@163.com>,
        "andrew@lunn.ch" <andrew@lunn.ch>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: YUAN Linyu <Linyu.Yuan@alcatel-sbell.com.cn>,
        David Miller <davem@davemloft.net>,
        "f.fainelli@gmail.com" <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.neratec.com ([46.140.151.2]:20033 "EHLO mail.neratec.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751918AbdARMhP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 18 Jan 2017 07:37:15 -0500
In-Reply-To: <8729016553E3654398EA69218DA29EEF15A58E63@cnshjmbx04>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------24EC91287AB545E3493DCAAB
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit

On 01/17/2017 01:11 AM, YUAN Linyu wrote:
> 
> 
>> -----Original Message-----
>> From: David Miller [mailto:davem@davemloft.net]
>> Sent: Tuesday, January 17, 2017 5:54 AM
>> To: f.fainelli@gmail.com
>> Cc: cugyly@163.com; andrew@lunn.ch; netdev@vger.kernel.org; YUAN Linyu
>> Subject: Re: [PATCH] net: add regs attribute to phy device for user diagnose
>>
>> From: Florian Fainelli <f.fainelli@gmail.com>
>> Date: Mon, 16 Jan 2017 12:22:16 -0800
>>
>>>
>>> So why not add support in ethtool for reading PHY registers if you need
>>> it? There are handful of PHY "things" in ethtool, such as reading
>>> counters, configuring downshift etc., adding support for dumping
>>> registers does not sound out of space.
> Thanks, I will try this direction.
>>
>> Agreed.

... on the other hand, having direct RW access to MDIO regs can ease your life
greatly during bring-up / debugging of PHYs.

Attached is a patch we are using to track down PHY problems at register level, not
for integrating into the kernel but as a handy tool for developers.


Cheers,
Zefir



--------------24EC91287AB545E3493DCAAB
Content-Type: text/x-patch;
 name="0001-phy_device-add-sysfs-access-to-mdio-registers.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0001-phy_device-add-sysfs-access-to-mdio-registers.patch"

>From f90fced08ca6094919483b0d9a4bde50053bbbd7 Mon Sep 17 00:00:00 2001
From: Zefir Kurtisi <zefir.kurtisi@neratec.com>
Date: Wed, 18 Jan 2017 13:17:42 +0100
Subject: [PATCH] phy_device: add sysfs access to mdio registers

This commit adds a direct RW access to MDIO registers
over sysfs.

It is meant only for debugging and testing of PHYs
at register level.

WARNING: Writing to registers directly in most cases
will interfere with the phylib and/or upper layer
components or even crash your system.

Signed-off-by: Zefir Kurtisi <zefir.kurtisi@neratec.com>
---
 drivers/net/phy/phy_device.c | 111 +++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 111 insertions(+)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 92b0838..16646763 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -617,10 +617,121 @@ phy_has_fixups_show(struct device *dev, struct device_attribute *attr,
 }
 static DEVICE_ATTR_RO(phy_has_fixups);
 
+static ssize_t
+mdio_reg_show(struct device *dev, struct device_attribute *attr, char *buf)
+{
+	struct phy_device *phydev = to_phy_device(dev);
+	struct mii_bus *bus = to_mii_bus(dev);
+	int regnum;
+	int val;
+
+	if (sscanf(attr->attr.name, "%d", &regnum) != 1)
+		return -EINVAL;
+
+	val = mdiobus_read(bus, phydev->mdio.addr, regnum);
+	if (val < 0)
+		return -EIO;
+
+	return sprintf(buf, "0x%.4x\n", val);
+}
+
+static ssize_t mdio_reg_store(struct device *dev, struct device_attribute *attr,
+			      const char *buf, size_t size)
+{
+	struct phy_device *phydev = to_phy_device(dev);
+	struct mii_bus *bus = to_mii_bus(dev);
+	int regnum;
+	int val;
+	int err;
+
+	if (sscanf(attr->attr.name, "%d", &regnum) != 1)
+		return -EINVAL;
+
+	if (sscanf(buf, "%x", &val) != 1)
+		return -EINVAL;
+
+	if (val < 0 || val > 0xffff)
+		return -EINVAL;
+
+	err = mdiobus_write(bus, phydev->mdio.addr, regnum, val);
+	if (err < 0)
+		return -EIO;
+
+	return size;
+}
+
+#define MDIO_REG(_name) \
+	DEVICE_ATTR(_name, (S_IWUSR | S_IRUGO), mdio_reg_show, mdio_reg_store)
+
+static MDIO_REG(0);
+static MDIO_REG(1);
+static MDIO_REG(2);
+static MDIO_REG(3);
+static MDIO_REG(4);
+static MDIO_REG(5);
+static MDIO_REG(6);
+static MDIO_REG(7);
+static MDIO_REG(8);
+static MDIO_REG(9);
+static MDIO_REG(10);
+static MDIO_REG(11);
+static MDIO_REG(12);
+static MDIO_REG(13);
+static MDIO_REG(14);
+static MDIO_REG(15);
+static MDIO_REG(16);
+static MDIO_REG(17);
+static MDIO_REG(18);
+static MDIO_REG(19);
+static MDIO_REG(20);
+static MDIO_REG(21);
+static MDIO_REG(22);
+static MDIO_REG(23);
+static MDIO_REG(24);
+static MDIO_REG(25);
+static MDIO_REG(26);
+static MDIO_REG(27);
+static MDIO_REG(28);
+static MDIO_REG(29);
+static MDIO_REG(30);
+static MDIO_REG(31);
+
 static struct attribute *phy_dev_attrs[] = {
 	&dev_attr_phy_id.attr,
 	&dev_attr_phy_interface.attr,
 	&dev_attr_phy_has_fixups.attr,
+	&dev_attr_0.attr,
+	&dev_attr_1.attr,
+	&dev_attr_2.attr,
+	&dev_attr_3.attr,
+	&dev_attr_4.attr,
+	&dev_attr_5.attr,
+	&dev_attr_6.attr,
+	&dev_attr_7.attr,
+	&dev_attr_8.attr,
+	&dev_attr_9.attr,
+	&dev_attr_10.attr,
+	&dev_attr_11.attr,
+	&dev_attr_12.attr,
+	&dev_attr_13.attr,
+	&dev_attr_14.attr,
+	&dev_attr_15.attr,
+	&dev_attr_16.attr,
+	&dev_attr_17.attr,
+	&dev_attr_18.attr,
+	&dev_attr_19.attr,
+	&dev_attr_20.attr,
+	&dev_attr_21.attr,
+	&dev_attr_22.attr,
+	&dev_attr_23.attr,
+	&dev_attr_24.attr,
+	&dev_attr_25.attr,
+	&dev_attr_26.attr,
+	&dev_attr_27.attr,
+	&dev_attr_28.attr,
+	&dev_attr_29.attr,
+	&dev_attr_30.attr,
+	&dev_attr_31.attr,
 	NULL,
 };
 ATTRIBUTE_GROUPS(phy_dev);
-- 
2.7.4


--------------24EC91287AB545E3493DCAAB--
