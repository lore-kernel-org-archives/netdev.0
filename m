From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCHv2 08/10] rfkill: Use switch to demux userspace operations
Date: Tue, 01 Mar 2016 14:43:07 +0100
Message-ID: <1456839787.3926.20.camel@sipsolutions.net>
References: <1456159001-20307-1-git-send-email-jprvita@endlessm.com>
	 <1456159001-20307-9-git-send-email-jprvita@endlessm.com>
	 <20160226175925.GA9331@w1.fi>
	 <CA+A7VXUY=qVDQ-OqT+QJK8haN6AFX4Br=OPXi-6RCxpvH3=QRg@mail.gmail.com>
	 <20160229223918.GA32464@w1.fi>
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
	=?ISO-8859-1?Q?Jo=E3o?= Paulo Rechi Vita
	<jprvita@endlessm.com>
To: Jouni Malinen <j@w1.fi>,
	=?ISO-8859-1?Q?Jo=E3o?= Paulo Rechi Vita <jprvita@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160229223918.GA32464@w1.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-03-01 at 00:39 +0200, Jouni Malinen wrote:

> > I agree there is a difference in the logic here,

Gah. I thought I'd reviewed the logic and made sure there's no
difference ... :)

> >  thanks for taking the
> > time to point it out so clearly, and sorry for missing this. But AF=
AIU
> > userspace should not call RFKILL_OP_CHANGE with ev.type =3D=3D
> > RFKILL_TYPE_ALL, as RFKILL_OP_CHANGE is intended to be used to
> > block/unblock one RFKill switch, and it is not possible to create a
> > RFKill switch with type =3D=3D RFKILL_TYPE_ALL (rfkill_alloc() woul=
d
> > return NULL).

> Interesting. Maybe Johannes can comment on that part since I think he
> wrote the code that interacts with kernel for the rfkill test cases.

So first of all, it seems that this argument is invalid since we can't =
break the ABI/API here; although perhaps if it's only a test case ...

Oh. It took me a while, but I see now. The original intent (I think)
was that with RFKILL_OP_CHANGE, the type would be ignored entirely. It
seems that the (my) original intent wouldn't have been to force
userspace to specify *both* the index and the type, but instead do

OP_CHANGE_ALL -> use type (possibly TYPE_ALL, ignoring idx)
OP_CHANGE =C2=A0 =C2=A0 -> use idx (ignoring type)


The original code implemented it as follows:

=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (rfkill->idx=
 !=3D ev.idx && ev.op !=3D RFKILL_OP_CHANGE_ALL)
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
continue;

-> check the idx only for OP_CHANGE

=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0if (rfkill->type !=3D ev.type && ev.type !=3D R=
=46KILL_TYPE_ALL)
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
continue;

-> check the type, allowing _ALL

Now, all userspace that I found sets the ev.type field to TYPE_ALL all
the time; and it had to given these checks.

e.g. from rfkill.py:

# idx, type, op, soft, hard
_event_struct =3D '@IBBBB'

[...]

=C2=A0 =C2=A0 def block(self):
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0rfk =3D open('/dev/rfki=
ll', 'w')
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0s =3D struct.pack(_even=
t_struct, self.idx, TYPE_ALL, _OP_CHANGE, 1, 0)
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0rfk.write(s)
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0rfk.close()


This check, originally, probably should've been

=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (rfkill->typ=
e !=3D ev.type && ev.type !=3D RFKILL_TYPE_ALL &&
                    ev.op !=3D RFKILL_OP_CHANGE)
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
continue;

to ignore the type entirely.

I'm fine with Jouni's change, preserving the original behaviour of
requiring TYPE_ALL or the correct type, but I'm tempted to simply
remove the type check entirely.

Thoughts?

johannes
