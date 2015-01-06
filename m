From: Erik Grinaker <erik@bengler.no>
Subject: Re: TCP connection issues against Amazon S3
Date: Tue, 6 Jan 2015 19:42:16 +0000
Message-ID: <76DC89D1-CFCE-44B7-994E-4349FEEDEFA6@bengler.no>
References: <5DCDADEF-FF9C-4844-8A2C-62E2D3B3B8CE@bengler.no> <1420560253.32621.20.camel@edumazet-glaptop2.roam.corp.google.com> <D5C36777-4461-4B8D-B6C4-38B4276F42DC@bengler.no> <1420564837.32621.30.camel@edumazet-glaptop2.roam.corp.google.com> <8C4F7938-DCA1-46F5-A3C9-7DF62511DEE7@bengler.no> <CAK6E8=d5Z0W5sSAdeEcecKbqjj_UwGw4949=a20fetFpLVKwwA@mail.gmail.com> <03FC652E-AA01-42C7-BD52-019B6D922A9C@bengler.no> <CAK6E8=cP0BFUob5MVj9M0hC0efgRnUY=JMUPKee+v-4TLvHBgg@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 8.1 \(1993\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:38291 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932165AbbAFTmT convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2015 14:42:19 -0500
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id 707FB20BCF
	for <netdev@vger.kernel.org>; Tue,  6 Jan 2015 14:42:18 -0500 (EST)
In-Reply-To: <CAK6E8=cP0BFUob5MVj9M0hC0efgRnUY=JMUPKee+v-4TLvHBgg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On 06 Jan 2015, at 19:18, Yuchung Cheng <ycheng@google.com> wrote:
>=20
> On Tue, Jan 6, 2015 at 11:01 AM, Erik Grinaker <erik@bengler.no> wrot=
e:
>>=20
>>> On 06 Jan 2015, at 18:33, Yuchung Cheng <ycheng@google.com> wrote:
>>>=20
>>> On Tue, Jan 6, 2015 at 10:17 AM, Erik Grinaker <erik@bengler.no> wr=
ote:
>>>>=20
>>>>> On 06 Jan 2015, at 17:20, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
>>>>> On Tue, 2015-01-06 at 16:11 +0000, Erik Grinaker wrote:
>>>>>>> On 06 Jan 2015, at 16:04, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
>>>>>>> On Tue, 2015-01-06 at 15:14 +0000, Erik Grinaker wrote:
>>>>>>>> (CCing Yuchung, as his name comes up in the relevant commits)
>>>>>>>>=20
>>>>>>>> After upgrading from Ubuntu 12.04.5 to 14.04.1 we have begun s=
eeing
>>>>>>>> intermittent TCP connection hangs for HTTP image requests agai=
nst
>>>>>>>> Amazon S3. 3-5% of requests will suddenly stall in the middle =
of the
>>>>>>>> transfer before timing out. We see this problem across a range=
 of
>>>>>>>> servers, in several data centres and networks, all located in =
Norway.
>>>>>>>>=20
>>>>>>>> A packet dump [1] shows repeated ACK retransmits for some of t=
he
>>> TCP does not retransmit ACK ... do you mean DUPACKs sent by the rec=
eiver?
>>=20
>> Ah, sorry, they are indeed DUPACKs; I thought they were the same thi=
ng.
>>=20
>>> I am trying to understand the problem. Could you confirm that it's =
the
>>> HTTP responses sent from Amazon S3 got stalled, or HTTP requests se=
nt
>>> from the receiver (your host)?
>>=20
>> Yes. We run HTTP GET requests against S3 for images (typically a few=
 megs in size). Once in a while, the response transfer stalls about hal=
fway through, until the client (Curl) times out. The packet dump shows =
loads of DUPACKs early on, then TCP retransmissions until the connectio=
n is closed.
>=20
> Without SACK, the sender uses NewReno fast recovery and recovers one
> packet per RTT. In contrast, SACK-based fast recovery can potentially
> recover all lost packets in one RTT.

The transfer on the functioning Netherlands server does indeed use SACK=
s, while the Norway servers do not.

=46or what it=E2=80=99s worth, I have made stripped down pcaps for a si=
ngle failing transfer as well as a single functioning transfer in the N=
etherlands:

http://abstrakt.bengler.no/tcp-issues-s3-failure.pcap.bz2
http://abstrakt.bengler.no/tcp-issues-s3-success-netherlands.pcap.bz2


> I still can't explain the problem seen on newer kernel. But that got
> to be some receiver related changes, not
> 0f7cc9a3c2bd89b15720dbf358e9b9e62af27126 b/c it's a sender side
> change.

Yeah, I=E2=80=99m not really sure what exactly in 3.12.0 is causing it,=
 that just seemed like a possible candidate to my untrained eye.


>>> btw I suspect some middleboxes are stripping SACKOK options from yo=
ur
>>> SYNs (or Amazon SYN-ACKs) assuming Amazon supports SACK.
>>=20
>> That may be. I just tested this on a server in the Netherlands, and =
I can not reproduce the problem there, while I can reproduce it from mu=
ltiple locations and ISPs in Norway. Would it be helpful to have a pack=
et dump from the functioning Netherlands server as well?
>=20
>=20
>>=20
>>=20
>>>>>>>> requests. Using Ubuntu mainline kernels, we found the problem =
to have
>>>>>>>> been introduced between 3.11.10 and 3.12.0, possibly in
>>>>>>>> 0f7cc9a3c2bd89b15720dbf358e9b9e62af27126. The problem is also =
present
>>>>>>>> in 3.18.1. Disabling tcp_window_scaling seems to solve it, but=
 has
>>>>>>>> obvious drawbacks for transfer speeds. Other sysctls do not se=
em to
>>>>>>>> affect it.
>>>>>>>>=20
>>>>>>>> I am not sure if this is fundamentally a kernel bug or a netwo=
rk
>>>>>>>> issue, but we did not see this problem with older kernels.
>>>>>>>>=20
>>>>>>>> [1] http://abstrakt.bengler.no/tcp-issues-s3.pcap.bz2
>>>>>>>=20
>>>>>>>=20
>>>>>>> CC netdev
>>>>>>>=20
>>>>>>> This looks like the bug we fixed here :
>>>>>>>=20
>>>>>>> http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/=
commit/?id=3D39bb5e62867de82b269b07df900165029b928359
>>>>>>=20
>>>>>> Has that patch gone into a release? Because the problem persists=
 with 3.18.1.
>>>>>=20
>>>>> Patch is in 3.18.1 yes.
>>>>>=20
>>>>> So thats a separate issue.
>>>>>=20
>>>>> Can you confirm pcap was taken at receiver (195.159.221.106), not=
 sender
>>>>> (54.231.136.74) , and on which host is running the 'buggy kernel'=
 ?
>>>>=20
>>>> Yes, pcap was taken on receiver (195.159.221.106).
>>>>=20
>>>>> If the sender is broken, changing the kernel on receiver wont hel=
p.
>>>>>=20
>>>>> BTW not using sack (on 54.231.132.98) is terrible for performance=
 in
>>>>> lossy environments.
>>>>=20
>>>> It may well be that the sender is broken; however, the sender is A=
mazon S3, so I do not have any control over it. And in any case, the pr=
oblem goes away with 3.11.10 on receiver, but persists with 3.12.0 (or =
later) on receiver, so there must be some change in 3.12.0 which has ca=
used this to trigger.
>>>>=20
>>>> If you are confident that the problem is with Amazon, I can get in=
 touch with their engineering department.
