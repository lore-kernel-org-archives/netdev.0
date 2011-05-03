From: Kalle Valo <kvalo-BkwN83ws05HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] net: fix rtnl even race in register_netdevice()
Date: Wed, 04 May 2011 01:13:33 +0300
Message-ID: <87ei4fh1pu.fsf@purkki.adurom.net>
References: <20110429172634.27130.25375.stgit@x201>
	<20110429.135339.200375209.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110429.135339.200375209.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> (David Miller's message of "Fri\, 29 Apr 2011 13\:53\:39 -0700 \(PDT\)")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> writes:

> From: Kalle Valo <kvalo-BkwN83ws05HQT0dZR+AlfA@public.gmane.org>
> Date: Fri, 29 Apr 2011 20:26:34 +0300
>
>> From: Kalle Valo <kalle.valo-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>
>> 
>> There's a race in register_netdevice so that the rtnl event is sent before
>> the device is actually ready. This was visible with flimflam, chrome os
>> connection manager:
>> 
>> 00:21:35 roska flimflamd[2598]: src/udev.c:add_net_device()
>> 00:21:35 roska flimflamd[2598]: connman_inet_ifname: SIOCGIFNAME(index
>>    4): No such device
>> 00:21:45 roska flimflamd[2598]: src/rtnl.c:rtnl_message() buf
>>    0xbfefda3c len 1004
>> 00:21:45 roska flimflamd[2598]: src/rtnl.c:rtnl_message()
>>    NEWLINK len 1004 type 16 flags 0x0000 seq 0

[...]

>> The fix is to call netdev_register_kobject() after the device is added
>> to the list.
>> 
>> Signed-off-by: Kalle Valo <kalle.valo-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>
>
> This is not correct.
>
> If you move the kobject registry around, you have to change the
> error handling cleanup to match.
>
> This change will leave the netdevice on all sorts of lists, it will
> also leak a reference to the device.
>
> I also think this points a fundamental problem with this change, in
> that you can't register the kobject after the device is added to
> the various lists in list_netdevice().
>
> Once it's in those lists, any thread of control can find the device
> and those threads of control may try to get at the data backed by
> the kobject and therefore they really expect it to be there by
> then.
>
> What you can do instead is try to delay the NETREG_REGISTERED
> setting, and block the problematic notifications by testing
> reg_state or similar.

I'm having difficulties to find a proper fix for the race. The uevent
is emitted from device_add() and I don't see how to block the event in
a clean way.

I tried to delay calling device_add() (patch below), but it didn't
work because register_queue_kobjects() expects that the parent device
is already added. I still need to investigate if I can delay creating
(or registering) queue kobjects.

This is a tricky problem and it's very easy to break something. I
would appreciate any help here. Maybe there's a better way to do this?

BTW, I can now easily reproduce the race on my laptop with e1000e and
a small test application. More info here:

https://bugzilla.kernel.org/show_bug.cgi?id=15606#c8

diff --git a/net/core/dev.c b/net/core/dev.c
index c2ac599..8882eaf 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5158,6 +5158,7 @@ static void rollback_registered_many(struct list_head *head)
 
 		/* Remove entries from kobject tree */
 		netdev_unregister_kobject(dev);
+		netdev_del_kobject(dev);
 	}
 
 	/* Process any work delayed until the end of the batch */
@@ -5432,7 +5433,6 @@ int register_netdevice(struct net_device *dev)
 	ret = netdev_register_kobject(dev);
 	if (ret)
 		goto err_uninit;
-	dev->reg_state = NETREG_REGISTERED;
 
 	netdev_update_features(dev);
 
@@ -5447,6 +5447,12 @@ int register_netdevice(struct net_device *dev)
 	dev_hold(dev);
 	list_netdevice(dev);
 
+	ret = netdev_add_kobject(dev);
+	if (ret)
+		goto err_unregister;
+
+	dev->reg_state = NETREG_REGISTERED;
+
 	/* Notify protocols, that a new device appeared. */
 	ret = call_netdevice_notifiers(NETDEV_REGISTER, dev);
 	ret = notifier_to_errno(ret);
@@ -5465,6 +5471,9 @@ int register_netdevice(struct net_device *dev)
 out:
 	return ret;
 
+err_unregister:
+	netdev_unregister_kobject(dev);
+
 err_uninit:
 	if (dev->netdev_ops->ndo_uninit)
 		dev->netdev_ops->ndo_uninit(dev);
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 5ceb257..db35137 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -1303,8 +1303,6 @@ void netdev_unregister_kobject(struct net_device * net)
 	kobject_get(&dev->kobj);
 
 	remove_queue_kobjects(net);
-
-	device_del(dev);
 }
 
 /* Create sysfs entries for network device. */
@@ -1312,7 +1310,6 @@ int netdev_register_kobject(struct net_device *net)
 {
 	struct device *dev = &(net->dev);
 	const struct attribute_group **groups = net->sysfs_groups;
-	int error = 0;
 
 	device_initialize(dev);
 	dev->class = &net_class;
@@ -1337,17 +1334,21 @@ int netdev_register_kobject(struct net_device *net)
 #endif
 #endif /* CONFIG_SYSFS */
 
-	error = device_add(dev);
-	if (error)
-		return error;
+	return register_queue_kobjects(net);
+}
 
-	error = register_queue_kobjects(net);
-	if (error) {
-		device_del(dev);
-		return error;
-	}
+void netdev_del_kobject(struct net_device *net)
+{
+	struct device *dev = &(net->dev);
 
-	return error;
+	device_del(dev);
+}
+
+int netdev_add_kobject(struct net_device *net)
+{
+	struct device *dev = &(net->dev);
+
+	return device_add(dev);
 }
 
 int netdev_class_create_file(struct class_attribute *class_attr)
diff --git a/net/core/net-sysfs.h b/net/core/net-sysfs.h
index bd7751e..ead06a1 100644
--- a/net/core/net-sysfs.h
+++ b/net/core/net-sysfs.h
@@ -4,6 +4,8 @@
 int netdev_kobject_init(void);
 int netdev_register_kobject(struct net_device *);
 void netdev_unregister_kobject(struct net_device *);
+int netdev_add_kobject(struct net_device *net);
+void netdev_del_kobject(struct net_device *net);
 int net_rx_queue_update_kobjects(struct net_device *, int old_num, int new_num);
 int netdev_queue_update_kobjects(struct net_device *net,
 				 int old_num, int new_num);
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
