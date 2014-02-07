From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: Cascading Bond devices
Date: Thu, 06 Feb 2014 23:57:29 -0800
Message-ID: <2905.1391759849@death.nxdomain>
References: <20140207074149.GA17815@glanzmann.de>
Cc: Linux Network Development <netdev@vger.kernel.org>
To: Thomas Glanzmann <thomas@glanzmann.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:57188 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751736AbaBGH6D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Feb 2014 02:58:03 -0500
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Fri, 7 Feb 2014 00:58:03 -0700
Received: from b03cxnp07029.gho.boulder.ibm.com (b03cxnp07029.gho.boulder.ibm.com [9.17.130.16])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 54BC33E40044
	for <netdev@vger.kernel.org>; Fri,  7 Feb 2014 00:58:01 -0700 (MST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by b03cxnp07029.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s175tNlD9503094
	for <netdev@vger.kernel.org>; Fri, 7 Feb 2014 06:55:28 +0100
Received: from d03av01.boulder.ibm.com (localhost [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s177veRw022915
	for <netdev@vger.kernel.org>; Fri, 7 Feb 2014 00:57:41 -0700
In-reply-to: <20140207074149.GA17815@glanzmann.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thomas Glanzmann <thomas@glanzmann.de> wrote:

>I wonder if it is possible to cascade bond devices. I have currently a
>box with four network cards. Two are going to switch a and two are going
>to switchb. And what I would like to do is the following:
>
>switch-01 port 1 - eth0 \
>switch-01 port 2 - eth1 - bond0 (802.3ad Layer 2 hash) \
>switch-02 port 1 - eth2 - bond1 (802.3ad Layer 2 hash) - bond2 (active-passive)
>switch-02 port 2 - eth3 /

	For this specific case, it is unnecessary to nest the bonds, as
one feature of 802.3ad is that it will group the ports correctly into
multiple aggregators, and fail over from one to the other under certain
circumstances selected by the ad_select parameter.  It is not possible
to select different hash algorithms on a per-aggregator basis, though.

>If it is possible, how would I configure such a scenario? bond0 and
>bond1 is easy and in fact I already have them. But I don't get howto to
>use adifferent hashing algorithm for bond2.

	Generally speaking, nesting of bonds does not function
correctly.  It is possible to configure, but various parts do not
function as expected from the nesting (when last I checked, transmit
generally functioned, but receive generally did not).

>I also wanted to use tlb/alb in the past but experienced broadcast
>storms when using IPv6 on such devices. Also I was not able to set an
>IPv6 address because of duplicated address detection told me that it was
>already online on the subnet which it was not. This was with kernel 3.12
>and 3.13.

	With a nesting, or just in general?  I have not tested alb/tlb
modes much with IPv6, but the remote peer load balancing scheme for alb
mode in particular is only implemented for IPv4.  I do recall that both
of them should balance outgoing traffic for IPv6.

	As far as storms go, normally for tlb/alb, one slave is the
"active" slave, and for both alb and tlb should be the only slave that
receives broadcasts or multicasts.  For tlb mode, the active slave is
the only slave that receives anything at all, the others are
transmit-only.  For alb mode, the other slaves receive unicast traffic
from network peers according to the balance algorithm issuing special
ARP frames to those peers to direct their traffic (this is the IPv4-only
part).

	I have not tested tlb/alb with very recent kernels, so it's
possible that something has been broken in some of the substantial
changes over the last few months.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
