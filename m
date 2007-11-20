From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: Re: HTB/HSFC shaping precision
Date: Tue, 20 Nov 2007 11:43:28 +0200
Message-ID: <20071120092317.M96721@visp.net.lb>
References: <20071119083849.M87605@visp.net.lb> <1195489494.4445.119.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:42248 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750797AbXKTJnj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 04:43:39 -0500
In-Reply-To: <1195489494.4445.119.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I wish i can setup soon my own lab (getting finally my personal room in 
company).

About CBQ, i didn't use it since long time. There is anything good in it?

What is interesting i did few tests with iperf as example, and what i found 
out:
iperf running 60 seconds with 1Mbit bandwidth set (iperf -c 192.168.0.1 -u -b 
1M -t 60) in shaper: 7718892 bytes passed(confirmed in two tests), what is 
128648.2 bytes/second 
If it is counting by IEC standarts - it will be 7500000 bytes. If pre-IEC 
(1024 divider) - 7864320. 
It seems iperf running pre-IEC standarts, with precision -1.84% on 60 seconds.

With 240 seconds duration iperf sent 30861564 bytes what is 128589/second and 
it has to be 31457280. What means again precision is -1.89% 

With 120 seconds and 10Mbit/s send 154269492, which is 1285579.1 b/s and it 
has to be 1310720 b/s or 157286400, as result precision is -1.918%

And thats amazing. ISP provide me 88Mbps link, sure it is set on new IEC 
standarts, means 88000000 bps,  and they test iperf and not able to get more 
than 85Mbps. That time we count it is overhead, and not a big deal. But... 
after all 3Mbps - it is more than $3k bucks. And i set 85Mbps in QoS (to 
avoid packetloss), because iperf gave me result that 85 only works fine. And 
iproute2 for example fully conform standarts (and 1Mbits = 1000000 bps) . I 
must blame only my stupidiness, that i didn't look to code of iperf. Except 
standarts issue, it is also seems have issue with timers and bandwidth 
precision.

And i am absolutely not sure, how iperf sending traffic, bursty or in regular 
intervals. Probably i must check also each traffic simulation program, cause 
it is very important to measure how shaper working in real life (not only 
theory) - to have precise packet generator.

Probably i will try to setup my own application(with realtime priority) based 
on  libpcap and realtime kernel(?), and will log each packet with timestamp. 
Not sure in details, how i will get high precision timers in userspace, 
especially cause i am not developer, and wrote only few trivial libpcap 
applications,since on bandwidth 30-40 megs - let's say iptraf and trafshow 
very unprecide,but i will try. Also i think if i will put sequence number, 
and later i will dump all this things (packet sequence number and arrival 
time) in file, i can have good picture - how shaper is working and what is a 
precision. Sure i must count also on PCI/PCI-X/PCI-express bus latency and 
other things. For now no idea how i will do that :-)
Sure i will try to test on both - HPET and TSC.

If let's say i will limit bandwidth to 1Mbps, and will try to send packets 
will 100Mbps speed, and will check which packets will be dropped.


For me HFSC and HTB looks much more clear in setup.
But what is worrying me a lot, with clear "bandwidth tree" setup, let's say 
to 88Mbit/s, in case of some kind of DDoS, even if i set overhead value and 
it is matching media overhead, my bandwidth still going out of limits. And 
sure link is going down, even hardware used on QoS server able to withstand 
this attack. This means something wrong or in my shaping tree configuration 
(that time HTB) or in shaper code. Thats why i try to dig in this things more 
deeply.

On Mon, 19 Nov 2007 11:24:54 -0500, jamal wrote
> Denys,
> 
> You certainly make a very compelling case. It is always compelling if
> you can translate a bug/feature into $$;->.
> 
> So in your measurements, what kind of clock sources did you use?
> I think the parameters to worry about are: packet size, rate and 
> clock source. I know that based on very old measurements i did on 
> CBQ, regardless of the clock source if you have a long-lived flow 
> the bandwidth measurement corrects itself. I wouldnt recommend going 
> to CBQ, but a good start is to test and post some results.
> 
> cheers,
> jamal
> 
> On Mon, 2007-19-11 at 10:55 +0200, Denys Fedoryshchenko wrote:
> > Hi 2 all again
> > 
> > This is not a bug report this time :-) 
> > Just it is very interesting question, about using Linux "shaping" 
technologies
> > in serious jobs.
> > 
> > What i realised few days ago, many ISP's set on their STM-1(155520000 
bits/s)
> > links (over Cisco) packet buffer/queue 40 packets(for example).
> > It means 103680  pps with 1500 byte packets,  and if buffer is only 40
> > packets, it means it require at least 0.3ms scheduler precision? 
Otherwise i
> > can have buffer overflow and as result packetloss(what is much worse than
> > delay in most of situations).
> > 
> > What i am interested - to utilise such links nearby 100%. So anything not
> > precise will kill idea.
> > Thats important, cause price for links in my area is about $1000-$1500 
Mbit/s,
> > and just 1% lost/not utilised on STM-1 is up to $2325/USD lost per month.
> > I have to count also overhead, LAN jitter, and etc.
> > 
> > As far as i test, on HFSC if i set dmax 1ms-10ms it works much better (i 
am
> > talking about precision) than HTB with quantum 1514 (it is over 
ethernet). 
> > 
> > Anybody have ideas what is the precision of bandwidth shaping in HFSC/HTB?
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

