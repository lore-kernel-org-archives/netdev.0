From: David Woodhouse <dwmw2@infradead.org>
Subject: 8139cp TX stall, timeout, failed recovery
Date: Sat, 24 Nov 2012 18:39:25 +0000
Message-ID: <1353782365.26346.266.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="sha1"; protocol="application/x-pkcs7-signature";
	boundary="=-PJSahic33nsb7ROUoUBQ"
Cc: romieu@fr.zoreil.com, jasowang@redhat.com, gilboad@gmail.com,
	jgarzik@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:41208 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752073Ab2KXSjb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Nov 2012 13:39:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-PJSahic33nsb7ROUoUBQ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

When I stress it hard, I see a Tx timeout that it doesn't recover from.
This is 3.6.7, with or without my recent init path patch (and with or
without my BQL patch).

To reproduce this, I send a *large* flood of packets (ping -l 1000) from
inside my network to the ADSL router. Its internal-facing interface is
an 8139cp. It seems to work best if the packets are destined for the
outside world over the ADSL lines, rather than the router itself. But
it's hard to tell. I need between 10 and 30 runs of 'ping -l 1000
$outside' before it happens. Or sometimes more...

Log shows it all running fine, followed by a flood of incoming packets
starting at around 28498.05. At 28498.060901 we queue a new tx, and
*immediately* afterwards (28498.060936) we get an interrupt with status
0x0080 (Tx Descriptor Unavailable, but no Tx Done). That's the last
tx-related interrupt we ever get.

This seems to be a consistent pattern =E2=80=94 when we get that 0x0080
interrupt and it dies, it's *very* soon after queueing a new tx:

8139dead2.cap-[27538.841952] 8139cp 0000:00:0b.0: eth1: tx queued, slot 54,=
 skblen 98
8139dead2.cap:[27538.841985] 8139cp 0000:00:0b.0: eth1: intr, status 0080 c=
md 0c cpcmd 002b
--
8139dead3a.cap-[28498.060901] 8139cp 0000:00:0b.0: eth1: tx queued, slot 12=
, skblen 98
8139dead3a.cap:[28498.060936] 8139cp 0000:00:0b.0: eth1: intr, status 0080 =
cmd 0c cpcmd 002b
--
8139dead4.cap-[30230.248780] 8139cp 0000:00:0b.0: eth1: tx queued, slot 27,=
 skblen 98
8139dead4.cap:[30230.248816] 8139cp 0000:00:0b.0: eth1: intr, status 0080 c=
md 0c cpcmd 002b
--
8139dead.cap-[  228.119159] 8139cp 0000:00:0b.0: eth1: tx queued, slot 63, =
skblen 98
8139dead.cap:[  228.119195] 8139cp 0000:00:0b.0: eth1: intr, status 0080 cm=
d 0c cpcmd 002b

Here's a full log of one of those, showing the failure to recover too...

Looking at it now... do we wrap around the Rx ring buffer at 28498.055
and process some of the packets more than once? Or is the hardware
genuinely keeping up with us as we suck out, descriptors 51-63, 0-63,
and 0-39 again all off the same interrupt? Perhaps there lies the root
of the problem?

