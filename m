From: Richard Laager <rlaager@wiktel.com>
Subject: Re: Fw: [Bug 82471] New: net/core/dev.c skb_war_bad_offload
Date: Wed, 17 Dec 2014 02:44:12 -0600
Message-ID: <1418805852.5277.25.camel@watermelon.coderich.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-dDpWoIK94V8BYgpOG/ol"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.wiktel.com ([69.89.207.152]:39331 "EHLO smtp2.wiktel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750999AbaLQJUG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Dec 2014 04:20:06 -0500
Received: from [172.16.0.106] (thief-pool3-123-250.mncable.net [216.172.123.250])
	(authenticated bits=0)
	by smtp2.wiktel.com (8.14.4/8.14.4/Debian-4.1ubuntu1) with ESMTP id sBH8iCYI018595
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 17 Dec 2014 02:44:12 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-dDpWoIK94V8BYgpOG/ol
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Previous history of this thread:
http://thread.gmane.org/gmane.linux.network/326672

On 2014-11-04 22:57:19, Tom Herbert wrote:
> Using vlan and bonding? vlan_dev_hard_start_xmit called. A possible
> cause is that bonding interface is out of sync with slave interface
> w.r.t. GSO features. Do we know if this worked in 3.14, 3.15?

I'm seeing the same sort of crash/warning (skb_war_bad_offload). It's
happening on Intel 10 Gig NICs using the ixgbe driver. I'm using bridges
(for virtual machines) on top of VLANs on top of 802.3ad bonding. I'm
using an MTU of 9000 on the bond0 interface, but 1500 everywhere else.

I'm always bonding two ports: one one system, I'm bonding two ports on
identical one-port NICs; on another system, I'm bonding two ports on a
single two-port NIC. Both systems exhibit the same behavior.

Everything has worked fine for a couple years on Ubuntu 12.04 Precise
(Linux 3.2.0). It immediately broke when I upgraded to Ubuntu 14.04
Trusty (Linux 3.13.0). I can also reproduce this using the packaged
version of Linux 3.16.0 on Trusty.

In contrast to other reports of this bug, disabling scatter gather on
the physical interfaces (e.g. eth0) does *not* stop the crashes
(assuming I disabled it correctly).

I currently have two systems (one with Precise, one with Trusty)
available to do any testing that you'd find helpful.

Here's a first pass at getting some debugging data.

The broken system (Ubuntu 14.04 Trusty):

rlaager@BROKEN:~$ uname -a
Linux BROKEN 3.13.0-43-generic #72-Ubuntu SMP Mon Dec 8 19:35:06 UTC
2014 x86_64 x86_64 x86_64 GNU/Linux

rlaager@BROKEN:~$ ethtool -k p6p1
Features for p6p1:
rx-checksumming: on
tx-checksumming: on
	tx-checksum-ipv4: on
	tx-checksum-ip-generic: off [fixed]
	tx-checksum-ipv6: on
	tx-checksum-fcoe-crc: on [fixed]
	tx-checksum-sctp: on
scatter-gather: on
	tx-scatter-gather: on
	tx-scatter-gather-fraglist: off [fixed]
tcp-segmentation-offload: on
	tx-tcp-segmentation: on
	tx-tcp-ecn-segmentation: off [fixed]
	tx-tcp6-segmentation: on
udp-fragmentation-offload: off [fixed]
generic-segmentation-offload: on
generic-receive-offload: on
large-receive-offload: off
rx-vlan-offload: on
tx-vlan-offload: on
ntuple-filters: off
receive-hashing: on
highdma: on [fixed]
rx-vlan-filter: on
vlan-challenged: off [fixed]
tx-lockless: off [fixed]
netns-local: off [fixed]
tx-gso-robust: off [fixed]
tx-fcoe-segmentation: on [fixed]
tx-gre-segmentation: off [fixed]
tx-ipip-segmentation: off [fixed]
tx-sit-segmentation: off [fixed]
tx-udp_tnl-segmentation: off [fixed]
tx-mpls-segmentation: off [fixed]
fcoe-mtu: off [fixed]
tx-nocache-copy: on
loopback: off [fixed]
rx-fcs: off [fixed]
rx-all: off
tx-vlan-stag-hw-insert: off [fixed]
rx-vlan-stag-hw-parse: off [fixed]
rx-vlan-stag-filter: off [fixed]
l2-fwd-offload: off

