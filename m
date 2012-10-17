From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: regression between v3.0 and v3.3 in bringing up IPoIB devices in
 a bond at boot
Date: Wed, 17 Oct 2012 12:13:25 +0200
Message-ID: <20121017101325.GA6204@minipsycho.orion>
References: <CAJtaB1vQymkE7ebTj6QRJ-+mfirpTjh=j6vxTdXQFqwtKrKQVg@mail.gmail.com>
 <1143.1350449897@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jon Stanley <jstanley@rmrf.net>, netdev@vger.kernel.org,
	Andy Gospodarek <andy@greyhouse.net>, davem@davemloft.net,
	kaber@trash.net
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:49679 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756089Ab2JQKNb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2012 06:13:31 -0400
Received: by mail-wi0-f178.google.com with SMTP id hr7so478240wib.1
        for <netdev@vger.kernel.org>; Wed, 17 Oct 2012 03:13:29 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1143.1350449897@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Oct 17, 2012 at 06:58:17AM CEST, fubar@us.ibm.com wrote:
>Jon Stanley <jstanley@rmrf.net> wrote:
>
>>Firstly, I apologize that this report isn't as well-formed as it
>>should be (i.e. I can't point to a specific commit that broke it), but
>>I'll do my best failing that. The reason I can't be as specific as I'd
>>like is that starting at 3.1-rc1, I'd run into the original VLAN
>>problem that I was having, and the patchset required to fix it (the
>>patch just submitted, efc73f4b, and 9b361c1) won't apply cleanly to
>>older kernels and I'm not sure it's worth the (seemingly massive)
>>effort required to backport them to something I don't plan to use :)
>>
>>First, let me explain the configuration a little:
>>
>>bond0 -> eth0, eth1.100
>>bond1 -> ib0, ib1
>>
>>The first problem, which is now resolved, was that ib0 and ib1
>>wouldn't enslave at all because of the presence of VLAN0. I can now
>>get them to enslave manually (echo +ib0 > /sys/.../slaves) *if* the
>>bond is down. If the bond is up, I still get the "refused to change
>>device type", which is fairly expected (I think, but that could be the
>>problem here).
>>
>>However, if I leave the distro (stock RHEL except the kernel) to it's
>>own devices to bring it up at boot, I get the same symptoms as though
>>the master (bond1 in this case) isn't down ("refused to change device
>>type"). If  I go back to v3.0, everything works fine. I've also
>>verified that it doesn't work on current mainline, and that it works
>>fine without any VLAN devices configured on bond0.
>
>	I haven't debugged on a live kernel yet to verify this, but I
>think I see what may be happening.  Basically, when the device is up,
>VID 0 has been added, and the VLAN code refuses to change type on a
>device with a VLAN configured (even VID 0).
>
>	If the bond is down (really, has never been up) when the
>NETDEV_PRE_TYPE_CHANGE event happens, the vlan_device_event callback
>will exit, because dev->vlan_info is NULL (dev here is the bond).  It's
>NULL because vlan_device_event will respond to a NETDEV_UP event by
>adding VID 0 to the device, which is what allocates the dev->vlan_info,
>so when the bond has never been up, there is no dev->vlan_info.
>
>	Once the bond is up, when the NETDEV_PRE_TYPE_CHANGE event
>reaches vlan_device_event, it will not exit as before, but proceed into
>the switch, and the NETDEV_PRE_TYPE_CHANGE case always returns
>NOTIFY_BAD, which results in the "refused to change type" message.
>
>	It (in theory) works with no VLANs on bond0 because then I'll
>guess that you have no VLANs at all, and therefore the 8021q module
>isn't loaded, and so the whole "VID 0" and vlan_device_event business
>doesn't take place.
>
>	I think that if vlan_device_event instead uses the new &
>improved vlan_uses_dev() test instead of its current test, that may
>resolve the problem; here's a patch against current net that I have not
>tested at all, but may fix things.  I'm not 100% sure this is the right
>thing to do, as it may result in IPoIB interfaces with VID 0 configured
>on them.


I strongly believe you are right Jay. I will look at this and fix it.

Thanks

Jiri

>
>diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
>index 9096bcb..57170fa 100644
>--- a/net/8021q/vlan.c
>+++ b/net/8021q/vlan.c
>@@ -342,7 +342,7 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
> 	}
> 
> 	vlan_info = rtnl_dereference(dev->vlan_info);
>-	if (!vlan_info)
>+	if (!vlan_info || !vlan_info->grp.nr_vlan_devs)
> 		goto out;
> 	grp = &vlan_info->grp;
> 
>
>	Comments?
>
>	-J
>
>---
>	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
>
