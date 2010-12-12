From: Shmulik Hen <shmulik@trego.co.il>
Subject: System blocks (hangs) on ifconfig up
Date: Sun, 12 Dec 2010 17:08:44 +0200
Message-ID: <4D04E57C.7020509@trego.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f45.google.com ([209.85.214.45]:53563 "EHLO
	mail-bw0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751614Ab0LLPIr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Dec 2010 10:08:47 -0500
Received: by bwz16 with SMTP id 16so5769080bwz.4
        for <netdev@vger.kernel.org>; Sun, 12 Dec 2010 07:08:46 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

My system is Ubuntu 10.04, running kernel 2.6.32-26-generic.

Whenever I try to bring up a specific ethernet interface for the second 
time, my
system becomes unresponsive for 60 seconds - i.e. no mouse, no keyboard, no
screen refresh. etc.

Looking at the driver's code, I could see that it's dev->open() method 
calls
wait_event_interruptible_timeout() with a timeout of 60 seconds - exactly
the delay I'm seeing.

I have narrowed the code to a bare minimum (see below - loosely based on
dummy.c), which only calls mdelay(10000) in it's dev->open() method, and
still, my system blocks for exactly 10 seconds when I run the following
sequence:

 > sudo ifconfig shmulik0 up
 > sudo ifconfig shmulik0 down
 > sudo ifconfig shmulik0 up

At this point - the system is stuck for 10 seconds.


Thanks,
Shmulik.

------------------------------------------------------------------------------ 


shmulik.c:

#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/netdevice.h>
#include <linux/etherdevice.h>
#include <linux/init.h>
#include <linux/delay.h>
#include <linux/skbuff.h>

MODULE_AUTHOR("Shmulik Hen");
MODULE_DESCRIPTION("Shmulik's sample network driver");
MODULE_LICENSE("GPL");

static struct net_device *g_dev = NULL;

static int shmulik_set_mac_address(struct net_device *dev, void *p)
{
     struct sockaddr *sa = p;

     if (!is_valid_ether_addr(sa->sa_data))
         return -EADDRNOTAVAIL;

     memcpy(dev->dev_addr, sa->sa_data, ETH_ALEN);
     return 0;
}

static netdev_tx_t shmulik_start_xmit(struct sk_buff *skb, struct 
net_device *dev)
{
     dev_kfree_skb(skb);
     return NETDEV_TX_OK;
}

static int shmulik_open(struct net_device *dev)
{
     mdelay(10000);
     netif_carrier_on(dev);
     netif_start_queue(dev);

     return 0;
}

static int shmulik_close(struct net_device *dev)
{
     netif_stop_queue(dev);
     netif_carrier_off(dev);

     return 0;
}

static const struct net_device_ops shmulik_drv_ops =
{
     .ndo_open            = shmulik_open,
     .ndo_stop            = shmulik_close,
     .ndo_start_xmit      = shmulik_start_xmit,
     .ndo_set_mac_address = shmulik_set_mac_address,
};

static int __init shmulik_drv_init(void)
{
     int rc;
     struct net_device *dev;

     if (g_dev)
         return -EEXIST;

     dev = alloc_etherdev(0);
     if (!dev)
         return -ENOMEM;

     sprintf(dev->name, "%s%d" , "shmulik", 0);
     dev->tx_queue_len = 0;
     dev->flags |= IFF_NOARP;
     dev->flags &= ~IFF_MULTICAST;
     random_ether_addr(dev->dev_addr);

     dev->netdev_ops = &shmulik_drv_ops;

     rc = register_netdev(dev);
     if (rc)
         goto err_exit;

     g_dev = dev;
     return 0;

err_exit:
     free_netdev(dev);
     return rc;
}

static void __exit shmulik_drv_exit(void)
{
     if (g_dev)
     {
         unregister_netdev(g_dev);
         free_netdev(g_dev);
         g_dev = NULL;
     }
}

module_init(shmulik_drv_init);
module_exit(shmulik_drv_exit);