rlaager@BROKEN:~$ ethtool -k bond0
Features for bond0:
rx-checksumming: off [fixed]
tx-checksumming: on
	tx-checksum-ipv4: off [fixed]
	tx-checksum-ip-generic: on
	tx-checksum-ipv6: off [fixed]
	tx-checksum-fcoe-crc: off [fixed]
	tx-checksum-sctp: off [fixed]
scatter-gather: on
	tx-scatter-gather: on
	tx-scatter-gather-fraglist: off [requested on]
tcp-segmentation-offload: on
	tx-tcp-segmentation: on
	tx-tcp-ecn-segmentation: on
	tx-tcp6-segmentation: on
udp-fragmentation-offload: off [fixed]
generic-segmentation-offload: on
generic-receive-offload: on
large-receive-offload: off
rx-vlan-offload: on
tx-vlan-offload: on
ntuple-filters: off [fixed]
receive-hashing: off [fixed]
highdma: on
rx-vlan-filter: on
vlan-challenged: off [fixed]
tx-lockless: on [fixed]
netns-local: off [fixed]
tx-gso-robust: off [fixed]
tx-fcoe-segmentation: off [fixed]
tx-gre-segmentation: off [fixed]
tx-ipip-segmentation: off [fixed]
tx-sit-segmentation: off [fixed]
tx-udp_tnl-segmentation: on
tx-mpls-segmentation: off [fixed]
fcoe-mtu: off [fixed]
tx-nocache-copy: off [requested on]
loopback: off [fixed]
rx-fcs: off [fixed]
rx-all: off [fixed]
tx-vlan-stag-hw-insert: off [fixed]
rx-vlan-stag-hw-parse: off [fixed]
rx-vlan-stag-filter: off [fixed]
l2-fwd-offload: off [fixed]

rlaager@BROKEN:~$ ethtool -k br7
Features for br7:
rx-checksumming: off [fixed]
tx-checksumming: on
	tx-checksum-ipv4: off [fixed]
	tx-checksum-ip-generic: on
	tx-checksum-ipv6: off [fixed]
	tx-checksum-fcoe-crc: off [fixed]
	tx-checksum-sctp: off [fixed]
scatter-gather: on
	tx-scatter-gather: on
	tx-scatter-gather-fraglist: off [requested on]
tcp-segmentation-offload: on
	tx-tcp-segmentation: on
	tx-tcp-ecn-segmentation: on
	tx-tcp6-segmentation: on
udp-fragmentation-offload: off [requested on]
generic-segmentation-offload: on
generic-receive-offload: on
large-receive-offload: off [fixed]
rx-vlan-offload: off [fixed]
tx-vlan-offload: on
ntuple-filters: off [fixed]
receive-hashing: off [fixed]
highdma: on
rx-vlan-filter: off [fixed]
vlan-challenged: off [fixed]
tx-lockless: on [fixed]
netns-local: on [fixed]
tx-gso-robust: off [requested on]
tx-fcoe-segmentation: off [requested on]
tx-gre-segmentation: on
tx-ipip-segmentation: on
tx-sit-segmentation: on
tx-udp_tnl-segmentation: on
tx-mpls-segmentation: on
fcoe-mtu: off [fixed]
tx-nocache-copy: off [requested on]
loopback: off [fixed]
rx-fcs: off [fixed]
rx-all: off [fixed]
tx-vlan-stag-hw-insert: off [fixed]
rx-vlan-stag-hw-parse: off [fixed]
rx-vlan-stag-filter: off [fixed]
l2-fwd-offload: off [fixed]

