From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: wl1251: NVS firmware data
Date: Mon, 8 Dec 2014 20:46:07 +0100
Message-ID: <508290C6-B3D7-4E07-BE5E-EF6BDE568E92@holtmann.org>
References: <201411271506.20457@pali> <201412082015.18501@pali> <1418066813.1350.18.camel@dcbw.local> <201412082036.14609@pali>
Mime-Version: 1.0 (Mac OS X Mail 8.1 \(1993\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Dan Williams <dcbw@redhat.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
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
In-Reply-To: <201412082036.14609@pali>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Pali,

>>>>>>>>>> On Saturday 06 December 2014 13:49:54 Pavel Machek
>>>>>>>>>> wrote: /**
>>>>>>>>>> 
>>>>>>>>>> + * request_firmware_prefer_user: - prefer usermode
>>>>>>>>>> helper for loading firmware + * @firmware_p:
>>>>>>>>>> pointer to firmware image
>>>>>>>>>> + * @name: name of firmware file
>>>>>>>>>> + * @device: device for which firmware is being
>>>>>>>>>> loaded + *
>>>>>>>>>> + * This function works pretty much like
>>>>>>>>>> request_firmware(), but it prefer + * usermode
>>>>>>>>>> helper. If usermode helper fails then it fallback
>>>>>>>>>> to direct access. + * Usefull for dynamic or model
>>>>>>>>>> specific firmware data. + **/
>>>>>>>>>> +int request_firmware_prefer_user(const struct
>>>>>>>>>> firmware **firmware_p, +                          
>>>>>>>>>> const char *name, struct device *device) +{
>>>>>>>>>> +       int ret;
>>>>>>>>>> +       __module_get(THIS_MODULE);
>>>>>>>>>> +       ret = _request_firmware(firmware_p, name,
>>>>>>>>>> device, +                              
>>>>>>>>>> FW_OPT_UEVENT
>>>>>>>>>> 
>>>>>>>>>> | FW_OPT_PREFER_USER); +
>>>>>>>>>> 
>>>>>>>>>> module_put(THIS_MODULE); +       return ret;
>>>>>>>>>> +}
>>>>>>>>>> +EXPORT_SYMBOL_GPL(request_firmware_prefer_user);
>>>>>>>>> 
>>>>>>>>> I'd like to introduce request_firmware_user() which
>>>>>>>>> only requests firmware from user space, and this
>>>>>>>>> way is simpler and more flexible since we have
>>>>>>>>> request_firmware_direct() already.
>>>>>>>> 
>>>>>>>> Why would a driver care about what program provides
>>>>>>>> the firmware?  It shouldn't at all, and we want to
>>>>>>>> get rid of the userspace firmware loader, not
>>>>>>>> encourage drivers to use it "exclusively" at all.
>>>>>>> 
>>>>>>> Do not remove it! Without userspace firmware loader it
>>>>>>> is impossible to load dynamic firmware files.
>>>>>> 
>>>>>> why is this dynamic in the first place. It does not
>>>>>> sound like dynamic data to me at all. This is like the
>>>>>> WiFi MAC address(es) or Bluetooth BD_ADDR. They are
>>>>>> all static information. The only difference is that
>>>>>> they are on the host accessibly filesystem or storage
>>>>>> and not on the device itself.
>>>>>> 
>>>>>> To be honest, for Bluetooth we solved this now. If the
>>>>>> device is missing key information like the calibration
>>>>>> data or BD_ADDR, then it comes up unconfigured. A
>>>>>> userspace process can then go and load the right data
>>>>>> into it and then the device becomes available as
>>>>>> Bluetooth device.
>>>>>> 
>>>>>> Trying to use request_firmware to load some random data
>>>>>> and insist on going through userspace helper for that
>>>>>> sounds crazy to me. Especially since we are trying
>>>>>> hard to get away from the userspace loader. Forcing to
>>>>>> keep it for new stuff sounds backwards to me.
>>>>>> 
>>>>>> With the special Nokia partition in mind, why hasn't
>>>>>> this been turned into a mountable filesystem or into a
>>>>>> driver/subsystem that can access the data direct from
>>>>>> the kernel. I advocated for this some time ago. Maybe
>>>>>> there should be a special subsystem for access to
>>>>>> these factory persistent information that drivers then
>>>>>> just can access. I seem to remember that some systems
>>>>>> provide these via ACPI. Why does the ARM platform has
>>>>>> to be special here?
>>>>>> 
>>>>>> And the problem of getting Ethernet and WiFi MAC
>>>>>> address and Bluetooth BD_ADDR comes up many many
>>>>>> times. Why not have something generic here. And don't
>>>>>> tell me request_firmware is that generic solution ;)
>>>>>> 
>>>>>> Regards
>>>>>> 
>>>>>> Marcel
>>>>> 
>>>>> Hi Marcel. I think you did not understand this problem.
>>>>> This discussion is not about mac address. Please read
>>>>> email thread again and if there are some unclear pars,
>>>>> then ask. Thanks!
>>>> 
>>>> I think that I pretty clearly understand the problem.
>>>> Calibration data, MAC address, what is the difference? For
>>>> me this is all the same. It is data that is specific to a
>>>> device or type of devices and it is stored somewhere
>>>> else. In most cases in some immutable memory/flash area.
>>> 
>>> Those calibration data (in form of binary NVS firmware file)
>>> needs to be sent to wl1251 chip. Mac address is not needed
>>> at this step (and kernel generate some random if is not
>>> provided).
>>> 
>>> (Just to note wl1271 driver loads both MAC address and NVS
>>> data via one firmware file which is prepared by userspace,
>>> but this discussion is about wl1251...)
>>> 
>>>> What you want is access to this data since the kernel
>>>> driver needs it. Do I get this so far ;)
>>> 
>>> Yes, we need to provide NVS data to kernel when kernel ask
>>> for them.
>>> 
>>>> So my take is that request_firmware is not the right way
>>>> to get this data. Or more precisely make sure that this
>>>> data is available to kernel drivers. And what I am seeing
>>>> here is that instead of actually solving the bigger
>>>> problem, we just hack around it with request_firmware.
>>>> Now surprisingly the request_firmware loads files
>>>> directly from the kernel and all the hacks do not work
>>>> anymore.
>>>> 
>>>> Regards
>>>> 
>>>> Marcel
>>> 
>>> Just read emails again...
>>> 
>>> Our problem is:
>>> 
>>> linux-firmware.git tree provides two binary firmware files:
>>> 
>>> ti-connectivity/wl1251-fw.bin
>>> ti-connectivity/wl1251-nvs.bin
>>> 
>>> First is firmware file, second NVS file with generic
>>> calibration data. Kernel driver wl1251 now loads both
>>> firmware files via request_firmware. Generic calibration
>>> data are enough for wl1251 chip (it should work). But
>>> devices have own calibration data stored somewhere else.
>>> 
>>> On Nokia N900 NVS data are generated on-the-fly from some
>>> bytes from CAL (/dev/mtd1), from state of cellular network
>>> and from some other regulation settings.
>>> 
>>> So I think that files stored in linux-firmware.git tree
>>> (which are also installed into /lib/firmware/) should be
>>> loaded with request_firmware function. Or not? Do you think
>>> something else? What other developers think?
>>> 
>>> I'm against kernel driver for CAL (/dev/mtd1) for more
>>> reasons:
>>> 
>>> 1) we have userspace open source code, but licensed under
>>> GPLv3. And until kernel change license, we cannot include
>>> it.
>>> 
>>> 2) NVS data are (probably) not in one place, plus they
>>> depends on something other.
>>> 
>>> 3) If manufacture XYZ create new device with its own storage
>>> format of calibration data this means that correct solution
>>> for XYZ is also to implement new kernel fs driver for its
>>> own format. Do you really want to have in kernel all those
>>> drivers for all different (proprietary) storage formats?
>>> 
>>> 4) It does not help us with existence of generic file
>>> /lib/firmware/ti-connectivity/wl1251-nvs.bin which comes
>>> from linux-firmware.git tree.
>> 
>> a) change driver to prefer a new "wl1251-nvs-n900.bin" file,
> 
> Why to "*-n900.bin" ? wl1251 driver is used on other devices too.
> 
>> but fall back to "wl1251-nvs.bin" if the first one isn't
>> present
> 
>> b) have a "wl1251-cal-nvs-update" service that, if
>> wl1521-nvs-n900.bin is *not* present mounts the CAL MTD,
>> reads the data, writes it out into wl1521-nvs-n900.bin, and
>> the rmmod/modprobes the driver
>> 
> 
> Quote:
>> On Nokia N900 NVS data are generated on-the-fly from some bytes 
>> from CAL (/dev/mtd1), from state of cellular network and from 
>> some other regulation settings.
> 
> This basically means to rewrite it every boot or everytime when 
> country was changed (for regulation settings). And Ii really do 
> not want to do that.
> 
> And rmmod is not working on statically linked drivers into 
> zImage. So this is not solution.

actually module removal is still considered a race condition. If re-loading a module is part of your solution, then you are already heading into the wrong direction.

WiFi subsystem have a solution for handling regulatory enforcement. I don't know why would you try to invent that same via NVS files.

> 
>> and done?  Stuff that's not N900 just wouldn't ship the update
>> service and would proceed like none of this happened.
>> 
>> Dan
> 
> Again, what is wrong with userspace firmware helper? I think that 
> it fix this problem in a clean way without any hacks (like CAL in 
> kernel or creating new FS specially for parsing NVS and so on) in 
> kernel. And in userspace we can implement program which generate 
> NVS firmware data on-the-fly and send them to kernel in 
> compatible format of ti-connectivity/wl1251-nvs.bin

How do you run a userspace firmware helper if the root filesystem has not yet been mounted? How do you run userspace helper during resume?

Honestly for drivers linked statically into the kernel, the best approach is that they stay unconfigured until userspace is available and can run a tool to provide the correct data.

Regards

Marcel
