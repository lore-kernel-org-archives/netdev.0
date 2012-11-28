From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH 1/2] smsc75xx: refactor entering suspend modes
Date: Wed, 28 Nov 2012 13:57:33 +0100
Message-ID: <87wqx528ci.fsf@nemi.mork.no>
References: <87y5hm9ap5.fsf@nemi.mork.no>
	<Pine.LNX.4.44L0.1211271443150.1489-100000@iolanthe.rowland.org>
	<CAKh2mn7+0itrJNxmh6Wv9njGaNOY48N_zfJm6=gTeMoF2VzW4g@mail.gmail.com>
	<874nka3wgx.fsf@nemi.mork.no>
	<CAKh2mn5UGRN5U0w_bj25e4VnCwr9kK3f798nHSwmF4WE4dORMw@mail.gmail.com>
	<87k3t62btw.fsf@nemi.mork.no>
	<CAKh2mn7VsNYMO-qYyyqR==A2sXjkZo6QXj_kOuem4o1Vu-LLmw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alan Stern <stern@rowland.harvard.edu>,
	netdev <netdev@vger.kernel.org>, linux-usb@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Steve Glendinning <steve@shawell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:36213 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754136Ab2K1M5l convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 07:57:41 -0500
In-Reply-To: <CAKh2mn7VsNYMO-qYyyqR==A2sXjkZo6QXj_kOuem4o1Vu-LLmw@mail.gmail.com>
	(Steve Glendinning's message of "Wed, 28 Nov 2012 12:43:36 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Steve Glendinning <steve@shawell.net> writes:

>> Looking at the different ethernet drivers, the normal way do do this
>> seems to be something like this in their .set_wol implementation:
>>
>>         device_set_wakeup_enable(&adapter->pdev->dev, adapter->wol);
>>
>>
>> where "adapter" is a netdev_priv private struct, "pdev" is a pci dev=
ice
>> and "wol" is an u32.  I don't see any problem doing the same for USB
>> network devices implementing ethtool "set_wol".
>
> Ahh, good spot.  I've implemented this (patch below for reference) an=
d
> it still doesn't work:
>
>
> $ cat /sys/bus/usb/devices/2-1.2/power/wakeup
> disabled
>
> $ sudo ethtool -s eth2 wol p
>
> [ 1607.237767] smsc75xx 2-1.2:1.0 eth2: set_wol before
> device_can_wakeup=3D1 device_may_wakeup=3D0
> [ 1607.237772] smsc75xx 2-1.2:1.0 eth2: set_wol after
> device_can_wakeup=3D1 device_may_wakeup=3D1
>
> $ cat /sys/bus/usb/devices/2-1.2/power/wakeup
> disabled
>
>
> Huh?!  My debugging printk statements tell me I've succesfully set it=
,
> but then the sysfs entry is disabled when I read it.  Is something
> else setting this back?
>
> My testing patch for reference (note this is against my tree with a
> few to-be submitted patches so won't apply cleanly!):

[..]

> @@ -674,8 +653,19 @@ static int smsc75xx_ethtool_set_wol(struct net_d=
evice *net,
>  {
>   struct usbnet *dev =3D netdev_priv(net);
>   struct smsc75xx_priv *pdata =3D (struct smsc75xx_priv *)(dev->data[=
0]);
> + int ret;
> +
> + netdev_info(dev->net, "set_wol before device_can_wakeup=3D%d
> device_may_wakeup=3D%d\n",
> + device_can_wakeup(&net->dev), device_may_wakeup(&net->dev));
>
>   pdata->wolopts =3D wolinfo->wolopts & SUPPORTED_WAKE;
> +
> + ret =3D device_set_wakeup_enable(&net->dev, pdata->wolopts);

You are touching the network device here.  That should have been the US=
B
device.  Try something like

 ret =3D device_set_wakeup_enable(&dev->udev->dev, pdata->wolopts);

instead.



Bj=C3=B8rn
