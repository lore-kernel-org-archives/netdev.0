From: =?UTF-8?B?RXJlbiBUw7xya2F5?= <erent@skyatlas.com>
Subject: Re: PROBLEM: Bnx2x Checksum/Length Error Over GRE Tunnel
Date: Wed, 04 Feb 2015 12:00:46 +0200
Message-ID: <54D1EDCE.3030602@skyatlas.com>
References: <54D0A345.2030108@skyatlas.com> <54D10DFE.1070604@skyatlas.com> <1422989196.907.34.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030809010206010003050709"
Cc: Network Development <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailfw.csoftintl.com ([209.11.253.18]:36378 "EHLO
	fmvm01.lax10.vpls.net" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S932605AbbBDKAw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 05:00:52 -0500
In-Reply-To: <1422989196.907.34.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030809010206010003050709
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit

On 03-02-2015 20:46, Eric Dumazet wrote:
> Can you please send : ifconfig -a, as I suspect an MTU issue

You are right. Previously I set gre interface MTU to 1500 and NIC interface had 9000 MTU.
I was able to get 3Gbit in a single flow, and 5-6Gbit in parallel. When I recreated the interfaces,
the MTU of gre was set 8976 and I can get 9.5Gbit in a single flow. The reason why I set 1500 on
gre interface was to mimic openvswitch setup as the main problem I have been investigating is VM
network performance problem (they have 3Gbit throughput). I have OpenStack installation using OVS with GRE
and those interfaces are set 1500 MTU by default. I tried to test iproute2 implementation with 1500.

With correct MTU setting in gre interface, it seems to work without checksumming and offloading
but I haven't tested my original OVS setting. I will tweak OVS bridge MTU settings and try to get
it work. If baremetal-to-baremetal works, I suspect there is an issue with OVS setup.
However, when I enable tx on, netperf cannot even connect.

"ifconfig -a" and "ovs-vsctl show" result is attached.

I am not sure if tx offloading will affect the VM performance. Regardless of OVS problem, there seems to be a
bug with segmentation offloading as it's only possible to use the interface with "tx off". I have compiled the
kernel with debugging on and I can enable debugging on related parts in the kernel for further information.

> Here I easily reach line rate with a single flow.
> 
> ip tunnel add gre1 mode gre remote 10.246.11.52 local 10.246.11.51
> ip link set gre1 up
> ip addr add 7.7.8.51/24 dev gre1

ip tunnel add gre1 mode gre remote 10.20.0.162 local 10.20.0.161
ip l set gre1 up
ip addr add 7.7.8.161/24 dev gre1

root@compute1vx:~# ip r get 7.7.8.162
7.7.8.162 dev gre1  src 7.7.8.161 
    cache  expires 539sec mtu 8976


root@compute1vx:~# ethtool -K em1 tx off
Actual changes:
tx-checksumming: off
        tx-checksum-ipv4: off
        tx-checksum-ipv6: off
tcp-segmentation-offload: off
        tx-tcp-segmentation: off [requested on]
        tx-tcp-ecn-segmentation: off [requested on]
        tx-tcp6-segmentation: off [requested on]

root@compute1vx:~# netperf -H 7.7.8.162 -Cc                                                                                                                                                                                                   
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 7.7.8.162 () port 0 AF_INET : demo
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB

 87380  16384  16384    10.00      9534.00   4.05     4.39     0.835   0.906  


root@compute1vx:~# ethtool -K em1 tx on
Actual changes:
tx-checksumming: on
        tx-checksum-ipv4: on
        tx-checksum-ipv6: on
tcp-segmentation-offload: on
        tx-tcp-segmentation: on
        tx-tcp-ecn-segmentation: on
        tx-tcp6-segmentation: on

root@compute1vx:~# netperf -H 7.7.8.162 -Cc
establish control: are you sure there is a netserver listening on 7.7.8.162 at port 12865?
establish_control could not establish the control connection from 0.0.0.0 port 0 address family AF_UNSPEC to 7.7.8.162 port 12865 address family AF_INET

Regards,
Eren

-- 
System Administrator
https://skyatlas.com/

--------------030809010206010003050709
Content-Type: text/plain; charset=UTF-8;
 name="ifconfig-and-ovs-result.txt"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="ifconfig-and-ovs-result.txt"

cm9vdEBjb21wdXRlMXZ4On4jIGlmY29uZmlnIC1hCmJyLWludCAgICBMaW5rIGVuY2FwOkV0
aGVybmV0ICBIV2FkZHIgNjI6NmU6YTQ6NDU6NzY6NGQgIAogICAgICAgICAgaW5ldDYgYWRk
cjogZmU4MDo6ZTg5NzpmMGZmOmZlZTM6NWEwZC82NCBTY29wZTpMaW5rCiAgICAgICAgICBV
UCBCUk9BRENBU1QgUlVOTklORyAgTVRVOjE1MDAgIE1ldHJpYzoxCiAgICAgICAgICBSWCBw
YWNrZXRzOjUwIGVycm9yczowIGRyb3BwZWQ6MCBvdmVycnVuczowIGZyYW1lOjAKICAgICAg
ICAgIFRYIHBhY2tldHM6OCBlcnJvcnM6MCBkcm9wcGVkOjAgb3ZlcnJ1bnM6MCBjYXJyaWVy
OjAKICAgICAgICAgIGNvbGxpc2lvbnM6MCB0eHF1ZXVlbGVuOjAgCiAgICAgICAgICBSWCBi
eXRlczozODU2ICgzLjggS0IpICBUWCBieXRlczo2NDggKDY0OC4wIEIpCgpici10dW4gICAg
TGluayBlbmNhcDpFdGhlcm5ldCAgSFdhZGRyIDcyOjUyOmY3OjYwOmJjOjRhICAKICAgICAg
ICAgIGluZXQ2IGFkZHI6IGZlODA6OjcwZDg6MjdmZjpmZTU3OjM2ZmQvNjQgU2NvcGU6TGlu
awogICAgICAgICAgVVAgQlJPQURDQVNUIFJVTk5JTkcgIE1UVToxNTAwICBNZXRyaWM6MQog
ICAgICAgICAgUlggcGFja2V0czowIGVycm9yczowIGRyb3BwZWQ6MCBvdmVycnVuczowIGZy
YW1lOjAKICAgICAgICAgIFRYIHBhY2tldHM6OCBlcnJvcnM6MCBkcm9wcGVkOjAgb3ZlcnJ1
bnM6MCBjYXJyaWVyOjAKICAgICAgICAgIGNvbGxpc2lvbnM6MCB0eHF1ZXVlbGVuOjAgCiAg
ICAgICAgICBSWCBieXRlczowICgwLjAgQikgIFRYIGJ5dGVzOjY0OCAoNjQ4LjAgQikKCmVt
MSAgICAgICBMaW5rIGVuY2FwOkV0aGVybmV0ICBIV2FkZHIgMDA6MjY6NTU6MWY6OWQ6YTAg
IAogICAgICAgICAgaW5ldCBhZGRyOjEwLjIwLjAuMTYxICBCY2FzdDoxMC4yMC4wLjI1NSAg
TWFzazoyNTUuMjU1LjI1NS4wCiAgICAgICAgICBpbmV0NiBhZGRyOiBmZTgwOjoyMjY6NTVm
ZjpmZTFmOjlkYTAvNjQgU2NvcGU6TGluawogICAgICAgICAgVVAgQlJPQURDQVNUIFJVTk5J
TkcgTVVMVElDQVNUICBNVFU6OTAwMCAgTWV0cmljOjEKICAgICAgICAgIFJYIHBhY2tldHM6
Mjc3NTk2NyBlcnJvcnM6MTIwNCBkcm9wcGVkOjAgb3ZlcnJ1bnM6MTIwNCBmcmFtZTowCiAg
ICAgICAgICBUWCBwYWNrZXRzOjE5NTQ0NjA0IGVycm9yczowIGRyb3BwZWQ6MCBvdmVycnVu
czowIGNhcnJpZXI6MAogICAgICAgICAgY29sbGlzaW9uczowIHR4cXVldWVsZW46MTAwMCAK
ICAgICAgICAgIFJYIGJ5dGVzOjMwOTg3OTU1NCAoMzA5LjggTUIpICBUWCBieXRlczo4MDcw
OTI1MTUwNSAoODAuNyBHQikKICAgICAgICAgIEludGVycnVwdDo0MiBNZW1vcnk6ZmIwMDAw
MDAtZmI3ZmZmZmYgCgplbTIgICAgICAgTGluayBlbmNhcDpFdGhlcm5ldCAgSFdhZGRyIDAw
OjI2OjU1OjFmOjlkOmE0ICAKICAgICAgICAgIGluZXQgYWRkcjoxOTIuMTY4Ljg4LjYxICBC
Y2FzdDoxOTIuMTY4Ljg4LjI1NSAgTWFzazoyNTUuMjU1LjI1NS4wCiAgICAgICAgICBpbmV0
NiBhZGRyOiBmZTgwOjoyMjY6NTVmZjpmZTFmOjlkYTQvNjQgU2NvcGU6TGluawogICAgICAg
ICAgVVAgQlJPQURDQVNUIFJVTk5JTkcgTVVMVElDQVNUICBNVFU6MTUwMCAgTWV0cmljOjEK
ICAgICAgICAgIFJYIHBhY2tldHM6OTgxOTk2IGVycm9yczowIGRyb3BwZWQ6MCBvdmVycnVu
czowIGZyYW1lOjAKICAgICAgICAgIFRYIHBhY2tldHM6NTA0NDYzIGVycm9yczowIGRyb3Bw
ZWQ6MCBvdmVycnVuczowIGNhcnJpZXI6MAogICAgICAgICAgY29sbGlzaW9uczowIHR4cXVl
dWVsZW46MTAwMCAKICAgICAgICAgIFJYIGJ5dGVzOjE0MjM4OTcwNjEgKDEuNCBHQikgIFRY
IGJ5dGVzOjM4ODI5MTc2ICgzOC44IE1CKQogICAgICAgICAgSW50ZXJydXB0OjUzIE1lbW9y
eTpmYTAwMDAwMC1mYTdmZmZmZiAKCmdyZTAgICAgICBMaW5rIGVuY2FwOlVOU1BFQyAgSFdh
ZGRyIDAwLTAwLTAwLTAwLTMyLTM2LTNBLTM1LTAwLTAwLTAwLTAwLTAwLTAwLTAwLTAwICAK
ICAgICAgICAgIE5PQVJQICBNVFU6MTQ3NiAgTWV0cmljOjEKICAgICAgICAgIFJYIHBhY2tl
dHM6MCBlcnJvcnM6MCBkcm9wcGVkOjAgb3ZlcnJ1bnM6MCBmcmFtZTowCiAgICAgICAgICBU
WCBwYWNrZXRzOjAgZXJyb3JzOjAgZHJvcHBlZDowIG92ZXJydW5zOjAgY2FycmllcjowCiAg
ICAgICAgICBjb2xsaXNpb25zOjAgdHhxdWV1ZWxlbjowIAogICAgICAgICAgUlggYnl0ZXM6
MCAoMC4wIEIpICBUWCBieXRlczowICgwLjAgQikKCmdyZTEgICAgICBMaW5rIGVuY2FwOlVO
U1BFQyAgSFdhZGRyIDBBLTE0LTAwLUExLTAwLTAwLTAwLTAwLTAwLTAwLTAwLTAwLTAwLTAw
LTAwLTAwICAKICAgICAgICAgIGluZXQgYWRkcjo3LjcuOC4xNjEgIFAtdC1QOjcuNy44LjE2
MSAgTWFzazoyNTUuMjU1LjI1NS4wCiAgICAgICAgICBpbmV0NiBhZGRyOiBmZTgwOjo1ZWZl
OmExNDphMS82NCBTY29wZTpMaW5rCiAgICAgICAgICBVUCBQT0lOVE9QT0lOVCBSVU5OSU5H
IE5PQVJQICBNVFU6ODk3NiAgTWV0cmljOjEKICAgICAgICAgIFJYIHBhY2tldHM6MjU0MTk4
NCBlcnJvcnM6MCBkcm9wcGVkOjAgb3ZlcnJ1bnM6MCBmcmFtZTowCiAgICAgICAgICBUWCBw
YWNrZXRzOjE3MDQyNTYgZXJyb3JzOjAgZHJvcHBlZDowIG92ZXJydW5zOjAgY2Fycmllcjow
CiAgICAgICAgICBjb2xsaXNpb25zOjAgdHhxdWV1ZWxlbjowIAogICAgICAgICAgUlggYnl0
ZXM6MTMzODc3NDk2ICgxMzMuOCBNQikgIFRYIGJ5dGVzOjc4OTQ0MTcyNTEyICg3OC45IEdC
KQoKZ3JldGFwMCAgIExpbmsgZW5jYXA6RXRoZXJuZXQgIEhXYWRkciAwMDowMDowMDowMDow
MDowMCAgCiAgICAgICAgICBCUk9BRENBU1QgTVVMVElDQVNUICBNVFU6MTQ2MiAgTWV0cmlj
OjEKICAgICAgICAgIFJYIHBhY2tldHM6MCBlcnJvcnM6MCBkcm9wcGVkOjAgb3ZlcnJ1bnM6
MCBmcmFtZTowCiAgICAgICAgICBUWCBwYWNrZXRzOjAgZXJyb3JzOjAgZHJvcHBlZDowIG92
ZXJydW5zOjAgY2FycmllcjowCiAgICAgICAgICBjb2xsaXNpb25zOjAgdHhxdWV1ZWxlbjox
MDAwIAogICAgICAgICAgUlggYnl0ZXM6MCAoMC4wIEIpICBUWCBieXRlczowICgwLjAgQikK
CmxvICAgICAgICBMaW5rIGVuY2FwOkxvY2FsIExvb3BiYWNrICAKICAgICAgICAgIGluZXQg
YWRkcjoxMjcuMC4wLjEgIE1hc2s6MjU1LjAuMC4wCiAgICAgICAgICBpbmV0NiBhZGRyOiA6
OjEvMTI4IFNjb3BlOkhvc3QKICAgICAgICAgIFVQIExPT1BCQUNLIFJVTk5JTkcgIE1UVTo2
NTUzNiAgTWV0cmljOjEKICAgICAgICAgIFJYIHBhY2tldHM6MTUgZXJyb3JzOjAgZHJvcHBl
ZDowIG92ZXJydW5zOjAgZnJhbWU6MAogICAgICAgICAgVFggcGFja2V0czoxNSBlcnJvcnM6
MCBkcm9wcGVkOjAgb3ZlcnJ1bnM6MCBjYXJyaWVyOjAKICAgICAgICAgIGNvbGxpc2lvbnM6
MCB0eHF1ZXVlbGVuOjAgCiAgICAgICAgICBSWCBieXRlczoxODc4ICgxLjggS0IpICBUWCBi
eXRlczoxODc4ICgxLjggS0IpCgpvdnMtc3lzdGVtIExpbmsgZW5jYXA6RXRoZXJuZXQgIEhX
YWRkciBmYTo2OToxYTo1Mzo0Zjo3MyAgCiAgICAgICAgICBCUk9BRENBU1QgTVVMVElDQVNU
ICBNVFU6MTUwMCAgTWV0cmljOjEKICAgICAgICAgIFJYIHBhY2tldHM6MCBlcnJvcnM6MCBk
cm9wcGVkOjAgb3ZlcnJ1bnM6MCBmcmFtZTowCiAgICAgICAgICBUWCBwYWNrZXRzOjAgZXJy
b3JzOjAgZHJvcHBlZDowIG92ZXJydW5zOjAgY2FycmllcjowCiAgICAgICAgICBjb2xsaXNp
b25zOjAgdHhxdWV1ZWxlbjowIAogICAgICAgICAgUlggYnl0ZXM6MCAoMC4wIEIpICBUWCBi
eXRlczowICgwLjAgQikKCnFicmU5MGFhNmJmLTM2IExpbmsgZW5jYXA6RXRoZXJuZXQgIEhX
YWRkciAzYTpkNjoyYzpiYTowOTo1NyAgCiAgICAgICAgICBpbmV0NiBhZGRyOiBmZTgwOjoz
ODdjOjRiZmY6ZmU2Nzo5MDRmLzY0IFNjb3BlOkxpbmsKICAgICAgICAgIFVQIEJST0FEQ0FT
VCBSVU5OSU5HIE1VTFRJQ0FTVCAgTVRVOjE1MDAgIE1ldHJpYzoxCiAgICAgICAgICBSWCBw
YWNrZXRzOjQ0IGVycm9yczowIGRyb3BwZWQ6MCBvdmVycnVuczowIGZyYW1lOjAKICAgICAg
ICAgIFRYIHBhY2tldHM6OCBlcnJvcnM6MCBkcm9wcGVkOjAgb3ZlcnJ1bnM6MCBjYXJyaWVy
OjAKICAgICAgICAgIGNvbGxpc2lvbnM6MCB0eHF1ZXVlbGVuOjAgCiAgICAgICAgICBSWCBi
eXRlczoyNzYwICgyLjcgS0IpICBUWCBieXRlczo2NDggKDY0OC4wIEIpCgpxdmJlOTBhYTZi
Zi0zNiBMaW5rIGVuY2FwOkV0aGVybmV0ICBIV2FkZHIgM2E6ZDY6MmM6YmE6MDk6NTcgIAog
ICAgICAgICAgaW5ldDYgYWRkcjogZmU4MDo6MzhkNjoyY2ZmOmZlYmE6OTU3LzY0IFNjb3Bl
OkxpbmsKICAgICAgICAgIFVQIEJST0FEQ0FTVCBSVU5OSU5HIFBST01JU0MgTVVMVElDQVNU
ICBNVFU6MTUwMCAgTWV0cmljOjEKICAgICAgICAgIFJYIHBhY2tldHM6NDUgZXJyb3JzOjAg
ZHJvcHBlZDowIG92ZXJydW5zOjAgZnJhbWU6MAogICAgICAgICAgVFggcGFja2V0czoxNSBl
cnJvcnM6MCBkcm9wcGVkOjAgb3ZlcnJ1bnM6MCBjYXJyaWVyOjAKICAgICAgICAgIGNvbGxp
c2lvbnM6MCB0eHF1ZXVlbGVuOjEwMDAgCiAgICAgICAgICBSWCBieXRlczozNDY2ICgzLjQg
S0IpICBUWCBieXRlczoxMjA2ICgxLjIgS0IpCgpxdm9lOTBhYTZiZi0zNiBMaW5rIGVuY2Fw
OkV0aGVybmV0ICBIV2FkZHIgZDI6ZDc6Nzc6OWE6ZDk6MWUgIAogICAgICAgICAgaW5ldDYg
YWRkcjogZmU4MDo6ZDBkNzo3N2ZmOmZlOWE6ZDkxZS82NCBTY29wZTpMaW5rCiAgICAgICAg
ICBVUCBCUk9BRENBU1QgUlVOTklORyBQUk9NSVNDIE1VTFRJQ0FTVCAgTVRVOjE1MDAgIE1l
dHJpYzoxCiAgICAgICAgICBSWCBwYWNrZXRzOjE1IGVycm9yczowIGRyb3BwZWQ6MCBvdmVy
cnVuczowIGZyYW1lOjAKICAgICAgICAgIFRYIHBhY2tldHM6NDUgZXJyb3JzOjAgZHJvcHBl
ZDowIG92ZXJydW5zOjAgY2FycmllcjowCiAgICAgICAgICBjb2xsaXNpb25zOjAgdHhxdWV1
ZWxlbjoxMDAwIAogICAgICAgICAgUlggYnl0ZXM6MTIwNiAoMS4yIEtCKSAgVFggYnl0ZXM6
MzQ2NiAoMy40IEtCKQoKdmlyYnIwICAgIExpbmsgZW5jYXA6RXRoZXJuZXQgIEhXYWRkciA4
ZTo1NDo3MDpjYjo4YTpmYyAgCiAgICAgICAgICBpbmV0IGFkZHI6MTkyLjE2OC4xMjIuMSAg
QmNhc3Q6MTkyLjE2OC4xMjIuMjU1ICBNYXNrOjI1NS4yNTUuMjU1LjAKICAgICAgICAgIFVQ
IEJST0FEQ0FTVCBNVUxUSUNBU1QgIE1UVToxNTAwICBNZXRyaWM6MQogICAgICAgICAgUlgg
cGFja2V0czowIGVycm9yczowIGRyb3BwZWQ6MCBvdmVycnVuczowIGZyYW1lOjAKICAgICAg
ICAgIFRYIHBhY2tldHM6MCBlcnJvcnM6MCBkcm9wcGVkOjAgb3ZlcnJ1bnM6MCBjYXJyaWVy
OjAKICAgICAgICAgIGNvbGxpc2lvbnM6MCB0eHF1ZXVlbGVuOjAgCiAgICAgICAgICBSWCBi
eXRlczowICgwLjAgQikgIFRYIGJ5dGVzOjAgKDAuMCBCKQoKCnJvb3RAY29tcHV0ZTF2eDp+
IyBvdnMtdnNjdGwgc2hvdwpkYjM4NTZjNC0zYWY1LTQ1YWYtOTY3Ni1kZWJjMzc5YTNlOWEK
ICAgIEJyaWRnZSBici1pbnQKICAgICAgICBmYWlsX21vZGU6IHNlY3VyZQogICAgICAgIFBv
cnQgcGF0Y2gtdHVuCiAgICAgICAgICAgIEludGVyZmFjZSBwYXRjaC10dW4KICAgICAgICAg
ICAgICAgIHR5cGU6IHBhdGNoCiAgICAgICAgICAgICAgICBvcHRpb25zOiB7cGVlcj1wYXRj
aC1pbnR9CiAgICAgICAgUG9ydCBici1pbnQKICAgICAgICAgICAgSW50ZXJmYWNlIGJyLWlu
dAogICAgICAgICAgICAgICAgdHlwZTogaW50ZXJuYWwKICAgICAgICBQb3J0ICJxdm9lOTBh
YTZiZi0zNiIKICAgICAgICAgICAgdGFnOiAxCiAgICAgICAgICAgIEludGVyZmFjZSAicXZv
ZTkwYWE2YmYtMzYiCiAgICBCcmlkZ2UgYnItdHVuCiAgICAgICAgUG9ydCBici10dW4KICAg
ICAgICAgICAgSW50ZXJmYWNlIGJyLXR1bgogICAgICAgICAgICAgICAgdHlwZTogaW50ZXJu
YWwKICAgICAgICBQb3J0IHBhdGNoLWludAogICAgICAgICAgICBJbnRlcmZhY2UgcGF0Y2gt
aW50CiAgICAgICAgICAgICAgICB0eXBlOiBwYXRjaAogICAgICAgICAgICAgICAgb3B0aW9u
czoge3BlZXI9cGF0Y2gtdHVufQogICAgICAgIFBvcnQgImdyZS0wYTE0MDBhMiIKICAgICAg
ICAgICAgSW50ZXJmYWNlICJncmUtMGExNDAwYTIiCiAgICAgICAgICAgICAgICB0eXBlOiBn
cmUKICAgICAgICAgICAgICAgIG9wdGlvbnM6IHtkZl9kZWZhdWx0PSJ0cnVlIiwgaW5fa2V5
PWZsb3csIGxvY2FsX2lwPSIxMC4yMC4wLjE2MSIsIG91dF9rZXk9ZmxvdywgcmVtb3RlX2lw
PSIxMC4yMC4wLjE2MiJ9CiAgICBvdnNfdmVyc2lvbjogIjIuMC4yIgoK
--------------030809010206010003050709--
