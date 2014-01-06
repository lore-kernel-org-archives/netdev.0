From: Benjamin Poirier <bpoirier@suse.de>
Subject: tx-nocache-copy performance
Date: Mon, 6 Jan 2014 15:27:54 -0500
Message-ID: <20140106202754.GA5877@d2.synalogic.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:45512 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756036AbaAFU2C (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jan 2014 15:28:02 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tom,

In commit "c6e1a0d net: Allow no-cache copy from user on transmit
(v3.0-rc1)" you introduced the tx-nocache-copy performance optimization
and set it to on by default. I've tried to reproduce your testcase, as
well as a few more, but I did not find any performance improvement from
turning on tx-nocache-copy. Do you think tx-nocache-copy is still a
worthwhile optimization and it should remain on by default? In which
situations does it help?

I've ran latency tests similar to the ones you described in the commit
log. I've also tested how the option affects single stream throughput
tests. According to the results I obtained, it seems that
tx-nocache-copy has either no impact (in the latency test) or a negativ=
e
impact (in the throughput test).

My test results follow. I tested using 3.12.6 on one Intel Xeon W3565
and one i7 920 connected by ixgbe adapters. The results are from the
Xeon, but they're similar on the i7. All numbers report the mean=B1stdd=
ev
over 10 runs of 10s.

1) latency tests similar to what you described
There is no statistically significant difference between tx-nocache-cop=
y
on/off.
nic irqs spread out (one queue per cpu)

200x netperf -r 1400,1
tx-nocache-copy off
        692000=B11000 tps
        50/90/95/99% latency (us): 275=B12/643.8=B10.4/799=B11/2474.4=B1=
0.3
tx-nocache-copy on
        693000=B11000 tps
        50/90/95/99% latency (us): 274=B11/644.1=B10.7/800=B12/2474.5=B1=
0.7

200x netperf -r 14000,14000
tx-nocache-copy off
        86450=B180 tps
        50/90/95/99% latency (us): 334.37=B10.02/838=B11/2100=B120/3990=
=B140
tx-nocache-copy on
        86110=B160 tps
        50/90/95/99% latency (us): 334.28=B10.01/837=B12/2110=B120/3990=
=B120

2) single stream throughput tests
tx-nocache-copy leads to higher service demand

                        throughput  cpu0        cpu1        demand
                        (Gb/s)      (Gcycle)    (Gcycle)    (cycle/B)

nic irqs and netperf on cpu0 (1x netperf -T0,0 -t omni -- -d send)

tx-nocache-copy off     9402=B15      9.4=B10.2                 0.80=B1=
0.01
tx-nocache-copy on      9403=B13      9.85=B10.04               0.838=B1=
0.004

nic irqs on cpu0, netperf on cpu1 (1x netperf -T1,1 -t omni -- -d send)

tx-nocache-copy off     9401=B15      5.83=B10.03   5.0=B10.1     0.923=
=B10.007
tx-nocache-copy on      9404=B12      5.74=B10.03   5.523=B10.009 0.958=
=B10.002

-Benjamin