rlaager@BROKEN:~$ lspci
00:00.0 Host bridge: Intel Corporation 5520 I/O Hub to ESI Port (rev 22)
00:01.0 PCI bridge: Intel Corporation 5520/5500/X58 I/O Hub PCI Express Roo=
t Port 1 (rev 22)
00:03.0 PCI bridge: Intel Corporation 5520/5500/X58 I/O Hub PCI Express Roo=
t Port 3 (rev 22)
00:05.0 PCI bridge: Intel Corporation 5520/X58 I/O Hub PCI Express Root Por=
t 5 (rev 22)
00:07.0 PCI bridge: Intel Corporation 5520/5500/X58 I/O Hub PCI Express Roo=
t Port 7 (rev 22)
00:09.0 PCI bridge: Intel Corporation 7500/5520/5500/X58 I/O Hub PCI Expres=
s Root Port 9 (rev 22)
00:0d.0 Host bridge: Intel Corporation Device 343a (rev 22)
00:0d.1 Host bridge: Intel Corporation Device 343b (rev 22)
00:0d.2 Host bridge: Intel Corporation Device 343c (rev 22)
00:0d.3 Host bridge: Intel Corporation Device 343d (rev 22)
00:0d.4 Host bridge: Intel Corporation 7500/5520/5500/X58 Physical Layer Po=
rt 0 (rev 22)
00:0d.5 Host bridge: Intel Corporation 7500/5520/5500 Physical Layer Port 1=
 (rev 22)
00:0d.6 Host bridge: Intel Corporation Device 341a (rev 22)
00:0e.0 Host bridge: Intel Corporation Device 341c (rev 22)
00:0e.1 Host bridge: Intel Corporation Device 341d (rev 22)
00:0e.2 Host bridge: Intel Corporation Device 341e (rev 22)
00:0e.4 Host bridge: Intel Corporation Device 3439 (rev 22)
00:13.0 PIC: Intel Corporation 7500/5520/5500/X58 I/O Hub I/OxAPIC Interrup=
t Controller (rev 22)
00:14.0 PIC: Intel Corporation 7500/5520/5500/X58 I/O Hub System Management=
 Registers (rev 22)
00:14.1 PIC: Intel Corporation 7500/5520/5500/X58 I/O Hub GPIO and Scratch =
Pad Registers (rev 22)
00:14.2 PIC: Intel Corporation 7500/5520/5500/X58 I/O Hub Control Status an=
d RAS Registers (rev 22)
00:14.3 PIC: Intel Corporation 7500/5520/5500/X58 I/O Hub Throttle Register=
s (rev 22)
00:16.0 System peripheral: Intel Corporation 5520/5500/X58 Chipset QuickDat=
a Technology Device (rev 22)
00:16.1 System peripheral: Intel Corporation 5520/5500/X58 Chipset QuickDat=
a Technology Device (rev 22)
00:16.2 System peripheral: Intel Corporation 5520/5500/X58 Chipset QuickDat=
a Technology Device (rev 22)
00:16.3 System peripheral: Intel Corporation 5520/5500/X58 Chipset QuickDat=
a Technology Device (rev 22)
00:16.4 System peripheral: Intel Corporation 5520/5500/X58 Chipset QuickDat=
a Technology Device (rev 22)
00:16.5 System peripheral: Intel Corporation 5520/5500/X58 Chipset QuickDat=
a Technology Device (rev 22)
00:16.6 System peripheral: Intel Corporation 5520/5500/X58 Chipset QuickDat=
a Technology Device (rev 22)
00:16.7 System peripheral: Intel Corporation 5520/5500/X58 Chipset QuickDat=
a Technology Device (rev 22)
00:1a.0 USB controller: Intel Corporation 82801JI (ICH10 Family) USB UHCI C=
ontroller #4
00:1a.1 USB controller: Intel Corporation 82801JI (ICH10 Family) USB UHCI C=
ontroller #5
00:1a.2 USB controller: Intel Corporation 82801JI (ICH10 Family) USB UHCI C=
ontroller #6
00:1a.7 USB controller: Intel Corporation 82801JI (ICH10 Family) USB2 EHCI =
Controller #2
00:1c.0 PCI bridge: Intel Corporation 82801JI (ICH10 Family) PCI Express Ro=
ot Port 1
00:1d.0 USB controller: Intel Corporation 82801JI (ICH10 Family) USB UHCI C=
ontroller #1
00:1d.1 USB controller: Intel Corporation 82801JI (ICH10 Family) USB UHCI C=
ontroller #2
00:1d.2 USB controller: Intel Corporation 82801JI (ICH10 Family) USB UHCI C=
ontroller #3
00:1d.7 USB controller: Intel Corporation 82801JI (ICH10 Family) USB2 EHCI =
Controller #1
00:1e.0 PCI bridge: Intel Corporation 82801 PCI Bridge (rev 90)
00:1f.0 ISA bridge: Intel Corporation 82801JIR (ICH10R) LPC Interface Contr=
oller
00:1f.2 SATA controller: Intel Corporation 82801JI (ICH10 Family) SATA AHCI=
 Controller
