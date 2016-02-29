From: =?UTF-8?Q?Jo=C3=A3o_Paulo_Rechi_Vita?= <jprvita@gmail.com>
Subject: Re: [PATCHv2 08/10] rfkill: Use switch to demux userspace operations
Date: Mon, 29 Feb 2016 17:30:20 -0500
Message-ID: <CA+A7VXUY=qVDQ-OqT+QJK8haN6AFX4Br=OPXi-6RCxpvH3=QRg@mail.gmail.com>
References: <1456159001-20307-1-git-send-email-jprvita@endlessm.com>
 <1456159001-20307-9-git-send-email-jprvita@endlessm.com> <20160226175925.GA9331@w1.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	Darren Hart <dvhart@infradead.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	platform-driver-x86@vger.kernel.org, linux-api@vger.kernel.org,
	linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	linux@endlessm.com,
	=?UTF-8?Q?Jo=C3=A3o_Paulo_Rechi_Vita?= <jprvita@endlessm.com>
To: Jouni Malinen <j@w1.fi>
Return-path: <platform-driver-x86-owner@vger.kernel.org>
In-Reply-To: <20160226175925.GA9331@w1.fi>
Sender: platform-driver-x86-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Jouni,

On 26 February 2016 at 12:59, Jouni Malinen <j@w1.fi> wrote:
> On Mon, Feb 22, 2016 at 11:36:39AM -0500, Jo=C3=A3o Paulo Rechi Vita =
wrote:
>> Using a switch to handle different ev.op values in rfkill_fop_write(=
)
>> makes the code easier to extend, as out-of-range values can always b=
e
>> handled by the default case.
>
> This breaks rfkill.. There are automated test scripts for testing thi=
s
> area (and most of Wi-Fi for that matter. It would be nice if these we=
re
> used for changes before they get contributed upstream..
>
> http://buildbot.w1.fi/hwsim/
>

Thanks for pointing that out, I haven't heard of this tool before.
I'll give it a try before my next submission.

> This specific commit broke all the rfkill_* test cases because of
> following:
>
>> diff --git a/net/rfkill/core.c b/net/rfkill/core.c
>> @@ -1199,29 +1200,32 @@ static ssize_t rfkill_fop_write(struct file =
*file, const char __user *buf,
>> -     list_for_each_entry(rfkill, &rfkill_list, node) {
>> -             if (rfkill->idx !=3D ev.idx && ev.op !=3D RFKILL_OP_CH=
ANGE_ALL)
>> -                     continue;
>> -
>> -             if (rfkill->type !=3D ev.type && ev.type !=3D RFKILL_T=
YPE_ALL)
>> -                     continue;
>
> Note that RFKILL_TYPE_ALL here..
>
>> +             list_for_each_entry(rfkill, &rfkill_list, node)
>> +                     if (rfkill->type =3D=3D ev.type ||
>> +                         ev.type =3D=3D RFKILL_TYPE_ALL)
>> +                             rfkill_set_block(rfkill, ev.soft);
>
> It was included for RFKILL_OP_CHANGE_ALL.
>
>> +     case RFKILL_OP_CHANGE:
>> +             list_for_each_entry(rfkill, &rfkill_list, node)
>> +                     if (rfkill->idx =3D=3D ev.idx && rfkill->type =
=3D=3D ev.type)
>> +                             rfkill_set_block(rfkill, ev.soft);
>
> but not for RFKILL_OP_CHANGE..
>
> This needs following to work:
>
>
> diff --git a/net/rfkill/core.c b/net/rfkill/core.c
> index 59ff92d..c4bbd19 100644
> --- a/net/rfkill/core.c
> +++ b/net/rfkill/core.c
> @@ -1239,7 +1239,9 @@ static ssize_t rfkill_fop_write(struct file *fi=
le, const char __user *buf,
>                 break;
>         case RFKILL_OP_CHANGE:
>                 list_for_each_entry(rfkill, &rfkill_list, node)
> -                       if (rfkill->idx =3D=3D ev.idx && rfkill->type=
 =3D=3D ev.type)
> +                       if (rfkill->idx =3D=3D ev.idx &&
> +                           (rfkill->type =3D=3D ev.type ||
> +                            ev.type =3D=3D RFKILL_TYPE_ALL))
>                                 rfkill_set_block(rfkill, ev.soft);
>                 ret =3D 0;
>                 break;
>

I agree there is a difference in the logic here, thanks for taking the
time to point it out so clearly, and sorry for missing this. But AFAIU
userspace should not call RFKILL_OP_CHANGE with ev.type =3D=3D
RFKILL_TYPE_ALL, as RFKILL_OP_CHANGE is intended to be used to
block/unblock one RFKill switch, and it is not possible to create a
RFKill switch with type =3D=3D RFKILL_TYPE_ALL (rfkill_alloc() would
return NULL).

I tried to look into the source code of the test suite you pointed,
but couldn't easily figure out how it ends up with that combination.
Could you please explain (or point me in the code) how is that a valid
operation? If I'm not missing anything, we should probably return
EINVAL in this case.

Regards,

--
Jo=C3=A3o Paulo Rechi Vita
http://about.me/jprvita
