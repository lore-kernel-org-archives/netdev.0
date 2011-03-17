From: Shirley Ma <mashirle@us.ibm.com>
Subject: [PATCH] virtio: Avoid virtio_net TX queue over run
Date: Wed, 16 Mar 2011 17:09:55 -0700
Message-ID: <1300320595.3255.29.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>,
	Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:46706 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751132Ab1CQAKG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2011 20:10:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch addresses small message size performance in a situation the
KVM guest virtio_net TX queue overrun. This patch adds a new API in
virtio_ring for ring capacity check; and remove KVM guest virtio_net TX
queue send completion interrupts completely. The test has shown that 
whenever the queue is overrun, it's much better to drop a few packets
than stopping TX queue and waiting for host to notify the guest to wake
up the TX queue again, the small messages size performance gain for
single TCP_STREAM BW could be up to 200%-300% and better than bare
metal, and no regression has been found in other situation.

Performance data for 10GbE,

KVM guest to local host:
------------------------
Message size	2.6.38-rc8 	2.6.38-rc8+patch
1024		1770.61		4528.37
2048		2702.30		7110.95
4096		5256.84		10104.76
8192		7543.66		10945.93
16K		10500.47	10783.50
64K		13718.62	13640.80

KVM guest to remote host:
--------------------------
Message size	Bare Metal  2.6.38-rc8	2.6.38-rc8+patch
1024		1802.67		2381.41		5599.15	
2048		4317.87		4094.12		9241.86
4096		6266.15		5231.24		9321.87
8192		8409.17		7952.74		9265.45
16K		9351.63		8260.68		8310.29
64K		9347.94		9103.75		9094.38 

Thanks
Shirley