00:1f.3 SMBus: Intel Corporation 82801JI (ICH10 Family) SMBus Controller
01:03.0 VGA compatible controller: Matrox Electronics Systems Ltd. MGA G200=
eW WPCM450 (rev 0a)
03:00.0 Serial Attached SCSI controller: LSI Logic / Symbios Logic SAS2008 =
PCI-Express Fusion-MPT SAS-2 [Falcon] (rev 02)
05:00.0 Ethernet controller: Intel Corporation 82599ES 10-Gigabit SFI/SFP+ =
Network Connection (rev 01)
05:00.1 Ethernet controller: Intel Corporation 82599ES 10-Gigabit SFI/SFP+ =
Network Connection (rev 01)
fe:00.0 Host bridge: Intel Corporation Xeon 5600 Series QuickPath Architect=
ure Generic Non-core Registers (rev 02)
fe:00.1 Host bridge: Intel Corporation Xeon 5600 Series QuickPath Architect=
ure System Address Decoder (rev 02)
fe:02.0 Host bridge: Intel Corporation Xeon 5600 Series QPI Link 0 (rev 02)
fe:02.1 Host bridge: Intel Corporation Xeon 5600 Series QPI Physical 0 (rev=
 02)
fe:02.2 Host bridge: Intel Corporation Xeon 5600 Series Mirror Port Link 0 =
(rev 02)
fe:02.3 Host bridge: Intel Corporation Xeon 5600 Series Mirror Port Link 1 =
(rev 02)
fe:02.4 Host bridge: Intel Corporation Xeon 5600 Series QPI Link 1 (rev 02)
fe:02.5 Host bridge: Intel Corporation Xeon 5600 Series QPI Physical 1 (rev=
 02)
fe:03.0 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory C=
ontroller Registers (rev 02)
fe:03.1 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory C=
ontroller Target Address Decoder (rev 02)
fe:03.2 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory C=
ontroller RAS Registers (rev 02)
fe:03.4 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory C=
ontroller Test Registers (rev 02)
fe:04.0 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory C=
ontroller Channel 0 Control (rev 02)
fe:04.1 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory C=
ontroller Channel 0 Address (rev 02)
fe:04.2 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory C=
ontroller Channel 0 Rank (rev 02)
fe:04.3 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory C=
ontroller Channel 0 Thermal Control (rev 02)
fe:05.0 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory C=
ontroller Channel 1 Control (rev 02)
fe:05.1 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory C=
ontroller Channel 1 Address (rev 02)
fe:05.2 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory C=
ontroller Channel 1 Rank (rev 02)
fe:05.3 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory C=
ontroller Channel 1 Thermal Control (rev 02)
fe:06.0 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory C=
ontroller Channel 2 Control (rev 02)
fe:06.1 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory C=
ontroller Channel 2 Address (rev 02)
fe:06.2 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory C=
ontroller Channel 2 Rank (rev 02)
fe:06.3 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory C=
ontroller Channel 2 Thermal Control (rev 02)
ff:00.0 Host bridge: Intel Corporation Xeon 5600 Series QuickPath Architect=
ure Generic Non-core Registers (rev 02)
ff:00.1 Host bridge: Intel Corporation Xeon 5600 Series QuickPath Architect=
ure System Address Decoder (rev 02)
ff:02.0 Host bridge: Intel Corporation Xeon 5600 Series QPI Link 0 (rev 02)
ff:02.1 Host bridge: Intel Corporation Xeon 5600 Series QPI Physical 0 (rev=
 02)