[28497.924957] 8139cp 0000:00:0b.0: eth1: rx slot 44 status 0x320141d8 len =
468
[28498.032253] 8139cp 0000:00:0b.0: eth1: intr, status 0001 cmd 0c cpcmd 00=
2b
[28498.032300] 8139cp 0000:00:0b.0: eth1: rx slot 45 status 0x32022062 len =
94
[28498.040770] 8139cp 0000:00:0b.0: eth1: tx queued, slot 7, skblen 110
[28498.040816] 8139cp 0000:00:0b.0: eth1: intr, status 0484 cmd 0c cpcmd 00=
2b
[28498.040836] 8139cp 0000:00:0b.0: eth1: tx done, slot 6
[28498.041048] 8139cp 0000:00:0b.0: eth1: tx queued, slot 8, skblen 1514
[28498.041090] 8139cp 0000:00:0b.0: eth1: intr, status 0484 cmd 0c cpcmd 00=
2b
[28498.041108] 8139cp 0000:00:0b.0: eth1: tx done, slot 7
[28498.041177] 8139cp 0000:00:0b.0: eth1: tx queued, slot 9, skblen 1514
[28498.041218] 8139cp 0000:00:0b.0: eth1: intr, status 0484 cmd 0c cpcmd 00=
2b
[28498.041236] 8139cp 0000:00:0b.0: eth1: tx done, slot 8
[28498.041677] 8139cp 0000:00:0b.0: eth1: intr, status 0001 cmd 0c cpcmd 00=
2b
[28498.041709] 8139cp 0000:00:0b.0: eth1: rx slot 46 status 0x3200e04e len =
74
[28498.041846] 8139cp 0000:00:0b.0: eth1: tx queued, slot 10, skblen 533
[28498.041882] 8139cp 0000:00:0b.0: eth1: intr, status 0484 cmd 0c cpcmd 00=
2b
[28498.041901] 8139cp 0000:00:0b.0: eth1: tx done, slot 9
[28498.043028] 8139cp 0000:00:0b.0: eth1: intr, status 0001 cmd 0c cpcmd 00=
2b
[28498.043056] 8139cp 0000:00:0b.0: eth1: rx slot 47 status 0x3200e04e len =
74
[28498.043264] 8139cp 0000:00:0b.0: eth1: intr, status 0001 cmd 0c cpcmd 00=
2b
[28498.043291] 8139cp 0000:00:0b.0: eth1: rx slot 48 status 0x3200e04e len =
74
[28498.043456] 8139cp 0000:00:0b.0: eth1: intr, status 0001 cmd 0c cpcmd 00=
2b
[28498.043483] 8139cp 0000:00:0b.0: eth1: rx slot 49 status 0x3200e04e len =
74
[28498.043905] 8139cp 0000:00:0b.0: eth1: tx queued, slot 11, skblen 245
[28498.043941] 8139cp 0000:00:0b.0: eth1: intr, status 0484 cmd 0c cpcmd 00=
2b
[28498.043960] 8139cp 0000:00:0b.0: eth1: tx done, slot 10
[28498.051129] 8139cp 0000:00:0b.0: eth1: intr, status 0001 cmd 0c cpcmd 00=
2b
[28498.051165] 8139cp 0000:00:0b.0: eth1: rx slot 50 status 0x32036066 len =
98
[28498.051333] 8139cp 0000:00:0b.0: eth1: rx slot 51 status 0x32036066 len =
98
[28498.051394] 8139cp 0000:00:0b.0: eth1: rx slot 52 status 0x32036066 len =
98
[28498.051451] 8139cp 0000:00:0b.0: eth1: rx slot 53 status 0x32036066 len =
98
[28498.051523] 8139cp 0000:00:0b.0: eth1: rx slot 54 status 0x32036066 len =
98
[28498.051575] 8139cp 0000:00:0b.0: eth1: rx slot 55 status 0x32036066 len =
98
[28498.051623] 8139cp 0000:00:0b.0: eth1: rx slot 56 status 0x32036066 len =
98
[28498.051672] 8139cp 0000:00:0b.0: eth1: rx slot 57 status 0x32036066 len =
98
[28498.051720] 8139cp 0000:00:0b.0: eth1: rx slot 58 status 0x32036066 len =
98
[28498.051771] 8139cp 0000:00:0b.0: eth1: rx slot 59 status 0x32036066 len =
98
[28498.051821] 8139cp 0000:00:0b.0: eth1: rx slot 60 status 0x32036066 len =
98
[28498.051871] 8139cp 0000:00:0b.0: eth1: rx slot 61 status 0x32036066 len =
98
[28498.051962] 8139cp 0000:00:0b.0: eth1: intr, status 0001 cmd 0c cpcmd 00=
2b
[28498.051989] 8139cp 0000:00:0b.0: eth1: rx slot 62 status 0x32036066 len =
98
[28498.052041] 8139cp 0000:00:0b.0: eth1: rx slot 63 status 0x72036066 len =
98
[28498.052089] 8139cp 0000:00:0b.0: eth1: rx slot 0 status 0x32036066 len 9=
8
[28498.052139] 8139cp 0000:00:0b.0: eth1: rx slot 1 status 0x32036066 len 9=
8
[28498.052189] 8139cp 0000:00:0b.0: eth1: rx slot 2 status 0x32036066 len 9=
8
[28498.052238] 8139cp 0000:00:0b.0: eth1: rx slot 3 status 0x32036066 len 9=
8
[28498.052287] 8139cp 0000:00:0b.0: eth1: rx slot 4 status 0x32036066 len 9=
8
[28498.052370] 8139cp 0000:00:0b.0: eth1: intr, status 0001 cmd 0c cpcmd 00=
2b
[28498.052396] 8139cp 0000:00:0b.0: eth1: rx slot 5 status 0x32036066 len 9=
8
[28498.052446] 8139cp 0000:00:0b.0: eth1: rx slot 6 status 0x32036066 len 9=
8
[28498.052496] 8139cp 0000:00:0b.0: eth1: rx slot 7 status 0x32036066 len 9=
8
[28498.052562] 8139cp 0000:00:0b.0: eth1: rx slot 8 status 0x32036066 len 9=
8
[28498.052612] 8139cp 0000:00:0b.0: eth1: rx slot 9 status 0x32036066 len 9=
8
[28498.052661] 8139cp 0000:00:0b.0: eth1: rx slot 10 status 0x32036066 len =
98
[28498.052711] 8139cp 0000:00:0b.0: eth1: rx slot 11 status 0x32036066 len =
98
[28498.052760] 8139cp 0000:00:0b.0: eth1: rx slot 12 status 0x32036066 len =
98
[28498.052810] 8139cp 0000:00:0b.0: eth1: rx slot 13 status 0x32036066 len =
98
[28498.052860] 8139cp 0000:00:0b.0: eth1: rx slot 14 status 0x32036066 len =
98
[28498.052975] 8139cp 0000:00:0b.0: eth1: intr, status 0001 cmd 0c cpcmd 00=
2b
[28498.053001] 8139cp 0000:00:0b.0: eth1: rx slot 15 status 0x32036066 len =
98
[28498.053053] 8139cp 0000:00:0b.0: eth1: rx slot 16 status 0x32036066 len =
98
[28498.053103] 8139cp 0000:00:0b.0: eth1: rx slot 17 status 0x32036066 len =
98
[28498.053151] 8139cp 0000:00:0b.0: eth1: rx slot 18 status 0x32036066 len =
98
[28498.053201] 8139cp 0000:00:0b.0: eth1: rx slot 19 status 0x32036066 len =
98
[28498.053249] 8139cp 0000:00:0b.0: eth1: rx slot 20 status 0x32036066 len =
98
[28498.053299] 8139cp 0000:00:0b.0: eth1: rx slot 21 status 0x32036066 len =
98
[28498.053348] 8139cp 0000:00:0b.0: eth1: rx slot 22 status 0x32036066 len =
98
[28498.053397] 8139cp 0000:00:0b.0: eth1: rx slot 23 status 0x32036066 len =
98
[28498.053446] 8139cp 0000:00:0b.0: eth1: rx slot 24 status 0x32036066 len =
98
[28498.053495] 8139cp 0000:00:0b.0: eth1: rx slot 25 status 0x32036066 len =
98
[28498.053561] 8139cp 0000:00:0b.0: eth1: rx slot 26 status 0x32036066 len =
98
[28498.053611] 8139cp 0000:00:0b.0: eth1: rx slot 27 status 0x32036066 len =
98
[28498.053661] 8139cp 0000:00:0b.0: eth1: rx slot 28 status 0x32036066 len =
98
[28498.053711] 8139cp 0000:00:0b.0: eth1: rx slot 29 status 0x32036066 len =
98
[28498.053760] 8139cp 0000:00:0b.0: eth1: rx slot 30 status 0x32036066 len =
98
[28498.053810] 8139cp 0000:00:0b.0: eth1: rx slot 31 status 0x32036066 len =
98
[28498.053860] 8139cp 0000:00:0b.0: eth1: rx slot 32 status 0x32036066 len =
98
[28498.053947] 8139cp 0000:00:0b.0: eth1: intr, status 0001 cmd 0c cpcmd 00=
2b
[28498.053973] 8139cp 0000:00:0b.0: eth1: rx slot 33 status 0x32036066 len =
98
[28498.054025] 8139cp 0000:00:0b.0: eth1: rx slot 34 status 0x32036066 len =
98
[28498.054074] 8139cp 0000:00:0b.0: eth1: rx slot 35 status 0x32036066 len =
98
[28498.054123] 8139cp 0000:00:0b.0: eth1: rx slot 36 status 0x32036066 len =
98
[28498.054173] 8139cp 0000:00:0b.0: eth1: rx slot 37 status 0x32036066 len =
98
[28498.054222] 8139cp 0000:00:0b.0: eth1: rx slot 38 status 0x32036066 len =
98
[28498.054272] 8139cp 0000:00:0b.0: eth1: rx slot 39 status 0x32036066 len =
98
[28498.054320] 8139cp 0000:00:0b.0: eth1: rx slot 40 status 0x32036066 len =
98
[28498.054405] 8139cp 0000:00:0b.0: eth1: intr, status 0001 cmd 0c cpcmd 00=
2b
[28498.054432] 8139cp 0000:00:0b.0: eth1: rx slot 41 status 0x32036066 len =
98
[28498.054482] 8139cp 0000:00:0b.0: eth1: rx slot 42 status 0x32036066 len =
98
[28498.054548] 8139cp 0000:00:0b.0: eth1: rx slot 43 status 0x32036066 len =
98
[28498.054597] 8139cp 0000:00:0b.0: eth1: rx slot 44 status 0x32036066 len =
98
[28498.054648] 8139cp 0000:00:0b.0: eth1: rx slot 45 status 0x32036066 len =
98
[28498.054697] 8139cp 0000:00:0b.0: eth1: rx slot 46 status 0x32036066 len =
98
[28498.054747] 8139cp 0000:00:0b.0: eth1: rx slot 47 status 0x32036066 len =
98
[28498.054796] 8139cp 0000:00:0b.0: eth1: rx slot 48 status 0x32036066 len =
98
[28498.054846] 8139cp 0000:00:0b.0: eth1: rx slot 49 status 0x32036066 len =
98
[28498.054895] 8139cp 0000:00:0b.0: eth1: rx slot 50 status 0x32036066 len =
98
[28498.055030] 8139cp 0000:00:0b.0: eth1: intr, status 0001 cmd 0c cpcmd 00=
2b
[28498.055057] 8139cp 0000:00:0b.0: eth1: rx slot 51 status 0x32036066 len =
98
[28498.055109] 8139cp 0000:00:0b.0: eth1: rx slot 52 status 0x32036066 len =
98
[28498.055158] 8139cp 0000:00:0b.0: eth1: rx slot 53 status 0x32036066 len =
98
[28498.055206] 8139cp 0000:00:0b.0: eth1: rx slot 54 status 0x32036066 len =
98
[28498.055256] 8139cp 0000:00:0b.0: eth1: rx slot 55 status 0x32036066 len =
98
[28498.055305] 8139cp 0000:00:0b.0: eth1: rx slot 56 status 0x32036066 len =
98
[28498.055355] 8139cp 0000:00:0b.0: eth1: rx slot 57 status 0x32036066 len =
98
[28498.055403] 8139cp 0000:00:0b.0: eth1: rx slot 58 status 0x32036066 len =
98
[28498.055453] 8139cp 0000:00:0b.0: eth1: rx slot 59 status 0x32036066 len =
98
[28498.055519] 8139cp 0000:00:0b.0: eth1: rx slot 60 status 0x32036066 len =
98
[28498.055568] 8139cp 0000:00:0b.0: eth1: rx slot 61 status 0x32036066 len =
98
[28498.055617] 8139cp 0000:00:0b.0: eth1: rx slot 62 status 0x32036066 len =
98
[28498.055666] 8139cp 0000:00:0b.0: eth1: rx slot 63 status 0x72036066 len =
98
[28498.055715] 8139cp 0000:00:0b.0: eth1: rx slot 0 status 0x32036066 len 9=
8
[28498.055763] 8139cp 0000:00:0b.0: eth1: rx slot 1 status 0x32036066 len 9=
8
[28498.055812] 8139cp 0000:00:0b.0: eth1: rx slot 2 status 0x32036066 len 9=
8
[28498.055861] 8139cp 0000:00:0b.0: eth1: rx slot 3 status 0x32036066 len 9=
8
[28498.055910] 8139cp 0000:00:0b.0: eth1: rx slot 4 status 0x32036066 len 9=
8
[28498.055958] 8139cp 0000:00:0b.0: eth1: rx slot 5 status 0x32036066 len 9=
8
[28498.056007] 8139cp 0000:00:0b.0: eth1: rx slot 6 status 0x32036066 len 9=
8
[28498.056056] 8139cp 0000:00:0b.0: eth1: rx slot 7 status 0x32036066 len 9=
8
[28498.056105] 8139cp 0000:00:0b.0: eth1: rx slot 8 status 0x32036066 len 9=
8
[28498.056154] 8139cp 0000:00:0b.0: eth1: rx slot 9 status 0x32036066 len 9=
8
[28498.056202] 8139cp 0000:00:0b.0: eth1: rx slot 10 status 0x32036066 len =
98
[28498.056251] 8139cp 0000:00:0b.0: eth1: rx slot 11 status 0x32036066 len =
98
[28498.056300] 8139cp 0000:00:0b.0: eth1: rx slot 12 status 0x32036066 len =
98
[28498.056349] 8139cp 0000:00:0b.0: eth1: rx slot 13 status 0x32036066 len =
98
[28498.056398] 8139cp 0000:00:0b.0: eth1: rx slot 14 status 0x32036066 len =
98
[28498.056447] 8139cp 0000:00:0b.0: eth1: rx slot 15 status 0x32036066 len =
98
[28498.056495] 8139cp 0000:00:0b.0: eth1: rx slot 16 status 0x32036066 len =
98
[28498.056544] 8139cp 0000:00:0b.0: eth1: rx slot 17 status 0x32036066 len =
98
[28498.056593] 8139cp 0000:00:0b.0: eth1: rx slot 18 status 0x32036066 len =
98
[28498.056678] 8139cp 0000:00:0b.0: eth1: rx slot 19 status 0x32036066 len =
98
[28498.056728] 8139cp 0000:00:0b.0: eth1: rx slot 20 status 0x32036066 len =
98
[28498.056777] 8139cp 0000:00:0b.0: eth1: rx slot 21 status 0x32036066 len =
98
[28498.056826] 8139cp 0000:00:0b.0: eth1: rx slot 22 status 0x32036066 len =
98
[28498.056875] 8139cp 0000:00:0b.0: eth1: rx slot 23 status 0x32036066 len =
98
[28498.056923] 8139cp 0000:00:0b.0: eth1: rx slot 24 status 0x32036066 len =
98
[28498.056972] 8139cp 0000:00:0b.0: eth1: rx slot 25 status 0x32036066 len =
98
[28498.057020] 8139cp 0000:00:0b.0: eth1: rx slot 26 status 0x32036066 len =
98
[28498.057069] 8139cp 0000:00:0b.0: eth1: rx slot 27 status 0x32036066 len =
98
[28498.057117] 8139cp 0000:00:0b.0: eth1: rx slot 28 status 0x32036066 len =
98
[28498.057166] 8139cp 0000:00:0b.0: eth1: rx slot 29 status 0x32036066 len =
98
[28498.057214] 8139cp 0000:00:0b.0: eth1: rx slot 30 status 0x32036066 len =
98
[28498.057263] 8139cp 0000:00:0b.0: eth1: rx slot 31 status 0x32036066 len =
98
[28498.057312] 8139cp 0000:00:0b.0: eth1: rx slot 32 status 0x32036066 len =
98
[28498.057362] 8139cp 0000:00:0b.0: eth1: rx slot 33 status 0x32036066 len =
98
[28498.057410] 8139cp 0000:00:0b.0: eth1: rx slot 34 status 0x32036066 len =
98
[28498.057459] 8139cp 0000:00:0b.0: eth1: rx slot 35 status 0x32036066 len =
98
[28498.057508] 8139cp 0000:00:0b.0: eth1: rx slot 36 status 0x32036066 len =
98
[28498.057557] 8139cp 0000:00:0b.0: eth1: rx slot 37 status 0x32036066 len =
98
[28498.057606] 8139cp 0000:00:0b.0: eth1: rx slot 38 status 0x32036066 len =
98
[28498.057654] 8139cp 0000:00:0b.0: eth1: rx slot 39 status 0x32036066 len =
98
[28498.057703] 8139cp 0000:00:0b.0: eth1: rx slot 40 status 0x32036066 len =
98
[28498.057752] 8139cp 0000:00:0b.0: eth1: rx slot 41 status 0x32036066 len =
98
[28498.057800] 8139cp 0000:00:0b.0: eth1: rx slot 42 status 0x32036066 len =
98
[28498.057848] 8139cp 0000:00:0b.0: eth1: rx slot 43 status 0x32036066 len =
98
[28498.057897] 8139cp 0000:00:0b.0: eth1: rx slot 44 status 0x32036066 len =
98
[28498.057946] 8139cp 0000:00:0b.0: eth1: rx slot 45 status 0x32036066 len =
98
[28498.057994] 8139cp 0000:00:0b.0: eth1: rx slot 46 status 0x32036066 len =
98
[28498.058043] 8139cp 0000:00:0b.0: eth1: rx slot 47 status 0x32036066 len =
98
[28498.058091] 8139cp 0000:00:0b.0: eth1: rx slot 48 status 0x32036066 len =
98
[28498.058141] 8139cp 0000:00:0b.0: eth1: rx slot 49 status 0x32036066 len =
98
[28498.058190] 8139cp 0000:00:0b.0: eth1: rx slot 50 status 0x32036066 len =
98
[28498.058238] 8139cp 0000:00:0b.0: eth1: rx slot 51 status 0x32036066 len =
98
[28498.058287] 8139cp 0000:00:0b.0: eth1: rx slot 52 status 0x32036066 len =
98
[28498.058337] 8139cp 0000:00:0b.0: eth1: rx slot 53 status 0x32036066 len =
98
[28498.058385] 8139cp 0000:00:0b.0: eth1: rx slot 54 status 0x32036066 len =
98
[28498.058434] 8139cp 0000:00:0b.0: eth1: rx slot 55 status 0x32036066 len =
98
[28498.058482] 8139cp 0000:00:0b.0: eth1: rx slot 56 status 0x32036066 len =
98
[28498.058531] 8139cp 0000:00:0b.0: eth1: rx slot 57 status 0x32036066 len =
98
[28498.058579] 8139cp 0000:00:0b.0: eth1: rx slot 58 status 0x32036066 len =
98
[28498.058629] 8139cp 0000:00:0b.0: eth1: rx slot 59 status 0x32036066 len =
98
[28498.058678] 8139cp 0000:00:0b.0: eth1: rx slot 60 status 0x32036066 len =
98
[28498.058727] 8139cp 0000:00:0b.0: eth1: rx slot 61 status 0x32036066 len =
98
[28498.058775] 8139cp 0000:00:0b.0: eth1: rx slot 62 status 0x32036066 len =
98
[28498.058824] 8139cp 0000:00:0b.0: eth1: rx slot 63 status 0x72036066 len =
98
[28498.058872] 8139cp 0000:00:0b.0: eth1: rx slot 0 status 0x32036066 len 9=
8
[28498.058921] 8139cp 0000:00:0b.0: eth1: rx slot 1 status 0x32036066 len 9=
8
[28498.058969] 8139cp 0000:00:0b.0: eth1: rx slot 2 status 0x32036066 len 9=
8
[28498.059018] 8139cp 0000:00:0b.0: eth1: rx slot 3 status 0x32036066 len 9=
8
[28498.059066] 8139cp 0000:00:0b.0: eth1: rx slot 4 status 0x32036066 len 9=
8
[28498.059115] 8139cp 0000:00:0b.0: eth1: rx slot 5 status 0x32036066 len 9=
8
[28498.059164] 8139cp 0000:00:0b.0: eth1: rx slot 6 status 0x32036066 len 9=
8
[28498.059212] 8139cp 0000:00:0b.0: eth1: rx slot 7 status 0x32036066 len 9=
8
[28498.059261] 8139cp 0000:00:0b.0: eth1: rx slot 8 status 0x32036066 len 9=
8
[28498.059309] 8139cp 0000:00:0b.0: eth1: rx slot 9 status 0x32036066 len 9=
8
[28498.059358] 8139cp 0000:00:0b.0: eth1: rx slot 10 status 0x32036066 len =
98
[28498.059407] 8139cp 0000:00:0b.0: eth1: rx slot 11 status 0x32036066 len =
98
[28498.059455] 8139cp 0000:00:0b.0: eth1: rx slot 12 status 0x32036066 len =
98
[28498.059504] 8139cp 0000:00:0b.0: eth1: rx slot 13 status 0x32036066 len =
98
[28498.059553] 8139cp 0000:00:0b.0: eth1: rx slot 14 status 0x32036066 len =
98
[28498.059602] 8139cp 0000:00:0b.0: eth1: rx slot 15 status 0x32036066 len =
98
[28498.059651] 8139cp 0000:00:0b.0: eth1: rx slot 16 status 0x32036066 len =
98
[28498.059700] 8139cp 0000:00:0b.0: eth1: rx slot 17 status 0x32036066 len =
98
[28498.059748] 8139cp 0000:00:0b.0: eth1: rx slot 18 status 0x32036066 len =
98
[28498.059814] 8139cp 0000:00:0b.0: eth1: rx slot 19 status 0x32036066 len =
98
[28498.059863] 8139cp 0000:00:0b.0: eth1: rx slot 20 status 0x32036066 len =
98
[28498.059913] 8139cp 0000:00:0b.0: eth1: rx slot 21 status 0x32036066 len =
98
[28498.059961] 8139cp 0000:00:0b.0: eth1: rx slot 22 status 0x32036066 len =
98
[28498.060011] 8139cp 0000:00:0b.0: eth1: rx slot 23 status 0x32036066 len =
98
[28498.060059] 8139cp 0000:00:0b.0: eth1: rx slot 24 status 0x32036066 len =
98
[28498.060108] 8139cp 0000:00:0b.0: eth1: rx slot 25 status 0x32036066 len =
98
[28498.060156] 8139cp 0000:00:0b.0: eth1: rx slot 26 status 0x32036066 len =
98
[28498.060205] 8139cp 0000:00:0b.0: eth1: rx slot 27 status 0x32036066 len =
98
[28498.060253] 8139cp 0000:00:0b.0: eth1: rx slot 28 status 0x32036066 len =
98
[28498.060302] 8139cp 0000:00:0b.0: eth1: rx slot 29 status 0x32036066 len =
98
[28498.060350] 8139cp 0000:00:0b.0: eth1: rx slot 30 status 0x32036066 len =
98
[28498.060399] 8139cp 0000:00:0b.0: eth1: rx slot 31 status 0x32036066 len =
98
[28498.060447] 8139cp 0000:00:0b.0: eth1: rx slot 32 status 0x32036066 len =
98
[28498.060496] 8139cp 0000:00:0b.0: eth1: rx slot 33 status 0x32036066 len =
98
[28498.060544] 8139cp 0000:00:0b.0: eth1: rx slot 34 status 0x32036066 len =
98
[28498.060594] 8139cp 0000:00:0b.0: eth1: rx slot 35 status 0x32036066 len =
98
[28498.060642] 8139cp 0000:00:0b.0: eth1: rx slot 36 status 0x32036066 len =
98
[28498.060691] 8139cp 0000:00:0b.0: eth1: rx slot 37 status 0x32036066 len =
98
[28498.060740] 8139cp 0000:00:0b.0: eth1: rx slot 38 status 0x32036066 len =
98
[28498.060789] 8139cp 0000:00:0b.0: eth1: rx slot 39 status 0x32036066 len =
98
[28498.060901] 8139cp 0000:00:0b.0: eth1: tx queued, slot 12, skblen 98
[28498.060936] 8139cp 0000:00:0b.0: eth1: intr, status 0080 cmd 0c cpcmd 00=
2b
[28498.061814] 8139cp 0000:00:0b.0: eth1: tx queued, slot 13, skblen 98
[28498.064007] 8139cp 0000:00:0b.0: eth1: tx queued, slot 14, skblen 98
[28498.065750] 8139cp 0000:00:0b.0: eth1: tx queued, slot 15, skblen 98
[28498.067472] 8139cp 0000:00:0b.0: eth1: tx queued, slot 16, skblen 98
[28498.068062] 8139cp 0000:00:0b.0: eth1: tx queued, slot 17, skblen 79
[28498.068221] 8139cp 0000:00:0b.0: eth1: tx queued, slot 18, skblen 74
[28498.070711] 8139cp 0000:00:0b.0: eth1: tx queued, slot 19, skblen 98
[28498.072137] 8139cp 0000:00:0b.0: eth1: tx queued, slot 20, skblen 98
[28498.074369] 8139cp 0000:00:0b.0: eth1: tx queued, slot 21, skblen 98
[28498.075829] 8139cp 0000:00:0b.0: eth1: tx queued, slot 22, skblen 98
[28498.078074] 8139cp 0000:00:0b.0: eth1: tx queued, slot 23, skblen 98
[28498.079772] 8139cp 0000:00:0b.0: eth1: tx queued, slot 24, skblen 98
[28498.082254] 8139cp 0000:00:0b.0: eth1: tx queued, slot 25, skblen 98
[28498.120915] 8139cp 0000:00:0b.0: eth1: intr, status 0001 cmd 0c cpcmd 00=
2b
[28498.120946] 8139cp 0000:00:0b.0: eth1: rx slot 40 status 0x3201404e len =
74
[28498.140144] 8139cp 0000:00:0b.0: eth1: tx queued, slot 26, skblen 74
[28498.182530] 8139cp 0000:00:0b.0: eth1: tx queued, slot 27, skblen 66
[28498.276742] 8139cp 0000:00:0b.0: eth1: tx queued, slot 28, skblen 79
[28498.421426] 8139cp 0000:00:0b.0: eth1: intr, status 0001 cmd 0c cpcmd 00=
2b
[28498.421454] 8139cp 0000:00:0b.0: eth1: rx slot 41 status 0x320141d8 len =
468
[28498.485291] 8139cp 0000:00:0b.0: eth1: tx queued, slot 29, skblen 74
[28498.578432] 8139cp 0000:00:0b.0: eth1: tx queued, slot 30, skblen 66
[28498.646429] 8139cp 0000:00:0b.0: eth1: tx queued, slot 31, skblen 118
[28498.649979] 8139cp 0000:00:0b.0: eth1: intr, status 0001 cmd 0c cpcmd 00=
2b
[28498.650008] 8139cp 0000:00:0b.0: eth1: rx slot 42 status 0x32036094 len =
144
[28498.650098] 8139cp 0000:00:0b.0: eth1: rx slot 43 status 0x32036096 len =
146
[28498.650165] 8139cp 0000:00:0b.0: eth1: rx slot 44 status 0x32036094 len =
144
[28498.696744] 8139cp 0000:00:0b.0: eth1: tx queued, slot 32, skblen 79
[28498.804309] 8139cp 0000:00:0b.0: eth1: intr, status 0001 cmd 0c cpcmd 00=
2b
[28498.804338] 8139cp 0000:00:0b.0: eth1: rx slot 45 status 0x320140a0 len =
156
[28498.885404] 8139cp 0000:00:0b.0: eth1: tx queued, slot 33, skblen 125
[28499.086435] 8139cp 0000:00:0b.0: eth1: tx queued, slot 34, skblen 74
[28499.098211] 8139cp 0000:00:0b.0: eth1: intr, status 0001 cmd 0c cpcmd 00=
2b
[28499.098239] 8139cp 0000:00:0b.0: eth1: rx slot 46 status 0x32014046 len =
66
[28499.108839] 8139cp 0000:00:0b.0: eth1: tx queued, slot 35, skblen 66
[28499.121567] 8139cp 0000:00:0b.0: eth1: intr, status 0001 cmd 0c cpcmd 00=
2b
[28499.121596] 8139cp 0000:00:0b.0: eth1: rx slot 47 status 0x3201404e len =
74
[28499.121992] 8139cp 0000:00:0b.0: eth1: intr, status 0001 cmd 0c cpcmd 00=
2b
[28499.122018] 8139cp 0000:00:0b.0: eth1: rx slot 48 status 0x3200e0a0 len =
156
[28499.139903] 8139cp 0000:00:0b.0: eth1: tx queued, slot 36, skblen 74
[28499.401749] 8139cp 0000:00:0b.0: eth1: intr, status 0001 cmd 0c cpcmd 00=
2b
[28499.401777] 8139cp 0000:00:0b.0: eth1: rx slot 49 status 0x320141d8 len =
468
[28499.558938] 8139cp 0000:00:0b.0: eth1: tx queued, slot 37, skblen 66
[28499.775920] 8139cp 0000:00:0b.0: eth1: intr, status 0001 cmd 0c cpcmd 00=
2b
[28499.775948] 8139cp 0000:00:0b.0: eth1: rx slot 50 status 0x3203605e len =
90
[28499.888841] 8139cp 0000:00:0b.0: eth1: tx queued, slot 38, skblen 116
[28500.286470] 8139cp 0000:00:0b.0: eth1: tx queued, slot 39, skblen 74
[28500.353205] 8139cp 0000:00:0b.0: eth1: tx queued, slot 40, skblen 66
[28501.125519] 8139cp 0000:00:0b.0: eth1: intr, status 0001 cmd 0c cpcmd 00=
2b
[28501.125553] 8139cp 0000:00:0b.0: eth1: rx slot 51 status 0x3201404e len =
74
[28501.143803] 8139cp 0000:00:0b.0: eth1: tx queued, slot 41, skblen 74
[28501.373644] 8139cp 0000:00:0b.0: eth1: intr, status 0001 cmd 0c cpcmd 00=
2b
[28501.373673] 8139cp 0000:00:0b.0: eth1: rx slot 52 status 0x320141d8 len =
468
[28501.530366] 8139cp 0000:00:0b.0: eth1: tx queued, slot 42, skblen 66
[28501.648615] 8139cp 0000:00:0b.0: eth1: tx queued, slot 43, skblen 112
[28501.888561] 8139cp 0000:00:0b.0: eth1: tx queued, slot 44, skblen 121
[28502.094862] 8139cp 0000:00:0b.0: eth1: intr, status 0001 cmd 0c cpcmd 00=
2b
[28502.094891] 8139cp 0000:00:0b.0: eth1: rx slot 53 status 0x32014046 len =
66
[28502.105856] 8139cp 0000:00:0b.0: eth1: tx queued, slot 45, skblen 66
[28502.113535] 8139cp 0000:00:0b.0: eth1: tx queued, slot 46, skblen 94
[28502.221163] 8139cp 0000:00:0b.0: eth1: tx queued, slot 47, skblen 58
[28502.507301] SysRq : Changing Loglevel
[28502.511000] Loglevel set to 9
[28502.690951] 8139cp 0000:00:0b.0: eth1: tx queued, slot 48, skblen 74
[28502.725709] 8139cp 0000:00:0b.0: eth1: tx queued, slot 49, skblen 62
[28502.891993] 8139cp 0000:00:0b.0: eth1: tx queued, slot 50, skblen 116
[28502.997597] 8139cp 0000:00:0b.0: eth1: tx queued, slot 51, skblen 102
[28504.652076] 8139cp 0000:00:0b.0: eth1: tx queued, slot 52, skblen 118
[28504.886623] 8139cp 0000:00:0b.0: eth1: tx queued, slot 53, skblen 147
[28504.894552] 8139cp 0000:00:0b.0: eth1: tx queued, slot 54, skblen 123
[28505.133020] 8139cp 0000:00:0b.0: eth1: intr, status 0001 cmd 0c cpcmd 00=
2b
[28505.140825] 8139cp 0000:00:0b.0: eth1: rx slot 54 status 0x3201404e len =
74
[28505.149255] 8139cp 0000:00:0b.0: eth1: tx queued, slot 55, skblen 147
[28505.167408] 8139cp 0000:00:0b.0: eth1: tx queued, slot 56, skblen 74
[28505.317183] 8139cp 0000:00:0b.0: eth1: intr, status 0001 cmd 0c cpcmd 00=
2b
[28505.325489] 8139cp 0000:00:0b.0: eth1: rx slot 55 status 0x320141d8 len =
468
[28508.094647] 8139cp 0000:00:0b.0: eth1: intr, status 0001 cmd 0c cpcmd 00=
2b
[28508.101681] 8139cp 0000:00:0b.0: eth1: rx slot 56 status 0x32014046 len =
66
[28508.913790] 8139cp 0000:00:0b.0: eth1: intr, status 0001 cmd 0c cpcmd 00=
2b
[28508.921135] 8139cp 0000:00:0b.0: eth1: rx slot 57 status 0x32022040 len =
60
[28510.009002] 8139cp 0000:00:0b.0: eth1: intr, status 0001 cmd 0c cpcmd 00=
2b
[28510.016533] 8139cp 0000:00:0b.0: eth1: rx slot 58 status 0x3201406b len =
103
[28510.239735] 8139cp 0000:00:0b.0: eth1: intr, status 0001 cmd 0c cpcmd 00=
2b
[28510.246717] 8139cp 0000:00:0b.0: eth1: rx slot 59 status 0x3201406b len =
103
[28510.702856] 8139cp 0000:00:0b.0: eth1: intr, status 0001 cmd 0c cpcmd 00=
2b
[28510.709886] 8139cp 0000:00:0b.0: eth1: rx slot 60 status 0x3201406b len =
103
[28511.098502] 8139cp 0000:00:0b.0: eth1: intr, status 0001 cmd 0c cpcmd 00=
2b
[28511.105396] 8139cp 0000:00:0b.0: eth1: rx slot 61 status 0x3202205d len =
89
[28511.629295] 8139cp 0000:00:0b.0: eth1: intr, status 0001 cmd 0c cpcmd 00=
2b
[28511.636190] 8139cp 0000:00:0b.0: eth1: rx slot 62 status 0x3201406b len =
103
[28511.898925] 8139cp 0000:00:0b.0: eth1: intr, status 0001 cmd 0c cpcmd 00=
2b
[28511.905833] 8139cp 0000:00:0b.0: eth1: rx slot 63 status 0x7202205d len =
89
[28512.011147] 8139cp 0000:00:0b.0: eth1: intr, status 0001 cmd 0c cpcmd 00=
2b
[28512.018063] 8139cp 0000:00:0b.0: eth1: rx slot 0 status 0x3202206b len 1=
03
[28513.017313] 8139cp 0000:00:0b.0: eth1: Transmit timeout, status  c   2b =
   0 80ff
