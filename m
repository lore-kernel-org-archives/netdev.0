From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: wl1251: NVS firmware data
Date: Mon, 8 Dec 2014 20:41:13 +0100
Message-ID: <9E6DD65F-8AF4-49C6-85EE-AA2BB4C6C39D@holtmann.org>
References: <201411271506.20457@pali> <201412081811.46943@pali> <30072B9E-2495-4F90-AC91-9C0D7E08F44E@holtmann.org> <201412082015.18501@pali>
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
In-Reply-To: <201412082015.18501@pali>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Pali,

>>>>>>>> On Saturday 06 December 2014 13:49:54 Pavel Machek
>>>>>>>> wrote: /**
>>>>>>>> 
>>>>>>>> + * request_firmware_prefer_user: - prefer usermode
>>>>>>>> helper for loading firmware + * @firmware_p: pointer to
>>>>>>>> firmware image
>>>>>>>> + * @name: name of firmware file
>>>>>>>> + * @device: device for which firmware is being loaded
>>>>>>>> + *
>>>>>>>> + * This function works pretty much like
>>>>>>>> request_firmware(), but it prefer + * usermode helper.
>>>>>>>> If usermode helper fails then it fallback to direct
>>>>>>>> access. + * Usefull for dynamic or model specific
>>>>>>>> firmware data. + **/
>>>>>>>> +int request_firmware_prefer_user(const struct firmware
>>>>>>>> **firmware_p, +                           const char
>>>>>>>> *name, struct device *device) +{
>>>>>>>> +       int ret;
>>>>>>>> +       __module_get(THIS_MODULE);
>>>>>>>> +       ret = _request_firmware(firmware_p, name,
>>>>>>>> device, +                               FW_OPT_UEVENT
>>>>>>>> | FW_OPT_PREFER_USER); +      
>>>>>>>> module_put(THIS_MODULE); +       return ret;
>>>>>>>> +}
>>>>>>>> +EXPORT_SYMBOL_GPL(request_firmware_prefer_user);
>>>>>>> 
>>>>>>> I'd like to introduce request_firmware_user() which only
>>>>>>> requests firmware from user space, and this way is
>>>>>>> simpler and more flexible since we have
>>>>>>> request_firmware_direct() already.
>>>>>> 
>>>>>> Why would a driver care about what program provides the
>>>>>> firmware?  It shouldn't at all, and we want to get rid of
>>>>>> the userspace firmware loader, not encourage drivers to
>>>>>> use it "exclusively" at all.
>>>>> 
>>>>> Do not remove it! Without userspace firmware loader it is
>>>>> impossible to load dynamic firmware files.
>>>> 
>>>> why is this dynamic in the first place. It does not sound
>>>> like dynamic data to me at all. This is like the WiFi MAC
>>>> address(es) or Bluetooth BD_ADDR. They are all static
>>>> information. The only difference is that they are on the
>>>> host accessibly filesystem or storage and not on the
>>>> device itself.
>>>> 
>>>> To be honest, for Bluetooth we solved this now. If the
>>>> device is missing key information like the calibration
>>>> data or BD_ADDR, then it comes up unconfigured. A
>>>> userspace process can then go and load the right data into
>>>> it and then the device becomes available as Bluetooth
>>>> device.
>>>> 
>>>> Trying to use request_firmware to load some random data and
>>>> insist on going through userspace helper for that sounds
>>>> crazy to me. Especially since we are trying hard to get
>>>> away from the userspace loader. Forcing to keep it for new
>>>> stuff sounds backwards to me.
>>>> 
>>>> With the special Nokia partition in mind, why hasn't this
>>>> been turned into a mountable filesystem or into a
>>>> driver/subsystem that can access the data direct from the
>>>> kernel. I advocated for this some time ago. Maybe there
>>>> should be a special subsystem for access to these factory
>>>> persistent information that drivers then just can access.
>>>> I seem to remember that some systems provide these via
>>>> ACPI. Why does the ARM platform has to be special here?
>>>> 
>>>> And the problem of getting Ethernet and WiFi MAC address
>>>> and Bluetooth BD_ADDR comes up many many times. Why not
>>>> have something generic here. And don't tell me
>>>> request_firmware is that generic solution ;)
>>>> 
>>>> Regards
>>>> 
>>>> Marcel
>>> 
>>> Hi Marcel. I think you did not understand this problem. This
>>> discussion is not about mac address. Please read email
>>> thread again and if there are some unclear pars, then ask.
>>> Thanks!
>> 
>> I think that I pretty clearly understand the problem.
>> Calibration data, MAC address, what is the difference? For me
>> this is all the same. It is data that is specific to a device
>> or type of devices and it is stored somewhere else. In most
>> cases in some immutable memory/flash area.
>> 
> 
> Those calibration data (in form of binary NVS firmware file) 
> needs to be sent to wl1251 chip. Mac address is not needed at 
> this step (and kernel generate some random if is not provided).