ff:02.2 Host bridge: Intel Corporation Xeon 5600 Series Mirror Port Link 0 =
(rev 02)
ff:02.3 Host bridge: Intel Corporation Xeon 5600 Series Mirror Port Link 1 =
(rev 02)
ff:02.4 Host bridge: Intel Corporation Xeon 5600 Series QPI Link 1 (rev 02)
ff:02.5 Host bridge: Intel Corporation Xeon 5600 Series QPI Physical 1 (rev=
 02)
ff:03.0 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory C=
ontroller Registers (rev 02)
ff:03.1 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory C=
ontroller Target Address Decoder (rev 02)
ff:03.2 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory C=
ontroller RAS Registers (rev 02)
ff:03.4 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory C=
ontroller Test Registers (rev 02)
ff:04.0 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory C=
ontroller Channel 0 Control (rev 02)
ff:04.1 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory C=
ontroller Channel 0 Address (rev 02)
ff:04.2 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory C=
ontroller Channel 0 Rank (rev 02)
ff:04.3 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory C=
ontroller Channel 0 Thermal Control (rev 02)
ff:05.0 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory C=
ontroller Channel 1 Control (rev 02)
ff:05.1 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory C=
ontroller Channel 1 Address (rev 02)
ff:05.2 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory C=
ontroller Channel 1 Rank (rev 02)
ff:05.3 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory C=
ontroller Channel 1 Thermal Control (rev 02)
ff:06.0 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory C=
ontroller Channel 2 Control (rev 02)
ff:06.1 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory C=
ontroller Channel 2 Address (rev 02)
ff:06.2 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory C=
ontroller Channel 2 Rank (rev 02)
ff:06.3 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory C=
ontroller Channel 2 Thermal Control (rev 02)


The working system (Ubuntu 12.04 Precise):

rlaager@WORKING:~$ uname -a
Linux WORKING 3.2.0-74-generic #109-Ubuntu SMP Tue Dec 9 16:45:49 UTC
2014 x86_64 x86_64 x86_64 GNU/Linux

rlaager@WORKING:~$ ethtool -k eth0
Offload parameters for eth0:
rx-checksumming: on
tx-checksumming: on
scatter-gather: on
tcp-segmentation-offload: on
udp-fragmentation-offload: off
generic-segmentation-offload: on
generic-receive-offload: on
large-receive-offload: off
rx-vlan-offload: on
tx-vlan-offload: on
ntuple-filters: off
receive-hashing: on

rlaager@WORKING:~$ ethtool -k bond0
Offload parameters for bond0:
rx-checksumming: on
tx-checksumming: on
scatter-gather: on
tcp-segmentation-offload: on
udp-fragmentation-offload: off
generic-segmentation-offload: on
generic-receive-offload: on
large-receive-offload: off
rx-vlan-offload: on
tx-vlan-offload: on
ntuple-filters: off
receive-hashing: off

rlaager@WORKING:~$ ethtool -k br7
Offload parameters for br7:
rx-checksumming: on
tx-checksumming: on
scatter-gather: off
tcp-segmentation-offload: off
udp-fragmentation-offload: off
generic-segmentation-offload: off
generic-receive-offload: on
large-receive-offload: off
rx-vlan-offload: off
tx-vlan-offload: on
ntuple-filters: off




A stack trace from 3.13.0 (the default kernel in Ubuntu Trusty):

[ 1161.275007] WARNING: CPU: 7 PID: 0 at /build/buildd/linux-3.13.0/net/cor=
e/dev.c:2224 skb_warn_bad_offload+0xcd/0xda()
[ 1161.275011] : caps=3D(0x00000022000048c1, 0x0000000000000000) len=3D1514=
 data_len=3D1460 gso_size=3D1460 gso_type=3D1 ip_summed=3D1
[ 1161.275012] Modules linked in: nfsv3 ipmi_devintf ipmi_si vhost_net vhos=
t macvtap macvlan bridge ip6t_REJECT xt_hl ip6t_rt nf_conntrack_ipv6 nf_def=
rag_ipv6 ipt_REJECT xt_comment xt_mul
 mrp xt_addrtype llc bonding nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack =
