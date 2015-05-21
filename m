From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: ingress policying for realtime protocol
Date: Thu, 21 May 2015 09:36:28 -0400
Message-ID: <555DDF5C.8080503@mojatatu.com>
References: <20150519211145.GA23134@pengutronix.de> <CAHA+R7N8wFKPzOR0EshWzcaTUd+ChMW0zb0=1go4oV_gxoAyiA@mail.gmail.com> <1432168240.4060.63.camel@edumazet-glaptop2.roam.corp.google.com> <20150521070712.GY24769@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Cong Wang <cwang@twopensource.com>, netdev <netdev@vger.kernel.org>
To: =?windows-1252?Q?Uwe_Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:36775 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755025AbbEUNgj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2015 09:36:39 -0400
Received: by igbpi8 with SMTP id pi8so9779367igb.1
        for <netdev@vger.kernel.org>; Thu, 21 May 2015 06:36:38 -0700 (PDT)
In-Reply-To: <20150521070712.GY24769@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/21/15 03:07, Uwe Kleine-K=F6nig wrote:
> On Wed, May 20, 2015 at 05:30:40PM -0700, Eric Dumazet wrote:
>> On Wed, 2015-05-20 at 16:46 -0700, Cong Wang wrote:
>>
>>> There is very little to do on ingress side since there is no queue =
at all,
>>> not to mention priority, you could try ifb to see if it fits your n=
eed.
>>
>> Note that if the need is to police traffic, ifb is not really needed=
 :
>>
>> TC=3D"tc"
>> DEV=3D"dev eth0"
>> IP=3D10.246.11.51/32
>> $TC qdisc del $DEV ingress 2>/dev/null
>> $TC qdisc add $DEV ingress
>> $TC filter add $DEV parent ffff: protocol ip u32 match ip src $IP \
>> 	police rate 1Mbit burst 10Mbit mtu 66000 action drop/continue
>>
>> $TC -s filter ls $DEV parent ffff: protocol ip
> I have something like that (matching on dst mac addresses instead of =
src ip):
>
> 	tc qdisc add dev eth0 handle ffff: ingress
> 	tc filter add dev eth0 parent ffff: protocol all prio 10 u32 match e=
ther dst 01:15:4E:00:00:01 police pass
> 	tc filter add dev eth0 parent ffff: protocol all prio 50 u32 match u=
32 0 0 at 0 police rate 100kbit burst 10k drop
>
> So Cong interpreted my question right and probably I just used the
> wrong keywords to make you understand the same.

I think both Cong and Eric are right.
You wanted to priotize something thats _realtime_ by using queues, so
Cong answered your question with ifb which will provide you a queue on
ingress.
OTOH, You should really avoid queues of any sort if latency is
important to you - hence what Eric said is correct. Jitter will occur
when it matters the most for you i.e when congestion kicks in; otherwis=
e
it will work (when there is no congestion;->)

So your requirements are conflicting and the result is two talented
people are intepretting things differently;->

So some questions to you:
Why is there a 100Kbps limit for everything else? If it has to be at
100Kbps, what is wrong with the policy you have?

 From my quick reading is it seems this thing has a state machine infac=
t
where sometimes you have to drop all other packets and when the state
machine transitions to a stable state then you just want to accept all
packets but prioritize its protocol packets. Also the state machine
seems to involve more than one port (for path redundancy reasons).
So where is this rate control coming from?

cheers,
jamal
