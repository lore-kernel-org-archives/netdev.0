From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCHv3 net 1/2] net: do not process device backlog during unregistration
Date: Thu,  9 Jul 2015 09:59:09 +0300
Message-ID: <1436425150-5612-2-git-send-email-ja@ssi.bg>
References: <1436425150-5612-1-git-send-email-ja@ssi.bg>
Cc: netdev@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"Vittorio G (VittGam)" <linuxbugs@vittgam.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:55513 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751885AbbGIG7l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jul 2015 02:59:41 -0400
In-Reply-To: <1436425150-5612-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 381c759d9916 ("ipv4: Avoid crashing in ip_error")
fixes a problem where processed packet comes from device
with destroyed inetdev (dev->ip_ptr). This is not expected
because inetdev_destroy is called in NETDEV_UNREGISTER
phase and packets should not be processed after
dev_close_many() and synchronize_net(). Above fix is still
required because inetdev_destroy can be called for other
reasons. But it shows the real problem: backlog can keep
packets for long time and they do not hold reference to
device. Such packets are then delivered to upper levels
at the same time when device is unregistered.
Calling flush_backlog after NETDEV_UNREGISTER_FINAL still
accounts all packets from backlog but before that some packets
continue to be delivered to upper levels long after the
synchronize_net call which is supposed to wait the last
ones. Also, as Eric pointed out, processed packets, mostly
from other devices, can continue to add new packets to backlog.

Fix the problem by moving flush_backlog early, after the
device driver is stopped and before the synchronize_net() call.
Then use netif_running check to make sure we do not add more
packets to backlog. We have to do it in enqueue_to_backlog
context when the local IRQ is disabled. As result, after the
flush_backlog and synchronize_net sequence all packets
should be accounted.

Thanks to Eric W. Biederman for the test script and his
valuable feedback!

Reported-by: Vittorio Gambaletta <linuxbugs@vittgam.net>
Fixes: 6e583ce5242f ("net: eliminate refcounting in backlog queue")
Cc: Eric W. Biederman <ebiederm@xmission.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/core/dev.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 1e57efd..6dd126a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3448,6 +3448,8 @@ static int enqueue_to_backlog(struct sk_buff *skb, int cpu,
 	local_irq_save(flags);
 
 	rps_lock(sd);
+	if (!netif_running(skb->dev))
+		goto drop;
 	qlen = skb_queue_len(&sd->input_pkt_queue);
 	if (qlen <= netdev_max_backlog && !skb_flow_limit(skb, qlen)) {
 		if (qlen) {
@@ -3469,6 +3471,7 @@ enqueue:
 		goto enqueue;
 	}
 
+drop:
 	sd->dropped++;
 	rps_unlock(sd);
 
@@ -6135,6 +6138,7 @@ static void rollback_registered_many(struct list_head *head)
 		unlist_netdevice(dev);
 
 		dev->reg_state = NETREG_UNREGISTERING;
+		on_each_cpu(flush_backlog, dev, 1);
 	}
 
 	synchronize_net();
@@ -6770,8 +6774,6 @@ void netdev_run_todo(void)
 
 		dev->reg_state = NETREG_UNREGISTERED;
 
-		on_each_cpu(flush_backlog, dev, 1);
-
 		netdev_wait_allrefs(dev);
 
 		/* paranoia */
-- 
1.9.3