[28513.025121] 8139cp 0000:00:0b.0: eth1: tx queued, slot 1, skblen 66
[28513.031420] 8139cp 0000:00:0b.0: eth1: tx queued, slot 2, skblen 111
[28513.037801] 8139cp 0000:00:0b.0: eth1: tx queued, slot 3, skblen 116
[28513.044164] 8139cp 0000:00:0b.0: eth1: tx queued, slot 4, skblen 109
[28513.050549] 8139cp 0000:00:0b.0: eth1: tx queued, slot 5, skblen 118
[28513.056912] 8139cp 0000:00:0b.0: eth1: tx queued, slot 6, skblen 111
[28513.063300] 8139cp 0000:00:0b.0: eth1: tx queued, slot 7, skblen 114
[28513.069685] 8139cp 0000:00:0b.0: eth1: tx queued, slot 8, skblen 125
[28513.076049] 8139cp 0000:00:0b.0: eth1: tx queued, slot 9, skblen 147
[28513.082426] 8139cp 0000:00:0b.0: eth1: tx queued, slot 10, skblen 66
[28513.088804] 8139cp 0000:00:0b.0: eth1: tx queued, slot 11, skblen 147
[28513.095254] 8139cp 0000:00:0b.0: eth1: tx queued, slot 12, skblen 74
[28513.101631] 8139cp 0000:00:0b.0: eth1: tx queued, slot 13, skblen 66
[28513.108009] 8139cp 0000:00:0b.0: eth1: tx queued, slot 14, skblen 147
[28513.114461] 8139cp 0000:00:0b.0: eth1: tx queued, slot 15, skblen 66
[28513.120846] 8139cp 0000:00:0b.0: eth1: tx queued, slot 16, skblen 66
[28513.127210] 8139cp 0000:00:0b.0: eth1: tx queued, slot 17, skblen 94
[28513.133595] 8139cp 0000:00:0b.0: eth1: tx queued, slot 18, skblen 66
[28513.139973] 8139cp 0000:00:0b.0: eth1: tx queued, slot 19, skblen 108
[28513.146425] 8139cp 0000:00:0b.0: eth1: tx queued, slot 20, skblen 110
[28513.152897] 8139cp 0000:00:0b.0: eth1: tx queued, slot 21, skblen 62
[28513.159273] 8139cp 0000:00:0b.0: eth1: tx queued, slot 22, skblen 66
[28513.165639] 8139cp 0000:00:0b.0: eth1: tx queued, slot 23, skblen 110
[28513.172111] 8139cp 0000:00:0b.0: eth1: tx queued, slot 24, skblen 147
[28513.178575] 8139cp 0000:00:0b.0: eth1: tx queued, slot 25, skblen 135
[28513.185027] 8139cp 0000:00:0b.0: eth1: tx queued, slot 26, skblen 70
[28513.191411] 8139cp 0000:00:0b.0: eth1: tx queued, slot 27, skblen 70
[28513.661282] 8139cp 0000:00:0b.0: eth1: tx queued, slot 28, skblen 110
[28513.902182] 8139cp 0000:00:0b.0: eth1: tx queued, slot 29, skblen 114
[28514.152998] 8139cp 0000:00:0b.0: eth1: tx queued, slot 30, skblen 62
[28514.904881] 8139cp 0000:00:0b.0: eth1: tx queued, slot 31, skblen 109
[28515.996046] 8139cp 0000:00:0b.0: eth1: tx queued, slot 32, skblen 70
[28516.664680] 8139cp 0000:00:0b.0: eth1: tx queued, slot 33, skblen 125
[28516.904608] 8139cp 0000:00:0b.0: eth1: tx queued, slot 34, skblen 126
[28517.916878] 8139cp 0000:00:0b.0: eth1: tx queued, slot 35, skblen 115
[28518.352300] 8139cp 0000:00:0b.0: eth1: tx queued, slot 36, skblen 66
[28519.028318] 8139cp 0000:00:0b.0: eth1: tx queued, slot 37, skblen 102
[28519.339446] 8139cp 0000:00:0b.0: eth1: tx queued, slot 38, skblen 141
[28519.668103] 8139cp 0000:00:0b.0: eth1: tx queued, slot 39, skblen 112
[28519.756759] 8139cp 0000:00:0b.0: eth1: tx queued, slot 40, skblen 141
[28519.907770] 8139cp 0000:00:0b.0: eth1: tx queued, slot 41, skblen 109
[28520.188635] 8139cp 0000:00:0b.0: eth1: tx queued, slot 42, skblen 62
[28520.596861] 8139cp 0000:00:0b.0: eth1: tx queued, slot 43, skblen 141
[28520.635544] 8139cp 0000:00:0b.0: eth1: tx queued, slot 44, skblen 147
[28520.911469] 8139cp 0000:00:0b.0: eth1: tx queued, slot 45, skblen 125
[28531.018105] 8139cp 0000:00:0b.0: eth1: Transmit timeout, status  c   2b =
 485    0
