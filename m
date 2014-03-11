From: Oliver Neukum <oliver@neukum.org>
Subject: Re: usbnet: driver_info->stop required to stop USB interrupts?
Date: Tue, 11 Mar 2014 10:10:19 +0100
Message-ID: <1394529019.16128.4.camel@linux-fkkt.site>
References: <CANEJEGsvqkT_H4i+UZpBaWMYmgXHmpD8SZ4tU1OHzLd8gyznow@mail.gmail.com>
	 <CANEJEGv03ohVwoS0Pd1Z3az9k-C=dTzG4qE1SBL6Um97QC1Ehw@mail.gmail.com>
	 <CAODwPW_t9COeg0LWfkiqXC_yTbSNhUHX-8T95KRZHfOTSiZK1Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Grant Grundler <grundler@google.com>,
	netdev <netdev@vger.kernel.org>, Freddy Xin <freddy@asix.com.tw>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	Allan Chou <allan@asix.com.tw>
To: Julius Werner <jwerner@chromium.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out003.kontent.com ([81.88.40.217]:35715 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750722AbaCKJKW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 05:10:22 -0400
In-Reply-To: <CAODwPW_t9COeg0LWfkiqXC_yTbSNhUHX-8T95KRZHfOTSiZK1Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-10 at 19:53 -0700, Julius Werner wrote:
> I think usbnet_stop() raced with the dev->bh tasklet, which by itself
> might not be a problem (usbnet_stop() later kills the tasklet itself,
> so it should expect that it can be running before that). The issue is
> that it calls usbnet_terminate_urbs() before that, which temporarily
> installs a waitqueue in dev->wait in order to be able to wait on the
> tasklet to run and finish up some queues. The waiting itself looks
> okay, but the access to 'dev->wait' is totally unprotected and can
> race arbitrarily. I think in this case usbnet_bh() managed to succeed
> it's dev->wait check just before usbnet_terminate_urbs() sets it back
> to NULL. The latter then finishes and the waitqueue_t structure on its
> stack gets overwritten by other functions halfway through the
> wake_up() call in usbnet_bh().
> 
> I think the best solution would be to just make dev->wait a directly
> embedded structure inside struct usbnet instead of a pointer to
> something stack-allocated. usbnet_bh() could just call wake_up()
> unconditionally (if empty it will be a noop), and then one other check
> for !dev->wait could be replaced with a call to waitqueue_active().
> Then the waitqueue-internal locks should be enough to protect all
> accesses.

The diagnosis seems spot on. The fix is not quite so simple.
dev->wait is abused as a flag in resume(). The easiest fix is just
to make sure resume() is never called while stopping.

	Regards
		Oliver
