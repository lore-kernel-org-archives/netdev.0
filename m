From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 0/2] sunvnet: Packet processing in non-interrupt
 context.
Date: Wed, 1 Oct 2014 14:56:04 -0400
Message-ID: <20141001185604.GG17706@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, raghuram.kothakota@oracle.com,
	sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:22898 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751518AbaJAS4J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 14:56:09 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The existing sunvnet implementation does all the packet interception
in LDC interrupt context. Patch 1 of this series moves the data
processing to a bottom-half handler.

Some context for the reasons for choosing a BH handler over NAPI:
   A NAPI (or simple tasklet) based implementation provides softirq
   context, which allows the driver to safely invoke netif_receive_skb()
   to deliver the packet to the IP stack. But in the case of sunvnet,
   we are already receiving multiple packets for a single ldc_rx
   interrupt, so the budget-based softirq-vs-polling infra does not
   provide a significant optimization. Rather, it can get in the way,
   if we constrain the vnet-rx path to a poorly chosen budget, and force
   ourselves to send a STOPPED/START ldc exchange needlessly.

   A BH Rx handler is a simpler way to  avoid the weaknesses of processing
   packets in LDC interrupt context, and also provides Rx load-spreading
   across multiple CPUs.

Note that PATCH 1 is dependant on the functions added as part of the
sparc-next commit "sparc64: Add vio_set_intr() to enable/disable Rx interrupts"
(Cf: http://www.spinics.net/lists/sparclinux/msg12647.html)

PATCH 2 of this series fixes a race-condition between vnet_port_remove()
and vnet_start_xmit().

Sowmini Varadhan (2):
  Process Rx data packets in a BH handler
  vnet_start_xmit() must hold a refcnt on port.

 drivers/net/ethernet/sun/sunvnet.c | 187 +++++++++++++++++++++++++++----------
 drivers/net/ethernet/sun/sunvnet.h |  12 ++-
 2 files changed, 146 insertions(+), 53 deletions(-)

-- 
1.8.4.2
