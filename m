From: Julius Werner <jwerner@chromium.org>
Subject: Re: usbnet: driver_info->stop required to stop USB interrupts?
Date: Mon, 10 Mar 2014 19:53:36 -0700
Message-ID: <CAODwPW_t9COeg0LWfkiqXC_yTbSNhUHX-8T95KRZHfOTSiZK1Q@mail.gmail.com>
References: <CANEJEGsvqkT_H4i+UZpBaWMYmgXHmpD8SZ4tU1OHzLd8gyznow@mail.gmail.com>
	<CANEJEGv03ohVwoS0Pd1Z3az9k-C=dTzG4qE1SBL6Um97QC1Ehw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, Freddy Xin <freddy@asix.com.tw>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	Allan Chou <allan@asix.com.tw>
To: Grant Grundler <grundler@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f47.google.com ([209.85.219.47]:35709 "EHLO
	mail-oa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752801AbaCKCxg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 22:53:36 -0400
Received: by mail-oa0-f47.google.com with SMTP id i11so7972250oag.20
        for <netdev@vger.kernel.org>; Mon, 10 Mar 2014 19:53:36 -0700 (PDT)
In-Reply-To: <CANEJEGv03ohVwoS0Pd1Z3az9k-C=dTzG4qE1SBL6Um97QC1Ehw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I think usbnet_stop() raced with the dev->bh tasklet, which by itself
might not be a problem (usbnet_stop() later kills the tasklet itself,
so it should expect that it can be running before that). The issue is
that it calls usbnet_terminate_urbs() before that, which temporarily
installs a waitqueue in dev->wait in order to be able to wait on the
tasklet to run and finish up some queues. The waiting itself looks
okay, but the access to 'dev->wait' is totally unprotected and can
race arbitrarily. I think in this case usbnet_bh() managed to succeed
it's dev->wait check just before usbnet_terminate_urbs() sets it back
to NULL. The latter then finishes and the waitqueue_t structure on its
stack gets overwritten by other functions halfway through the
wake_up() call in usbnet_bh().

I think the best solution would be to just make dev->wait a directly
embedded structure inside struct usbnet instead of a pointer to
something stack-allocated. usbnet_bh() could just call wake_up()
unconditionally (if empty it will be a noop), and then one other check
for !dev->wait could be replaced with a call to waitqueue_active().
Then the waitqueue-internal locks should be enough to protect all
accesses.
