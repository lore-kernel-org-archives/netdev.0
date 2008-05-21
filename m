From: Stephane Chazelas <Stephane_Chazelas@yahoo.fr>
Subject: [iproute2] get_hz() with CONFIG_HIGH_RES_TIMERS
Date: Wed, 21 May 2008 17:38:15 +0100
Message-ID: <20080521163815.GA5028@sc.homeunix.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: shemminger@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yoda.london.02.net ([82.132.130.151]:58317 "EHLO mail.o2.co.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754401AbYEUQoy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 May 2008 12:44:54 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,

there seems to be something wrong with the timer values as
processed by at least the "ss" and "ip" commands when
CONFIG_HIGH_RES_TIMERS is on.

$ zgrep -e HZ=3D -e HIGH_RES /proc/config.gz
CONFIG_HIGH_RES_TIMERS=3Dy
CONFIG_HZ=3D250

=46or instance, the "ip route rtt <time>" and=20
rto values returned by PROC_NET_TCP=3D/proc/net/tcp ss -i
look incorrect:

$ PROC_NET_TCP=3D/proc/net/tcp ss -i
State       Recv-Q Send-Q  Local Address:Port      Peer Address:Port
ESTAB       0      0           127.0.0.1:35466        127.0.0.1:10198  =
  rto:5.5e-08
[...]

$ ss -i
State       Recv-Q Send-Q  Local Address:Port      Peer Address:Port
ESTAB       0      0           127.0.0.1:35466        127.0.0.1:10198
        bic wscale:7,7 rto:220 rtt:23.5/19 send 11.2Mbps rcv_space:3279=
2


$ ip route show
10.95.131.111 via 10.95.128.1 dev eth0  rtt 5ms

$ netstat -rn
Kernel IP routing table
Destination     Gateway         Genmask         Flags   MSS Window  irt=
t Iface
10.95.131.111   10.95.128.1     255.255.255.255 UGH       0 0     50000=
00 eth0

I think this is because get_hz gets the HZ value from the fourth
field in /proc/net/psched. That's 1e9 in my case, because that's
meant to be the frequency of CLOCK_MONOTONIC and when
CONFIG_HIGH_RES_TIMERS is on, the CLOCK_MONOTONIC resolution is
1ns. So get_hz returns 1,000,000,000 instead of 250 in my case.

I don't know how to get the right value, clock_getres return 1ns
as well.

That's with 2.6.24.2, iproute-20080108 from debian (but the GIT
head code looks the same).

Best regards,
St=E9phane
