From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] bonding: Fix ARP monitor validation
Date: Sun, 07 Feb 2016 14:26:45 -0500 (EST)
Message-ID: <20160207.142645.2230058287676177228.davem@davemloft.net>
References: <29855.1454448956@famine>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vfalico@gmail.com,
	gospo@cumulusnetworks.com
To: jay.vosburgh@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35758 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750997AbcBGT0t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Feb 2016 14:26:49 -0500
In-Reply-To: <29855.1454448956@famine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <jay.vosburgh@canonical.com>
Date: Tue, 02 Feb 2016 13:35:56 -0800

> 
> 	The current logic in bond_arp_rcv will accept an incoming ARP for
> validation if (a) the receiving slave is either "active" (which includes
> the currently active slave, or the current ARP slave) or, (b) there is a
> currently active slave, and it has received an ARP since it became active.
> For case (b), the receiving slave isn't the currently active slave, and is
> receiving the original broadcast ARP request, not an ARP reply from the
> target.
> 
> 	This logic can fail if there is no currently active slave.  In
> this situation, the ARP probe logic cycles through all slaves, assigning
> each in turn as the "current_arp_slave" for one arp_interval, then setting
> that one as "active," and sending an ARP probe from that slave.  The
> current logic expects the ARP reply to arrive on the sending
> current_arp_slave, however, due to switch FDB updating delays, the reply
> may be directed to another slave.
> 
> 	This can arise if the bonding slaves and switch are working, but
> the ARP target is not responding.  When the ARP target recovers, a
> condition may result wherein the ARP target host replies faster than the
> switch can update its forwarding table, causing each ARP reply to be sent
> to the previous current_arp_slave.  This will never pass the logic in
> bond_arp_rcv, as neither of the above conditions (a) or (b) are met.
> 
> 	Some experimentation on a LAN shows ARP reply round trips in the
> 200 usec range, but my available switches never update their FDB in less
> than 4000 usec.
> 
> 	This patch changes the logic in bond_arp_rcv to additionally
> accept an ARP reply for validation on any slave if there is a current ARP
> slave and it sent an ARP probe during the previous arp_interval.
> 
> Fixes: aeea64ac717a ("bonding: don't trust arp requests unless active slave really works")
> Cc: Veaceslav Falico <vfalico@gmail.com>
> Cc: Andy Gospodarek <gospo@cumulusnetworks.com>
> Signed-off-by: Jay Vosburgh <jay.vosburgh@canonical.com>

I'm going to wait until we get some feedback from Uwe if you don't mind
Jay, it would be nice to know if it solves their problem too.
