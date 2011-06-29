From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Bug#631945: linux-image-2.6.39-2-amd64: HFSC puts lots of
 "WARNING: at .../sch_hfsc.c:1427 hfsc_dequeue+0x155/0x28b [sch_hfsc]()" in
 dmesg
Date: Wed, 29 Jun 2011 05:08:27 +0100
Message-ID: <1309320507.3093.1622.camel@localhost>
References: <20110628131310.9941.39557.reportbug@wenus.h1.pl>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512"; protocol="application/pgp-signature"; boundary="=-b+OnCg7DELmDZtX0f/UG"
Cc: 631945@bugs.debian.org, Michal Pokrywka <wolfmoon@o2.pl>,
	netdev <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>, Michal Soltys <soltys@ziu.info>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:42897 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750820Ab1F2EIn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2011 00:08:43 -0400
In-Reply-To: <20110628131310.9941.39557.reportbug@wenus.h1.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-b+OnCg7DELmDZtX0f/UG
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2011-06-28 at 15:13 +0200, Michal Pokrywka wrote:
> Package: linux-2.6
> Version: 2.6.39-2
> Severity: important
> Tags: upstream
>=20
>=20
> I had working HFSC configuration on gateway machine with kernel
> 2.6.26-21~bpo40+1. Now I switched to new machine and kernel 2.6.39-2 with=
 the
> same configuration script. Shaping works but after a couple of minutes
> houndreds of warnings per second fills dmesg severly slowing whole system
> (kernel log attached below).

This is the warning in hfsc_schedule_watchdog().  Patrick, Michal, it
looks like you made some changes in this area since 2.6.32 (the last
version reported as OK).  Can you see how this can happen?

Ben.

> My configuration on eth0 involves SFQ queues connected to HFSC leafs, and=
 one
> RED queue connected to one HFSC leaf. Similar configuration runs on ifb0.
> All incoming to eth0 traffic is directed to ifb0 using egress action mirr=
ed.
> Also there is some hashtable filtering based in IP addresses.
>=20
> When I erased all queues and put for testing purposes only one HFSC queue=
 on
> eth0 with one default class I noticed that the problem exists no more.
> So I connected one SFQ queue to this single HFSC class and problem still
> not occurs.
>=20
> Then I did the same thing on ifb0 and redirected traffic from eth0 egress
> and noticed still no warnings in dmesg.
>=20
> Connecting RED to HFSC leaf also produces no warnings.
>=20
> Switching in udev eth0->eth1 and eth1->eth0 (to make HFSC work with diffe=
rent
> ethernet driver: forcedeth->tg3) does not solve the problem.
>=20
> Maybe someone can suggest what else could be done to trace the problem.
>=20
> Here are the HFSC script that triggers the bug (without repeating stuff).
> It is a bit complicated but it works with different users on three differ=
ent
> machines (different ethernet devices) with 2.6.32 kernel.
> It should work on every machine which has 192.168.20.0/24 network on eth0
> and internet access on eth1.
>=20
> -- CUT HERE (hfsc.sh begins) --
> modprobe ifb numifbs=3D1
> ### DOWNLOAD ###
> tc qdisc del dev eth0 root 2>&1 >/dev/null
> tc qdisc add dev eth0 root handle 1: hfsc default 4
> tc class add dev eth0 parent 1:  classid 1:1 hfsc ls rate 100000kbit ul r=
ate 100000kbit # main eth0 download
>=20
> tc class add dev eth0 parent 1:1 classid 1:2 hfsc ls rate 3891kbit ul rat=
e 3891kbit # main internet download
> tc class add dev eth0 parent 1:2 classid 1:4 hfsc ls rate 50kbit ul rate =
100kbit # bulk class
> tc class add dev eth0 parent 1:2 classid 1:5 hfsc ls rate 200kbit ul rate=
 1000kbit # wireless class
