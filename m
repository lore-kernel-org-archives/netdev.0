From: Horia Geanta <horia.geanta@freescale.com>
Subject: [RFC ipsec-next] Temporary SA allocation and OOM
Date: Sun, 26 Jan 2014 11:50:51 +0200
Message-ID: <1390729852-7842-1-git-send-email-horia.geanta@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co1ehsobe002.messaging.microsoft.com ([216.32.180.185]:29104
	"EHLO co1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750987AbaAZJwd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jan 2014 04:52:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

In the cases where:
-policies are in place
-there are no key managers registered to PF_KEY / NETLINK XFRM events
-xfrm_states are not available (no KM to negotiate them)

xfrm_state_find will be called for every IPsec packet entering the system.
A temporary SA is allocated; however, since there are no KMs, km_query()
fails to send an ACQUIRE notification and the temporary SA is
immediately garbage collected.

This leads to OOM, considering the fact that SA alloc/free is performed
for each packet and garbage collection does not keep up the pace when
traffic rate is high.

I am attaching as RFC a patch that checks whether there are
any KMs registered before allocating the temporary SA.

A new callback - is_alive - is added to the xfrm_mgr.
If is_alive returns true, there are many chances that km_query() won't fail,
thus temporary SA won't be freed (at least not until it expires - 30s default).
This alleviates the strain caused by very frequent memory allocation.

Thanks,
Horia

Horia Geanta (1):
  xfrm: avoid creating temporary SA when there are no listeners

 include/net/xfrm.h    | 15 +++++++++++++++
 net/key/af_key.c      | 20 ++++++++++++++++++++
 net/xfrm/xfrm_state.c | 31 +++++++++++++++++++++++++++++++
 net/xfrm/xfrm_user.c  |  6 ++++++
 4 files changed, 72 insertions(+)

-- 
1.8.3.1
