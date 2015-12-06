From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: gigaset: freeing an active object
Date: Sun, 06 Dec 2015 21:12:22 +0100
Message-ID: <1449432742.2515.20.camel@tiscali.nl>
References: <56587467.8050102@oracle.com> <565B1A1B.8020503@imap.cc>
	 <565B4256.6080101@hurleysoftware.com> <565B4844.9020600@imap.cc>
	 <1448828800.2603.17.camel@tiscali.nl> <1448839396.2891.14.camel@tiscali.nl>
	 <1448906497.3546.16.camel@tiscali.nl> <565F8341.7010704@hurleysoftware.com>
	 <1449408690.2515.15.camel@tiscali.nl> <5664545C.90607@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, davem@davemloft.net,
	gigaset307x-common@lists.sourceforge.net,
	LKML <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>
To: Tilman Schmidt <tilman@imap.cc>,
	Peter Hurley <peter@hurleysoftware.com>,
	Sasha Levin <sasha.levin@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lb1-smtp-cloud6.xs4all.net ([194.109.24.24]:50699 "EHLO
	lb1-smtp-cloud6.xs4all.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754125AbbLFUM0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Dec 2015 15:12:26 -0500
In-Reply-To: <5664545C.90607@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On zo, 2015-12-06 at 16:29 +0100, Tilman Schmidt wrote:
> So the solution might be as simple as moving the kfree() call from
> gigaset_freecshw() to gigaset_device_release(). Something like this:
> 
> --- a/drivers/isdn/gigaset/ser-gigaset.c
> +++ b/drivers/isdn/gigaset/ser-gigaset.c
> @@ -370,19 +370,18 @@ static void gigaset_freecshw(struct cardstate
> *cs)
>         tasklet_kill(&cs->write_tasklet);
>         if (!cs->hw.ser)
>                 return;
> -       dev_set_drvdata(&cs->hw.ser->dev.dev, NULL);
>         platform_device_unregister(&cs->hw.ser->dev);
> -       kfree(cs->hw.ser);
> -       cs->hw.ser = NULL;
>  }
> 
>  static void gigaset_device_release(struct device *dev)
>  {
> -       struct platform_device *pdev = to_platform_device(dev);
> +       struct cardstate *cs = dev_get_drvdata(dev);
> 
> -       /* adapted from platform_device_release() in
> drivers/base/platform.c */
> -       kfree(dev->platform_data);
> -       kfree(pdev->resource);
> +       if (!cs)
> +               return;
> +       dev_set_drvdata(dev, NULL);
> +       kfree(cs->hw.ser);
> +       cs->hw.ser = NULL;
>  }

This solution assumes that the struct platform_device is moved out of
the struct ser_cardstate, doesn't it? In other words, this is something
to do on top of my (draft) patch. Otherwise we'd still be freeing memory
managed through reference counting.

Thanks,


Paul Bolle
