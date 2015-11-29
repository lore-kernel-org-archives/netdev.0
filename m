From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: gigaset: freeing an active object
Date: Sun, 29 Nov 2015 16:30:35 +0100
Message-ID: <565B1A1B.8020503@imap.cc>
References: <56587467.8050102@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="sU7HbfqRIdX8G68sdWIbRlLdMrdbSNLtn"
Cc: pebolle@tiscali.nl, isdn@linux-pingi.de, davem@davemloft.net,
	gigaset307x-common@lists.sourceforge.net,
	LKML <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>
To: Sasha Levin <sasha.levin@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:56483 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750759AbbK2Paz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2015 10:30:55 -0500
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id 3B2652080A
	for <netdev@vger.kernel.org>; Sun, 29 Nov 2015 10:30:52 -0500 (EST)
In-Reply-To: <56587467.8050102@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--sU7HbfqRIdX8G68sdWIbRlLdMrdbSNLtn
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Hi Sasha,

thanks for the report. As the original author of the code in question, I
am somewhat at a loss what to make of it.

Am 27.11.2015 um 16:19 schrieb Sasha Levin:
> Fuzzing with syzkaller on the latest -next kernel produced this error:

Is there a way to know the actual sequence of events that triggered this
warning?

> [  413.536749] WARNING: CPU: 6 PID: 25400 at lib/debugobjects.c:263 deb=
ug_print_object+0x1c4/0x1e0()
> [  413.538111] ODEBUG: free active (active state 0) object type: timer_=
list hint: delayed_work_timer_fn+0x0/0x90

This message seems to indicate that an object of type timer_list was
freed which was still active. However the driver in question
(ser_gigaset) does not use any timers.

What are the exact conditions for producing this message? IOW how does
the ODEBUG code determine that an object of type timer_list is being
freed, and that it is still in use?

Are there any messages from ser_gigaset or another one of the gigaset
drivers before that warning?

> [  413.539598] Modules linked in:3470693efef57268844f02f5de3ab392d8cf5e=
209671ddd87163cb964c510659

This message does not tell me anything. What does that hex string after
the colon mean?

> [  413.540448] CPU: 6 PID: 25400 Comm: syzkaller_execu Not tainted 4.4.=
0-rc2-next-20151126-sasha-00005-g00d303e-dirty #2653
> [  413.547614] Call Trace:
> [  413.548077]  [<ffffffffa8e6b5bb>] dump_stack+0x72/0xb7
> [  413.548765]  [<ffffffffa73531d3>] warn_slowpath_common+0x113/0x140
> [  413.551151]  [<ffffffffa73532cb>] warn_slowpath_fmt+0xcb/0x100
> [  413.554295]  [<ffffffffa8ed0194>] debug_print_object+0x1c4/0x1e0
> [  413.556592]  [<ffffffffa8ed1035>] __debug_check_no_obj_freed+0x215/0=
x7a0
> [  413.560526]  [<ffffffffa8ed2b6c>] debug_check_no_obj_freed+0x2c/0x40=

> [  413.561328]  [<ffffffffa77aac4c>] kfree+0x1fc/0x2f0

Judging from the backtrace below this must be the call

        kfree(cs->hw.ser);

in drivers/isdn/gigaset/ser-gigaset.c line 375.
cs->hw.ser is of type struct ser_cardstate *.
struct ser_cardstate consists of a struct platform_device, a struct
completion, an atomic_t and a pointer. No timer_list.

> [  413.561970]  [<ffffffffae74b021>] gigaset_freecshw+0xe1/0x120

There are functions by this name in all three Gigaset hardware dependent
modules (bas_gigaset, ser_gigaset and usb_gigaset), but ...

> [  413.562723]  [<ffffffffae70669d>] gigaset_freecs+0x2ad/0x600
> [  413.564240]  [<ffffffffae74ba60>] gigaset_tty_close+0x210/0x280

this function only exists in ser_gigaset.

Thanks,
Tilman

--=20
Tilman Schmidt                              E-Mail: tilman@imap.cc
Bonn, Germany
Nous, on a des fleurs et des bougies pour nous prot=C3=A9ger.


--sU7HbfqRIdX8G68sdWIbRlLdMrdbSNLtn
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJWWxoqAAoJEFPuqx0v+F+qIm8H/RKWmFocpKNd2NUgpFY+f/cd
l7PXUwlvXWnpO/0TLdb7NGxB9d8jvC2dMbDU+7e9+ARGJXsi/Tyud75xfGR5iuU1
h4sIyTm2wacJHGdCQnr8bgPqQMDeDtlgMW6Vs7jWE7G4MYs92ybkdpXcJ+mvnh6G
wJB70IobQrNzDOd2t/QcnYJwFsMu8GKtAcq4l5JeCs2b+k+e397ktT0qHR7KVL4v
PFLrRaEH9so+u1h8EwZLkZTpR8ptm2GW4Qs4VkaxpIyNRcHPgfeJ7HMxStmWI3Gt
sYpcSbxVI4M3WAOHLLdCWK+y9kRBgybXj73lCGMmQZ+yfPtKHcCPkZEzygzYef4=
=BBRg
-----END PGP SIGNATURE-----

--sU7HbfqRIdX8G68sdWIbRlLdMrdbSNLtn--
