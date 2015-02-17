From: Holger =?iso-8859-1?q?Hoffst=E4tte?=
	<holger.hoffstaette@googlemail.com>
Subject: r8169: strange increase in ping latency after suspend/resume
Date: Tue, 17 Feb 2015 14:46:13 +0000 (UTC)
Message-ID: <pan.2015.02.17.14.46.13@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:47091 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751665AbbBQOqX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Feb 2015 09:46:23 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1YNjPm-0008FF-UM
	for netdev@vger.kernel.org; Tue, 17 Feb 2015 15:46:18 +0100
Received: from p4ff58072.dip0.t-ipconnect.de ([79.245.128.114])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 17 Feb 2015 15:46:18 +0100
Received: from holger.hoffstaette by p4ff58072.dip0.t-ipconnect.de with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 17 Feb 2015 15:46:18 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


While benchmarking things on my home LAN (wired, 1Gbit) I noticed an
apparent asymmetric network behaviour between two hosts: a flood ping
from a -> b was consistently slower than from b -> a, despite same
kernel (3.18.x), same NIC (even same rev/firmware), same everything, an=
d
even a being the faster machine (8-core i7 desktop vs. low-end 4-core i=
5).

Despite the fact that there are two cheap switches in the path I couldn=
't
figure out why one way would be faster than the other. After many itera=
tions
of eliminating possible causes of my tweaked kernel (with/without BFS C=
PU
scheduler, SMT awareness, offload settings, HZ/NOHZ and whatnot) I foun=
d
that the difference is much more subtle: reboot vs. suspend/resume.

Since I suspend/resume the desktop nightly but not the server, the
behaviour would never become visible in the other direction.

=46rom desktop to server (tux aka. 192.168.100.222), hosts & network id=
le:

$ping -q -c 10000 -i 0 tux

after a reboot:

--- tux ping statistics ---
10000 packets transmitted, 10000 received, 0% packet loss, time 647ms
rtt min/avg/max/mdev =3D 0.038/0.046/0.152/0.004 ms, ipg/ewma 0.064/0.0=
41 ms

--- tux ping statistics ---
10000 packets transmitted, 10000 received, 0% packet loss, time 645ms
rtt min/avg/max/mdev =3D 0.041/0.046/0.061/0.003 ms, ipg/ewma 0.064/0.0=
45 ms

--- tux ping statistics ---
10000 packets transmitted, 10000 received, 0% packet loss, time 639ms
rtt min/avg/max/mdev =3D 0.039/0.045/0.151/0.009 ms, ipg/ewma 0.063/0.0=
46 ms

This is not too bad considering cheap equipment + two switches in the p=
ath,
and consistent with measurements in the other direction (server to desk=
top)
which would also see *very slightly* increase due to the host being slo=
wer.
So that's good and consistent.

Now I suspend/resume the desktop, and we get:

--- tux ping statistics ---
10000 packets transmitted, 10000 received, 0% packet loss, time 930ms
rtt min/avg/max/mdev =3D 0.041/0.050/0.150/0.009 ms, ipg/ewma 0.093/0.0=
53 ms

--- tux ping statistics ---
10000 packets transmitted, 10000 received, 0% packet loss, time 952ms
rtt min/avg/max/mdev =3D 0.042/0.051/0.132/0.005 ms, ipg/ewma 0.095/0.0=
50 ms

--- tux ping statistics ---
10000 packets transmitted, 10000 received, 0% packet loss, time 938ms
rtt min/avg/max/mdev =3D 0.040/0.050/0.157/0.009 ms, ipg/ewma 0.093/0.0=
52 ms

This is 100% repeatable: after a reboot it's fast; suspend/resume: slow=
=2E

While this is no drama and far from being unusable, something is now st=
ealing
~5=C2=B5s on average. I *think* that this relates to either the r8169 N=
IC or driver,
but can only offer inconclusive evidence insofar as an old laptop with =
e1000e
shows consistently slower performance, regardless of reboot vs. wakeup.

Any ideas or suggestions?

thanks
Holger
