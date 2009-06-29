From: Or Gerlitz <ogerlitz@voltaire.com>
Subject: difference in counters values between vlan and parent device
Date: Mon, 29 Jun 2009 17:16:34 +0300 (IDT)
Message-ID: <Pine.LNX.4.64.0906291654310.27208@zuben.voltaire.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:26437 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1759887AbZF2OQn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jun 2009 10:16:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I noticed that the rx byte counters for 8021q/vlan devices are showing lower
quantities then the parent device. Below are three cuts of /proc/net/dev
where one can see clearly that after running unidirectional traffic over
the vlan the vlan TX packet/byte counters follow well the parent counters,
where after running bidirectional traffic the parent RX byte counters are
30% (30M vs 22M) higher, the packet counters follow the parent.

Now, looking in net/8021q/vlan_dev.c :: vlan_skb_recv() I see this code,

	stats->rx_packets++;
	stats->rx_bytes += skb->len;

I understand that skb->len as seen by the parent device may be different
then the len seen by 8021q but I don't see how it can account to 30%.

For what it worth, this is 2.6.30

Or.

1. both devices are fresh, just loaded the NIC driver (igb) and then setup a vlan

Inter-|   Receive                                                |  Transmit
 face |bytes    packets errs drop fifo frame compressed multicast|bytes    packets errs drop fifo colls carrier compressed
  eth1:       0       0    0    0    0     0          0         0    14456      55    0    0    0     0       0          0
eth1.4001:       0       0    0    0    0     0          0         0     6434      23    0    0    0     0       0          0

2. after running unidirectional traffic over the vlan (netperf UDP_STREAM)

Inter-|   Receive                                                |  Transmit
 face |bytes    packets errs drop fifo frame compressed multicast|bytes    packets errs drop fifo colls carrier compressed
  eth1:    1644      11    0    0    0     0          0         0 1136967388 17764927    0    0    0     0       0          0
eth1.4001:    1490      11    0    0    0     0          0         0 1136959282 17764893    0    0    0     0       0          0

3. after running bidirectional traffic over the vlan (netperf UDP_RR)

Inter-|   Receive                                                |  Transmit
 face |bytes    packets errs drop fifo frame compressed multicast|bytes    packets errs drop fifo colls carrier compressed
  eth1:30611926  546614    0    0    0     0          0         0 1160471756 18311532    0    0    0     0       0          0
eth1.4001:22959330  546614    0    0    0     0          0         0 1160463650 18311498    0    0    0     0       0          0
