From: Harald Welte <laforge@netfilter.org>
Subject: [PATCH 2.6] fix deadlock with ip_queue and tcp local input path
Date: Mon, 30 May 2005 20:06:54 +0200
Message-ID: <20050530180654.GX22760@sunbeam.de.gnumonks.org>
References: <20050526142420.GD13114@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="vqZEy/DEMZDTzjXG"
Cc: netdev@oss.sgi.com,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050526142420.GD13114@sunbeam.de.gnumonks.org>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org


--vqZEy/DEMZDTzjXG
Content-Type: multipart/mixed; boundary="oxour8c+zPVguRmP"
Content-Disposition: inline


--oxour8c+zPVguRmP
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, May 26, 2005 at 04:24:21PM +0200, Harald Welte wrote:
=20
> When we have ip_queue being used from LOCAL_IN, then we end up with a
> situation where the verdicts coming back from userspace traverse the TCP
> input path from syscall context.  While this seems to work most of the
> time, there's an ungly deadlock:
>=20
> syscall context is interrupted by the timer interrupt.  When the timer
> interrupt leaves, the timer softirq get's scheduled and calls
> tcp_delack_timer() and alike.  They themselves do bh_lock_sock(sk),
> which is already held from somewhere else[1] -> boom.

I've now tested the suggested solution by Patrick McHardy and Herbert Xu to
simply use local_bh_{en,dis}able().

Please apply the following patch to mainline.

btw: How do we get this into 2.6.11.x ?

Signed-off-by: Harald Welte <laforge@netfilter.org>

--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--oxour8c+zPVguRmP
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment;
	filename="queue-local-reinject-smp-deadlock-fix-localbhdisable.patch"
Content-Transfer-Encoding: quoted-printable

Index: linux-2.6.10/net/ipv4/netfilter/ip_queue.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.10.orig/net/ipv4/netfilter/ip_queue.c	2005-05-27 09:44:32.000=
000000 +0200
+++ linux-2.6.10/net/ipv4/netfilter/ip_queue.c	2005-05-27 09:47:13.00000000=
0 +0200
@@ -3,6 +3,7 @@
  * communicating with userspace via netlink.
  *
  * (C) 2000-2002 James Morris <jmorris@intercode.com.au>
+ * (C) 2003-2005 Netfilter Core Team <coreteam@netfilter.org>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
@@ -14,6 +15,7 @@
  *             Zander).
  * 2000-08-01: Added Nick Williams' MAC support.
  * 2002-06-25: Code cleanup.
+ * 2005-05-26: local_bh_{disable,enable} around nf_reinject (Harald Welte)
  *
  */
 #include <linux/module.h>
@@ -66,7 +68,15 @@
 static void
 ipq_issue_verdict(struct ipq_queue_entry *entry, int verdict)
 {
+	/* TCP input path (and probably other bits) assume to be called
+	 * from softirq context, not from syscall, like ipq_issue_verdict is
+	 * called.  TCP input path deadlocks with locks taken from timer
+	 * softirq, e.g.  We therefore emulate this by local_bh_disable() */
+
+	local_bh_disable();
 	nf_reinject(entry->skb, entry->info, verdict);
+	local_bh_enable();
+
 	kfree(entry);
 }
=20

--oxour8c+zPVguRmP--

--vqZEy/DEMZDTzjXG
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFCm1Y+XaXGVTD0i/8RAufMAJ0c/XMkxoX9ELYwyvJ+K/SE9Gz68gCgj1v0
RB57oSGm8xQAhPsi4UgJT94=
=OQYS
-----END PGP SIGNATURE-----

--vqZEy/DEMZDTzjXG--