[28531.025915] 8139cp 0000:00:0b.0: eth1: tx queued, slot 1, skblen 141
[28531.032305] 8139cp 0000:00:0b.0: eth1: tx queued, slot 2, skblen 117
[28531.038685] 8139cp 0000:00:0b.0: eth1: tx queued, slot 3, skblen 115
[28531.045049] 8139cp 0000:00:0b.0: eth1: tx queued, slot 4, skblen 117
[28531.051433] 8139cp 0000:00:0b.0: eth1: tx queued, slot 5, skblen 126
[28531.057797] 8139cp 0000:00:0b.0: eth1: tx queued, slot 6, skblen 112
[28531.064184] 8139cp 0000:00:0b.0: eth1: tx queued, slot 7, skblen 121
[28531.070559] 8139cp 0000:00:0b.0: eth1: tx queued, slot 8, skblen 118
[28531.076925] 8139cp 0000:00:0b.0: eth1: tx queued, slot 9, skblen 118
[28531.083310] 8139cp 0000:00:0b.0: eth1: tx queued, slot 10, skblen 115
[28531.089779] 8139cp 0000:00:0b.0: eth1: tx queued, slot 11, skblen 79
[28531.096148] 8139cp 0000:00:0b.0: eth1: tx queued, slot 12, skblen 141
[28531.102613] 8139cp 0000:00:0b.0: eth1: tx queued, slot 13, skblen 94
[28531.108990] 8139cp 0000:00:0b.0: eth1: tx queued, slot 14, skblen 42
[28531.115354] 8139cp 0000:00:0b.0: eth1: tx queued, slot 15, skblen 42
[28531.121738] 8139cp 0000:00:0b.0: eth1: tx queued, slot 16, skblen 42
[28531.128116] 8139cp 0000:00:0b.0: eth1: tx queued, slot 17, skblen 42
[28531.858156] 8139cp 0000:00:0b.0: eth1: tx queued, slot 18, skblen 42
[28532.256232] 8139cp 0000:00:0b.0: eth1: tx queued, slot 19, skblen 141
[28532.858193] 8139cp 0000:00:0b.0: eth1: tx queued, slot 20, skblen 42
[28533.862354] 8139cp 0000:00:0b.0: eth1: tx queued, slot 21, skblen 42
[28534.858290] 8139cp 0000:00:0b.0: eth1: tx queued, slot 22, skblen 42
[28535.858336] 8139cp 0000:00:0b.0: eth1: tx queued, slot 23, skblen 42
[28536.634367] 8139cp 0000:00:0b.0: eth1: tx queued, slot 24, skblen 147
[28537.684826] 8139cp 0000:00:0b.0: eth1: tx queued, slot 25, skblen 42
[28538.678444] 8139cp 0000:00:0b.0: eth1: tx queued, slot 26, skblen 42
[28539.678487] 8139cp 0000:00:0b.0: eth1: tx queued, slot 27, skblen 42
[28540.688218] 8139cp 0000:00:0b.0: eth1: tx queued, slot 28, skblen 42
[28541.678581] 8139cp 0000:00:0b.0: eth1: tx queued, slot 29, skblen 42
[28542.678622] 8139cp 0000:00:0b.0: eth1: tx queued, slot 30, skblen 42
[28543.690661] 8139cp 0000:00:0b.0: eth1: tx queued, slot 31, skblen 42
[28544.688708] 8139cp 0000:00:0b.0: eth1: tx queued, slot 32, skblen 42
[28545.575351] 8139cp 0000:00:0b.0: eth1: tx queued, slot 33, skblen 141
[28545.688766] 8139cp 0000:00:0b.0: eth1: tx queued, slot 34, skblen 42
[28546.694068] 8139cp 0000:00:0b.0: eth1: tx queued, slot 35, skblen 42
[28547.688840] 8139cp 0000:00:0b.0: eth1: tx queued, slot 36, skblen 42
[28548.688882] 8139cp 0000:00:0b.0: eth1: tx queued, slot 37, skblen 42
[28549.697713] 8139cp 0000:00:0b.0: eth1: tx queued, slot 38, skblen 42
[28550.579007] 8139cp 0000:00:0b.0: eth1: tx queued, slot 39, skblen 86
[28550.688971] 8139cp 0000:00:0b.0: eth1: tx queued, slot 40, skblen 42
[28550.811035] SysRq : Changing Loglevel
[28550.814730] Loglevel set to 1
[28551.579045] 8139cp 0000:00:0b.0: eth1: tx queued, slot 41, skblen 86
[28551.689016] 8139cp 0000:00:0b.0: eth1: tx queued, slot 42, skblen 42
[28551.719077] 8139cp 0000:00:0b.0: eth1: tx queued, slot 43, skblen 79
[28552.579071] 8139cp 0000:00:0b.0: eth1: tx queued, slot 44, skblen 86
[28552.701599] 8139cp 0000:00:0b.0: eth1: tx queued, slot 45, skblen 42
[28555.116322] 8139cp 0000:00:0b.0: eth1: disabling interface
[28555.116663] br-lan: port 2(eth1) entered disabled state
[28555.120239] device eth1 left promiscuous mode




