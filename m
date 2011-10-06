From: Jasper Spaans <spaans@fox-it.com>
Subject: bnx2 rxhash
Date: Thu, 6 Oct 2011 11:57:25 +0200
Message-ID: <4E8D7B85.7060702@fox-it.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pkcs7-signature";
	micalg=sha1; boundary="------------ms040706040909040606020901"
Cc: <mchan@broadcom.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.fox-it.com ([178.250.144.131]:11906 "EHLO ns2.fox-it.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754781Ab1JFKGZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Oct 2011 06:06:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--------------ms040706040909040606020901
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hi list,

I'm doing some experiments with rxhash and packet capturing, and I'm
seeing some unexpected results when receiving data (which happens in
promiscuous mode). This behaviour seems to be similar to that seen in
the question asked previously by Christophe Ngo Van Duc:
http://kerneltrap.com/mailarchive/linux-netdev/2010/7/2/6280474

The data I'm processing consists of (almost 100% tcp) traffic between an
ssl-offloader and a cluster of webservers, so the range of mac-addresses
is rather limited. This ssl-offloader does preserve the IP-address and
tcp ports of the clients, so if the rxhash is based on that data, it
should be distributed evenly.

Is there anything I can do about this?


Thanks,
Jasper



The raw data:

spaans@dhcp-074:~$ uname -a
Linux dhcp-074 3.0.4 #7 SMP Tue Sep 13 12:52:01 CEST 2011 x86_64 GNU/Linu=
x

spaans@dhcp-074:~$ grep eth6 /proc/interrupts  | cut -b -30,270-
 142:      57070          0      PCI-MSI-edge      eth6-0
 143:          0          0      PCI-MSI-edge      eth6-1
 144:          0          0      PCI-MSI-edge      eth6-2
 145:          0          0      PCI-MSI-edge      eth6-3
 146:          0          0      PCI-MSI-edge      eth6-4
 147:      17127          0      PCI-MSI-edge      eth6-5
 148:         24          0      PCI-MSI-edge      eth6-6
 149:          0          0      PCI-MSI-edge      eth6-7

This is rather different from the behaviour I get with an intel card:

spaans@dhcp-074:~$ grep eth2 /proc/interrupts  | cut -b -30,270-
  98:          3          0      PCI-MSI-edge      eth2
  99:       4492          0      PCI-MSI-edge      eth2-TxRx-0
 100:       4647          0      PCI-MSI-edge      eth2-TxRx-1
 101:       4369          0      PCI-MSI-edge      eth2-TxRx-2
 102:       4579          0      PCI-MSI-edge      eth2-TxRx-3
 103:       4184          0      PCI-MSI-edge      eth2-TxRx-4
 104:      51268          0      PCI-MSI-edge      eth2-TxRx-5
 105:       4610          0      PCI-MSI-edge      eth2-TxRx-6
 106:       4528          0      PCI-MSI-edge      eth2-TxRx-7

In both cases, only Tx-5 was used for sending data.


Information about the nics:

from dmesg:
[    5.857778] igb 0000:08:00.0: Intel(R) Gigabit Ethernet Network
Connection
[    5.857780] igb 0000:08:00.0: eth6: (PCIe:2.5Gb/s:Width x4)
00:1b:21:b9:b8:dc
[    5.858101] igb 0000:08:00.0: eth6: PBA No: G18771-002
[    5.858102] igb 0000:08:00.0: Using MSI-X interrupts. 8 rx queue(s),
8 tx queue(s)
note that this interface is renamed to eth2 after boot

spaans@dhcp-074:~$ ip link sh eth2
8: eth2: <BROADCAST,MULTICAST,PROMISC,UP,LOWER_UP> mtu 1500 qdisc mq
state UP qlen 1000
    link/ether 00:1b:21:b9:b8:dc brd ff:ff:ff:ff:ff:ff


spaans@dhcp-074:~$ sudo ethtool -k eth2
Offload parameters for eth2:
rx-checksumming: off
tx-checksumming: off
scatter-gather: off
tcp-segmentation-offload: off
udp-fragmentation-offload: off
generic-segmentation-offload: on
generic-receive-offload: off
large-receive-offload: off
ntuple-filters: off
receive-hashing: off
spaans@dhcp-074:~$ sudo ethtool -i eth2
driver: igb
version: 3.0.6-k2
firmware-version: 1.5-1
bus-info: 0000:08:00.0

vs

from dmesg:
[    5.090860] bnx2 0000:02:00.0: eth2: Broadcom NetXtreme II BCM5709
1000Base-T (C0) PCI Express found at mem d8000000, IRQ 32, node addr
18:03:73:fa:0f:0e
note that this interface is renamed to eth6 after boot

spaans@dhcp-074:~$ ip link sh eth6
4: eth6: <BROADCAST,MULTICAST,PROMISC,UP,LOWER_UP> mtu 1500 qdisc mq
state UP qlen 1000
    link/ether 18:03:73:fa:0f:0e brd ff:ff:ff:ff:ff:ff

spaans@dhcp-074:~$ sudo ethtool -k eth6
Offload parameters for eth6:
rx-checksumming: off
tx-checksumming: off
scatter-gather: off
tcp-segmentation-offload: off
udp-fragmentation-offload: off
generic-segmentation-offload: off
generic-receive-offload: off
large-receive-offload: off
ntuple-filters: off
receive-hashing: on
spaans@dhcp-074:~$ sudo ethtool -i eth6
driver: bnx2
version: 2.1.6
firmware-version: 6.2.12 bc 5.2.3 NCSI 2.0.11
bus-info: 0000:02:00.0


--=20
 /\____/\   Ir. Jasper Spaans     =20
 \   (_)/   Fox-IT Experts in IT Security!
  \    X    T: +31-15-2847999
   \  / \   M: +31-6-41588725  =20
    \/      KvK Haaglanden 27301624



--------------ms040706040909040606020901
Content-Type: application/pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"
Content-Description: S/MIME Cryptographic Signature

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIIFojCC
BZ4wggSGoAMCAQICAgDtMA0GCSqGSIb3DQEBBQUAMHsxEjAQBgNVBAMTCUZveC1JVCBDQTEd
MBsGCSqGSIb3DQEJARYOc29jQGZveC1pdC5jb20xDzANBgNVBAoTBkZveC1JVDERMA8GA1UE
BxMIUmlqc3dpamsxFTATBgNVBAgTDFp1aWQtSG9sbGFuZDELMAkGA1UEBhMCTkwwHhcNMTAx
MjAyMTIzOTEzWhcNMTMxMTE0MTUwMzUxWjBHMRYwFAYDVQQDEw1KYXNwZXIgU3BhYW5zMSAw
HgYJKoZIhvcNAQkBFhFzcGFhbnNAZm94LWl0LmNvbTELMAkGA1UEBhMCTkwwggIiMA0GCSqG
SIb3DQEBAQUAA4ICDwAwggIKAoICAQCV2jL4fYLEWizsk30IbwV7Uc3ESK3ctlcbSDBpBFH8
4dsL3+f6kKS6q+DJVbUhg1qZXNQzLP1O50Og2Ry2j9DThgYCBz0cmw8s7WR/F89DZ5NEg4UW
P1pPgRXtqnSJ7GQI4LVXtEe9NLlArgXMbNczt2Q2H89tPSVUmbp6ZxMMXZwBPTyUjC9u2u41
xyQVE6lhL0nvjU8yt3oJjYIhUuh6kXp6dkmQzVn/3zlVr3UBOmQXOx44MTBYXE1y9YEECODt
XzFgtvcWlW+kc3P6xUHA+QAsa7NugpYgUWQ6UTWcEQ6fBVROYhhUZyWjVibL7LD4Q85u+sEc
h6Khpt0A+ycg0jiXD5CqnLjpro8EysMQHwO8Z12qSo8DQY3AxeVPHGUvHTetDYhp3DavJrHp
ryx/LDT57NzZsR7l+dDBDZlK7N+dFwlcgCCsWqRvudkbS3FvE2Uoxx2u0hVOyFv04vuStkGA
lY/sHkrKT0IZnaQqPAcs3YsvRdUfKFFdSLLa1SIOfczwH3wMo1wju0jbp5iLY4vG6hL+OSY9
QSufl7Uia9ALDJsrL8MuznKlhrgW2IMLaGHC02zqJTELwShasv2cPC/F+8twSRlLNyQOA3G9
9FeUQbAn2FEXlqxCfzCoBq9YmVz5lJOQ/SPBAnrhwauZDTTHwSqnc4RgtOd0eAyi8QIDAQAB
o4IBXjCCAVowgaUGA1UdIwSBnTCBmoAUITvNG/EBZgl32Y7HpBKzbyMpCOmhf6R9MHsxEjAQ
BgNVBAMTCUZveC1JVCBDQTEdMBsGCSqGSIb3DQEJARYOc29jQGZveC1pdC5jb20xDzANBgNV
BAoTBkZveC1JVDERMA8GA1UEBxMIUmlqc3dpamsxFTATBgNVBAgTDFp1aWQtSG9sbGFuZDEL
MAkGA1UEBhMCTkyCAQAwDAYDVR0TAQH/BAIwADA6BgNVHR8EMzAxMC+gLaArhilodHRwOi8v
d3d3LnNlYy1pZC5uZXQvY2dpLWJpbi9jcmwucGw/MTAwNDAZBgNVHRIEEjAQgQ5zb2NAZm94
LWl0LmNvbTAOBgNVHQ8BAf8EBAMCA/gwHAYDVR0RBBUwE4ERc3BhYW5zQGZveC1pdC5jb20w
HQYDVR0OBBYEFD39p3bQ8VbZ+kA05vBzbBD6E7CaMA0GCSqGSIb3DQEBBQUAA4IBAQBM1SWd
bXz2dIqjaO2esYO49wkWh4XkrRDJtxusA1ZWE6jxb+3Pl59tC426BPa++MV1lUkGMyaUUOdo
frTu8rBipoiXcEEOajNdnnuqQefUErh4bBnLj7zsKzdOxJur6YYSA/HqG7zeyhCXybrCCyhs
RjNqpiJBxiu7SBUM75wRyz7m4HAlOwpCtQq3cxn11txaiA14qlPOLC1B9M3b9dTj/MyRkw0x
Xpdluwlj+jUSM8W2ofWnQ4IZ1IjsXHeoVExy15Lq7rUlTmVhu8JsGbPIiJU0T6h+4iVWVtpk
hngn8nM+Ggyz0IVmslL/i/SBECrHUsPDCol0BVechszjlbHUMYIElzCCBJMCAQEwgYEwezES
MBAGA1UEAxMJRm94LUlUIENBMR0wGwYJKoZIhvcNAQkBFg5zb2NAZm94LWl0LmNvbTEPMA0G
A1UEChMGRm94LUlUMREwDwYDVQQHEwhSaWpzd2lqazEVMBMGA1UECBMMWnVpZC1Ib2xsYW5k
MQswCQYDVQQGEwJOTAICAO0wCQYFKw4DAhoFAKCCAeowGAYJKoZIhvcNAQkDMQsGCSqGSIb3
DQEHATAcBgkqhkiG9w0BCQUxDxcNMTExMDA2MDk1NzI1WjAjBgkqhkiG9w0BCQQxFgQUZuC4
HKGIPLpoAgT/tjBEw3FFy8cwXwYJKoZIhvcNAQkPMVIwUDALBglghkgBZQMEAQIwCgYIKoZI
hvcNAwcwDgYIKoZIhvcNAwICAgCAMA0GCCqGSIb3DQMCAgFAMAcGBSsOAwIHMA0GCCqGSIb3
DQMCAgEoMIGSBgkrBgEEAYI3EAQxgYQwgYEwezESMBAGA1UEAxMJRm94LUlUIENBMR0wGwYJ
KoZIhvcNAQkBFg5zb2NAZm94LWl0LmNvbTEPMA0GA1UEChMGRm94LUlUMREwDwYDVQQHEwhS
aWpzd2lqazEVMBMGA1UECBMMWnVpZC1Ib2xsYW5kMQswCQYDVQQGEwJOTAICAO0wgZQGCyqG
SIb3DQEJEAILMYGEoIGBMHsxEjAQBgNVBAMTCUZveC1JVCBDQTEdMBsGCSqGSIb3DQEJARYO
c29jQGZveC1pdC5jb20xDzANBgNVBAoTBkZveC1JVDERMA8GA1UEBxMIUmlqc3dpamsxFTAT
BgNVBAgTDFp1aWQtSG9sbGFuZDELMAkGA1UEBhMCTkwCAgDtMA0GCSqGSIb3DQEBAQUABIIC
ABy0n/q42bpBaZ6kjSaotHa2euQ8QV/H5oyhQ0qIcm6sOch/gYEOQTVyJsn98/kQY1wojMqB
FBJzqRQogb1DK4TSczNWpCJ5FmnguztxmaRBLyI5AjxMtshl1QzBsVnaPY23rVnyoegeQNbs
jfKPMyl44Z/50SH2UaAPCJiD/Q0vamU1MaLWxCjPOst8vI2uxEtlbVBjg02n2kSvsSRH1/CV
Pe8RZ6NzWKJrgWiXrlvcUe8j4xUQecg5ky7V2yW6N1m8rltAfk5A2hcwLq/PfrGRBhW9Yvc/
ifiTysvwFl/dbQarQIaQLfO20zOIcVwOUC4tfAhNbGCgzOjjmrtBNgto4IWF2xQ1kh4F0QmP
N7pMboX0y0YspT9k/UQkA6YeKuFpEHfqfweNZJCQq196jE+eF4D4i/l2I7UxO32GwLJUfGqz
4dBw1wtmofGWFoE0f7vg/E4CBbMoKSL13DMCX59BftZN/nwNMG01coft2pPgbtEJAa4tVhHU
Pt56luTi1O1ztLQ7XLQH8VWvdyyJbz6njIvOaRl6Q8C94R9WFJoN4TuxmfvgJ2bpt1nI1bmi
23pJo1b91JIjGZVzKmeZExt4kcy+s1WW8AiJzqSZ2eEKXzm6pDCo84SqQImSnAa8mgJwJc+c
7Een1eoo/Qtkdyo8D3+Q+CRffV81YTGUmyVqAAAAAAAA
--------------ms040706040909040606020901--
