From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP keepalive timer problem
Date: Thu, 27 Aug 2009 16:49:00 +0200
Message-ID: <4A969CDC.6060402@gmail.com>
References: <0939B589FC103041945B9F13274963E303B1A9D4@CORPUSMX90A.corp.emc.com> <4A93E36C.8070502@gmail.com> <0939B589FC103041945B9F13274963E303B1AD89@CORPUSMX90A.corp.emc.com> <4A967FCE.3000807@gmail.com> <87skfdl6qt.fsf@basil.nowhere.org> <4A969566.3070606@gmail.com> <20090827142927.GA17220@basil.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Li_Xin2@emc.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751545AbZH0OtF@vger.kernel.org>
In-Reply-To: <20090827142927.GA17220@basil.fritz.box>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andi Kleen a =E9crit :
> On Thu, Aug 27, 2009 at 04:17:10PM +0200, Eric Dumazet wrote:
>> Andi Kleen a =E9crit :
>>> Eric Dumazet <eric.dumazet@gmail.com> writes:
>>>> Now, 7200 seconds might be inappropriate for special needs, and co=
nsidering
>>>> there is no way to change tcp_retries2 for a given socket (only ch=
oice being the global
>>>> tcp_retries2 setting), I would vote for a change in our stack, to =
*relax* RFC,
>>>> and get smaller keepalive timers if possible.
>>> I think the better fix would be to just to only do that when
>>> tcp_retries2 > keep alive time. So keep the existing behaviour
>>> with default keep alive, but switch when the user defined
>>> a very short keep alive.
>>>
>> tcp_retries2 is a number of retries, its difficult to derive a time =
from it.
>=20
> That shouldn't be too hard.=20
>=20
>> Also, it's not clear what behavior you are refering to.
>> Imagine we can be smart and compute tcp_retries2_time (in jiffies) f=
rom tcp_retries2
>> If keepalive_timer fires and we have packets in flight, what heurist=
ic do you suggest ?
>=20
> I didn't suggest to change something at firing time, just pattern
> the code you removed with if (keepalive_time > retries2 time)
>=20
> That's not perfect, but likely good enough.
>=20
>=20
>> if (tp->packets_out || tcp_send_head(sk))
>> 	if (tcp_retries2_time < keepalive_time_when(tp))
>> 		goto resched;
>> elapsed =3D tcp_time_stamp - tp->rcv_tstamp;
>> ...
>>
>> What would be the gain ?
>> Arming timer exactly every keepalive_time_when(tp)
>> instead of keepalive_time_when(tp) - (tcp_time_stamp - tp->rcv_tstam=
p) ?
>=20
> The gain would be that you don't send unnecessary packets by default =
(following the RFC), but=20
> still give expected behaviour to users who explicitely set short keep=
alives.
>=20

Yep, so to recap we have two changes :

1) The one I sent (taking into account the time of last ACK we received=
) to compute the
timer delays.

2) The one you suggest, avoiding to send a probe if we have packets in =
flight, relying
on normal retransmits timers.
