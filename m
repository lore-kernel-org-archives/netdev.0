From: =?UTF-8?Q?Jo=C3=A3o_Paulo_Rechi_Vita?= <jprvita-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCHv2 08/10] rfkill: Use switch to demux userspace operations
Date: Tue, 1 Mar 2016 11:15:27 -0500
Message-ID: <CA+A7VXWWQOti7pOre08QcXN9vgssQH3V1f6RjphaK0VwM27C7g@mail.gmail.com>
References: <1456159001-20307-1-git-send-email-jprvita@endlessm.com>
 <1456159001-20307-9-git-send-email-jprvita@endlessm.com> <20160226175925.GA9331@w1.fi>
 <CA+A7VXUY=qVDQ-OqT+QJK8haN6AFX4Br=OPXi-6RCxpvH3=QRg@mail.gmail.com>
 <20160229223918.GA32464@w1.fi> <1456839787.3926.20.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jouni Malinen <j@w1.fi>, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Darren Hart <dvhart-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	platform-driver-x86-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-6IF/jdPJHihWk0Htik3J/w@public.gmane.org,
	=?UTF-8?Q?Jo=C3=A3o_Paulo_Rechi_Vita?= <jprvita-6IF/jdPJHihWk0Htik3J/w@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1456839787.3926.20.camel-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 1 March 2016 at 08:43, Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org> wro=
te:
> On Tue, 2016-03-01 at 00:39 +0200, Jouni Malinen wrote:
>
>> > I agree there is a difference in the logic here,
>
> Gah. I thought I'd reviewed the logic and made sure there's no
> difference ... :)
>
>> >  thanks for taking the
>> > time to point it out so clearly, and sorry for missing this. But A=
=46AIU
>> > userspace should not call RFKILL_OP_CHANGE with ev.type =3D=3D
>> > RFKILL_TYPE_ALL, as RFKILL_OP_CHANGE is intended to be used to
>> > block/unblock one RFKill switch, and it is not possible to create =
a
>> > RFKill switch with type =3D=3D RFKILL_TYPE_ALL (rfkill_alloc() wou=
ld
>> > return NULL).
>
>> Interesting. Maybe Johannes can comment on that part since I think h=
e
>> wrote the code that interacts with kernel for the rfkill test cases.
>
> So first of all, it seems that this argument is invalid since we can'=
t break the ABI/API here; although perhaps if it's only a test case ...
>

Yep, that's an important point (not breaking the API/ABI).

> Oh. It took me a while, but I see now. The original intent (I think)
> was that with RFKILL_OP_CHANGE, the type would be ignored entirely. I=
t
> seems that the (my) original intent wouldn't have been to force
> userspace to specify *both* the index and the type, but instead do
>
> OP_CHANGE_ALL -> use type (possibly TYPE_ALL, ignoring idx)
> OP_CHANGE     -> use idx (ignoring type)
>
>
> The original code implemented it as follows:
>
>                 if (rfkill->idx !=3D ev.idx && ev.op !=3D RFKILL_OP_C=
HANGE_ALL)
>                         continue;
>
> -> check the idx only for OP_CHANGE
>
>                 if (rfkill->type !=3D ev.type && ev.type !=3D RFKILL_=
TYPE_ALL)
>                         continue;
>
> -> check the type, allowing _ALL
>
> Now, all userspace that I found sets the ev.type field to TYPE_ALL al=
l
> the time; and it had to given these checks.
>
> e.g. from rfkill.py:
>
> # idx, type, op, soft, hard
> _event_struct =3D '@IBBBB'
>
> [...]
>
>     def block(self):
>         rfk =3D open('/dev/rfkill', 'w')
>         s =3D struct.pack(_event_struct, self.idx, TYPE_ALL, _OP_CHAN=
GE, 1, 0)
>         rfk.write(s)
>         rfk.close()
>
>
> This check, originally, probably should've been
>
>                 if (rfkill->type !=3D ev.type && ev.type !=3D RFKILL_=
TYPE_ALL &&
>                     ev.op !=3D RFKILL_OP_CHANGE)
>                         continue;
>
> to ignore the type entirely.
>
> I'm fine with Jouni's change, preserving the original behaviour of
> requiring TYPE_ALL or the correct type, but I'm tempted to simply
> remove the type check entirely.
>
> Thoughts?
>

I think this patch should keep the original logic, as this is supposed
to be a refactor only. If we decide to remove the check, we should to
it in a separate patch, to make it clear for someone looking at the
history later.

I'm fine with removing the type check (in a separate patch), but I
don't see much gain in doing so.

--
Jo=C3=A3o Paulo Rechi Vita
http://about.me/jprvita
