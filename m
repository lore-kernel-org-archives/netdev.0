From: Daniel Willmann <d.willmann@tu-bs.de>
Subject: tg3 kernel oops when setting flow control while interface is down
 (2.6.10)
Date: Mon, 28 Feb 2005 03:59:00 +0100
Message-ID: <20050228035900.416f633c@elara.orbit.homelinux.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
 boundary=Signature_Mon__28_Feb_2005_03_59_00_+0100_jjta_L.DSeb85H7p;
 protocol="application/pgp-signature"; micalg=pgp-sha1
Cc: jluebbe@lasnet.de, davem@redhat.com
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--Signature_Mon__28_Feb_2005_03_59_00_+0100_jjta_L.DSeb85H7p
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Dear netdevs,

a colleague and I discovered a bug in the Tigon3 driver.
tg3_set_pauseparams should check if the interface is down. Right now it
doesn't and ends up in tg3_free_rings where it assumes that
tp->rx_std_buffers[i] does point to a sane address. This is not the case
and "if (rxp->skb =3D=3D NULL)" breaks. (drivers/net/tg3.c line 3299).

Steps to reproduce:
* ip link set eth0 down
* ethtool -A eth0 autoneg off

We have added the check from tg3_set_settings to tg3_set_pauseparam to
return -EAGAIN when the interface is down which works for us.
ethtool then returns "Resource temporarily unavailable" if you try to
set flowcontrol with -A.

The patch and the kernel oops follows.

Sincerely,

Jan Luebbe and Daniel Willmann


--- drivers/net/tg3.c.old	2005-02-27 23:26:48.000000000 +0100
+++ drivers/net/tg3.c	2005-02-28 02:01:11.000000000 +0100
@@ -6155,6 +6155,10 @@
 {
 	struct tg3 *tp =3D netdev_priv(dev);
  =20
+	if (!(tp->tg3_flags & TG3_FLAG_INIT_COMPLETE) ||
+	    tp->link_config.phy_is_low_power)
+		return -EAGAIN;
+
 	tg3_netif_stop(tp);
 	spin_lock_irq(&tp->lock);
 	spin_lock(&tp->tx_lock);

--------

Feb 27 23:55:24 hiro kernel: Unable to handle kernel NULL pointer dereferen=
ce at virtual address 00000000
Feb 27 23:55:24 hiro kernel:  printing eip:
Feb 27 23:55:24 hiro kernel: c0325114
Feb 27 23:55:24 hiro kernel: *pde =3D 36c10001
Feb 27 23:55:24 hiro kernel: *pte =3D 00000000
Feb 27 23:55:24 hiro kernel: Oops: 0000 [#1]
Feb 27 23:55:24 hiro kernel: PREEMPT SMP=20
Feb 27 23:55:24 hiro kernel: Modules linked in: 8021q piix hw_random shpchp=
 pci_hotplug evdev ide_cd ide_core cdrom unix
Feb 27 23:55:24 hiro kernel: CPU:    0
Feb 27 23:55:24 hiro kernel: EIP:    0060:[tg3_free_rings+100/704]    Not t=
ainted VLI
Feb 27 23:55:24 hiro kernel: EFLAGS: 00010082   (2.6.10-hiro)=20
Feb 27 23:55:24 hiro kernel: EIP is at tg3_free_rings+0x64/0x2c0
Feb 27 23:55:24 hiro kernel: eax: 00000021   ebx: 00000000   ecx: c04cc890 =
  edx: 00000092
Feb 27 23:55:24 hiro kernel: esi: 00000000   edi: 00000000   ebp: f6d9fef0 =
  esp: f6d9fe30
Feb 27 23:55:24 hiro kernel: ds: 007b   es: 007b   ss: 0068
Feb 27 23:55:24 hiro kernel: Process ethtool (pid: 3601, threadinfo=3Df6d9e=
000 task=3Df71b1020)
Feb 27 23:55:24 hiro kernel: Stack: c0497f00 00000000 00000000 f7e59220 000=
00000 f7e59220 f7e59220 f6d9fef0=20
Feb 27 23:55:24 hiro kernel:        c0325393 f7e59220 f7e59220 f6d9fe80 000=
00000 f7e59220 00000000 f7e59220=20
Feb 27 23:55:24 hiro kernel:        f7e59220 f6d9fef0 c0327314 f7e59220 f7e=
59220 00000000 c0498700 f6d9feb0=20
Feb 27 23:55:24 hiro kernel: Call Trace:
Feb 27 23:55:24 hiro kernel:  [tg3_init_rings+35/368] tg3_init_rings+0x23/0=
x170
Feb 27 23:55:24 hiro kernel:  [tg3_reset_hw+260/5360] tg3_reset_hw+0x104/0x=
14f0
Feb 27 23:55:24 hiro kernel:  [tg3_init_hw+138/192] tg3_init_hw+0x8a/0xc0
Feb 27 23:55:24 hiro kernel:  [tg3_set_pauseparam+267/464] tg3_set_pausepar=
am+0x10b/0x1d0
Feb 27 23:55:24 hiro kernel:  [ethtool_set_pauseparam+81/112] ethtool_set_p=
auseparam+0x51/0x70
Feb 27 23:55:24 hiro kernel:  [dev_ethtool+511/800] dev_ethtool+0x1ff/0x320
Feb 27 23:55:24 hiro kernel:  [dev_ioctl+308/624] dev_ioctl+0x134/0x270
Feb 27 23:55:24 hiro kernel:  [inet_ioctl+156/176] inet_ioctl+0x9c/0xb0
Feb 27 23:55:24 hiro kernel:  [sock_ioctl+201/592] sock_ioctl+0xc9/0x250
Feb 27 23:55:24 hiro kernel:  [sys_ioctl+202/560] sys_ioctl+0xca/0x230
Feb 27 23:55:24 hiro kernel:  [syscall_call+7/11] syscall_call+0x7/0xb
Feb 27 23:55:24 hiro kernel: Code: c0 8d 04 b8 89 44 24 08 e8 3a 8a df ff 8=
b 4c 24 24 8b 41 60 89 7c 24 04 c7 04 24 00 7f 49 c0 8d 34 b8 89 74 24 08 e=
8 1c 8a df ff <8b> 0e 85 c9 0f 85 c4 01 00 00 47 81 ff ff 01 00 00 7e a9 31=
 ff=20
Feb 27 23:55:24 hiro kernel:  <6>note: ethtool[3601] exited with preempt_co=
unt 2


--Signature_Mon__28_Feb_2005_03_59_00_+0100_jjta_L.DSeb85H7p
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQFCIoj3Z2fhlIqbZ1gRAj8mAKCu1gYpAvb6dLflG4ZWKPCCG5LCeACfVMiL
vTRdciQerViGrmumxMCwhz4=
=Kcuz
-----END PGP SIGNATURE-----

--Signature_Mon__28_Feb_2005_03_59_00_+0100_jjta_L.DSeb85H7p--
