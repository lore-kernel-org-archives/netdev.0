From: =?UTF-8?Q?Jo=C3=A3o_Paulo_Rechi_Vita?= <jprvita@gmail.com>
Subject: Re: [PATCH 8/9] rfkill: Userspace control for airplane mode
Date: Mon, 22 Feb 2016 11:11:25 -0500
Message-ID: <CA+A7VXVj4rx4GHRd4ojpGmLOt0=Vg7nHNUxTdN2tgHd2Ma6szg@mail.gmail.com>
References: <1454946096-9752-1-git-send-email-jprvita@endlessm.com>
 <1454946096-9752-9-git-send-email-jprvita@endlessm.com> <1455826364.2084.22.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Darren Hart <dvhart@infradead.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	platform-driver-x86@vger.kernel.org, linux-api@vger.kernel.org,
	linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	linux@endlessm.com,
	=?UTF-8?Q?Jo=C3=A3o_Paulo_Rechi_Vita?= <jprvita@endlessm.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <platform-driver-x86-owner@vger.kernel.org>
In-Reply-To: <1455826364.2084.22.camel@sipsolutions.net>
Sender: platform-driver-x86-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 18 February 2016 at 15:12, Johannes Berg <johannes@sipsolutions.net>=
 wrote:
> Hi,
>
> Sorry for the delay reviewing this.
>

No problems!

>
> On Mon, 2016-02-08 at 10:41 -0500, Jo=C3=A3o Paulo Rechi Vita wrote:
>> Provide an interface for the airplane-mode indicator be controlled
>> from
>> userspace. User has to first acquire the control through
>> RFKILL_OP_AIRPLANE_MODE_ACQUIRE and keep the fd open for the whole
>> time
>> it wants to be in control of the indicator. Closing the fd or using
>> RFKILL_OP_AIRPLANE_MODE_RELEASE restores the default policy.
>
> I've come to the conclusion that the new ops are probably the best
> thing to do here.
>

Nice.

>> +Userspace can also override the default airplane-mode indicator
>> policy through
>> +/dev/rfkill. Control of the airplane mode indicator has to be
>> acquired first,
>> +using RFKILL_OP_AIRPLANE_MODE_ACQUIRE, and is only available for on=
e
>> userspace
>> +application at a time. Closing the fd or using
>> RFKILL_OP_AIRPLANE_MODE_RELEASE
>> +reverts the airplane-mode indicator back to the default kernel
>> policy and makes
>> +it available for other applications to take control. Changes to the
>> +airplane-mode indicator state can be made using
>> RFKILL_OP_AIRPLANE_MODE_CHANGE,
>> +passing the new value in the 'soft' field of 'struct rfkill_event'.
>
> I don't really see any value in _RELEASE, since an application can ju=
st
> close the fd? I'd prefer not having the duplicate functionality
> and force us to exercise the single code path every time.
>

I actually added this op only for completion, I couldn't think of a
use-case where simply closing the fd wouldn't be enough. I'll remove
it for the next revision.

>>  For further details consult Documentation/ABI/stable/sysfs-class-
>> rfkill.
>> diff --git a/include/uapi/linux/rfkill.h
>> b/include/uapi/linux/rfkill.h
>> index 2e00dce..9cb999b 100644
>> --- a/include/uapi/linux/rfkill.h
>> +++ b/include/uapi/linux/rfkill.h
>> @@ -67,6 +67,9 @@ enum rfkill_operation {
>>       RFKILL_OP_DEL,
>>       RFKILL_OP_CHANGE,
>>       RFKILL_OP_CHANGE_ALL,
>> +     RFKILL_OP_AIRPLANE_MODE_ACQUIRE,
>> +     RFKILL_OP_AIRPLANE_MODE_RELEASE,
>> +     RFKILL_OP_AIRPLANE_MODE_CHANGE,
>>  };
>
>> @@ -1199,7 +1202,7 @@ static ssize_t rfkill_fop_write(struct file
>> *file, const char __user *buf,
>>       if (copy_from_user(&ev, buf, count))
>>               return -EFAULT;
>>
>> -     if (ev.op !=3D RFKILL_OP_CHANGE && ev.op !=3D
>> RFKILL_OP_CHANGE_ALL)
>> +     if (ev.op < RFKILL_OP_CHANGE)
>>               return -EINVAL;
>
> You need to also reject invalid high values, like 27.
>

Yes, sorry for missing this.

>>       mutex_lock(&rfkill_global_mutex);
>>
>> +     if (ev.op =3D=3D RFKILL_OP_AIRPLANE_MODE_ACQUIRE) {
>> +             if (rfkill_apm_owned && !data->is_apm_owner) {
>> +                     count =3D -EACCES;
>> +             } else {
>> +                     rfkill_apm_owned =3D true;
>> +                     data->is_apm_owner =3D true;
>> +             }
>> +     }
>> +
>> +     if (ev.op =3D=3D RFKILL_OP_AIRPLANE_MODE_RELEASE) {
>
> It would probably be better to simply use "switch (ev.op)" and make t=
he
> default case do a reject.
>

Sounds better indeed.

>>       if (ev.op =3D=3D RFKILL_OP_CHANGE_ALL)
>>               rfkill_update_global_state(ev.type, ev.soft);
>
> Also moving the existing code inside the switch, of course.
>

Sure.

--
Jo=C3=A3o Paulo Rechi Vita
http://about.me/jprvita
