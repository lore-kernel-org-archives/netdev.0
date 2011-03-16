From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH] tcp: avoid cwnd moderation in undo
Date: Wed, 16 Mar 2011 15:04:57 -0700
Message-ID: <AANLkTi=_duV-X26OkDaDB2fcvFJuJSt-hHxpdpG4f=B-@mail.gmail.com>
References: <1299894051-13820-1-git-send-email-ycheng@google.com>
 <201103151107.35379.carsten@wolffcarsten.de> <AANLkTinzkJKb9EtOys2EOW8SDnORdEOT=+UMNBACTJJe@mail.gmail.com>
 <201103161718.39110.carsten@wolffcarsten.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Ilpo Jarvinen <ilpo.jarvinen@helsinki.fi>,
	Nandita Dukkipati <nanditad@google.com>,
	netdev@vger.kernel.org,
	Alexander Zimmermann <alexander.zimmermann@comsys.rwth-aachen.de>
To: Carsten Wolff <carsten@wolffcarsten.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:7397 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751143Ab1CPWFU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2011 18:05:20 -0400
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [172.25.149.1])
	by smtp-out.google.com with ESMTP id p2GM5JkG031096
	for <netdev@vger.kernel.org>; Wed, 16 Mar 2011 15:05:19 -0700
Received: from yia25 (yia25.prod.google.com [10.243.65.25])
	by hpaq1.eem.corp.google.com with ESMTP id p2GM4kkI026119
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 16 Mar 2011 15:05:17 -0700
Received: by yia25 with SMTP id 25so1062357yia.21
        for <netdev@vger.kernel.org>; Wed, 16 Mar 2011 15:05:17 -0700 (PDT)
In-Reply-To: <201103161718.39110.carsten@wolffcarsten.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Carsten,

Thanks for the detailed explanation. This funnels down to

a) is cwnd moderation always a good idea?

b) if (a) is true, cwnd should be moderated all the time to suppress
any possible burst.

Clearly, Linux code supports (a) and (b). Like John's email, I am not
aware of too much scientific data supporting that.

But I do have a real problem on web server. The HTTP response has
normally a handful of packets. Moderating cwnd at the end or after the
(false) recovery often makes cwnd=3D3-4. This causes slow-start on the
subsequent HTTP response and throws away some benefit of  persistent
HTTP connections. That slow-start is not necessary and adds some extra
round-trips to serve the tiny object.


