From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [patch] usbnet: fix 100% CPU use on suspended device
Date: Wed, 4 Aug 2010 16:08:51 +0200
Message-ID: <201008041608.51227.oneukum@suse.de>
References: <Pine.LNX.4.44L0.1007261106350.1550-100000@iolanthe.rowland.org> <201008031639.24874.oliver@neukum.org> <AANLkTim-6VhV7AD_QQh-5j5RqxEDDh1oyX4CqZWGb-ZH@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Alan Stern <stern@rowland.harvard.edu>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	USB list <linux-usb@vger.kernel.org>
To: Elly Jones <ellyjones@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:44294 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754067Ab0HDOJN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Aug 2010 10:09:13 -0400
In-Reply-To: <AANLkTim-6VhV7AD_QQh-5j5RqxEDDh1oyX4CqZWGb-ZH@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Mittwoch, 4. August 2010, 16:04:48 schrieben Sie:
> On Tue, Aug 3, 2010 at 10:39 AM, Oliver Neukum <oliver@neukum.org> wrote:
> > Am Montag, 2. August 2010, 15:31:33 schrieb Elly Jones:
> >> On Mon, Jul 26, 2010 at 12:21 PM, Oliver Neukum <oliver@neukum.org> wrote:
> >> > Am Montag, 26. Juli 2010, 17:13:23 schrieb Alan Stern:
> >> >> On Mon, 26 Jul 2010, Elly Jones wrote:
> >> >>
> >> >> > > This isn't right.  The problem should be fixed some other way.  Under
> >> >> > > what circumstances are URBs submitted incorrectly?
> >> >> >
> >> >> > When the device is autosuspended. What is the proper thing for a
> >> >> > device to do here?
> >> >>
> >> >> From looking at the code, it appears that the EVENT_DEV_ASLEEP flag
> >> >> should be tested in usbnet_bh() the way it is in rx_submit().  But I'm
> >> >> not an expert on usbnet; we should ask someone who is, like Oliver.
> >> >
> >> > Sorry, I didn't notice this thread.
> >> >
> >> > The correct way to check for autosuspend in usbnet is to look
> >> > at EVENT_DEV_ASLEEP under txq.lock. That being said, usbnet_bh()
> >> > uses rx_submit() which does the correct check. The bug seems to be
> >> > a lack of error handling in usbnet_bh() regarding the return of rx_submit()
> >>
> >> If rx_submit() fails, should usbnet_bh() just not tasklet_schedule() itself?
> >
> > That would not work unless the cause of the failure would be removed.
> > If you get -ENOLINK the sane option seems to me to give up.
> 
> 'Give up' meaning what? If we reschedule the tasklet, it'll just try
> again (and fail again), won't it?

Yes, exactly. If the tasklet runs after the interface has been suspended,
it cannot replenish the rx URBs. That will be the job of resume()
Just stop trying and do nothing.

	Regards
		Oliver