ip6table_filter ip6_tables nf_conntrack_netbios_ns nf_conntrack_broadcast n=
f_nat_ftp nf_nat nf_conntrack_ftp nf_
ch intel_powerclamp coretemp kvm_intel kvm crct10dif_pclmul crc32_pclmul gh=
ash_clmulni_intel aesni_intel aes_x86_64 lrw gf128mul glue_helper ablk_help=
er cryptd serio_raw joydev i7core_eda
id nfs_acl lp parport nfs lockd sunrpc fscache ses enclosure raid10 raid456=
 async_raid6_recov async_memcpy async_pq async_xor async_tx xor ixgbe raid6=
_pq dca hid_generic raid1 ptp mpt2sas
smouse hid libahci scsi_transport_sas mdio linear
[ 1161.275077] CPU: 7 PID: 0 Comm: swapper/7 Tainted: G        W     3.13.0=
-43-generic #72-Ubuntu
[ 1161.275079] Hardware name: Supermicro X8DT6/X8DT6, BIOS 2.0a    09/14/20=
10
[ 1161.275080]  0000000000000009 ffff880c3fc239d8 ffffffff81720bf6 ffff880c=
3fc23a20
[ 1161.275085]  ffff880c3fc23a10 ffffffff810677cd ffff880c1d3b9600 ffff8806=
18e08000
[ 1161.275089]  0000000000000001 0000000000000001 ffff880c1d3b9600 ffff880c=
3fc23a70
[ 1161.275092] Call Trace:
[ 1161.275094]  <IRQ>  [<ffffffff81720bf6>] dump_stack+0x45/0x56
[ 1161.275101]  [<ffffffff810677cd>] warn_slowpath_common+0x7d/0xa0
[ 1161.275105]  [<ffffffff8106783c>] warn_slowpath_fmt+0x4c/0x50
[ 1161.275109]  [<ffffffff8136a0a3>] ? ___ratelimit+0x93/0x100
[ 1161.275113]  [<ffffffff81723afe>] skb_warn_bad_offload+0xcd/0xda
[ 1161.275118]  [<ffffffff81626489>] __skb_gso_segment+0x79/0xb0
[ 1161.275122]  [<ffffffff8162677a>] dev_hard_start_xmit+0x18a/0x560
[ 1161.275126]  [<ffffffff81098209>] ? ttwu_do_wakeup+0x19/0xc0
[ 1161.275129]  [<ffffffff8164594e>] sch_direct_xmit+0xee/0x1c0
[ 1161.275133]  [<ffffffff81626d80>] __dev_queue_xmit+0x230/0x500
[ 1161.275137]  [<ffffffff81627060>] dev_queue_xmit+0x10/0x20
[ 1161.275143]  [<ffffffffa04ab31b>] br_dev_queue_push_xmit+0x7b/0xc0 [brid=
ge]
[ 1161.275149]  [<ffffffffa04ab532>] br_forward_finish+0x22/0x60 [bridge]
[ 1161.275155]  [<ffffffffa04ab710>] __br_forward+0x80/0xf0 [bridge]
[ 1161.275161]  [<ffffffffa04ab9bb>] br_forward+0x8b/0xa0 [bridge]
[ 1161.275167]  [<ffffffffa04ac6d9>] br_handle_frame_finish+0x149/0x3d0 [br=
idge]
[ 1161.275173]  [<ffffffffa04acad5>] br_handle_frame+0x175/0x250 [bridge]
[ 1161.275177]  [<ffffffff81624ac2>] __netif_receive_skb_core+0x262/0x840
[ 1161.275181]  [<ffffffff8101b700>] ? check_tsc_unstable+0x10/0x10
[ 1161.275184]  [<ffffffff816250b8>] __netif_receive_skb+0x18/0x60
[ 1161.275188]  [<ffffffff81625123>] netif_receive_skb+0x23/0x90
[ 1161.275192]  [<ffffffff81625b70>] napi_gro_receive+0x80/0xb0
[ 1161.275202]  [<ffffffffa014009c>] ixgbe_clean_rx_irq+0x7ac/0xb10 [ixgbe]
[ 1161.275211]  [<ffffffffa0141140>] ixgbe_poll+0x460/0x800 [ixgbe]
[ 1161.275216]  [<ffffffff816254a2>] net_rx_action+0x152/0x250
[ 1161.275220]  [<ffffffff8106cc1c>] __do_softirq+0xec/0x2c0
[ 1161.275223]  [<ffffffff8106d165>] irq_exit+0x105/0x110
[ 1161.275227]  [<ffffffff817339e6>] do_IRQ+0x56/0xc0
[ 1161.275231]  [<ffffffff817290ed>] common_interrupt+0x6d/0x6d
[ 1161.275232]  <EOI>  [<ffffffff815d361f>] ? cpuidle_enter_state+0x4f/0xc0
[ 1161.275240]  [<ffffffff815d3749>] cpuidle_idle_call+0xb9/0x1f0
[ 1161.275244]  [<ffffffff8101d35e>] arch_cpu_idle+0xe/0x30
[ 1161.275247]  [<ffffffff810bef35>] cpu_startup_entry+0xc5/0x290
[ 1161.275251]  [<ffffffff810413ed>] start_secondary+0x21d/0x2d0


