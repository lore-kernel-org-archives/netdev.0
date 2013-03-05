From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH 0/7] USB: don't recover device if suspend fails in system sleep
Date: Tue, 05 Mar 2013 08:03:46 +0100
Message-ID: <87fw0aqqel.fsf@nemi.mork.no>
References: <1362456103-24956-1-git-send-email-ming.lei@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Jiri Kosina <jkosina@suse.cz>,
	Alan Stern <stern@rowland.harvard.edu>,
	Oliver Neukum <oneukum@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-input@vger.kernel.org
To: Ming Lei <ming.lei@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:56261 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752467Ab3CEHF0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Mar 2013 02:05:26 -0500
In-Reply-To: <1362456103-24956-1-git-send-email-ming.lei@canonical.com> (Ming
	Lei's message of "Tue, 5 Mar 2013 12:01:36 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ming Lei <ming.lei@canonical.com> writes:

> Hi,
>
> This patch adds comments on interface driver suspend callback
> to emphasize that the failure return value is ignored by
> USB core in system sleep context, so do not try to recover
> device for this case, otherwise the URB traffic scheduled
> in recovery of failure path may cross system sleep, and may
> cause problems.

Well, an unexpected error did happen so problems are to be expected,
yes.

> Also fixes the USB serial, HID and several usbnet drivers
> which may recover device in suspend failure path of system sleep.

I believe all of these are wrong unless you have any real bug which is
fixed by this.

All these drivers suspend in multiple steps, where each step can
fail. If a later step fails then they revert any previously successful
step before returning the failure, thereby ensuring that the
device/driver state when suspend returns is consistently either
suspended or resumed.

The error recovery they do in suspend is not about preventing suspend a=
t
all.  It is about ensuring that that the driver and device is in a
consistent state, which is "resumed" if suspend fails.

Your patch set make the drivers return from suspend in some intermediat=
e
state, where the device and/or driver is neither suspended nor resumed.
This is wrong.  You still did not necessarily kill all URBs, but you
killed some of them.  What is resume() going to do then?

I am going to NAK the cdc_mbim and qmi_wwan pacthes unless you can
convince me that we need to add a "partly-suspended" state for the
system suspend error case.  In which case the patch will need to includ=
e
the corresponding resume fix for the "partly-suspended" state.


Bj=C3=B8rn
