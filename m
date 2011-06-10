From: Barry G <mr.scada@gmail.com>
Subject: Re: Configure Distributed Switch Architecture Via Device Tree
Date: Fri, 10 Jun 2011 08:14:39 -0700
Message-ID: <BANLkTin0L010DLSBitOgS09x6UDU-NYS=Q@mail.gmail.com>
References: <BANLkTikystOn-36tCWWnYZR7_+yx2wFt=Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:60456 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757555Ab1FJPOk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2011 11:14:40 -0400
Received: by bwz15 with SMTP id 15so2266398bwz.19
        for <netdev@vger.kernel.org>; Fri, 10 Jun 2011 08:14:39 -0700 (PDT)
In-Reply-To: <BANLkTikystOn-36tCWWnYZR7_+yx2wFt=Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just in case anyone else runs into this problem, this is what I ended up doing.
This code needs more error checking and isn't "right", plus it needs
to read the
chip mapping stuff from the OF, but it answers my original two questions :-)

#include <linux/of.h>
#include <linux/kernel.h>
#include <linux/of_platform.h>
#include <net/dsa.h>

static struct dsa_chip_data switches[] = {
   {
      .sw_addr = 0x9,
      .port_names = {
         "eth%d", //0
         "eth%d", //1
         "eth%d", //2
         "eth%d", //3
         "eth%d", //4
         "eth%d", //5
         "eth%d", //6
         "eth%d", //7
         NULL,   //8
         NULL,   //9
         "cpu",   //10
      },
      .rtable = (s8 []){-1, 9, 8},
   },
   {
      .sw_addr = 0xa,
      .port_names = {
         "eth%d", //0
         "eth%d", //1
         "eth%d", //2
         "eth%d", //3
         "eth%d", //4
         "eth%d", //5
         "eth%d", //6
         "eth%d", //7
         "dsa",   //8
         "dsa",   //9
      },
      .rtable = (s8 []){8, -1, 9},
   },
   {
      .sw_addr = 0x8,
      .port_names = {
         "eth%d", //0
         "eth%d", //1
         "eth%d", //2
         "eth%d", //3
         "eth%d", //4
         "eth%d", //5
         "eth%d", //6
         "eth%d", //7
         "dsa",   //8
         "dsa",   //9
         NULL,    //10
      },
      .rtable = (s8 []){9, 8, -1},
   },
};

static struct dsa_platform_data my_switch_data = {
   .nr_chips = 3,
   .chip = switches,
};

static int __devinit dsa_probe(struct platform_device *);
static int __devexit dsa_remove(struct platform_device *);

static const struct of_device_id dsa_match[] = {
   {
      .compatible = "vendor,my-dsa-of",
   },
   {}
};

static struct platform_driver dsa_driver = {
   .driver = {
      .name = "dsa-driver",
      .owner = THIS_MODULE,
      .of_match_table = dsa_match,
   },
   .probe = dsa_probe,
   .remove = dsa_remove,
};

static struct platform_device switchdriver = {
   .name = "dsa",
   .id = 0,
   .num_resources = 0,
   .dev.platform_data = &my_switch_data
};

static int __devinit dsa_probe(struct platform_device *pdev)
{
   struct device_node *np = pdev->dev.of_node;
   const phandle *mdio_ph;
   const phandle *ethernet_ph;

   struct device_node *mdio;
   struct device_node *ethernet;

   struct platform_device *mdio_pd;
   struct platform_device *ethernet_pd;

   int i;

   dev_info(&pdev->dev, "Initializing OF Marvell DSA driver\n");

   mdio_ph = of_get_property(np, "mdio-handle", NULL);
   ethernet_ph = of_get_property(np, "ethernet-handle", NULL);

   mdio = of_find_node_by_phandle(*mdio_ph);
   ethernet = of_find_node_by_phandle(*ethernet_ph);

   mdio_pd = of_find_device_by_node(mdio);
   ethernet_pd = of_find_device_by_node(ethernet);

   my_switch_data.netdev = &ethernet_pd->dev;

   for(i = 0; i < my_switch_data.nr_chips; i++)
   {
      switches[i].mii_bus = &mdio_pd->dev;
   }

   platform_device_register(&switchdriver);

   return 0;
}

static int __devexit dsa_remove(struct platform_device *pdev)
{
   printk("dsa_remove\n");
   return 0;
}


static int __init dsa_driver_init(void)
{
   printk("dsa_drver_init\n");
   return platform_driver_register(&dsa_driver);
}

static void __exit dsa_driver_cleanup(void)
{
   printk("dsa_driver_cleanup\n");
   platform_driver_unregister(&dsa_driver);
}

module_init(dsa_driver_init);
module_exit(dsa_driver_cleanup);

MODULE_DESCRIPTION("Marvell DSA OF driver");
MODULE_AUTHOR("Barry G <mr.scada@gmail.com>");
MODULE_LICENSE("GPL v2");
MODULE_ALIAS("platform:dsa-driver");
