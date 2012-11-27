From: Steve Glendinning <steve@shawell.net>
Subject: Re: smsc95xx: detect chip revision specific features
Date: Tue, 27 Nov 2012 12:32:26 +0000
Message-ID: <CAKh2mn4x=0HwUdH8hSbk3fsa16RUBqze_n5XegVjRBsTnT08SA@mail.gmail.com>
References: <20121126204722.GA26463@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:64797 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752359Ab2K0Mc2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2012 07:32:28 -0500
Received: by mail-ee0-f46.google.com with SMTP id e53so5067213eek.19
        for <netdev@vger.kernel.org>; Tue, 27 Nov 2012 04:32:27 -0800 (PST)
In-Reply-To: <20121126204722.GA26463@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dan,

> drivers/net/usb/smsc95xx.c
>   1283          if (pdata->wolopts & (WAKE_BCAST | WAKE_MCAST | WAKE_ARP | WAKE_UCAST)) {
>   1284                  u32 *filter_mask = kzalloc(32, GFP_KERNEL);
>                                                    ^^
> We allocate 8 unsigned 32 bit values.  I think this is the mistake here
> actually.  It is a typo and should say:
>
>                         u32 *filter_mask = kzalloc(sizeof(u32) * 32, GFP_KERNEL);
>
> If 8 elements was the intent then that's nasty.

Good spot!  8 32-bit elements was the intent, but all the following
code is actually accessing it using what should be byte offsets.  So I
think this should read:

    u8 *filter_mask = kzalloc(32, GFP_KERNEL);

The rest of the code following makes sense then, up until:

>   1349                          ret = smsc95xx_write_reg_nopm(dev, WUFF, filter_mask[i]);

Which we'll need to change so it dereferences a u32 at that offset
instead of a u8, something like *((u32 *)&filter_mask[i])

If this looks good to you I'll prepare a patch?

Steve