--=-PJSahic33nsb7ROUoUBQ
Content-Type: application/x-pkcs7-signature; name="smime.p7s"
Content-Disposition: attachment; filename="smime.p7s"
Content-Transfer-Encoding: base64

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIIUbjCCBjQw
ggQcoAMCAQICAR4wDQYJKoZIhvcNAQEFBQAwfTELMAkGA1UEBhMCSUwxFjAUBgNVBAoTDVN0YXJ0
Q29tIEx0ZC4xKzApBgNVBAsTIlNlY3VyZSBEaWdpdGFsIENlcnRpZmljYXRlIFNpZ25pbmcxKTAn
BgNVBAMTIFN0YXJ0Q29tIENlcnRpZmljYXRpb24gQXV0aG9yaXR5MB4XDTA3MTAyNDIxMDE1NVoX
DTE3MTAyNDIxMDE1NVowgYwxCzAJBgNVBAYTAklMMRYwFAYDVQQKEw1TdGFydENvbSBMdGQuMSsw
KQYDVQQLEyJTZWN1cmUgRGlnaXRhbCBDZXJ0aWZpY2F0ZSBTaWduaW5nMTgwNgYDVQQDEy9TdGFy
dENvbSBDbGFzcyAxIFByaW1hcnkgSW50ZXJtZWRpYXRlIENsaWVudCBDQTCCASIwDQYJKoZIhvcN
AQEBBQADggEPADCCAQoCggEBAMcJg8zOLdgasSmkLhOrlr6KMoOMpohBllVHrdRvEg/q6r8jR+EK
75xCGhR8ToREoqe7zM9/UnC6TS2y9UKTpT1v7RSMzR0t6ndl0TWBuUr/UXBhPk+Kmy7bI4yW4urC
+y7P3/1/X7U8ocb8VpH/Clt+4iq7nirMcNh6qJR+xjOhV+VHzQMALuGYn5KZmc1NbJQYclsGkDxD
z2UbFqE2+6vIZoL+jb9x4Pa5gNf1TwSDkOkikZB1xtB4ZqtXThaABSONdfmv/Z1pua3FYxnCFmdr
/+N2JLKutIxMYqQOJebr/f/h5t95m4JgrM3Y/w7YX9d7YAL9jvN4SydHsU6n65cCAwEAAaOCAa0w
ggGpMA8GA1UdEwEB/wQFMAMBAf8wDgYDVR0PAQH/BAQDAgEGMB0GA1UdDgQWBBRTcu2SnODaywFc
fH6WNU7y1LhRgjAfBgNVHSMEGDAWgBROC+8apEBbpRdphzDKNGhD0EGu8jBmBggrBgEFBQcBAQRa
MFgwJwYIKwYBBQUHMAGGG2h0dHA6Ly9vY3NwLnN0YXJ0c3NsLmNvbS9jYTAtBggrBgEFBQcwAoYh
aHR0cDovL3d3dy5zdGFydHNzbC5jb20vc2ZzY2EuY3J0MFsGA1UdHwRUMFIwJ6AloCOGIWh0dHA6
Ly93d3cuc3RhcnRzc2wuY29tL3Nmc2NhLmNybDAnoCWgI4YhaHR0cDovL2NybC5zdGFydHNzbC5j
b20vc2ZzY2EuY3JsMIGABgNVHSAEeTB3MHUGCysGAQQBgbU3AQIBMGYwLgYIKwYBBQUHAgEWImh0
dHA6Ly93d3cuc3RhcnRzc2wuY29tL3BvbGljeS5wZGYwNAYIKwYBBQUHAgEWKGh0dHA6Ly93d3cu
c3RhcnRzc2wuY29tL2ludGVybWVkaWF0ZS5wZGYwDQYJKoZIhvcNAQEFBQADggIBAAqDCH14qywG
XLhjjF6uHLkjd02hcdh9hrw+VUsv+q1eeQWB21jWj3kJ96AUlPCoEGZ/ynJNScWy6QMVQjbbMXlt
UfO4n4bGGdKo3awPWp61tjAFgraLJgDk+DsSvUD6EowjMTNx25GQgyYJ5RPIzKKR9tQW8gGK+2+R
HxkUCTbYFnL6kl8Ch507rUdPPipJ9CgJFws3kDS3gOS5WFMxcjO5DwKfKSETEPrHh7p5shuuNktv
sv6hxHTLhiMKX893gxdT3XLS9OKmCv87vkINQcNEcIIoFWbP9HORz9v3vQwR4e3ksLc2JZOAFK+s
sS5XMEoznzpihEP0PLc4dCBYjbvSD7kxgDwZ+Aj8Q9PkbvE9sIPP7ON0fz095HdThKjiVJe6vofq
+n6b1NBc8XdrQvBmunwxD5nvtTW4vtN6VY7mUCmxsCieuoBJ9OlqmsVWQvifIYf40dJPZkk9YgGT
zWLpXDSfLSplbY2LL9C9U0ptvjcDjefLTvqSFc7tw1sEhF0n/qpA2r0GpvkLRDmcSwVyPvmjFBGq
Up/pNy8ZuPGQmHwFi2/14+xeSUDG2bwnsYJQG2EdJCB6luQ57GEnTA/yKZSTKI8dDQa8Sd3zfXb1
9mOgSF0bBdXbuKhEpuP9wirslFe6fQ1t5j5R0xi72MZ8ikMu1RQZKCyDbMwazlHiMIIHFzCCBf+g
AwIBAgIDBCZ6MA0GCSqGSIb3DQEBBQUAMIGMMQswCQYDVQQGEwJJTDEWMBQGA1UEChMNU3RhcnRD
b20gTHRkLjErMCkGA1UECxMiU2VjdXJlIERpZ2l0YWwgQ2VydGlmaWNhdGUgU2lnbmluZzE4MDYG
A1UEAxMvU3RhcnRDb20gQ2xhc3MgMSBQcmltYXJ5IEludGVybWVkaWF0ZSBDbGllbnQgQ0EwHhcN
MTIwNTAxMTI1ODI3WhcNMTMwNTAzMTEzNzIwWjBdMRkwFwYDVQQNExA4Y1VOSzUzMTc0ODRYRjk3
MRwwGgYDVQQDDBNkd213MkBpbmZyYWRlYWQub3JnMSIwIAYJKoZIhvcNAQkBFhNkd213MkBpbmZy
YWRlYWQub3JnMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAyYe7wo6MrtrB4uIGGbrY
4IifY/Xsq22pSv605yganL0+uyUdd8rCjrYlH6Q/ra5TVJCQFTgzaepkuqPQc79DC/Cxmzm6Qo+s
wLZy868oFsccsVokL2bPAWIPaRXfNPJKkYR1FTWQfZpWJVQmT+sPf1XFUullVBAK+d9RztopyacI
xWoZ/W/Cmv7mseQbttYTtGKJa0btX73nsQRWl6SgErWXo59zg9friCLTy1GXMXJYB8H+PtnuwX0w
MrAvWDdX1ABgIlA17W3FraCn0eW15ZM46eyu0/amGzJZNtemCWF73P7BAijzeV1jNmiJFXdZ0DT0
w+hmtMO9PxdDUyt78QIDAQABo4IDrjCCA6owCQYDVR0TBAIwADALBgNVHQ8EBAMCBLAwHQYDVR0l
BBYwFAYIKwYBBQUHAwIGCCsGAQUFBwMEMB0GA1UdDgQWBBTkfe5UOr3PcirsjApibyyUEfsyRzAf
BgNVHSMEGDAWgBRTcu2SnODaywFcfH6WNU7y1LhRgjAeBgNVHREEFzAVgRNkd213MkBpbmZyYWRl
YWQub3JnMIICIQYDVR0gBIICGDCCAhQwggIQBgsrBgEEAYG1NwECAjCCAf8wLgYIKwYBBQUHAgEW
Imh0dHA6Ly93d3cuc3RhcnRzc2wuY29tL3BvbGljeS5wZGYwNAYIKwYBBQUHAgEWKGh0dHA6Ly93
d3cuc3RhcnRzc2wuY29tL2ludGVybWVkaWF0ZS5wZGYwgfcGCCsGAQUFBwICMIHqMCcWIFN0YXJ0
Q29tIENlcnRpZmljYXRpb24gQXV0aG9yaXR5MAMCAQEagb5UaGlzIGNlcnRpZmljYXRlIHdhcyBp
c3N1ZWQgYWNjb3JkaW5nIHRvIHRoZSBDbGFzcyAxIFZhbGlkYXRpb24gcmVxdWlyZW1lbnRzIG9m
IHRoZSBTdGFydENvbSBDQSBwb2xpY3ksIHJlbGlhbmNlIG9ubHkgZm9yIHRoZSBpbnRlbmRlZCBw
dXJwb3NlIGluIGNvbXBsaWFuY2Ugb2YgdGhlIHJlbHlpbmcgcGFydHkgb2JsaWdhdGlvbnMuMIGc
BggrBgEFBQcCAjCBjzAnFiBTdGFydENvbSBDZXJ0aWZpY2F0aW9uIEF1dGhvcml0eTADAgECGmRM
aWFiaWxpdHkgYW5kIHdhcnJhbnRpZXMgYXJlIGxpbWl0ZWQhIFNlZSBzZWN0aW9uICJMZWdhbCBh
bmQgTGltaXRhdGlvbnMiIG9mIHRoZSBTdGFydENvbSBDQSBwb2xpY3kuMDYGA1UdHwQvMC0wK6Ap
oCeGJWh0dHA6Ly9jcmwuc3RhcnRzc2wuY29tL2NydHUxLWNybC5jcmwwgY4GCCsGAQUFBwEBBIGB
MH8wOQYIKwYBBQUHMAGGLWh0dHA6Ly9vY3NwLnN0YXJ0c3NsLmNvbS9zdWIvY2xhc3MxL2NsaWVu
dC9jYTBCBggrBgEFBQcwAoY2aHR0cDovL2FpYS5zdGFydHNzbC5jb20vY2VydHMvc3ViLmNsYXNz
MS5jbGllbnQuY2EuY3J0MCMGA1UdEgQcMBqGGGh0dHA6Ly93d3cuc3RhcnRzc2wuY29tLzANBgkq
hkiG9w0BAQUFAAOCAQEAqDU1FKifNtCFJbLnvOi1BLRfk7mut55PMtPSZLJ4/AnG7AjmJnbBI4U5
DELwvVq3mIpwUpGqZUkqkZMEfBPIbfq517UZB3h4iANtqif+ULfTLhg5XgcK5eF8/T6EtX2c3epq
ylARdleCbj/0FwiUDvPlTsA6PIN4SCekjRLgjKERrL3heFz+Hteq1rtMAvMkNuyL0/0ijyyg2y45
NASAl2Afl9SLes/fnoh9nBwzfNQfb6qDYUFpnglfpGrq/0b1NtaOUb2z1SR+H1tKlb8bVJJIdvpu
mEi27kSRIhzk3h30uTfKkKetgy++ouyldxZ7KZ0PuoLQrBy465EoQLosETCCBxcwggX/oAMCAQIC
AwQmejANBgkqhkiG9w0BAQUFADCBjDELMAkGA1UEBhMCSUwxFjAUBgNVBAoTDVN0YXJ0Q29tIEx0
ZC4xKzApBgNVBAsTIlNlY3VyZSBEaWdpdGFsIENlcnRpZmljYXRlIFNpZ25pbmcxODA2BgNVBAMT
L1N0YXJ0Q29tIENsYXNzIDEgUHJpbWFyeSBJbnRlcm1lZGlhdGUgQ2xpZW50IENBMB4XDTEyMDUw
MTEyNTgyN1oXDTEzMDUwMzExMzcyMFowXTEZMBcGA1UEDRMQOGNVTks1MzE3NDg0WEY5NzEcMBoG
A1UEAwwTZHdtdzJAaW5mcmFkZWFkLm9yZzEiMCAGCSqGSIb3DQEJARYTZHdtdzJAaW5mcmFkZWFk
Lm9yZzCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAMmHu8KOjK7aweLiBhm62OCIn2P1
7KttqUr+tOcoGpy9PrslHXfKwo62JR+kP62uU1SQkBU4M2nqZLqj0HO/QwvwsZs5ukKPrMC2cvOv
KBbHHLFaJC9mzwFiD2kV3zTySpGEdRU1kH2aViVUJk/rD39VxVLpZVQQCvnfUc7aKcmnCMVqGf1v
wpr+5rHkG7bWE7RiiWtG7V+957EEVpekoBK1l6Ofc4PX64gi08tRlzFyWAfB/j7Z7sF9MDKwL1g3
V9QAYCJQNe1txa2gp9HlteWTOOnsrtP2phsyWTbXpglhe9z+wQIo83ldYzZoiRV3WdA09MPoZrTD
vT8XQ1Mre/ECAwEAAaOCA64wggOqMAkGA1UdEwQCMAAwCwYDVR0PBAQDAgSwMB0GA1UdJQQWMBQG
CCsGAQUFBwMCBggrBgEFBQcDBDAdBgNVHQ4EFgQU5H3uVDq9z3Iq7IwKYm8slBH7MkcwHwYDVR0j
BBgwFoAUU3Ltkpzg2ssBXHx+ljVO8tS4UYIwHgYDVR0RBBcwFYETZHdtdzJAaW5mcmFkZWFkLm9y
ZzCCAiEGA1UdIASCAhgwggIUMIICEAYLKwYBBAGBtTcBAgIwggH/MC4GCCsGAQUFBwIBFiJodHRw
Oi8vd3d3LnN0YXJ0c3NsLmNvbS9wb2xpY3kucGRmMDQGCCsGAQUFBwIBFihodHRwOi8vd3d3LnN0
YXJ0c3NsLmNvbS9pbnRlcm1lZGlhdGUucGRmMIH3BggrBgEFBQcCAjCB6jAnFiBTdGFydENvbSBD
ZXJ0aWZpY2F0aW9uIEF1dGhvcml0eTADAgEBGoG+VGhpcyBjZXJ0aWZpY2F0ZSB3YXMgaXNzdWVk
IGFjY29yZGluZyB0byB0aGUgQ2xhc3MgMSBWYWxpZGF0aW9uIHJlcXVpcmVtZW50cyBvZiB0aGUg
U3RhcnRDb20gQ0EgcG9saWN5LCByZWxpYW5jZSBvbmx5IGZvciB0aGUgaW50ZW5kZWQgcHVycG9z
ZSBpbiBjb21wbGlhbmNlIG9mIHRoZSByZWx5aW5nIHBhcnR5IG9ibGlnYXRpb25zLjCBnAYIKwYB
BQUHAgIwgY8wJxYgU3RhcnRDb20gQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkwAwIBAhpkTGlhYmls
aXR5IGFuZCB3YXJyYW50aWVzIGFyZSBsaW1pdGVkISBTZWUgc2VjdGlvbiAiTGVnYWwgYW5kIExp
bWl0YXRpb25zIiBvZiB0aGUgU3RhcnRDb20gQ0EgcG9saWN5LjA2BgNVHR8ELzAtMCugKaAnhiVo
dHRwOi8vY3JsLnN0YXJ0c3NsLmNvbS9jcnR1MS1jcmwuY3JsMIGOBggrBgEFBQcBAQSBgTB/MDkG
CCsGAQUFBzABhi1odHRwOi8vb2NzcC5zdGFydHNzbC5jb20vc3ViL2NsYXNzMS9jbGllbnQvY2Ew
QgYIKwYBBQUHMAKGNmh0dHA6Ly9haWEuc3RhcnRzc2wuY29tL2NlcnRzL3N1Yi5jbGFzczEuY2xp
ZW50LmNhLmNydDAjBgNVHRIEHDAahhhodHRwOi8vd3d3LnN0YXJ0c3NsLmNvbS8wDQYJKoZIhvcN
AQEFBQADggEBAKg1NRSonzbQhSWy57zotQS0X5O5rreeTzLT0mSyePwJxuwI5iZ2wSOFOQxC8L1a
t5iKcFKRqmVJKpGTBHwTyG36ude1GQd4eIgDbaon/lC30y4YOV4HCuXhfP0+hLV9nN3qaspQEXZX
gm4/9BcIlA7z5U7AOjyDeEgnpI0S4IyhEay94Xhc/h7Xqta7TALzJDbsi9P9Io8soNsuOTQEgJdg
H5fUi3rP356IfZwcM3zUH2+qg2FBaZ4JX6Rq6v9G9TbWjlG9s9Ukfh9bSpW/G1SSSHb6bphItu5E
kSIc5N4d9Lk3ypCnrYMvvqLspXcWeymdD7qC0KwcuOuRKEC6LBExggNvMIIDawIBATCBlDCBjDEL
MAkGA1UEBhMCSUwxFjAUBgNVBAoTDVN0YXJ0Q29tIEx0ZC4xKzApBgNVBAsTIlNlY3VyZSBEaWdp
dGFsIENlcnRpZmljYXRlIFNpZ25pbmcxODA2BgNVBAMTL1N0YXJ0Q29tIENsYXNzIDEgUHJpbWFy
eSBJbnRlcm1lZGlhdGUgQ2xpZW50IENBAgMEJnowCQYFKw4DAhoFAKCCAa8wGAYJKoZIhvcNAQkD
MQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMTIxMTI0MTgzOTI1WjAjBgkqhkiG9w0BCQQx
FgQUQr0OMiX6URownCXdREZjreLI/nYwgaUGCSsGAQQBgjcQBDGBlzCBlDCBjDELMAkGA1UEBhMC
SUwxFjAUBgNVBAoTDVN0YXJ0Q29tIEx0ZC4xKzApBgNVBAsTIlNlY3VyZSBEaWdpdGFsIENlcnRp
ZmljYXRlIFNpZ25pbmcxODA2BgNVBAMTL1N0YXJ0Q29tIENsYXNzIDEgUHJpbWFyeSBJbnRlcm1l
ZGlhdGUgQ2xpZW50IENBAgMEJnowgacGCyqGSIb3DQEJEAILMYGXoIGUMIGMMQswCQYDVQQGEwJJ
TDEWMBQGA1UEChMNU3RhcnRDb20gTHRkLjErMCkGA1UECxMiU2VjdXJlIERpZ2l0YWwgQ2VydGlm
aWNhdGUgU2lnbmluZzE4MDYGA1UEAxMvU3RhcnRDb20gQ2xhc3MgMSBQcmltYXJ5IEludGVybWVk
aWF0ZSBDbGllbnQgQ0ECAwQmejANBgkqhkiG9w0BAQEFAASCAQAon88nQ1+rzN8rxyS+zv9jk7iy
aDmQOeTFbJJD8WB2VhaxzYoyzdF45LXIDnXiJ1QKkmGu+OM/LZG1ggf5yymFyfo0V+mF5T4g1Wdg
A3G8g9KoCZTK2o7mGooTVToLfdKkBZmE7qbStyW5FIgeGB48uZeK3DnnCRjuMfMn3mo1sZptEkxs
rjyH3xaOdifxTg/mKKCslIsTRhl6aWT8tbdHuJi5zvt39+FAfgohP7lmHVok5bap0TmgqBCV6PiT
qOlzw5GPPuifVVRM+opl+QI05aSLezQAXI1ZqOKwcbJIU34b0Q5OG53y87Z+ZIRTHfS4jtRON8I1
3ix0iy5YY5EZAAAAAAAA


--=-PJSahic33nsb7ROUoUBQ--
