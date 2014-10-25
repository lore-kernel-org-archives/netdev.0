From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCHv6 net-next 0/3] sunvnet: NAPIfy sunvnet
Date: Sat, 25 Oct 2014 15:11:52 -0400
Message-ID: <20141025191152.GA31334@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, bob.picco@oracle.com,
	sowmini.varadhan@oracle.com, dwight.engen@oracle.com,
	raghuram.kothakota@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:23467 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751699AbaJYTMa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Oct 2014 15:12:30 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patchset converts the sunvnet driver to use the NAPI framework.
Changes since v4 to Patch1: 
  vnet_event accumulates LDC_EVENT_* bits into rx_event. 
  vnet_event_napi() unrolls send_events() logic to process all rx_event bits.
Changes since v5: 
  Patch 1: use net_device.h definition for NAPI_POLL_WEIGHT.
  Drop sparclinux changes (patch3) per David Miller feedback 

Patch 1 in the series addresses the packet-receive path- all
the vnet_event() processing is moved into NAPI context.
This patch is dependant on the sparc-next commit:
  "sparc64: Add vio_set_intr() to enable/disable Rx interrupts"
  (sparc commit id ca605b7dd740c8909408d67911d8ddd272c2b320)

Patch 2 uses RCU to fix race conditions between vnet_port_remove and
paths that access/modify port-related state, such as vnet_start_xmit.

Patch 3 leverages from the NAPIfied Rx path, 
dropping superfluous usage of the irqsave/irqrestores on the vio.lock
where possible.


Sowmini Varadhan (4):
  NAPIfy sunvnet
  Use RCU to synchronize port usage with vnet_port_remove()
  Avoid irqsave/restore on vio.lock if in_softirq()
  Remove irqsave/irqrestore on vio.lock

 arch/sparc/kernel/viohs.c          |   8 +-
 drivers/net/ethernet/sun/sunvnet.c | 263 +++++++++++++++++++++++--------------
 drivers/net/ethernet/sun/sunvnet.h |   6 +-
 3 files changed, 177 insertions(+), 100 deletions(-)

-- 
1.8.4.2
