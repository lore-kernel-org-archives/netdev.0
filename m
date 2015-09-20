From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next 7/7] switchdev: update documentation on FDB ageing_time
Date: Sat, 19 Sep 2015 19:21:39 -0700
Message-ID: <CAE4R7bD_FchEJ_HuuJcGx0_fqwjxCG_EsYETogVO6O-6uoLj1g@mail.gmail.com>
References: <1442606151-50429-1-git-send-email-sfeldma@gmail.com>
 <1442606151-50429-8-git-send-email-sfeldma@gmail.com> <55FE0A2C.9040205@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Siva Mannem <siva.mannem.lnx@gmail.com>,
	Premkumar Jonnala <pjonnala@broadcom.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Wilson Kok <wkok@cumulusnetworks.com>
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:33688 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753889AbbITCWA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Sep 2015 22:22:00 -0400
Received: by obbbh8 with SMTP id bh8so61762140obb.0
        for <netdev@vger.kernel.org>; Sat, 19 Sep 2015 19:21:59 -0700 (PDT)
In-Reply-To: <55FE0A2C.9040205@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 19, 2015 at 6:21 PM, roopa <roopa@cumulusnetworks.com> wrote:
> On 9/18/15, 12:55 PM, sfeldma@gmail.com wrote:
>>
>> From: Scott Feldman <sfeldma@gmail.com>
>>
>> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>> ---
>>   Documentation/networking/switchdev.txt |   24 ++++++++++++------------
>>   1 file changed, 12 insertions(+), 12 deletions(-)
>>
>> diff --git a/Documentation/networking/switchdev.txt
>> b/Documentation/networking/switchdev.txt
>> index 476df04..67e43ee 100644
>> --- a/Documentation/networking/switchdev.txt
>> +++ b/Documentation/networking/switchdev.txt
>> @@ -239,20 +239,20 @@ The driver should initialize the attributes to the
>> hardware defaults.
>>   FDB Ageing
>>   ^^^^^^^^^^
>>   -There are two FDB ageing models supported: 1) ageing by the device, and
>> 2)
>> -ageing by the kernel.  Ageing by the device is preferred if many FDB
>> entries
>> -are supported.  The driver calls
>> call_switchdev_notifiers(SWITCHDEV_FDB_DEL,
>> -...) to age out the FDB entry.  In this model, ageing by the kernel
>> should be
>> -turned off.  XXX: how to turn off ageing in kernel on a per-port basis or
>> -otherwise prevent the kernel from ageing out the FDB entry?
>> -
>> -In the kernel ageing model, the standard bridge ageing mechanism is used
>> to age
>> -out stale FDB entries.  To keep an FDB entry "alive", the driver should
>> refresh
>> -the FDB entry by calling call_switchdev_notifiers(SWITCHDEV_FDB_ADD,
>> ...).  The
>> +The bridge will skip ageing FDB entries marked with NTF_EXT_LEARNED and
>> it is
>> +the responsibility of the port driver/device to age out these entries.
>> If the
>> +port device supports ageing, when the FDB entry expires, it will notify
>> the
>> +driver which in turn will notify the bridge with SWITCHDEV_FDB_DEL.  If
>> the
>> +device does not support ageing, the driver can simulate ageing using a
>> +garbage collection timer to monitor FBD entries.  Expired entries will be
>> +notified to the bridge using SWITCHDEV_FDB_DEL.  See rocker driver for
>> +example of driver running ageing timer.
>
> We do rely on the bridge driver ageing out entries. We have gone from
> hardware ageing to ageing in the switch driver to ultimately ageing in the
> bridge driver.  :). And we keep the fdb entries in the bridge driver "alive"
> by using 'NTF_USE' from the user-space driver.

Yes, your switch driver is in user-space so you have to use NTF_USE to
refresh the entry since you cannot use the kernel driver model to
call_switchdev_notifiers(SWITCHDEV_FDB_ADD, ...).  Consequently, your
entries are not marked with NTF_EXT_LEARNED, so this patch is a no-op
for you.  You can continue to use the bridge driver to age out your
entries.

>> +To keep an NTF_EXT_LEARNED entry "alive", the driver should refresh the
>> FDB
>> +entry by calling call_switchdev_notifiers(SWITCHDEV_FDB_ADD, ...).  The
>>
> Even with your current patches, looks like the switch driver will need to
> refresh the entries anyways to keep the "last-used" time to now.
> In which case is there much value in switch driver doing the ageing ?.

"should" not "must".

Value is for the many learned FDB entries case, to move the ageing
function to hardware.

> I am thinking keeping the default behavior of the bridge driver to age and
> anything else configurable might be a better option.

I'd rather someone add that knob when it's actually needed.  When the
first in-kernel switchdev driver that wants to use the bridge driver's
ageing function, then we can make that adjustment.