> tc qdisc add dev eth0 parent 1:4 handle 4: sfq perturb 5 quantum 1920 # b=
ulk qdisc
> tc qdisc add dev eth0 parent 1:5 handle 5: sfq perturb 5 quantum 1920 # w=
ifi qdisc
>=20
> tc class add dev eth0 parent 1:1 classid 1:3 hfsc ls rate 94904kbit ul ra=
te 94904kbit # local class
> tc qdisc add dev eth0 parent 1:3 handle 3: red min 75000 max 225000 proba=
bility 0.02 limit 675000 avpkt 1000 burst 120 bandwidth 94904
>=20
> tc filter add dev eth0 parent 1: protocol ip prio 3 u32 match ip src 192.=
168.20.0/24 match ip dst 62.***.***.88/29 flowid 1:3
> tc filter add dev eth0 parent 1: protocol ip prio 3 u32 match ip src 192.=
168.20.0/24 match ip dst 62.***.***.96/28 flowid 1:3
> tc filter add dev eth0 parent 1: protocol ip prio 3 u32 match ip dst 192.=
168.20.0/24 match ip src 62.***.***.88/29 flowid 1:3
> tc filter add dev eth0 parent 1: protocol ip prio 3 u32 match ip dst 192.=
168.20.0/24 match ip src 62.***.***.96/28 flowid 1:3
> tc filter add dev eth0 parent 1: protocol ip prio 3 u32 match ip src 192.=
168.20.91 match ip dst 192.168.20.0/24 flowid 1:3
>=20
> tc filter add dev eth0 parent 1: protocol ip prio 3 u32 match ip dst 10.0=
.0.0/8 flowid 1:5
>=20
> tc filter add dev eth0 parent 1: prio 5 handle 100: protocol ip u32 divis=
or 256
> tc filter add dev eth0 protocol ip parent 1: prio 5 u32 ht 800:: match ip=
 dst 192.168.20.0/24 hashkey mask 0x000000ff at 16 link 100:
>=20
> # example_user / 192.168.20.16
> tc class add dev eth0 parent 1:2    classid 1:0016  hfsc ls m1 400kbit d =
4s m2 100kbit ul rate 3696kbit
> tc class add dev eth0 parent 1:0016 classid 1:1016  hfsc rt rate 336bit l=
s m1 400kbit d 4s m2 100kbit ul rate 3696kbit # ack
> tc qdisc add dev eth0 parent 1:1016 handle    1016: sfq perturb 10 quantu=
m 1920
> tc class add dev eth0 parent 1:0016 classid 1:2016  hfsc rt rate 94566bit=
 ls m1 400kbit d 4s m2 100kbit ul rate 3696kbit # data
> tc qdisc add dev eth0 parent 1:2016 handle    2016: sfq perturb 10 quantu=
m 1920
>=20
> tc filter add dev eth0 parent 1: protocol ip prio  5 u32 ht 100:10 match =
ip protocol 6 0xff match u8 0x10 0xff at nexthdr+33 match u16 0x0000 0xffc0=
 at 2 flowid 1:1016 # ack
> tc filter add dev eth0 parent 1: protocol ip prio 10 u32 ht 100:10 match =
u32 0 0 flowid 1:2016 # data
>=20
> (... more users ...)
>=20
> ### UPLOAD ###
> ifconfig ifb0 up
>=20
> tc qdisc del dev ifb0 root 2>&1 >/dev/null
> tc qdisc add dev ifb0 root handle 1: hfsc default 4
> tc class add dev ifb0 parent 1:  classid 1:1 hfsc ls rate 100000kbit ul r=
ate 100000kbit # main eth0 upload
> tc class add dev ifb0 parent 1:1 classid 1:2 hfsc ls rate 460kbit ul rate=
 460kbit # main internet upload
>=20
> tc class add dev ifb0 parent 1:2 classid 1:4 hfsc ls rate 50kbit ul rate =
10kbit # bulk class
> tc class add dev ifb0 parent 1:2 classid 1:5 hfsc ls rate 200kbit ul rate=
 100kbit # wireless class
