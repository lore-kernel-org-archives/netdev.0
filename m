From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ixgbe question
Date: Mon, 23 Nov 2009 15:05:30 +0100
Message-ID: <4B0A96AA.8030104@gmail.com>
References: <20091123064630.7385.30498.stgit@ppwaskie-hc2.jf.intel.com>  <2674af740911222332i65c0d066h79bf2c1ca1d5e4f0@mail.gmail.com> <1258968980.2697.9.camel@ppwaskie-mobl2> <4B0A6218.9040303@gmail.com> <Pine.WNT.4.64.0911230225140.6352@ppwaskie-MOBL2.amr.corp.intel.com> <4B0A65E0.7060403@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:37191 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753080AbZKWOF1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 09:05:27 -0500
In-Reply-To: <4B0A65E0.7060403@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =E9crit :
> Waskiewicz Jr, Peter P a =E9crit :
>> On Mon, 23 Nov 2009, Eric Dumazet wrote:
>>
>>> Hi Peter
>>>
>>> I tried a pktgen stress on 82599EB card and could not split RX load=
 on multiple cpus.
>>>
>>> Setup is :
>>>
>>> One 82599 card with fiber0 looped to fiber1, 10Gb link mode.
>>> machine is a HPDL380 G6 with dual quadcore E5530 @2.4GHz (16 logica=
l cpus)
>> Can you specify kernel version and driver version?
>=20
>=20
> Well, I forgot to mention I am only working with net-next-2.6 tree.
>=20
> Ubuntu 9.10 kernel (Fedora Core 12 installer was not able to recogniz=
e disks on this machine :( )
>=20
> ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver - version 2.0.4=
4-k2
>=20
>=20

I tried with several pktgen threads, no success so far.

Only one cpu handles all interrupts and ksoftirq enters
a mode with no escape to splitted mode.

To get real multi queue and uncontended handling, I had to force :

echo 1 >`echo /proc/irq/*/fiber1-TxRx-0/../smp_affinity`=20
echo 2 >`echo /proc/irq/*/fiber1-TxRx-1/../smp_affinity`
echo 4 >`echo /proc/irq/*/fiber1-TxRx-2/../smp_affinity`
echo 8 >`echo /proc/irq/*/fiber1-TxRx-3/../smp_affinity`
echo 10 >`echo /proc/irq/*/fiber1-TxRx-4/../smp_affinity`
echo 20 >`echo /proc/irq/*/fiber1-TxRx-5/../smp_affinity`
echo 40 >`echo /proc/irq/*/fiber1-TxRx-6/../smp_affinity`
echo 80 >`echo /proc/irq/*/fiber1-TxRx-7/../smp_affinity`
echo 100 >`echo /proc/irq/*/fiber1-TxRx-8/../smp_affinity`
echo 200 >`echo /proc/irq/*/fiber1-TxRx-9/../smp_affinity`
echo 400 >`echo /proc/irq/*/fiber1-TxRx-10/../smp_affinity`
echo 800 >`echo /proc/irq/*/fiber1-TxRx-11/../smp_affinity`
echo 1000 >`echo /proc/irq/*/fiber1-TxRx-12/../smp_affinity`
echo 2000 >`echo /proc/irq/*/fiber1-TxRx-13/../smp_affinity`
echo 4000 >`echo /proc/irq/*/fiber1-TxRx-14/../smp_affinity`
echo 8000 >`echo /proc/irq/*/fiber1-TxRx-15/../smp_affinity`


Probably problem comes from fact that when ksoftirqd runs and
RX queues are not depleted, no hardware interrupts is sent,
and NAPI contexts stay sticked on one cpu forever ?

