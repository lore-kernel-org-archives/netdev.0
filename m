From: "Alexander Y. Fomichev" <git.user@gmail.com>
Subject: Re: Is it normal to have cross namespace symlinks?
Date: Thu, 21 Aug 2014 19:13:16 +0400
Message-ID: <20140821191316.27807ef7@mad-cat.int.e5.ru>
References: <20140821143816.48c5ad08@mad-cat.int.e5.ru>
	<20140821121205.GR9476@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="MP_/LQM9xdmrMS5pR6TBWydphEq"
Cc: netdev@vger.kernel.org
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f181.google.com ([209.85.217.181]:58872 "EHLO
	mail-lb0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750857AbaHUPNh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2014 11:13:37 -0400
Received: by mail-lb0-f181.google.com with SMTP id 10so8359675lbg.12
        for <netdev@vger.kernel.org>; Thu, 21 Aug 2014 08:13:35 -0700 (PDT)
In-Reply-To: <20140821121205.GR9476@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--MP_/LQM9xdmrMS5pR6TBWydphEq
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Thu, 21 Aug 2014 14:12:05 +0200
Veaceslav Falico <vfalico@redhat.com> wrote:

> On Thu, Aug 21, 2014 at 02:38:16PM +0400, Alexander Y. Fomichev wrote:
> >Hello guys!
> >
> >Recently i switched to 3.14.x stable branch and i've got a bunch of
> >warnings:
> >
> >[   44.717746] ------------[ cut here ]------------
> >[   44.717750] WARNING: CPU: 1 PID: 7007 at fs/sysfs/dir.c:52
> >sysfs_warn_dup+0x86/0xa0() [   44.717751] sysfs: cannot create
> >duplicate filename
> >'/devices/pci0000:00/0000:00:1c.4/0000:05:00.0/net/eth1/upper_eth1'
> >
> >[   37.759856] ------------[ cut here ]------------
> >[   37.759863] WARNING: CPU: 1 PID: 3822 at fs/sysfs/dir.c:52
> >sysfs_warn_dup+0x86/0xa0() [   37.759864] sysfs: cannot create
> >duplicate filename '/devices/virtual/net/bond0/upper_eth0'
> >....
> >
> >It was triggered by renaming of macvlan interfaces in a freshly
> >created network namespaces. Just start two lxc containers one by one
> >with macvlans on the same lowerdev and rename devices inside
> >containers (with the same name) and voila.
> >v
> >I investigated problem a bit and i see that code in net/core/dev.c
> >which working with sysfs symlinks upper_dev / lower_dev is absolutely
> >unaware of namespaces. I mean code which uses functions
> >netdev_adjacent_sysfs_del,netdev_adjacent_sysfs_add
> >netdev_adjacent_rename_links,dev_change_name
> >just not takes into account that dev and adj_dev could be in a
> >different namespaces.
> 
> That's indeed so. When I've implemented it, I indeed didn't take into
> account net_ns, my bad.
> 
> Before the code, though, I'm not sure on how exactly to fix this. The
> only idea which comes to mind is to prohibit inter-net_ns symlinks
> (which can be done without much hassle) - i.e. to remove/add them on
> net_ns change, and to prohibit creating them on adding an inter-ns
> upper links.

uh.. seems like this is a first and only what come to mind. At least i
have something similar in my local tree. Though it looks pretty ugly and
required two ad-hoc functions traversing both adj_list(s). Though
again it works as expected in both directions so i attached it just in
case.

> However, as I definitely lack experience using net_ns, maybe there are
> other, better way, to fix this?

I can not say with confidence.. Someone of namespace guys better be
here.  as far as i can see the most notable thing in this context,
netdev belongs to only one net_ns at any one time and a little sense to
have a symlink on non-existent device.

-- 

Best regards.
        Alexander Y. Fomichev <Aleksandr.Fomichev@x5.ru>
	        +7-495-662-88-88 ext. 11346

--MP_/LQM9xdmrMS5pR6TBWydphEq
Content-Type: text/x-patch
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename=fix_netdev_adjacent_sysfs_links.patch

diff --git a/net/core/dev.c b/net/core/dev.c
index b65a505..683cedf 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4889,7 +4889,8 @@ static void __netdev_adjacent_dev_remove(struct net_device *dev,
 	if (adj->master)
 		sysfs_remove_link(&(dev->dev.kobj), "master");
 
-	if (netdev_adjacent_is_neigh_list(dev, dev_list))
+	if (netdev_adjacent_is_neigh_list(dev, dev_list) &&
+		net_eq(dev_net(dev),dev_net(adj_dev)))
 		netdev_adjacent_sysfs_del(dev, adj_dev->name, dev_list);
 
 	list_del_rcu(&adj->list);
@@ -5159,11 +5160,65 @@ void netdev_upper_dev_unlink(struct net_device *dev,
 }
 EXPORT_SYMBOL(netdev_upper_dev_unlink);
 
+void netdev_adjacent_add_links(struct net_device *dev)
+{
+	struct netdev_adjacent *iter;
+
+	struct net *net = dev_net(dev);
+
+	list_for_each_entry(iter, &dev->adj_list.upper, list) {
+		if (!net_eq(net,dev_net(iter->dev)))
+			continue;
+		netdev_adjacent_sysfs_add(iter->dev, dev,
+					  &iter->dev->adj_list.lower);
+		netdev_adjacent_sysfs_add(dev, iter->dev,
+					  &dev->adj_list.upper);
+	}
+
+	list_for_each_entry(iter, &dev->adj_list.lower, list) {
+		if (!net_eq(net,dev_net(iter->dev)))
+			continue;
+		netdev_adjacent_sysfs_add(iter->dev, dev,
+					  &iter->dev->adj_list.upper);
+		netdev_adjacent_sysfs_add(dev, iter->dev,
+					  &dev->adj_list.lower);
+	}
+}
+
+void netdev_adjacent_del_links(struct net_device *dev)
+{
+	struct netdev_adjacent *iter;
+
+	struct net *net = dev_net(dev);
+
+	list_for_each_entry(iter, &dev->adj_list.upper, list) {
+		if (!net_eq(net,dev_net(iter->dev)))
+			continue;
+		netdev_adjacent_sysfs_del(iter->dev, dev->name,
+					  &iter->dev->adj_list.lower);
+		netdev_adjacent_sysfs_del(dev, iter->dev->name,
+					  &dev->adj_list.upper);
+	}
+
+	list_for_each_entry(iter, &dev->adj_list.lower, list) {
+		if (!net_eq(net,dev_net(iter->dev)))
+			continue;
+		netdev_adjacent_sysfs_del(iter->dev, dev->name,
+					  &iter->dev->adj_list.upper);
+		netdev_adjacent_sysfs_del(dev, iter->dev->name,
+					  &dev->adj_list.lower);
+	}
+}
+
 void netdev_adjacent_rename_links(struct net_device *dev, char *oldname)
 {
 	struct netdev_adjacent *iter;
 
+	struct net *net = dev_net(dev);
+
 	list_for_each_entry(iter, &dev->adj_list.upper, list) {
+		if (!net_eq(net,dev_net(iter->dev)))
+			continue;
 		netdev_adjacent_sysfs_del(iter->dev, oldname,
 					  &iter->dev->adj_list.lower);
 		netdev_adjacent_sysfs_add(iter->dev, dev,
@@ -5171,6 +5226,8 @@ void netdev_adjacent_rename_links(struct net_device *dev, char *oldname)
 	}
 
 	list_for_each_entry(iter, &dev->adj_list.lower, list) {
+		if (!net_eq(net,dev_net(iter->dev)))
+			continue;
 		netdev_adjacent_sysfs_del(iter->dev, oldname,
 					  &iter->dev->adj_list.upper);
 		netdev_adjacent_sysfs_add(iter->dev, dev,
@@ -6771,8 +6828,10 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
 	dev_uc_flush(dev);
 	dev_mc_flush(dev);
 
+
 	/* Send a netdev-removed uevent to the old namespace */
 	kobject_uevent(&dev->dev.kobj, KOBJ_REMOVE);
+	netdev_adjacent_del_links(dev);
 
 	/* Actually switch the network namespace */
 	dev_net_set(dev, net);
@@ -6787,6 +6846,7 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
 
 	/* Send a netdev-add uevent to the new namespace */
 	kobject_uevent(&dev->dev.kobj, KOBJ_ADD);
+	netdev_adjacent_add_links(dev);
 
 	/* Fixup kobjects */
 	err = device_rename(&dev->dev, dev->name);

--MP_/LQM9xdmrMS5pR6TBWydphEq--
