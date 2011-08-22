From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Miscalculated TCP ACK ?
Date: Mon, 22 Aug 2011 20:49:33 +0200
Message-ID: <1314038973.3777.0.camel@edumazet-laptop>
References: <CAPbw_hwQSXtmFSxK49jDDgF2LuG8=cu5t=ZjQ_aO7=M9fm9xeA@mail.gmail.com>
	 <1314031128.2307.110.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CAEnQRZAB=tKwr0wX2OrpG8iq5VaJPmssHEfC3U62bz1XL_2FHw@mail.gmail.com>
	 <CAPbw_hy7xjhWSsiHnB9HN+ROCEUNzOS8aPsFwjvdY4FY+pRVjw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Gabriel Beddingfield <gabrbedd@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:50724 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753370Ab1HVStj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2011 14:49:39 -0400
Received: by wwe5 with SMTP id 5so2423749wwe.1
        for <netdev@vger.kernel.org>; Mon, 22 Aug 2011 11:49:37 -0700 (PDT)
In-Reply-To: <CAPbw_hy7xjhWSsiHnB9HN+ROCEUNzOS8aPsFwjvdY4FY+pRVjw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 22 ao=C3=BBt 2011 =C3=A0 13:05 -0500, Gabriel Beddingfield a =C3=
=A9crit :=20
> On Mon, Aug 22, 2011 at 12:19 PM, Daniel Baluta <daniel.baluta@gmail.=
com> wrote:
> >>> It appears to me that the ACK is off-by-one (should have been 276=
76).
> >>> The server replies again with retransmissions.  This is with seve=
ral
> >>> kernel versions on local machines, ranging from 2.6.31 to 2.6.38.
> >
> >> Not a bug if frame carried a FIN
>=20
> The server packet had the FIN bit set.
>=20

then its fine.

> > Well then, why do retransmissions occur?
> > Gabriel could you post the full capture file?
>=20
> Sure: http://gabe.is-a-geek.org/tmp/20110822-skyward-conversation-seg=
ment.tcpdump
>=20
> I clipped the conversation to the vicinity of the problem.
>=20

This sounds as a TSO bug, maybe driver/NIC related

What is the NIC/driver used on your server ?

try "ethtool -K eth0 tso off" on the server

$ tcpdump -p -n -S -r 20110822-skyward-conversation-segment.tcpdump
reading from file 20110822-skyward-conversation-segment.tcpdump, link-t=
ype EN10MB (Ethernet)

Sorry we miss a few frames just before.

14:48:31.368344 IP 50.84.128.30.443 > 192.168.1.25.36015: Flags [.], se=
q 401237709:401239157, ack 1404739303, win 64334, options [nop,nop,TS v=
al 1663311 ecr 3624365496], length 1448
14:48:31.368410 IP 192.168.1.25.36015 > 50.84.128.30.443: Flags [.], ac=
k 401239157, win 52128, options [nop,nop,TS val 3624365515 ecr 1663311]=
, length 0
14:48:31.368556 IP 50.84.128.30.443 > 192.168.1.25.36015: Flags [.], se=
q 401239157:401240605, ack 1404739303, win 64334, options [nop,nop,TS v=
al 1663311 ecr 3624365496], length 1448
14:48:31.369019 IP 50.84.128.30.443 > 192.168.1.25.36015: Flags [.], se=
q 401240605:401242053, ack 1404739303, win 64334, options [nop,nop,TS v=
al 1663311 ecr 3624365496], length 1448
14:48:31.369099 IP 192.168.1.25.36015 > 50.84.128.30.443: Flags [.], ac=
k 401242053, win 57920, options [nop,nop,TS val 3624365515 ecr 1663311]=
, length 0
14:48:31.369357 IP 50.84.128.30.443 > 192.168.1.25.36015: Flags [.], se=
q 401242053:401243501, ack 1404739303, win 64334, options [nop,nop,TS v=
al 1663311 ecr 3624365496], length 1448
14:48:31.369412 IP 50.84.128.30.443 > 192.168.1.25.36015: Flags [FP.], =
seq 401243501:401243519, ack 1404739303, win 64334, options [nop,nop,TS=
 val 1663311 ecr 3624365496], length 18

following frames acknowledge all data sent from server and FIN flag.
14:48:31.369442 IP 192.168.1.25.36015 > 50.84.128.30.443: Flags [.], ac=
k 401243520, win 57920, options [nop,nop,TS val 3624365516 ecr 1663311]=
, length 0

Up to there, its OK.

But following frame makes no sense : this data was already acknowledged

14:48:31.373447 IP 50.84.128.30.443 > 192.168.1.25.36015: Flags [.], se=
q 401236261:401237709, ack 1404739303, win 64334, options [nop,nop,TS v=
al 1663311 ecr 3624365496], length 1448

14:48:31.373532 IP 192.168.1.25.36015 > 50.84.128.30.443: Flags [.], ac=
k 401243520, win 57920, options [nop,nop,TS val 3624365520 ecr 1663311,=
nop,nop,sack 1 {401236261:401237709}], length 0

client timeouts :
14:48:31.458943 IP 192.168.1.25.36015 > 50.84.128.30.443: Flags [F.], s=
eq 1404739303, ack 401243520, win 57920, options [nop,nop,TS val 362436=
5605 ecr 1663311], length 0

14:48:31.475204 IP 50.84.128.30.443 > 192.168.1.25.36015: Flags [.], ac=
k 1404739304, win 64334, options [nop,nop,TS val 1663321 ecr 3624365605=
], length 0
14:48:31.475351 IP 50.84.128.30.443 > 192.168.1.25.36015: Flags [.], ac=
k 1404739304, win 0, length 0
14:48:31.475395 IP 192.168.1.25.36015 > 50.84.128.30.443: Flags [R], se=
q 1404739304, win 0, length 0



