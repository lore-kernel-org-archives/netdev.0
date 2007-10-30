From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] remove claim balance_rr won't reorder on many to one
Date: Tue, 30 Oct 2007 13:55:50 -0700
Message-ID: <5242.1193777750@death>
References: <200710301948.MAA04351@tardy.cup.hp.com>
Cc: netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:44015 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754408AbXJ3Uzx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Oct 2007 16:55:53 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9UKtqXL017105
	for <netdev@vger.kernel.org>; Tue, 30 Oct 2007 16:55:52 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9UKtq49116718
	for <netdev@vger.kernel.org>; Tue, 30 Oct 2007 14:55:52 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9UKtq5t026698
	for <netdev@vger.kernel.org>; Tue, 30 Oct 2007 14:55:52 -0600
In-reply-to: <200710301948.MAA04351@tardy.cup.hp.com> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rick Jones <rick.jones2@hp.com> wrote:
[...]
>-	Note that this out of order delivery occurs when both the
>-	sending and receiving systems are utilizing a multiple
>-	interface bond.  Consider a configuration in which a
>-	balance-rr bond feeds into a single higher capacity network
>-	channel (e.g., multiple 100Mb/sec ethernets feeding a single
>-	gigabit ethernet via an etherchannel capable switch).  In this
>-	configuration, traffic sent from the multiple 100Mb devices to
>-	a destination connected to the gigabit device will not see
>-	packets out of order.  However, traffic sent from the gigabit
>-	device to the multiple 100Mb devices may or may not see
>-	traffic out of order, depending upon the balance policy of the
>-	switch.  Many switches do not support any modes that stripe
>-	traffic (instead choosing a port based upon IP or MAC level
>-	addresses); for those devices, traffic flowing from the
>-	gigabit device to the many 100Mb devices will only utilize one
>-	interface.

	Rather than simply removing this entirely (because I do think
there is value in discussion of the reordering aspects of balance-rr),
I'd rather see something that makes the following points:

	1- the worst reordering is balance-rr to balance-rr, back to
back.  The reordering rate here depends upon (a) the number of slaves
involved and (b) packet reception scheduling behaviors (packet
coalescing, NAPI, etc), and thus will vary signficantly, but won't be
better than case #2.

	2- next worst is "balance-rr many slow" to "single fast", with
the reordering rate generally being substantially lower than case #1 (it
looked like your test showed about a 1% reordering rate, if I'm reading
your data correctly).

	3- For the "single fast" to "balance-rr many" case, going
through a switch configured for etherchannel "may or may not see traffic
out of order, depending upon the balance policy of the switch.  Many
switches do not support any modes that stripe traffic (instead choosing
a port based upon IP or MAC level addresses); for those devices, traffic
flowing from the [single fast] device to the [balance-rr many] devices
will only utilize one interface."

[...]
> 	This mode requires the switch to have the appropriate ports
>-	configured for "etherchannel" or "trunking."
>+	configured for "etherchannel" or "aggregation." N.B. some
>+	switches might use the term "trunking" for something other 
>+	than link aggregation.

	If memory serves, Sun uses the term "trunking" to refer to
"etherchannel" compatible behavior.

	I'm also hearing "aggregation" used to described 802.3ad
specifically.

	Perhaps text of the form:

	This mode requires the switch to have the appropriate ports
configured for "Etherchannel."  Some switches use different terms, so
the configuration may be called "trunking" or "aggregation."  Note that
both of these terms also have other meanings.  For example, "trunking"
is also used to describe a type of switch port, and "aggregation" or
"link aggregation" is often used to refer to 802.3ad link aggregation,
which is compatible with bonding's 802.3ad mode, but not balance-rr.

	Thoughts?

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
