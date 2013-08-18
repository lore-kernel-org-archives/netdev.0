From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [OpenWrt-Devel] [RFC][PATCH 2/2] bgmac: pass received packet to
 the netif instead of copying it
Date: Sun, 18 Aug 2013 23:06:33 +0200
Message-ID: <CACna6ryu6es1tBq-FV5UX7Rdqu5GZsHk-UELW2-Yjuv26t3pMw@mail.gmail.com>
References: <1376243355-5740-1-git-send-email-zajec5@gmail.com>
	<1376243355-5740-2-git-send-email-zajec5@gmail.com>
	<CACna6rwtLw-Aiz3amMvTBwWsi0OWo5f2yMCF9e8DeCjKLOGDEA@mail.gmail.com>
	<520CBFD6.6030600@openwrt.org>
	<CACna6rwi1+2ghyyKonaw=6xVDwipb3=1zUzOJ7dVoNoVyRx9fw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=089e01537e42db9d1d04e43f324f
Cc: OpenWrt Development List <openwrt-devel@lists.openwrt.org>,
	Network Development <netdev@vger.kernel.org>,
	Hauke Mehrtens <hauke@hauke-m.de>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Jonas Gorski <jogo@openwrt.org>,
	Robert Bradley <robert.bradley1@gmail.com>