On Wed, Mar 16, 2011 at 9:18 AM, Carsten Wolff <carsten@wolffcarsten.de=
> wrote:
> Hi again,
>
> On Wednesday 16 March 2011, Yuchung Cheng wrote:
>> On Tue, Mar 15, 2011 at 3:07 AM, Carsten Wolff <carsten@wolffcarsten=
=2Ede>
> wrote:
>> > Hi,
>> >
>> > On Monday 14 March 2011, Yuchung Cheng wrote:
>> > > On Mon, Mar 14, 2011 at 3:06 AM, Carsten Wolff
>> > > <carsten@wolffcarsten.de>
>> >
>> > wrote:
>> > > In the presence of reordering, cwnd is already moderated in Diso=
rder
>> > > state before
>> > > =A0entering the (false) recovery.
>> >
>> > Sure, cwnd moderation to in_flight + 1 segment is applied in disor=
der
>> > state,
>>
>> it's in_flight + 3 usually. the moderation first happens
>> tcp_try_to_open() instead of tcp_cwnd_down()
>
> In disorder state, tcp_try_to_open() calls tcp_cwnd_down() which clam=
ps cwnd
> to in_flight + 1 for dupacks (where tcp_packets_in_flight() is not to=
 be
> confused with the IN_FLIGHT variable in IETF documents, which is call=
ed
> packets_out in Linux ...). Otherwise, Linux would be violating RFC304=
2, which
> allows to send one SMSS of data on each dupack before recovery (actua=
lly, just
> the first two, but since the DupThresh can be larger than 3 in linux,=
 it
> extends Limited Transmit to more than just the first two dupacks). Th=
is is
> mostly equivalent to the aggressive variant of extended limited trans=
mit in
> RFC4653.
>
>> > because this is implementing a form of extended limited transmit.
>> > Nevertheless, after a reordering event that caused a spurious fast
>> > retransmit, there can be an undo of congestion state changes (eith=
er
>> > after recovery or interrupting recovery, depending on the options
>> > enabled in the connection). I just wanted to point out, that the
>> > moderation step happening upon an undo may allow a larger burst, i=
f a
>> > previous reordering event was detected and caused tp->reordering t=
o be
>> > increased.
>>
>> Your point is that cwnd should be moderated on reordering (in undo o=
r
>> other events). Point taken.
>> =A0My point is that cwnd does not need to be moderated on false
>> recoveries. Do you agree?
>> To implement your design, tcp_update_reordering should do
>> tcp_cwnd_moderation().
>> To implement my point, the moderations should be avoided in undo
>> operations.
>>
>> The two aren't in conflict. But there are cases that have both undo
>> and reordering.
>> Are we on the same page?
>
> Unfortunately, no. ;-) My point is, that cwnd should be moderated whe=
n the
> congestion state changes are undone after a spurious recovery has bee=
n
> detected. Reordering is only one possible reason for a false recovery=
=2E And I
> stick to that point because of the thoughts I pointed out in my mail =
to john,
> i.e. undo typically leading to exceptionally large segment bursts.
>
> As for cwnd moderation upon the detection of a reordering event (that=
's a
> different thing at a differnt point in time than detection of a false
> recovery!): This wouldn't make sense to me. The detection of the reor=
dering
> event together with a metric that measures the extent of the reorderi=
ng can be
> used to try and prevent false recoverys in future reordering events, =
by
> delaying the congestion reaction (i.e. fast retransmit) then.
>
> Reordering can be a cause of spurious recovery. But undo mechanisms a=
nd
> mechanisms to prevent false recovery(s) are orthogonal.
>
> Your patch touches all undos, while reordering is just an example for=
 a cause
> of false recovery.
>
>> > > > More importantly, the prior ssthresh is restored and not affec=
ted by
>> > > > moderation. This means, if moderation reduces cwnd to a small =
value,
>> > > > then cwnd < ssthresh and TCP will quickly slow-start back to t=
he
>> > > > previous state, without sending a big burst of segments.
>> >
>> > This is actually the more important point, because it means that t=
he
>> > moderation does not negate the effects of the undo operation, as
>> > suggested by your patch-description.
>>
>> It's a double-edge sword. Why slow-start if there is no real loss?
>
> Its a timing thing. I mean, it is an undo operation: the harm has bee=
n done,
> some opportunity to send new data has been lost. Trying to send all t=
hat data
> at once now without an ACK-clock will cause more harm when buffers ar=
e under
> pressure. The undo operation should not try to make up for lost oppor=
tunity,
> only try to reduce further loss of opportunity to send new data. For =
this, the
> segment bursts have to be moderated.
>
>> It
>> hurts short
>> request-response type traffic performance badly b/c each undo makes =
cwnd =3D
>> 3.
>>
>> > False fast retransmits are mostly caused by reordering, spurious R=
TOs can
>> > also be caused by delay variations that do not exhibit reordering.=
 Your
>> > patch touches all cases of spurious events. Anyway, I just mention=
ed
>> > reordering, because it is the event in which Linux already allows =
larger
>> > bursts of size tp->reordering in the moderation function (i.e.
>> > tp->reordering might be increased). It's also not important to me =
if the
>> > undo is happening duringor after recovery, the important question =
is, if
>> > burst protection in general is an important goal, or not (and I th=
ink
>> > it's there for a reason).
>>
>> I am hoping my previous explanation make sense to you (these two poi=
nts are
>> not in conflict).
>
> I hope the same for my explanations. :-)
>
> Cheers
> Carsten
> --
> =A0 =A0 =A0 =A0 =A0 /\-=B4-/\
> =A0 =A0 =A0 =A0 =A0( =A0@ @ =A0)
> ________o0O___^___O0o________
>
