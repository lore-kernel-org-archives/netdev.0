From: David Miller <davem@davemloft.net>
Subject: ARP resolving for switch drivers
Date: Sun, 22 Feb 2015 01:11:09 -0500 (EST)
Message-ID: <20150222.011109.109641758308879034.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38823 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751072AbbBVGLN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Feb 2015 01:11:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Scott I looked into the current state of affairs and you should
be able to use generic infrastructure to resolve a neighbour
entry and even trigger the state machine.

For ipv4:

	n = __ipv4_neigh_lookup(dev, ip_addr);
	if (!n)
		n = neigh_create(&arp_tbl, &ip_addr, dev, true);
	if (!n)
		goto error;

	if (!(n->nud_state & NUD_VALID))
		neigh_event_send(n, NULL);
	else
		memcpy(&hw_entry->mac_addr, n->ha, dev_addr_len);

If you have to take the neigh_event_send() path, you have to wait for
the notifier to be invoked.  And in the notifier you can fetch the
MAC address.

You shouldn't have to hand craft ARP requests and listen for responses
or anything like that.
