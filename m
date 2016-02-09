From: =?UTF-8?Q?Jo=C3=A3o_Paulo_Rechi_Vita?= <jprvita-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 8/9] rfkill: Userspace control for airplane mode
Date: Tue, 9 Feb 2016 16:35:19 -0500
Message-ID: <CA+A7VXU9zoQZ5wM2Ranf7o9vUphGb0THkh8-TUM_1yD7aC30pQ@mail.gmail.com>
References: <1454946096-9752-1-git-send-email-jprvita@endlessm.com>
 <1454946096-9752-9-git-send-email-jprvita@endlessm.com> <CAGRGNgVuwrh5unUoQ0P+ow55ChOQ+qsRRjfD1bb7DC6PcrCO2g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Darren Hart <dvhart-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	platform-driver-x86-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-6IF/jdPJHihWk0Htik3J/w@public.gmane.org,
	=?UTF-8?Q?Jo=C3=A3o_Paulo_Rechi_Vita?= <jprvita-6IF/jdPJHihWk0Htik3J/w@public.gmane.org>
To: Julian Calaby <julian.calaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAGRGNgVuwrh5unUoQ0P+ow55ChOQ+qsRRjfD1bb7DC6PcrCO2g-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 8 February 2016 at 17:53, Julian Calaby <julian.calaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wr=
ote:

>> +       if (ev.op =3D=3D RFKILL_OP_AIRPLANE_MODE_RELEASE) {
>> +               if (rfkill_apm_owned && !data->is_apm_owner) {
>
> Are you sure this is correct?
>
> In the case that airplane mode isn't owned, the
> rfkill_apm_led_trigger_event() call will be a noop, so we should
> arguably not be calling it.
>

Ok, I'm changing the check to be consistent with _CHANGE, so the call
only succeeds if (rfkill_apm_owned && data->is_apm_owner), and return
an error otherwise.

> Also, should we just fail silently if we're not the owner? I.e. what
> does userspace learn from this op failing and is that useful?
>

I think it is better to return an error every time userspace is trying
to call an operation that it was not supposed to call at a certain
state (without acquiring control of the airplane-mode indicator). If a
program has a logic error that makes it call _RELEASE without calling
_ACQUIRE first, it's easier for the programmer to spot the problem if
we return an error here.

>> +                       count =3D -EACCES;
>> +               } else {
>> +                       bool state =3D rfkill_global_states[RFKILL_T=
YPE_ALL].cur;
>> +
>> +                       rfkill_apm_owned =3D false;
>> +                       data->is_apm_owner =3D false;
>> +                       rfkill_apm_led_trigger_event(state);
>> +               }
>> +       }
>> +
>> +       if (ev.op =3D=3D RFKILL_OP_AIRPLANE_MODE_CHANGE) {
>> +               if (rfkill_apm_owned && data->is_apm_owner)
>> +                       rfkill_apm_led_trigger_event(ev.soft);
>> +               else
>> +                       count =3D -EACCES;
>> +       }
>> +
>>         if (ev.op =3D=3D RFKILL_OP_CHANGE_ALL)
>>                 rfkill_update_global_state(ev.type, ev.soft);
>>
>> @@ -1230,7 +1261,17 @@ static int rfkill_fop_release(struct inode *i=
node, struct file *file)
>>         struct rfkill_int_event *ev, *tmp;
>>
>>         mutex_lock(&rfkill_global_mutex);
>> +
>> +       if (data->is_apm_owner) {
>> +               bool state =3D rfkill_global_states[RFKILL_TYPE_ALL]=
=2Ecur;
>> +
>> +               rfkill_apm_owned =3D false;
>> +               data->is_apm_owner =3D false;
>> +               rfkill_apm_led_trigger_event(state);
>
> Also, this code is duplicated from the _RELEASE op above. Would it
> make sense to factor it out into a separate function?
>

Yes, makes sense. This also made me notice I was assigning a negative
value to a size_t variable (count).

>> +       }
>> +
>>         list_del(&data->list);
>> +
>
> (extra line)
>

After factoring out the _RELEASE code it looks better without this
additional line.

>>         mutex_unlock(&rfkill_global_mutex);
>>
>>         mutex_destroy(&data->mtx);
>
> Thanks,
>

Thanks for the review, Julian. I'm sending an updated version.

--
Jo=C3=A3o Paulo Rechi Vita
http://about.me/jprvita
