From: Jiri Bohac <jbohac@suse.cz>
Subject: bonding: time limits too tight in bond_ab_arp_inspect
Date: Wed, 22 Aug 2012 19:45:34 +0200
Message-ID: <20120822174534.GA20260@midget.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Petr Tesarik <ptesarik@suse.cz>
To: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:49375 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752676Ab2HVRpd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Aug 2012 13:45:33 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

a customer reported that a bonding slave did not come back up
after setting their link down and then up again. ARP monitoring +
arp_validate were used.

Petr has tracked the problem down to the time comaprisons in
bond_ab_arp_inspect().

                if (slave->link != BOND_LINK_UP) {
                        if (time_in_range(jiffies,
                                slave_last_rx(bond, slave) - delta_in_ticks,
                                slave_last_rx(bond, slave) + delta_in_ticks)) {

                                slave->new_link = BOND_LINK_UP;
                                commit++;
                        }

                        continue;
                }

This code is run from bond_activebackup_arp_mon() about
delta_in_ticks jiffies after the previous ARP probe has been
sent. If the delayed work gets executed exactly in delta_in_ticks
jiffies, there is a chance the slave will be brought up.  If the
delayed work runs one jiffy later, the slave will stay down.

With arp_validate this is more noticeable, since traffic other than the
bonding-generated ARP probes does not update the slave_last_rx timestamp.

A simple patch will fix this case.

--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3001,7 +3001,7 @@ static int bond_ab_arp_inspect(struct bo
 		if (slave->link != BOND_LINK_UP) {
 			if (time_in_range(jiffies,
 				slave_last_rx(bond, slave) - delta_in_ticks,
-				slave_last_rx(bond, slave) + delta_in_ticks)) {
+				slave_last_rx(bond, slave) + 2 * delta_in_ticks)) {
 
 				slave->new_link = BOND_LINK_UP;
 				commit++;


The remaining time comparisons inside bond_ab_arp_inspect() have larger
tolerances (3*delta_in_ticks or 2*delta_in_ticks), but it still seems strange
that the precision of delayed work scheduling should steal a full
arp_interval from the time limits.

What is the intention of e.g. the "3*delta since last receive" limit? 
Was this really meant to be "as little as 2*delta + 1 jiffy"?

Should they perhaps all be increased by, say, delta_in_ticks/2, to make this
less dependent on the current scheduling latencies?

Thoughts?

-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ
