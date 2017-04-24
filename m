From: Andreas Petlund <apetlund@simula.no>
Subject: Re: Get amount of fast retransmissions from TCP info
Date: Tue, 25 Apr 2017 00:20:05 +0200
Message-ID: <8D257A7F-6045-46C5-AEED-A4630D10CD5A@simula.no>
References: <CAF0XkCCFwxuyJ5bc4SUHjdDJb_E-CqYC-3k3nzi+0i3H9D2zPA@mail.gmail.com> <CADVnQyk9-OGKBKBvQ76itP5JwbVBPt40S8KJ+6oY506hVpMEYA@mail.gmail.com> <CAF0XkCDTexCTxPmGvM4+FZtVhQg13Ggsbm0QSbcKCSR5LGbs9w@mail.gmail.com> <CADVnQyn=6wYbVP0m3mepGU23LcEn_BK_TKoSNxVf=TUz9Q+f8g@mail.gmail.com> <CAF0XkCAZJd7adZf6VHdDc2yesyKQ8DqQnDOv_uk8o8mOVGMRyA@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: LKML <linux-kernel@vger.kernel.org>,
        Netdev <netdev@vger.kernel.org>,
        =?utf-8?Q?Lars_Erik_Storbuk=C3=A5s?= <storbukas.dev@gmail.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f48.google.com ([209.85.215.48]:36419 "EHLO
        mail-lf0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755742AbdDXWUK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 18:20:10 -0400
Received: by mail-lf0-f48.google.com with SMTP id c80so81493019lfh.3
        for <netdev@vger.kernel.org>; Mon, 24 Apr 2017 15:20:09 -0700 (PDT)
In-Reply-To: <CAF0XkCAZJd7adZf6VHdDc2yesyKQ8DqQnDOv_uk8o8mOVGMRyA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On 24 Apr 2017, at 23:31, Lars Erik Storbuk=C3=A5s =
<storbukas.dev@gmail.com> wrote:
>=20
> 2017-04-24 23:00 GMT+02:00 Neal Cardwell <ncardwell@google.com>:
>> On Mon, Apr 24, 2017 at 4:20 PM, Lars Erik Storbuk=C3=A5s
>> <storbukas.dev@gmail.com> wrote:
>>> 2017-04-24 21:42 GMT+02:00 Neal Cardwell <ncardwell@google.com>:
>>>> On Mon, Apr 24, 2017 at 3:11 PM, Lars Erik Storbuk=C3=A5s
>>>> <storbukas.dev@gmail.com> wrote:
>>>>> I'm trying to get amount of congestion events in TCP caused by
>>>>> DUPACK's (fast retransmissions), and can't seem to find any =
variable
>>>>> in the TCP info struct which hold that value. There are three
>>>>> variables in the TCP info struct that seem to hold similar =
congestion
>>>>> values: __u8 tcpi_retransmits;__u32 tcpi_retrans; __u32
>>>>> tcpi_total_retrans;
>>>>>=20
>>>>> Does anyone have any pointers on how to find this value in the TCP =
code?
>>>>>=20
>>>>> Please CC me personally if answering this question. Any help is
>>>>> greatly appreciated.
>>>>=20
>>>> [I'm cc-ing the netdev list.]
>>>>=20
>>>> Do you need this per-socket? On a per-socket basis, I do not think
>>>> there are separate totals for fast retransmits and timeout
>>>> retransmits.
>>>>=20
>>>> If a global number is good enough, then you can get that number =
from
>>>> the global network statistics. In "nstat" output they look like:
>>>>=20
>>>>  TcpExtTCPFastRetrans =3D packets sent in fast retransmit / fast =
recovery
>>>>=20
>>>>  TcpExtTCPSlowStartRetrans =3D packets sent in timeout recovery
>>>>=20
>>>> It sounds like TcpExtTCPFastRetrans is what you are after.
>>>>=20
>>>> Hope that helps,
>>>> neal
>>>=20
>>> Thanks for your answer Neal.
>>>=20
>>> Yes, I need this information per-socket. What would be the most
>>> appropriate place to update this value?
>>=20
>> Is this for a custom kernel you are building? Or are you proposing
>> this for upstream?
>=20
> This is currently for a custom kernel.
>=20
>> IMHO the best place to add this for your custom kernel would be in
>> _tcp_retransmit_skb() around the spot with the comment "Update global
>> and local TCP statistics". Something like:
>>=20
>>  /* Update global and local TCP statistics. */
>> ...
>>  tp->total_retrans +=3D segs;
>>  if (icsk->icsk_ca_state =3D=3D TCP_CA_Loss)
>>    tp->slow_retrans +=3D segs;
>>  else
>>    tp->fast_retrans +=3D segs;
>>=20
>=20
> Excellent. That seems like a logical place.
>=20
>>> If none of the variables (mentioned above) contain any value in
>>> regards to fast retransmits, what does the different values =
represent?
>>=20
>> tcpi_retransmits: consecutive retransmits of lowest-sequence =
outstanding packet
>>=20
>> tcpi_retrans: retransmitted packets estimated to be in-flight in the =
network now
>>=20
>> tcpi_total_retrans: total number of retransmitted packets over the
>> life of the connection
>>=20
>> Can you sketch out why you need to have separate counts for fast
>> retransmits and timeout/slow-start retransmits?
>>=20
>> neal
>=20
> I'm working on the implementation of a Deadline Aware, Less than Best
> Effort framework proposed by David A. Hayes, David Ros, Andreas
> Petlund. A framework for adding both LBE behaviour and awareness of
> =E2=80=9Csoft=E2=80=9D delivery deadlines to any congestion control =
(CC) algorithm,
> whether loss-based, delay- based or explicit signaling-based. This
> effectively allows it to turn an arbitrary CC protocol into a
> scavenger protocol that dynamically adapts its sending rate to network
> conditions and remaining time before the deadline, to balance
> timeliness and transmission aggressiveness.
>=20

Just for the record, the paper is not publicly available yet, so it=E2=80=99=
s a bit hard to find:)=20
It will be published in IFIP Networking in June.
We will make it available as  soon as the conference regulations allows.
You can find the abstract here:=20
=
https://www.simula.no/publications/framework-less-best-effort-congestion-c=
ontrol-soft-deadlines

Cheers,
Andreas Petlund
