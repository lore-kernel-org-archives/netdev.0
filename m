From: Basil Gor <basil.gor@gmail.com>
Subject: [PATCH v3 1/2] vhost-net: fix handle_rx buffer size
Date: Wed, 25 Apr 2012 21:01:15 +0400
Message-ID: <1335373275-336-1-git-send-email-basil.gor@gmail.com>
References: <m1ipgtzwew.fsf@fess.ebiederm.org>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:44641 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755633Ab2DYRCC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2012 13:02:02 -0400
Received: by lbbgf7 with SMTP id gf7so270700lbb.19
        for <netdev@vger.kernel.org>; Wed, 25 Apr 2012 10:02:01 -0700 (PDT)
In-Reply-To: <m1ipgtzwew.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Take vlan header length into account, when vlan id is stored as
vlan_tci. Otherwise tagged packets comming from macvtap will be
truncated.

Signed-off-by: Basil Gor <basil.gor@gmail.com>
---
 drivers/vhost/net.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 1f21d2a..5c17010 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -24,6 +24,7 @@
 #include <linux/if_arp.h>
 #include <linux/if_tun.h>
 #include <linux/if_macvlan.h>
+#include <linux/if_vlan.h>
 
 #include <net/sock.h>
 
@@ -283,8 +284,12 @@ static int peek_head_len(struct sock *sk)
 
 	spin_lock_irqsave(&sk->sk_receive_queue.lock, flags);
 	head = skb_peek(&sk->sk_receive_queue);
-	if (likely(head))
+	if (likely(head)) {
 		len = head->len;
+		if (vlan_tx_tag_present(head))
+			len += VLAN_HLEN;
+	}
+
 	spin_unlock_irqrestore(&sk->sk_receive_queue.lock, flags);
 	return len;
 }
-- 
1.7.6.5