the MAC address is just an example or similar data. And to be clear the kernel generating some random address is not a good idea either. If you get a new random address on every boot that is total disaster. Because it sort of works does not mean it is the right way to do it. That is why I am including MAC address in the list here. It is same kind of data that is needed before a device can be declared fully functional.

> (Just to note wl1271 driver loads both MAC address and NVS data 
> via one firmware file which is prepared by userspace, but this 
> discussion is about wl1251...)

There is no difference between any drivers here. I do not know why are you trying to tie this to a specific driver. Why does it matter what kind of information these are. The point is they are not static, they are device specific and come from different sources. And the kernel driver needs them.

>> What you want is access to this data since the kernel driver
>> needs it. Do I get this so far ;)
>> 
> 
> Yes, we need to provide NVS data to kernel when kernel ask for 
> them.
> 
>> So my take is that request_firmware is not the right way to
>> get this data. Or more precisely make sure that this data is
>> available to kernel drivers. And what I am seeing here is
>> that instead of actually solving the bigger problem, we just
>> hack around it with request_firmware. Now surprisingly the
>> request_firmware loads files directly from the kernel and all
>> the hacks do not work anymore.
>> 
>> Regards
>> 
>> Marcel
> 
> Just read emails again...
> 
> Our problem is:
> 
> linux-firmware.git tree provides two binary firmware files:
> 
> ti-connectivity/wl1251-fw.bin
> ti-connectivity/wl1251-nvs.bin
> 
> First is firmware file, second NVS file with generic calibration 
> data. Kernel driver wl1251 now loads both firmware files via 
> request_firmware. Generic calibration data are enough for wl1251 
> chip (it should work). But devices have own calibration data 
> stored somewhere else.

Loading generic data that is static and stored on the filesystem via request_firmware is totally fine. If you have the NVS data in that file, then great. If you have specific data, then overwrite the file, link it to the real file or do something with it. As long as it is a file on the filesystem, you will be just fine.

If you however want to hook into some magic userspace helper to build the content of the file and somehow load it, then that sounds like the wrong approach to me.

> On Nokia N900 NVS data are generated on-the-fly from some bytes 
> from CAL (/dev/mtd1), from state of cellular network and from 
> some other regulation settings.
> 
> So I think that files stored in linux-firmware.git tree (which 
> are also installed into /lib/firmware/) should be loaded with 
> request_firmware function. Or not? Do you think something else? 
> What other developers think?
> 
> I'm against kernel driver for CAL (/dev/mtd1) for more reasons:
> 
> 1) we have userspace open source code, but licensed under GPLv3. 
> And until kernel change license, we cannot include it.
> 
> 2) NVS data are (probably) not in one place, plus they depends on 
> something other.
> 
> 3) If manufacture XYZ create new device with its own storage 
> format of calibration data this means that correct solution for 
> XYZ is also to implement new kernel fs driver for its own format. 
> Do you really want to have in kernel all those drivers for all 
> different (proprietary) storage formats?
> 
> 4) It does not help us with existence of generic file 
> /lib/firmware/ti-connectivity/wl1251-nvs.bin which comes from 
> linux-firmware.git tree.

As I said before, I think that a driver should not register with its subsystem until it has all data that it needs. Or if it can tell the subsystem that it is missing data and the subsystem knows how to provide hooks for getting this data.

We all know that many embedded devices need extra data to operation properly. This data is normally programmed onto the device in the factory. So if someone would now build a subsystem that can retrieve magic blobs of data from magic places like ACPI, devicetree, userspace or whatever that would help. I can see that request_firmware looks a lot like this. However the reality is that you have a race condition here. request_firmware relies on the fact that it is file in userspace. That is what it was designed for in the first place. Firmware files that are place on the hosts filesystem. It does not have the option to start a notifier when blob xyz becomes available. And that is what you essentially need for the drivers. The driver finds the hardware and goes, now I need blob xyz to function 
 and then it sits and waits until it gets told that blob is now available. Then it initializes the hardware and registers it to the subsystem.

I fully realize that request_firmware is pretty close in this regard, but the semantics and timing that many of these NVS data like addresses, our calibration information are different. It is more than just this specific drivers problem. There are many devices out there that have certain settings stored somewhere and it needs these based on how the device is build or how it is provisioning in the factory.

What I would actually prefer to see that the driver just requests this blob of information and then a separate subsystem deals with getting it. As I said, in some cases the information might be in ACPI or devicetree or accessible by a special driver. In that case no userspace interaction would be needed at all. However the driver has to deal with the fact that the data blob might not be available for a certain period of time. If you mention cellular modem, then that one has to boot up first and get its data. More reason to actually design this cleanly so that there are no race conditions.

Regards

Marcel
