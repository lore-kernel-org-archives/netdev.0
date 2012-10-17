From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: regression between v3.0 and v3.3 in bringing up IPoIB devices in a bond at boot
Date: Tue, 16 Oct 2012 21:58:17 -0700
Message-ID: <1143.1350449897@death.nxdomain>
References: <CAJtaB1vQymkE7ebTj6QRJ-+mfirpTjh=j6vxTdXQFqwtKrKQVg@mail.gmail.com>
Cc: netdev@vger.kernel.org, Jiri Pirko <jiri@resnulli.us>,
	Andy Gospodarek <andy@greyhouse.net>, davem@davemloft.net,
	kaber@trash.net
To: Jon Stanley <jstanley@rmrf.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:34547 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751294Ab2JQE7c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2012 00:59:32 -0400
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Tue, 16 Oct 2012 22:59:32 -0600
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id C24621FF0039
	for <netdev@vger.kernel.org>; Tue, 16 Oct 2012 22:58:13 -0600 (MDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q9H4wJ1W118372
	for <netdev@vger.kernel.org>; Tue, 16 Oct 2012 22:58:19 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q9H4wIhS011381
	for <netdev@vger.kernel.org>; Tue, 16 Oct 2012 22:58:19 -0600
In-reply-to: <CAJtaB1vQymkE7ebTj6QRJ-+mfirpTjh=j6vxTdXQFqwtKrKQVg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jon Stanley <jstanley@rmrf.net> wrote:

>Firstly, I apologize that this report isn't as well-formed as it
>should be (i.e. I can't point to a specific commit that broke it), but
>I'll do my best failing that. The reason I can't be as specific as I'd
>like is that starting at 3.1-rc1, I'd run into the original VLAN
>problem that I was having, and the patchset required to fix it (the
>patch just submitted, efc73f4b, and 9b361c1) won't apply cleanly to
>older kernels and I'm not sure it's worth the (seemingly massive)
>effort required to backport them to something I don't plan to use :)
>
>First, let me explain the configuration a little:
>
>bond0 -> eth0, eth1.100
>bond1 -> ib0, ib1
>
>The first problem, which is now resolved, was that ib0 and ib1
>wouldn't enslave at all because of the presence of VLAN0. I can now
>get them to enslave manually (echo +ib0 > /sys/.../slaves) *if* the
>bond is down. If the bond is up, I still get the "refused to change
>device type", which is fairly expected (I think, but that could be the
>problem here).
>
>However, if I leave the distro (stock RHEL except the kernel) to it's
>own devices to bring it up at boot, I get the same symptoms as though
>the master (bond1 in this case) isn't down ("refused to change device
>type"). If  I go back to v3.0, everything works fine. I've also
>verified that it doesn't work on current mainline, and that it works
>fine without any VLAN devices configured on bond0.

	I haven't debugged on a live kernel yet to verify this, but I
think I see what may be happening.  Basically, when the device is up,
VID 0 has been added, and the VLAN code refuses to change type on a
device with a VLAN configured (even VID 0).

	If the bond is down (really, has never been up) when the
NETDEV_PRE_TYPE_CHANGE event happens, the vlan_device_event callback
will exit, because dev->vlan_info is NULL (dev here is the bond).  It's
NULL because vlan_device_event will respond to a NETDEV_UP event by
adding VID 0 to the device, which is what allocates the dev->vlan_info,
so when the bond has never been up, there is no dev->vlan_info.

	Once the bond is up, when the NETDEV_PRE_TYPE_CHANGE event
reaches vlan_device_event, it will not exit as before, but proceed into
the switch, and the NETDEV_PRE_TYPE_CHANGE case always returns
NOTIFY_BAD, which results in the "refused to change type" message.

	It (in theory) works with no VLANs on bond0 because then I'll
guess that you have no VLANs at all, and therefore the 8021q module
isn't loaded, and so the whole "VID 0" and vlan_device_event business
doesn't take place.

	I think that if vlan_device_event instead uses the new &
improved vlan_uses_dev() test instead of its current test, that may
resolve the problem; here's a patch against current net that I have not
tested at all, but may fix things.  I'm not 100% sure this is the right
thing to do, as it may result in IPoIB interfaces with VID 0 configured
on them.

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 9096bcb..57170fa 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -342,7 +342,7 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 	}
 
 	vlan_info = rtnl_dereference(dev->vlan_info);
-	if (!vlan_info)
+	if (!vlan_info || !vlan_info->grp.nr_vlan_devs)
 		goto out;
 	grp = &vlan_info->grp;
 

	Comments?

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
