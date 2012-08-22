From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: bonding: why zero out bond_dev->dev_addr when last slave removed?
Date: Wed, 22 Aug 2012 14:20:10 -0700
Message-ID: <26676.1345670410@death.nxdomain>
References: <5035458C.9000804@genband.com>
Cc: Andy Gospodarek <andy@greyhouse.net>,
	netdev <netdev@vger.kernel.org>
To: Chris Friesen <chris.friesen@genband.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:59624 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752177Ab2HVVUn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 17:20:43 -0400
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Wed, 22 Aug 2012 15:20:42 -0600
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 337CE1FF003C
	for <netdev@vger.kernel.org>; Wed, 22 Aug 2012 15:20:40 -0600 (MDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q7MLKEA8182430
	for <netdev@vger.kernel.org>; Wed, 22 Aug 2012 15:20:14 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q7MLKCPw027254
	for <netdev@vger.kernel.org>; Wed, 22 Aug 2012 15:20:13 -0600
In-reply-to: <5035458C.9000804@genband.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chris Friesen <chris.friesen@genband.com> wrote:
[...]
>I was wondering about the rationale for zeroing out bond_dev->dev_addr
>when the last slave is removed from the bond.
>
>Assuming bond0 is currently using the mac address of eth0 then doing
>
>ifenslave -d bond0 eth0
>ifenslave -d bond0 eth1
>ifenslave bond0 eth1
>ifenslave bond0 eth0
>
>ends up changing the MAC address of the bond link. Given that the bond
>itself stays up during this time, why don't we let the bond device keep
>it's previous MAC address (at least if fail_over_mac is zero)?
>
>Is this to account for the case where we move the bond to totally
>different devices such that the old MAC no longer belongs to one of the
>slaves but instead belongs to a NIC outside the bond?

	More or less.  When the last slave is removed from the bond,
several properties of the bond are reset to an initial state, one of
which is that the bond's MAC is reset to all zeroes.

	If fail_over_mac is set to "active," then the bond must use the
MAC of one of its slaves, as the implication is that the slaves cannot
or should not change their MAC addresses.  In this case, I believe the
bond's MAC will be set to the first active slave's MAC, so holding over
the bond's MAC makes no practical difference.

	For fail_over_mac=follow, if the bond kept its MAC, then it
would be possible for both slaves to end up with the same MAC (because
the follow logic will set the first slave to the bond's MAC when it is
made active, and the second slave will keep its MAC after enslavement,
and those could be the same MAC if the second slave is the one the bond
originally got its MAC from).

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
