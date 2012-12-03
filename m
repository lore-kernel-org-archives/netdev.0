From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: re: netdevice wanrouter: Convert directly reference of netdev->priv
Date: Mon, 3 Dec 2012 12:04:05 +0300
Message-ID: <20121203090405.GA12089@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:38167 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750800Ab2LCJEK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Dec 2012 04:04:10 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Wang Chen,

The patch 7be6065b39c3: "netdevice wanrouter: Convert directly
reference of netdev->priv" from Nov 20, 2008, leads to the following
Smatch warning:
net/wanrouter/wanmain.c:610 wanrouter_device_new_if()
	 error: potential NULL dereference 'dev'.

This is an old patch from 2008.  It removed the allocation in
wanrouter_device_new_if() so it looks like wanrouter has been completely
broken for four years.

@@ -589,10 +591,6 @@ static int wanrouter_device_new_if(struct wan_device *wandev,
                err = -EPROTONOSUPPORT;
                goto out;
        } else {
-               dev = kzalloc(sizeof(struct net_device), GFP_KERNEL);
-               err = -ENOBUFS;
-               if (dev == NULL)
-                       goto out;
                err = wandev->new_if(wandev, dev, cnf);

"dev" is still NULL after the call to ->new_if().

        }

Here is what the code looks like now:

net/wanrouter/wanmain.c
   590          if (cnf->config_id == WANCONFIG_MPPP) {
   591                  printk(KERN_INFO "%s: Wanpipe Mulit-Port PPP support has not been compiled in!\n",
   592                                  wandev->name);
   593                  err = -EPROTONOSUPPORT;
   594                  goto out;
   595          } else {

We were supposed to allocate "dev" here.

   596                  err = wandev->new_if(wandev, dev, cnf);
   597          }
   598  
   599          if (!err) {
   600                  /* Register network interface. This will invoke init()
   601                   * function supplied by the driver.  If device registered
   602                   * successfully, add it to the interface list.
   603                   */
   604  
   605  #ifdef WANDEBUG
   606                  printk(KERN_INFO "%s: registering interface %s...\n",
   607                         wanrouter_modname, dev->name);
   608  #endif
   609  
   610                  err = register_netdev(dev);
                              ^^^^^^^^^^^^^^^^^^^^

The kernel will always oops inside the call to register_netdev() because
"dev" is still NULL.

I suspect we should just revert the patch?

regards,
dan carpenter
