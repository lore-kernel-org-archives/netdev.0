From: Oliver Neukum <oneukum@suse.com>
Subject: Re: [PATCH net 2/3] r8152: fix remote wakeup
Date: Thu, 23 Jul 2015 12:27:26 +0200
Message-ID: <1437647246.4377.33.camel@suse.com>
References: <1394712342-15778-148-Taiwan-albertk@realtek.com>
	 <1394712342-15778-150-Taiwan-albertk@realtek.com>
	 <1437640258.4377.6.camel@suse.com>
	 <0835B3720019904CB8F7AA43166CEEB2F3AC58@RTITMBSV03.realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: nic_swsd <nic_swsd@realtek.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <0835B3720019904CB8F7AA43166CEEB2F3AC58@RTITMBSV03.realtek.com.tw>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-07-23 at 09:55 +0000, Hayes Wang wrote:
> > Hi,
> > 
> > this is most likely wrong. Usbcore does check for a device's ability to
> > do remote wakeup and will block a runtime suspend if it detects that
> > a remote wakeup would be required but the device cannot deliver.
> > (static int autosuspend_check())
> > 
> > So by removing the flag in the probe() method means that devices will
> > suspend during operations without remote wakeup requested. Thus an
> > incoming packet cannot wake them up.
> > 
> > If you remove setting the flag on probe() you need to set it at open()
> > [and reset on close()], as devices which cannot do remote wakeup must
> > only be suspended when they are down.
> 
> Hi,
> 
> I don't think I understand your description clearly. My idea is that if the

Sorry, I will try to be clearer.

> device doesn't support wakeup, we don't need set " needs_remote_wakeup".

The algorithm for power saving needs remote wakeup.

> We allow the device could be suspended and couldn't be waked up by
> incoming packet. The system could be waked up by other methods except
> by the device.

The system is not the problem. I was talking about device level power
management at runtime.

> I don't understand why I have to set it at open() and reset it at close(). And
> why must the device only be suspended when it is down?

OK,

the driver right now requests that runtime power management be done:

static struct usb_driver rtl8152_driver = {
	.name =		MODULENAME,
	.id_table =	rtl8152_table,
	.probe =	rtl8152_probe,
	.disconnect =	rtl8152_disconnect,
	.suspend =	rtl8152_suspend,
	.resume =	rtl8152_resume,
	.reset_resume =	rtl8152_resume,
	.supports_autosuspend = 1,

	^ the crucial flag

	.disable_hub_initiated_lpm = 1,
};

It implements an advanced form of runtime power management which
requires remote wakeup.
For the device to work correctly it must not be suspended while

a - a setting is changed
b - a packet is transmitted
c - a packet is received

Cases a and b are covered by the driver on its own.
Case a see for example rtl8152_set_mac_address()
Case b is handled in rtl8152_start_xmit()

		if (test_bit(SELECTIVE_SUSPEND, &tp->flags)) {
			set_bit(SCHEDULE_NAPI, &tp->flags);
			schedule_delayed_work(&tp->schedule, 0);
		} else {
			usb_mark_last_busy(tp->udev);

The scheduled work will resume the device if necessary.

Case c is handled in rtl8152_resume()

	if (netif_running(tp->netdev)) {
		if (test_bit(SELECTIVE_SUSPEND, &tp->flags)) {
			rtl_runtime_suspend_enable(tp, false);
			clear_bit(SELECTIVE_SUSPEND, &tp->flags);
			set_bit(WORK_ENABLE, &tp->flags);
			if (netif_carrier_ok(tp->netdev))
				rtl_start_rx(tp);

But that code path only runs if remote wakeup is enabled.
So to operate with runtime power management is is necessary
that the device support remote wakeup and the driver enable it.

If the device does not support remote wakeup and the driver
enables it, runtime power management will be switched off.
That is the current state and it means that devices which
don't support remote wakeup cannot do runtime power management
at all. But the driver is correct.

The only time a device that doesn't support remote wakeup can
do runtime power managent is when no packets can be received
that is while the interface is down. If you want to allow that
you must not set needs_remote_wakeup in probe(), but you must
set it in open() because it is necessary for runtime power
management as I explained above.

Sorry for the length of this mail, but I wanted to make sure
I am absolutely clear this time.

	HTH
		Oliver
