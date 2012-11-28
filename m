From: Steve Glendinning <steve-nksJyM/082jR7s880joybQ@public.gmane.org>
Subject: Re: [PATCH 1/2] smsc75xx: refactor entering suspend modes
Date: Wed, 28 Nov 2012 12:43:36 +0000
Message-ID: <CAKh2mn7VsNYMO-qYyyqR==A2sXjkZo6QXj_kOuem4o1Vu-LLmw@mail.gmail.com>
References: <87y5hm9ap5.fsf@nemi.mork.no>
	<Pine.LNX.4.44L0.1211271443150.1489-100000@iolanthe.rowland.org>
	<CAKh2mn7+0itrJNxmh6Wv9njGaNOY48N_zfJm6=gTeMoF2VzW4g@mail.gmail.com>
	<874nka3wgx.fsf@nemi.mork.no>
	<CAKh2mn5UGRN5U0w_bj25e4VnCwr9kK3f798nHSwmF4WE4dORMw@mail.gmail.com>
	<87k3t62btw.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87k3t62btw.fsf-lbf33ChDnrE/G1V5fR+Y7Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> Looking at the different ethernet drivers, the normal way do do this
> seems to be something like this in their .set_wol implementation:
>
>         device_set_wakeup_enable(&adapter->pdev->dev, adapter->wol);
>
>
> where "adapter" is a netdev_priv private struct, "pdev" is a pci device
> and "wol" is an u32.  I don't see any problem doing the same for USB
> network devices implementing ethtool "set_wol".

Ahh, good spot.  I've implemented this (patch below for reference) and
it still doesn't work:


$ cat /sys/bus/usb/devices/2-1.2/power/wakeup
disabled

$ sudo ethtool -s eth2 wol p

[ 1607.237767] smsc75xx 2-1.2:1.0 eth2: set_wol before
device_can_wakeup=1 device_may_wakeup=0
[ 1607.237772] smsc75xx 2-1.2:1.0 eth2: set_wol after
device_can_wakeup=1 device_may_wakeup=1

$ cat /sys/bus/usb/devices/2-1.2/power/wakeup
disabled


Huh?!  My debugging printk statements tell me I've succesfully set it,
but then the sysfs entry is disabled when I read it.  Is something
else setting this back?

My testing patch for reference (note this is against my tree with a
few to-be submitted patches so won't apply cleanly!):


diff --git a/drivers/net/usb/smsc75xx.c b/drivers/net/usb/smsc75xx.c
index d8fa649..4c17849 100644
--- a/drivers/net/usb/smsc75xx.c
+++ b/drivers/net/usb/smsc75xx.c
@@ -61,7 +61,6 @@
 #define SUSPEND_SUSPEND1 (0x02)
 #define SUSPEND_SUSPEND2 (0x04)
 #define SUSPEND_SUSPEND3 (0x08)
-#define SUSPEND_REMOTEWAKE (0x10)
 #define SUSPEND_ALLMODES (SUSPEND_SUSPEND0 | SUSPEND_SUSPEND1 | \
  SUSPEND_SUSPEND2 | SUSPEND_SUSPEND3)

@@ -172,26 +171,6 @@ static int __must_check smsc75xx_write_reg(struct
usbnet *dev, u32 index,
  return __smsc75xx_write_reg(dev, index, data, 0);
 }