> tc qdisc add dev ifb0 parent 1:4 handle 4: sfq perturb 5 quantum 1920 # b=
ulk qdisc
> tc qdisc add dev ifb0 parent 1:5 handle 5: sfq perturb 5 quantum 1920 # w=
ifi qdisc
>=20
> tc class add dev ifb0 parent 1:1 classid 1:3 hfsc ls rate 94904kbit ul ra=
te 94904kbit # local class
> tc qdisc add dev ifb0 parent 1:3 handle 3: red min 75000 max 225000 proba=
bility 0.02 limit 675000 avpkt 1000 burst 120 bandwidth 94904
>=20
> tc filter add dev ifb0 parent 1: protocol ip prio 2 u32 match ip src 192.=
168.20.0/24 match ip dst 62.***.***.88/29 flowid 1:3
> tc filter add dev ifb0 parent 1: protocol ip prio 2 u32 match ip src 192.=
168.20.0/24 match ip dst 62.***.***.96/28 flowid 1:3
> tc filter add dev ifb0 parent 1: protocol ip prio 2 u32 match ip dst 192.=
168.20.0/24 match ip src 62.***.***.88/29 flowid 1:3
> tc filter add dev ifb0 parent 1: protocol ip prio 2 u32 match ip dst 192.=
168.20.0/24 match ip src 62.***.***.96/28 flowid 1:3
> tc filter add dev ifb0 parent 1: protocol ip prio 2 u32 match ip dst 192.=
168.20.91 match ip src 192.168.20.0/24 flowid 1:3
> tc filter add dev ifb0 parent 1: protocol ip prio 2 u32 match ip src 192.=
168.20.91 match ip dst 192.168.20.0/24 flowid 1:3
>=20
> tc filter add dev ifb0 parent 1: protocol ip prio 3 u32 match ip src 10.0=
.0.0/8 flowid 1:5
> tc filter add dev ifb0 parent 1: prio 5 handle 100: protocol ip u32 divis=
or 256
>=20
> # example_user / 192.168.20.16
> tc class add dev ifb0 parent 1:2    classid 1:0016  hfsc ls m1 400kbit d =
4s m2 100kbit ul rate 437kbit
> tc class add dev ifb0 parent 1:0016 classid 1:1016  hfsc rt rate 2847bit =
ls m1 400kbit d 4s m2 100kbit ul rate 437kbit # ack
> tc qdisc add dev ifb0 parent 1:1016 handle    1016: sfq perturb 10 quantu=
m 1920
> tc class add dev ifb0 parent 1:0016 classid 1:2016  hfsc rt rate 8372bit =
ls m1 400kbit d 4s m2 100kbit ul rate 437kbit # data
> tc qdisc add dev ifb0 parent 1:2016 handle    2016: sfq perturb 10 quantu=
m 1920
>=20
> tc filter add dev ifb0 parent 1: protocol ip prio  5 u32 ht 100:10 match =
ip protocol 6 0xff match u8 0x10 0xff at nexthdr+33 match u16 0x0000 0xffc0=
 at 2 flowid 1:1016 # ack
> tc filter add dev ifb0 parent 1: protocol ip prio 10 u32 ht 100:10 match =
u32 0 0 flowid 1:2016 # data
>=20
> (... more users ...)
>=20
> tc qdisc del dev eth0 ingress 2>&1 >/dev/null
> tc qdisc add dev eth0 ingress
>=20
> tc filter add dev eth0 parent ffff: protocol ip prio 40 u32 match ip src =
192.168.20.0/24 flowid 1: action mirred egress redirect dev ifb0
> tc filter add dev eth0 parent ffff: protocol ip prio 40 u32 match ip src =
10.0.0.0/8  flowid 1: action mirred egress redirect dev ifb0
>=20
> # Local to hashtable
> tc filter add dev ifb0 protocol ip parent 1: prio 40 u32 ht 800:: match i=
p src 192.168.20.0/24 hashkey mask 0x000000ff at 12 link 100:
>=20
> -- CUT HERE (hfsc.sh ends) --
>=20
> -- Package-specific info:
> ** Version:
> Linux version 2.6.39-2-amd64 (Debian 2.6.39-2) (ben@decadent.org.uk) (gcc=
 version 4.4.6 (Debian 4.4.6-3) ) #1 SMP Wed Jun 8 11:01:04 UTC 2011
