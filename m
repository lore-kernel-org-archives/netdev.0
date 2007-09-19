From: Domen Puncer <domen@coderock.org>
Subject: Re: [PATCH] phy: export phy_mii_ioctl
Date: Wed, 19 Sep 2007 13:56:21 +0200
Message-ID: <20070919115621.GI32628@nd47.coderock.org>
References: <20070810095153.GC13994@moe.telargo.com> <20070902074143.GB2642@nd47.coderock.org> <fa686aa40709030857j6c36c87ek60215f812864ee0f@mail.gmail.com> <20070915121444.GA19857@nd47.coderock.org> <20070917095334.GA4546@powerlinux.fr> <20070917202140.GB2642@nd47.coderock.org> <9e4733910709171508s76c842c8hca236249617cbb44@mail.gmail.com> <20070918151622.GD32628@nd47.coderock.org> <9e4733910709181217v417438s85bb9e6b4ad4b475@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linuxppc-embedded@ozlabs.org,
	sven@powerlinux.fr
To: Jon Smirl <jonsmirl@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kukmak.uni-mb.si ([164.8.100.3]:60322 "EHLO kukmak.uni-mb.si"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754041AbXISL4Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Sep 2007 07:56:24 -0400
Content-Disposition: inline
In-Reply-To: <9e4733910709181217v417438s85bb9e6b4ad4b475@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 18/09/07 15:17 -0400, Jon Smirl wrote:
> On 9/18/07, Domen Puncer <domen@coderock.org> wrote:
> > More testing and getting it to work properly on Phytec pcm030 would
> > be great.
> 
> I compiled it as a module:
>   CC [M]  drivers/net/fec_mpc52xx/fec.o
> drivers/net/fec_mpc52xx/fec.c:613: warning: 'mpc52xx_fec_mac_setup'
> defined but not used
> 
> This code needs to be enclosed in "#ifndef MODULE". But why aren't you
> using module_param() to make a string parameter and then copy it into
> mpc52xx_fec_mac_addr[] if the parameter is not null?

Right,

Patch at the end.
When compiled as module use "modprobe fec_mpc52xx mac=foo",
when built-in add to boot line: "fec_mpc52xx.mac=foo"


As for link-up-printk in the middle of DHCP requests...
is it really that big of a problem?

This sort of things happen when printk doesn't have the whole
line... getting rid of link-up message would just hide it (it can show
ie. when an usb device is bound to scsi layer).


	Domen

---
 drivers/net/fec_mpc52xx/fec.c |   18 ++----------------
 1 files changed, 2 insertions(+), 16 deletions(-)

Index: linux.git/drivers/net/fec_mpc52xx/fec.c
===================================================================
--- linux.git.orig/drivers/net/fec_mpc52xx/fec.c
+++ linux.git/drivers/net/fec_mpc52xx/fec.c
@@ -53,6 +53,8 @@ static void fec_start(struct net_device 
 static void fec_reset(struct net_device *dev);
 
 static u8 mpc52xx_fec_mac_addr[6];
+module_param_array_named(mac, mpc52xx_fec_mac_addr, byte, NULL, 0);
+MODULE_PARM_DESC(mac, "six hex digits, ie. 0x1,0x2,0xc0,0x01,0xba,0xbe");
 
 static void fec_tx_timeout(struct net_device *dev)
 {
@@ -609,22 +611,6 @@ static void fec_set_multicast_list(struc
 	}
 }
 
-static int __init mpc52xx_fec_mac_setup(char *mac_address)
-{
-	int i;
-	u64 val64;
-
-	val64 = simple_strtoull(mac_address, NULL, 16);
-
-	for (i = 0; i < 6; i++)
-		mpc52xx_fec_mac_addr[5-i] = val64 >> (i*8);
-
-	return 0;
-}
-
-__setup("mpc52xx-mac=",mpc52xx_fec_mac_setup);
-
-
 /**
  * fec_hw_init
  * @dev: network device
