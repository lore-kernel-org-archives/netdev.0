From: Arend van Spriel <arend@broadcom.com>
Subject: Re: [RESEND][PATCH] Bluetooth: Make request workqueue freezable
Date: Fri, 22 May 2015 09:41:32 +0200
Message-ID: <555EDDAC.6080504@broadcom.com>
References: <Pine.LNX.4.44L0.1505211112310.1397-100000@iolanthe.rowland.org> <555E767B.2040808@redhat.com> <555EDCA9.4030007@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alan Stern <stern@rowland.harvard.edu>,
	Marcel Holtmann <marcel@holtmann.org>,
	Takashi Iwai <tiwai@suse.de>, Oliver Neukum <oneukum@suse.com>,
	Ming Lei <ming.lei@canonical.com>,
	"David S. Miller" <davem@davemloft.net>,
	Laura Abbott <labbott@fedoraproject.org>,
	"Johan Hedberg" <johan.hedberg@gmail.com>,
	"Rafael J. Wysocki" <rafael.j.wysocki@intel.com>,
	"Gustavo F. Padovan" <gustavo@padovan.org>,
	"bluez mailin list (linux-bluetooth@vger.kernel.org)"
	<linux-bluetooth@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	USB list <linux-usb@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Laura Abbott <labbott@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <555EDCA9.4030007@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/22/15 09:37, Arend van Spriel wrote:
> On 05/22/15 02:21, Laura Abbott wrote:
>> On 05/21/2015 08:26 AM, Alan Stern wrote:
>>> On Thu, 21 May 2015, Marcel Holtmann wrote:
>>>
>>>> Hi Alan,
>>>>
>>>>>> Then avoiding the failed firmware is no solution, indeed.
>>>>>> If it's a new probe, it should be never executed during resume.
>>>>>
>>>>> Can you expand this comment? What's wrong with probing during resume?
>>>>>
>>>>> The USB stack does carry out probes during resume under certain
>>>>> circumstances. A driver lacking a reset_resume callback is one of
>>>>> those circumstances.
>>>>
>>>> in case the platform kills the power to the USB lines, we can never
>>>> do anything about this. I do not want to hack around this in the
>>>> driver.
>>>>
>>>> What are the cases where we should implement reset_resume and would
>>>> it really help here. Since the btusb.ko driver implements
>>>> suspend/resume support, would reset_resume ever be called?
>>>
>>> One of those cases is exactly what you have been talking about: when
>>> the platform kills power to the USB lines during suspend. The driver's
>>> reset_resume routine will be called during resume, as opposed to the
>>> probe routine being called. Therefore the driver will be able to tell
>>> that this is not a new device instance.
>>>
>>> The other cases are less likely to occur: a device is unable to resume
>>> normally and requires a reset before it will start working again, or
>>> something else goes wrong along those lines.
>>>
>>>> However I get the feeling someone needs to go back and see if the
>>>> device is the same one and just gets probed again or if it is a new
>>>> one from the USB host stack perspective.
>>>
>>> That can be done easily enough by enabling usbcore debugging before
>>> carrying out the system suspend:
>>>
>>> echo 'module usbcore =p' >/debug/dynamic_debug/control
>>>
>>> The debugging information in the kernel log will tell just what
>>> happened.
>>>
>>>
>>
>> Playing around in my test setup as a baseline
>>
>> [ 41.991035] usb usb1-port11: not reset yet, waiting 50ms
>> [ 42.092902] usb 1-11: reset full-speed USB device number 4 using
>> xhci_hcd
>> [ 42.143575] usb usb1-port11: not reset yet, waiting 50ms
>> [ 42.257822] btusb 1-11:1.0: no reset_resume for driver btusb?
>> [ 42.257823] btusb 1-11:1.1: no reset_resume for driver btusb?
>> [ 42.257825] btusb 1-11:1.0: forced unbind
>> [ 42.258305] kworker/dying (826) used greatest stack depth: 10680 bytes
>> left
>> [ 42.331342] usb 1-9.2: reset full-speed USB device number 7 using
>> xhci_hcd
>> [ 42.416631] usb 1-9.2: ep0 maxpacket = 8
>> [ 42.681288] usb 1-9.1: reset low-speed USB device number 5 using
>> xhci_hcd
>> [ 42.968138] usb 1-9.1: ep 0x81 - rounding interval to 64 microframes,
>> ep desc says 80 microframes
>> [ 42.968157] usb 1-9.1: ep 0x82 - rounding interval to 64 microframes,
>> ep desc says 80 microframes
>> [ 43.036290] usb 1-9.4: reset high-speed USB device number 8 using
>> xhci_hcd
>> [ 43.123126] hub 1-9.4:1.0: hub_reset_resume
>> [ 43.123581] hub 1-9.4:1.0: enabling power on all ports
>> [ 43.224853] PM: resume of devices complete after 2456.587 msecs
>> [ 43.225038] btusb 1-11:1.0: usb_probe_interface
>> [ 43.225040] btusb 1-11:1.0: usb_probe_interface - got id
>> [ 43.225802] ------------[ cut here ]------------
>> [ 43.225807] WARNING: CPU: 7 PID: 2844 at
>> drivers/base/firmware_class.c:1118 _request_firmware+0x5ee/0x890()
>>
>>
>> so it is trying to call the reset resume. If I try a 'dummy reset resume'
>>
>> diff --git a/drivers/bluetooth/btusb.c b/drivers/bluetooth/btusb.c
>> index a7bdac0..cda8137 100644
>> --- a/drivers/bluetooth/btusb.c
>> +++ b/drivers/bluetooth/btusb.c
>> @@ -3401,6 +3401,7 @@ static struct usb_driver btusb_driver = {
>> #ifdef CONFIG_PM
>> .suspend = btusb_suspend,
>> .resume = btusb_resume,
>> + .reset_resume = btusb_resume,
>> #endif
>> .id_table = btusb_table,
>> .supports_autosuspend = 1,
>>
>>
>> I no longer see the warning which means that probe is no longer being
>> called.
>>
>> Marcel, does implementing a proper reset_resume callback seem like the
>> right
>> approach or do you need more information?
>
> Hi, Laura
>
> I believe that some devices supported by btusb would need to do a
> request_firmware() in the reset_resume() callback and thus end up with
> the same issue. btusb could store the firmware obtained during the probe
> in it driver private structure and use that in reset_resume() callback,
> but it means the memory for the firmware blobs will not be released
> until the driver is unloaded.

Same is true if caching is done in firmware_loader so it may not be a 
big deal.

Regards,
Arend

> Regards,
> Arend
>
>> Thanks,
>> Laura
>> --
>> To unsubscribe from this list: send the line "unsubscribe
>> linux-bluetooth" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at http://vger.kernel.org/majordomo-info.html
>
> --
> To unsubscribe from this list: send the line "unsubscribe
> linux-bluetooth" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at http://vger.kernel.org/majordomo-info.html
