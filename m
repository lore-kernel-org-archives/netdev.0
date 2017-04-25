From: =?utf-8?B?0JDQu9C10LrRgdC10Lkg0JHQvtC70LTRi9GA0LXQsg==?=
        <ne-vlezay80@yandex.ru>
Subject: Bug and configuration MPLS error?
Date: Tue, 25 Apr 2017 20:28:34 +0300
Message-ID: <184081493141314@web16g.yandex.ru>
References: <61671493137651@web14o.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward17h.cmail.yandex.net ([87.250.230.159]:37759 "EHLO
        forward17h.cmail.yandex.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1952186AbdDYRgZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 13:36:25 -0400
Received: from mxback14j.mail.yandex.net (mxback14j.mail.yandex.net [IPv6:2a02:6b8:0:1619::90])
        by forward17h.cmail.yandex.net (Yandex) with ESMTP id AB824227E2
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 20:28:34 +0300 (MSK)
In-Reply-To: <61671493137651@web14o.yandex.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Короче, вот конфиг MPLS на одном из дистрибутивов:
In short, here's the MPLS configuration on one of the distributions:
226 sysctl -w net.mpls.conf.lo.input=1
227 sysctl -w net.mpls.platform_labels=1048575
228 ip link add veth0 type veth peer name veth1
229 ip link add veth2 type veth peer name veth3
230 sysctl -w net.mpls.conf.veth0.input=1
231 sysctl -w net.mpls.conf.veth2.input=1
232 ifconfig veth0 10.3.3.1 netmask 255.255.255.0
233 ifconfig veth2 10.4.4.1 netmask 255.255.255.0
234 ip netns add host1
235 ip netns add host2
236 ip link set veth1 netns host1
237 ip link set veth3 netns host2
238 ip netns exec host1 ifconfig veth1 10.3.3.2 netmask 255.255.255.0 up
239 ip netns exec host2 ifconfig veth3 10.4.4.2 netmask 255.255.255.0 up
240 ip netns exec host1 ip route add 10.10.10.2/32 encap mpls 112 via inet 10.3.3.1
241 ip netns exec host2 ip route add 10.10.10.1/32 encap mpls 111 via inet 10.4.4.1
242 ip -f mpls route add 111 via inet 10.3.3.2
243 ip -f mpls route add 112 via inet 10.4.4.2

Результаты теста:
Test Results:
tcp по mpls:
~ # ip netns exec host2 iperf3 -c 10.10.10.1 -B 10.10.10.2
Connecting to host 10.10.10.1, port 5201
[ 4] local 10.10.10.2 port 34021 connected to 10.10.10.1 port 5201
[ ID] Interval Transfer Bandwidth Retr Cwnd
[ 4] 0.00-1.00 sec 912 KBytes 7.46 Mbits/sec 0 636 KBytes
[ 4] 1.00-2.00 sec 0.00 Bytes 0.00 bits/sec 0 636 KBytes
[ 4] 2.00-3.00 sec 0.00 Bytes 0.00 bits/sec 0 636 KBytes
[ 4] 3.00-4.00 sec 0.00 Bytes 0.00 bits/sec 0 636 KBytes
[ 4] 4.00-5.00 sec 0.00 Bytes 0.00 bits/sec 0 636 KBytes
[ 4] 5.00-6.00 sec 0.00 Bytes 0.00 bits/sec 0 636 KBytes
[ 4] 6.00-7.00 sec 0.00 Bytes 0.00 bits/sec 0 636 KBytes
[ 4] 7.00-8.00 sec 0.00 Bytes 0.00 bits/sec 0 636 KBytes
[ 4] 8.00-9.00 sec 0.00 Bytes 0.00 bits/sec 0 636 KBytes
[ 4] 9.00-10.00 sec 0.00 Bytes 0.00 bits/sec 0 636 KBytes
----------------------------------------

[ ID] Interval Transfer Bandwidth Retr
[ 4] 0.00-10.00 sec 912 KBytes 747 Kbits/sec 0 sender
[ 4] 0.00-10.00 sec 21.3 KBytes 17.5 Kbits/sec receiver

iperf Done.
~ #
udp по mpls:
~ # ip netns exec host2 iperf3 -c 10.10.10.1 -B 10.10.10.2 -u -b 10g
Connecting to host 10.10.10.1, port 5201
[ 4] local 10.10.10.2 port 56901 connected to 10.10.10.1 port 5201
[ ID] Interval Transfer Bandwidth Total Datagrams
[ 4] 0.00-1.00 sec 438 MBytes 3.67 Gbits/sec 56049
[ 4] 1.00-2.00 sec 491 MBytes 4.12 Gbits/sec 62829
[ 4] 2.00-3.00 sec 492 MBytes 4.12 Gbits/sec 62919
[ 4] 3.00-4.00 sec 490 MBytes 4.11 Gbits/sec 62762
[ 4] 4.00-5.00 sec 491 MBytes 4.12 Gbits/sec 62891
[ 4] 5.00-6.00 sec 492 MBytes 4.13 Gbits/sec 62994
[ 4] 6.00-7.00 sec 503 MBytes 4.22 Gbits/sec 64322
[ 4] 7.00-8.00 sec 503 MBytes 4.22 Gbits/sec 64321
[ 4] 8.00-9.00 sec 502 MBytes 4.21 Gbits/sec 64279
[ 4] 9.00-10.00 sec 511 MBytes 4.28 Gbits/sec 65352
----------------------------------------

[ ID] Interval Transfer Bandwidth Jitter Lost/Total Datagrams
[ 4] 0.00-10.00 sec 4.80 GBytes 4.12 Gbits/sec 0.001 ms 0/628718 (0%)
[ 4] Sent 628718 datagrams

iperf Done.
UDP как видим, проходит нормально.
UDP as seen, is normal.
Вот параметры интерфейсов:
Here are the interface parameters:
P:
veth0 Link encap:Ethernet HWaddr 72:0D:9E:D7:BC:B3
inet addr:10.3.3.1 Bcast:10.3.3.255 Mask:255.255.255.0
inet6 addr: fe80::700d:9eff:fed7:bcb3/64 Scope:Link
UP BROADCAST RUNNING MULTICAST MTU:65535 Metric:1
RX packets:126 errors:0 dropped:0 overruns:0 frame:0
TX packets:629026 errors:0 dropped:0 overruns:0 carrier:0
collisions:0 txqueuelen:1000
RX bytes:9592 (9.3 KiB) TX bytes:5178498619 (4.8 GiB)

veth2 Link encap:Ethernet HWaddr CE:24:F8:1F:99:C1
inet addr:10.4.4.1 Bcast:10.4.4.255 Mask:255.255.255.0
inet6 addr: fe80::cc24:f8ff:fe1f:99c1/64 Scope:Link
UP BROADCAST RUNNING MULTICAST MTU:65535 Metric:1
RX packets:629015 errors:0 dropped:0 overruns:0 frame:0
TX packets:135 errors:0 dropped:0 overruns:0 carrier:0
collisions:0 txqueuelen:1000
RX bytes:5181014123 (4.8 GiB) TX bytes:9564 (9.3 KiB)
PE1:
~ # ip netns exec host2 ifconfig
lo Link encap:Local Loopback
inet addr:127.0.0.1 Mask:255.0.0.0
inet6 addr: ::1/128 Scope:Host
UP LOOPBACK RUNNING MTU:65536 Metric:1
RX packets:0 errors:0 dropped:0 overruns:0 frame:0
TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
collisions:0 txqueuelen:1
RX bytes:0 (0.0 B) TX bytes:0 (0.0 B)

veth3 Link encap:Ethernet HWaddr 36:00:C2:29:0D:F9
inet addr:10.4.4.2 Bcast:10.4.4.255 Mask:255.255.255.0
inet6 addr: fe80::3400:c2ff:fe29:df9/64 Scope:Link
UP BROADCAST RUNNING MULTICAST MTU:65200 Metric:1
RX packets:136 errors:0 dropped:0 overruns:0 frame:0
TX packets:629015 errors:0 dropped:1 overruns:0 carrier:0
collisions:0 txqueuelen:1000
RX bytes:9596 (9.3 KiB) TX bytes:5181014123 (4.8 GiB)
PE2:
lo Link encap:Local Loopback
inet addr:127.0.0.1 Mask:255.0.0.0
inet6 addr: ::1/128 Scope:Host
UP LOOPBACK RUNNING MTU:65536 Metric:1
RX packets:0 errors:0 dropped:0 overruns:0 frame:0
TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
collisions:0 txqueuelen:1
RX bytes:0 (0.0 B) TX bytes:0 (0.0 B)

veth1 Link encap:Ethernet HWaddr DA:B2:AD:31:68:77
inet addr:10.3.3.2 Bcast:10.3.3.255 Mask:255.255.255.0
inet6 addr: fe80::d8b2:adff:fe31:6877/64 Scope:Link
UP BROADCAST RUNNING MULTICAST MTU:65200 Metric:1
RX packets:629027 errors:0 dropped:0 overruns:0 frame:0
TX packets:126 errors:0 dropped:0 overruns:0 carrier:0
collisions:0 txqueuelen:1000
RX bytes:5178498651 (4.8 GiB) TX bytes:9592 (9.3 KiB)
Тоже самое, только на более свежом ядре: http://forum.nag.ru/forum/index.php?showtopic=128927&st=0
The same thing, only on amore recent nucleus:
Ядро:
Core:
/ # uname -r
4.8.6
Конфиг ядра:
Kernel Config:
https://pastebin.com/raw/EE1k05cT

Это баг ядра, или ошибка конфигурирования?
Is it a kernel bug, or a configuration error?
