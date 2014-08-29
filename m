From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 0/2] sunvnet: Reduce LDC message overhead.
Date: Fri, 29 Aug 2014 16:16:24 -0400
Message-ID: <20140829201624.GG14753@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, sowmini.varadhan@oracle.com,
	raghuram.kothakota@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:36512 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754373AbaH2UQd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Aug 2014 16:16:33 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch series has 2 sets of changes to reduce the overhead
from LDC messages.

- the current linux sunvnet driver sends out many more LDC start and stop
  triggers than it needs to: when we are sending a burst of packets across
  multiple descriptor rings, we only need to send the "start" trigger for
  the first dring (we currently send one for every dring). And we only need
  to send the "STOPPED" trigger for the last dring (and if that fails, hold
  off and send the trigger later).

- When reading the descriptor rings, don't give up as soon as a dring
  that is not VIO_DESC_READY is found- especially when the peer is sending
  a burst of packets, it is worthwhile to recheck the descriptor status
  after a small microsecond delay, as the likelihood of finding this
  descriptor READY is high, and it is cheaper to just retry with a delay
  than to return from the current context, read another LDC message,
  and then come back to read this descriptor.

Sowmini Varadhan (2):
  Avoid sending superfluous LDC messages.
  Re-check for a VIO_DESC_READY data descriptor after short udelay()

 drivers/net/ethernet/sun/sunvnet.c | 87 ++++++++++++++++++++++++++++++++++----
 drivers/net/ethernet/sun/sunvnet.h |  4 ++
 2 files changed, 83 insertions(+), 8 deletions(-)

-- 
1.8.4.2
