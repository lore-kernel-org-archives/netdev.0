From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next] mlx4: do not fire tasklet unless necessary
Date: Mon, 20 Feb 2017 00:33:28 +0200
Message-ID: <CALzJLG_NyUBPtyCxxjAqkAthJ9c3qAh1N=e=fhfFeL-51XfEcw@mail.gmail.com>
References: <1486729678.7793.139.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALzJLG9HWiNfGaWF_uB6F0BttPbzc_eSpow_zv7FwiK3GWoYQA@mail.gmail.com>
 <1487165355.1311.2.camel@edumazet-glaptop3.roam.corp.google.com>
 <1487167443.1311.8.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALzJLG8WHJYQFEsxU39jgpMDFHPkHuDX6VU7vOcd+wqBedonfA@mail.gmail.com>
 <1487260187.1311.53.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALzJLG_w2m9p3OQxi9c9=Y-RVKKLyce1b-WjoSvLUVGcWHNwYA@mail.gmail.com> <1487286833.1311.63.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Matan Barak <matanb@mellanox.com>, jackm@mellanox.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:35586 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751717AbdBSWdt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 19 Feb 2017 17:33:49 -0500
Received: by mail-qk0-f195.google.com with SMTP id n127so1281742qkf.2
        for <netdev@vger.kernel.org>; Sun, 19 Feb 2017 14:33:49 -0800 (PST)
In-Reply-To: <1487286833.1311.63.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 17, 2017 at 1:13 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2017-02-16 at 23:17 +0200, Saeed Mahameed wrote:
>
>> so i guess you are not busy polling .. and adaptive moderation decided
>> to lower down
>> rx-usecs for you, and you are looking to improve latency.
>>
>> > Interrupt moderation is a latency killer, we want our usec back.
>> >
>>
>> well, for RX we have adaptive moderation.
>> and for TX we have xmit more.
>> so interrupt moderation can be good if it is done right.
>>
>> do i understand from this that you are against interrupt moderation ?
>
> Absolutely against it. We prefer gro_flush_timeout.
>
> The defaults values in mlx4 never were tuned for 40Gbit.
>
> If you want to be able to reach 40Gbit on a single TCP flow, you want :
>
> ethtool -C ethX rx-frames 16 rx-usecs-high 32
>
> Or disable interrupt mitigation of course.
>
>
> Interrupt moderation comes for free with NAPI really :
>
> If under stress, number of interrupts will naturally decrease,
> so what's the point with hardware _delaying_ an incoming packet
> exactly ???
>

Theoretically NAPI provides some kind of interrupt delaying mechanism
(only under stress), but is it as good as explicit HW interrupt
moderation ?

for example in mlx5 the adaptive mechanism is more intelligent than
the one we have in mlx4.
it always tries to improve BW/packet rate, and reduce # of interrupts
per second.
and it will park at the optimal values.

As you know the less the interrupts overhead the better the latency.

I assume there are many cases where napi will not be good enough and
will keep running at max interrupt rate.
while the above mechanism will deliberately look for and find a better
interrupt rate for at least the same packet rate or even better one.
(Napi will not do that for you).

But we will have to measure before we decide napi as is is good enough.

> BTW interrupt moderation in mlx4 has at least two bugs.
>
> I will send a patch.

Saw it, nice catch !!
