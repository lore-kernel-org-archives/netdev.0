From: Yuchung Cheng <ycheng@google.com>
Subject: Re: Linux TCP's Robustness to Multipath Packet Reordering
Date: Wed, 27 Apr 2011 14:41:19 -0700
Message-ID: <BANLkTin5dsubSjOhz3enOjubfVVk6uiNbQ@mail.gmail.com>
References: <BANLkTimpgXCpweZKCihCQkLjSZw5zL4=Pg@mail.gmail.com>
 <BANLkTikjcd6ZAF5wH_8CKA_OCrfprGokmw@mail.gmail.com> <BANLkTikoQfbSxnJi_OR+N6sa5iVNcTO6Ug@mail.gmail.com>
 <201104271157.49386.carsten@wolffcarsten.de> <BANLkTimNC9DgWtkTTtjC_v0FsxzvBMsQGw@mail.gmail.com>
 <BANLkTi=i5ZftuL++ORuy=n_yM_futWYoZw@mail.gmail.com> <BANLkTinsHuP3XSSghfpYET=os9VcJ3FRDA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Carsten Wolff <carsten@wolffcarsten.de>,
	John Heffner <johnwheffner@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Zimmermann Alexander <zimmermann@nets.rwth-aachen.de>,
	Lennart Schulte <Lennart.Schulte@comsys.rwth-aachen.de>,
	Arnd Hannemann <arnd@arndnet.de>
To: Dominik Kaspar <dokaspar.ietf@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:42757 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759894Ab1D0Vln convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2011 17:41:43 -0400
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id p3RLffs9001727
	for <netdev@vger.kernel.org>; Wed, 27 Apr 2011 14:41:41 -0700
Received: from yia28 (yia28.prod.google.com [10.243.65.28])
	by wpaz21.hot.corp.google.com with ESMTP id p3RLeHwN023535
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 27 Apr 2011 14:41:40 -0700
Received: by yia28 with SMTP id 28so1040718yia.21
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2011 14:41:40 -0700 (PDT)
In-Reply-To: <BANLkTinsHuP3XSSghfpYET=os9VcJ3FRDA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

AFAIK, FACK is disabled throughout the life of the connection after
sender detects reordering degree > 3.

But Alex said the reordering has some bugs. I suspect these bugs may
affect FACK/sack auto-tuning. Maybe Alex could describe the reordering
bugs?

On Wed, Apr 27, 2011 at 12:56 PM, Dominik Kaspar
<dokaspar.ietf@gmail.com> wrote:
> Hi Yuchung,
>
> Yes, FACK was enabled (as it is by default), but as Alexander already
> pointed out, it should be disabled automatically when TCP detects
> reordering.
>
> However, I am not so sure how well this automatic turning off FACK is
> done by Linux... I see a tendency that in situations with persistent
> packet reordering, TCP with FACK enabled gets a lower performance tha=
n
> if FACK is disabled right from the beginning of a connection.
>
> Greetings,
> Dominik
>
> On Wed, Apr 27, 2011 at 7:39 PM, Yuchung Cheng <ycheng@google.com> wr=
ote:
>> Hi Dominik,
>>
>> On Wed, Apr 27, 2011 at 9:22 AM, Dominik Kaspar <dokaspar.ietf@gmail=
=2Ecom> wrote:
>>>
>>> Hi Carsten,
>>>
>>> Thanks for your feedback. I made some new tests with the same setup=
 of
>>> packet-based forwarding over two emulated paths (600 KB/s, 10 ms) +
>>> (400 KB/s, 100 ms). In the first experiments, which showed a step-w=
ise
>>> adaptation to reordering, SACK, DSACK, and Timestamps were all
>>> enabled. In the experiments, I individually disabled these three
>>> mechanisms and saw the following:
>>>
>>> - Disabling timestamps causes TCP to never adjust to reordering at =
all.
>>> - Disabling SACK allows TCP to adapt very rapidly ("perfect" aggreg=
ation!).
>>
>> Did you enable tcp_fack when sack is enabled? this may make a (big)
>> difference. FACK assumes little network reordering and mark packet
>> losses more aggressively.
>>
>>> - Disabling DSACK has no obvious impact (still a step-wise throughp=
ut).
>>>
>>> Is there an explanation for why turning off SACK can be beneficial =
in
>>> the presence of packet reordering? That sounds pretty
>>> counter-intuitive to me... I thought SACK=3D1 always performs bette=
r
>>> than SACK=3D0. The results are also illustrated in the following pl=
ot.
>>> For each setting, there are three runs, which all exhibit a similar
>>> behavior:
>>>
>>> http://home.simula.no/~kaspar/static/mptcp-emu-wlan-hspa-02-sack.pn=
g
>>>
>>> Greetings,
>>> Dominik
>>>
>>> On Wed, Apr 27, 2011 at 11:57 AM, Carsten Wolff <carsten@wolffcarst=
en.de> wrote:
>>> > Hi all,
>>> >
>>> > On Tuesday 26 April 2011, John Heffner wrote:
>>> >> First, TCP is definitely not designed to work under such conditi=
ons.
>>> >> For example, assumptions behind RTO calculation and fast retrans=
mit
>>> >> heuristics are violated. =A0However, in this particular case my =
first
>>> >> guess is that you are being limited by "cwnd moderation," which =
was
>>> >> the topic of recent discussion here. =A0Under persistent reorder=
ing,
>>> >> cwnd moderation can inhibit the ability of cwnd to grow.
>>> >
>>> > it's not just cwnd moderation (of which I'm still in favor, even =
though I lost
>>> > the argument by inactivity ;-)).
>>> >
>>> > Anyway, there are a lot of things in reordering handling that can=
 be improved.
>>> > Our group (Alexander, Lennart, Arnd, myself and others) has worke=
d on the
>>> > problem for a long time now. This work resulted in an algorithm t=
hat is in
>>> > large parts TCP-NCR (RFC4653), but also utilizes information gath=
ered by
>>> > reordering detection for determination of a good DupThresh, fixes=
 a few
>>> > problems in RFC4653 and improves on the reordering detection in L=
inux when the
>>> > connection has no timestamps option. We implemented "pure" TCP-NC=
R and our own
>>> > variant in Linux using a modular framework similar to the congest=
ion control
>>> > modules. A lot of measurements and evaluation have gone into the =
comparison of
>>> > the three algorithms. We are now very close(TM) to a final patch,=
 that is more
>>> > suited for publication on this list and integrates our algorithm =
into tcp*.
>>> > [hc] without introducing the overhead of that modular framework.
>>> >
>>> > Greetings,
>>> > Carsten
>>> >
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe netdev" i=
n
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.htm=
l
>>
>
