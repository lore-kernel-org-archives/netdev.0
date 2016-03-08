From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] cdc_ncm: do not call usbnet_link_change from cdc_ncm_bind
Date: Tue, 8 Mar 2016 11:43:26 -0800
Message-ID: <CA+55aFxt7zWW+-EkwCbAWCb9wkgVswYJNAz86bc_QRcv1pBHZw@mail.gmail.com>
References: <CA+55aFw43uKkUK-h=VMwXcb9NM+g2AdeB960kWb4YihmjQ8DRw@mail.gmail.com>
	<20160307.141100.1511700720120062677.davem@davemloft.net>
	<CA+fCnZdurxGBsOrANb_m5BLK1BKzH3J_GmZ=dbH=ABThgFNGxg@mail.gmail.com>
	<20160307.145406.188091362181073486.davem@davemloft.net>
	<87k2le815w.fsf_-_@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Andrey Konovalov <andreyknvl@gmail.com>,
	Oliver Neukum <oneukum@suse.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Alexander Potapenko <glider@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	USB list <linux-usb@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: =?UTF-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f182.google.com ([209.85.223.182]:36416 "EHLO
	mail-io0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750782AbcCHTn1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2016 14:43:27 -0500
In-Reply-To: <87k2le815w.fsf_-_@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 7, 2016 at 12:15 PM, Bj=C3=B8rn Mork <bjorn@mork.no> wrote:
> usbnet_link_change will call schedule_work and should be
> avoided if bind is failing. Otherwise we will end up with
> scheduled work referring to a netdev which has gone away.
>
> Instead of making the call conditional, we can just defer
> it to usbnet_probe, using the driver_info flag made for
> this purpose.

So looking at this, I wonder...

Why is that FLAG_LINK_INTR thing not just always used?

The _only_ thing that FLAG_LINK_INTR does is to cause

        usbnet_link_change(dev, 0, 0);

to be called after network device attach. That doesn't seem to be contr=
oversial.

Looking at some examples, we have ax88179_178a.c that doesn't set the
flag, but instead does that usbnet_link_change() call at the end of
ax88179_bind().

There are a few drivers that seem to never call that
usbnet_link_change() at all, and don't have that FLAG_LINK_INTR flag.
Would they break?

Stupid grep:

    git grep -lw FLAG_ETHER |
        xargs grep -L FLAG_LINK_INTR |
        xargs grep -L usbnet_link_change |
        sed 's:drivers/net/usb/::'

gives

    cdc_eem.c
    ch9200.c
    cx82310_eth.c
    int51x1.c
    rndis_host.c

so maybe that FLAG_LINK_INTR si required.

Why is it called "FLAG_LINK_INTR" anyway? There doesn't seem to be
anything "INTR" about it.

               Linus
