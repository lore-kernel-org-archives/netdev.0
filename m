From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: sky2 bonding problem, 802.3ad
Date: Thu, 15 Feb 2007 12:13:14 -0800
Message-ID: <200702152013.l1FKDE22017473@death.nxdomain.ibm.com>
References: <871wkruu6p.fsf@kruemel.my-eitzenberger.de>
Cc: shemminger@linux-foundation.org,
	sk-drivers@lists.linux-foundation.org, netdev@vger.kernel.org
To: Holger Eitzenberger <holger@my-eitzenberger.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:37452 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161133AbXBOUN2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Feb 2007 15:13:28 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l1FKDQ2i011976
	for <netdev@vger.kernel.org>; Thu, 15 Feb 2007 15:13:26 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l1FKDGuW109032
	for <netdev@vger.kernel.org>; Thu, 15 Feb 2007 15:13:16 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l1FKDGCD021008
	for <netdev@vger.kernel.org>; Thu, 15 Feb 2007 15:13:16 -0500
In-reply-to: <871wkruu6p.fsf@kruemel.my-eitzenberger.de> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Holger Eitzenberger <holger@my-eitzenberger.de> wrote:

>I have tested v1.10 with kernel 2.6.19 and 2.6.16.36 (own backport),
>which despite the bonding problem runs fine.  Both, kernel 2.6.19 and
>2.6.16.36 show the same behaviour.  The 802.3ad aware switch is a Dell
>PowerConnect 5324.  VLAN is not configured on all switch ports.  Another
>test on a host running kernel 2.6.18.2 with two e1000's bonded runs
>fine.  Using sk98lin (v8.41 & v10.0.4) worked also.

	The log you included (with debug turned on) indicates that
bonding is at least attempting to send LACPDUs, but there are no log
entries for having received any LACPDUs.

	I'm unfamiliar with your particular switch, but usually this
kind of problem with bonding 802.3ad is in the switch interaction.  The
switches I have (Cisco) require that 802.3ad mode be explicitly enabled
on whichever ports it is desired on, so it may be worthwhile to check
your switch and make sure that it really is configured for 802.3ad on
the sky2 ports.

	If the switch is configured, you may want to also check to see
if it has counters for LACPDUs sent and received.  If the switch is not
sending and receiving LACPDUs on the appropriate ports, then it's more
likely to be a communications problem somewhere (vs. an 802.3ad
negotiation problem).

>When looking at the working bond I see that both slave interfaces are
>IFF_UP, the load is shared over both links.  When looking at the failing
>sky2 bond I see that the bond is not IFF_UP, whereas both slave
>interfaces are IFF_UP.  The 802.3ad "partner MAC address" is left all zero's, 
>also both interfaces have different Aggregator IDs (1 & 2).  One of the
>two failing interfaces always has IFF_NOARP set, caused by code
>calling bond_main.c:bond_set_slave_inactive_flags().

	For the version of bonding in your dmesg log, the IFF_NOARP is
expected; 802.3ad will select one aggregator as the active one, the
other aggregators will be marked inactive, and that sets IFF_NOARP.
Since no LACPDUs have been exchanged, bonding is leaving each interface
as a separate aggregator.  Versions of bonding later than February 2006
(your proc-bond0-ok for example) don't set the IFF_NOARP on inactive
slaves (a new mechanism is used that doesn't mess with the flags).

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
