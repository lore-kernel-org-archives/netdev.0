From: "Dr. H. Nikolaus Schaller" <hns@goldelico.com>
Subject: Re: [PATCH 1/1] hso: fix problem with wrong status code sent by OPTION GTM601 during RING indication
Date: Thu, 19 Dec 2013 08:48:30 +0100
Message-ID: <874B65AE-8B15-4427-8EF4-F0CA2BC55062@goldelico.com>
References: <B1808224-5850-41E3-9A8F-0F350F84FF89@goldelico.com> <541AADAC-7D20-4410-90FC-3E354B0C1457@goldelico.com> <1387222829.2156.51.camel@dcbw.foobar.com> <174CD81C-6425-4560-A3FA-3BFAA83BA770@goldelico.com> <1387319242.28943.42.camel@dcbw.local> <54ED5542-6C9E-4AC6-90CC-ED77972D8CB1@goldelico.com> <1387388963.5549.11.camel@dcbw.local>
Mime-Version: 1.0 (Apple Message framework v1085)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Jan Dumon <j.dumon@option.com>, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Belisko Marek <marek.belisko@gmail.com>, e.verdonck@option.com
To: Dan Williams <dcbw@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1387388963.5549.11.camel@dcbw.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dan,

Am 18.12.2013 um 18:49 schrieb Dan Williams:

