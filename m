From: Kay Sievers <kay.sievers@vrfy.org>
Subject: Re: [RFC][PATCH] Fix another namespace issue with devices assigned
 to  classes
Date: Mon, 07 Jun 2010 14:26:03 +0200
Message-ID: <1275913563.1823.1.camel@yio.site>
References: <1275484611.3915.11.camel@jlt3.sipsolutions.net>
	 <20100602154608.GB12361@kroah.com>
	 <1275493693.3915.12.camel@jlt3.sipsolutions.net>
	 <m1ljaxxvcj.fsf@fess.ebiederm.org>
	 <1275495677.3915.16.camel@jlt3.sipsolutions.net>
	 <m14ohlxu51.fsf@fess.ebiederm.org>
	 <1275498007.3915.20.camel@jlt3.sipsolutions.net>
	 <m1ocftwdp7.fsf@fess.ebiederm.org>
	 <1275501157.3915.22.camel@jlt3.sipsolutions.net>
	 <m1y6exux6x.fsf@fess.ebiederm.org>
	 <1275506732.3915.41.camel@jlt3.sipsolutions.net>
	 <m16321t4ke.fsf@fess.ebiederm.org> <m17hmhrl6v.fsf_-_@fess.ebiederm.org>
	 <1275634452.5189.1.camel@jlt3.sipsolutions.net>
	 <AANLkTingSwM7e8ldyT1FplF5WCHBsCBCwNkb5ZPHe6hB@mail.gmail.com>
	 <1275640113.9953.8.camel@jlt3.sipsolutions.net>
	 <AANLkTin6ub4k4QYSMnGLRw7lxQaz23Xmo2GQC1RrUf-X@mail.gmail.com>
	 <1275829701.3615.54.camel@jlt3.sipsolutions.net>
	 <AANLkTinUAR2gkY7ipgXKy-pMHcmLuouEeyXxnP97U_7N@mail.gmail.com>
	 <1275903773.29978.1.camel@jlt3.sipsolutions.net>
	 <AANLkTin_qjU0-xXfMDYeYWRd0BmvT4OIdK4S_GQ3ZYUi@mail.gmail.com>
	 <1275905686.29978.3.camel@jlt3.sipsolutions.net>
	 <AANLkTikMDvpEzrtFVue8gStudKONxuQmVx9B2w1JM1vO@mail.gmail.com>
	 <1275910905.29978.7.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Greg KH <greg@kroah.com>, netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.159]:36028 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752558Ab0FGM1F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jun 2010 08:27:05 -0400
Received: by fg-out-1718.google.com with SMTP id d23so1633516fga.1
        for <netdev@vger.kernel.org>; Mon, 07 Jun 2010 05:27:03 -0700 (PDT)
In-Reply-To: <1275910905.29978.7.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 7, 2010 at 13:41, Johannes Berg <johannes@sipsolutions.net> wrote:
> (mind you, I think we probably need to have the bus/driver assignment,
> but I wanted to try out your suggestion first)

Class device can never have a driver. And unregistered drivers can
not be used, what you try to do here. That all should just be removed or
properly registered with the core if needed.

> So I removed bus/driver assignment from the above code just to try it
> out, and got
>
> Device 'hwsim0' does not have a release() function, it is broken and
> must be fixed.

The driver core expects the resources of the device to be freed on
release. You can provide an empty release function because you do this
from a global list of devices.

> This has evolved far too much for me right now. Can we just apply the
> initial patch from Eric and be happier for a while? I can't justify
> spending this much time on it right now. Alternatively, you could look
> at hwsim too, since it's all virtual, nothing special is required, I do
> testing in a virtual machine ...
>
> current patch is at
> http://johannes.sipsolutions.net/patches/kernel/all/2010-06-07-11:41/hwsim-bus.patch

Here is something that seems to work for me.

Cheers,
Kay



diff --git a/drivers/net/wireless/mac80211_hwsim.c b/drivers/net/wireless/mac80211_hwsim.c
index 6f8cb3e..d210ce6 100644
--- a/drivers/net/wireless/mac80211_hwsim.c
+++ b/drivers/net/wireless/mac80211_hwsim.c
@@ -194,7 +194,13 @@ static inline void hwsim_clear_sta_magic(struct ieee80211_sta *sta)
 	sp->magic = 0;
 }
 
-static struct class *hwsim_class;
+static struct bus_type hwsim_bus = {
+	.name = "mac80211_hwsim",
+};
+
+static struct device hwsim_parent = {
+	.init_name = "mac80211_hwsim",
+};
 
 static struct net_device *hwsim_mon; /* global monitor netdev */
 
@@ -1071,14 +1077,10 @@ static void mac80211_hwsim_free(void)
 		device_unregister(data->dev);
 		ieee80211_free_hw(data->hw);
 	}
-	class_destroy(hwsim_class);
+	device_unregister(&hwsim_parent);
+	bus_unregister(&hwsim_bus);
 }
 
-
-static struct device_driver mac80211_hwsim_driver = {
-	.name = "mac80211_hwsim"
-};
-
 static const struct net_device_ops hwsim_netdev_ops = {
 	.ndo_start_xmit 	= hwsim_mon_xmit,
 	.ndo_change_mtu		= eth_change_mtu,
@@ -1231,6 +1233,9 @@ DEFINE_SIMPLE_ATTRIBUTE(hwsim_fops_group,
 			hwsim_fops_group_read, hwsim_fops_group_write,
 			"%llx\n");
 
+/* all devices are kept in out own list and the ressources are freed on exit */
+static void hwsim_dev_release(struct device* dev) {}
+
 static int __init init_mac80211_hwsim(void)
 {
 	int i, err = 0;
@@ -1251,9 +1256,15 @@ static int __init init_mac80211_hwsim(void)
 	spin_lock_init(&hwsim_radio_lock);
 	INIT_LIST_HEAD(&hwsim_radios);
 
-	hwsim_class = class_create(THIS_MODULE, "mac80211_hwsim");
-	if (IS_ERR(hwsim_class))
-		return PTR_ERR(hwsim_class);
+	err = bus_register(&hwsim_bus);
+	if (err)
+		return err;
+
+	err = device_register(&hwsim_parent);
+	if (err) {
+		bus_unregister(&hwsim_bus);
+		return err;
+	}
 
 	memset(addr, 0, ETH_ALEN);
 	addr[0] = 0x02;
@@ -1271,16 +1282,24 @@ static int __init init_mac80211_hwsim(void)
 		data = hw->priv;
 		data->hw = hw;
 
-		data->dev = device_create(hwsim_class, NULL, 0, hw,
-					  "hwsim%d", i);
-		if (IS_ERR(data->dev)) {
-			printk(KERN_DEBUG
-			       "mac80211_hwsim: device_create "
-			       "failed (%ld)\n", PTR_ERR(data->dev));
+		data->dev = kzalloc(sizeof(struct device), GFP_KERNEL);
+		if (!data->dev) {
 			err = -ENOMEM;
 			goto failed_drvdata;
 		}
-		data->dev->driver = &mac80211_hwsim_driver;
+
+		dev_set_name(data->dev, "hwsim%d", i);
+		data->dev->parent = &hwsim_parent;
+		data->dev->bus = &hwsim_bus;
+		data->dev->release = hwsim_dev_release;
+
+		err = device_register(data->dev);
+		if (err) {
+			printk(KERN_DEBUG
+			       "mac80211_hwsim: device_register failed (%d)\n",
+			       err);
+			goto failed_drvdata;
+		}
 
 		SET_IEEE80211_DEV(hw, data->dev);
 		addr[3] = i >> 8;