To: Felix Fietkau <nbd@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f41.google.com ([209.85.219.41]:48276 "EHLO
	mail-oa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754490Ab3HRVGe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Aug 2013 17:06:34 -0400
Received: by mail-oa0-f41.google.com with SMTP id j6so4611804oag.14
        for <netdev@vger.kernel.org>; Sun, 18 Aug 2013 14:06:34 -0700 (PDT)
In-Reply-To: <CACna6rwi1+2ghyyKonaw=6xVDwipb3=1zUzOJ7dVoNoVyRx9fw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--089e01537e42db9d1d04e43f324f
Content-Type: text/plain; charset=UTF-8

I performed some tests using Netgear WNDR4500 (BCM4706 based) using:
WNDR4500-V1.0.1.36_1.0.63.chk

On IRC we were wondering if switch does routing for the CPU, so I did
some trivial tests using "ifconfig".

Short introduction of available intefaces:

# brctl show
bridge name bridge id STP enabled interfaces
br0 8000.204e7fab3aa8 no vlan1
eth1
eth2

So br0 bridge connects: vlan1, eth1, eth2. I don't really know why
there are eth2 and vlan2

I was using 192.168.5.2 for my WAN port
I was using 192.168.1.1 for my LAN ports

192.168.5.1 was a "gate" PC with iperf -s running. On my 192.168.1.X
machine I started iperf -c. So it was transfer of packets from LAN
vlan to WAN vlan.

iperf.exe -c 192.168.5.1 -t 60
------------------------------------------------------------
Client connecting to 192.168.5.1, TCP port 5001
TCP window size: 64.0 KByte (default)
------------------------------------------------------------
[ 3] local 192.168.1.3 port 55244 connected with 192.168.5.1 port 5001
[ ID] Interval Transfer Bandwidth
[ 3] 0.0-60.0 sec 4.02 GBytes 576 Mbits/sec

As you can see, I got ~500Mb/s in comparison to ~105Mb/s when using OpenWrt.

Now the most interesting part (I hope my mailer won't fail on formatting):

# ifconfig; sleep 10; ifconfig
br0 Link encap:Ethernet HWaddr 11:22:33:44:55:A8
inet addr:192.168.1.1 Bcast:192.168.1.255 Mask:255.255.255.0
inet6 addr: fe80::224e:7fff:feab:3aa8/64 Scope:Link
UP BROADCAST RUNNING MULTICAST MTU:1500 Metric:1
RX packets:3639 errors:0 dropped:0 overruns:0 frame:0
TX packets:4001 errors:0 dropped:0 overruns:0 carrier:0
collisions:0 txqueuelen:0
RX bytes:368045 (359.4 KiB) TX bytes:3516213 (3.3 MiB)

eth0 Link encap:Ethernet HWaddr 11:22:33:44:55:A9
inet addr:192.168.5.2 Bcast:192.168.5.255 Mask:255.255.255.0
inet6 addr: fe80::224e:7fff:feab:3aa9/64 Scope:Link
UP BROADCAST RUNNING PROMISC ALLMULTI MULTICAST MTU:1500 Metric:1
RX packets:309084 errors:0 dropped:0 overruns:0 frame:0
TX packets:3126985 errors:0 dropped:0 overruns:0 carrier:0
collisions:0 txqueuelen:1000
RX bytes:19789406 (18.8 MiB) TX bytes:377801895 (360.2 MiB)
Interrupt:4 Base address:0x2000

eth1 Link encap:Ethernet HWaddr 11:22:33:44:55:A8
inet6 addr: fe80::224e:7fff:feab:3aa8/64 Scope:Link
UP BROADCAST RUNNING MULTICAST MTU:1500 Metric:1
RX packets:0 errors:0 dropped:0 overruns:0 frame:424
TX packets:0 errors:65 dropped:0 overruns:0 carrier:0
collisions:0 txqueuelen:1000
RX bytes:0 (0.0 B) TX bytes:0 (0.0 B)
Interrupt:3 Base address:0x8000

eth2 Link encap:Ethernet HWaddr 11:22:33:44:55:A7
inet6 addr: fe80::224e:7fff:feab:3aa7/64 Scope:Link
UP BROADCAST RUNNING MULTICAST MTU:1500 Metric:1
RX packets:0 errors:0 dropped:0 overruns:0 frame:0
TX packets:0 errors:54 dropped:0 overruns:0 carrier:0
collisions:0 txqueuelen:1000
RX bytes:0 (0.0 B) TX bytes:0 (0.0 B)
Interrupt:5 Base address:0x8000

lo Link encap:Local Loopback
inet addr:127.0.0.1 Mask:255.0.0.0
inet6 addr: ::1/128 Scope:Host
UP LOOPBACK RUNNING MULTICAST MTU:16436 Metric:1
RX packets:107 errors:0 dropped:0 overruns:0 frame:0
TX packets:107 errors:0 dropped:0 overruns:0 carrier:0
collisions:0 txqueuelen:0
RX bytes:11408 (11.1 KiB) TX bytes:11408 (11.1 KiB)

vlan1 Link encap:Ethernet HWaddr 11:22:33:44:55:A8
inet6 addr: fe80::224e:7fff:feab:3aa8/64 Scope:Link
UP BROADCAST RUNNING PROMISC ALLMULTI MULTICAST MTU:1500 Metric:1
RX packets:3127849 errors:0 dropped:0 overruns:0 frame:0
TX packets:310049 errors:0 dropped:0 overruns:0 carrier:0
collisions:0 txqueuelen:0
RX bytes:390393723 (372.3 MiB) TX bytes:20643844 (19.6 MiB)

vlan2 Link encap:Ethernet HWaddr 11:22:33:44:55:A8
inet6 addr: fe80::224e:7fff:feab:3aa8/64 Scope:Link
UP BROADCAST RUNNING PROMISC ALLMULTI MULTICAST MTU:1500 Metric:1
RX packets:0 errors:0 dropped:0 overruns:0 frame:0
TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
collisions:0 txqueuelen:0
RX bytes:0 (0.0 B) TX bytes:0 (0.0 B)





br0 Link encap:Ethernet HWaddr 11:22:33:44:55:A8
inet addr:192.168.1.1 Bcast:192.168.1.255 Mask:255.255.255.0
inet6 addr: fe80::224e:7fff:feab:3aa8/64 Scope:Link
UP BROADCAST RUNNING MULTICAST MTU:1500 Metric:1
RX packets:3670 errors:0 dropped:0 overruns:0 frame:0
TX packets:4004 errors:0 dropped:0 overruns:0 carrier:0
collisions:0 txqueuelen:0
RX bytes:370146 (361.4 KiB) TX bytes:3516858 (3.3 MiB)

eth0 Link encap:Ethernet HWaddr 11:22:33:44:55:A9
inet addr:192.168.5.2 Bcast:192.168.5.255 Mask:255.255.255.0
inet6 addr: fe80::224e:7fff:feab:3aa9/64 Scope:Link
UP BROADCAST RUNNING PROMISC ALLMULTI MULTICAST MTU:1500 Metric:1
RX packets:362946 errors:0 dropped:0 overruns:0 frame:0
TX packets:3671812 errors:0 dropped:0 overruns:0 carrier:0
collisions:0 txqueuelen:1000
RX bytes:23236574 (22.1 MiB) TX bytes:1191974445 (1.1 GiB)
Interrupt:4 Base address:0x2000

eth1 Link encap:Ethernet HWaddr 11:22:33:44:55:A8
inet6 addr: fe80::224e:7fff:feab:3aa8/64 Scope:Link
UP BROADCAST RUNNING MULTICAST MTU:1500 Metric:1
RX packets:0 errors:0 dropped:0 overruns:0 frame:424
TX packets:0 errors:65 dropped:0 overruns:0 carrier:0
collisions:0 txqueuelen:1000
RX bytes:0 (0.0 B) TX bytes:0 (0.0 B)
Interrupt:3 Base address:0x8000

eth2 Link encap:Ethernet HWaddr 11:22:33:44:55:A7
inet6 addr: fe80::224e:7fff:feab:3aa7/64 Scope:Link
UP BROADCAST RUNNING MULTICAST MTU:1500 Metric:1
RX packets:0 errors:0 dropped:0 overruns:0 frame:0
TX packets:0 errors:54 dropped:0 overruns:0 carrier:0
collisions:0 txqueuelen:1000
RX bytes:0 (0.0 B) TX bytes:0 (0.0 B)
Interrupt:5 Base address:0x8000

lo Link encap:Local Loopback
inet addr:127.0.0.1 Mask:255.0.0.0
inet6 addr: ::1/128 Scope:Host
UP LOOPBACK RUNNING MULTICAST MTU:16436 Metric:1
RX packets:119 errors:0 dropped:0 overruns:0 frame:0
TX packets:119 errors:0 dropped:0 overruns:0 carrier:0
collisions:0 txqueuelen:0
RX bytes:12532 (12.2 KiB) TX bytes:12532 (12.2 KiB)

vlan1 Link encap:Ethernet HWaddr 11:22:33:44:55:A8
inet6 addr: fe80::224e:7fff:feab:3aa8/64 Scope:Link
UP BROADCAST RUNNING PROMISC ALLMULTI MULTICAST MTU:1500 Metric:1
RX packets:3672697 errors:0 dropped:0 overruns:0 frame:0
TX packets:363914 errors:0 dropped:0 overruns:0 carrier:0
collisions:0 txqueuelen:0
RX bytes:1206747346 (1.1 GiB) TX bytes:24091669 (22.9 MiB)

vlan2 Link encap:Ethernet HWaddr 11:22:33:44:55:A8
inet6 addr: fe80::224e:7fff:feab:3aa8/64 Scope:Link
UP BROADCAST RUNNING PROMISC ALLMULTI MULTICAST MTU:1500 Metric:1
RX packets:0 errors:0 dropped:0 overruns:0 frame:0
TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
collisions:0 txqueuelen:0
RX bytes:0 (0.0 B) TX bytes:0 (0.0 B)


So over 10s Netgear's firmware received ~700MiB of packets on vlan1
And it transferred ~700MiB of packets to eth0.

I believe it proves that Netgear's firmware doesn't use any built in
routing feature of the BCM53125 switch.

--089e01537e42db9d1d04e43f324f
Content-Type: text/plain; charset=US-ASCII;
	name="netgear.wndr4500.orig.firmware.ifconfig.txt"
Content-Disposition: attachment;
	filename="netgear.wndr4500.orig.firmware.ifconfig.txt"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_hkiqu40e1

IyBpZmNvbmZpZzsgc2xlZXAgMTA7IGlmY29uZmlnIApicjAgICAgICAgTGluayBlbmNhcDpFdGhl
cm5ldCAgSFdhZGRyIDExOjIyOjMzOjQ0OjU1OkE4ICAKICAgICAgICAgIGluZXQgYWRkcjoxOTIu
MTY4LjEuMSAgQmNhc3Q6MTkyLjE2OC4xLjI1NSAgTWFzazoyNTUuMjU1LjI1NS4wCiAgICAgICAg
ICBpbmV0NiBhZGRyOiBmZTgwOjoyMjRlOjdmZmY6ZmVhYjozYWE4LzY0IFNjb3BlOkxpbmsKICAg
ICAgICAgIFVQIEJST0FEQ0FTVCBSVU5OSU5HIE1VTFRJQ0FTVCAgTVRVOjE1MDAgIE1ldHJpYzox
CiAgICAgICAgICBSWCBwYWNrZXRzOjM2MzkgZXJyb3JzOjAgZHJvcHBlZDowIG92ZXJydW5zOjAg
ZnJhbWU6MAogICAgICAgICAgVFggcGFja2V0czo0MDAxIGVycm9yczowIGRyb3BwZWQ6MCBvdmVy
cnVuczowIGNhcnJpZXI6MAogICAgICAgICAgY29sbGlzaW9uczowIHR4cXVldWVsZW46MCAKICAg
ICAgICAgIFJYIGJ5dGVzOjM2ODA0NSAoMzU5LjQgS2lCKSAgVFggYnl0ZXM6MzUxNjIxMyAoMy4z
IE1pQikKCmV0aDAgICAgICBMaW5rIGVuY2FwOkV0aGVybmV0ICBIV2FkZHIgMTE6MjI6MzM6NDQ6
NTU6QTkgIAogICAgICAgICAgaW5ldCBhZGRyOjE5Mi4xNjguNS4yICBCY2FzdDoxOTIuMTY4LjUu
MjU1ICBNYXNrOjI1NS4yNTUuMjU1LjAKICAgICAgICAgIGluZXQ2IGFkZHI6IGZlODA6OjIyNGU6
N2ZmZjpmZWFiOjNhYTkvNjQgU2NvcGU6TGluawogICAgICAgICAgVVAgQlJPQURDQVNUIFJVTk5J
TkcgUFJPTUlTQyBBTExNVUxUSSBNVUxUSUNBU1QgIE1UVToxNTAwICBNZXRyaWM6MQogICAgICAg
ICAgUlggcGFja2V0czozMDkwODQgZXJyb3JzOjAgZHJvcHBlZDowIG92ZXJydW5zOjAgZnJhbWU6
MAogICAgICAgICAgVFggcGFja2V0czozMTI2OTg1IGVycm9yczowIGRyb3BwZWQ6MCBvdmVycnVu
czowIGNhcnJpZXI6MAogICAgICAgICAgY29sbGlzaW9uczowIHR4cXVldWVsZW46MTAwMCAKICAg
ICAgICAgIFJYIGJ5dGVzOjE5Nzg5NDA2ICgxOC44IE1pQikgIFRYIGJ5dGVzOjM3NzgwMTg5NSAo
MzYwLjIgTWlCKQogICAgICAgICAgSW50ZXJydXB0OjQgQmFzZSBhZGRyZXNzOjB4MjAwMCAKCmV0
aDEgICAgICBMaW5rIGVuY2FwOkV0aGVybmV0ICBIV2FkZHIgMTE6MjI6MzM6NDQ6NTU6QTggIAog
ICAgICAgICAgaW5ldDYgYWRkcjogZmU4MDo6MjI0ZTo3ZmZmOmZlYWI6M2FhOC82NCBTY29wZTpM
aW5rCiAgICAgICAgICBVUCBCUk9BRENBU1QgUlVOTklORyBNVUxUSUNBU1QgIE1UVToxNTAwICBN
ZXRyaWM6MQogICAgICAgICAgUlggcGFja2V0czowIGVycm9yczowIGRyb3BwZWQ6MCBvdmVycnVu
czowIGZyYW1lOjQyNAogICAgICAgICAgVFggcGFja2V0czowIGVycm9yczo2NSBkcm9wcGVkOjAg
b3ZlcnJ1bnM6MCBjYXJyaWVyOjAKICAgICAgICAgIGNvbGxpc2lvbnM6MCB0eHF1ZXVlbGVuOjEw
MDAgCiAgICAgICAgICBSWCBieXRlczowICgwLjAgQikgIFRYIGJ5dGVzOjAgKDAuMCBCKQogICAg
ICAgICAgSW50ZXJydXB0OjMgQmFzZSBhZGRyZXNzOjB4ODAwMCAKCmV0aDIgICAgICBMaW5rIGVu
Y2FwOkV0aGVybmV0ICBIV2FkZHIgMTE6MjI6MzM6NDQ6NTU6QTcgIAogICAgICAgICAgaW5ldDYg
YWRkcjogZmU4MDo6MjI0ZTo3ZmZmOmZlYWI6M2FhNy82NCBTY29wZTpMaW5rCiAgICAgICAgICBV
UCBCUk9BRENBU1QgUlVOTklORyBNVUxUSUNBU1QgIE1UVToxNTAwICBNZXRyaWM6MQogICAgICAg
ICAgUlggcGFja2V0czowIGVycm9yczowIGRyb3BwZWQ6MCBvdmVycnVuczowIGZyYW1lOjAKICAg
ICAgICAgIFRYIHBhY2tldHM6MCBlcnJvcnM6NTQgZHJvcHBlZDowIG92ZXJydW5zOjAgY2Fycmll
cjowCiAgICAgICAgICBjb2xsaXNpb25zOjAgdHhxdWV1ZWxlbjoxMDAwIAogICAgICAgICAgUlgg
Ynl0ZXM6MCAoMC4wIEIpICBUWCBieXRlczowICgwLjAgQikKICAgICAgICAgIEludGVycnVwdDo1
IEJhc2UgYWRkcmVzczoweDgwMDAgCgpsbyAgICAgICAgTGluayBlbmNhcDpMb2NhbCBMb29wYmFj
ayAgCiAgICAgICAgICBpbmV0IGFkZHI6MTI3LjAuMC4xICBNYXNrOjI1NS4wLjAuMAogICAgICAg
ICAgaW5ldDYgYWRkcjogOjoxLzEyOCBTY29wZTpIb3N0CiAgICAgICAgICBVUCBMT09QQkFDSyBS
VU5OSU5HIE1VTFRJQ0FTVCAgTVRVOjE2NDM2ICBNZXRyaWM6MQogICAgICAgICAgUlggcGFja2V0
czoxMDcgZXJyb3JzOjAgZHJvcHBlZDowIG92ZXJydW5zOjAgZnJhbWU6MAogICAgICAgICAgVFgg
cGFja2V0czoxMDcgZXJyb3JzOjAgZHJvcHBlZDowIG92ZXJydW5zOjAgY2FycmllcjowCiAgICAg
ICAgICBjb2xsaXNpb25zOjAgdHhxdWV1ZWxlbjowIAogICAgICAgICAgUlggYnl0ZXM6MTE0MDgg
KDExLjEgS2lCKSAgVFggYnl0ZXM6MTE0MDggKDExLjEgS2lCKQoKdmxhbjEgICAgIExpbmsgZW5j
YXA6RXRoZXJuZXQgIEhXYWRkciAxMToyMjozMzo0NDo1NTpBOCAgCiAgICAgICAgICBpbmV0NiBh
ZGRyOiBmZTgwOjoyMjRlOjdmZmY6ZmVhYjozYWE4LzY0IFNjb3BlOkxpbmsKICAgICAgICAgIFVQ
IEJST0FEQ0FTVCBSVU5OSU5HIFBST01JU0MgQUxMTVVMVEkgTVVMVElDQVNUICBNVFU6MTUwMCAg
TWV0cmljOjEKICAgICAgICAgIFJYIHBhY2tldHM6MzEyNzg0OSBlcnJvcnM6MCBkcm9wcGVkOjAg
b3ZlcnJ1bnM6MCBmcmFtZTowCiAgICAgICAgICBUWCBwYWNrZXRzOjMxMDA0OSBlcnJvcnM6MCBk
cm9wcGVkOjAgb3ZlcnJ1bnM6MCBjYXJyaWVyOjAKICAgICAgICAgIGNvbGxpc2lvbnM6MCB0eHF1
ZXVlbGVuOjAgCiAgICAgICAgICBSWCBieXRlczozOTAzOTM3MjMgKDM3Mi4zIE1pQikgIFRYIGJ5
dGVzOjIwNjQzODQ0ICgxOS42IE1pQikKCnZsYW4yICAgICBMaW5rIGVuY2FwOkV0aGVybmV0ICBI
V2FkZHIgMTE6MjI6MzM6NDQ6NTU6QTggIAogICAgICAgICAgaW5ldDYgYWRkcjogZmU4MDo6MjI0
ZTo3ZmZmOmZlYWI6M2FhOC82NCBTY29wZTpMaW5rCiAgICAgICAgICBVUCBCUk9BRENBU1QgUlVO
TklORyBQUk9NSVNDIEFMTE1VTFRJIE1VTFRJQ0FTVCAgTVRVOjE1MDAgIE1ldHJpYzoxCiAgICAg
ICAgICBSWCBwYWNrZXRzOjAgZXJyb3JzOjAgZHJvcHBlZDowIG92ZXJydW5zOjAgZnJhbWU6MAog
ICAgICAgICAgVFggcGFja2V0czowIGVycm9yczowIGRyb3BwZWQ6MCBvdmVycnVuczowIGNhcnJp
ZXI6MAogICAgICAgICAgY29sbGlzaW9uczowIHR4cXVldWVsZW46MCAKICAgICAgICAgIFJYIGJ5
dGVzOjAgKDAuMCBCKSAgVFggYnl0ZXM6MCAoMC4wIEIpCgoKCgoKYnIwICAgICAgIExpbmsgZW5j
YXA6RXRoZXJuZXQgIEhXYWRkciAxMToyMjozMzo0NDo1NTpBOCAgCiAgICAgICAgICBpbmV0IGFk
ZHI6MTkyLjE2OC4xLjEgIEJjYXN0OjE5Mi4xNjguMS4yNTUgIE1hc2s6MjU1LjI1NS4yNTUuMAog
ICAgICAgICAgaW5ldDYgYWRkcjogZmU4MDo6MjI0ZTo3ZmZmOmZlYWI6M2FhOC82NCBTY29wZTpM
aW5rCiAgICAgICAgICBVUCBCUk9BRENBU1QgUlVOTklORyBNVUxUSUNBU1QgIE1UVToxNTAwICBN
ZXRyaWM6MQogICAgICAgICAgUlggcGFja2V0czozNjcwIGVycm9yczowIGRyb3BwZWQ6MCBvdmVy
cnVuczowIGZyYW1lOjAKICAgICAgICAgIFRYIHBhY2tldHM6NDAwNCBlcnJvcnM6MCBkcm9wcGVk
OjAgb3ZlcnJ1bnM6MCBjYXJyaWVyOjAKICAgICAgICAgIGNvbGxpc2lvbnM6MCB0eHF1ZXVlbGVu
OjAgCiAgICAgICAgICBSWCBieXRlczozNzAxNDYgKDM2MS40IEtpQikgIFRYIGJ5dGVzOjM1MTY4
NTggKDMuMyBNaUIpCgpldGgwICAgICAgTGluayBlbmNhcDpFdGhlcm5ldCAgSFdhZGRyIDExOjIy
OjMzOjQ0OjU1OkE5ICAKICAgICAgICAgIGluZXQgYWRkcjoxOTIuMTY4LjUuMiAgQmNhc3Q6MTky
LjE2OC41LjI1NSAgTWFzazoyNTUuMjU1LjI1NS4wCiAgICAgICAgICBpbmV0NiBhZGRyOiBmZTgw
OjoyMjRlOjdmZmY6ZmVhYjozYWE5LzY0IFNjb3BlOkxpbmsKICAgICAgICAgIFVQIEJST0FEQ0FT
VCBSVU5OSU5HIFBST01JU0MgQUxMTVVMVEkgTVVMVElDQVNUICBNVFU6MTUwMCAgTWV0cmljOjEK
ICAgICAgICAgIFJYIHBhY2tldHM6MzYyOTQ2IGVycm9yczowIGRyb3BwZWQ6MCBvdmVycnVuczow
IGZyYW1lOjAKICAgICAgICAgIFRYIHBhY2tldHM6MzY3MTgxMiBlcnJvcnM6MCBkcm9wcGVkOjAg
b3ZlcnJ1bnM6MCBjYXJyaWVyOjAKICAgICAgICAgIGNvbGxpc2lvbnM6MCB0eHF1ZXVlbGVuOjEw
MDAgCiAgICAgICAgICBSWCBieXRlczoyMzIzNjU3NCAoMjIuMSBNaUIpICBUWCBieXRlczoxMTkx
OTc0NDQ1ICgxLjEgR2lCKQogICAgICAgICAgSW50ZXJydXB0OjQgQmFzZSBhZGRyZXNzOjB4MjAw
MCAKCmV0aDEgICAgICBMaW5rIGVuY2FwOkV0aGVybmV0ICBIV2FkZHIgMTE6MjI6MzM6NDQ6NTU6
QTggIAogICAgICAgICAgaW5ldDYgYWRkcjogZmU4MDo6MjI0ZTo3ZmZmOmZlYWI6M2FhOC82NCBT
Y29wZTpMaW5rCiAgICAgICAgICBVUCBCUk9BRENBU1QgUlVOTklORyBNVUxUSUNBU1QgIE1UVTox
NTAwICBNZXRyaWM6MQogICAgICAgICAgUlggcGFja2V0czowIGVycm9yczowIGRyb3BwZWQ6MCBv
dmVycnVuczowIGZyYW1lOjQyNAogICAgICAgICAgVFggcGFja2V0czowIGVycm9yczo2NSBkcm9w
cGVkOjAgb3ZlcnJ1bnM6MCBjYXJyaWVyOjAKICAgICAgICAgIGNvbGxpc2lvbnM6MCB0eHF1ZXVl
bGVuOjEwMDAgCiAgICAgICAgICBSWCBieXRlczowICgwLjAgQikgIFRYIGJ5dGVzOjAgKDAuMCBC
KQogICAgICAgICAgSW50ZXJydXB0OjMgQmFzZSBhZGRyZXNzOjB4ODAwMCAKCmV0aDIgICAgICBM
aW5rIGVuY2FwOkV0aGVybmV0ICBIV2FkZHIgMTE6MjI6MzM6NDQ6NTU6QTcgIAogICAgICAgICAg
aW5ldDYgYWRkcjogZmU4MDo6MjI0ZTo3ZmZmOmZlYWI6M2FhNy82NCBTY29wZTpMaW5rCiAgICAg
ICAgICBVUCBCUk9BRENBU1QgUlVOTklORyBNVUxUSUNBU1QgIE1UVToxNTAwICBNZXRyaWM6MQog
ICAgICAgICAgUlggcGFja2V0czowIGVycm9yczowIGRyb3BwZWQ6MCBvdmVycnVuczowIGZyYW1l
OjAKICAgICAgICAgIFRYIHBhY2tldHM6MCBlcnJvcnM6NTQgZHJvcHBlZDowIG92ZXJydW5zOjAg
Y2FycmllcjowCiAgICAgICAgICBjb2xsaXNpb25zOjAgdHhxdWV1ZWxlbjoxMDAwIAogICAgICAg
ICAgUlggYnl0ZXM6MCAoMC4wIEIpICBUWCBieXRlczowICgwLjAgQikKICAgICAgICAgIEludGVy
cnVwdDo1IEJhc2UgYWRkcmVzczoweDgwMDAgCgpsbyAgICAgICAgTGluayBlbmNhcDpMb2NhbCBM
b29wYmFjayAgCiAgICAgICAgICBpbmV0IGFkZHI6MTI3LjAuMC4xICBNYXNrOjI1NS4wLjAuMAog
ICAgICAgICAgaW5ldDYgYWRkcjogOjoxLzEyOCBTY29wZTpIb3N0CiAgICAgICAgICBVUCBMT09Q
QkFDSyBSVU5OSU5HIE1VTFRJQ0FTVCAgTVRVOjE2NDM2ICBNZXRyaWM6MQogICAgICAgICAgUlgg
cGFja2V0czoxMTkgZXJyb3JzOjAgZHJvcHBlZDowIG92ZXJydW5zOjAgZnJhbWU6MAogICAgICAg
ICAgVFggcGFja2V0czoxMTkgZXJyb3JzOjAgZHJvcHBlZDowIG92ZXJydW5zOjAgY2Fycmllcjow
CiAgICAgICAgICBjb2xsaXNpb25zOjAgdHhxdWV1ZWxlbjowIAogICAgICAgICAgUlggYnl0ZXM6
MTI1MzIgKDEyLjIgS2lCKSAgVFggYnl0ZXM6MTI1MzIgKDEyLjIgS2lCKQoKdmxhbjEgICAgIExp
bmsgZW5jYXA6RXRoZXJuZXQgIEhXYWRkciAxMToyMjozMzo0NDo1NTpBOCAgCiAgICAgICAgICBp
bmV0NiBhZGRyOiBmZTgwOjoyMjRlOjdmZmY6ZmVhYjozYWE4LzY0IFNjb3BlOkxpbmsKICAgICAg
ICAgIFVQIEJST0FEQ0FTVCBSVU5OSU5HIFBST01JU0MgQUxMTVVMVEkgTVVMVElDQVNUICBNVFU6
MTUwMCAgTWV0cmljOjEKICAgICAgICAgIFJYIHBhY2tldHM6MzY3MjY5NyBlcnJvcnM6MCBkcm9w
cGVkOjAgb3ZlcnJ1bnM6MCBmcmFtZTowCiAgICAgICAgICBUWCBwYWNrZXRzOjM2MzkxNCBlcnJv
cnM6MCBkcm9wcGVkOjAgb3ZlcnJ1bnM6MCBjYXJyaWVyOjAKICAgICAgICAgIGNvbGxpc2lvbnM6
MCB0eHF1ZXVlbGVuOjAgCiAgICAgICAgICBSWCBieXRlczoxMjA2NzQ3MzQ2ICgxLjEgR2lCKSAg
VFggYnl0ZXM6MjQwOTE2NjkgKDIyLjkgTWlCKQoKdmxhbjIgICAgIExpbmsgZW5jYXA6RXRoZXJu
ZXQgIEhXYWRkciAxMToyMjozMzo0NDo1NTpBOCAgCiAgICAgICAgICBpbmV0NiBhZGRyOiBmZTgw
OjoyMjRlOjdmZmY6ZmVhYjozYWE4LzY0IFNjb3BlOkxpbmsKICAgICAgICAgIFVQIEJST0FEQ0FT
VCBSVU5OSU5HIFBST01JU0MgQUxMTVVMVEkgTVVMVElDQVNUICBNVFU6MTUwMCAgTWV0cmljOjEK
ICAgICAgICAgIFJYIHBhY2tldHM6MCBlcnJvcnM6MCBkcm9wcGVkOjAgb3ZlcnJ1bnM6MCBmcmFt
ZTowCiAgICAgICAgICBUWCBwYWNrZXRzOjAgZXJyb3JzOjAgZHJvcHBlZDowIG92ZXJydW5zOjAg
Y2FycmllcjowCiAgICAgICAgICBjb2xsaXNpb25zOjAgdHhxdWV1ZWxlbjowIAogICAgICAgICAg
UlggYnl0ZXM6MCAoMC4wIEIpICBUWCBieXRlczowICgwLjAgQikK
--089e01537e42db9d1d04e43f324f--
