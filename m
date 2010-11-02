From: Jon Mason <jon.mason@exar.com>
Subject: Re: [PATCH 05/11] vxge: add support for ethtool firmware flashing
Date: Mon, 1 Nov 2010 23:04:56 -0500
Message-ID: <20101102040456.GC7938@exar.com>
References: <1288318786-12319-1-git-send-email-jon.mason@exar.com>
 <1288318786-12319-5-git-send-email-jon.mason@exar.com>
 <1288644687.2231.46.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Sivakumar Subramani <Sivakumar.Subramani@exar.com>,
	Sreenivasa Honnur <Sreenivasa.Honnur@exar.com>,
	Ramkrishna Vepa <Ramkrishna.Vepa@exar.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:58369 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750905Ab0KBEFE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Nov 2010 00:05:04 -0400
Received: by gyg4 with SMTP id 4so3731846gyg.19
        for <netdev@vger.kernel.org>; Mon, 01 Nov 2010 21:05:03 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1288644687.2231.46.camel@achroite.uk.solarflarecom.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 01, 2010 at 01:51:27PM -0700, Ben Hutchings wrote:
> On Thu, 2010-10-28 at 21:19 -0500, Jon Mason wrote:
> > Add the ability in the vxge driver to flash firmware via ethtool.
> [...]
> > +enum vxge_hw_status
> > +vxge_update_fw_image(struct __vxge_hw_device *hldev, const u8 *fwdata, int size)
> > +{
> > +	u64 data0 = 0, data1 = 0, steer_ctrl = 0;
> > +	struct __vxge_hw_virtualpath *vpath;
> > +	enum vxge_hw_status status;
> > +	int ret_code, sec_code, i;
> > +
> > +	vpath = &hldev->virtual_paths[hldev->first_vp_id];
> > +
> > +	/* send upgrade start command */
> > +	status = vxge_hw_vpath_fw_api(vpath,
> > +				      VXGE_HW_FW_UPGRADE_ACTION,
> > +				      VXGE_HW_FW_UPGRADE_MEMO,
> > +				      VXGE_HW_FW_UPGRADE_OFFSET_START,
> > +				      &data0, &data1, &steer_ctrl);
> > +	if (status != VXGE_HW_OK) {
> > +		vxge_debug_init(VXGE_ERR, " %s: Upgrade start cmd failed",
> > +				__func__);
> > +		return status;
> > +	}
> > +
> > +	/* Transfer fw image to adapter 16 bytes at a time */
> > +	for (; size > 0; size -= VXGE_HW_FW_UPGRADE_BLK_SIZE) {
> > +		data0 = data1 = steer_ctrl = 0;
> > +
> > +		/* send 16 bytes at a time */
> > +		for (i = 0; i < VXGE_HW_BYTES_PER_U64; i++) {
> > +			data0 |= (u64)fwdata[i] << (i * VXGE_HW_BYTES_PER_U64);
> 
> You apparently mean to multiply i by the number of bits in a byte here.
> This happens to be equal to VXGE_HW_BYTES_PER_U64 but it still doesn't
> make sense to use that name for it.

This is transfering the firmware image 128bits at a time.  If the name
is confusing, would a "sizeof(u64)" make more sense?

> 
> [...]
> > diff --git a/drivers/net/vxge/vxge-ethtool.c b/drivers/net/vxge/vxge-ethtool.c
> > index 6194fd9..c5ab375 100644
> > --- a/drivers/net/vxge/vxge-ethtool.c
> > +++ b/drivers/net/vxge/vxge-ethtool.c
> > @@ -11,7 +11,7 @@
> >   *                 Virtualized Server Adapter.
> >   * Copyright(c) 2002-2010 Exar Corp.
> >   ******************************************************************************/
> > -#include<linux/ethtool.h>
> > +#include <linux/ethtool.h>
> >  #include <linux/slab.h>
> >  #include <linux/pci.h>
> >  #include <linux/etherdevice.h>
> > @@ -29,7 +29,6 @@
> >   * Return value:
> >   * 0 on success.
> >   */
> > -
> >  static int vxge_ethtool_sset(struct net_device *dev, struct ethtool_cmd *info)
> >  {
> >  	/* We currently only support 10Gb/FULL */
> > @@ -148,8 +147,7 @@ static void vxge_ethtool_gregs(struct net_device *dev,
> >  static int vxge_ethtool_idnic(struct net_device *dev, u32 data)
> >  {
> >  	struct vxgedev *vdev = (struct vxgedev *)netdev_priv(dev);
> > -	struct __vxge_hw_device  *hldev = (struct __vxge_hw_device  *)
> > -			pci_get_drvdata(vdev->pdev);
> > +	struct __vxge_hw_device *hldev = vdev->devh;
> >  
> >  	vxge_hw_device_flick_link_led(hldev, VXGE_FLICKER_ON);
> >  	msleep_interruptible(data ? (data * HZ) : VXGE_MAX_FLICKER_TIME);
> > @@ -168,11 +166,10 @@ static int vxge_ethtool_idnic(struct net_device *dev, u32 data)
> >   *  void
> >   */
> >  static void vxge_ethtool_getpause_data(struct net_device *dev,
> > -					struct ethtool_pauseparam *ep)
> > +				       struct ethtool_pauseparam *ep)
> >  {
> >  	struct vxgedev *vdev = (struct vxgedev *)netdev_priv(dev);
> > -	struct __vxge_hw_device  *hldev = (struct __vxge_hw_device  *)
> > -			pci_get_drvdata(vdev->pdev);
> > +	struct __vxge_hw_device *hldev = vdev->devh;
> >  
> >  	vxge_hw_device_getpause_data(hldev, 0, &ep->tx_pause, &ep->rx_pause);
> >  }
> > @@ -188,11 +185,10 @@ static void vxge_ethtool_getpause_data(struct net_device *dev,
> >   * int, returns 0 on Success
> >   */
> >  static int vxge_ethtool_setpause_data(struct net_device *dev,
> > -					struct ethtool_pauseparam *ep)
> > +				      struct ethtool_pauseparam *ep)
> >  {
> >  	struct vxgedev *vdev = (struct vxgedev *)netdev_priv(dev);
> > -	struct __vxge_hw_device  *hldev = (struct __vxge_hw_device  *)
> > -			pci_get_drvdata(vdev->pdev);
> > +	struct __vxge_hw_device *hldev = vdev->devh;
> >  
> >  	vxge_hw_device_setpause_data(hldev, 0, ep->tx_pause, ep->rx_pause);
> >  
> > @@ -211,7 +207,7 @@ static void vxge_get_ethtool_stats(struct net_device *dev,
> >  	struct vxge_vpath *vpath = NULL;
> >  
> >  	struct vxgedev *vdev = (struct vxgedev *)netdev_priv(dev);
> > -	struct __vxge_hw_device  *hldev = vdev->devh;
> > +	struct __vxge_hw_device *hldev = vdev->devh;
> >  	struct vxge_hw_xmac_stats *xmac_stats;
> >  	struct vxge_hw_device_stats_sw_info *sw_stats;
> >  	struct vxge_hw_device_stats_hw_info *hw_stats;
> 
> These changes seem to be entirely unrelated to the patch description.

Yes, they should've been included in the cleanup patch.

> 
> > @@ -1153,6 +1149,25 @@ static int vxge_set_flags(struct net_device *dev, u32 data)
> >  	return 0;
> >  }
> >  
> > +static int vxge_fw_flash(struct net_device *dev, struct ethtool_flash *parms)
> > +{
> > +	struct vxgedev *vdev = (struct vxgedev *)netdev_priv(dev);
> > +
> > +	if (vdev->max_vpath_supported != VXGE_HW_MAX_VIRTUAL_PATHS) {
> > +		printk(KERN_INFO "Single Function Mode is required to flash the"
> > +		       " firmware\n");
> > +		return -EINVAL;
> > +	}
> > +
> > +	if (netif_running(dev)) {
> > +		printk(KERN_INFO "Interface %s must be down to flash the "
> > +		       "firmware\n", dev->name);
> > +		return -EINVAL;
> > +	}
> > +
> > +	return vxge_fw_upgrade(vdev, parms->data, 1);
> > +}
> 
> I think EBUSY is a more appropriate error code.  There is nothing wrong
> with the arguments, only the current state of the device.

Fair enough

> 
> [...]
> > diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.c
> > index d977a63..52a48e7 100644
> > --- a/drivers/net/vxge/vxge-main.c
> > +++ b/drivers/net/vxge/vxge-main.c
> [...]
> > @@ -3277,30 +3279,23 @@ vxge_device_unregister(struct __vxge_hw_device *hldev)
> >  	struct vxgedev *vdev;
> >  	struct net_device *dev;
> >  	char buf[IFNAMSIZ];
> > -#if ((VXGE_DEBUG_INIT & VXGE_DEBUG_MASK) || \
> > -	(VXGE_DEBUG_ENTRYEXIT & VXGE_DEBUG_MASK))
> > -	u32 level_trace;
> > -#endif
> >  
> >  	dev = hldev->ndev;
> >  	vdev = netdev_priv(dev);
> > -#if ((VXGE_DEBUG_INIT & VXGE_DEBUG_MASK) || \
> > -	(VXGE_DEBUG_ENTRYEXIT & VXGE_DEBUG_MASK))
> > -	level_trace = vdev->level_trace;
> > -#endif
> > -	vxge_debug_entryexit(level_trace,
> > -		"%s: %s:%d", vdev->ndev->name, __func__, __LINE__);
> > +	vxge_debug_entryexit(vdev->level_trace,	"%s: %s:%d", dev->name,
> > +			     __func__, __LINE__);
> >  
> > -	memcpy(buf, vdev->ndev->name, IFNAMSIZ);
> > +	memcpy(buf, dev->name, IFNAMSIZ);
> >  
> >  	/* in 2.6 will call stop() if device is up */
> >  	unregister_netdev(dev);
> >  
> >  	flush_scheduled_work();
> >  
> > -	vxge_debug_init(level_trace, "%s: ethernet device unregistered", buf);
> > -	vxge_debug_entryexit(level_trace,
> > -		"%s: %s:%d  Exiting...", buf, __func__, __LINE__);
> > +	vxge_debug_init(vdev->level_trace, "%s: ethernet device unregistered",
> > +			buf);
> > +	vxge_debug_entryexit(vdev->level_trace,	"%s: %s:%d  Exiting...", buf,
> > +			     __func__, __LINE__);
> >  }
> >  
> >  /*
> 
> More apparently unrelated changes.
> 
> > @@ -3924,6 +3919,142 @@ static inline u32 vxge_get_num_vfs(u64 function_mode)
> >  	return num_functions;
> >  }
> >  
> > +int vxge_fw_upgrade(struct vxgedev *vdev, char *fw_name, int override)
> > +{
> > +	struct __vxge_hw_device *hldev = vdev->devh;
> > +	u32 maj, min, bld, cmaj, cmin, cbld;
> > +	enum vxge_hw_status status;
> > +	const struct firmware *fw;
> > +	int ret;
> > +
> > +	ret = request_firmware(&fw, fw_name, &vdev->pdev->dev);
> > +	if (ret) {
> > +		vxge_debug_init(VXGE_ERR, "%s: Firmware file '%s' not found",
> > +				VXGE_DRIVER_NAME, fw_name);
> > +		goto out;
> > +	}
> > +
> > +	/* Load the new firmware onto the adapter */
> > +	status = vxge_update_fw_image(hldev, fw->data, fw->size);
> > +	if (status != VXGE_HW_OK) {
> > +		vxge_debug_init(VXGE_ERR,
> > +				"%s: FW image download to adapter failed '%s'.",
> > +				VXGE_DRIVER_NAME, fw_name);
> > +		ret = -EFAULT;
> 
> Surely EIO or EINVAL.

EIO would make more sense in the case, yes.

> 
> > +		goto out;
> > +	}
> > +
> > +	/* Read the version of the new firmware */
> > +	status = vxge_hw_upgrade_read_version(hldev, &maj, &min, &bld);
> > +	if (status != VXGE_HW_OK) {
> > +		vxge_debug_init(VXGE_ERR,
> > +				"%s: Upgrade read version failed '%s'.",
> > +				VXGE_DRIVER_NAME, fw_name);
> > +		ret = -EFAULT;
> 
> EIO.
> 
> > +		goto out;
> > +	}
> > +
> > +	cmaj = vdev->config.device_hw_info.fw_version.major;
> > +	cmin = vdev->config.device_hw_info.fw_version.minor;
> > +	cbld = vdev->config.device_hw_info.fw_version.build;
> > +	/* It's possible the version in /lib/firmware is not the latest version.
> > +	 * If so, we could get into a loop of trying to upgrade to the latest
> > +	 * and flashing the older version.
> > +	 */
> > +	if (VXGE_FW_VER(maj, min, bld) == VXGE_FW_VER(cmaj, cmin, cbld) &&
> > +	    !override) {
> > +		ret = -EINVAL;
> > +		goto out;
> > +	}
> > +
> > +	printk(KERN_NOTICE "Upgrade to firmware version %d.%d.%d commencing\n",
> > +	       maj, min, bld);
> > +
> > +	/* Flash the adapter with the new firmware */
> > +	status = vxge_hw_flash_fw(hldev);
> > +	if (status != VXGE_HW_OK) {
> > +		vxge_debug_init(VXGE_ERR, "%s: Upgrade commit failed '%s'.",
> > +				VXGE_DRIVER_NAME, fw_name);
> > +		ret = -EFAULT;
> > +		goto out;
> > +	}
> > +
> > +	printk(KERN_NOTICE "Upgrade of firmware successful!  Adapter must be "
> > +	       "hard reset before using, thus requiring a system reboot or a "
> > +	       "hotplug event.\n");
> 
> Then what is the point of having the driver manage this?  And how can
> you be sure the user will even see this message?

The device is unusable at this point.  Open will fail and rmmod/insmod
will fail with hardware errors.  On a PCI-hotplug system, the driver
could most likely call those functions directly, but this is not
something that should be done and will not work on non-hotplug
systems.  I am open to suggestions for alternatives.

> 
> [...]
> > +static int vxge_probe_fw_update(struct vxgedev *vdev)
> > +{
> [...]
> > +	ret = vxge_fw_upgrade(vdev, fw_name, 0);
> > +	/* -EINVAL and -ENOENT are not fatal errors for flashing firmware on
> > +	 * probe, so ignore them
> > +	 */
> > +	if (ret != -EINVAL && ret != -ENOENT)
> > +		return -EFAULT;
> [..]
> 
> EIO.

Thanks for the eyes :)
Jon

> 
> Ben.
> 
> -- 
> Ben Hutchings, Senior Software Engineer, Solarflare Communications
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
> 
