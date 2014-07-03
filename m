From: Flavio Leitner <fbl@redhat.com>
Subject: RSS is not efficient when forwarding
Date: Thu, 3 Jul 2014 19:44:08 -0300
Message-ID: <20140703224408.GA2343@t520.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55906 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753290AbaGCWoK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Jul 2014 18:44:10 -0400
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s63Mi97w029143
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 3 Jul 2014 18:44:10 -0400
Received: from localhost (vpn1-7-95.gru2.redhat.com [10.97.7.95])
	by int-mx13.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id s63Mi8EE026585
	for <netdev@vger.kernel.org>; Thu, 3 Jul 2014 18:44:09 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,

I have a simple router setup which forwards traffic from
one ixgbe 82599ES to another ixgbe of the same model.

kernel: 3.16.0-rc2-00262-ga921e2a

  p2p1: 192.168.155.1/24 is the gateway of the LAN
  p2p2: 192.168.156.1/24 is the gateway of the other LAN

While the ARP is resolving, I can see the packets being spread
among all the 8 queues (8 online CPUs) available and that is fine.

However, as soon as the TCP traffic starts, all streams are
merged to rx-queue-0 which overwhelms one single CPU, so the
total throughput is about 4Gbits/sec.

I can see the driver sending different skb->hash for each stream,
so it can't be the NIC.

Also, if I run a local http on the router, the skb->hash pattern
doesn't change, but the workload is spread among all CPUs.

debug output while reproducing all the streams on rx-queue-0:
[...]
[11685.885093] ixgbe_rx_skb:1713 skb(ffff880222a77200) hash: 0xC2AF4A27
[11685.891454] ixgbe_rx_skb:1713 skb(ffff880222a77200) hash: 0x8C5B749D
[11685.897820] ixgbe_rx_skb:1713 skb(ffff880222a77200) hash: 0xA33BA6D5
[11690.845032] net_ratelimit: 3276406 callbacks suppressed
[...]

Any idea why all TCP streams are going to a single rx queue?

Thanks,
fbl
