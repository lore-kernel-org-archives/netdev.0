From: Jasper Spaans <spaans@fox-it.com>
Subject: bridging + load balancing bonding
Date: Thu, 22 Oct 2009 14:23:39 +0200
Message-ID: <20091022122339.GA20148@spaans.fox.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.fox-it.com ([82.94.91.210]:34835 "EHLO mail2.fox-it.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755443AbZJVM6B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Oct 2009 08:58:01 -0400
Received: from localhost (mail2 [127.0.0.1])
	by mail2.fox-it.com (Postfix) with ESMTP id C4E1E4EC84
	for <netdev@vger.kernel.org>; Thu, 22 Oct 2009 14:23:44 +0200 (CEST)
Received: from mail2.fox-it.com ([127.0.0.1])
 by localhost (mail2.fox-it.com [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 12889-09 for <netdev@vger.kernel.org>;
 Thu, 22 Oct 2009 14:23:44 +0200 (CEST)
Received: from FOXDFT02.FOX.local (unknown [10.0.0.66])
	by mail2.fox-it.com (Postfix) with ESMTP
	for <netdev@vger.kernel.org>; Thu, 22 Oct 2009 14:23:44 +0200 (CEST)
Received: from spaans by spaans.fox.local with local (Exim 4.69)
	(envelope-from <spaans@fox-it.com>)	id 1N0whf-0005Os-58	for
 netdev@vger.kernel.org; Thu, 22 Oct 2009 14:23:39 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

We're using the following setup for bonding and bridging, to be able to put
large amounts of data through multiple IDS analyzers:

                             +---[br0]----+     +--- eth1 ---(IDS machine 1)
(Span port from switch) -- eth0          bond0--+
                                                +--- eth2 ---(IDS machine 2)

eth0 receives network traffic, which should be passed to machines which are
connected to eth1 and eth2. These machines run an IDS package, and there are
two of those for performance reasons.

bond0 is configured to load balance the packets using "balance-xor", in this
case combined with xmit_hash_policy layer2.

However, we're seeing problems: packets from one flow do not end up at the
same IDS machine.  This is because this selection is not based on the source
_and_ destination mac addresses of the original packet, but on the mac
address of the bonding device and the destination mac address of the
package.

This is also clear in the code:
For example, in bond_main.c, in bond_xmit_hash_policy_l2:
	return (data->h_dest[5] ^ bond_dev->dev_addr[5]) % count;

Changing this to
	return (data->h_dest[5] ^ data->h_source[5]) % count;
fixes our problems, but is this harmful for packets originating locally (or
being routed?)

If not, can this be applied? Or does anyone have other ideas?

Thanks,
Jasper Spaans
-- 
Fox-IT Experts in IT Security!
T: +31 (0) 15 284 79 99
KvK Haaglanden 27301624