A stack trace from 3.16.0 (still on Ubuntu Trusty):

[  120.376026] WARNING: CPU: 6 PID: 0 at /build/buildd/linux-lts-utopic-3.1=
6.0/net/core/dev.c:2246 skb_warn_bad_offload+0xcd/0xda()
[  120.376029] : caps=3D(0x00000080000048c1, 0x0000000000000000) len=3D1514=
 data_len=3D1460 gso_size=3D1460 gso_type=3D1 ip_summed=3D1
[  120.376030] Modules linked in: nfsv3 ipmi_devintf ipmi_si ipmi_msghandle=
r vhost_net vhost macvtap macvlan bridge 8021q garp stp mrp llc bonding ip6=
t_REJECT xt_hl ip6t_rt nf_conntrack_ipv6 nf_defrag_ipv6 ipt_REJECT xt_comme=
nt xt_multiport xt_recent xt_limit xt_tcpudp xt_addrtype nf_conntrack_ipv4 =
nf_defrag_ipv4 xt_conntrack ip6table_filter ip6_tables nf_conntrack_netbios=
_ns nf_conntrack_broadcast nf_nat_ftp nf_nat nf_conntrack_ftp nf_conntrack =
iptable_filter ip_tables x_tables intel_powerclamp coretemp kvm_intel gpio_=
ich kvm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel aesni_intel aes_x=
86_64 lrw gf128mul glue_helper ablk_helper cryptd serio_raw lpc_ich joydev =
i7core_edac ioatdma edac_core nfsd auth_rpcgss mac_hid nfs_acl lp parport n=
fs lockd sunrpc fscache ses enclosure raid10 raid456 async_raid6_recov asyn=
c_memcpy async_pq async_xor async_tx xor hid_generic raid6_pq ixgbe usbhid =
raid1 mpt2sas dca ahci raid0 ptp raid_class pps_core scsi_transport_sas mul=
tipath hid mdio libahci linear
[  120.376085] CPU: 6 PID: 0 Comm: swapper/6 Not tainted 3.16.0-28-generic =
#37-Ubuntu
[  120.376086] Hardware name: Supermicro X8DT6/X8DT6, BIOS 2.0a    09/14/20=
10
[  120.376088]  0000000000000009 ffff880c3fc039b8 ffffffff81762220 ffff880c=
3fc03a00
[  120.376090]  ffff880c3fc039f0 ffffffff8106dd2d ffff880c1ac99a00 ffff8806=
1c2fc000
[  120.376092]  0000000000000001 0000000000000001 ffff880c1ac99a00 ffff880c=
3fc03a50
[  120.376094] Call Trace:
[  120.376096]  <IRQ>  [<ffffffff81762220>] dump_stack+0x45/0x56
[  120.376105]  [<ffffffff8106dd2d>] warn_slowpath_common+0x7d/0xa0
[  120.376107]  [<ffffffff8106dd9c>] warn_slowpath_fmt+0x4c/0x50
[  120.376111]  [<ffffffff8138b153>] ? ___ratelimit+0x93/0x100
[  120.376114]  [<ffffffff817654da>] skb_warn_bad_offload+0xcd/0xda
[  120.376119]  [<ffffffff81661d29>] __skb_gso_segment+0x79/0xb0
[  120.376122]  [<ffffffff81662052>] dev_hard_start_xmit+0x182/0x5c0
[  120.376125]  [<ffffffff8168337e>] sch_direct_xmit+0xee/0x1c0
[  120.376127]  [<ffffffff81662690>] __dev_queue_xmit+0x200/0x4d0
[  120.376129]  [<ffffffff81662970>] dev_queue_xmit+0x10/0x20
[  120.376135]  [<ffffffffc0796ac8>] br_dev_queue_push_xmit+0x68/0xa0 [brid=
ge]
[  120.376138]  [<ffffffffc0796cd2>] br_forward_finish+0x22/0x60 [bridge]
[  120.376142]  [<ffffffffc0796e90>] __br_forward+0x80/0xf0 [bridge]
[  120.376145]  [<ffffffffc079713b>] br_forward+0x8b/0xa0 [bridge]
[  120.376149]  [<ffffffffc0797fb9>] br_handle_frame_finish+0x139/0x3c0 [br=
idge]
[  120.376153]  [<ffffffffc079838e>] br_handle_frame+0x14e/0x240 [bridge]
[  120.376155]  [<ffffffff81660102>] __netif_receive_skb_core+0x1b2/0x790
[  120.376158]  [<ffffffff8101bcd9>] ? read_tsc+0x9/0x20
[  120.376161]  [<ffffffff816606f8>] __netif_receive_skb+0x18/0x60
[  120.376163]  [<ffffffff81660763>] netif_receive_skb_internal+0x23/0x90
[  120.376165]  [<ffffffff816612c0>] napi_gro_receive+0xc0/0xf0
[  120.376174]  [<ffffffffc03007ac>] ixgbe_clean_rx_irq+0x7bc/0xb40 [ixgbe]
[  120.376180]  [<ffffffffc03018a2>] ixgbe_poll+0x482/0x850 [ixgbe]
[  120.376183]  [<ffffffff8109e9e9>] ? ttwu_do_wakeup+0x19/0xc0
[  120.376186]  [<ffffffff81660b52>] net_rx_action+0x152/0x250
[  120.376189]  [<ffffffff81073055>] __do_softirq+0xf5/0x2e0
[  120.376191]  [<ffffffff81073515>] irq_exit+0x105/0x110
[  120.376194]  [<ffffffff8176d748>] do_IRQ+0x58/0xf0
[  120.376198]  [<ffffffff8176b5ed>] common_interrupt+0x6d/0x6d
[  120.376199]  <EOI>  [<ffffffff815fb83f>] ? cpuidle_enter_state+0x4f/0xc0
[  120.376204]  [<ffffffff815fb838>] ? cpuidle_enter_state+0x48/0xc0
[  120.376206]  [<ffffffff815fb967>] cpuidle_enter+0x17/0x20
[  120.376209]  [<ffffffff810b527d>] cpu_startup_entry+0x31d/0x450
[  120.376213]  [<ffffffff810e028d>] ? tick_check_new_device+0xdd/0xf0
[  120.376216]  [<ffffffff8104520d>] start_secondary+0x21d/0x2e0
[  120.376217] ---[ end trace 90d53a2c9c47f360 ]---

--=20
Richard

--=-dDpWoIK94V8BYgpOG/ol
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABCAAGBQJUkUJcAAoJEA/9MsdVF+JSQkgIAM5GxN0dWQHH79comg+M6vGu
hAsSbtXFDWq9Qywf80I+QGbGpmtizXsx97JHpLHYnjQLZr2jCfkXGuyB2Syxtc+T
V3o60a5Xg10S+TRVnZixzT14TMiXHcaAbXCOnakB+I+XF0FDL3yXZELc91RhEN9h
M/kqc7WruTbzsGzW4/Q8FwGJgjFqqd1Z9fwKXUh7UW6fLCbsRro3MiPWHPVxUr6U
8s9WXmYPSxq7HdJiu7eSY7OMcf2w29KHD2y7Lo0my3TPwqRx2Ll0nDvNsoP2403p
Gaj9iiJfYolDwElbTE/ijeiA0664eY/xjlVnQoH4ICgr68jZSvvRS+Y3851CpLg=
=Z77+
-----END PGP SIGNATURE-----

--=-dDpWoIK94V8BYgpOG/ol--
