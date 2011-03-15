From: John Heffner <johnwheffner@gmail.com>
Subject: Re: [PATCH] tcp: avoid cwnd moderation in undo
Date: Tue, 15 Mar 2011 06:50:47 -0400
Message-ID: <AANLkTim_U9CySFQimQ8cG_iHdXCYXSALi9E6ticKztnk@mail.gmail.com>
References: <1299894051-13820-1-git-send-email-ycheng@google.com>
	<AANLkTimra1e-ONMx2hTeN90HFEvxqb3jPAr4v9_C+9wR@mail.gmail.com>
	<AANLkTi=qi2GOprXEWCf6v=j=L98SQMdHb1OaHcdALepf@mail.gmail.com>
	<201103151120.55388.carsten@wolffcarsten.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Yuchung Cheng <ycheng@google.com>,
	David Miller <davem@davemloft.net>,
	Ilpo Jarvinen <ilpo.jarvinen@helsinki.fi>,
	Nandita Dukkipati <nanditad@google.com>, netdev@vger.kernel.org
To: Carsten Wolff <carsten@wolffcarsten.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:47595 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750920Ab1COKus convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2011 06:50:48 -0400
Received: by ywj3 with SMTP id 3so176652ywj.19
        for <netdev@vger.kernel.org>; Tue, 15 Mar 2011 03:50:47 -0700 (PDT)
In-Reply-To: <201103151120.55388.carsten@wolffcarsten.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Anecdotally, I've seen more harm than good from cwnd moderation but I
don't have any data to back that up.  It's hard to categorically say
anything.  But I don't know what makes the cases where cwnd moderation
is applied special.

Some other sources of bursts include
- Send-limited applications that stall for some time but less than an
RTO and do a large write
- Receive-limited applications that stall for some time but less than
an RTO and do a large read
- "Ack compression," when acks are queued somewhere in the network and
flood out at line rate
- "Stretch acks," when the receiving TCP does not ack every segment
(for efficiency, etc.), or acks are lost in the network.

Since all of these may occur in the Open state, cwnd moderation is not =
applied.

While I'm adding to my wish list ;-), I will also say that the undo
logic seems unnecessarily complicated.  If you expect you might have
to undo what you just did, why not wait a bit?  Something like rfc4653
seems like it might be a better approach and might make the cwnd
moderation discussion moot.

Thanks,
  -John


On Tue, Mar 15, 2011 at 6:20 AM, Carsten Wolff <carsten@wolffcarsten.de=
> wrote:
> On Monday 14 March 2011, John Heffner wrote:
>> On Mon, Mar 14, 2011 at 3:10 PM, Yuchung Cheng <ycheng@google.com> w=
rote:
>> > On Mon, Mar 14, 2011 at 3:06 AM, Carsten Wolff <carsten@wolffcarst=
en.de>
> wrote:
>> >> The moderation is in place to avoid gigantic segment bursts, whic=
h could
>> >> cause unnecessary pressure on buffers. In my eyes it's already
>> >> suboptimal that the moderation is weakened in the presence of
>> >> (detected) reordering, let alone removing it completely.
>> >
>> > In the presence of reordering, cwnd is already moderated in Disord=
er
>> > state before
>> > =A0entering the (false) recovery.
>>
>> I've always been somewhat skeptical of the usefulness of cwnd
>> moderation. =A0First, I don't know that its behavior is well defined=
=2E
>> When *should* tcp_moderate_cwnd() actually be called, and why?
>>
>> Second, I've never liked the idea in general. =A0Reducing cwnd has a=
n
>> effect lasting many RTTs, so reducing it in response to a transient
>> event like reordering seems dubious. =A0And it does not address many
>> causes of bursts, such as ack compression or stretch acks.
>
> I think the undo operations are a special case where it absolutely ma=
kes
> sense, because the cwnd _already_ has been reduced (down to 1 segment=
 by RTO
> recovery, or, with its special mixture of ratehalving and newreno, Li=
nux
> sometimes reduces cwnd far below half of it even in fast recovery.). =
The undo
> re-opens the window all at once, which may allow _really huge_ bursts=
=2E I don't
> know enough about the other causes of TCPs burstiness, I'm just conce=
rned
> about allowing this special cause.
>
> Carsten
> --
> =A0 =A0 =A0 =A0 =A0 /\-=B4-/\
> =A0 =A0 =A0 =A0 =A0( =A0@ @ =A0)
> ________o0O___^___O0o________
>
