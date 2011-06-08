From: Barry G <mr.scada@gmail.com>
Subject: Configure Distributed Switch Architecture Via Device Tree
Date: Wed, 8 Jun 2011 10:18:15 -0700
Message-ID: <BANLkTikystOn-36tCWWnYZR7_+yx2wFt=Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:60137 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751443Ab1FHRSQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2011 13:18:16 -0400
Received: by bwz15 with SMTP id 15so606050bwz.19
        for <netdev@vger.kernel.org>; Wed, 08 Jun 2011 10:18:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

We are working on bringing up a powerpc platform that has a few
Marvell switches on it.  We would like to make use of the DSA
stuff in the kernel.

It appears all the devices currently in the kernel that use DSA
are done via the platform_add_devices route.  I was hoping
to use the device tree since most of the powerpc stuff does.

My main two questions right now are:
How do I pull together the various components into the
dsa structures and how do I register that structure with
the dsa subsystem.

I added the following to my device tree:
   virtual-device {
      compatible = "simple-bus";
      dsa {
         compatible = "vendor,my-dsa-of";
         ethernet-handle = <&enet0>;
         mdio-handle = <&mdio0>;
      };
   };

And wrote the attached driver.  It loads at boot, so I
know the compatible stuff is working and all, but
I am a little lost as to the next steps.  Any help
would be much appreciated.

Thanks,

Barry


Here is my first hack at a drive:
#include <linux/of.h>
#include <linux/kernel.h>
#include <linux/of_platform.h>
#include <net/dsa.h>

static struct dsa_chip_data switches[] = {
   {
      .sw_addr = 0,
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
      .rtable = (s8 []){-1, 8, 9},
   },
   {
      .sw_addr = 1,
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
         "cpu",   //10
      },
      .rtable = (s8 []){9, -1, 8},
   },
   {
      .sw_addr = 2,
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
      .rtable = (s8 []){8, 9, -1},
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

static int __devinit dsa_probe(struct platform_device *pdev)
{
   /* Question 1:
      I need to hookup the mii_bus in the dsa_chip_data and
      the netdev in the dsa_platform_data to the various
      struct device *s.  I could get access to the device nodes
      like:

      ph = of_get_property(np, "mdio-handle", NULL);
      mdio = of_find_node_by_phandle(*ph);

      Now I have the mdio device_node, but what do I do with
      it?  How do I get the device *?

      */

   /* Question 2: Whats the entry point into the DSA stuff
      now that I have my snazzy chips setup in the
      my_switch_data?  Usually it is added as a stamp device
      ad added with platform_add_devices.  Do I need to edit
      the DSA stuff to work with OF devices? */


   dev_info(&pdev->dev, "Initializing OF Marvell DSA driver\n");

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
