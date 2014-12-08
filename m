From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: wl1251: NVS firmware data
Date: Mon, 8 Dec 2014 19:50:17 +0100
Message-ID: <30072B9E-2495-4F90-AC91-9C0D7E08F44E@holtmann.org>
References: <201411271506.20457@pali> <201412081747.30965@pali> <E5F3BB54-6365-4856-A231-A5FEDAEA217F@holtmann.org> <201412081811.46943@pali>
Mime-Version: 1.0 (Mac OS X Mail 8.1 \(1993\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Ming Lei <ming.lei@canonical.com>, Pavel Machek <pavel@ucw.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	Grazvydas Ignotas <notasas@gmail.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
	Aaro Koskinen <aaro.koskinen@iki.fi>,
	Kalle Valo <kvalo@adurom.com>,
	Sebastian Reichel <sre@ring0.de>,
	David Gnedt <david.gnedt@davizone.at>
To: =?utf-8?Q?Pali_Roh=C3=A1r?= <pali.rohar@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201412081811.46943@pali>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Pali,

>>>>>> On Saturday 06 December 2014 13:49:54 Pavel Machek wrote:
>>>>>> /**
>>>>>> 
>>>>>> + * request_firmware_prefer_user: - prefer usermode
>>>>>> helper for loading firmware + * @firmware_p: pointer to
>>>>>> firmware image
>>>>>> + * @name: name of firmware file
>>>>>> + * @device: device for which firmware is being loaded
>>>>>> + *
>>>>>> + * This function works pretty much like
>>>>>> request_firmware(), but it prefer + * usermode helper. If
>>>>>> usermode helper fails then it fallback to direct access.
>>>>>> + * Usefull for dynamic or model specific firmware data.
>>>>>> + **/
>>>>>> +int request_firmware_prefer_user(const struct firmware
>>>>>> **firmware_p, +                           const char
>>>>>> *name, struct device *device) +{
>>>>>> +       int ret;
>>>>>> +       __module_get(THIS_MODULE);
>>>>>> +       ret = _request_firmware(firmware_p, name, device,
>>>>>> +                               FW_OPT_UEVENT |
>>>>>> FW_OPT_PREFER_USER); +       module_put(THIS_MODULE);
>>>>>> +       return ret;
>>>>>> +}
>>>>>> +EXPORT_SYMBOL_GPL(request_firmware_prefer_user);
>>>>> 
>>>>> I'd like to introduce request_firmware_user() which only
>>>>> requests firmware from user space, and this way is simpler
>>>>> and more flexible since we have request_firmware_direct()
>>>>> already.
>>>> 
>>>> Why would a driver care about what program provides the
>>>> firmware?  It shouldn't at all, and we want to get rid of
>>>> the userspace firmware loader, not encourage drivers to
>>>> use it "exclusively" at all.
>>> 
>>> Do not remove it! Without userspace firmware loader it is
>>> impossible to load dynamic firmware files.
>> 
>> why is this dynamic in the first place. It does not sound like
>> dynamic data to me at all. This is like the WiFi MAC
>> address(es) or Bluetooth BD_ADDR. They are all static
>> information. The only difference is that they are on the host
>> accessibly filesystem or storage and not on the device
>> itself.
>> 
>> To be honest, for Bluetooth we solved this now. If the device
>> is missing key information like the calibration data or
>> BD_ADDR, then it comes up unconfigured. A userspace process
>> can then go and load the right data into it and then the
>> device becomes available as Bluetooth device.
>> 
>> Trying to use request_firmware to load some random data and
>> insist on going through userspace helper for that sounds
>> crazy to me. Especially since we are trying hard to get away
>> from the userspace loader. Forcing to keep it for new stuff
>> sounds backwards to me.
>> 
>> With the special Nokia partition in mind, why hasn't this been
>> turned into a mountable filesystem or into a driver/subsystem
>> that can access the data direct from the kernel. I advocated
>> for this some time ago. Maybe there should be a special
>> subsystem for access to these factory persistent information
>> that drivers then just can access. I seem to remember that
>> some systems provide these via ACPI. Why does the ARM
>> platform has to be special here?
>> 
>> And the problem of getting Ethernet and WiFi MAC address and
>> Bluetooth BD_ADDR comes up many many times. Why not have
>> something generic here. And don't tell me request_firmware is
>> that generic solution ;)
>> 
>> Regards
>> 
>> Marcel
> 
> Hi Marcel. I think you did not understand this problem. This 
> discussion is not about mac address. Please read email thread 
> again and if there are some unclear pars, then ask. Thanks!

I think that I pretty clearly understand the problem. Calibration data, MAC address, what is the difference? For me this is all the same. It is data that is specific to a device or type of devices and it is stored somewhere else. In most cases in some immutable memory/flash area.

What you want is access to this data since the kernel driver needs it. Do I get this so far ;)

So my take is that request_firmware is not the right way to get this data. Or more precisely make sure that this data is available to kernel drivers. And what I am seeing here is that instead of actually solving the bigger problem, we just hack around it with request_firmware. Now surprisingly the request_firmware loads files directly from the kernel and all the hacks do not work anymore.

Regards

Marcel
