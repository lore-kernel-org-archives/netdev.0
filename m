From: Prarit Bhargava <prarit@redhat.com>
Subject: Re: [PATCH RESEND] iwlwifi, Do not implement thermal zone unless
 ucode is loaded
Date: Mon, 11 Jul 2016 14:19:42 -0400
Message-ID: <5783E33E.7090205@redhat.com>
References: <1468250301-10357-1-git-send-email-prarit@redhat.com> <CANUX_P0AFoM5VEDWDjtvOhNbExu4T1bLWU+uS-EYqoGtu5h2bw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Johannes Berg <johannes.berg@intel.com>,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
	Luca Coelho <luciano.coelho@intel.com>,
	Intel Linux Wireless <linuxwifi@intel.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	Chaya Rachel Ivgi <chaya.rachel.ivgi@intel.com>,
	Sara Sharon <sara.sharon@intel.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Emmanuel Grumbach <egrumbach@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CANUX_P0AFoM5VEDWDjtvOhNbExu4T1bLWU+uS-EYqoGtu5h2bw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 07/11/2016 02:00 PM, Emmanuel Grumbach wrote:
> On Mon, Jul 11, 2016 at 6:18 PM, Prarit Bhargava <prarit@redhat.com> wrote:
>>
>> Didn't get any feedback or review comments on this patch.  Resending ...
>>
>> P.
> 
> This change is obviously completely broken. It simply disables the
> registration to thermal zone core.

No it is not broken, and yes, that is exactly what should happen IMO.

The problem is that the iwlwifi driver implements the thermal zone even when the
device doesn't support it.

As can be seen in the current code base, iwl_mvm_tzone_get_temp() will return
-EIO 100% of the time when the firmware doesn't support reading the
temperature[1].  In this case a read of sysfs will result in a return of -EIO,
and this breaks existing userspace programs such as lm-sensors (which by all
accounts is bad to do).

Note that in my patch I have removed the -EIO return in favor of not registering
the non-existent thermal zone.  I'm not removing any functionality by changing
this, nor am I adding functionality.  In both cases the thermal zone is not
functional, and with my patch userspace continues to work.

P.

[1] iwl_mvm_tzone_set_trip_temp() also returns -EIO, so setting and getting of
the temperature is non-functional.


> 
>>
>> ---8<---
>>
>> The iwlwifi driver implements a thermal zone and hwmon device, but
>> returns -EIO on temperature reads if the firmware isn't loaded.  This
>> results in the error
>>
>> iwlwifi-virtual-0
>> Adapter: Virtual device
>> ERROR: Can't get value of subfeature temp1_input: I/O error
>> temp1:            N/A
>>
>> being output when using sensors from the lm-sensors package.  Since
>> the temperature cannot be read unless the ucode is loaded there is no
>> reason to add the interface only to have it return an error 100% of
>> the time.
>>
>> This patch moves the firmware check to iwl_mvm_thermal_zone_register() and
>> stops the thermal zone from being created if the ucode hasn't been loaded.
>>
>> Signed-off-by: Prarit Bhargava <prarit@redhat.com>
>> Cc: Johannes Berg <johannes.berg@intel.com>
>> Cc: Emmanuel Grumbach <emmanuel.grumbach@intel.com>
>> Cc: Luca Coelho <luciano.coelho@intel.com>
>> Cc: Intel Linux Wireless <linuxwifi@intel.com>
>> Cc: Kalle Valo <kvalo@codeaurora.org>
>> Cc: Chaya Rachel Ivgi <chaya.rachel.ivgi@intel.com>
>> Cc: Sara Sharon <sara.sharon@intel.com>
>> Cc: linux-wireless@vger.kernel.org
>> Cc: netdev@vger.kernel.org
>> ---
>>  drivers/net/wireless/intel/iwlwifi/mvm/tt.c |   13 +++----------
>>  1 file changed, 3 insertions(+), 10 deletions(-)
>>
>> diff --git a/drivers/net/wireless/intel/iwlwifi/mvm/tt.c b/drivers/net/wireless/intel/iwlwifi/mvm/tt.c
>> index 58fc7b3c711c..64802659711f 100644
>> --- a/drivers/net/wireless/intel/iwlwifi/mvm/tt.c
>> +++ b/drivers/net/wireless/intel/iwlwifi/mvm/tt.c
>> @@ -634,11 +634,6 @@ static int iwl_mvm_tzone_get_temp(struct thermal_zone_device *device,
>>
>>         mutex_lock(&mvm->mutex);
>>
>> -       if (!mvm->ucode_loaded || !(mvm->cur_ucode == IWL_UCODE_REGULAR)) {
>> -               ret = -EIO;
>> -               goto out;
>> -       }
>> -
>>         ret = iwl_mvm_get_temp(mvm, &temp);
>>         if (ret)
>>                 goto out;
>> @@ -684,11 +679,6 @@ static int iwl_mvm_tzone_set_trip_temp(struct thermal_zone_device *device,
>>
>>         mutex_lock(&mvm->mutex);
>>
>> -       if (!mvm->ucode_loaded || !(mvm->cur_ucode == IWL_UCODE_REGULAR)) {
>> -               ret = -EIO;
>> -               goto out;
>> -       }
>> -
>>         if (trip < 0 || trip >= IWL_MAX_DTS_TRIPS) {
>>                 ret = -EINVAL;
>>                 goto out;
>> @@ -750,6 +740,9 @@ static void iwl_mvm_thermal_zone_register(struct iwl_mvm *mvm)
>>                 return;
>>         }
>>
>> +       if (!mvm->ucode_loaded || !(mvm->cur_ucode == IWL_UCODE_REGULAR))
>> +               return;
>> +
>>         BUILD_BUG_ON(ARRAY_SIZE(name) >= THERMAL_NAME_LENGTH);
>>
>>         mvm->tz_device.tzone = thermal_zone_device_register(name,
>> --
>> 1.7.9.3
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
