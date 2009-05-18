From: Antonio Almeida <vexwek@gmail.com>
Subject: Re: HTB accuracy for high speed
Date: Mon, 18 May 2009 15:36:00 +0100
Message-ID: <298f5c050905180736m303f0c79ha30d3f791222fa1b@mail.gmail.com>
References: <298f5c050905150745p13dc226eia1ff50ffa8c4b300@mail.gmail.com>
	 <298f5c050905150749s3597328dr8dd15adbd7a37532@mail.gmail.com>
	 <20090516141430.GB3013@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kaber@trash.net, davem@davemloft.net,
	devik@cdi.cz
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f158.google.com ([209.85.220.158]:54678 "EHLO
	mail-fx0-f158.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752034AbZEROgA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2009 10:36:00 -0400
Received: by fxm2 with SMTP id 2so3278151fxm.37
        for <netdev@vger.kernel.org>; Mon, 18 May 2009 07:36:00 -0700 (PDT)
In-Reply-To: <20090516141430.GB3013@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch works perfectly!
rate (bits/s) is now decreasing along with pps when I stop the traffic
(doesn't grow as it used to for rates over 500Mbtis/s).

# tc -s -d class ls dev eth1 | head -21 | tail -1
 rate 651960Kbit 97482pps backlog 0b 0p requeues 0
 rate 541134Kbit 80911pps backlog 0b 0p requeues 0
 rate 405850Kbit 60683pps backlog 0b 0p requeues 0
 rate 304388Kbit 45512pps backlog 0b 0p requeues 0
 rate 304388Kbit 45512pps backlog 0b 0p requeues 0
 rate 228291Kbit 34134pps backlog 0b 0p requeues 0
 rate 171218Kbit 25601pps backlog 0b 0p requeues 0
 rate 171218Kbit 25601pps backlog 0b 0p requeues 0
 rate 128414Kbit 19201pps backlog 0b 0p requeues 0
 rate 96310Kbit 14400pps backlog 0b 0p requeues 0
 rate 96310Kbit 14400pps backlog 0b 0p requeues 0
 rate 72233Kbit 10800pps backlog 0b 0p requeues 0
 rate 54174Kbit 8100pps backlog 0b 0p requeues 0


Thank's to you!
  Antonio Almeida




On Sat, May 16, 2009 at 3:14 PM, Jarek Poplawski <jarkao2@gmail.com> wr=
ote:
> On Fri, May 15, 2009 at 03:49:31PM +0100, Antonio Almeida wrote:
> ...
>> I also note that, for HTB rate configurations over 500Mbit/s on leaf
>> class, when I stop the traffic, in the output of "tc -s -d class ls
>> dev eth1" command, I see that leaf's rate (in bits/s) is growing
>> instead of decreasing (as expected since I've stopped the traffic).
>> Rate in pps is ok and decreases until 0pps. Rate in bits/s increases
>> above 1000Mbit and stays there for a few minutes. After two or three
>> minutes it becomes 0bit. The same happens for it's ancestors (also f=
or
>> root class).Here's tc output of my leaf class for this situation:
>>
>> class htb 1:108 parent 1:10 leaf 108: prio 7 quantum 1514 rate
>> 555000Kbit ceil 555000Kbit burst 70901b/8 mpu 0b overhead 0b cburst
>> 70901b/8 mpu 0b overhead 0b level 0
>> =A0Sent 120267768144 bytes 242475339 pkt (dropped 62272599, overlimi=
ts 0
>> requeues 0)
>> =A0rate 1074Mbit 0pps backlog 0b 0p requeues 0
>> =A0lended: 242475339 borrowed: 0 giants: 0
>> =A0tokens: 8 ctokens: 8
>
> This looks like a regular bug. I guess it's an overflow in
> gen_estimator(), but I'm not sure there is nothing more. Could you
> try the patch below? (An offset warning when patching 2.6.25 is OK)
>
> Thanks,
> Jarek P.
> ---
>
> =A0net/core/gen_estimator.c | =A0 =A06 +++++-
> =A01 files changed, 5 insertions(+), 1 deletions(-)
>
> diff --git a/net/core/gen_estimator.c b/net/core/gen_estimator.c
> index 9cc9f95..87f0ced 100644
> --- a/net/core/gen_estimator.c
> +++ b/net/core/gen_estimator.c
> @@ -127,7 +127,11 @@ static void est_timer(unsigned long arg)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0npackets =3D e->bstats->packets;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rate =3D (nbytes - e->last_bytes)<<(7 =
- idx);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0e->last_bytes =3D nbytes;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 e->avbps +=3D ((long)rate - (long)e->av=
bps) >> e->ewma_log;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (rate > e->avbps)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 e->avbps +=3D (rate - e=
->avbps) >> e->ewma_log;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 e->avbps -=3D (e->avbps=
 - rate) >> e->ewma_log;
> +
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0e->rate_est->bps =3D (e->avbps+0xF)>>5=
;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rate =3D (npackets - e->last_packets)<=
<(12 - idx);
>
