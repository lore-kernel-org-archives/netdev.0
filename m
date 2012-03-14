From: Dave Taht <dave.taht@gmail.com>
Subject: Re: [PATCH] sch_sfq: revert dont put new flow at the end of flows
Date: Wed, 14 Mar 2012 17:22:52 +0000
Message-ID: <CAA93jw67JfUXvZZxs8TGHJ23UBsBkedo2-Ve3u9ufF1ob3FpRQ@mail.gmail.com>
References: <1327570722.8191.46.camel@probook>
	<1331697865.2456.19.camel@edumazet-laptop>
	<CAA93jw4kYqCWg424SXkrtQeg9bPfpfgH-x_7tjg=m8uxk_GNaA@mail.gmail.com>
	<1331724732.7651.58.camel@probook>
	<1331733899.2456.66.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jdb@comx.dk, David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Jesper Dangaard Brouer <netoptimizer@brouer.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:45082 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755051Ab2CNRWx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Mar 2012 13:22:53 -0400
Received: by wibhj6 with SMTP id hj6so7516752wib.1
        for <netdev@vger.kernel.org>; Wed, 14 Mar 2012 10:22:52 -0700 (PDT)
In-Reply-To: <1331733899.2456.66.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 14, 2012 at 2:04 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le mercredi 14 mars 2012 =E0 12:32 +0100, Jesper Dangaard Brouer a =E9=
crit :
>> ons, 14 03 2012 kl. 04:52 +0000, skrev Dave Taht:
>> > On Wed, Mar 14, 2012 at 4:04 AM, Eric Dumazet <eric.dumazet@gmail.=
com> wrote:
>
>> > As the depth of the sfq queue increases it gets increasingly hard =
to
>> > trigger the problem. I've been using values in the 200-300 range, =
and
>> > in combination with red, haven't seen it happen.
>>
>> I don't think you should adjust the "depth", but instead "limit" or
>> "flows".

Sorry, I'd meant 'limit' above, with limiting the per flow depth (at
4Mbit depths of 12-24 are good + red doing byte limiting starting at
3000), and having lots of flows in the hash....

Anyway, as this change to sfq currently has pathological edge cases, I =
suggest:

1) reverting this patch (the new features of sfq - hugely increased
number of flows, and increased limit, head drop/marking support, red,
ecn, etc, can stay - and are rather nice in and of themselves)

2) trying again, but not in the context of sfq - starting with sfq as
a base, with a copy and rename, getting the iproute infrastructure
around it working, more thorough tests going. I'll note that while
flow management is needed, it needent be red-based.

nsfq? efq?


>>
>> The problem can be solved by SFQ parameter tuning. =A0Perhaps, we co=
uld
>> just change the default parameters?

I can't think of a way to make existing users of sfq not hit this probl=
em
if they are overriding the default params in the first place. thus my
suggestion we start again in a new namespace.

>> The problem occurs when all flows have ONE packet, then sfq_drop()
>> cannot find a good flow to drop packets from...
>>
>> This situation can occur because the default setting is "limit=3D127=
"
>> packets and "flows=3D127". =A0If we just make sure that "limit" > "f=
lows",
>> then one flow with >=3D2 packets should exist, which is then chosen =
for
>> drop.
>> My practical experiments show that "limit" should be between 10-20
>> packets larger than "flows" (I'm not completely sure why this is
>> needed).

flows and/or depth?

if flows, then we could drop the flows parameter entirely and just use =
limit
to calculate flows. But I think that it's more subtle than just this.

more thorough tests exploring the pathological cases are needed. I'm on=
 it.

>>
>
> There are many ways to starve SFQ if we dont revert the patch or add =
new
> logic in linux-3.4
>
> Even if we change default settings, we can have following situation :
>
> SFQ in a state with several regular flows in queue, correctly behavin=
g
> because they are nice.
>
> loop repeat_as_many_times_you_can_think
> =A0enqueue : packet comes for a new flow X.
> =A0 =A0 =A0 =A0 =A0 OK lets favor this new flow against 'old' ones.
> =A0dequeue : takes the packet for flow X.
> =A0 =A0 =A0 =A0 =A0 forget about flow X since dequeue all its packets=
=2E
> endloop
>
> All other flows are in a frozen state.

some thoughts

1) Keeping more history around during the next X packet deliveries woul=
d help.
2) in case of being close up against various limits randomly enqueue on=
 tail

I note that htb introduces a window for new flows to win
pathologically by holding onto a packet
which perhaps it should be peeking (or so I understand it)
>
>
>



--=20
Dave T=E4ht
SKYPE: davetaht
US Tel: 1-239-829-5608
http://www.bufferbloat.net
