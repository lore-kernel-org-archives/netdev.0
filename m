From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net] netlink: reset network header before passing to taps
Date: Thu,  7 Aug 2014 22:22:47 +0200
Message-ID: <1407442967-2109-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, marcel@holtmann.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8679 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752614AbaHGUWy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Aug 2014 16:22:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netlink doesn't set any network header offset thus when the skb is
being passed to tap devices via dev_queue_xmit_nit(), it emits klog
false positives due to it being unset like:

  ...
  [  124.990397] protocol 0000 is buggy, dev nlmon0
  [  124.990411] protocol 0000 is buggy, dev nlmon0
  ...

So just reset the network header before passing to the device; for
packet sockets that just means nothing will change - mac and net
offset hold the same value just as before.

Reported-by: Marcel Holtmann <marcel@holtmann.org>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/netlink/af_netlink.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index a324b4b..2e152e5 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -213,7 +213,7 @@ static int __netlink_deliver_tap_skb(struct sk_buff *skb,
 		nskb->protocol = htons((u16) sk->sk_protocol);
 		nskb->pkt_type = netlink_is_kernel(sk) ?
 				 PACKET_KERNEL : PACKET_USER;
-
+		skb_reset_network_header(nskb);
 		ret = dev_queue_xmit(nskb);
 		if (unlikely(ret > 0))
 			ret = net_xmit_errno(ret);
-- 
1.7.11.7