>=20
> ** Command line:
> BOOT_IMAGE=3D/boot/vmlinuz-2.6.39-2-amd64 root=3DUUID=3Db9cc0f29-98ad-403=
4-ba84-167769b10cd6 ro quiet
>=20
> ** Tainted: W (512)
>  * Taint on warning.
>=20
> ** Kernel log:
> [ 4522.772401] ------------[ cut here ]------------
> [ 4522.772405] WARNING: at /build/buildd-linux-2.6_2.6.39-2-amd64-kuqdRa/=
linux-2.6-2.6.39/debian/build/source_amd64_none/net/sched/sch_hfsc.c:1427 h=
fsc_dequeue+0x155/0x28b [sch_hfsc]()
> [ 4522.772410] Hardware name: S2865
> [ 4522.772412] Modules linked in: act_mirred sch_ingress cls_u32 sch_red =
sch_sfq sch_hfsc ifb xt_tcpudp xt_state iptable_filter iptable_nat ip_table=
s x_tables nf_nat_ftp nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_conntrack_=
ftp nf_conntrack xfs dme1737 hwmon_vid loop snd_pcm snd_timer amd64_edac_mo=
d snd soundcore snd_page_alloc k8temp edac_core serio_raw edac_mce_amd pcsp=
kr evdev joydev parport_pc parport i2c_nforce2 processor button i2c_core ex=
t4 mbcache jbd2 crc16 raid1 md_mod sg usbhid hid sr_mod sd_mod crc_t10dif c=
drom ohci_hcd ata_generic pata_amd sata_nv libata ehci_hcd tg3 scsi_mod the=
rmal usbcore floppy fan thermal_sys libphy forcedeth [last unloaded: scsi_w=
ait_scan]
> [ 4522.772453] Pid: 3, comm: ksoftirqd/0 Tainted: G        W    2.6.39-2-=
amd64 #1
> [ 4522.772455] Call Trace:
> [ 4522.772459]  [<ffffffff810458b4>] ? warn_slowpath_common+0x78/0x8c
> [ 4522.772463]  [<ffffffffa039ab3f>] ? hfsc_dequeue+0x155/0x28b [sch_hfsc=
]
> [ 4522.772467]  [<ffffffff81291962>] ? __qdisc_run+0x93/0x11a
> [ 4522.772471]  [<ffffffff8127696f>] ? net_tx_action+0x10f/0x186
> [ 4522.772475]  [<ffffffff8104b4cf>] ? __do_softirq+0xc3/0x19e
> [ 4522.772479]  [<ffffffff8104b626>] ? run_ksoftirqd+0x7c/0x122
> [ 4522.772483]  [<ffffffff8104b5aa>] ? __do_softirq+0x19e/0x19e
> [ 4522.772486]  [<ffffffff8104b5aa>] ? __do_softirq+0x19e/0x19e
> [ 4522.772490]  [<ffffffff8105ef05>] ? kthread+0x7a/0x82
> [ 4522.772494]  [<ffffffff81339ee4>] ? kernel_thread_helper+0x4/0x10
> [ 4522.772498]  [<ffffffff8105ee8b>] ? kthread_worker_fn+0x147/0x147
> [ 4522.772502]  [<ffffffff81339ee0>] ? gs_change+0x13/0x13
> [ 4522.772505] ---[ end trace 9a0810cc4dbd421e ]---
[...]

--=20
Ben Hutchings
If at first you don't succeed, you're doing about average.

--=-b+OnCg7DELmDZtX0f/UG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIVAwUATgqlNee/yOyVhhEJAQontw//f+TiBVnchPPKT8PkI2qJHFJHYccSclbP
LFZrh5/v8QqEZcSap5mjEJ2ik9aUCXM3NIaNH1ohNBlpeayyC20yY+QxT7HYnM91
sDD/QO0SaRu+3RyZRmZJd4xPVBOKq1evYC0u1ziQwntSeGPt+s1H+N0EUteYL9WW
ZjAxjAvsC+R3vDLxAwZbX2G8tTqhKcOUuAEqgPHkwm1RczNhh9FY+so21ZQz3ATv
qNHVk6OAy4DhQwFKZAIBtyILAgoZIRmTUx1IQg322yBuc30xYKNPyV7hfT81dDrW
hW9VFBnjrPIGQhciVT/6VBJsoAJLN7tz2wJR7RzdX/bxBN3BJZ4Jz+5I2hchcr9Y
eAWoCXaUrNWaCuLdQI8eJDU+N6BCa1AerXBmO6tO9K9IDWcXyy73nS99JiPR27IK
8Fcnqdh42xz2jrbtslXwlsv3nQxGa10Qsa29SWLtyn5DFyzsNVDGuiZQw+f0v/eP
TZ90BxVUmtIrDqgLkcNbttP5vpV5F79cPXIaBxWxasHDRRHwpj/+/zIA5Dkfg/Qi
81pZPcfUZrn2+dFkanGleeE0BVQEEd+XCTfTpUic6FhR2oqNlxpZ947S4r7IQdId
7By4C0NmhL8nVLvTB+xcBnueOnnbB0lgaurH9lwLo8K9S2UulIOhXLsZqFPu3Gu9
gcaX/YNsbEU=
=esHO
-----END PGP SIGNATURE-----

--=-b+OnCg7DELmDZtX0f/UG--
