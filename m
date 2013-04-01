From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH]  net-sysfs: make flags symmetrical
Date: Mon, 1 Apr 2013 11:53:15 -0700
Message-ID: <20130401115315.1f8e4213@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:43738 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758184Ab3DASxc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Apr 2013 14:53:32 -0400
Received: by mail-pd0-f171.google.com with SMTP id z10so1372742pdj.16
        for <netdev@vger.kernel.org>; Mon, 01 Apr 2013 11:53:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The flags reported by sysfs are the raw kernel flags, not the version
exported to user space. This leads to the unsymmetrical behaviour that
read != write. An example of this is when a device is part of a
bridge.  The PROMISC flag returned from sysfs will not be the same as
other API's.

The reason this patch deserves wider discussion is someone might be
depending on sysfs to read raw kernel flags.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


--- a/net/core/net-sysfs.c	2013-03-21 14:17:08.740354291 -0700
+++ b/net/core/net-sysfs.c	2013-04-01 11:47:46.949728288 -0700
@@ -252,7 +252,19 @@ static ssize_t store_mtu(struct device *
 	return netdev_store(dev, attr, buf, len, change_mtu);
 }
 
-NETDEVICE_SHOW(flags, fmt_hex);
+static ssize_t show_flags(struct device *dev,
+			  struct device_attribute *attr, char *buf)
+{
+	struct net_device *ndev = to_net_dev(dev);
+	ssize_t ret = -EINVAL;
+
+	read_lock(&dev_base_lock);
+	if (dev_isalive(ndev))
+		ret = sprintf(buf, fmt_hex, dev_get_flags(ndev));
+	read_unlock(&dev_base_lock);
+
+	return ret;
+}
 
 static int change_flags(struct net_device *net, unsigned long new_flags)
 {
