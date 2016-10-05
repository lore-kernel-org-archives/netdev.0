From: Anoob Soman <anoob.soman@citrix.com>
Subject: [PATCH net] packet: call fanout_release, while UNREGISTERING a netdev
Date: Wed, 5 Oct 2016 15:12:54 +0100
Message-ID: <1475676774-18726-1-git-send-email-anoob.soman@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Anoob Soman <anoob.soman@citrix.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:53959 "EHLO
        SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754222AbcJEONJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Oct 2016 10:13:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If a socket has FANOUT sockopt set, a new proto_hook is registered
as part of fanout_add(). When processing a NETDEV_UNREGISTER event in
af_packet, __fanout_unlink is called for all sockets, but prot_hook which was
registered as part of fanout_add is not removed. Call fanout_release, on a
NETDEV_UNREGISTER, which removes prot_hook and removes fanout from the
fanout_list.

This fixes BUG_ON(!list_empty(&dev->ptype_specific)) in netdev_run_todo()

Signed-off-by: Anoob Soman <anoob.soman@citrix.com>
---
 net/packet/af_packet.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 33a4697..11db0d6 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -3952,6 +3952,7 @@ static int packet_notifier(struct notifier_block *this,
 				}
 				if (msg == NETDEV_UNREGISTER) {
 					packet_cached_dev_reset(po);
+					fanout_release(sk);
 					po->ifindex = -1;
 					if (po->prot_hook.dev)
 						dev_put(po->prot_hook.dev);
-- 
2.7.4