> On Wed, 2013-12-18 at 14:16 +0100, Dr. H. Nikolaus Schaller wrote:
>> Hi Dan,
>> 
>> Am 17.12.2013 um 23:27 schrieb Dan Williams:
>> 
>>> On Tue, 2013-12-17 at 20:56 +0100, Dr. H. Nikolaus Schaller wrote:
>>>> Hi Dan,
>>>> 
>>>> Am 16.12.2013 um 20:40 schrieb Dan Williams:
>>>> 
>>>>> On Fri, 2013-12-13 at 15:43 +0100, Dr. H. Nikolaus Schaller wrote:
>>>>>> Hi,
>>>>>> 
>>>>>> Am 02.10.2013 um 09:00 schrieb Dr. H. Nikolaus Schaller:
>>>>>> 
>>>>>>> Hi Jan,
>>>>>>> 
>>>>>>> we are using a GTM601 modem (Firmware 1.7) for a while and have spotted an
>>>>>>> issue that under some conditions the modem sends a packed wIndex over USB
>>>>>>> that is rejected by the hso driver making troubles afterwards. Not rejecting makes
>>>>>>> it work fine.
>>>>>>> 
>>>>>>> BR,
>>>>>>> Nikolaus Schaller
>>>>>>> 
>>>>>>> ---
>>>>>>> 
>>>>>>> From f5c7e15b61f2ce4fe3105ff914f6bfaf5d74af0d Mon Sep 17 00:00:00 2001
>>>>>>> From: "H. Nikolaus Schaller" <hns@goldelico.com>
>>>>>>> Date: Thu, 15 Nov 2012 14:40:57 +0100
>>>>>>> Subject: [PATCH 1/1] hso: fix problem with wrong status code sent by OPTION
>>>>>>> GTM601 during RING indication
>>>>>>> 
>>>>>>> It has been observed that the GTM601 with 1.7 firmware sometimes sends a value
>>>>>>> wIndex that has bit 0x04 set instead of being reset as the code expects. So we
>>>>>>> mask it for the error check.
>>>>>>> 
>>>>>>> See http://lists.goldelico.com/pipermail/gta04-owner/2012-February/001643.html
>>>>>>> 
>>>>>>> Signed-off-by: NeilBrown <neilb@suse.de>
>>>>>>> Signed-off-by: H. Nikolaus Schaller <hns@goldelico.de>
>>>>>>> ---
>>>>>>> drivers/net/usb/hso.c |    3 ++-
>>>>>>> 1 files changed, 2 insertions(+), 1 deletions(-)
>>>>>>> 
>>>>>>> diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
>>>>>>> index cba1d46..d146e26 100644
>>>>>>> --- a/drivers/net/usb/hso.c
>>>>>>> +++ b/drivers/net/usb/hso.c
>>>>>>> @@ -1503,7 +1503,8 @@ static void tiocmget_intr_callback(struct urb *urb)
>>>>>>> 	if (serial_state_notification->bmRequestType != BM_REQUEST_TYPE ||
>>>>>>> 	    serial_state_notification->bNotification != B_NOTIFICATION ||
>>>>>>> 	    le16_to_cpu(serial_state_notification->wValue) != W_VALUE ||
>>>>>>> -	    le16_to_cpu(serial_state_notification->wIndex) != W_INDEX ||
>>>>>>> +	    (le16_to_cpu(serial_state_notification->wIndex) & ~0x4) !=
>>>>>>> +		W_INDEX ||
>>>>>>> 	    le16_to_cpu(serial_state_notification->wLength) != W_LENGTH) {
>>>>>>> 		dev_warn(&usb->dev,
>>>>>>> 			 "hso received invalid serial state notification\n");
>>>>>>> -- 
>>>>>>> 1.7.7.4
>>>>>>> 
>>>>>>> 
>>>>>> 
>>>>>> I have found this (better) proposal by OPTION, but wonder what did happen to it.
>>>>>> It neither shows in mainline 3.13-rc nor linux-next:
>>>>>> 
>>>>>> https://lkml.org/lkml/2013/10/9/263
>>>>> 
>>>>> Likely because nobody formally submitted the patch with a signed-off-by,
>>>>> which indicates their intent that the patch is tested, correct, and can
>>>>> be merged to the kernel.
>>>> 
>>>> Ok, I see. I just wasn't aware of the proposal at all since I missed the discussion
>>>> and wasn't on CC.
>>>> 
>>>> Therefore I have added Eric to the CC.
>>>> 
>>>>> 
>>>>> I looked at this today, and I'm left wondering how any port other than
>>>>> HSO_PORT_MODEM can get the notification via tiocmget_intr_callback().
>>>>> "serial->tiocmget" is only created for HSO_PORT_MODEM serial ports (see
>>>>> hso_create_bulk_serial_device()):
>>>>> 
>>>>> 	if ((port & HSO_PORT_MASK) == HSO_PORT_MODEM) {
>>>>> 		num_urbs = 2;
>>>>> 		serial->tiocmget = kzalloc(sizeof(struct hso_tiocmget),
>>>>> 					   GFP_KERNEL);
>>>>> 
>>>>> and the code in tiocmget_intr_callback() does this:
>>>>> 
>>>>> 	tiocmget = serial->tiocmget;
>>>>> 	if (!tiocmget)
>>>>> 		return;
>>>>> 
>>>>> which should mean that only a HSO_PORT_MODEM will ever process the
>>>>> notification.  Further, the tiocmget interrupt URB is only created and
>>>>> submitted if serial->tiocmget != NULL, so only HSO_PORT_MODEM should
>>>>> ever be calling into tiocmget_intr_callback().
>>>> 
>>>> Ok, that looks plausible.
>>>> 
>>>>> 
>>>>> So I think Eric's patch is actually wrong because it will *always* pass
>>>>> the new check.
>>>>> 
>>>>> The original code had the correct intention, but the original code was
>>>>> obviously wrong for newer devices where the port layout is read from
>>>>> firmware and not from static tables, and thus for recent devices where
>>>>> the modem interface is not USB interface #2.
>>>> 
>>>> This explains why we did run into the problem with the GTM601.
>>>> 
>>>>> 
>>>>> Can you confirm/deny that the 'modem' interface for your GTM601 is USB
>>>>> interface #6?  For example, my Icon 452 has the following USB interface
>>>>> layout:
>>>>> 
>>>>> 0: Diag
>>>>> 1: GPS
>>>>> 2: GPS control
>>>>> 3: Application
>>>>> 4: Control
>>>>> 5: Network
>>>>> 6: Modem
>>>>> 
>>>>> So like the GTM601, I would expect any RING notifications to appear for
>>>>> wIndex=0x06.
>>>> 
>>>> Interestingly I see:
>>>> 
>>>> 0: Diagnostic
>>>> 1: GPS
>>>> 2: GPS Control
>>>> 3: Application
>>>> 4: Control
>>>> 5: Modem
>>>> 
>>>> I.e. there is no Network interface. Originally we did focus on /dev/ttyHS3
>>> 
>>> How are you determining the number here?  Are you using:
>>> 
>>> cat /sys/class/tty/ttyHS_Modem/device/bInterfaceNumber
>>> 
>>> to determine the actual USB interface number associated with the Modem
>>> port?  Or are you going off the pre-udev-rename ttyHSx numbers?
>> 
>> Ah, I did use
>> 
>> root@gta04:~#  ls -d /sys/class/tty/ttyHS*; cat /sys/class/tty/ttyHS*/hsotype
>> /sys/class/tty/ttyHS0  /sys/class/tty/ttyHS1  /sys/class/tty/ttyHS2  /sys/class/tty/ttyHS3  /sys/class/tty/ttyHS4  /sys/class/tty/ttyHS5
>> Diagnostic
>> GPS
>> GPS Control
>> Application
>> Control
>> Modem
>> 
>> With bInterfaceNumber I get
>> 
>> root@gta04:~# cat /sys/class/tty/ttyHS*/device/bInterfaceNumber
>> 00
>> 01
>> 02
>> 03
>> 04
>> 06
>> 
>> So the Modem is indeed interface 06 and there is just no ttyHS_Network.
> 
> Ah, excellent.
> 
> I assume you use the "disable_net" module parameter for hso.ko to
> disable the net device?  You likely don't want to do that :)

Hm. Not that I am aware of. The driver loads automatically at boot time
and we use the AT_O commands to set up networking. Maybe it is simply
hidden because I see it in the ifconfig as hso0.

>  If you
> disable the net device and rely on PPP, you're severely limiting the
> throughput as PPP overhead does not allow reaching HSPA data rates.  The
> GTM601 can only do HSPA 14.4 though, so it's not a huge problem, but if
> you ever want to use a faster module (HSPA+ 21 or 42 or LTE) you
> definitely want to ditch PPP.
> 
> (PPP is only used between the modem and the host; it's not used over the
> air... so it's just overhead and another point of failure.  The
> netdevice and the custom Option AT commands for IP details are simpler
> and faster.)
> 
>>> 
>>>> to access the Application interface, but people reported that it is not stable
>>>> or always so. Therefore we have some udev rule to add symbolic names
>>>> (e.g. /dev/ttyHS_Application):
>>>> 
>>>> http://git.goldelico.com/?p=gta04-kernel.git;a=blob;f=GTA04/udev-rules/hso.rules;hb=HEAD
>>>> 
>>>> So I think the assignment is not even always the same on the same device.
>>> 
>>> The assignment will always be the same on the same device *and the same
>>> firmware*.  That is because the hso driver asks the firmware for the
>>> port layout, and that is what is put into the 'hsotype' file in sysfs
>>> that the udev rules use.  So if your telephony/WWAN stack is using the
>>> udev symbolic links or reading 'hsotype' directly, you can be assured
>>> that ttyHS_Modem is always the port you should be using for PPP.
>>> 
>>>> And I am a little puzzled why we do see the wIndex == 6 if it is the interface
>>>> number. Maybe it happens only in some scenario where the Modem becomes
>>>> interface #6.
>>> 
>>> I'm still not convinced that that it isn't #6 until we agree on how
>>> we're figuring that out :)  I may well assume to little of you, so
>>> forgive me if you are actually reporting the real USB interface # of the
>>> ports.  But I've seen too many people confuse the tty numbers with USB
>>> interface numbers, so I must ask.
>> 
>> Yes, I did the mistake as you describe...
>> 
>>> 
>>>>> 
>>>>> Does the following patch fix the problem for you?
>>>> 
>>>> I will try but need a little time to setup a test scenario (because I need to trigger
>>>> RING indications) and will then report.
>>> 
>>> Here's a RING on the 452 with Modem @ usbif #6:
>>> 
>>> [65808.711323] tiocmget_intr_callback: W_INDEX 0006
>>> [65808.711330] tiocmget_intr_callback: UART bits 000a
>>> [65808.711333] tiocmget_intr_callback: Modem ifnum 06
>>> 
>>> and B_TX_CARRIER notification with GIO322 with Modem @ usbif #2:
>>> 
>>> [66029.365441] tiocmget_intr_callback: W_INDEX 0002
>>> [66029.365444] tiocmget_intr_callback: UART bits 0002
>>> [66029.365445] tiocmget_intr_callback: Modem ifnum 02
>> 
>> Hm. I didn't see these messages (on 3.12). How do I enable them?
> 
> I added them to the driver manually so I could ensure that the fix I
> posted was working.  I noticed similar messages in the logs you
> originally posted debugging the problem, so I assumed you had some
> custom logging of your own.

Ah, I see. I did have it but not in the most current code. So I have added
a little printk().

Now I have firstly removed my patch and then added yours and I can confirm that it works fine:

w/o patch:

[  143.964111] tiocmget_intr_callback: serial de61b800
[  143.969207] tiocmget_intr_callback: status 00000000
[  143.974334] tiocmget_intr_callback: tiocmget dddd5d40
[  143.979614] tiocmget_intr_callback: serial_state_notification dddd5d60
[  143.986419] tiocmget_intr_callback: wValue 0000
[  143.991149] tiocmget_intr_callback: wValue 06
[  143.995727] tiocmget_intr_callback: wValue 0002
[  144.000457] usb 1-2: hso received invalid serial state notification
[  144.007019] hso[1522:tiocmget_intr_callback]a1 20 00 00 06 00 02 00 0b 00

with patch:

[  192.589172] tiocmget_intr_callback: serial de69da00
[  192.594299] tiocmget_intr_callback: status 00000000
[  192.599395] tiocmget_intr_callback: tiocmget de5b4540
[  192.604675] tiocmget_intr_callback: serial_state_notification de5b4560
[  192.611511] tiocmget_intr_callback: wValue 0000
[  192.616241] tiocmget_intr_callback: wValue 06
[  192.620788] tiocmget_intr_callback: wValue 0002

> 
>> BTW: the RING (or +CRING:) text messages do appear on the Application port,
>> while the NO CARRIER after ATA and ending the call appears on
>> the Modem port.
> 
> Ah fun.  Which would explain why I never saw the RING message myself,
> since I was using the Modem port for AT communication and calling the
> SIM from another phone.

And I have found that the tiocmget_intr_callback is only active if I open the Modem port.
If I use the Application port, I don't see any tiocmget_intr_callback messages
(but the RING text message ).

> 
> If you can can test this patch out and confirm/deny that it corrects the
> problem for you, then I'll post an official version of it.

So I can confirm for the GTM601:

Tested-by: H. Nikolaus Schaller <hns@goldelico.com>

BR,
Nikolaus
