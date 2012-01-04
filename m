From: Dave Taht <dave.taht@gmail.com>
Subject: Re: [RFC] SFQ planned changes
Date: Wed, 4 Jan 2012 08:56:05 +0100
Message-ID: <CAA93jw6g1se3pfC8qzvDKnp9N8x0wRhdBActr0Og8rHaHvdAMQ@mail.gmail.com>
References: <1325385056.4174.51.camel@denise.theartistscloset.com>
	<21734335.uCtjXOcSpA@alaris>
	<CAA93jw5NYChp+hKWjOWiw7SnGhNe+REofr2KM-85GnKNVpkw6w@mail.gmail.com>
	<1325587235.2320.37.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<CAA93jw5T10PHD+YQQjy_r=LHKVbYeiWerwM0ou7HANGoenFRKw@mail.gmail.com>
	<1325595036.2320.43.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1325606918.2320.84.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<CAA93jw427XZj17CtAavJCiZDgPqYu4S5v_fZzoYuZ+p5KbyWAg@mail.gmail.com>
	<1325636098.30256.12.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?Q?Michal_Kube=C4=8Dek?= <mkubecek@suse.cz>,
	netdev@vger.kernel.org,
	"John A. Sullivan III" <jsullivan@opensourcedevel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:45163 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751633Ab2ADH4G convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2012 02:56:06 -0500
Received: by iaeh11 with SMTP id h11so32172107iae.19
        for <netdev@vger.kernel.org>; Tue, 03 Jan 2012 23:56:05 -0800 (PST)
In-Reply-To: <1325636098.30256.12.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 4, 2012 at 1:14 AM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> Le mercredi 04 janvier 2012 =E0 00:57 +0100, Dave Taht a =E9crit :
>> On Tue, Jan 3, 2012 at 5:08 PM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:
>> > Here is the code I ran on my test server with 200 netperf TCP_STRE=
AM
>> > flows with pretty good results (each flow gets 0.5 % of bandwidth)
>>
>> Can I encourage you to always simultaneously run a fping and/or a
>> netperf -t TCP_RR
>>

So I sat down and setup something that could do gigE and exercise
everything I had lying around worth playing with to see what crashed...

> a ping on idle link :
> #  ping -c 20 192.168.20.112
> PING 192.168.20.112 (192.168.20.112) 56(84) bytes of data.

> 64 bytes from 192.168.20.112: icmp_req=3D1 ttl=3D64 time=3D0.119 ms
> 64 bytes from 192.168.20.112: icmp_req=3D2 ttl=3D64 time=3D0.090 ms
> 64 bytes from 192.168.20.112: icmp_req=3D3 ttl=3D64 time=3D0.085 ms
> 64 bytes from 192.168.20.112: icmp_req=3D4 ttl=3D64 time=3D0.087 ms

I find puzzling that my baseline ping time is nearly 3x yours.

I guess this is the price I pay for a 680mhz box on the other end.

My baseline ping (1 hop e1000e to router)

64 bytes from 172.30.50.1: icmp_req=3D18 ttl=3D64 time=3D0.239 ms
64 bytes from 172.30.50.1: icmp_req=3D19 ttl=3D64 time=3D0.247 ms
64 bytes from 172.30.50.1: icmp_req=3D20 ttl=3D64 time=3D0.301 ms

(or, in my data format)

|T|172.30.50.1  |172.30.47.1  |172.30.47.27 |
|-+-+-+-+|
|1|0.34|0.63|0.59|
|2|0.28|0.42|0.45|
|3|0.39|0.41|0.48|
|4|0.37|0.42|0.51|
|5|0.33|0.43|0.49|


your load test:

> # ping -c 20 192.168.20.112
> PING 192.168.20.112 (192.168.20.112) 56(84) bytes of data.
> 64 bytes from 192.168.20.112: icmp_req=3D1 ttl=3D64 time=3D0.251 ms
> 64 bytes from 192.168.20.112: icmp_req=3D2 ttl=3D64 time=3D0.123 ms
> 64 bytes from 192.168.20.112: icmp_req=3D3 ttl=3D64 time=3D0.124 ms

This was my complex qfq/sfq test that ran all night (somehow), at gigE.

STAQFQ is on on the source laptop, 100 iperfs in play, 600 seconds
at a time, net transfer rate
about 250Mbit.... - and I rate limited BQL to 9000 limit_max.
GSO/TSO are off throughout

(STAQFQ is 514 QFQ bins, 24 pfifo_fast qdiscs per)

first router has staqfq on the external interface connected to laptop #=
1
sfq on the internal interface connected to router #2

router #2 had sfq on it's external interface and internal interface

laptop #2 had pfifo_fast on it

|count|e1000e to router|to next router|through next router's switch to
laptop #2|
|100|0.40|0.42|0.57|
|101|0.49|0.48|0.54|
|102|0.59|0.65|0.73|
|103|0.48|0.59|0.83|
|104|0.36|0.56|0.75|
|105|0.51|0.63|0.66|
|106|0.41|0.60|0.40|
|107|0.62|0.44|0.81|
|108|0.33|0.36|0.79|
|109|0.49|0.49|0.49|
|110|0.48|0.42|0.54|

Three notes of interest while I sort through this:

1) I saw spikes of up to 12ms with BQL's limiter enabled at one point
or another.
I'll try to duplicate that.
2) I did manage to crash QFQ multiple times earlier in the night
(on every interface that has sfq on it now)
3) And when the ping ends up in the wrong bin, the results can be inter=
esting.

|125|0.56|98.91|0.55|
|126|0.41|96.54|0.52|
|127|0.35|96.11|0.91|
|128|0.23|106.52|0.57|
|129|0.42|104.01|0.83|
|130|0.44|105.92|0.59|

4) there was packet loss (yea!) and many other anomalies, I ran each te=
st for
600 seconds, need to look at the actual data transferred, and will try
a plot later.

But I can say the 2 day old SFQ stuff stands up to a load test...
And QFQ can do pretty well, too, when not crashing...
I will get to your new patch set over the weekend.

--=20
Dave T=E4ht
SKYPE: davetaht
US Tel: 1-239-829-5608
=46R Tel: 0638645374
http://www.bufferbloat.net
