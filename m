From: Valdis.Kletnieks@vt.edu
Subject: 2.6.22-rc3-mm1 - pppd hanging in netdev_run_todo while holding mutex
Date: Mon, 04 Jun 2007 14:00:56 -0400
Message-ID: <11184.1180980056@turing-police.cc.vt.edu>
References: <20070530235823.793f00d9.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1180980056_7893P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759261AbXFDSBk@vger.kernel.org>
In-Reply-To: Your message of "Wed, 30 May 2007 23:58:23 PDT."
             <20070530235823.793f00d9.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1180980056_7893P
Content-Type: text/plain; charset=us-ascii

On Wed, 30 May 2007 23:58:23 PDT, Andrew Morton said:
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.22-rc3/2.6.22-rc3-mm1/

Under 22-rc2-mm1, if my VPN connection got reset, ppp0 just quietly went away.

Under 22-rc3-mm1, it seems to end up wedged and waiting for references to
go away:

Jun  4 09:23:01 turing-police kernel: [90089.270707] unregister_netdevice: waiting for ppp0 to become free. Usage count = 8
Jun  4 09:23:11 turing-police kernel: [90099.396121] unregister_netdevice: waiting for ppp0 to become free. Usage count = 8
Jun  4 09:23:21 turing-police kernel: [90109.520574] unregister_netdevice: waiting for ppp0 to become free. Usage count = 8
Jun  4 09:23:32 turing-police kernel: [90119.653129] unregister_netdevice: waiting for ppp0 to become free. Usage count = 8

'echo t > /proc/sysrq_trigger' shows pppd hung up here:

Jun  4 10:52:57 turing-police kernel: [95478.047892] pppd          D 0000000105ad3830  4968  3815      1 (NOTLB)
Jun  4 10:52:57 turing-police kernel: [95478.047902]  ffff810008d5fd78 0000000000000086 0000000000000000 ffff810003490000
Jun  4 10:52:57 turing-police kernel: [95478.047911]  ffff810008d5fd28 ffff810008d4a040 ffff810003461820 ffff810008d4a2b0
Jun  4 10:52:57 turing-police kernel: [95478.047920]  0000000105ad3733 0000000000000202 00000000000000ff ffffffff80239795
Jun  4 10:52:57 turing-police kernel: [95478.047928] Call Trace:
Jun  4 10:52:57 turing-police kernel: [95478.047936]  [<ffffffff805207a2>] schedule_timeout+0x8d/0xb4
Jun  4 10:52:57 turing-police kernel: [95478.047945]  [<ffffffff805207e2>] schedule_timeout_uninterruptible+0x19/0x1b
Jun  4 10:52:57 turing-police kernel: [95478.047954]  [<ffffffff802397bb>] msleep+0x14/0x1e
Jun  4 10:52:57 turing-police kernel: [95478.047963]  [<ffffffff8048aa4e>] netdev_run_todo+0x12f/0x234 
Jun  4 10:52:57 turing-police kernel: [95478.047972]  [<ffffffff8049166f>] rtnl_unlock+0x35/0x37
Jun  4 10:52:57 turing-police kernel: [95478.047981]  [<ffffffff804894a9>] unregister_netdev+0x1e/0x23
Jun  4 10:52:57 turing-police kernel: [95478.047994]  [<ffffffff88a5f2c2>] :ppp_generic:ppp_shutdown_interface+0x67/0xbb
Jun  4 10:52:57 turing-police kernel: [95478.048018]  [<ffffffff88a5f5b8>] :ppp_generic:ppp_release+0x33/0x65
Jun  4 10:52:57 turing-police kernel: [95478.048028]  [<ffffffff8028d54a>] __fput+0xac/0x176
Jun  4 10:52:57 turing-police kernel: [95478.048036]  [<ffffffff8028d628>] fput+0x14/0x16
Jun  4 10:52:57 turing-police kernel: [95478.048045]  [<ffffffff8028a9c6>] filp_close+0x66/0x71
Jun  4 10:52:57 turing-police kernel: [95478.048054]  [<ffffffff8028bd54>] sys_close+0x98/0xd7
Jun  4 10:52:57 turing-police kernel: [95478.048062]  [<ffffffff8020a03c>] tracesys+0xdc/0xe1
Jun  4 10:52:57 turing-police kernel: [95478.048073]  [<00002b45cd2429a0>]

Which in itself wouldn't be so bad, except that it's holding a mutex and
lots of other stuff gets wedged up waiting for it (here's 1 of 6 processes
that was wedged this morning):

Jun  4 10:52:58 turing-police kernel: [95478.051129] ifconfig      D ffff810005e19820  5800  9787  20510 (NOTLB)
Jun  4 10:52:58 turing-police kernel: [95478.051141]  ffff81000868fd08 0000000000000082 ffff81000868fec8 0000000000000246
Jun  4 10:52:58 turing-police kernel: [95478.051150]  0000000100000101 ffff810005e19820 ffff810003fe0820 ffff810005e19a90
Jun  4 10:52:58 turing-police kernel: [95478.051159]  000000000a3f26c0 0000000000000006 ffff81000868ff28 ffffffff8028aacc
Jun  4 10:52:58 turing-police kernel: [95478.051167] Call Trace:
Jun  4 10:52:58 turing-police kernel: [95478.051176]  [<ffffffff80520bc4>] __mutex_lock_slowpath+0x74/0xb6
Jun  4 10:52:58 turing-police kernel: [95478.051185]  [<ffffffff805209f3>] mutex_lock+0xe/0x10
Jun  4 10:52:58 turing-police kernel: [95478.051193]  [<ffffffff8048a938>] netdev_run_todo+0x19/0x234
Jun  4 10:52:58 turing-police kernel: [95478.051202]  [<ffffffff8049166f>] rtnl_unlock+0x35/0x37
Jun  4 10:52:58 turing-police kernel: [95478.051210]  [<ffffffff8048a3f2>] dev_ioctl+0x3e3/0x483
Jun  4 10:52:58 turing-police kernel: [95478.051218]  [<ffffffff8047df30>] sock_ioctl+0x1ef/0x1fc
Jun  4 10:52:58 turing-police kernel: [95478.051227]  [<ffffffff802989be>] do_ioctl+0x2a/0x77
Jun  4 10:52:58 turing-police kernel: [95478.051235]  [<ffffffff80298c52>] vfs_ioctl+0x247/0x264
Jun  4 10:52:58 turing-police kernel: [95478.051243]  [<ffffffff80298cce>] sys_ioctl+0x5f/0x85
Jun  4 10:52:58 turing-police kernel: [95478.051252]  [<ffffffff8020a03c>] tracesys+0xdc/0xe1

(And of course, you can't shutdown cleanly, because /etc/init.d/network tries
to down other interfaces on the way out, and....)

I'd bisect this, except I don't have a better way to replicate it than "wait for
our VPN box to reset the connection after 24 hours of connect" - basically means
I get 2 tries per weekend..)

An hour or so of digging through the -rc3-mm1 broken-out/ didn't find any
obvious-to-me culprits.  Any ideas/suggestions?

--==_Exmh_1180980056_7893P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFGZFNYcC3lWbTT17ARAiKGAKDFn8repVNpToEnTqi4l2IQKs5v8gCeNJZu
Cz+L3Hiwd0nU4UL8hllitDc=
=GkFs
-----END PGP SIGNATURE-----

--==_Exmh_1180980056_7893P--
