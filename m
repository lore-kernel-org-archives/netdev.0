From: Dominik Kaspar <dokaspar.ietf@gmail.com>
Subject: Re: Linux TCP's Robustness to Multipath Packet Reordering
Date: Wed, 27 Apr 2011 21:56:52 +0200
Message-ID: <BANLkTinsHuP3XSSghfpYET=os9VcJ3FRDA@mail.gmail.com>
References: <BANLkTimpgXCpweZKCihCQkLjSZw5zL4=Pg@mail.gmail.com>
	<BANLkTikjcd6ZAF5wH_8CKA_OCrfprGokmw@mail.gmail.com>
	<BANLkTikoQfbSxnJi_OR+N6sa5iVNcTO6Ug@mail.gmail.com>
	<201104271157.49386.carsten@wolffcarsten.de>
	<BANLkTimNC9DgWtkTTtjC_v0FsxzvBMsQGw@mail.gmail.com>
	<BANLkTi=i5ZftuL++ORuy=n_yM_futWYoZw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Carsten Wolff <carsten@wolffcarsten.de>,
	John Heffner <johnwheffner@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Zimmermann Alexander <zimmermann@nets.rwth-aachen.de>,
	Lennart Schulte <Lennart.Schulte@comsys.rwth-aachen.de>,
	Arnd Hannemann <arnd@arndnet.de>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:44233 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751954Ab1D0T4x convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2011 15:56:53 -0400
Received: by iwn34 with SMTP id 34so1646921iwn.19
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2011 12:56:52 -0700 (PDT)
In-Reply-To: <BANLkTi=i5ZftuL++ORuy=n_yM_futWYoZw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Yuchung,

Yes, FACK was enabled (as it is by default), but as Alexander already
pointed out, it should be disabled automatically when TCP detects
reordering.

However, I am not so sure how well this automatic turning off FACK is
done by Linux... I see a tendency that in situations with persistent
packet reordering, TCP with FACK enabled gets a lower performance than
if FACK is disabled right from the beginning of a connection.

Greetings,
Dominik

On Wed, Apr 27, 2011 at 7:39 PM, Yuchung Cheng <ycheng@google.com> wrot=
e:
> Hi Dominik,
>
> On Wed, Apr 27, 2011 at 9:22 AM, Dominik Kaspar <dokaspar.ietf@gmail.=
com> wrote:
>>
>> Hi Carsten,
>>
>> Thanks for your feedback. I made some new tests with the same setup =
of
>> packet-based forwarding over two emulated paths (600 KB/s, 10 ms) +
>> (400 KB/s, 100 ms). In the first experiments, which showed a step-wi=
se
>> adaptation to reordering, SACK, DSACK, and Timestamps were all
>> enabled. In the experiments, I individually disabled these three
>> mechanisms and saw the following:
>>
>> - Disabling timestamps causes TCP to never adjust to reordering at a=
ll.
>> - Disabling SACK allows TCP to adapt very rapidly ("perfect" aggrega=
tion!).
>
> Did you enable tcp_fack when sack is enabled? this may make a (big)
> difference. FACK assumes little network reordering and mark packet
> losses more aggressively.
>
>> - Disabling DSACK has no obvious impact (still a step-wise throughpu=
t).
>>
>> Is there an explanation for why turning off SACK can be beneficial i=
n
>> the presence of packet reordering? That sounds pretty
>> counter-intuitive to me... I thought SACK=3D1 always performs better
>> than SACK=3D0. The results are also illustrated in the following plo=
t.
>> For each setting, there are three runs, which all exhibit a similar
>> behavior:
>>
>> http://home.simula.no/~kaspar/static/mptcp-emu-wlan-hspa-02-sack.png
>>
>> Greetings,
>> Dominik
>>
>> On Wed, Apr 27, 2011 at 11:57 AM, Carsten Wolff <carsten@wolffcarste=
n.de> wrote:
>> > Hi all,
>> >
>> > On Tuesday 26 April 2011, John Heffner wrote:
>> >> First, TCP is definitely not designed to work under such conditio=
ns.
>> >> For example, assumptions behind RTO calculation and fast retransm=
it
>> >> heuristics are violated. =A0However, in this particular case my f=
irst
>> >> guess is that you are being limited by "cwnd moderation," which w=
as
>> >> the topic of recent discussion here. =A0Under persistent reorderi=
ng,
>> >> cwnd moderation can inhibit the ability of cwnd to grow.
>> >
>> > it's not just cwnd moderation (of which I'm still in favor, even t=
hough I lost
>> > the argument by inactivity ;-)).
>> >
>> > Anyway, there are a lot of things in reordering handling that can =
be improved.
>> > Our group (Alexander, Lennart, Arnd, myself and others) has worked=
 on the
>> > problem for a long time now. This work resulted in an algorithm th=
at is in
>> > large parts TCP-NCR (RFC4653), but also utilizes information gathe=
red by
>> > reordering detection for determination of a good DupThresh, fixes =
a few
>> > problems in RFC4653 and improves on the reordering detection in Li=
nux when the
>> > connection has no timestamps option. We implemented "pure" TCP-NCR=
 and our own
>> > variant in Linux using a modular framework similar to the congesti=
on control
>> > modules. A lot of measurements and evaluation have gone into the c=
omparison of
>> > the three algorithms. We are now very close(TM) to a final patch, =
that is more
>> > suited for publication on this list and integrates our algorithm i=
nto tcp*.
>> > [hc] without introducing the overhead of that modular framework.
>> >
>> > Greetings,
>> > Carsten
>> >
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
