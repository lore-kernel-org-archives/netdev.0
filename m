From: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Subject: Re: [RESEND][PATCH] Bluetooth: Make request workqueue freezable
Date: Fri, 22 May 2015 05:13:37 +0200
Message-ID: <DF182762-5B64-4B76-8D3E-AF3728102881@holtmann.org>
References: <Pine.LNX.4.44L0.1505211112310.1397-100000@iolanthe.rowland.org> <555E767B.2040808@redhat.com>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2098\))
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8BIT
Cc: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>,
	Takashi Iwai <tiwai-l3A5Bk7waGM@public.gmane.org>, Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>,
	Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Laura Abbott <labbott-rxtnV0ftBwyoClj4AeEUq9i2O/JbrIOy@public.gmane.org>,
	Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Rafael J. Wysocki" <rafael.j.wysocki-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"Gustavo F. Padovan" <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>,
	"bluez mailin list (linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org)"
	<linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	USB list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Laura Abbott <labbott-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <555E767B.2040808-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Laura,

>>>>> Then avoiding the failed firmware is no solution, indeed.
>>>>> If it's a new probe, it should be never executed during resume.
>>>> 
>>>> Can you expand this comment?  What's wrong with probing during resume?
>>>> 
>>>> The USB stack does carry out probes during resume under certain
>>>> circumstances.  A driver lacking a reset_resume callback is one of
>>>> those circumstances.
>>> 
>>> in case the platform kills the power to the USB lines, we can never
>>> do anything about this. I do not want to hack around this in the
>>> driver.
>>> 
>>> What are the cases where we should implement reset_resume and would
>>> it really help here. Since the btusb.ko driver implements
>>> suspend/resume support, would reset_resume ever be called?
>> 
>> One of those cases is exactly what you have been talking about: when
>> the platform kills power to the USB lines during suspend.  The driver's
>> reset_resume routine will be called during resume, as opposed to the
>> probe routine being called.  Therefore the driver will be able to tell
>> that this is not a new device instance.
>> 
>> The other cases are less likely to occur: a device is unable to resume
>> normally and requires a reset before it will start working again, or
>> something else goes wrong along those lines.
>> 
>>> However I get the feeling someone needs to go back and see if the
>>> device is the same one and just gets probed again or if it is a new
>>> one from the USB host stack perspective.
>> 
>> That can be done easily enough by enabling usbcore debugging before
>> carrying out the system suspend:
>> 
>> 	echo 'module usbcore =p' >/debug/dynamic_debug/control
>> 
>> The debugging information in the kernel log will tell just what
>> happened.
>> 
>> 
> 
> Playing around in my test setup as a baseline
> 
> [   41.991035] usb usb1-port11: not reset yet, waiting 50ms
> [   42.092902] usb 1-11: reset full-speed USB device number 4 using xhci_hcd
> [   42.143575] usb usb1-port11: not reset yet, waiting 50ms
> [   42.257822] btusb 1-11:1.0: no reset_resume for driver btusb?
> [   42.257823] btusb 1-11:1.1: no reset_resume for driver btusb?
> [   42.257825] btusb 1-11:1.0: forced unbind
> [   42.258305] kworker/dying (826) used greatest stack depth: 10680 bytes left
> [   42.331342] usb 1-9.2: reset full-speed USB device number 7 using xhci_hcd
> [   42.416631] usb 1-9.2: ep0 maxpacket = 8
> [   42.681288] usb 1-9.1: reset low-speed USB device number 5 using xhci_hcd
> [   42.968138] usb 1-9.1: ep 0x81 - rounding interval to 64 microframes, ep desc says 80 microframes
> [   42.968157] usb 1-9.1: ep 0x82 - rounding interval to 64 microframes, ep desc says 80 microframes
> [   43.036290] usb 1-9.4: reset high-speed USB device number 8 using xhci_hcd
> [   43.123126] hub 1-9.4:1.0: hub_reset_resume
> [   43.123581] hub 1-9.4:1.0: enabling power on all ports
> [   43.224853] PM: resume of devices complete after 2456.587 msecs
> [   43.225038] btusb 1-11:1.0: usb_probe_interface
> [   43.225040] btusb 1-11:1.0: usb_probe_interface - got id
> [   43.225802] ------------[ cut here ]------------
> [   43.225807] WARNING: CPU: 7 PID: 2844 at drivers/base/firmware_class.c:1118 _request_firmware+0x5ee/0x890()
> 
> 
> so it is trying to call the reset resume. If I try a 'dummy reset resume'
> 
> diff --git a/drivers/bluetooth/btusb.c b/drivers/bluetooth/btusb.c
> index a7bdac0..cda8137 100644
> --- a/drivers/bluetooth/btusb.c
> +++ b/drivers/bluetooth/btusb.c
> @@ -3401,6 +3401,7 @@ static struct usb_driver btusb_driver = {
> #ifdef CONFIG_PM
>        .suspend        = btusb_suspend,
>        .resume         = btusb_resume,
> +       .reset_resume   = btusb_resume,
> #endif
>        .id_table       = btusb_table,
>        .supports_autosuspend = 1,
> 
> 
> I no longer see the warning which means that probe is no longer being called.
> 
> Marcel, does implementing a proper reset_resume callback seem like the right
> approach or do you need more information?

I wonder what is the right work that needs to be done in the reset_resume callback. I am curious if devices are forgetting their firmware or not. There is a patch to make the Realtek devices forcefully reset_resume since they forget their firmware. So there is at least one kind of devices where the firmware does not survive normal suspend/resume behaviour.

If the devices forget the firmware, then this means that we actually need to tell the Bluetooth core that this device has been reset and it has to run through hdev->setup() again. If it does that, then we have the same problem that the firmware will not be found since userspace is not yet ready. However we could note the fact that we tried to lookup the firmware and just know that it was not found. So that might help already.

Devices that always require the firmware, we can assume that the firmware will have been cached since we successfully loaded it in the first place. Which will most likely make the Realtek devices function just fine. It has the advantage that we do not have to go through the disconnect() and probe() cycle which will in turn unregister and re-register the HCI device.

The question really is what a btusb_reset_resume() function should be doing. We have to assume that the device lost all its state and a reset of the Bluetooth stack is needed. The question if firmware is persistent or not might be a per device quirk that we have to deal with later.

This means we need to do at least the following transactions in reset_resume case:

	Clear all suspend flags and flush all data
	Start the interrupt URB if it was running before
	Start the bulk URBs if they were running before
	Call hci_reset_dev

Now the problem with hci_reset_dev at the moment is that it just injects a hardware error event. And based on that we restart the Bluetooth stack for that device. This needs extra work to restart the stack without needing to inject an event. The injection of the event will still be needed in case of HCI user channel operation, but that is yet another story.

Do we have an easy way to simulate this behaviour and trigger this specific case? We really need to know for which devices the firmware stays around.

Regards

Marcel
