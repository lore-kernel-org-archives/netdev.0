From: Johannes Naab <jn@stusta.de>
Subject: net: netem: regression/bug: using a pfifo no longer avoids reordering
 caused by jitter
Date: Wed, 21 Aug 2013 20:40:32 +0200
Message-ID: <521509A0.3060607@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: mailings@hupie.com, eric.dumazet@gmail.com,
	stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.stusta.mhn.de ([141.84.69.5]:34349 "EHLO
	mail.stusta.mhn.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752436Ab3HUSkk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 14:40:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This is in relation to the
"[PATCH 2/2] net: netem: always adjust now/delay when not reordering"
discussion.

Since the issue is not related to the proposed patch itself (but the workaround),
I have taken the freedom of starting a new thread.

I tried the pfifo for delay+jitter with reordering avoidance 
(as given on the netem website http://www.linuxfoundation.org/collaborate/workgroups/networking/netem#How_to_reorder_packets_based_on_jitter.3F) 
in 3.11-rc4, 3.8 and 3.2 (Debian experimental, an old experimental
and current stable kernels).


The jitter reorder avoidance seems to work in 3.2, but no longer in 3.8 or 3.11-rc4.


First the working 3.2:

$ tc qdisc add dev node-net handle 1: root netem delay 1000ms 1000ms
$ ping -D -n -c 25 -i 0.1 10.0.2.1
PING 10.0.2.1 (10.0.2.1) 56(84) bytes of data.
[1377107794.371992] 64 bytes from 10.0.2.1: icmp_req=3 ttl=63 time=1846 ms
[1377107794.372231] 64 bytes from 10.0.2.1: icmp_req=5 ttl=63 time=1630 ms
[1377107794.372341] 64 bytes from 10.0.2.1: icmp_req=2 ttl=63 time=1954 ms
[1377107794.372432] 64 bytes from 10.0.2.1: icmp_req=7 ttl=63 time=1414 ms
[1377107794.372524] 64 bytes from 10.0.2.1: icmp_req=10 ttl=63 time=1090 ms
[1377107794.372629] 64 bytes from 10.0.2.1: icmp_req=1 ttl=63 time=2061 ms
[1377107794.372719] 64 bytes from 10.0.2.1: icmp_req=4 ttl=63 time=1738 ms
[1377107794.372810] 64 bytes from 10.0.2.1: icmp_req=14 ttl=63 time=658 ms
[1377107794.372901] 64 bytes from 10.0.2.1: icmp_req=11 ttl=63 time=982 ms
[1377107794.372971] 64 bytes from 10.0.2.1: icmp_req=8 ttl=63 time=1306 ms
[1377107794.397883] 64 bytes from 10.0.2.1: icmp_req=6 ttl=63 time=1548 ms
[1377107794.603519] 64 bytes from 10.0.2.1: icmp_req=16 ttl=63 time=674 ms
[1377107794.797632] 64 bytes from 10.0.2.1: icmp_req=9 ttl=63 time=1624 ms
[1377107794.952395] 64 bytes from 10.0.2.1: icmp_req=12 ttl=63 time=1454 ms
[1377107795.062865] 64 bytes from 10.0.2.1: icmp_req=15 ttl=63 time=1241 ms
[1377107795.168301] 64 bytes from 10.0.2.1: icmp_req=24 ttl=63 time=390 ms
[1377107795.263823] 64 bytes from 10.0.2.1: icmp_req=18 ttl=63 time=1118 ms
[1377107795.272856] 64 bytes from 10.0.2.1: icmp_req=20 ttl=63 time=911 ms
[1377107795.323775] 64 bytes from 10.0.2.1: icmp_req=19 ttl=63 time=1070 ms
[1377107795.419494] 64 bytes from 10.0.2.1: icmp_req=17 ttl=63 time=1382 ms
[1377107795.478443] 64 bytes from 10.0.2.1: icmp_req=13 ttl=63 time=1872 ms
[1377107795.703842] 64 bytes from 10.0.2.1: icmp_req=21 ttl=63 time=1241 ms
[1377107796.002957] 64 bytes from 10.0.2.1: icmp_req=25 ttl=63 time=1125 ms
[1377107796.434347] 64 bytes from 10.0.2.1: icmp_req=22 ttl=63 time=1864 ms
[1377107796.606394] 64 bytes from 10.0.2.1: icmp_req=23 ttl=63 time=1936 ms

--- 10.0.2.1 ping statistics ---
25 packets transmitted, 25 received, 0% packet loss, time 2567ms
rtt min/avg/max/mdev = 390.813/1365.603/2061.036/438.727 ms, pipe 20


by adding the pfifo, the reordering does not occur:

$ sudo tc qdisc add dev node-net parent 1:1 pfifo limit 1000
$ sudo ping -D -n -c 25 -i 0.1 10.0.2.1
PING 10.0.2.1 (10.0.2.1) 56(84) bytes of data.
[1377107865.731835] 64 bytes from 10.0.2.1: icmp_req=1 ttl=63 time=1855 ms
[1377107865.732082] 64 bytes from 10.0.2.1: icmp_req=2 ttl=63 time=1746 ms
[1377107865.732185] 64 bytes from 10.0.2.1: icmp_req=3 ttl=63 time=1638 ms
[1377107865.732290] 64 bytes from 10.0.2.1: icmp_req=4 ttl=63 time=1530 ms
[1377107865.786417] 64 bytes from 10.0.2.1: icmp_req=5 ttl=63 time=1476 ms
[1377107865.786552] 64 bytes from 10.0.2.1: icmp_req=6 ttl=63 time=1368 ms
[1377107865.978256] 64 bytes from 10.0.2.1: icmp_req=7 ttl=63 time=1452 ms
[1377107865.978349] 64 bytes from 10.0.2.1: icmp_req=8 ttl=63 time=1344 ms
[1377107865.978407] 64 bytes from 10.0.2.1: icmp_req=9 ttl=63 time=1236 ms
[1377107866.840396] 64 bytes from 10.0.2.1: icmp_req=10 ttl=63 time=1990 ms
[1377107866.840597] 64 bytes from 10.0.2.1: icmp_req=11 ttl=63 time=1882 ms
[1377107866.840740] 64 bytes from 10.0.2.1: icmp_req=12 ttl=63 time=1774 ms
[1377107867.020757] 64 bytes from 10.0.2.1: icmp_req=13 ttl=63 time=1847 ms
[1377107867.020893] 64 bytes from 10.0.2.1: icmp_req=14 ttl=63 time=1739 ms
[1377107867.020987] 64 bytes from 10.0.2.1: icmp_req=15 ttl=63 time=1631 ms
[1377107867.021078] 64 bytes from 10.0.2.1: icmp_req=16 ttl=63 time=1523 ms
[1377107867.021168] 64 bytes from 10.0.2.1: icmp_req=17 ttl=63 time=1415 ms
[1377107867.021258] 64 bytes from 10.0.2.1: icmp_req=18 ttl=63 time=1307 ms
[1377107867.021348] 64 bytes from 10.0.2.1: icmp_req=19 ttl=63 time=1207 ms
[1377107867.022735] 64 bytes from 10.0.2.1: icmp_req=20 ttl=63 time=1101 ms
[1377107867.757821] 64 bytes from 10.0.2.1: icmp_req=21 ttl=63 time=1736 ms
[1377107867.758009] 64 bytes from 10.0.2.1: icmp_req=22 ttl=63 time=1628 ms
[1377107867.832652] 64 bytes from 10.0.2.1: icmp_req=23 ttl=63 time=1595 ms
[1377107867.832776] 64 bytes from 10.0.2.1: icmp_req=24 ttl=63 time=1487 ms
[1377107867.832881] 64 bytes from 10.0.2.1: icmp_req=25 ttl=63 time=1379 ms

--- 10.0.2.1 ping statistics ---
25 packets transmitted, 25 received, 0% packet loss, time 2577ms
rtt min/avg/max/mdev = 1101.255/1555.884/1990.917/226.825 ms, pipe 18



In 3.8 and 3.11-rc4 without pfifo (with causes reordering as currently expected):

$ sudo ping -D -n -c 25 -i 0.1 10.0.2.1
PING 10.0.2.1 (10.0.2.1) 56(84) bytes of data.
[1377108036.574818] 64 bytes from 10.0.2.1: icmp_req=1 ttl=63 time=252 ms
[1377108037.846016] 64 bytes from 10.0.2.1: icmp_req=4 ttl=63 time=1207 ms
[1377108037.846200] 64 bytes from 10.0.2.1: icmp_req=5 ttl=63 time=1100 ms
[1377108037.846287] 64 bytes from 10.0.2.1: icmp_req=8 ttl=63 time=776 ms
[1377108037.846399] 64 bytes from 10.0.2.1: icmp_req=6 ttl=63 time=992 ms
[1377108037.846483] 64 bytes from 10.0.2.1: icmp_req=3 ttl=63 time=1308 ms
[1377108038.025777] 64 bytes from 10.0.2.1: icmp_req=10 ttl=63 time=740 ms
[1377108038.072852] 64 bytes from 10.0.2.1: icmp_req=2 ttl=63 time=1643 ms
[1377108038.288748] 64 bytes from 10.0.2.1: icmp_req=9 ttl=63 time=1111 ms
[1377108038.317722] 64 bytes from 10.0.2.1: icmp_req=11 ttl=63 time=924 ms
[1377108038.369579] 64 bytes from 10.0.2.1: icmp_req=13 ttl=63 time=760 ms
[1377108038.384918] 64 bytes from 10.0.2.1: icmp_req=7 ttl=63 time=1423 ms
[1377108038.704846] 64 bytes from 10.0.2.1: icmp_req=14 ttl=63 time=987 ms
[1377108038.852763] 64 bytes from 10.0.2.1: icmp_req=16 ttl=63 time=926 ms
[1377108039.158401] 64 bytes from 10.0.2.1: icmp_req=21 ttl=63 time=724 ms
[1377108039.213823] 64 bytes from 10.0.2.1: icmp_req=12 ttl=63 time=1712 ms
[1377108039.310065] 64 bytes from 10.0.2.1: icmp_req=18 ttl=63 time=1183 ms
[1377108039.457295] 64 bytes from 10.0.2.1: icmp_req=25 ttl=63 time=604 ms
[1377108039.560758] 64 bytes from 10.0.2.1: icmp_req=15 ttl=63 time=1735 ms
[1377108039.847344] 64 bytes from 10.0.2.1: icmp_req=17 ttl=63 time=1821 ms
[1377108039.922450] 64 bytes from 10.0.2.1: icmp_req=23 ttl=63 time=1273 ms
[1377108040.189117] 64 bytes from 10.0.2.1: icmp_req=19 ttl=63 time=1955 ms
[1377108040.233637] 64 bytes from 10.0.2.1: icmp_req=20 ttl=63 time=1899 ms
[1377108040.430303] 64 bytes from 10.0.2.1: icmp_req=22 ttl=63 time=1889 ms
[1377108040.437195] 64 bytes from 10.0.2.1: icmp_req=24 ttl=63 time=1686 ms

--- 10.0.2.1 ping statistics ---
25 packets transmitted, 25 received, 0% packet loss, time 2531ms
rtt min/avg/max/mdev = 252.930/1225.728/1955.892/459.288 ms, pipe 16


Adding the pfifo does not avoid the reordering (which is a regression against 3.2).

$ sudo tc qdisc add dev node-net parent 1:1 pfifo limit 1000
$ sudo ping -D -n -c 25 -i 0.1 10.0.2.1
PING 10.0.2.1 (10.0.2.1) 56(84) bytes of data.
[1377108141.816852] 64 bytes from 10.0.2.1: icmp_req=1 ttl=63 time=1260 ms
[1377108141.817114] 64 bytes from 10.0.2.1: icmp_req=7 ttl=63 time=611 ms
[1377108141.817230] 64 bytes from 10.0.2.1: icmp_req=3 ttl=63 time=1043 ms
[1377108141.817336] 64 bytes from 10.0.2.1: icmp_req=4 ttl=63 time=935 ms
[1377108141.842461] 64 bytes from 10.0.2.1: icmp_req=10 ttl=63 time=313 ms
[1377108142.029281] 64 bytes from 10.0.2.1: icmp_req=2 ttl=63 time=1363 ms
[1377108142.085116] 64 bytes from 10.0.2.1: icmp_req=6 ttl=63 time=987 ms
[1377108142.136125] 64 bytes from 10.0.2.1: icmp_req=8 ttl=63 time=822 ms
[1377108142.359697] 64 bytes from 10.0.2.1: icmp_req=9 ttl=63 time=938 ms
[1377108142.456998] 64 bytes from 10.0.2.1: icmp_req=11 ttl=63 time=819 ms
[1377108142.779780] 64 bytes from 10.0.2.1: icmp_req=20 ttl=63 time=202 ms
[1377108142.779960] 64 bytes from 10.0.2.1: icmp_req=15 ttl=63 time=719 ms
[1377108142.815326] 64 bytes from 10.0.2.1: icmp_req=13 ttl=63 time=962 ms
[1377108142.830840] 64 bytes from 10.0.2.1: icmp_req=5 ttl=63 time=1841 ms
[1377108143.099230] 64 bytes from 10.0.2.1: icmp_req=23 ttl=63 time=207 ms
[1377108143.299404] 64 bytes from 10.0.2.1: icmp_req=18 ttl=63 time=929 ms
[1377108143.333906] 64 bytes from 10.0.2.1: icmp_req=21 ttl=63 time=648 ms
[1377108143.391823] 64 bytes from 10.0.2.1: icmp_req=19 ttl=63 time=921 ms
[1377108143.402795] 64 bytes from 10.0.2.1: icmp_req=12 ttl=63 time=1657 ms
[1377108143.496919] 64 bytes from 10.0.2.1: icmp_req=16 ttl=63 time=1335 ms
[1377108143.680456] 64 bytes from 10.0.2.1: icmp_req=17 ttl=63 time=1411 ms
[1377108143.781552] 64 bytes from 10.0.2.1: icmp_req=14 ttl=63 time=1820 ms
[1377108144.020711] 64 bytes from 10.0.2.1: icmp_req=24 ttl=63 time=1029 ms
[1377108144.374671] 64 bytes from 10.0.2.1: icmp_req=25 ttl=63 time=1283 ms
[1377108144.447944] 64 bytes from 10.0.2.1: icmp_req=22 ttl=63 time=1657 ms

--- 10.0.2.1 ping statistics ---
25 packets transmitted, 25 received, 0% packet loss, time 2534ms
rtt min/avg/max/mdev = 202.462/1029.004/1841.404/445.533 ms, pipe 18


Can anyone confirm this behavior? Is the documentation out of date,
or is that a regression?

Best regards,
Johannes
-- 
