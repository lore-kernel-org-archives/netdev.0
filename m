From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH v2 net] af_packet: block BH in prb_shutdown_retire_blk_timer()
Date: Fri, 29 Nov 2013 09:53:23 +0100
Message-ID: <1385715203-14712-1-git-send-email-vfalico@redhat.com>
Cc: jstancek@redhat.com, Veaceslav Falico <vfalico@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Willem de Bruijn <willemb@google.com>,
	Phil Sutter <phil@nwl.cc>, Eric Dumazet <edumazet@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43252 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753780Ab3K2IxE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Nov 2013 03:53:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently we're using plain spin_lock() in prb_shutdown_retire_blk_timer(),
however the timer might fire right in the middle and thus try to re-aquire
the same spinlock, leaving us in a endless loop.

To fix that, use the spin_lock_bh() to block it.

CC: "David S. Miller" <davem@davemloft.net>
CC: Daniel Borkmann <dborkman@redhat.com>
CC: Willem de Bruijn <willemb@google.com>
CC: Phil Sutter <phil@nwl.cc>
CC: Eric Dumazet <edumazet@google.com>
Reported-by: Jan Stancek <jstancek@redhat.com>
Tested-by: Jan Stancek <jstancek@redhat.com>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---

Notes:
    v1 -> v2:
    Per Eric's suggestion, reward the commit message to actually match the
    patch (thanks a lot!).

 net/packet/af_packet.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index ac27c86..ba2548b 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -439,9 +439,9 @@ static void prb_shutdown_retire_blk_timer(struct packet_sock *po,
 
 	pkc = tx_ring ? &po->tx_ring.prb_bdqc : &po->rx_ring.prb_bdqc;
 
-	spin_lock(&rb_queue->lock);
+	spin_lock_bh(&rb_queue->lock);
 	pkc->delete_blk_timer = 1;
-	spin_unlock(&rb_queue->lock);
+	spin_unlock_bh(&rb_queue->lock);
 
 	prb_del_retire_blk_timer(pkc);
 }
-- 
1.8.4