-static int smsc75xx_set_feature(struct usbnet *dev, u32 feature)
-{
- if (WARN_ON_ONCE(!dev))
- return -EINVAL;
-
- return usbnet_write_cmd_nopm(dev, USB_REQ_SET_FEATURE,
-     USB_DIR_OUT | USB_RECIP_DEVICE,
-     feature, 0, NULL, 0);
-}
-
-static int smsc75xx_clear_feature(struct usbnet *dev, u32 feature)
-{
- if (WARN_ON_ONCE(!dev))
- return -EINVAL;
-
- return usbnet_write_cmd_nopm(dev, USB_REQ_CLEAR_FEATURE,
-     USB_DIR_OUT | USB_RECIP_DEVICE,
-     feature, 0, NULL, 0);
-}
-
 /* Loop until the read is completed with timeout
  * called with phy_mutex held */
 static __must_check int __smsc75xx_phy_wait_not_busy(struct usbnet *dev,
@@ -674,8 +653,19 @@ static int smsc75xx_ethtool_set_wol(struct net_device *net,
 {
  struct usbnet *dev = netdev_priv(net);
  struct smsc75xx_priv *pdata = (struct smsc75xx_priv *)(dev->data[0]);
+ int ret;
+
+ netdev_info(dev->net, "set_wol before device_can_wakeup=%d
device_may_wakeup=%d\n",
+ device_can_wakeup(&net->dev), device_may_wakeup(&net->dev));

  pdata->wolopts = wolinfo->wolopts & SUPPORTED_WAKE;
+
+ ret = device_set_wakeup_enable(&net->dev, pdata->wolopts);
+ check_warn_return(ret, "device_set_wakeup_enable error %d\n", ret);
+
+ netdev_info(dev->net, "set_wol after device_can_wakeup=%d
device_may_wakeup=%d\n",
+ device_can_wakeup(&net->dev), device_may_wakeup(&net->dev));
+
  return 0;
 }

@@ -1197,12 +1187,17 @@ static int smsc75xx_bind(struct usbnet *dev,
struct usb_interface *intf)

  /* Init all registers */
  ret = smsc75xx_reset(dev);
+ check_warn_return(ret, "smsc75xx_reset error %d\n", ret);

  dev->net->netdev_ops = &smsc75xx_netdev_ops;
  dev->net->ethtool_ops = &smsc75xx_ethtool_ops;
  dev->net->flags |= IFF_MULTICAST;
  dev->net->hard_header_len += SMSC75XX_TX_OVERHEAD;
  dev->hard_mtu = dev->net->mtu + dev->net->hard_header_len;
+
+ ret = device_init_wakeup(&dev->net->dev, 1);
+ check_warn_return(ret, "device_init_wakeup error %d\n", ret);
+
  return 0;
 }

@@ -1262,9 +1257,7 @@ static int smsc75xx_enter_suspend0(struct usbnet *dev)
  ret = smsc75xx_write_reg_nopm(dev, PMT_CTL, val);
  check_warn_return(ret, "Error writing PMT_CTL\n");

- smsc75xx_set_feature(dev, USB_DEVICE_REMOTE_WAKEUP);
-
- pdata->suspend_flags |= SUSPEND_SUSPEND0 | SUSPEND_REMOTEWAKE;
+ pdata->suspend_flags |= SUSPEND_SUSPEND0;

  return 0;
 }
@@ -1291,9 +1284,7 @@ static int smsc75xx_enter_suspend1(struct usbnet *dev)
  ret = smsc75xx_write_reg_nopm(dev, PMT_CTL, val);
  check_warn_return(ret, "Error writing PMT_CTL\n");

- smsc75xx_set_feature(dev, USB_DEVICE_REMOTE_WAKEUP);
-
- pdata->suspend_flags |= SUSPEND_SUSPEND1 | SUSPEND_REMOTEWAKE;
+ pdata->suspend_flags |= SUSPEND_SUSPEND1;

  return 0;
 }
@@ -1348,9 +1339,7 @@ static int smsc75xx_enter_suspend3(struct usbnet *dev)
  ret = smsc75xx_write_reg_nopm(dev, PMT_CTL, val);
  check_warn_return(ret, "Error writing PMT_CTL\n");

- smsc75xx_set_feature(dev, USB_DEVICE_REMOTE_WAKEUP);
-
- pdata->suspend_flags |= SUSPEND_SUSPEND3 | SUSPEND_REMOTEWAKE;
+ pdata->suspend_flags |= SUSPEND_SUSPEND3;

  return 0;
  }
@@ -1650,11 +1639,6 @@ static int smsc75xx_resume(struct usb_interface *intf)
  /* do this first to ensure it's cleared even in error case */
  pdata->suspend_flags = 0;

- if (suspend_flags & SUSPEND_REMOTEWAKE) {
- ret = smsc75xx_clear_feature(dev, USB_DEVICE_REMOTE_WAKEUP);
- check_warn_return(ret, "Error disabling remote wakeup\n");
- }
