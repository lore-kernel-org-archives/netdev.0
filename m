From: Yuchung Cheng <ycheng@google.com>
Subject: Re: TCP connection issues against Amazon S3
Date: Wed, 7 Jan 2015 13:33:51 -0800
Message-ID: <CAK6E8=cXJWGdc6be==5B4mA+xU7JuOnvUMpsEGJ=9RTj8YDwsA@mail.gmail.com>
References: <5DCDADEF-FF9C-4844-8A2C-62E2D3B3B8CE@bengler.no>
 <1420560253.32621.20.camel@edumazet-glaptop2.roam.corp.google.com>
 <D5C36777-4461-4B8D-B6C4-38B4276F42DC@bengler.no> <1420564837.32621.30.camel@edumazet-glaptop2.roam.corp.google.com>
 <8C4F7938-DCA1-46F5-A3C9-7DF62511DEE7@bengler.no> <CAK6E8=d5Z0W5sSAdeEcecKbqjj_UwGw4949=a20fetFpLVKwwA@mail.gmail.com>
 <03FC652E-AA01-42C7-BD52-019B6D922A9C@bengler.no> <CAK6E8=cP0BFUob5MVj9M0hC0efgRnUY=JMUPKee+v-4TLvHBgg@mail.gmail.com>
 <76DC89D1-CFCE-44B7-994E-4349FEEDEFA6@bengler.no> <1420575216.5947.12.camel@edumazet-glaptop2.roam.corp.google.com>
 <4DA8529D-4EEC-42DA-89B0-DC7746DB2B10@bengler.no> <3F608393-E5F1-4647-81BF-C6C740100934@bengler.no>
 <CAK6E8=cf7cROQ0SON0BihkbOsBB+-sLAbexxgt4_xD+Auqev3Q@mail.gmail.com>
 <34CE0233-F881-4F40-B119-AA9D8F7D500F@bengler.no> <1420646284.5947.19.camel@edumazet-glaptop2.roam.corp.google.com>
 <A58F8257-97F8-4662-98FC-7AC57F35A3A4@bengler.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Erik Grinaker <erik@bengler.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <A58F8257-97F8-4662-98FC-7AC57F35A3A4@bengler.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 7, 2015 at 12:37 PM, Erik Grinaker <erik@bengler.no> wrote:
> On 07 Jan 2015, at 15:58, Eric Dumazet <eric.dumazet@gmail.com> wrote=
:
>> On Wed, 2015-01-07 at 13:31 +0000, Erik Grinaker wrote:
>>> On 06 Jan 2015, at 22:00, Yuchung Cheng <ycheng@google.com> wrote:
>>>> On Tue, Jan 6, 2015 at 1:04 PM, Erik Grinaker <erik@bengler.no> wr=
ote:
>>>>>
>>>>>> On 06 Jan 2015, at 20:26, Erik Grinaker <erik@bengler.no> wrote:
>>>>> This still doesn=E2=80=99t explain why it works with older kernel=
s, but not newer ones. I=E2=80=99m thinking it=E2=80=99s
>>>> probably some minor change, which gets amplified by the lack of SA=
CKs
>>>> on the loadbalancer. Anyway, I=E2=80=99ll bring it up with Amazon.
>>>> can you post traces with the older kernels?
>>>
>>> Here is a dump using 3.11.10 against a non-SACK-enabled loadbalance=
r:
>>>
>>> http://abstrakt.bengler.no/tcp-issues-s3-nosack-3.11.10.pcap.bz2
>>>
>>> The transfer shows lots of DUPACKs and retransmits, but this does n=
ot
>>> seem to have as bad an effect as it did with the failing transfer w=
e
>>> saw on newer kernels:
>>>
>>> http://abstrakt.bengler.no/tcp-issues-s3-failure.pcap.bz2
>>>
>>> One big difference, which Rick touched on earlier, is that the newe=
r
>>> kernels keep sending TCP window updates as it=E2=80=99s going throu=
gh the
>>> retransmits. The older kernel does not do this.
>>
>> The new kernel is the receiver : It does no retransmits.
>>
>> Increasing window in ACK packets should not prevent sender into
>> retransmitting missing packets.
>>
>> Sender is not a linux host and is very buggy IMO : If receiver
>> advertises a too big window, sender decides to not retransmit in som=
e
>> cases.
>
> I agree. I have contacted Amazon about this, but am not too hopeful f=
or a quick fix; they have been promising SACK-support on their loadbala=
ncers since 2006, for example.
>
> That said, since this change breaks a service as popular as S3, it mi=
ght be worth reconsidering.
With the newer kernel and bigger receive window, the sender skips (the
already slow NewReno) fast recovery and falls back to (exp backoff)
timeout recovery. Reducing rwin to accommodate the sender's bug seems
backward to me.


>
>> You can play with /proc/sys/net/ipv4/tcp_rmem and adopt very low val=
ues
>> to work around the sender bug.
>>
>> ( Or use SO_RCVBUF in receiver application)
>
> Thanks, setting SO_RCVBUF seems like a reasonable workaround.
