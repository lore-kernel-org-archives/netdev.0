From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [PATCH] usbnet: prevent device rpm suspend in usbnet_probe
 function
Date: Tue, 8 Nov 2016 13:44:07 -0500 (EST)
Message-ID: <Pine.LNX.4.44L0.1611081339060.1499-100000@iolanthe.rowland.org>
References: <87eg2lkjce.fsf@miraculix.mork.no>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: Kai-Heng Feng <kai.heng.feng@canonical.com>,
        Oliver Neukum <oneukum@suse.com>,
        <linux-kernel@vger.kernel.org>, <linux-usb@vger.kernel.org>,
        <netdev@vger.kernel.org>
To: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87eg2lkjce.fsf@miraculix.mork.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 8 Nov 2016, Bjørn Mork wrote:

> Alan Stern <stern@rowland.harvard.edu> writes:
> 
> > On Tue, 8 Nov 2016, Kai-Heng Feng wrote:
> >
> >> Hi,
> >> 
> >> On Mon, Nov 7, 2016 at 7:02 PM, Oliver Neukum <oneukum@suse.com> wrote:
> >> > On Fri, 2016-11-04 at 17:57 +0800, Kai-Heng Feng wrote:
> >> >> Sometimes cdc_mbim failed to probe if runtime pm is enabled:
> >> >> [    9.305626] cdc_mbim: probe of 2-2:1.12 failed with error -22
> >> >>
> >> >> This can be solved by increase its pm usage counter.
> >> >>
> >> >> Signed-off-by: Kai-Heng Feng <kai.heng.feng@canonical.com>
> >> >
> >> > For the record:
> >> >
> >> > NAK. This fixes a symptom. If this patch helps something is broken in
> >> > device core. We need to find that.
> >> >
> >> 
> >> Please check attached dmesg with usbcore.dyndbg="+p".
> >
> > The log shows that the device went into suspend _before_ the cdc_mbim 
> > driver was probed, not during the probe.  Then just before the probe 
> > was started, the USB core tried to resume the device and the resume 
> > failed.
> >
> > The log shows a bunch of other problems with this device:
> >
> > [    3.862253] usb 2-2: config 1 has an invalid interface number: 12 but max is 1
> > [    3.862254] usb 2-2: config 1 has an invalid interface number: 13 but max is 1
> > [    3.862254] usb 2-2: config 1 has an invalid interface number: 13 but max is 1
> > [    3.862255] usb 2-2: config 1 has no interface number 0
> > [    3.862256] usb 2-2: config 1 has no interface number 1
> 
> These messages are completely harmless and normal for Sierra Wireless
> devices.  They use the interface number to identify the type of
> function, causing this mismatch between the number of interfaces and the
> inteface numbers. Boy, that looks weird in writing :)
> 
> Ref this discussion we had a few years ago:
> http://www.spinics.net/lists/linux-usb/msg77499.html
> 
> No, I didn't expect you to remember that :)

You're right; I didn't remember it.  But seeing those messages again in
the mailing list archives, they do look a little familiar.

> > [    8.295180] usb 2-2: Disable of device-initiated U1 failed.
> > [    8.295322] usb 2-2: Disable of device-initiated U2 failed.
> >
> > I get the impression that the device won't work properly with runtime 
> > PM at all.
> 
> I suspect the device is an EM7455?  If so, then it does work fine with
> runtime PM, as long as we're talking USB2.  Not sure about USB3 runtime
> PM though.  Cannot test it. The Lenovo laptop I got with one of these
> modems has disabled the USB3 link on the m.2 modem slot for some reason.

These problems could very well be caused by running at SuperSpeed
(USB-3) instead of high speed (USB-2).

Is there any way to test what happens when the device is attached to 
the computer by a USB-2 cable?  That would prevent it from operating at 
SuperSpeed.

The main point, however, is that the proposed patch doesn't seem to
address the true problem, which is that the device gets suspended
between probes.  The patch only tries to prevent it from being
suspended during a probe -- which is already prevented by the USB core.

Alan Stern
