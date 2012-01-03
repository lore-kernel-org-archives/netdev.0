From: Rick Jones <rick.jones2@hp.com>
Subject: Re: TCP communication for raw image transmission
Date: Tue, 03 Jan 2012 14:35:39 -0800
Message-ID: <4F0382BB.5060601@hp.com>
References: <CAL8zT=iSiKZfENdtng9gDtuRSuFNn4WZ69uuGapLVVEduFRVyQ@mail.gmail.com> <1325519943.2375.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <CAL8zT=giNe46FYQYxPkbshVfyG-DvCTKS0RLdiN8Kz+e-x-JFw@mail.gmail.com> <1325521745.18116.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <CAL8zT=gbCmtNpw1Lot0P7zB+b_Kw911jhxsXCzO3JOBmMLRcFg@mail.gmail.com> <1325523137.18116.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Jean-Michel Hautbois <jhautbois@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:9630 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755043Ab2ACWfl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 17:35:41 -0500
In-Reply-To: <1325523137.18116.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/02/2012 08:52 AM, Eric Dumazet wrote:
> Le lundi 02 janvier 2012 =C3=A0 17:40 +0100, Jean-Michel Hautbois a =C3=
=A9crit :
>
>> Mmmh, using netperf you would like to know what the client (my ARM
>> board) can do ?
>> How would you test it ? I can have an ARM board on one side, and the
>> x86 on the other...
>>
>
> x86>  netserver&
> arm>  netperf -H<arm_ip_address>  -l 60 -t TCP_STREAM
>
> 1) check cpu usage on<arm>  while test is running
> (for example : vmstat 1 )
> 2) check bandwith of test run

The "&" at the end of the netserver command is (should be) redundant -=20
netserver will by default daemonize itself.

I would suggest amending the netperf command line to something more lik=
e:

netperf -H <x86IP> -c -l 60 -t TCP_STREAM -- -m <dataofoneline> -D

Which will cause netperf to make "send" calls of <dataofoneline> bytes=20
(substitute dataoftwolines if you like).

The -D is to disable Nagle, which you will need to do if you really=20
really want to have only one line of the picture per TCP segment.  Even=
=20
then though, the streaming nature of TCP means you don't "really" know=20
that it will go out that way onto the network.  Otherwise, leave it off=
=20
and TCP will attempt to aggregate the sends into maximum segment sized=20
segments.

The -c is to get netperf to report CPU utilization for the local/netper=
f=20
side.

As Eric suggests, you really should just hand as much data to TCP at on=
e=20
time as you reasonably can within the constraints of the rest of your=20
application

Skipping ahead a little, on the netperf side at least you might be well=
=20
served to do:

netstat -s > before
netperf ....
netstat -s > after
beforeafter before after > delta

and then run "before" and "after" through "beforeafter" from=20
ftp://ftp.cup.hp.com/dist/networking/tools or something similar - I=20
think someone (here on netdev?) created a more robust version at some=20
point.  Alas, beforeafter will sometimes get confused if a new statisti=
c=20
appears in after that was not present in before - the utility was=20
initially developed on HP-UX, the netstat of which does not have the=20
"only display non-zero values" mindset.

One other thing - your 100 Mbit/s link - is that full duplex or half?=20
If half you may need to be concerned with "capture effect."  Briefly, i=
t=20
was a CSMA/CD behaviour which emerged once systems were fast enough to=20
saturate the Ethernet link - the transmitting station would "capture"=20
the wire (half-duplex) and the receiving station, which was still tryin=
g=20
to transmit ACKs would end-up backing-off (at the PHY/data link).  Then=
=20
the transmitter would stop transmitting, having run-out of window, but=20
the receiver's NIC would still be backed-off and so the link would go=20
idle.  The workaround was to either have a rather large or rather small=
=20
(8KB, IIRC but best do some web searchings - this topic goes back to th=
e=20
1990s) TCP window.

happy benchmarking,

rick jones
