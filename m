From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [PATCH net v2] bonding: Fix ARP monitor validation
Date: Wed, 3 Feb 2016 14:40:58 -0500
Message-ID: <20160203194058.GE54057@redhat.com>
References: <29855.1454448956@famine>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	"David S. Miller" <davem@davemloft.net>,
	Uwe Koziolek <uwe.koziolek@redknee.com>
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38764 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751524AbcBCTk7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Feb 2016 14:40:59 -0500
Content-Disposition: inline
In-Reply-To: <29855.1454448956@famine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 02, 2016 at 01:35:56PM -0800, Jay Vosburgh wrote:
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
> 
> ---
> v2: more detail in log and comment; no code change.

This sounds suspiciously like the same problem Uwe was encountering[*] and
attempting to solve. Uwe, can you give this patch a try?

[*] = http://marc.info/?l=linux-netdev&m=144416122705850&w=2

-- 
Jarod Wilson
jarod@redhat.com
