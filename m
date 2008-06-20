From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next 3/8] bridge: Check return of
 dev_set_promiscuity
Date: Thu, 19 Jun 2008 18:18:19 -0700
Message-ID: <20080619181819.15b2cc9d@extreme>
References: <485AFFE4.4000300@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:52837 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750885AbYFTBSV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jun 2008 21:18:21 -0400
In-Reply-To: <485AFFE4.4000300@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 20 Jun 2008 08:55:00 +0800
Wang Chen <wangchen@cn.fujitsu.com> wrote:

> dev_set_promiscuity/allmulti might overflow.
> Commit: "netdevice: Fix promiscuity and allmulti overflow" in net-next makes
> dev_set_promiscuity/allmulti return error number if overflow happened.
> 
> Here, we check the positive increment for promiscuity to get error return.
> 
> BTW, I have to add a function to handle cleanup for br_sysfs_addif().
> I know Stephen has removed br_sysfs_removeif() to keep kobjects in use
> even if not using sysfs.
> But here we have a new br_sysfs_removeif() which only cleanup the sysfs
> and doesn't touch kobjects.
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>

Not that hard way please. Instead just rearrange the order of setup to avoid having to
do the things that are harder to unwind. Sysfs calls seem to be more fragile/error
prone than the simple counters.

Like this (untested)

--- a/net/bridge/br_if.c	2008-06-19 18:09:59.000000000 -0700
+++ b/net/bridge/br_if.c	2008-06-19 18:16:44.000000000 -0700
@@ -373,6 +373,10 @@ int br_add_if(struct net_bridge *br, str
 	if (IS_ERR(p))
 		return PTR_ERR(p);
 
+	err = dev_set_promiscuity(dev, 1);
+	if (err)
+		goto put_kobj;
+
 	err = kobject_init_and_add(&p->kobj, &brport_ktype, &(dev->dev.kobj),
 				   SYSFS_BRIDGE_PORT_ATTR);
 	if (err)
@@ -387,7 +391,6 @@ int br_add_if(struct net_bridge *br, str
 		goto err2;
 
 	rcu_assign_pointer(dev->br_port, p);
-	dev_set_promiscuity(dev, 1);
 
 	list_add_rcu(&p->list, &br->port_list);
 
@@ -416,6 +419,8 @@ err0:
 	kobject_put(&p->kobj);
 
 put_back:
+	dev_set_promiscuity(dev, -1);
+put_dev:
 	dev_put(dev);
 	return err;
 }
