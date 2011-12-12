From: Vasu Dev <vasu.dev@intel.com>
Subject: [PATCH] net: do not pass vlan pkts to real dev pkt handler also
Date: Mon, 12 Dec 2011 14:19:23 -0800
Message-ID: <20111212221923.5356.43629.stgit@vifc.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jpirko@redhat.com, devel@open-fcoe.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:39255 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754185Ab1LLWSq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Dec 2011 17:18:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The orig_dev has to be updated before going another round
for vlan pkts, otherwise currently unmodified real orig_dev
causes vlan pkt delivered to real orig_dev also.

The fcoe stack doesn't expects its vlan pkts on real dev
and it causes crash in fcoe stack.

This wasn't issue untill __netif_receive_skb recursive calling
was removed with this commit 0dfe178, so this patch restores
orig_dev uses as it was prior to that commit but still w/o
recursive calling to __netif_receive_skb.

Signed-off-by: Vasu Dev <vasu.dev@intel.com>
---

 net/core/dev.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index f494675..adbcd7a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3222,9 +3222,10 @@ ncls:
 			ret = deliver_skb(skb, pt_prev, orig_dev);
 			pt_prev = NULL;
 		}
-		if (vlan_do_receive(&skb, !rx_handler))
+		if (vlan_do_receive(&skb, !rx_handler)) {
+			orig_dev = skb->dev;
 			goto another_round;
-		else if (unlikely(!skb))
+		} else if (unlikely(!skb))
 			goto out;
 	}
 
