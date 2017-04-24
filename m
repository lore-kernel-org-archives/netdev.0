From: =?UTF-8?Q?Lars_Erik_Storbuk=C3=A5s?= <storbukas.dev@gmail.com>
Subject: Re: Get amount of fast retransmissions from TCP info
Date: Mon, 24 Apr 2017 23:31:25 +0200
Message-ID: <CAF0XkCAZJd7adZf6VHdDc2yesyKQ8DqQnDOv_uk8o8mOVGMRyA@mail.gmail.com>
References: <CAF0XkCCFwxuyJ5bc4SUHjdDJb_E-CqYC-3k3nzi+0i3H9D2zPA@mail.gmail.com>
 <CADVnQyk9-OGKBKBvQ76itP5JwbVBPt40S8KJ+6oY506hVpMEYA@mail.gmail.com>
 <CAF0XkCDTexCTxPmGvM4+FZtVhQg13Ggsbm0QSbcKCSR5LGbs9w@mail.gmail.com> <CADVnQyn=6wYbVP0m3mepGU23LcEn_BK_TKoSNxVf=TUz9Q+f8g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: LKML <linux-kernel@vger.kernel.org>,
        Netdev <netdev@vger.kernel.org>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CADVnQyn=6wYbVP0m3mepGU23LcEn_BK_TKoSNxVf=TUz9Q+f8g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2017-04-24 23:00 GMT+02:00 Neal Cardwell <ncardwell@google.com>:
> On Mon, Apr 24, 2017 at 4:20 PM, Lars Erik Storbuk=C3=A5s
> <storbukas.dev@gmail.com> wrote:
>> 2017-04-24 21:42 GMT+02:00 Neal Cardwell <ncardwell@google.com>:
>>> On Mon, Apr 24, 2017 at 3:11 PM, Lars Erik Storbuk=C3=A5s
>>> <storbukas.dev@gmail.com> wrote:
>>>> I'm trying to get amount of congestion events in TCP caused by
>>>> DUPACK's (fast retransmissions), and can't seem to find any variable
>>>> in the TCP info struct which hold that value. There are three
>>>> variables in the TCP info struct that seem to hold similar congestion
>>>> values: __u8 tcpi_retransmits;__u32 tcpi_retrans; __u32
>>>> tcpi_total_retrans;
>>>>
>>>> Does anyone have any pointers on how to find this value in the TCP cod=
e?
>>>>
>>>> Please CC me personally if answering this question. Any help is
>>>> greatly appreciated.
>>>
>>> [I'm cc-ing the netdev list.]
>>>
>>> Do you need this per-socket? On a per-socket basis, I do not think
>>> there are separate totals for fast retransmits and timeout
>>> retransmits.
>>>
>>> If a global number is good enough, then you can get that number from
>>> the global network statistics. In "nstat" output they look like:
>>>
>>>   TcpExtTCPFastRetrans =3D packets sent in fast retransmit / fast recov=
ery
>>>
>>>   TcpExtTCPSlowStartRetrans =3D packets sent in timeout recovery
>>>
>>> It sounds like TcpExtTCPFastRetrans is what you are after.
>>>
>>> Hope that helps,
>>> neal
>>
>> Thanks for your answer Neal.
>>
>> Yes, I need this information per-socket. What would be the most
>> appropriate place to update this value?
>
> Is this for a custom kernel you are building? Or are you proposing
> this for upstream?

This is currently for a custom kernel.

> IMHO the best place to add this for your custom kernel would be in
> _tcp_retransmit_skb() around the spot with the comment "Update global
> and local TCP statistics". Something like:
>
>   /* Update global and local TCP statistics. */
> ...
>   tp->total_retrans +=3D segs;
>   if (icsk->icsk_ca_state =3D=3D TCP_CA_Loss)
>     tp->slow_retrans +=3D segs;
>   else
>     tp->fast_retrans +=3D segs;
>

Excellent. That seems like a logical place.

>> If none of the variables (mentioned above) contain any value in
>> regards to fast retransmits, what does the different values represent?
>
> tcpi_retransmits: consecutive retransmits of lowest-sequence outstanding =
packet
>
> tcpi_retrans: retransmitted packets estimated to be in-flight in the netw=
ork now
>
> tcpi_total_retrans: total number of retransmitted packets over the
> life of the connection
>
> Can you sketch out why you need to have separate counts for fast
> retransmits and timeout/slow-start retransmits?
>
> neal

I'm working on the implementation of a Deadline Aware, Less than Best
Effort framework proposed by David A. Hayes, David Ros, Andreas
Petlund. A framework for adding both LBE behaviour and awareness of
=E2=80=9Csoft=E2=80=9D delivery deadlines to any congestion control (CC) al=
gorithm,
whether loss-based, delay- based or explicit signaling-based. This
effectively allows it to turn an arbitrary CC protocol into a
scavenger protocol that dynamically adapts its sending rate to network
conditions and remaining time before the deadline, to balance
timeliness and transmission aggressiveness.

/Lars Erik
