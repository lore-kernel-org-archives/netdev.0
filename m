From: Tom Herbert <therbert@google.com>
Subject: Re: tx-nocache-copy performance
Date: Mon, 6 Jan 2014 12:59:59 -0800
Message-ID: <CA+mtBx_RH3v92Pmd_TYM=i0Anx-iG63762NPRSeCc1k98-Q6UQ@mail.gmail.com>
References: <20140106202754.GA5877@d2.synalogic.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Benjamin Poirier <bpoirier@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:33846 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755092AbaAFVAA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jan 2014 16:00:00 -0500
Received: by mail-ie0-f182.google.com with SMTP id as1so19288051iec.41
        for <netdev@vger.kernel.org>; Mon, 06 Jan 2014 13:00:00 -0800 (PST)
In-Reply-To: <20140106202754.GA5877@d2.synalogic.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 6, 2014 at 12:27 PM, Benjamin Poirier <bpoirier@suse.de> wr=
ote:
> Hi Tom,
>
> In commit "c6e1a0d net: Allow no-cache copy from user on transmit
> (v3.0-rc1)" you introduced the tx-nocache-copy performance optimizati=
on
> and set it to on by default. I've tried to reproduce your testcase, a=
s
> well as a few more, but I did not find any performance improvement fr=
om
> turning on tx-nocache-copy. Do you think tx-nocache-copy is still a
> worthwhile optimization and it should remain on by default? In which
> situations does it help?
>
Unfortunately, I think this is probably not a worthwhile optimization
at this point. The benefits should manifest themselves under high
networking load and high CPU load where we are getting a lot of
pressure on the cache, the non-temporal copy should alleviate that
case. In reality, I suspect that rep movsq is more efficient that
movntq's so the advantages of skipping the cache might be wiped out.
It would be nice if Intel had a movntsq instruction!

btw, I still believe it would be a win if we could use vmsplice to
mitigate the copy altogether, unfortunately no one has yet to come up
with an interface to reliably reclaim buffers :-(.

> I've ran latency tests similar to the ones you described in the commi=
t
> log. I've also tested how the option affects single stream throughput
> tests. According to the results I obtained, it seems that
> tx-nocache-copy has either no impact (in the latency test) or a negat=
ive
> impact (in the throughput test).
>
> My test results follow. I tested using 3.12.6 on one Intel Xeon W3565
> and one i7 920 connected by ixgbe adapters. The results are from the
> Xeon, but they're similar on the i7. All numbers report the mean=C4=85=
stddev
> over 10 runs of 10s.
>
> 1) latency tests similar to what you described
> There is no statistically significant difference between tx-nocache-c=
opy
> on/off.
> nic irqs spread out (one queue per cpu)
>
> 200x netperf -r 1400,1
> tx-nocache-copy off
>         692000=C4=851000 tps
>         50/90/95/99% latency (us): 275=C4=852/643.8=C4=850.4/799=C4=85=
1/2474.4=C4=850.3
> tx-nocache-copy on
>         693000=C4=851000 tps
>         50/90/95/99% latency (us): 274=C4=851/644.1=C4=850.7/800=C4=85=
2/2474.5=C4=850.7
>
> 200x netperf -r 14000,14000
> tx-nocache-copy off
>         86450=C4=8580 tps
>         50/90/95/99% latency (us): 334.37=C4=850.02/838=C4=851/2100=C4=
=8520/3990=C4=8540
> tx-nocache-copy on
>         86110=C4=8560 tps
>         50/90/95/99% latency (us): 334.28=C4=850.01/837=C4=852/2110=C4=
=8520/3990=C4=8520
>
> 2) single stream throughput tests
> tx-nocache-copy leads to higher service demand
>
>                         throughput  cpu0        cpu1        demand
>                         (Gb/s)      (Gcycle)    (Gcycle)    (cycle/B)
>
> nic irqs and netperf on cpu0 (1x netperf -T0,0 -t omni -- -d send)
>
> tx-nocache-copy off     9402=C4=855      9.4=C4=850.2                =
 0.80=C4=850.01
> tx-nocache-copy on      9403=C4=853      9.85=C4=850.04              =
 0.838=C4=850.004
>
> nic irqs on cpu0, netperf on cpu1 (1x netperf -T1,1 -t omni -- -d sen=
d)
>
> tx-nocache-copy off     9401=C4=855      5.83=C4=850.03   5.0=C4=850.=
1     0.923=C4=850.007
> tx-nocache-copy on      9404=C4=852      5.74=C4=850.03   5.523=C4=85=
0.009 0.958=C4=850.002
>
> -Benjamin
